# edge_api.py
import io
import logging
import os
import time
from typing import Any, Dict

import cv2
import numpy as np
from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image

from config import get_settings
from modules.face_detector import FaceDetector
from modules.recommender import ProductRecommender
from modules.kafka_client import EdgeKafkaProducer
from modules.recommender import fetch_cloud_recommendations

logger = logging.getLogger(__name__)
logging.basicConfig(
    level=logging.INFO,
    format="[%(asctime)s] [%(levelname)s] %(name)s - %(message)s",
)

settings = get_settings()

app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
)

# ========= CORS =========
# Cho phép FE (React) gọi từ browser
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # TODO: sau này nên giới hạn origin cho an toàn hơn
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ========= GLOBAL OBJECTS =========

# FaceDetector: bên trong đã load BlazeFace + model nhận diện .pth
face_detector = FaceDetector(
    model_path=settings.FACE_DETECTION_MODEL_PATH,
    min_conf=settings.FACE_DETECTION_CONFIDENCE,
)

# Recommender: gợi ý sản phẩm theo chi nhánh
recommender = ProductRecommender(settings.BRANCH_ID)

# Kafka producer để đẩy event về server
kafka_producer = EdgeKafkaProducer()

# Thông tin định danh edge (có thể lấy từ .env / config)
BRANCH_ID = os.getenv("BRANCH_ID", settings.BRANCH_ID)
DEVICE_ID = os.getenv("DEVICE_ID", settings.DEVICE_ID)


# ========= HEALTHCHECK =========
@app.get("/health")
def health_check() -> Dict[str, Any]:
    """
    Endpoint đơn giản để kiểm tra edge API còn sống không.
    Dùng cho monitoring hoặc FE gọi trước khi nhận diện.
    """
    return {
        "status": "ok",
        "branch_id": BRANCH_ID,
        "device_id": DEVICE_ID,
        "app": settings.APP_NAME,
        "version": settings.APP_VERSION,
    }


# ========= FACE IDENTIFICATION =========
@app.post("/face/identify")
async def face_identify(file: UploadFile = File(...)) -> Dict[str, Any]:
    """
    Nhận 1 frame từ FE (upload file image), chạy nhận diện khuôn mặt trên edge:
      - Dùng FaceDetector để detect + extract embedding
      - Gọi ProductRecommender để lấy danh sách gợi ý
      - Trả JSON cho FE để hiển thị UI
      - Đồng thời đẩy 1 event vào Kafka cho backend xử lý / lưu DB / analytics
    """
    try:
        # ----- 1. Đọc ảnh từ FE -----
        image_bytes = await file.read()

        try:
            pil_img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        except Exception as e:
            logger.warning("Không đọc được ảnh từ upload: %s", e)
            raise HTTPException(status_code=400, detail="Invalid image file")

        # PIL → numpy RGB → BGR (cho đồng bộ với luồng OpenCV)
        rgb = np.array(pil_img)
        frame_bgr = cv2.cvtColor(rgb, cv2.COLOR_RGB2BGR)

        # ----- 2. Nhận diện khuôn mặt trên frame -----
        face_data = face_detector.detect_and_extract(frame_bgr)
        if face_data is None:
            logger.info("Không phát hiện khuôn mặt nào trong frame")

            # Gửi event 'no_face' lên Kafka (nếu muốn track)
            event = {
                "event_type": "no_face",
                "branch_id": BRANCH_ID,
                "device_id": DEVICE_ID,
                "timestamp": time.time(),
            }
            kafka_producer.publish_face_event(event)

            return {
                "success": False,
                "reason": "no_face_detected",
            }

        # face_data expected fields:
        # - 'attributes': dict (age_group, gender, ...)
        # - 'embedding': list[float]
        # - 'customer_id': str
        # - 'similarity': float (nếu FaceDetector + FaceVerification có trả)
        # customer_id = face_data.get("customer_id")
        # attributes = face_data.get("attributes") or {}
        # similarity = float(face_data.get("similarity", 0.0))
        embedding = face_data.get("embedding")  # có thể None nếu bạn không trả

        logger.info(
            "Face recognized: customer_id=%s similarity=%.3f branch=%s device=%s",
            customer_id,
            # similarity,
            BRANCH_ID,
            DEVICE_ID,
        )

        # ----- 3. Lấy gợi ý sản phẩm từ recommender -----
        try:
            recommendations = await fetch_cloud_recommendations(
                branch_id=BRANCH_ID,
                customer_id=customer_id,
                top_k=5,
            )
        except Exception as e:
            logger.warning("Cloud /recommend failed, fallback local recommender: %s", e)
            recommendations = recommender.recommend_products(
                face_attributes=attributes,
                customer_id=customer_id,
            )

        # ----- 4. Gửi event lên Kafka -----
        # Event này sẽ được backend server consume để:
        # - lưu vào DB
        # - làm analytics
        # - trigger marketing / automation, ...

        event = {
            "event_type": "face_recognized",
            "branch_id": BRANCH_ID,
            "device_id": DEVICE_ID,
            "customer_id": customer_id,
            "similarity": similarity,
            "attributes": attributes,
            "timestamp": time.time(),
        }
        kafka_producer.publish_face_event(event)

        # ----- 5. Trả response cho FE -----
        return {
            "success": True,
            "branch_id": BRANCH_ID,
            "device_id": DEVICE_ID,
            "customer_id": customer_id,
            "similarity": similarity,
            "face_attributes": attributes,
            # embedding có thể không cần trả cho FE, tuỳ use-case:
            "embedding": embedding,
            "recommendations": recommendations,
        }

    except HTTPException:
        # đã raise ở trên với detail rõ ràng
        raise
    except Exception as e:
        logger.exception("Error in /face/identify: %s", e)
        raise HTTPException(
            status_code=500, detail="Internal server error on edge device"
        )
