"""
Configuration management for Edge Device
Loads settings from environment variables with sensible defaults
"""
import os
from typing import Optional
from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import Field, field_validator


class EdgeSettings(BaseSettings):
    """Edge device settings loaded from environment variables"""

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore",
    )
    
    # Device Identity
    BRANCH_ID: str = Field(default="HCM_Q1")
    BRANCH_NAME: str = Field(default="Mart Quan 1")
    DEVICE_ID: str = Field(default="EDGE_HCM_Q1_01")
    
    # Application
    APP_NAME: str = "Edge AI Retail - Edge Device"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = Field(default=False)

    @field_validator("DEBUG", mode="before")
    @classmethod
    def normalize_debug(cls, value):
        if isinstance(value, str) and value.lower() in {"release", "prod", "production"}:
            return False
        return value
    
    # Server
    API_HOST: str = Field(default="0.0.0.0")
    API_PORT: int = Field(default=8001)
    
    # Cloud Server
    CLOUD_API: str = Field(default="http://localhost:8000")
    CLOUD_API_KEY: Optional[str] = Field(default=None)
    CLOUD_API_TIMEOUT: int = Field(default=30)
    
    # Redis (for local caching)
    REDIS_URL: str = Field(default="redis://localhost:6379")
    CACHE_TTL: int = Field(default=3600)  # 1 hour
    
    # MQTT
    MQTT_BROKER: str = Field(default="localhost")
    MQTT_PORT: int = Field(default=1883)
    MQTT_USERNAME: Optional[str] = Field(default=None)
    MQTT_PASSWORD: Optional[str] = Field(default=None)
    MQTT_KEEPALIVE: int = Field(default=60)
    MQTT_QOS: int = Field(default=1)
    
    # Camera Settings
    CAMERA_ENABLED: bool = Field(default=True)
    CAMERA_INDEX: int = Field(default=0)
    CAMERA_WIDTH: int = Field(default=640)
    CAMERA_HEIGHT: int = Field(default=480)
    CAMERA_FPS: int = Field(default=30)
    CAMERA_MOCK: bool = Field(default=True)  # Use mock camera for simulation
    
    # Face Detection
    FACE_PREPROCESSING_ENABLED: bool = Field(default=False)
    FACE_DETECTION_ENABLED: bool = Field(default=True)
    FACE_MIN_SIZE: int = Field(default=50)
    FACE_DETECTION_CONFIDENCE: float = Field(default=0.7)
    FACE_DETECTION_MODEL_PATH: str = Field(default="")
    
    # Recommendation
    RECOMMENDATION_ENABLED: bool = Field(default=True)
    RECOMMENDATION_TOP_K: int = Field(default=5)
    RECOMMENDATION_MODEL_PATH: str = Field(default="./models/recommender.onnx")
    RECOMMENDATION_TIMEOUT_MS: int = Field(default=200)
    
    # Model Management
    MODEL_STORAGE_PATH: str = Field(default="./models")
    FACE_ATTR_MODEL_FILE: str = Field(default="best_model_v2_embedder.onnx")
    MODEL_AUTO_UPDATE: bool = Field(default=True)
    MODEL_UPDATE_CHECK_INTERVAL: int = Field(default=3600)  # 1 hour
    
    # Performance
    INFERENCE_BATCH_SIZE: int = Field(default=1)
    INFERENCE_DEVICE: str = Field(default="cpu")  # cpu, cuda, or tensorrt
    MAX_CONCURRENT_INFERENCES: int = Field(default=2)
    
    # Customer Interaction
    CUSTOMER_WAIT_TIME_MIN: float = Field(default=5.0)
    CUSTOMER_WAIT_TIME_MAX: float = Field(default=15.0)
    PURCHASE_PROBABILITY: float = Field(default=0.4)
    RECOMMENDATION_ACCEPTANCE_RATE: float = Field(default=0.6)
    
    # Privacy & Consent
    REQUIRE_CONSENT: bool = Field(default=True)
    STORE_FACE_IMAGES: bool = Field(default=False)
    ANONYMIZE_DATA: bool = Field(default=True)
    
    # Monitoring
    METRICS_ENABLED: bool = Field(default=True)
    METRICS_PORT: int = Field(default=9091)
    LOG_LEVEL: str = Field(default="INFO")
    
    # Heartbeat
    HEARTBEAT_ENABLED: bool = Field(default=True)
    HEARTBEAT_INTERVAL: int = Field(default=60)  # seconds
    
    # Data Sync
    SYNC_ENABLED: bool = Field(default=True)
    SYNC_INTERVAL: int = Field(default=300)  # 5 minutes
    SYNC_BATCH_SIZE: int = Field(default=100)
    
    # Federated Learning
    FL_ENABLED: bool = Field(default=True)
    FL_LOCAL_EPOCHS: int = Field(default=1)
    FL_BATCH_SIZE: int = Field(default=32)
    FL_LEARNING_RATE: float = Field(default=0.01)
    

# Global settings instance
settings = EdgeSettings()


def get_settings() -> EdgeSettings:
    """Get edge device settings"""
    return settings
