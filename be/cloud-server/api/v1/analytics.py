from fastapi import APIRouter, HTTPException, Depends, Query
from typing import List, Optional
from datetime import datetime, timedelta
from pydantic import BaseModel
from sqlalchemy.orm import Session
from sqlalchemy import func
from database.db import SessionLocal
from database.models import (
    Transaction, Recommendation, BranchMetrics, 
    ModelPerformanceLog, InventoryOptimization
)
import logging

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v1/analytics", tags=["analytics"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Pydantic models
class CTRMetrics(BaseModel):
    period: str
    total_recommendations: int
    total_clicks: int
    total_conversions: int
    ctr: float
    conversion_rate: float
    by_branch: List[dict]

class InventoryRecommendation(BaseModel):
    product_id: str
    branch_id: str
    action: str  # restock, transfer, markdown
    quantity: int
    reason: str
    priority: str  # high, medium, low

# ============ Analytics Endpoints ============

@router.get("/ctr", response_model=CTRMetrics)
async def get_ctr_metrics(
    days: int = Query(7, ge=1, le=90),
    branch_id: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """Get Click-Through Rate and conversion metrics"""
    from fastapi.concurrency import run_in_threadpool
    
    def query_metrics():
        start_date = datetime.now() - timedelta(days=days)
        
        # Query recommendations
        rec_query = db.query(Recommendation).filter(
            Recommendation.timestamp >= start_date
        )
        
        if branch_id:
            rec_query = rec_query.filter(Recommendation.branch_id == branch_id)
        
        recommendations = rec_query.all()
        
        total_recs = len(recommendations)
        total_accepted = sum(1 for r in recommendations if r.accepted)
        
        # Query transactions to count conversions
        txn_query = db.query(Transaction).filter(
            Transaction.timestamp >= start_date
        )
        
        if branch_id:
            txn_query = txn_query.filter(Transaction.branch_id == branch_id)
        
        transactions = txn_query.all()
        
        # Calculate by branch
        if not branch_id:
            branch_stats = db.query(
                Recommendation.branch_id,
                func.count(Recommendation.id).label('total'),
                func.sum(func.cast(Recommendation.accepted, func.Integer)).label('accepted')
            ).filter(
                Recommendation.timestamp >= start_date
            ).group_by(Recommendation.branch_id).all()
            
            by_branch = [
                {
                    "branch_id": stat[0],
                    "total_recommendations": stat[1],
                    "accepted": stat[2] or 0,
                    "ctr": (stat[2] or 0) / stat[1] * 100 if stat[1] > 0 else 0
                }
                for stat in branch_stats
            ]
        else:
            by_branch = []
        
        return {
            "period": f"{days}d",
            "total_recommendations": total_recs,
            "total_clicks": total_accepted,
            "total_conversions": len(transactions),
            "ctr": (total_accepted / total_recs * 100) if total_recs > 0 else 0,
            "conversion_rate": (len(transactions) / total_recs * 100) if total_recs > 0 else 0,
            "by_branch": by_branch
        }
    
    metrics = await run_in_threadpool(query_metrics)
    return metrics


@router.get("/inventory-optimization", response_model=List[InventoryRecommendation])
async def get_inventory_recommendations(
    branch_id: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """Get inventory optimization recommendations"""
    from fastapi.concurrency import run_in_threadpool
    
    def analyze_inventory():
        # Get recent transactions
        start_date = datetime.now() - timedelta(days=30)
        
        query = db.query(Transaction).filter(
            Transaction.timestamp >= start_date
        )
        
        if branch_id:
            query = query.filter(Transaction.branch_id == branch_id)
        
        transactions = query.all()
        
        # Analyze product sales velocity
        product_sales = {}
        for txn in transactions:
            if txn.items_data:
                import json
                try:
                    items = json.loads(txn.items_data) if isinstance(txn.items_data, str) else txn.items_data
                    for item in items:
                        pid = item.get('product_id', 'unknown')
                        bid = txn.branch_id
                        key = f"{bid}_{pid}"
                        
                        if key not in product_sales:
                            product_sales[key] = {
                                'branch_id': bid,
                                'product_id': pid,
                                'quantity': 0
                            }
                        product_sales[key]['quantity'] += 1
                except:
                    continue
        
        # Generate recommendations (simplified logic)
        recommendations = []
        
        for key, data in product_sales.items():
            velocity = data['quantity'] / 30  # items per day
            
            if velocity > 5:  # High demand
                recommendations.append(InventoryRecommendation(
                    product_id=data['product_id'],
                    branch_id=data['branch_id'],
                    action='restock',
                    quantity=int(velocity * 14),  # 2 weeks supply
                    reason=f'High demand: {velocity:.1f} units/day',
                    priority='high'
                ))
            elif velocity < 0.5:  # Low demand
                recommendations.append(InventoryRecommendation(
                    product_id=data['product_id'],
                    branch_id=data['branch_id'],
                    action='markdown',
                    quantity=int(velocity * 7),
                    reason=f'Low demand: {velocity:.1f} units/day',
                    priority='low'
                ))
        
        return recommendations[:20]  # Top 20
    
    recs = await run_in_threadpool(analyze_inventory)
    return recs


@router.get("/model-performance")
async def get_model_performance(
    model_version: str,
    days: int = Query(7, ge=1, le=90),
    db: Session = Depends(get_db)
):
    """Get model performance metrics over time"""
    from fastapi.concurrency import run_in_threadpool
    
    def query_performance():
        start_date = datetime.now() - timedelta(days=days)
        
        logs = db.query(ModelPerformanceLog).filter(
            ModelPerformanceLog.model_version == model_version,
            ModelPerformanceLog.date >= start_date
        ).order_by(ModelPerformanceLog.date).all()
        
        if not logs:
            return {
                "model_version": model_version,
                "period": f"{days}d",
                "metrics": []
            }
        
        metrics = [
            {
                "date": log.date.isoformat(),
                "branch_id": log.branch_id,
                "precision_at_5": log.precision_at_5,
                "recall_at_5": log.recall_at_5,
                "ndcg_at_5": log.ndcg_at_5,
                "ctr": log.ctr,
                "avg_latency_ms": log.avg_latency_ms,
                "p95_latency_ms": log.p95_latency_ms
            }
            for log in logs
        ]
        
        # Calculate averages
        avg_precision = sum(m['precision_at_5'] for m in metrics if m['precision_at_5']) / len(metrics)
        avg_latency = sum(m['avg_latency_ms'] for m in metrics if m['avg_latency_ms']) / len(metrics)
        
        return {
            "model_version": model_version,
            "period": f"{days}d",
            "avg_precision_at_5": avg_precision,
            "avg_latency_ms": avg_latency,
            "metrics": metrics
        }
    
    performance = await run_in_threadpool(query_performance)
    return performance


@router.get("/demand-forecast")
async def get_demand_forecast(
    branch_id: str,
    days_ahead: int = Query(7, ge=1, le=30),
    db: Session = Depends(get_db)
):
    """Get demand forecast for products (simplified linear projection)"""
    from fastapi.concurrency import run_in_threadpool
    
    def forecast():
        # Get historical data
        start_date = datetime.now() - timedelta(days=30)
        
        transactions = db.query(Transaction).filter(
            Transaction.branch_id == branch_id,
            Transaction.timestamp >= start_date
        ).all()
        
        # Calculate daily sales
        daily_sales = {}
        for txn in transactions:
            date_key = txn.timestamp.date().isoformat()
            if date_key not in daily_sales:
                daily_sales[date_key] = 0
            daily_sales[date_key] += txn.total_amount or 0
        
        # Simple moving average forecast
        if daily_sales:
            avg_daily_revenue = sum(daily_sales.values()) / len(daily_sales)
            forecasted_revenue = avg_daily_revenue * days_ahead
        else:
            avg_daily_revenue = 0
            forecasted_revenue = 0
        
        return {
            "branch_id": branch_id,
            "forecast_period_days": days_ahead,
            "historical_daily_avg": avg_daily_revenue,
            "forecasted_total_revenue": forecasted_revenue,
            "confidence": "low",  # Placeholder
            "method": "moving_average"
        }
    
    forecast_data = await run_in_threadpool(forecast)
    return forecast_data


@router.get("/top-products")
async def get_top_products(
    branch_id: Optional[str] = None,
    days: int = Query(7, ge=1, le=90),
    limit: int = Query(10, le=50),
    db: Session = Depends(get_db)
):
    """Get top selling products"""
    from fastapi.concurrency import run_in_threadpool
    
    def query_top_products():
        start_date = datetime.now() - timedelta(days=days)
        
        query = db.query(Transaction).filter(
            Transaction.timestamp >= start_date
        )
        
        if branch_id:
            query = query.filter(Transaction.branch_id == branch_id)
        
        transactions = query.all()
        
        # Count product sales
        product_counts = {}
        for txn in transactions:
            if txn.items_data:
                import json
                try:
                    items = json.loads(txn.items_data) if isinstance(txn.items_data, str) else txn.items_data
                    for item in items:
                        pid = item.get('product_id', 'unknown')
                        pname = item.get('product_name', pid)
                        
                        if pid not in product_counts:
                            product_counts[pid] = {
                                'product_id': pid,
                                'product_name': pname,
                                'quantity_sold': 0,
                                'revenue': 0
                            }
                        
                        product_counts[pid]['quantity_sold'] += 1
                        product_counts[pid]['revenue'] += item.get('price', 0)
                except:
                    continue
        
        # Sort by quantity
        top_products = sorted(
            product_counts.values(),
            key=lambda x: x['quantity_sold'],
            reverse=True
        )[:limit]
        
        return {
            "period": f"{days}d",
            "branch_id": branch_id or "all",
            "products": top_products
        }
    
    result = await run_in_threadpool(query_top_products)
    return result
