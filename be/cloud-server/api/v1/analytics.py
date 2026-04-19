from fastapi import APIRouter, Depends, Query
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime, timedelta, date
from decimal import Decimal

from sqlalchemy.orm import Session
from sqlalchemy import func, cast, Date, case, desc
from fastapi.concurrency import run_in_threadpool

from database.db import SessionLocal
from database.models import (
    Store,
    Product,
    Transaction,
    TransactionItem,
    Recommendation,
    RecommendationEvent,
    Customer,
    CustomerStats,
    BranchInventory,
    EdgeDevice,
    FaceEvent,
)

router = APIRouter(prefix="/api/v1/analytics", tags=["analytics"])


# =========================
# DB Dependency
# =========================
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# =========================
# Helpers
# =========================
def to_float(value):
    if value is None:
        return 0.0
    if isinstance(value, Decimal):
        return float(value)
    return float(value)


def pct_change(current: float, previous: float) -> float:
    if previous == 0:
        return 0.0 if current == 0 else 100.0
    return round(((current - previous) / previous) * 100, 2)


def safe_div(numerator: float, denominator: float) -> float:
    if denominator == 0:
        return 0.0
    return round(numerator / denominator, 4)


# =========================
# Response Schemas
# =========================
class KPIItem(BaseModel):
    value: float
    change_pct: float = 0.0


class OverviewKPIs(BaseModel):
    revenue: KPIItem
    transactions: KPIItem
    avg_order_value: KPIItem
    unique_customers: KPIItem
    recommendation_ctr: KPIItem
    recommendation_acceptance_rate: KPIItem
    foot_traffic: KPIItem
    conversion_rate: KPIItem


class RevenuePoint(BaseModel):
    date: str
    revenue: float
    transactions: int
    avg_order_value: float


class BranchPerformanceItem(BaseModel):
    branch_id: str
    branch_name: Optional[str] = None
    revenue: float
    transactions: int
    avg_order_value: float
    unique_customers: int
    foot_traffic: int
    conversion_rate: float


class TopProductItem(BaseModel):
    product_id: int
    product_name: str
    category: Optional[str] = None
    quantity_sold: int
    revenue: float


class CategoryBreakdownItem(BaseModel):
    category: str
    revenue: float
    quantity_sold: int


class CustomerSegmentItem(BaseModel):
    segment: str
    customers: int


class InventoryAlertItem(BaseModel):
    branch_id: str
    branch_name: Optional[str] = None
    product_id: int
    product_name: str
    stock: int
    reserved: int
    available: int
    status: str


class BranchInventorySummaryItem(BaseModel):
    branch_id: str
    branch_name: Optional[str] = None
    sku_count: int
    total_stock: int
    total_reserved: int
    total_available: int
    low_stock_items: int
    out_of_stock_items: int


class BranchInventoryProductItem(BaseModel):
    branch_id: str
    branch_name: Optional[str] = None
    product_id: int
    product_name: str
    category: Optional[str] = None
    stock: int
    reserved: int
    available: int
    status: str
    updated_at: Optional[str] = None


class RecommendationSummary(BaseModel):
    total_recommendations: int
    total_accepted: int
    acceptance_rate: float


class RecommendationAlgorithmPerformanceItem(BaseModel):
    algorithm: str
    impressions: int
    clicks: int
    accepted: int
    ctr: float
    acceptance_rate: float


class DeviceStatusSummary(BaseModel):
    total_devices: int
    active_devices: int
    offline_devices: int
    error_devices: int


class DashboardOverviewResponse(BaseModel):
    period_days: int
    branch_id: Optional[str] = None
    generated_at: str
    kpis: OverviewKPIs
    revenue_trend: List[RevenuePoint]
    branch_performance: List[BranchPerformanceItem]
    top_products: List[TopProductItem]
    category_breakdown: List[CategoryBreakdownItem]
    customer_segments: List[CustomerSegmentItem]
    inventory_alerts: List[InventoryAlertItem]
    recommendation_summary: RecommendationSummary
    recommendation_algorithm_performance: List[RecommendationAlgorithmPerformanceItem]
    device_status: DeviceStatusSummary


# =========================
# Core Query Builder
# =========================
def _get_dashboard_data(
    db: Session, days: int, branch_id: Optional[str]
) -> Dict[str, Any]:
    now = datetime.utcnow()
    start_date = now - timedelta(days=days)
    prev_start_date = start_date - timedelta(days=days)

    # -------------------------
    # Base filters
    # -------------------------
    current_txn_filter = [Transaction.timestamp >= start_date]
    prev_txn_filter = [
        Transaction.timestamp >= prev_start_date,
        Transaction.timestamp < start_date,
    ]

    current_rec_filter = [Recommendation.timestamp >= start_date]
    prev_rec_filter = [
        Recommendation.timestamp >= prev_start_date,
        Recommendation.timestamp < start_date,
    ]

    current_face_filter = [FaceEvent.timestamp >= start_date]
    prev_face_filter = [
        FaceEvent.timestamp >= prev_start_date,
        FaceEvent.timestamp < start_date,
    ]

    current_device_filter = []
    if branch_id:
        current_txn_filter.append(Transaction.branch_id == branch_id)
        prev_txn_filter.append(Transaction.branch_id == branch_id)

        current_rec_filter.append(Recommendation.branch_id == branch_id)
        prev_rec_filter.append(Recommendation.branch_id == branch_id)

        current_face_filter.append(FaceEvent.branch_id == branch_id)
        prev_face_filter.append(FaceEvent.branch_id == branch_id)

        current_device_filter.append(EdgeDevice.branch_id == branch_id)

    # -------------------------
    # KPI - Current period
    # -------------------------
    current_txn_stats = (
        db.query(
            func.coalesce(func.sum(Transaction.total_amount), 0.0),
            func.count(Transaction.id),
            func.count(func.distinct(Transaction.customer_id)),
        )
        .filter(*current_txn_filter)
        .one()
    )

    current_revenue = to_float(current_txn_stats[0])
    current_transactions = int(current_txn_stats[1] or 0)
    current_unique_customers = int(current_txn_stats[2] or 0)
    current_aov = safe_div(current_revenue, current_transactions)

    prev_txn_stats = (
        db.query(
            func.coalesce(func.sum(Transaction.total_amount), 0.0),
            func.count(Transaction.id),
            func.count(func.distinct(Transaction.customer_id)),
        )
        .filter(*prev_txn_filter)
        .one()
    )

    prev_revenue = to_float(prev_txn_stats[0])
    prev_transactions = int(prev_txn_stats[1] or 0)
    prev_unique_customers = int(prev_txn_stats[2] or 0)
    prev_aov = safe_div(prev_revenue, prev_transactions)

    # -------------------------
    # Recommendation KPIs
    # -------------------------
    current_rec_stats = (
        db.query(
            func.count(Recommendation.id),
        )
        .filter(*current_rec_filter)
        .one()
    )

    prev_rec_stats = (
        db.query(
            func.count(Recommendation.id),
        )
        .filter(*prev_rec_filter)
        .one()
    )

    current_total_recs = int(current_rec_stats[0] or 0)
    prev_total_recs = int(prev_rec_stats[0] or 0)

    current_event_filter = [RecommendationEvent.timestamp >= start_date]
    prev_event_filter = [
        RecommendationEvent.timestamp >= prev_start_date,
        RecommendationEvent.timestamp < start_date,
    ]
    if branch_id:
        current_event_filter.append(RecommendationEvent.branch_id == branch_id)
        prev_event_filter.append(RecommendationEvent.branch_id == branch_id)

    current_event_stats = (
        db.query(
            func.coalesce(
                func.sum(
                    case((RecommendationEvent.event_type == "impression", 1), else_=0)
                ),
                0,
            ),
            func.coalesce(
                func.sum(case((RecommendationEvent.event_type == "click", 1), else_=0)),
                0,
            ),
            func.coalesce(
                func.sum(
                    case((RecommendationEvent.event_type == "add_to_cart", 1), else_=0)
                ),
                0,
            ),
        )
        .filter(*current_event_filter)
        .one()
    )
    prev_event_stats = (
        db.query(
            func.coalesce(
                func.sum(
                    case((RecommendationEvent.event_type == "impression", 1), else_=0)
                ),
                0,
            ),
            func.coalesce(
                func.sum(case((RecommendationEvent.event_type == "click", 1), else_=0)),
                0,
            ),
            func.coalesce(
                func.sum(
                    case((RecommendationEvent.event_type == "add_to_cart", 1), else_=0)
                ),
                0,
            ),
        )
        .filter(*prev_event_filter)
        .one()
    )

    current_impressions = int(current_event_stats[0] or 0)
    current_clicks = int(current_event_stats[1] or 0)
    current_total_accepted = int(current_event_stats[2] or 0)
    prev_impressions = int(prev_event_stats[0] or 0)
    prev_clicks = int(prev_event_stats[1] or 0)
    prev_total_accepted = int(prev_event_stats[2] or 0)

    current_ctr = round(safe_div(current_clicks, current_impressions) * 100, 2)
    prev_ctr = round(safe_div(prev_clicks, prev_impressions) * 100, 2)
    current_acceptance_rate = round(
        safe_div(current_total_accepted, current_impressions) * 100, 2
    )
    prev_acceptance_rate = round(
        safe_div(prev_total_accepted, prev_impressions) * 100, 2
    )

    algorithm_key = case(
        (RecommendationEvent.algorithm == "client_ai_sort", "attribute_ai"),
        else_=func.coalesce(RecommendationEvent.algorithm, "unknown"),
    ).label("algorithm")
    algorithm_rows = (
        db.query(
            algorithm_key,
            func.coalesce(
                func.sum(
                    case((RecommendationEvent.event_type == "impression", 1), else_=0)
                ),
                0,
            ).label("impressions"),
            func.coalesce(
                func.sum(case((RecommendationEvent.event_type == "click", 1), else_=0)),
                0,
            ).label("clicks"),
            func.coalesce(
                func.sum(
                    case((RecommendationEvent.event_type == "add_to_cart", 1), else_=0)
                ),
                0,
            ).label("accepted"),
        )
        .filter(*current_event_filter)
        .group_by(algorithm_key)
        .all()
    )

    algorithm_metrics = {
        "purchase_history_sort": {"impressions": 0, "clicks": 0, "accepted": 0},
        "attribute_ai": {"impressions": 0, "clicks": 0, "accepted": 0},
        "association_rules": {"impressions": 0, "clicks": 0, "accepted": 0},
    }
    for row in algorithm_rows:
        key = row.algorithm or "unknown"
        if key not in algorithm_metrics:
            algorithm_metrics[key] = {"impressions": 0, "clicks": 0, "accepted": 0}
        algorithm_metrics[key]["impressions"] += int(row.impressions or 0)
        algorithm_metrics[key]["clicks"] += int(row.clicks or 0)
        algorithm_metrics[key]["accepted"] += int(row.accepted or 0)

    recommendation_algorithm_performance = [
        RecommendationAlgorithmPerformanceItem(
            algorithm=algorithm,
            impressions=values["impressions"],
            clicks=values["clicks"],
            accepted=values["accepted"],
            ctr=round(safe_div(values["clicks"], values["impressions"]) * 100, 2),
            acceptance_rate=round(
                safe_div(values["accepted"], values["impressions"]) * 100, 2
            ),
        )
        for algorithm, values in algorithm_metrics.items()
    ]

    # -------------------------
    # Foot traffic & conversion
    # -------------------------
    current_foot_traffic = (
        db.query(func.count(FaceEvent.id)).filter(*current_face_filter).scalar() or 0
    )
    prev_foot_traffic = (
        db.query(func.count(FaceEvent.id)).filter(*prev_face_filter).scalar() or 0
    )

    current_conversion_rate = round(
        safe_div(current_transactions, current_foot_traffic) * 100, 2
    )
    prev_conversion_rate = round(
        safe_div(int(prev_transactions), int(prev_foot_traffic)) * 100, 2
    )

    # -------------------------
    # Revenue trend
    # -------------------------
    revenue_rows = (
        db.query(
            cast(Transaction.timestamp, Date).label("day"),
            func.coalesce(func.sum(Transaction.total_amount), 0.0).label("revenue"),
            func.count(Transaction.id).label("transactions"),
        )
        .filter(*current_txn_filter)
        .group_by(cast(Transaction.timestamp, Date))
        .order_by(cast(Transaction.timestamp, Date))
        .all()
    )

    revenue_trend = [
        RevenuePoint(
            date=row.day.isoformat(),
            revenue=round(to_float(row.revenue), 2),
            transactions=int(row.transactions or 0),
            avg_order_value=round(
                safe_div(to_float(row.revenue), int(row.transactions or 0)), 2
            ),
        )
        for row in revenue_rows
    ]

    # -------------------------
    # Branch performance
    # -------------------------
    branch_performance = []
    if not branch_id:
        branch_rows = (
            db.query(
                Store.id.label("branch_id"),
                Store.name.label("branch_name"),
                func.coalesce(func.sum(Transaction.total_amount), 0.0).label("revenue"),
                func.count(Transaction.id).label("transactions"),
                func.count(func.distinct(Transaction.customer_id)).label(
                    "unique_customers"
                ),
            )
            .outerjoin(Transaction, Transaction.branch_id == Store.id)
            .filter((Transaction.timestamp >= start_date) | (Transaction.id.is_(None)))
            .group_by(Store.id, Store.name)
            .order_by(desc("revenue"))
            .all()
        )

        foot_traffic_map = {
            row.branch_id: int(row.foot_traffic or 0)
            for row in (
                db.query(
                    FaceEvent.branch_id.label("branch_id"),
                    func.count(FaceEvent.id).label("foot_traffic"),
                )
                .filter(*current_face_filter)
                .group_by(FaceEvent.branch_id)
                .all()
            )
        }

        for row in branch_rows:
            revenue = round(to_float(row.revenue), 2)
            txns = int(row.transactions or 0)
            foot = foot_traffic_map.get(row.branch_id, 0)
            branch_performance.append(
                BranchPerformanceItem(
                    branch_id=row.branch_id,
                    branch_name=row.branch_name,
                    revenue=revenue,
                    transactions=txns,
                    avg_order_value=round(safe_div(revenue, txns), 2),
                    unique_customers=int(row.unique_customers or 0),
                    foot_traffic=foot,
                    conversion_rate=round(safe_div(txns, foot) * 100, 2),
                )
            )

    # -------------------------
    # Top products
    # -------------------------
    top_product_query = (
        db.query(
            Product.id.label("product_id"),
            Product.name.label("product_name"),
            Product.category.label("category"),
            func.coalesce(func.sum(TransactionItem.qty), 0).label("quantity_sold"),
            func.coalesce(
                func.sum(TransactionItem.qty * TransactionItem.unit_price), 0.0
            ).label("revenue"),
        )
        .join(TransactionItem, TransactionItem.product_id == Product.id)
        .join(Transaction, Transaction.id == TransactionItem.transaction_id)
        .filter(*current_txn_filter)
    )

    top_product_rows = (
        top_product_query.group_by(Product.id, Product.name, Product.category)
        .order_by(desc("quantity_sold"), desc("revenue"))
        .limit(10)
        .all()
    )

    top_products = [
        TopProductItem(
            product_id=row.product_id,
            product_name=row.product_name,
            category=row.category,
            quantity_sold=int(row.quantity_sold or 0),
            revenue=round(to_float(row.revenue), 2),
        )
        for row in top_product_rows
    ]

    # -------------------------
    # Category breakdown
    # -------------------------
    category_rows = (
        db.query(
            Product.category.label("category"),
            func.coalesce(func.sum(TransactionItem.qty), 0).label("quantity_sold"),
            func.coalesce(
                func.sum(TransactionItem.qty * TransactionItem.unit_price), 0.0
            ).label("revenue"),
        )
        .join(TransactionItem, TransactionItem.product_id == Product.id)
        .join(Transaction, Transaction.id == TransactionItem.transaction_id)
        .filter(*current_txn_filter)
        .group_by(Product.category)
        .order_by(desc("revenue"))
        .all()
    )

    category_breakdown = [
        CategoryBreakdownItem(
            category=row.category or "Unknown",
            revenue=round(to_float(row.revenue), 2),
            quantity_sold=int(row.quantity_sold or 0),
        )
        for row in category_rows
    ]

    # -------------------------
    # Customer segments
    # -------------------------
    customer_segment_query = db.query(
        CustomerStats.segment,
        func.count(CustomerStats.id).label("customers"),
    ).join(Customer, Customer.id == CustomerStats.customer_id)

    if branch_id:
        customer_segment_query = customer_segment_query.filter(
            Customer.preferred_branch == branch_id
        )

    customer_segment_rows = (
        customer_segment_query.group_by(CustomerStats.segment)
        .order_by(desc("customers"))
        .all()
    )

    customer_segments = [
        CustomerSegmentItem(
            segment=row.segment or "Unclassified",
            customers=int(row.customers or 0),
        )
        for row in customer_segment_rows
    ]

    # -------------------------
    # Inventory alerts
    # -------------------------
    inventory_query = (
        db.query(
            BranchInventory.branch_id,
            Store.name.label("branch_name"),
            BranchInventory.product_id,
            Product.name.label("product_name"),
            BranchInventory.stock,
            BranchInventory.reserved,
            (BranchInventory.stock - BranchInventory.reserved).label("available"),
            case(
                (
                    (BranchInventory.stock - BranchInventory.reserved) <= 0,
                    "out_of_stock",
                ),
                ((BranchInventory.stock - BranchInventory.reserved) <= 5, "low_stock"),
                else_="ok",
            ).label("status"),
        )
        .join(Store, Store.id == BranchInventory.branch_id)
        .join(Product, Product.id == BranchInventory.product_id)
    )

    if branch_id:
        inventory_query = inventory_query.filter(BranchInventory.branch_id == branch_id)

    inventory_rows = (
        inventory_query.filter((BranchInventory.stock - BranchInventory.reserved) <= 5)
        .order_by(BranchInventory.branch_id, "available", BranchInventory.stock)
        .limit(20)
        .all()
    )

    inventory_alerts = [
        InventoryAlertItem(
            branch_id=row.branch_id,
            branch_name=row.branch_name,
            product_id=row.product_id,
            product_name=row.product_name,
            stock=int(row.stock or 0),
            reserved=int(row.reserved or 0),
            available=int(row.available or 0),
            status=row.status,
        )
        for row in inventory_rows
    ]

    # -------------------------
    # Device status
    # -------------------------
    device_rows = (
        db.query(
            func.count(EdgeDevice.id).label("total"),
            func.coalesce(
                func.sum(case((EdgeDevice.status == "active", 1), else_=0)), 0
            ).label("active"),
            func.coalesce(
                func.sum(case((EdgeDevice.status == "offline", 1), else_=0)), 0
            ).label("offline"),
            func.coalesce(
                func.sum(case((EdgeDevice.status == "error", 1), else_=0)), 0
            ).label("error"),
        )
        .filter(*current_device_filter)
        .one()
    )

    device_status = DeviceStatusSummary(
        total_devices=int(device_rows.total or 0),
        active_devices=int(device_rows.active or 0),
        offline_devices=int(device_rows.offline or 0),
        error_devices=int(device_rows.error or 0),
    )

    # -------------------------
    # Final response
    # -------------------------
    return DashboardOverviewResponse(
        period_days=days,
        branch_id=branch_id,
        generated_at=now.isoformat(),
        kpis=OverviewKPIs(
            revenue=KPIItem(
                value=round(current_revenue, 2),
                change_pct=pct_change(current_revenue, prev_revenue),
            ),
            transactions=KPIItem(
                value=current_transactions,
                change_pct=pct_change(current_transactions, prev_transactions),
            ),
            avg_order_value=KPIItem(
                value=round(current_aov, 2),
                change_pct=pct_change(current_aov, prev_aov),
            ),
            unique_customers=KPIItem(
                value=current_unique_customers,
                change_pct=pct_change(current_unique_customers, prev_unique_customers),
            ),
            recommendation_ctr=KPIItem(
                value=current_ctr,
                change_pct=pct_change(current_ctr, prev_ctr),
            ),
            recommendation_acceptance_rate=KPIItem(
                value=current_acceptance_rate,
                change_pct=pct_change(current_acceptance_rate, prev_acceptance_rate),
            ),
            foot_traffic=KPIItem(
                value=current_foot_traffic,
                change_pct=pct_change(current_foot_traffic, prev_foot_traffic),
            ),
            conversion_rate=KPIItem(
                value=current_conversion_rate,
                change_pct=pct_change(current_conversion_rate, prev_conversion_rate),
            ),
        ),
        revenue_trend=revenue_trend,
        branch_performance=branch_performance,
        top_products=top_products,
        category_breakdown=category_breakdown,
        customer_segments=customer_segments,
        inventory_alerts=inventory_alerts,
        recommendation_summary=RecommendationSummary(
            total_recommendations=current_total_recs,
            total_accepted=current_total_accepted,
            acceptance_rate=current_acceptance_rate,
        ),
        recommendation_algorithm_performance=recommendation_algorithm_performance,
        device_status=device_status,
    )


# =========================
# Endpoints
# =========================
@router.get("/dashboard/overview", response_model=DashboardOverviewResponse)
async def get_dashboard_overview(
    days: int = Query(7, ge=1, le=365),
    branch_id: Optional[str] = Query(None),
    db: Session = Depends(get_db),
):
    """
    API tổng hợp cho dashboard tổng quan kinh doanh.
    FE chỉ cần gọi 1 endpoint này để dựng:
    - KPI cards
    - revenue line chart
    - branch ranking
    - top products
    - category pie/bar chart
    - customer segments
    - inventory alerts
    - device status
    """
    return await run_in_threadpool(_get_dashboard_data, db, days, branch_id)


@router.get("/dashboard/revenue-trend")
async def get_revenue_trend(
    days: int = Query(30, ge=1, le=365),
    branch_id: Optional[str] = Query(None),
    db: Session = Depends(get_db),
):
    start_date = datetime.utcnow() - timedelta(days=days)

    query = db.query(
        cast(Transaction.timestamp, Date).label("day"),
        func.coalesce(func.sum(Transaction.total_amount), 0.0).label("revenue"),
        func.count(Transaction.id).label("transactions"),
    ).filter(Transaction.timestamp >= start_date)

    if branch_id:
        query = query.filter(Transaction.branch_id == branch_id)

    rows = (
        query.group_by(cast(Transaction.timestamp, Date))
        .order_by(cast(Transaction.timestamp, Date))
        .all()
    )

    return {
        "period_days": days,
        "branch_id": branch_id,
        "data": [
            {
                "date": row.day.isoformat(),
                "revenue": round(to_float(row.revenue), 2),
                "transactions": int(row.transactions or 0),
                "avg_order_value": round(
                    safe_div(to_float(row.revenue), int(row.transactions or 0)), 2
                ),
            }
            for row in rows
        ],
    }


@router.get("/dashboard/top-products")
async def get_top_products(
    days: int = Query(30, ge=1, le=365),
    branch_id: Optional[str] = Query(None),
    limit: int = Query(10, ge=1, le=50),
    db: Session = Depends(get_db),
):
    start_date = datetime.utcnow() - timedelta(days=days)

    query = (
        db.query(
            Product.id.label("product_id"),
            Product.name.label("product_name"),
            Product.category.label("category"),
            func.coalesce(func.sum(TransactionItem.qty), 0).label("quantity_sold"),
            func.coalesce(
                func.sum(TransactionItem.qty * TransactionItem.unit_price), 0.0
            ).label("revenue"),
        )
        .join(TransactionItem, TransactionItem.product_id == Product.id)
        .join(Transaction, Transaction.id == TransactionItem.transaction_id)
        .filter(Transaction.timestamp >= start_date)
    )

    if branch_id:
        query = query.filter(Transaction.branch_id == branch_id)

    rows = (
        query.group_by(Product.id, Product.name, Product.category)
        .order_by(desc("quantity_sold"), desc("revenue"))
        .limit(limit)
        .all()
    )

    return {
        "period_days": days,
        "branch_id": branch_id,
        "items": [
            {
                "product_id": row.product_id,
                "product_name": row.product_name,
                "category": row.category,
                "quantity_sold": int(row.quantity_sold or 0),
                "revenue": round(to_float(row.revenue), 2),
            }
            for row in rows
        ],
    }


@router.get("/dashboard/branch-performance")
async def get_branch_performance(
    days: int = Query(30, ge=1, le=365),
    db: Session = Depends(get_db),
):
    start_date = datetime.utcnow() - timedelta(days=days)

    branch_rows = (
        db.query(
            Store.id.label("branch_id"),
            Store.name.label("branch_name"),
            func.coalesce(func.sum(Transaction.total_amount), 0.0).label("revenue"),
            func.count(Transaction.id).label("transactions"),
            func.count(func.distinct(Transaction.customer_id)).label(
                "unique_customers"
            ),
        )
        .outerjoin(Transaction, Transaction.branch_id == Store.id)
        .filter((Transaction.timestamp >= start_date) | (Transaction.id.is_(None)))
        .group_by(Store.id, Store.name)
        .order_by(desc("revenue"))
        .all()
    )

    foot_traffic_map = {
        row.branch_id: int(row.foot_traffic or 0)
        for row in (
            db.query(
                FaceEvent.branch_id.label("branch_id"),
                func.count(FaceEvent.id).label("foot_traffic"),
            )
            .filter(FaceEvent.timestamp >= start_date)
            .group_by(FaceEvent.branch_id)
            .all()
        )
    }

    return {
        "period_days": days,
        "items": [
            {
                "branch_id": row.branch_id,
                "branch_name": row.branch_name,
                "revenue": round(to_float(row.revenue), 2),
                "transactions": int(row.transactions or 0),
                "avg_order_value": round(
                    safe_div(to_float(row.revenue), int(row.transactions or 0)), 2
                ),
                "unique_customers": int(row.unique_customers or 0),
                "foot_traffic": foot_traffic_map.get(row.branch_id, 0),
                "conversion_rate": round(
                    safe_div(
                        int(row.transactions or 0),
                        foot_traffic_map.get(row.branch_id, 0),
                    )
                    * 100,
                    2,
                ),
            }
            for row in branch_rows
        ],
    }


@router.get("/dashboard/inventory-alerts")
async def get_inventory_alerts(
    branch_id: Optional[str] = Query(None),
    threshold: int = Query(5, ge=0, le=100),
    db: Session = Depends(get_db),
):
    query = (
        db.query(
            BranchInventory.branch_id,
            Store.name.label("branch_name"),
            BranchInventory.product_id,
            Product.name.label("product_name"),
            BranchInventory.stock,
            BranchInventory.reserved,
            (BranchInventory.stock - BranchInventory.reserved).label("available"),
            case(
                (
                    (BranchInventory.stock - BranchInventory.reserved) <= 0,
                    "out_of_stock",
                ),
                (
                    (BranchInventory.stock - BranchInventory.reserved) <= threshold,
                    "low_stock",
                ),
                else_="ok",
            ).label("status"),
        )
        .join(Store, Store.id == BranchInventory.branch_id)
        .join(Product, Product.id == BranchInventory.product_id)
        .filter((BranchInventory.stock - BranchInventory.reserved) <= threshold)
        .order_by(BranchInventory.branch_id, "available", BranchInventory.stock)
    )

    if branch_id:
        query = query.filter(BranchInventory.branch_id == branch_id)

    rows = query.all()

    return {
        "branch_id": branch_id,
        "threshold": threshold,
        "items": [
            {
                "branch_id": row.branch_id,
                "branch_name": row.branch_name,
                "product_id": row.product_id,
                "product_name": row.product_name,
                "stock": int(row.stock or 0),
                "reserved": int(row.reserved or 0),
                "available": int(row.available or 0),
                "status": row.status,
            }
            for row in rows
        ],
    }


@router.get("/dashboard/branch-inventory")
async def get_branch_inventory(
    branch_id: Optional[str] = Query(None),
    threshold: int = Query(5, ge=0, le=100),
    limit: int = Query(15, ge=1, le=100),
    db: Session = Depends(get_db),
):
    available_expr = BranchInventory.stock - BranchInventory.reserved

    summary_query = (
        db.query(
            BranchInventory.branch_id,
            Store.name.label("branch_name"),
            func.count(BranchInventory.product_id).label("sku_count"),
            func.coalesce(func.sum(BranchInventory.stock), 0).label("total_stock"),
            func.coalesce(func.sum(BranchInventory.reserved), 0).label("total_reserved"),
            func.coalesce(func.sum(available_expr), 0).label("total_available"),
            func.coalesce(
                func.sum(case((available_expr <= threshold, 1), else_=0)),
                0,
            ).label("low_stock_items"),
            func.coalesce(
                func.sum(case((available_expr <= 0, 1), else_=0)),
                0,
            ).label("out_of_stock_items"),
        )
        .join(Store, Store.id == BranchInventory.branch_id)
        .group_by(BranchInventory.branch_id, Store.name)
        .order_by(BranchInventory.branch_id)
    )

    items_query = (
        db.query(
            BranchInventory.branch_id,
            Store.name.label("branch_name"),
            BranchInventory.product_id,
            Product.name.label("product_name"),
            Product.category,
            BranchInventory.stock,
            BranchInventory.reserved,
            available_expr.label("available"),
            case(
                (available_expr <= 0, "out_of_stock"),
                (available_expr <= threshold, "low_stock"),
                else_="in_stock",
            ).label("status"),
            BranchInventory.updated_at,
        )
        .join(Store, Store.id == BranchInventory.branch_id)
        .join(Product, Product.id == BranchInventory.product_id)
    )

    if branch_id:
        summary_query = summary_query.filter(BranchInventory.branch_id == branch_id)
        items_query = items_query.filter(BranchInventory.branch_id == branch_id)

    summary_rows = summary_query.all()
    item_rows = (
        items_query.order_by(
            "available",
            BranchInventory.branch_id,
            BranchInventory.stock,
            Product.name,
        )
        .limit(limit)
        .all()
    )

    totals = {
        "sku_count": sum(int(row.sku_count or 0) for row in summary_rows),
        "total_stock": sum(int(row.total_stock or 0) for row in summary_rows),
        "total_reserved": sum(int(row.total_reserved or 0) for row in summary_rows),
        "total_available": sum(int(row.total_available or 0) for row in summary_rows),
        "low_stock_items": sum(int(row.low_stock_items or 0) for row in summary_rows),
        "out_of_stock_items": sum(int(row.out_of_stock_items or 0) for row in summary_rows),
    }

    return {
        "branch_id": branch_id,
        "threshold": threshold,
        "limit": limit,
        "totals": totals,
        "branches": [
            BranchInventorySummaryItem(
                branch_id=row.branch_id,
                branch_name=row.branch_name,
                sku_count=int(row.sku_count or 0),
                total_stock=int(row.total_stock or 0),
                total_reserved=int(row.total_reserved or 0),
                total_available=int(row.total_available or 0),
                low_stock_items=int(row.low_stock_items or 0),
                out_of_stock_items=int(row.out_of_stock_items or 0),
            ).model_dump()
            for row in summary_rows
        ],
        "items": [
            BranchInventoryProductItem(
                branch_id=row.branch_id,
                branch_name=row.branch_name,
                product_id=row.product_id,
                product_name=row.product_name,
                category=row.category,
                stock=int(row.stock or 0),
                reserved=int(row.reserved or 0),
                available=int(row.available or 0),
                status=row.status,
                updated_at=row.updated_at.isoformat() if row.updated_at else None,
            ).model_dump()
            for row in item_rows
        ],
    }


@router.get("/dashboard/customer-segments")
async def get_customer_segments(
    branch_id: Optional[str] = Query(None),
    db: Session = Depends(get_db),
):
    query = db.query(
        CustomerStats.segment,
        func.count(CustomerStats.id).label("customers"),
    ).join(Customer, Customer.id == CustomerStats.customer_id)

    if branch_id:
        query = query.filter(Customer.preferred_branch == branch_id)

    rows = query.group_by(CustomerStats.segment).order_by(desc("customers")).all()

    return {
        "branch_id": branch_id,
        "items": [
            {
                "segment": row.segment or "Unclassified",
                "customers": int(row.customers or 0),
            }
            for row in rows
        ],
    }
