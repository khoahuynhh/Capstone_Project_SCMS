from fastapi import APIRouter, HTTPException, Depends, UploadFile, File
from typing import List, Optional
from datetime import datetime
from pydantic import BaseModel
from sqlalchemy.orm import Session
from database.db import SessionLocal
from database.models import FederatedLearningRound, FederatedClientUpdate
import logging
import os

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v1/federated", tags=["federated-learning"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Pydantic models
class ClientUpdateUpload(BaseModel):
    branch_id: str
    round_number: int
    local_loss: float
    local_accuracy: float
    local_samples_count: int

class AggregationRequest(BaseModel):
    model_type: str
    aggregation_method: str = "fedavg"  # fedavg, krum, trimmed_mean, median
    min_clients: int = 2

class AggregationStatus(BaseModel):
    round_number: int
    status: str
    participating_branches: List[str]
    aggregation_method: str
    
    class Config:
        from_attributes = True

# ============ Federated Learning Endpoints ============

@router.post("/upload-update")
async def upload_client_update(
    branch_id: str,
    round_number: int,
    local_loss: float,
    local_accuracy: float,
    local_samples_count: int,
    update_file: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    """Edge device uploads local model update (gradients or weights)"""
    from fastapi.concurrency import run_in_threadpool
    from config import get_settings
    
    settings = get_settings()
    
    # Save update file
    update_dir = os.path.join(settings.MODEL_STORAGE_PATH, "federated_updates", str(round_number))
    os.makedirs(update_dir, exist_ok=True)
    
    file_path = os.path.join(update_dir, f"{branch_id}_update.pkl")
    
    with open(file_path, "wb") as buffer:
        content = await update_file.read()
        buffer.write(content)
    
    file_size_mb = len(content) / (1024 * 1024)
    
    def save_update():
        update = FederatedClientUpdate(
            round_number=round_number,
            branch_id=branch_id,
            update_path=file_path,
            update_size_mb=file_size_mb,
            local_loss=local_loss,
            local_accuracy=local_accuracy,
            local_samples_count=local_samples_count,
            status='received'
        )
        
        db.add(update)
        db.commit()
        db.refresh(update)
        
        return update
    
    update = await run_in_threadpool(save_update)
    
    logger.info(f"Received FL update from {branch_id} for round {round_number}")
    
    return {
        "status": "success",
        "branch_id": branch_id,
        "round_number": round_number,
        "update_id": update.id
    }


@router.post("/aggregate", response_model=AggregationStatus)
async def trigger_aggregation(request: AggregationRequest, db: Session = Depends(get_db)):
    """Trigger federated aggregation for latest round"""
    from fastapi.concurrency import run_in_threadpool
    
    def create_round():
        # Get latest round number
        latest_round = db.query(FederatedLearningRound).order_by(
            FederatedLearningRound.round_number.desc()
        ).first()
        
        new_round_number = (latest_round.round_number + 1) if latest_round else 1
        
        # Get pending updates
        updates = db.query(FederatedClientUpdate).filter(
            FederatedClientUpdate.round_number == new_round_number - 1,  # Previous round
            FederatedClientUpdate.status == 'received'
        ).all()
        
        if len(updates) < request.min_clients:
            raise HTTPException(
                status_code=400,
                detail=f"Not enough clients. Required: {request.min_clients}, Got: {len(updates)}"
            )
        
        # Create aggregation round
        fl_round = FederatedLearningRound(
            round_number=new_round_number,
            model_type=request.model_type,
            aggregation_method=request.aggregation_method,
            participating_branches=[u.branch_id for u in updates],
            total_branches=len(updates),
            status='aggregating',
            started_at=datetime.now()
        )
        
        db.add(fl_round)
        db.commit()
        db.refresh(fl_round)
        
        return fl_round
    
    fl_round = await run_in_threadpool(create_round)
    
    # TODO: AI team implements actual aggregation logic here
    # For now, just log the trigger
    logger.info(f"Triggered FL aggregation for round {fl_round.round_number}")
    logger.warning("PLACEHOLDER: Actual aggregation algorithm not implemented yet")
    
    # Placeholder: would call aggregation service
    # from services.federated_aggregator import aggregate_models
    # result = await aggregate_models(fl_round.round_number, request.aggregation_method)
    
    return fl_round


@router.get("/status/{round_number}", response_model=AggregationStatus)
async def get_aggregation_status(round_number: int, db: Session = Depends(get_db)):
    """Get status of a specific aggregation round"""
    from fastapi.concurrency import run_in_threadpool
    
    def query_status():
        return db.query(FederatedLearningRound).filter(
            FederatedLearningRound.round_number == round_number
        ).first()
    
    fl_round = await run_in_threadpool(query_status)
    
    if not fl_round:
        raise HTTPException(status_code=404, detail=f"Round {round_number} not found")
    
    return fl_round


@router.get("/history")
async def get_aggregation_history(limit: int = 10, db: Session = Depends(get_db)):
    """Get history of federated learning rounds"""
    from fastapi.concurrency import run_in_threadpool
    
    def query_history():
        return db.query(FederatedLearningRound).order_by(
            FederatedLearningRound.round_number.desc()
        ).limit(limit).all()
    
    rounds = await run_in_threadpool(query_history)
    
    return {
        "total": len(rounds),
        "rounds": [
            {
                "round_number": r.round_number,
                "status": r.status,
                "participants": r.total_branches,
                "aggregation_method": r.aggregation_method,
                "started_at": r.started_at,
                "completed_at": r.completed_at
            }
            for r in rounds
        ]
    }


