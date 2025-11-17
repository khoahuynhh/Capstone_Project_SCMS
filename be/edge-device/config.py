"""
Configuration management for Edge Device
Loads settings from environment variables with sensible defaults
"""
import os
from typing import Optional
from pydantic_settings import BaseSettings
from pydantic import Field


class EdgeSettings(BaseSettings):
    """Edge device settings loaded from environment variables"""
    
    # Device Identity
    BRANCH_ID: str = Field(default="branch_001", env="BRANCH_ID")
    BRANCH_NAME: str = Field(default="Default Branch", env="BRANCH_NAME")
    DEVICE_ID: str = Field(default="edge_001", env="DEVICE_ID")
    
    # Application
    APP_NAME: str = "Edge AI Retail - Edge Device"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = Field(default=False, env="DEBUG")
    
    # Server
    API_HOST: str = Field(default="0.0.0.0", env="API_HOST")
    API_PORT: int = Field(default=8001, env="API_PORT")
    
    # Cloud Server
    CLOUD_API: str = Field(default="http://localhost:8000", env="CLOUD_API")
    CLOUD_API_KEY: Optional[str] = Field(default=None, env="CLOUD_API_KEY")
    CLOUD_API_TIMEOUT: int = Field(default=30, env="CLOUD_API_TIMEOUT")
    
    # Redis (for local caching)
    REDIS_URL: str = Field(default="redis://localhost:6379", env="REDIS_URL")
    CACHE_TTL: int = Field(default=3600, env="CACHE_TTL")  # 1 hour
    
    # MQTT
    MQTT_BROKER: str = Field(default="localhost", env="MQTT_BROKER")
    MQTT_PORT: int = Field(default=1883, env="MQTT_PORT")
    MQTT_USERNAME: Optional[str] = Field(default=None, env="MQTT_USERNAME")
    MQTT_PASSWORD: Optional[str] = Field(default=None, env="MQTT_PASSWORD")
    MQTT_KEEPALIVE: int = Field(default=60, env="MQTT_KEEPALIVE")
    MQTT_QOS: int = Field(default=1, env="MQTT_QOS")
    
    # Camera Settings
    CAMERA_ENABLED: bool = Field(default=True, env="CAMERA_ENABLED")
    CAMERA_INDEX: int = Field(default=0, env="CAMERA_INDEX")
    CAMERA_WIDTH: int = Field(default=640, env="CAMERA_WIDTH")
    CAMERA_HEIGHT: int = Field(default=480, env="CAMERA_HEIGHT")
    CAMERA_FPS: int = Field(default=30, env="CAMERA_FPS")
    CAMERA_MOCK: bool = Field(default=True, env="CAMERA_MOCK")  # Use mock camera for simulation
    
    # Face Detection
    FACE_DETECTION_ENABLED: bool = Field(default=True, env="FACE_DETECTION_ENABLED")
    FACE_MIN_SIZE: int = Field(default=50, env="FACE_MIN_SIZE")
    FACE_DETECTION_CONFIDENCE: float = Field(default=0.7, env="FACE_DETECTION_CONFIDENCE")
    FACE_DETECTION_MODEL_PATH: str = Field(default="./models/face_detector.onnx", env="FACE_DETECTION_MODEL_PATH")
    
    # Recommendation
    RECOMMENDATION_ENABLED: bool = Field(default=True, env="RECOMMENDATION_ENABLED")
    RECOMMENDATION_TOP_K: int = Field(default=5, env="RECOMMENDATION_TOP_K")
    RECOMMENDATION_MODEL_PATH: str = Field(default="./models/recommender.onnx", env="RECOMMENDATION_MODEL_PATH")
    RECOMMENDATION_TIMEOUT_MS: int = Field(default=200, env="RECOMMENDATION_TIMEOUT_MS")
    
    # Model Management
    MODEL_STORAGE_PATH: str = Field(default="./models", env="MODEL_STORAGE_PATH")
    MODEL_AUTO_UPDATE: bool = Field(default=True, env="MODEL_AUTO_UPDATE")
    MODEL_UPDATE_CHECK_INTERVAL: int = Field(default=3600, env="MODEL_UPDATE_CHECK_INTERVAL")  # 1 hour
    
    # Performance
    INFERENCE_BATCH_SIZE: int = Field(default=1, env="INFERENCE_BATCH_SIZE")
    INFERENCE_DEVICE: str = Field(default="cpu", env="INFERENCE_DEVICE")  # cpu, cuda, or tensorrt
    MAX_CONCURRENT_INFERENCES: int = Field(default=2, env="MAX_CONCURRENT_INFERENCES")
    
    # Customer Interaction
    CUSTOMER_WAIT_TIME_MIN: float = Field(default=5.0, env="CUSTOMER_WAIT_TIME_MIN")
    CUSTOMER_WAIT_TIME_MAX: float = Field(default=15.0, env="CUSTOMER_WAIT_TIME_MAX")
    PURCHASE_PROBABILITY: float = Field(default=0.4, env="PURCHASE_PROBABILITY")
    RECOMMENDATION_ACCEPTANCE_RATE: float = Field(default=0.6, env="RECOMMENDATION_ACCEPTANCE_RATE")
    
    # Privacy & Consent
    REQUIRE_CONSENT: bool = Field(default=True, env="REQUIRE_CONSENT")
    STORE_FACE_IMAGES: bool = Field(default=False, env="STORE_FACE_IMAGES")
    ANONYMIZE_DATA: bool = Field(default=True, env="ANONYMIZE_DATA")
    
    # Monitoring
    METRICS_ENABLED: bool = Field(default=True, env="METRICS_ENABLED")
    METRICS_PORT: int = Field(default=9091, env="METRICS_PORT")
    LOG_LEVEL: str = Field(default="INFO", env="LOG_LEVEL")
    
    # Heartbeat
    HEARTBEAT_ENABLED: bool = Field(default=True, env="HEARTBEAT_ENABLED")
    HEARTBEAT_INTERVAL: int = Field(default=60, env="HEARTBEAT_INTERVAL")  # seconds
    
    # Data Sync
    SYNC_ENABLED: bool = Field(default=True, env="SYNC_ENABLED")
    SYNC_INTERVAL: int = Field(default=300, env="SYNC_INTERVAL")  # 5 minutes
    SYNC_BATCH_SIZE: int = Field(default=100, env="SYNC_BATCH_SIZE")
    
    # Federated Learning
    FL_ENABLED: bool = Field(default=True, env="FL_ENABLED")
    FL_LOCAL_EPOCHS: int = Field(default=1, env="FL_LOCAL_EPOCHS")
    FL_BATCH_SIZE: int = Field(default=32, env="FL_BATCH_SIZE")
    FL_LEARNING_RATE: float = Field(default=0.01, env="FL_LEARNING_RATE")
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = True


# Global settings instance
settings = EdgeSettings()


def get_settings() -> EdgeSettings:
    """Get edge device settings"""
    return settings
