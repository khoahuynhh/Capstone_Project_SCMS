from fastapi import APIRouter, HTTPException, Query, UploadFile, File
from typing import List, Optional
from datetime import datetime, timedelta
from pydantic import BaseModel
from database.db import SessionLocal
from database.models import Transaction, Recommendation, BranchMetrics, Product
import logging
import pandas as pd
import os
import zipfile

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v1", tags=["api"])


# Pydantic models
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


# ============ Transactions API ============


@router.get("/transactions", response_model=List[TransactionResponse])
async def get_transactions(
    branch_id: Optional[str] = None,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    limit: int = Query(100, le=1000),
):
    """Get transactions with optional filters"""
    db = SessionLocal()
    try:
        query = db.query(Transaction)

        if branch_id:
            query = query.filter(Transaction.branch_id == branch_id)

        if start_date:
            query = query.filter(Transaction.timestamp >= start_date)

        if end_date:
            query = query.filter(Transaction.timestamp <= end_date)

        transactions = query.order_by(Transaction.timestamp.desc()).limit(limit).all()

        return transactions
    finally:
        db.close()


@router.get("/transactions/{transaction_id}")
async def get_transaction(transaction_id: str):
    """Get specific transaction"""
    db = SessionLocal()
    try:
        transaction = (
            db.query(Transaction)
            .filter(Transaction.transaction_id == transaction_id)
            .first()
        )

        if not transaction:
            raise HTTPException(status_code=404, detail="Transaction not found")

        return transaction
    finally:
        db.close()


# ============ Branch Analytics API ============


@router.get("/branches/{branch_id}/stats", response_model=BranchStats)
async def get_branch_stats(branch_id: str, days: int = Query(7, ge=1, le=90)):
    """Get branch statistics"""
    db = SessionLocal()
    try:
        start_date = datetime.now() - timedelta(days=days)

        transactions = (
            db.query(Transaction)
            .filter(
                Transaction.branch_id == branch_id, Transaction.timestamp >= start_date
            )
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

        # Calculate stats
        total_transactions = len(transactions)
        total_revenue = sum(t.total_amount for t in transactions)
        avg_value = total_revenue / total_transactions if total_transactions > 0 else 0

        # Calculate top products (simplified)
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

    finally:
        db.close()


@router.get("/branches")
async def list_branches():
    """List all branches"""
    db = SessionLocal()
    try:
        branches = db.query(Transaction.branch_id).distinct().all()
        return {"branches": [b[0] for b in branches]}
    finally:
        db.close()


# ============ Recommendations API ============


@router.get("/recommendations/performance")
async def get_recommendation_performance(
    branch_id: Optional[str] = None, days: int = Query(7, ge=1, le=90)
):
    """Get recommendation performance metrics"""
    db = SessionLocal()
    try:
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
        accepted = sum(1 for r in recommendations if r.accepted)

        return {
            "total_recommendations": total,
            "acceptance_rate": (accepted / total * 100) if total > 0 else 0,
            "avg_items_recommended": (
                sum(r.items_count for r in recommendations) / total if total > 0 else 0
            ),
        }

    finally:
        db.close()


# ============ Model Management API ============


@router.get("/models/current", response_model=ModelInfo)
async def get_current_model():
    """Get current model information"""
    # Mock data - in production, load from model registry
    return ModelInfo(
        version="v1.0.0", created_at=datetime.now(), accuracy=0.85, model_size_mb=45.2
    )


@router.post("/models/deploy")
async def deploy_model(branch_id: Optional[str] = None, model_version: str = "latest"):
    """Trigger model deployment to edge devices"""
    # In production, this would:
    # 1. Prepare model package
    # 2. Upload to storage
    # 3. Send MQTT notification to edge devices

    logger.info(f"Deploying model {model_version} to {branch_id or 'all branches'}")

    return {
        "status": "deployment_initiated",
        "model_version": model_version,
        "target": branch_id or "all_branches",
    }


# ============ System Metrics API ============


@router.get("/metrics/summary")
async def get_metrics_summary():
    """Get system-wide metrics summary"""
    db = SessionLocal()
    try:
        # Get data from last 24 hours
        start_time = datetime.now() - timedelta(hours=24)

        total_transactions = (
            db.query(Transaction).filter(Transaction.timestamp >= start_time).count()
        )

        total_revenue = (
            db.query(Transaction)
            .filter(Transaction.timestamp >= start_time)
            .with_entities(Transaction.total_amount)
            .all()
        )

        revenue_sum = sum(t[0] for t in total_revenue if t[0])

        return {
            "period": "24h",
            "total_transactions": total_transactions,
            "total_revenue": revenue_sum,
            "active_branches": db.query(Transaction.branch_id).distinct().count(),
        }

    finally:
        db.close()


# ============ Bulk Product Import API ============


@router.post("/products/import-with-images")
async def import_with_images(
    excel_file: UploadFile = File(...), images_zip: UploadFile = File(...)
):
    # 1. Đọc Excel
    df = pd.read_excel(excel_file.file)

    required = {"product_id", "name", "price", "image_file"}
    if not required.issubset(df.columns):
        return {"error": f"Excel must contain: {', '.join(required)}"}

    # 2. Giải nén ZIP hình
    images_path = "uploads/product_images"
    os.makedirs(images_path, exist_ok=True)

    with zipfile.ZipFile(images_zip.file, "r") as zip_ref:
        zip_ref.extractall(images_path)

    db = SessionLocal()

    inserted = 0
    errors = []

    try:
        for idx, row in df.iterrows():
            image_file = row["image_file"]
            image_path = f"{images_path}/{image_file}"

            if not os.path.exists(image_path):
                errors.append(f"Image not found: {image_file}")
                continue

            # Lưu sản phẩm
            new_product = Product(
                product_id=row["product_id"],
                name=row["name"],
                price=row["price"],
                category=row.get("category"),
                stock=row.get("stock", 0),
                image_url=f"/static/product_images/{image_file}",  # Path để FE dùng
            )

            db.add(new_product)
            db.commit()
            db.refresh(new_product)
            inserted += 1

        return {"status": "completed", "inserted": inserted, "errors": errors}

    finally:
        db.close()
