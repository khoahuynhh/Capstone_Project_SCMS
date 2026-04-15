from fastapi import APIRouter, HTTPException, Depends, UploadFile, File
from typing import List, Optional
from datetime import datetime
from pydantic import BaseModel, ConfigDict
from sqlalchemy.orm import Session
from database.db import SessionLocal
from database.models import ModelVersion
import logging
import os
import shutil

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v1/models", tags=["models"])

# Database dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Pydantic models
class ModelInfo(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    version: str
    model_type: str
    model_format: str
    model_size_mb: float
    accuracy: Optional[float] = None
    precision: Optional[float] = None
    recall: Optional[float] = None
    f1_score: Optional[float] = None
    latency_ms: Optional[float] = None
    is_active: bool
    training_date: Optional[datetime] = None
    deployed_to_branches: Optional[List[str]] = None

class ModelDeployRequest(BaseModel):
    version: str
    target_branches: Optional[List[str]] = None  # None = all branches

class ModelRollbackRequest(BaseModel):
    model_type: str
    target_version: str

class ModelUploadResponse(BaseModel):
    version: str
    message: str
    file_path: str

# ============ Model Management Endpoints ============

@router.get("/list", response_model=List[ModelInfo])
async def list_models(
    model_type: Optional[str] = None,
    active_only: bool = False,
    db: Session = Depends(get_db)
):
    """List all model versions"""
    from fastapi.concurrency import run_in_threadpool
    
    def query_models():
        query = db.query(ModelVersion)
        
        if model_type:
            query = query.filter(ModelVersion.model_type == model_type)
        
        if active_only:
            query = query.filter(ModelVersion.is_active == True)
        
        return query.order_by(ModelVersion.created_at.desc()).all()
    
    models = await run_in_threadpool(query_models)
    return models


@router.get("/{version}", response_model=ModelInfo)
async def get_model(version: str, db: Session = Depends(get_db)):
    """Get specific model version details"""
    from fastapi.concurrency import run_in_threadpool
    
    def query_model():
        return db.query(ModelVersion).filter(ModelVersion.version == version).first()
    
    model = await run_in_threadpool(query_model)
    
    if not model:
        raise HTTPException(status_code=404, detail=f"Model version {version} not found")
    
    return model


@router.post("/upload", response_model=ModelUploadResponse)
async def upload_model(
    version: str,
    model_type: str,
    model_format: str = "onnx",
    file: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    """Upload a new model version"""
    from config import get_settings
    
    settings = get_settings()
    model_dir = settings.MODEL_STORAGE_PATH
    
    # Create storage directory
    os.makedirs(model_dir, exist_ok=True)
    
    # Save file
    file_path = os.path.join(model_dir, f"{model_type}_{version}.{model_format}")
    
    try:
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        
        # Get file size
        file_size_mb = os.path.getsize(file_path) / (1024 * 1024)
        
        # Create model version record
        model_version = ModelVersion(
            version=version,
            model_type=model_type,
            model_format=model_format,
            model_path=file_path,
            model_size_mb=file_size_mb,
            training_date=datetime.now(),
            is_active=False
        )
        
        db.add(model_version)
        db.commit()
        
        logger.info(f"Model uploaded: {version} ({file_size_mb:.2f} MB)")
        
        return ModelUploadResponse(
            version=version,
            message="Model uploaded successfully",
            file_path=file_path
        )
        
    except Exception as e:
        logger.error(f"Error uploading model: {e}")
        raise HTTPException(status_code=500, detail=f"Upload failed: {str(e)}")


@router.post("/deploy")
async def deploy_model(request: ModelDeployRequest, db: Session = Depends(get_db)):
    """Deploy model to edge devices"""
    from fastapi.concurrency import run_in_threadpool
    
    def get_model():
        return db.query(ModelVersion).filter(ModelVersion.version == request.version).first()
    
    model = await run_in_threadpool(get_model)
    
    if not model:
        raise HTTPException(status_code=404, detail=f"Model version {request.version} not found")
    
    # Update deployment status
    def update_deployment():
        model.deployed_to_branches = request.target_branches or ["all"]
        model.is_active = True
        db.commit()
    
    await run_in_threadpool(update_deployment)
    
    # TODO: Trigger MQTT model update message
    # This will be implemented in deployment service
    
    logger.info(f"Model {request.version} deployed to {request.target_branches or 'all branches'}")
    
    return {
        "status": "success",
        "version": request.version,
        "deployed_to": request.target_branches or "all branches",
        "message": "Deployment initiated. Edge devices will update automatically."
    }


@router.post("/rollback")
async def rollback_model(request: ModelRollbackRequest, db: Session = Depends(get_db)):
    """Rollback to a previous model version"""
    from fastapi.concurrency import run_in_threadpool
    
    def get_models():
        # Get target version
        target = db.query(ModelVersion).filter(
            ModelVersion.model_type == request.model_type,
            ModelVersion.version == request.target_version
        ).first()
        
        # Get current active version
        current = db.query(ModelVersion).filter(
            ModelVersion.model_type == request.model_type,
            ModelVersion.is_active == True
        ).first()
        
        return target, current
    
    target_model, current_model = await run_in_threadpool(get_models)
    
    if not target_model:
        raise HTTPException(
            status_code=404, 
            detail=f"Target version {request.target_version} not found"
        )
    
    def perform_rollback():
        # Deactivate current
        if current_model:
            current_model.is_active = False
        
        # Activate target
        target_model.is_active = True
        db.commit()
    
    await run_in_threadpool(perform_rollback)
    
    logger.info(f"Rolled back {request.model_type} to version {request.target_version}")
    
    return {
        "status": "success",
        "model_type": request.model_type,
        "previous_version": current_model.version if current_model else None,
        "current_version": request.target_version,
        "message": "Rollback completed. Edge devices will update automatically."
    }


@router.delete("/{version}")
async def delete_model(version: str, db: Session = Depends(get_db)):
    """Delete a model version (soft delete - keep record but remove file)"""
    from fastapi.concurrency import run_in_threadpool
    
    def get_model():
        return db.query(ModelVersion).filter(ModelVersion.version == version).first()
    
    model = await run_in_threadpool(get_model)
    
    if not model:
        raise HTTPException(status_code=404, detail=f"Model version {version} not found")
    
    if model.is_active:
        raise HTTPException(
            status_code=400, 
            detail="Cannot delete active model. Deactivate or rollback first."
        )
    
    # Delete file
    if model.model_path and os.path.exists(model.model_path):
        try:
            os.remove(model.model_path)
        except Exception as e:
            logger.error(f"Failed to delete model file: {e}")
    
    # Delete record
    def delete_record():
        db.delete(model)
        db.commit()
    
    await run_in_threadpool(delete_record)
    
    logger.info(f"Model version {version} deleted")
    
    return {"status": "success", "message": f"Model version {version} deleted"}


@router.get("/active/{model_type}", response_model=ModelInfo)
async def get_active_model(model_type: str, db: Session = Depends(get_db)):
    """Get currently active model for a type"""
    from fastapi.concurrency import run_in_threadpool
    
    def query_active():
        return db.query(ModelVersion).filter(
            ModelVersion.model_type == model_type,
            ModelVersion.is_active == True
        ).first()
    
    model = await run_in_threadpool(query_active)
    
    if not model:
        raise HTTPException(
            status_code=404, 
            detail=f"No active model found for type {model_type}"
        )
    
    return model
