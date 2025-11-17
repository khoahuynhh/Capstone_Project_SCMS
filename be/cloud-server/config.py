"""
Configuration management for Cloud Server
Loads settings from environment variables with sensible defaults
"""
import os
from typing import Optional
from pydantic_settings import BaseSettings
from pydantic import Field


class Settings(BaseSettings):
    """Application settings loaded from environment variables"""
    
    # Application
    APP_NAME: str = "Edge AI Retail - Cloud Server"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = Field(default=False, env="DEBUG")
    ENVIRONMENT: str = Field(default="development", env="ENVIRONMENT")  # development, staging, production
    
    # Server
    HOST: str = Field(default="0.0.0.0", env="HOST")
    PORT: int = Field(default=8000, env="PORT")
    WORKERS: int = Field(default=4, env="WORKERS")
    
    # Database
    DATABASE_URL: str = Field(
        default="postgresql://admin:admin123@localhost:5432/retail_db",
        env="DATABASE_URL"
    )
    DATABASE_POOL_SIZE: int = Field(default=20, env="DATABASE_POOL_SIZE")
    DATABASE_MAX_OVERFLOW: int = Field(default=10, env="DATABASE_MAX_OVERFLOW")
    
    # Redis
    REDIS_URL: str = Field(default="redis://localhost:6379", env="REDIS_URL")
    REDIS_TTL: int = Field(default=3600, env="REDIS_TTL")  # 1 hour
    
    # MQTT
    MQTT_BROKER: str = Field(default="localhost", env="MQTT_BROKER")
    MQTT_PORT: int = Field(default=1883, env="MQTT_PORT")
    MQTT_USERNAME: Optional[str] = Field(default=None, env="MQTT_USERNAME")
    MQTT_PASSWORD: Optional[str] = Field(default=None, env="MQTT_PASSWORD")
    MQTT_KEEPALIVE: int = Field(default=60, env="MQTT_KEEPALIVE")
    
    # MQTT Topics
    MQTT_TOPIC_RECOMMENDATIONS: str = "retail/recommendations"
    MQTT_TOPIC_TRANSACTIONS: str = "retail/transactions"
    MQTT_TOPIC_MODEL_UPDATES: str = "retail/model_updates"
    MQTT_TOPIC_EDGE_STATUS: str = "retail/edge_status"
    MQTT_TOPIC_FEDERATED_UPDATES: str = "retail/federated/updates"
    
    # Model Storage
    MODEL_STORAGE_PATH: str = Field(default="./models", env="MODEL_STORAGE_PATH")
    MODEL_MAX_SIZE_MB: int = Field(default=500, env="MODEL_MAX_SIZE_MB")
    MODEL_RETENTION_DAYS: int = Field(default=30, env="MODEL_RETENTION_DAYS")
    
    # Federated Learning
    FL_AGGREGATION_INTERVAL_HOURS: int = Field(default=24, env="FL_AGGREGATION_INTERVAL_HOURS")
    FL_MIN_CLIENTS: int = Field(default=2, env="FL_MIN_CLIENTS")
    FL_BYZANTINE_TOLERANCE: float = Field(default=0.2, env="FL_BYZANTINE_TOLERANCE")  # 20% malicious clients
    FL_AGGREGATION_METHOD: str = Field(default="fedavg", env="FL_AGGREGATION_METHOD")  # fedavg, krum, trimmed_mean
    
    # Privacy & Compliance
    DATA_RETENTION_DAYS: int = Field(default=90, env="DATA_RETENTION_DAYS")
    FACE_IMAGE_RETENTION_HOURS: int = Field(default=0, env="FACE_IMAGE_RETENTION_HOURS")  # 0 = don't store
    ANONYMIZE_CUSTOMER_DATA: bool = Field(default=True, env="ANONYMIZE_CUSTOMER_DATA")
    GDPR_ENABLED: bool = Field(default=True, env="GDPR_ENABLED")
    
    # Security
    API_KEY_ENABLED: bool = Field(default=False, env="API_KEY_ENABLED")
    JWT_SECRET_KEY: str = Field(default="change-this-secret-key-in-production", env="JWT_SECRET_KEY")
    JWT_ALGORITHM: str = Field(default="HS256", env="JWT_ALGORITHM")
    JWT_EXPIRATION_MINUTES: int = Field(default=30, env="JWT_EXPIRATION_MINUTES")
    ADMIN_API_KEY: Optional[str] = Field(default=None, env="ADMIN_API_KEY")
    
    # Rate Limiting
    RATE_LIMIT_ENABLED: bool = Field(default=True, env="RATE_LIMIT_ENABLED")
    RATE_LIMIT_PER_MINUTE: int = Field(default=60, env="RATE_LIMIT_PER_MINUTE")
    RATE_LIMIT_PER_HOUR: int = Field(default=1000, env="RATE_LIMIT_PER_HOUR")
    
    # Monitoring
    PROMETHEUS_ENABLED: bool = Field(default=True, env="PROMETHEUS_ENABLED")
    METRICS_PORT: int = Field(default=9090, env="METRICS_PORT")
    LOG_LEVEL: str = Field(default="INFO", env="LOG_LEVEL")
    
    # Training & Retraining
    AUTO_RETRAIN_ENABLED: bool = Field(default=True, env="AUTO_RETRAIN_ENABLED")
    RETRAIN_SCHEDULE_HOUR: int = Field(default=2, env="RETRAIN_SCHEDULE_HOUR")  # 2 AM daily
    MIN_TRANSACTIONS_FOR_RETRAIN: int = Field(default=100, env="MIN_TRANSACTIONS_FOR_RETRAIN")
    
    # A/B Testing
    AB_TEST_ENABLED: bool = Field(default=True, env="AB_TEST_ENABLED")
    AB_TEST_SPLIT_RATIO: float = Field(default=0.5, env="AB_TEST_SPLIT_RATIO")  # 50/50 split
    
    # Analytics
    ANALYTICS_AGGREGATION_INTERVAL_HOURS: int = Field(default=1, env="ANALYTICS_AGGREGATION_INTERVAL_HOURS")
    
    # Recommendation Settings
    RECOMMENDATION_TOP_K: int = Field(default=5, env="RECOMMENDATION_TOP_K")
    RECOMMENDATION_TIMEOUT_MS: int = Field(default=200, env="RECOMMENDATION_TIMEOUT_MS")
    
    # Edge Device Settings
    EDGE_HEARTBEAT_INTERVAL_SECONDS: int = Field(default=60, env="EDGE_HEARTBEAT_INTERVAL_SECONDS")
    EDGE_OFFLINE_THRESHOLD_MINUTES: int = Field(default=5, env="EDGE_OFFLINE_THRESHOLD_MINUTES")
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = True


# Global settings instance
settings = Settings()


def get_settings() -> Settings:
    """Get application settings"""
    return settings
