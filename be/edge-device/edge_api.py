import io
import json
import logging
import os
import shutil
import time
from datetime import datetime, timezone
from threading import Event, Lock, Thread
from typing import Any, Dict

from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
import numpy as np
from PIL import Image
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Histogram, generate_latest
from starlette.responses import Response

from config import get_settings
from modules.mqtt_client import MQTTClient
from modules.onnx_predictor import OnnxFaceAttrPredictor
from modules.preprocessor import FacePreprocessor

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
predictor_lock = Lock()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

MODEL_STORAGE_PATH = os.getenv("MODEL_STORAGE_PATH", settings.MODEL_STORAGE_PATH)
MODEL_DIR = (
    MODEL_STORAGE_PATH
    if os.path.isabs(MODEL_STORAGE_PATH)
    else os.path.normpath(os.path.join(BASE_DIR, MODEL_STORAGE_PATH))
)

KNOWN_FACE_ATTR_MODELS = (
    "best_model_v2_embedder.onnx",
    "best_model.onnx",
    "embedder.onnx",
)


def resolve_model_path() -> str:
    configured_model = os.getenv("FACE_ATTR_MODEL_FILE", settings.FACE_ATTR_MODEL_FILE)
    configured_path = (
        configured_model
        if os.path.isabs(configured_model)
        else os.path.join(MODEL_DIR, configured_model)
    )
    if os.path.exists(configured_path):
        return configured_path

    for file_name in KNOWN_FACE_ATTR_MODELS:
        candidate = os.path.join(MODEL_DIR, file_name)
        if os.path.exists(candidate):
            return candidate

    if os.path.isdir(MODEL_DIR):
        for file_name in sorted(os.listdir(MODEL_DIR)):
            if file_name.lower().endswith(".onnx"):
                return os.path.join(MODEL_DIR, file_name)

    return configured_path


MODEL_PATH = resolve_model_path()

attr_predictor = None
face_preprocessor = None


def resolve_edge_path(path: str) -> str:
    if not path:
        return ""
    if os.path.isabs(path):
        return path
    return os.path.normpath(os.path.join(BASE_DIR, path))


def build_predictor(model_path: str) -> OnnxFaceAttrPredictor:
    extension = os.path.splitext(model_path)[1].lower()
    if extension != ".onnx":
        raise ValueError(f"Unsupported edge model format: {extension or 'unknown'}")
    return OnnxFaceAttrPredictor(model_path)


def load_predictor(model_path: str = MODEL_PATH) -> OnnxFaceAttrPredictor | None:
    try:
        predictor = build_predictor(model_path)
        logger.info("Loaded face attribute model from %s", model_path)
        return predictor
    except Exception as exc:
        logger.error("Face attribute model could not be loaded: %s", exc)
        return None


def install_model(temp_model_path: str, metadata: Dict[str, Any] | None = None) -> None:
    """Atomically replace the active model and reload the predictor in memory."""
    global attr_predictor, MODEL_PATH

    os.makedirs(MODEL_DIR, exist_ok=True)
    model_format = str((metadata or {}).get("model_format") or "").lower().lstrip(".")
    if model_format and model_format != "onnx":
        raise ValueError(f"Unsupported edge model format: {model_format}")

    target_model_path = os.path.join(MODEL_DIR, "best_model.onnx")
    backup_path = f"{target_model_path}.bak"
    old_exists = os.path.exists(target_model_path)

    if old_exists:
        shutil.copy2(target_model_path, backup_path)

    try:
        shutil.move(temp_model_path, target_model_path)
        new_predictor = build_predictor(target_model_path)
        with predictor_lock:
            attr_predictor = new_predictor
            MODEL_PATH = target_model_path
        if os.path.exists(backup_path):
            os.remove(backup_path)
        logger.info("Installed model version %s", (metadata or {}).get("version"))
    except Exception:
        if os.path.exists(temp_model_path):
            os.remove(temp_model_path)
        if not old_exists and os.path.exists(target_model_path):
            os.remove(target_model_path)
        if old_exists and os.path.exists(backup_path):
            shutil.move(backup_path, target_model_path)
            with predictor_lock:
                attr_predictor = load_predictor(target_model_path)
                MODEL_PATH = target_model_path
        raise


attr_predictor = load_predictor(MODEL_PATH)
face_preprocessor = FacePreprocessor(
    detector_model_path=resolve_edge_path(settings.FACE_DETECTION_MODEL_PATH),
    detection_confidence=settings.FACE_DETECTION_CONFIDENCE,
)
mqtt_client = MQTTClient(BRANCH_ID, on_model_update=install_model)

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
        "model_path": MODEL_PATH,
        "model_dir": MODEL_DIR,
        "preprocessing_enabled": settings.FACE_PREPROCESSING_ENABLED,
        "preprocessor_detector": getattr(face_preprocessor, "detector_backend", None),
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

        with predictor_lock:
            predictor = attr_predictor

        if predictor is None:
            raise HTTPException(
                status_code=500, detail="Face attribute model is not loaded"
            )

        inference_image = image
        if settings.FACE_PREPROCESSING_ENABLED:
            image_rgb = np.asarray(image, dtype=np.uint8)
            with predictor_lock:
                inference_image = face_preprocessor.process_rgb_array(image_rgb)

            if inference_image is None:
                raise HTTPException(status_code=422, detail="No usable face detected")

        attributes = normalize_attributes(predictor.predict(inference_image))

        latency = time.time() - start
        INFERENCE_COUNTER.inc()
        INFERENCE_LATENCY.observe(latency)

        response = {
            "success": True,
            "branch_id": BRANCH_ID,
            "device_id": DEVICE_ID,
            "age": attributes["age"],
            "age_group": attributes["age_group"],
            "gender": attributes["gender"],
            "emotion": attributes["emotion"],
            "face_attributes": attributes,
            "source": "edge_face_attribute_model",
            "preprocessed": settings.FACE_PREPROCESSING_ENABLED,
            "latency_ms": round(latency * 1000, 2),
        }

        logger.info(
            "FACE_ANALYSIS_RESPONSE %s",
            json.dumps(response, ensure_ascii=False, default=str),
        )
        return response
    except HTTPException:
        INFERENCE_ERRORS.inc()
        raise
    except Exception as exc:
        INFERENCE_ERRORS.inc()
        logger.exception("Error in /face/analysis: %s", exc)
        raise HTTPException(
            status_code=500, detail="Internal server error on edge device"
        )
