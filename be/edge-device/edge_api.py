# edge_api.py
import io
import logging
import os

from typing import Any, Dict
from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image
from config import get_settings
from modules.recommender import ProductRecommender
from modules.recommender import fetch_cloud_recommendations
from modules.mqtt_client import MQTTClient
from modules.model import FaceAttrPredictor

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

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

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

# Recommender: gợi ý sản phẩm theo chi nhánh
recommender = ProductRecommender(settings.BRANCH_ID)

# Thông tin định danh edge (có thể lấy từ .env / config)
BRANCH_ID = os.getenv("BRANCH_ID", settings.BRANCH_ID)
DEVICE_ID = os.getenv("DEVICE_ID", settings.DEVICE_ID)

# Mô hình
MODEL_STORAGE_PATH = os.getenv("MODEL_STORAGE_PATH", "models")
MODEL_DIR = os.path.join(BASE_DIR, MODEL_STORAGE_PATH)
MODEL_PATH = os.path.join(MODEL_DIR, "best_model.pth")
attr_predictor = None
try:
    attr_predictor = FaceAttrPredictor(
        ckpt_path=MODEL_PATH,
        backbone_name="resnet50_pretrained",
        emo_classes=7,
    )
except Exception as e:
    print(f"Lỗi khởi tạo mô hình Face Attributes: {e}")
    attr_predictor = None


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


# ========= FACE ANALYSIS =========
@app.post("/face/analysis")
async def face_identify(file: UploadFile = File(...)) -> Dict[str, Any]:
    try:
        # 1. Đọc và kiểm tra ảnh từ request
        image_bytes = await file.read()
        try:
            pil_img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        except Exception:
            raise HTTPException(status_code=400, detail="Invalid image file")

        # 2. Lấy Face Attributes trực tiếp từ model.py (Age, Gender, Emotion)
        if attr_predictor is None:
            raise HTTPException(
                status_code=500, detail="Face attribute model is not loaded"
            )

        attributes = attr_predictor.predict(pil_img)

        # 3. Bỏ qua Embedding & Nhận diện (Mặc định là khách vãng lai/ẩn danh)
        customer_id = None
        similarity = 0.0

        # 4. Lấy gợi ý sản phẩm (Local) dựa hoàn toàn vào các thuộc tính khuôn mặt
        recommendations = recommender.recommend_products(
            face_attributes=attributes,
            customer_id=customer_id,  # Truyền None để recommender biết đây là khách mới
        )

        # 5. Trả về kết quả cho Frontend
        return {
            "success": True,
            "branch_id": BRANCH_ID,
            "device_id": DEVICE_ID,
            "customer_id": customer_id,  # Sẽ là None
            "similarity": similarity,  # Sẽ là 0.0
            "face_attributes": attributes,  # Ví dụ: {'age': 25, 'gender': 'Male', 'emotion': 'Happy'}
            "recommendations": recommendations,
            "source": "local_attributes_only",  # Đổi source để FE biết dữ liệu lấy từ đâu
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Error in /face/analysis: %s", e)
        raise HTTPException(
            status_code=500, detail="Internal server error on edge device"
        )
