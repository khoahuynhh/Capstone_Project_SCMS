"""
Model deployment via MQTT notifications.
"""
import hashlib
import json
import logging
import os
from datetime import datetime
from typing import List, Optional

import paho.mqtt.client as mqtt

from config import get_settings
from database.db import SessionLocal
from database.models import ModelVersion

logger = logging.getLogger(__name__)
settings = get_settings()


class ModelDeploymentService:
    """Service for deploying models to edge devices"""

    def __init__(self):
        self.mqtt_client = None

    def connect_mqtt(self):
        """Connect to MQTT broker"""
        try:
            self.mqtt_client = mqtt.Client(client_id="cloud_model_deployment")
            if settings.MQTT_USERNAME:
                self.mqtt_client.username_pw_set(
                    settings.MQTT_USERNAME, settings.MQTT_PASSWORD
                )
            self.mqtt_client.connect(
                settings.MQTT_BROKER,
                settings.MQTT_PORT,
                settings.MQTT_KEEPALIVE,
            )
            self.mqtt_client.loop_start()
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
        db = SessionLocal()
        try:
            model = db.query(ModelVersion).filter(
                ModelVersion.version == model_version
            ).first()

            if not model:
                raise ValueError(f"Model version {model_version} not found")

            checksum = self._calculate_checksum(model.model_path)
            deployment_message = {
                "action": "model_update",
                "version": model.version,
                "model_type": model.model_type,
                "model_format": model.model_format,
                "download_path": f"/api/v1/models/{model.version}/download",
                "model_size_mb": model.model_size_mb,
                "checksum": checksum,
                "deployed_at": datetime.now().isoformat(),
                "target_branches": target_branches or ["all"],
            }

            if target_branches:
                for branch_id in target_branches:
                    topic = f"retail/{branch_id}/model/update"
                    self._publish_update(topic, deployment_message)
            else:
                topic = "retail/all/model/update"
                self._publish_update(topic, deployment_message)

            self._deactivate_other_versions(
                db, model.model_type, exclude_version=model.version
            )
            model.is_active = True
            model.deployed_to_branches = target_branches or ["all"]
            db.commit()

            logger.info(
                f"Model {model_version} deployed to {target_branches or 'all branches'}"
            )

            return {
                "status": "deployed",
                "model_version": model_version,
                "target_branches": target_branches or "all",
                "deployment_time": datetime.now().isoformat(),
            }
        finally:
            db.close()
    
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
        db = SessionLocal()
        try:
            target_model = db.query(ModelVersion).filter(
                ModelVersion.model_type == model_type,
                ModelVersion.version == target_version
            ).first()

            if not target_model:
                raise ValueError(f"Target version {target_version} not found")
        finally:
            db.close()

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
        db = SessionLocal()
        try:
            model = db.query(ModelVersion).filter(
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
        finally:
            db.close()
    
    def _publish_update(self, topic: str, message: dict):
        """Publish deployment message to MQTT"""
        try:
            if self.mqtt_client:
                result = self.mqtt_client.publish(topic, json.dumps(message), qos=1)
                if result.rc != mqtt.MQTT_ERR_SUCCESS:
                    raise RuntimeError(f"MQTT publish failed with code {result.rc}")
                logger.info(f"Published model update to {topic}")
            else:
                logger.warning("MQTT client not connected, cannot publish")
        except Exception as e:
            logger.error(f"Failed to publish model update: {e}")

    def _deactivate_other_versions(self, db, model_type: str, exclude_version: str) -> None:
        """Keep only the deployed version active for a given model type."""
        active_models = db.query(ModelVersion).filter(
            ModelVersion.model_type == model_type,
            ModelVersion.version != exclude_version,
            ModelVersion.is_active == True,
        ).all()
        for item in active_models:
            item.is_active = False
    
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
        if self.mqtt_client:
            try:
                self.mqtt_client.loop_stop()
                self.mqtt_client.disconnect()
            except Exception:
                pass


# Global instance
_deployment_service = None

def get_deployment_service() -> ModelDeploymentService:
    """Get global deployment service instance"""
    global _deployment_service
    if _deployment_service is None:
        _deployment_service = ModelDeploymentService()
        _deployment_service.connect_mqtt()
    return _deployment_service
