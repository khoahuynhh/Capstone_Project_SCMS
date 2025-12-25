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
from modules.recommender import fetch_cloud_recommendations
from modules.mqtt_client import MQTTClient

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
    try:
        image_bytes = await file.read()
        try:
            pil_img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        except Exception:
            raise HTTPException(status_code=400, detail="Invalid image file")

        frame_bgr = cv2.cvtColor(np.array(pil_img), cv2.COLOR_RGB2BGR)

        face_data = face_detector.detect_and_extract(frame_bgr)
        if face_data is None:
            return {
                "success": False,
                "reason": "no_face_detected",
                "branch_id": BRANCH_ID,
                "device_id": DEVICE_ID,
            }

        embedding = face_data.get("embedding")
        attributes = face_data.get("attributes") or {}

        # 1) MQTT RPC -> cloud identify + recommendations (realtime)
        resp = MQTTClient.request_face_identify(
            embedding=embedding,
            attributes=attributes,
            timeout=1.0,  # tune
        )

        # 2) Parse result + fallback
        if resp.get("success"):
            customer_id = resp.get("customer_id")
            similarity = float(resp.get("similarity", 0.0))
            recommendations = resp.get("recommendations", [])
            source = "cloud_mqtt"
        else:
            # fallback local (tùy bạn: local verify + local recs)
            customer_id = face_data.get("customer_id")  # nếu local detector có verify
            similarity = float(face_data.get("similarity", 0.0))
            recommendations = recommender.recommend_products(
                face_attributes=attributes,
                customer_id=customer_id,
            )
            source = f"fallback_{resp.get('reason','unknown')}"

        # 4) Response cho FE
        return {
            "success": True,
            "branch_id": BRANCH_ID,
            "device_id": DEVICE_ID,
            "customer_id": customer_id,
            "similarity": similarity,
            "face_attributes": attributes,
            "recommendations": recommendations,
            "source": source,
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Error in /face/identify: %s", e)
        raise HTTPException(
            status_code=500, detail="Internal server error on edge device"
        )
