"""
Configuration management for Cloud Server
Loads settings from environment variables with sensible defaults
"""

import os
from typing import Optional
from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import Field
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
ROOT_DIR = BASE_DIR.parent


class Settings(BaseSettings):
    """Application settings loaded from environment variables"""

    model_config = SettingsConfigDict(
        env_file=ROOT_DIR / ".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore",
    )

    # Application
    APP_NAME: str = "Edge AI Retail - Cloud Server"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = Field(default=False)
    ENVIRONMENT: str = Field(
        default="development"
    )  # development, staging, production

    # Server
    HOST: str = Field(default="0.0.0.0")
    PORT: int = Field(default=8000)
    WORKERS: int = Field(default=4)

    # Database
    DATABASE_URL: str | None = Field(default=None)
    DATABASE_POOL_SIZE: int = Field(default=20)
    DATABASE_MAX_OVERFLOW: int = Field(default=10)
    POSTGRES_USER: str = Field(default="admin")
    POSTGRES_PASSWORD: str = Field(default="admin123")
    POSTGRES_DB: str = Field(default="localhost")
    PRODUCT_CSV_PATH: str = Field(
        default="./cloud-server/data/Products.csv"
    )

    # Redis
    REDIS_URL: str = Field(default="redis://localhost:6379")
    REDIS_TTL: int = Field(default=3600)  # 1 hour

    # MQTT
    MQTT_BROKER: str = Field(default="localhost")
    MQTT_PORT: int = Field(default=1883)
    MQTT_USERNAME: Optional[str] = Field(default=None)
    MQTT_PASSWORD: Optional[str] = Field(default=None)
    MQTT_KEEPALIVE: int = Field(default=60)

    # MQTT Topics
    MQTT_TOPIC_RECOMMENDATIONS: str = "retail/recommendations"
    MQTT_TOPIC_TRANSACTIONS: str = "retail/transactions"
    MQTT_TOPIC_MODEL_UPDATES: str = "retail/model_updates"
    MQTT_TOPIC_EDGE_STATUS: str = "retail/edge_status"
    MQTT_TOPIC_FEDERATED_UPDATES: str = "retail/federated/updates"

    # Model Storage
    MODEL_STORAGE_PATH: str = Field(default="./models")
    MODEL_MAX_SIZE_MB: int = Field(default=500)
    MODEL_RETENTION_DAYS: int = Field(default=30)

    # Federated Learning
    FL_AGGREGATION_INTERVAL_HOURS: int = Field(
        default=24
    )
    FL_MIN_CLIENTS: int = Field(default=2)
    FL_BYZANTINE_TOLERANCE: float = Field(
        default=0.2
    )  # 20% malicious clients
    FL_AGGREGATION_METHOD: str = Field(
        default="fedavg"
    )  # fedavg, krum, trimmed_mean

    # Privacy & Compliance
    DATA_RETENTION_DAYS: int = Field(default=90)
    FACE_IMAGE_RETENTION_HOURS: int = Field(
        default=0
    )  # 0 = don't store
    ANONYMIZE_CUSTOMER_DATA: bool = Field(default=True)
    GDPR_ENABLED: bool = Field(default=True)

    # Security
    API_KEY_ENABLED: bool = Field(default=False)
    JWT_SECRET_KEY: str = Field(
        default="change-this-secret-key-in-production"
    )
    JWT_ALGORITHM: str = Field(default="HS256")
    JWT_EXPIRATION_MINUTES: int = Field(default=30)
    ADMIN_API_KEY: Optional[str] = Field(default=None)

    # Rate Limiting
    RATE_LIMIT_ENABLED: bool = Field(default=True)
    RATE_LIMIT_PER_MINUTE: int = Field(default=60)
    RATE_LIMIT_PER_HOUR: int = Field(default=1000)

    # Monitoring
    PROMETHEUS_ENABLED: bool = Field(default=True)
    METRICS_PORT: int = Field(default=9090)
    LOG_LEVEL: str = Field(default="INFO")

    # Training & Retraining
    AUTO_RETRAIN_ENABLED: bool = Field(default=True)
    RETRAIN_SCHEDULE_HOUR: int = Field(
        default=2
    )  # 2 AM daily
    MIN_TRANSACTIONS_FOR_RETRAIN: int = Field(
        default=100
    )

    # A/B Testing
    AB_TEST_ENABLED: bool = Field(default=True)
    AB_TEST_SPLIT_RATIO: float = Field(
        default=0.5
    )  # 50/50 split

    # Analytics
    ANALYTICS_AGGREGATION_INTERVAL_HOURS: int = Field(
        default=1
    )

    # Recommendation Settings
    RECOMMENDATION_TOP_K: int = Field(default=5)
    RECOMMENDATION_TIMEOUT_MS: int = Field(default=200)

    # Edge Device Settings
    EDGE_HEARTBEAT_INTERVAL_SECONDS: int = Field(
        default=60
    )
    EDGE_OFFLINE_THRESHOLD_MINUTES: int = Field(
        default=5
    )


# Global settings instance
settings = Settings()


def get_settings() -> Settings:
    """Get application settings"""
    return settings
