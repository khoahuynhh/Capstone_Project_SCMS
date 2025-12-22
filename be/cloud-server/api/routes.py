from fastapi import APIRouter, HTTPException, Query, UploadFile, File, Depends
from typing import List, Optional
from datetime import datetime, timedelta
from pydantic import BaseModel
import logging
import pandas as pd

from sqlalchemy.orm import Session

from database.db import get_db
from database.models import Transaction, Recommendation, Product
from services.recommend_service import recommend_products

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v1", tags=["api"])


# =========================
# Pydantic response models
# =========================
class TransactionResponse(BaseModel):
    id: int
    branch_id: str
    transaction_id: str
    timestamp: datetime
    customer_id: Optional[str]
    total_amount: float
    items_count: int

    class Config:
        from_attributes = True


class BranchStats(BaseModel):
    branch_id: str
    total_transactions: int
    total_revenue: float
    avg_transaction_value: float
    top_products: List[dict]


class ModelInfo(BaseModel):
    version: str
    created_at: datetime
    accuracy: float
    model_size_mb: float


# =========================
# Transactions API
# =========================
@router.get("/transactions", response_model=List[TransactionResponse])
def get_transactions(
    branch_id: Optional[str] = None,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    limit: int = Query(100, le=1000),
    db: Session = Depends(get_db),
):
    """Get transactions with optional filters"""
    query = db.query(Transaction)

    if branch_id:
        query = query.filter(Transaction.branch_id == branch_id)
    if start_date:
        query = query.filter(Transaction.timestamp >= start_date)
    if end_date:
        query = query.filter(Transaction.timestamp <= end_date)

    return query.order_by(Transaction.timestamp.desc()).limit(limit).all()


@router.get("/transactions/{transaction_id}")
async def get_transaction(transaction_id: str, db: Session = Depends(get_db)):
    """Get specific transaction"""
    transaction = (
        db.query(Transaction)
        .filter(Transaction.transaction_id == transaction_id)
        .first()
    )
    if not transaction:
        raise HTTPException(status_code=404, detail="Transaction not found")
    return transaction


# =========================
# Branch Analytics API
# =========================
@router.get("/branches/{branch_id}/stats", response_model=BranchStats)
def get_branch_stats(
    branch_id: str,
    days: int = Query(7, ge=1, le=90),
    db: Session = Depends(get_db),
):
    """Get branch statistics"""
    start_date = datetime.now() - timedelta(days=days)

    transactions = (
        db.query(Transaction)
        .filter(Transaction.branch_id == branch_id, Transaction.timestamp >= start_date)
        .all()
    )

    if not transactions:
        return BranchStats(
            branch_id=branch_id,
            total_transactions=0,
            total_revenue=0,
            avg_transaction_value=0,
            top_products=[],
        )

    total_transactions = len(transactions)
    total_revenue = sum(t.total_amount or 0 for t in transactions)
    avg_value = total_revenue / total_transactions if total_transactions > 0 else 0

    # Calculate top products (simplified from items_data)
    product_counts = {}
    for txn in transactions:
        if hasattr(txn, "items_data") and txn.items_data:
            import json

            items = (
                json.loads(txn.items_data)
                if isinstance(txn.items_data, str)
                else txn.items_data
            )
            for item in items:
                pid = item.get("product_id", "unknown")
                product_counts[pid] = product_counts.get(pid, 0) + 1

    top_products = [
        {"product_id": pid, "count": count}
        for pid, count in sorted(
            product_counts.items(), key=lambda x: x[1], reverse=True
        )[:10]
    ]

    return BranchStats(
        branch_id=branch_id,
        total_transactions=total_transactions,
        total_revenue=total_revenue,
        avg_transaction_value=avg_value,
        top_products=top_products,
    )


@router.get("/branches")
def list_branches(db: Session = Depends(get_db)):
    """List all branches"""
    branches = db.query(Transaction.branch_id).distinct().all()
    return {"branches": [b[0] for b in branches]}


# =========================
# Recommendations API
# =========================
@router.get("/recommendations/performance")
def get_recommendation_performance(
    branch_id: Optional[str] = None,
    days: int = Query(7, ge=1, le=90),
    db: Session = Depends(get_db),
):
    """Get recommendation performance metrics"""
    start_date = datetime.now() - timedelta(days=days)

    query = db.query(Recommendation).filter(Recommendation.timestamp >= start_date)
    if branch_id:
        query = query.filter(Recommendation.branch_id == branch_id)

    recommendations = query.all()
    if not recommendations:
        return {
            "total_recommendations": 0,
            "acceptance_rate": 0,
            "avg_items_recommended": 0,
        }

    total = len(recommendations)
    accepted = sum(1 for r in recommendations if getattr(r, "accepted", False))

    return {
        "total_recommendations": total,
        "acceptance_rate": (accepted / total * 100) if total > 0 else 0,
        "avg_items_recommended": (
            sum((r.items_count or 0) for r in recommendations) / total
            if total > 0
            else 0
        ),
    }


# =========================
# Model Management API (mock)
# =========================
@router.get("/models/current", response_model=ModelInfo)
async def get_current_model():
    """Get current model information"""
    return ModelInfo(
        version="v1.0.0",
        created_at=datetime.now(),
        accuracy=0.85,
        model_size_mb=45.2,
    )


@router.post("/models/deploy")
async def deploy_model(branch_id: Optional[str] = None, model_version: str = "latest"):
    """Trigger model deployment to edge devices (mock)"""
    logger.info(f"Deploying model {model_version} to {branch_id or 'all branches'}")
    return {
        "status": "deployment_initiated",
        "model_version": model_version,
        "target": branch_id or "all_branches",
    }


# =========================
# System Metrics API
# =========================
@router.get("/metrics/summary")
def get_metrics_summary(db: Session = Depends(get_db)):
    """Get system-wide metrics summary"""
    start_time = datetime.now() - timedelta(hours=24)

    total_transactions = (
        db.query(Transaction).filter(Transaction.timestamp >= start_time).count()
    )

    # sum revenue
    total_amounts = (
        db.query(Transaction.total_amount)
        .filter(Transaction.timestamp >= start_time)
        .all()
    )
    revenue_sum = sum(x[0] for x in total_amounts if x[0])

    return {
        "period": "24h",
        "total_transactions": total_transactions,
        "total_revenue": revenue_sum,
        "active_branches": db.query(Transaction.branch_id).distinct().count(),
    }


# =========================
# Bulk Product Import API
# =========================
@router.post("/products/import-with-image-url")
def import_with_image_url(
    excel_file: UploadFile = File(...),
    db: Session = Depends(get_db),
):
    df = pd.read_excel(excel_file.file)

    required = {"product_id", "name", "price", "image_url"}
    if not required.issubset(df.columns):
        return {"error": f"Excel must contain: {', '.join(required)}"}

    inserted = 0
    errors = []

    for idx, row in df.iterrows():
        try:
            new_product = Product(
                product_id=row["product_id"],
                name=row["name"],
                volume=row.get("volume"),
                price=row["price"],
                # nếu excel của bạn dùng category_vi thì giữ như cũ,
                # nếu dùng category thì đổi row.get("category") cho đúng file excel
                category=row.get("category_vi") or row.get("category"),
                stock=row.get("stock", 0),
                image_url=row.get("image_url"),
            )
            db.add(new_product)
            db.commit()
            db.refresh(new_product)
            inserted += 1
        except Exception as e:
            db.rollback()
            errors.append(f"Row {idx}: {str(e)}")

    return {"status": "completed", "inserted": inserted, "errors": errors}


# =========================
# Product Recommendation API
# =========================
@router.get("/recommend")
def recommend(
    branch_id: str,
    customer_id: str,
    top_k: int = 5,
    db: Session = Depends(get_db),
):
    return recommend_products(
        db, branch_id=branch_id, customer_id=customer_id, top_k=top_k
    )
