import io
import logging
import os
import time
from datetime import datetime, timezone
from threading import Event, Thread
from typing import Any, Dict

from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Histogram, generate_latest
from starlette.responses import Response

from config import get_settings
from modules.model import FaceAttrPredictor
from modules.mqtt_client import MQTTClient

logger = logging.getLogger(__name__)
logging.basicConfig(
    level=logging.INFO,
    format="[%(asctime)s] [%(levelname)s] %(name)s - %(message)s",
)

settings = get_settings()
app = FastAPI(title=settings.APP_NAME, version=settings.APP_VERSION)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
BRANCH_ID = os.getenv("BRANCH_ID", settings.BRANCH_ID)
DEVICE_ID = os.getenv("DEVICE_ID", settings.DEVICE_ID)
heartbeat_stop = Event()
heartbeat_thread: Thread | None = None
mqtt_client = MQTTClient(BRANCH_ID)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

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
except Exception as exc:
    logger.error("Face attribute model could not be loaded: %s", exc)

INFERENCE_COUNTER = Counter(
    "edge_api_face_analysis_total", "Total face analysis requests handled by edge API"
)
INFERENCE_ERRORS = Counter(
    "edge_api_face_analysis_errors_total", "Total face analysis failures"
)
INFERENCE_LATENCY = Histogram(
    "edge_api_face_analysis_latency_seconds", "Face analysis latency in seconds"
)


def heartbeat_payload(status: str) -> Dict[str, Any]:
    return {
        "branch_id": BRANCH_ID,
        "device_id": DEVICE_ID,
        "status": status,
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "app": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "model_loaded": attr_predictor is not None,
        "model_path": MODEL_PATH,
    }


def publish_edge_status(event_type: str, status: str) -> None:
    if not settings.HEARTBEAT_ENABLED:
        return
    mqtt_client.publish_event(event_type, heartbeat_payload(status))


def heartbeat_loop() -> None:
    interval = max(5, int(settings.HEARTBEAT_INTERVAL))
    publish_edge_status("edge_online", "online")
    while not heartbeat_stop.wait(interval):
        publish_edge_status("edge_heartbeat", "online")


@app.on_event("startup")
def startup() -> None:
    global heartbeat_thread
    if not settings.HEARTBEAT_ENABLED:
        return

    try:
        mqtt_client.connect()
    except Exception as exc:
        logger.warning("MQTT heartbeat disabled: %s", exc)
        return

    heartbeat_stop.clear()
    heartbeat_thread = Thread(target=heartbeat_loop, name="edge-heartbeat", daemon=True)
    heartbeat_thread.start()


@app.on_event("shutdown")
def shutdown() -> None:
    heartbeat_stop.set()
    publish_edge_status("edge_offline", "offline")
    try:
        mqtt_client.disconnect()
    except Exception:
        pass


def build_age_group(age: int | None) -> str:
    if age is None:
        return "unknown"
    if age < 18:
        return "UNDER_18"
    if age <= 24:
        return "18_24"
    if age <= 34:
        return "25_34"
    if age <= 44:
        return "35_44"
    return "45_PLUS"


def normalize_attributes(prediction: Dict[str, Any]) -> Dict[str, Any]:
    age = prediction.get("age")
    try:
        age = int(age)
    except (TypeError, ValueError):
        age = None

    gender = prediction.get("gender_label") or prediction.get("gender")
    emotion = prediction.get("emotion_label") or prediction.get("emotion")

    return {
        **prediction,
        "age": age,
        "age_group": build_age_group(age),
        "gender": str(gender).lower() if gender else None,
        "emotion": str(emotion).lower() if emotion else None,
    }


@app.get("/health")
def health_check() -> Dict[str, Any]:
    return {
        "status": "ok",
        "branch_id": BRANCH_ID,
        "device_id": DEVICE_ID,
        "app": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "model_loaded": attr_predictor is not None,
        "mqtt_connected": mqtt_client.connected,
        "heartbeat_enabled": settings.HEARTBEAT_ENABLED,
    }


@app.get("/metrics")
def metrics() -> Response:
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)


@app.post("/face/analysis")
async def face_analysis(file: UploadFile = File(...)) -> Dict[str, Any]:
    start = time.time()
    try:
        image_bytes = await file.read()
        try:
            image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        except Exception:
            raise HTTPException(status_code=400, detail="Invalid image file")

        if attr_predictor is None:
            raise HTTPException(
                status_code=500, detail="Face attribute model is not loaded"
            )

        attributes = normalize_attributes(attr_predictor.predict(image))

        latency = time.time() - start
        INFERENCE_COUNTER.inc()
        INFERENCE_LATENCY.observe(latency)

        return {
            "success": True,
            "branch_id": BRANCH_ID,
            "device_id": DEVICE_ID,
            "age": attributes["age"],
            "age_group": attributes["age_group"],
            "gender": attributes["gender"],
            "emotion": attributes["emotion"],
            "face_attributes": attributes,
            "source": "edge_face_attribute_model",
            "latency_ms": round(latency * 1000, 2),
        }
    except HTTPException:
        INFERENCE_ERRORS.inc()
        raise
    except Exception as exc:
        INFERENCE_ERRORS.inc()
        logger.exception("Error in /face/analysis: %s", exc)
        raise HTTPException(
            status_code=500, detail="Internal server error on edge device"
        )
