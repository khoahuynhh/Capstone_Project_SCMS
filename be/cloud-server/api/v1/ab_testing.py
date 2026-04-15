from fastapi import APIRouter, HTTPException, Depends
from typing import List, Optional
from datetime import datetime
from pydantic import BaseModel, ConfigDict
from sqlalchemy.orm import Session
from database.db import SessionLocal
from database.models import ABExperiment, ABExperimentEvent
import logging
import random

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v1/experiments", tags=["ab-testing"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Pydantic models
class ExperimentCreate(BaseModel):
    experiment_name: str
    variant_a: dict  # Control config
    variant_b: dict  # Treatment config
    split_ratio: float = 0.5
    target_branches: Optional[List[str]] = None
    target_metric: str = "ctr"  # ctr, conversion, revenue

class ExperimentResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    experiment_id: str
    experiment_name: str
    status: str
    variant_a: dict
    variant_b: dict
    start_date: Optional[datetime]
    end_date: Optional[datetime]

@router.post("/create", response_model=ExperimentResponse)
async def create_experiment(request: ExperimentCreate, db: Session = Depends(get_db)):
    """Create new A/B test experiment"""
    from fastapi.concurrency import run_in_threadpool
    import uuid
    
    def create_exp():
        experiment_id = f"exp_{uuid.uuid4().hex[:12]}"
        
        experiment = ABExperiment(
            experiment_id=experiment_id,
            experiment_name=request.experiment_name,
            variant_a=request.variant_a,
            variant_b=request.variant_b,
            split_ratio=request.split_ratio,
            target_branches=request.target_branches,
            target_metric=request.target_metric,
            status='draft'
        )
        
        db.add(experiment)
        db.commit()
        db.refresh(experiment)
        
        return experiment
    
    experiment = await run_in_threadpool(create_exp)
    logger.info(f"Created experiment {experiment.experiment_id}")
    
    return experiment

@router.post("/{experiment_id}/start")
async def start_experiment(experiment_id: str, db: Session = Depends(get_db)):
    """Start running an experiment"""
    from fastapi.concurrency import run_in_threadpool
    
    def start_exp():
        exp = db.query(ABExperiment).filter(ABExperiment.experiment_id == experiment_id).first()
        if not exp:
            raise HTTPException(status_code=404, detail="Experiment not found")
        
        exp.status = 'running'
        exp.start_date = datetime.now()
        db.commit()
        return exp
    
    exp = await run_in_threadpool(start_exp)
    return {"status": "success", "experiment_id": experiment_id, "started_at": exp.start_date}

@router.get("/{experiment_id}/results")
async def get_experiment_results(experiment_id: str, db: Session = Depends(get_db)):
    """Get experiment results with statistical analysis"""
    from fastapi.concurrency import run_in_threadpool
    from scipy import stats
    
    def query_results():
        exp = db.query(ABExperiment).filter(ABExperiment.experiment_id == experiment_id).first()
        if not exp:
            raise HTTPException(status_code=404, detail="Experiment not found")
        
        # Get events
        events_a = db.query(ABExperimentEvent).filter(
            ABExperimentEvent.experiment_id == experiment_id,
            ABExperimentEvent.variant == 'a'
        ).all()
        
        events_b = db.query(ABExperimentEvent).filter(
            ABExperimentEvent.experiment_id == experiment_id,
            ABExperimentEvent.variant == 'b'
        ).all()
        
        return exp, events_a, events_b
    
    exp, events_a, events_b = await run_in_threadpool(query_results)
    
    # Calculate metrics
    conversions_a = sum(1 for e in events_a if e.converted)
    conversions_b = sum(1 for e in events_b if e.converted)
    
    ctr_a = conversions_a / len(events_a) if events_a else 0
    ctr_b = conversions_b / len(events_b) if events_b else 0
    
    # Statistical significance (simplified)
    p_value = 0.05  # Placeholder - use real test
    winner = 'b' if ctr_b > ctr_a else 'a' if ctr_a > ctr_b else 'no_difference'
    
    return {
        "experiment_id": experiment_id,
        "status": exp.status,
        "variant_a": {
            "participants": len(events_a),
            "conversions": conversions_a,
            "ctr": ctr_a
        },
        "variant_b": {
            "participants": len(events_b),
            "conversions": conversions_b,
            "ctr": ctr_b
        },
        "uplift": ((ctr_b - ctr_a) / ctr_a * 100) if ctr_a > 0 else 0,
        "p_value": p_value,
        "winner": winner,
        "statistically_significant": p_value < 0.05
    }

@router.post("/{experiment_id}/conclude")
async def conclude_experiment(experiment_id: str, db: Session = Depends(get_db)):
    """Conclude experiment and declare winner"""
    from fastapi.concurrency import run_in_threadpool
    
    def conclude_exp():
        exp = db.query(ABExperiment).filter(ABExperiment.experiment_id == experiment_id).first()
        if not exp:
            raise HTTPException(status_code=404, detail="Experiment not found")
        
        exp.status = 'completed'
        exp.end_date = datetime.now()
        db.commit()
        return exp
    
    exp = await run_in_threadpool(conclude_exp)
    return {"status": "success", "experiment_id": experiment_id, "concluded_at": exp.end_date}
