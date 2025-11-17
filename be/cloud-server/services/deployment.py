"""
Model Deployment Service
Handles model deployment to edge devices via MQTT
"""
import os
import json
import logging
from typing import List, Optional
from datetime import datetime
import hashlib
from database.db import SessionLocal
from database.models import ModelVersion
from services.mqtt_subscriber import get_mqtt_client
from config import get_settings

logger = logging.getLogger(__name__)
settings = get_settings()


class ModelDeploymentService:
    """Service for deploying models to edge devices"""
    
    def __init__(self):
        self.mqtt_client = None
        self.db = SessionLocal()
    
    def connect_mqtt(self):
        """Connect to MQTT broker"""
        try:
            self.mqtt_client = get_mqtt_client()
            logger.info("Model deployment service connected to MQTT")
        except Exception as e:
            logger.error(f"Failed to connect to MQTT: {e}")
    
    def deploy_model(
        self,
        model_version: str,
        target_branches: Optional[List[str]] = None
    ) -> dict:
        """
        Deploy model to edge devices
        
        Args:
            model_version: Version string of model to deploy
            target_branches: List of branch IDs to deploy to (None = all)
        
        Returns:
            Deployment status dict
        """
        # Get model from database
        model = self.db.query(ModelVersion).filter(
            ModelVersion.version == model_version
        ).first()
        
        if not model:
            raise ValueError(f"Model version {model_version} not found")
        
        # Prepare deployment message
        deployment_message = {
            "action": "model_update",
            "model_version": model.version,
            "model_type": model.model_type,
            "model_path": model.model_path,
            "model_size_mb": model.model_size_mb,
            "model_format": model.model_format,
            "checksum": self._calculate_checksum(model.model_path),
            "deployed_at": datetime.now().isoformat(),
            "target_branches": target_branches or ["all"]
        }
        
        # Publish to MQTT
        if target_branches:
            # Deploy to specific branches
            for branch_id in target_branches:
                topic = f"{settings.MQTT_TOPIC_MODEL_UPDATES}/{branch_id}"
                self._publish_update(topic, deployment_message)
        else:
            # Broadcast to all branches
            topic = f"{settings.MQTT_TOPIC_MODEL_UPDATES}/all"
            self._publish_update(topic, deployment_message)
        
        # Update model status
        model.is_active = True
        model.deployed_to_branches = target_branches or ["all"]
        self.db.commit()
        
        logger.info(f"Model {model_version} deployed to {target_branches or 'all branches'}")
        
        return {
            "status": "deployed",
            "model_version": model_version,
            "target_branches": target_branches or "all",
            "deployment_time": datetime.now().isoformat()
        }
    
    def rollback_model(
        self,
        model_type: str,
        target_version: str,
        target_branches: Optional[List[str]] = None
    ) -> dict:
        """
        Rollback to a previous model version
        
        Args:
            model_type: Type of model to rollback
            target_version: Version to rollback to
            target_branches: Branches to rollback (None = all)
        
        Returns:
            Rollback status dict
        """
        # Get target model
        target_model = self.db.query(ModelVersion).filter(
            ModelVersion.model_type == model_type,
            ModelVersion.version == target_version
        ).first()
        
        if not target_model:
            raise ValueError(f"Target version {target_version} not found")
        
        # Deactivate current active model
        current_model = self.db.query(ModelVersion).filter(
            ModelVersion.model_type == model_type,
            ModelVersion.is_active == True
        ).first()
        
        if current_model:
            current_model.is_active = False
        
        # Deploy target version
        return self.deploy_model(target_version, target_branches)
    
    def check_deployment_status(
        self,
        model_version: str
    ) -> dict:
        """
        Check deployment status of a model
        
        Returns:
            Status dict with deployment info
        """
        model = self.db.query(ModelVersion).filter(
            ModelVersion.version == model_version
        ).first()
        
        if not model:
            raise ValueError(f"Model version {model_version} not found")
        
        return {
            "version": model.version,
            "is_active": model.is_active,
            "deployed_to_branches": model.deployed_to_branches,
            "deployment_time": model.updated_at.isoformat()
        }
    
    def _publish_update(self, topic: str, message: dict):
        """Publish deployment message to MQTT"""
        try:
            if self.mqtt_client:
                self.mqtt_client.publish(
                    topic,
                    json.dumps(message),
                    qos=1  # At least once delivery
                )
                logger.info(f"Published model update to {topic}")
            else:
                logger.warning("MQTT client not connected, cannot publish")
        except Exception as e:
            logger.error(f"Failed to publish model update: {e}")
    
    def _calculate_checksum(self, file_path: str) -> str:
        """Calculate SHA256 checksum of model file"""
        if not os.path.exists(file_path):
            return ""
        
        sha256_hash = hashlib.sha256()
        with open(file_path, "rb") as f:
            for byte_block in iter(lambda: f.read(4096), b""):
                sha256_hash.update(byte_block)
        
        return sha256_hash.hexdigest()
    
    def cleanup_old_models(self, retention_days: int = 30):
        """Remove old model files based on retention policy"""
        from datetime import timedelta
        
        cutoff_date = datetime.now() - timedelta(days=retention_days)
        
        old_models = self.db.query(ModelVersion).filter(
            ModelVersion.created_at < cutoff_date,
            ModelVersion.is_active == False
        ).all()
        
        for model in old_models:
            if model.model_path and os.path.exists(model.model_path):
                try:
                    os.remove(model.model_path)
                    logger.info(f"Removed old model file: {model.model_path}")
                except Exception as e:
                    logger.error(f"Failed to remove model file: {e}")
        
        logger.info(f"Cleaned up {len(old_models)} old models")
    
    def __del__(self):
        """Cleanup on destroy"""
        if self.db:
            self.db.close()


# Global instance
_deployment_service = None

def get_deployment_service() -> ModelDeploymentService:
    """Get global deployment service instance"""
    global _deployment_service
    if _deployment_service is None:
        _deployment_service = ModelDeploymentService()
        _deployment_service.connect_mqtt()
    return _deployment_service
