from fastapi import (
    APIRouter,
    HTTPException,
    status,
    Response,
    Request,
    Query,
    Depends,
    BackgroundTasks,
    UploadFile,
    File,
)
from typing import List, Optional, Dict, Literal
from datetime import datetime, timedelta
from pydantic import BaseModel, EmailStr, field_validator
from passlib.context import CryptContext
from sqlalchemy.orm import Session
from sqlalchemy import or_, desc, func, case
from database.db import get_db
from database.models import (
    Transaction,
    TransactionItem,
    Recommendation,
    RecommendationEvent,
    Product,
    UserAccount,
    Customer,
    CartAssociationRule,
    ProductAssociation,
)
from services.recommend_service import recommend_products
from services.customer_analytics import update_customer_stats
from services.association_jobs import (
    get_product_association_job,
    run_product_association_job,
    start_product_association_job,
)
from jose import jwt, JWTError

import pandas as pd
import io
import os
import logging
import uuid
import json

logger = logging.getLogger(__name__)

router = APIRouter(tags=["api"])

# =========================
# Hash Password
# =========================

JWT_SECRET = os.getenv("JWT_SECRET", "dev-secret-change-me")
JWT_ALG = "HS256"
JWT_EXPIRE_MIN = int(os.getenv("JWT_EXPIRE_MIN", "43200"))  # 30 days
COOKIE_NAME = "access_token"

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def _hash_password(pw: str) -> str:
    return pwd_context.hash(pw)


def _verify_password(pw: str, hashed: str) -> bool:
    return pwd_context.verify(pw, hashed)


def _create_access_token(payload: dict) -> str:
    exp = datetime.utcnow() + timedelta(minutes=JWT_EXPIRE_MIN)
    data = {**payload, "exp": exp}
    return jwt.encode(data, JWT_SECRET, algorithm=JWT_ALG)


# =========================
# Pydantic response models
# =========================
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


class TransactionItemCreate(BaseModel):
    product_id: int
    qty: int
    unit_price: float


class TransactionCreate(BaseModel):
    transaction_id: str
    branch_id: str
    device_id: str
    customer_id: Optional[str] = None
    timestamp: Optional[datetime] = None
    items: List[TransactionItemCreate]


class TransactionSummary(BaseModel):
    id: int
    transaction_id: str
    branch_id: str
    device_id: str
    customer_id: Optional[int] = None
    timestamp: datetime
    items_count: int
    total_amount: float


class AttributeRecommendationBody(BaseModel):
    age: Optional[int] = None
    age_group: Optional[str] = None
    gender: Optional[str] = None
    emotion: Optional[str] = None
    branch_id: Optional[str] = None
    top_k: int = 20


class CartAssociationRecommendationBody(BaseModel):
    product_ids: List[int]
    limit: int = 5

    @field_validator("product_ids")
    @classmethod
    def validate_product_ids(cls, value: List[int]) -> List[int]:
        unique_ids = sorted({int(product_id) for product_id in value if product_id})
        if not unique_ids:
            raise ValueError("product_ids must contain at least one product id")
        return unique_ids

    @field_validator("limit")
    @classmethod
    def validate_limit(cls, value: int) -> int:
        if value < 1 or value > 50:
            raise ValueError("limit must be between 1 and 50")
        return value


class RecommendationEventCreate(BaseModel):
    event_type: Literal["impression", "click", "add_to_cart"]
    product_id: int
    customer_id: Optional[int] = None
    branch_id: Optional[str] = None
    device_id: Optional[str] = None
    surface: str
    algorithm: Optional[str] = None
    position: Optional[int] = None
    session_id: Optional[str] = None
    recommendation_id: Optional[int] = None
    event_metadata: Optional[Dict] = None
    timestamp: Optional[datetime] = None


class RecommendationEventBulkCreate(BaseModel):
    events: List[RecommendationEventCreate]


class UpdateProfileBody(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    phone: Optional[str] = None
    gender: Optional[str] = None
    address: Optional[str] = None
    description: Optional[str] = None
    birth_date: Optional[str] = None
    age: Optional[int] = None


# =========================
# Register
# =========================


class RegisterBody(BaseModel):
    lastName: str
    firstName: str
    birthDate: str
    email: EmailStr
    phone: str
    cccd: str
    gender: str
    age: str | None = None
    address: str
    password: str
    # customerLevel: str
    description: str | None = None

    @field_validator("email", mode="before")
    @classmethod
    def normalize_email(cls, value):
        return value.strip() if isinstance(value, str) else value


@router.post("/register", status_code=status.HTTP_201_CREATED)
def register(body: RegisterBody, db: Session = Depends(get_db)):
    email = str(body.email).strip().lower()

    # 1) Check duplicated email (account)
    if db.query(UserAccount).filter(UserAccount.email == email).first():
        raise HTTPException(status_code=400, detail="Email already exists")

    # 2) (Optional) Check duplicated CCCD/Phone in Customer or Account
    # Set CCCD/phone is unique in the system:
    existed_customer = (
        db.query(Customer)
        .filter((Customer.phone == body.phone) | (Customer.email == email))
        .first()
    )

    if body.cccd:
        cccd_customer = (
            db.query(Customer).filter(Customer.cccd == body.cccd.strip()).first()
        )
        if cccd_customer:
            raise HTTPException(
                status_code=400, detail="Customer with CCCD already exists"
            )

    birth_date_obj = None
    if body.birthDate:
        try:
            birth_date_obj = datetime.strptime(body.birthDate, "%Y-%m-%d").date()
        except ValueError:
            pass

    if existed_customer:
        # If registered before
        raise HTTPException(
            status_code=400, detail="Customer with phone/email already exists"
        )

    # 3) Create Customer (profile)
    cust = Customer(
        customer_id=str(uuid.uuid4()),  # bạn có thể thay bằng uuid nếu thích
        first_name=body.firstName.strip(),
        last_name=body.lastName.strip(),
        phone=body.phone.strip(),
        email=email,
        gender=body.gender.strip(),
        cccd=body.cccd.strip() if body.cccd else None,
        address=body.address.strip() if body.address else None,
        description=body.description.strip() if body.description else None,
        birth_date=birth_date_obj,
        age=int(body.age) if body.age and str(body.age).isdigit() else None,
        age_group=(
            "UNDER_18"
            if body.age and int(body.age) < 18
            else (
                "18_24"
                if body.age and int(body.age) <= 24
                else (
                    "25_34"
                    if body.age and int(body.age) <= 34
                    else (
                        "35_44"
                        if body.age and int(body.age) <= 44
                        else "45_PLUS" if body.age else None
                    )
                )
            )
        ),
    )
    db.add(cust)
    db.flush()  # get cust.id that not commit yet

    # 4) Create UserAccount (auth)
    acc = UserAccount(
        email=email,
        password_hash=_hash_password(body.password),
        customer_pk=cust.id,
    )
    db.add(acc)

    # 5) Commit
    db.commit()
    db.refresh(acc)

    return {
        "message": "Registered successfully",
        "account_id": acc.id,
        "customer_id": cust.id,
        "email": acc.email,
    }


# =========================
# Login & Logout
# =========================


class LoginBody(BaseModel):
    email: EmailStr
    password: str

    @field_validator("email", mode="before")
    @classmethod
    def normalize_email(cls, value):
        return value.strip() if isinstance(value, str) else value


@router.post("/auth/login")
def login(body: LoginBody, response: Response, db: Session = Depends(get_db)):
    email = str(body.email).strip().lower()

    acc = db.query(UserAccount).filter(UserAccount.email == email).first()
    if not acc or not _verify_password(body.password, acc.password_hash):
        raise HTTPException(status_code=401, detail="Invalid email or password")

    token = _create_access_token({"sub": str(acc.id)})

    response.set_cookie(
        key=COOKIE_NAME,
        value=token,
        httponly=True,
        samesite="lax",
        secure=False,  # deploy https -> True
        max_age=JWT_EXPIRE_MIN * 60,
        path="/",
    )
    return {"message": "Logged in"}


@router.post("/auth/logout")
def logout(response: Response):
    response.delete_cookie(COOKIE_NAME, path="/")
    return {"message": "Logged out"}


# =========================
# Check cookie
# =========================


def get_current_account(request: Request, db: Session = Depends(get_db)) -> UserAccount:
    token = request.cookies.get(COOKIE_NAME)
    if not token:
        raise HTTPException(status_code=401, detail="Not authenticated")

    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALG])
        sub = payload.get("sub")
        if not sub:
            raise HTTPException(status_code=401, detail="Not authenticated")
        acc_id = int(sub)
    except (JWTError, ValueError):
        raise HTTPException(status_code=401, detail="Not authenticated")

    acc = db.query(UserAccount).filter(UserAccount.id == acc_id).first()
    if not acc:
        raise HTTPException(status_code=401, detail="Not authenticated")
    return acc


def require_admin_account(
    acc: UserAccount = Depends(get_current_account),
) -> UserAccount:
    if not getattr(acc, "is_admin", False):
        raise HTTPException(status_code=403, detail="Admin permission required")
    return acc


@router.get("/auth/me")
def me(acc: UserAccount = Depends(get_current_account), db: Session = Depends(get_db)):
    customer = None
    if getattr(acc, "customer_pk", None):
        customer = db.query(Customer).filter(Customer.id == acc.customer_pk).first()

    return {
        "account": {
            "id": acc.id,
            "email": acc.email,
            "is_admin": getattr(acc, "is_admin", False),
            "customer_pk": getattr(acc, "customer_pk", None),
        },
        "customer": (
            None
            if not customer
            else {
                "id": customer.id,
                "customer_id": customer.customer_id,
                "first_name": customer.first_name,
                "last_name": customer.last_name,
                "phone": customer.phone,
                "email": customer.email,
                "age": getattr(customer, "age", None),
                "age_group": customer.age_group,
                "gender": customer.gender,
                "preferred_branch": customer.preferred_branch,
            }
        ),
    }


@router.patch("/auth/me")
def update_me(
    body: UpdateProfileBody,
    acc: UserAccount = Depends(get_current_account),
    db: Session = Depends(get_db),
):
    customer = db.query(Customer).filter(Customer.id == acc.customer_pk).first()
    if not customer:
        raise HTTPException(status_code=404, detail="Customer not found")

    # Update từng field nếu có gửi lên
    if body.first_name is not None:
        customer.first_name = body.first_name.strip()

    if body.last_name is not None:
        customer.last_name = body.last_name.strip()

    if body.phone is not None:
        customer.phone = body.phone.strip()

    if body.gender is not None:
        customer.gender = body.gender.strip()

    if body.address is not None:
        customer.address = body.address.strip()

    if body.description is not None:
        customer.description = body.description.strip()

    if body.birth_date:
        try:
            customer.birth_date = datetime.strptime(body.birth_date, "%Y-%m-%d").date()
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid birth_date format")

    if body.age is not None:
        customer.age = body.age

    db.commit()
    db.refresh(customer)

    return {"message": "Profile updated successfully"}


@router.post("/admin/product-associations/generate")
def generate_product_associations(
    background_tasks: BackgroundTasks,
    min_support: float = Query(0.001, gt=0, le=1),
    min_confidence: float = Query(0.03, gt=0, le=1),
    min_lift: float = Query(1.0, ge=0),
    min_items_per_transaction: int = Query(2, ge=2, le=50),
    max_rules: int = Query(10000, ge=1, le=100000),
    _: UserAccount = Depends(require_admin_account),
):
    job = start_product_association_job(
        min_support=min_support,
        min_confidence=min_confidence,
        min_lift=min_lift,
        min_items_per_transaction=min_items_per_transaction,
        max_rules=max_rules,
    )
    if job["status"] == "pending" and not job.get("already_running"):
        background_tasks.add_task(run_product_association_job, job["job_id"])
    return job


@router.get("/admin/product-associations/jobs/{job_id}")
def get_product_association_job_status(
    job_id: str,
    _: UserAccount = Depends(require_admin_account),
):
    job = get_product_association_job(job_id)
    if not job:
        raise HTTPException(status_code=404, detail="Association job not found")
    return job


# =========================
# Transactions API
# =========================


@router.get("/transactions", response_model=List[TransactionSummary])
def list_transactions(
    branch_id: Optional[str] = None,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    limit: int = Query(20, ge=1, le=200),
    db: Session = Depends(get_db),
):
    query = db.query(Transaction)

    if branch_id:
        query = query.filter(Transaction.branch_id == branch_id)
    if start_date:
        query = query.filter(Transaction.timestamp >= start_date)
    if end_date:
        query = query.filter(Transaction.timestamp <= end_date)

    transactions = query.order_by(desc(Transaction.timestamp)).limit(limit).all()

    return [
        TransactionSummary(
            id=tx.id,
            transaction_id=tx.transaction_id,
            branch_id=tx.branch_id,
            device_id=tx.device_id,
            customer_id=tx.customer_id,
            timestamp=tx.timestamp,
            items_count=tx.items_count or len(tx.items_data or []),
            total_amount=float(tx.total_amount or 0),
        )
        for tx in transactions
    ]


@router.post("/transactions", status_code=status.HTTP_201_CREATED)
def create_transaction(
    body: TransactionCreate,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db),
):
    """
    API nhận transaction từ Edge Device.
    Sau khi lưu xong, sẽ kích hoạt background task để tính lại CustomerStats.
    """
    # 1. Tính tổng tiền
    total_amount = sum(item.qty * item.unit_price for item in body.items)
    resolved_customer = None

    if body.customer_id:
        raw_customer_id = str(body.customer_id).strip()
        resolved_customer = (
            db.query(Customer).filter(Customer.customer_id == raw_customer_id).first()
        )

        if not resolved_customer and raw_customer_id.isdigit():
            resolved_customer = (
                db.query(Customer).filter(Customer.id == int(raw_customer_id)).first()
            )

    # 2. Tạo Transaction record
    # Lưu ý: items_data (JSON) để đọc nhanh, items (Relationship) để chuẩn hóa

    items_json = [item.dict() for item in body.items]

    new_tx = Transaction(
        transaction_id=body.transaction_id,
        branch_id=body.branch_id,
        device_id=body.device_id,
        customer_id=resolved_customer.id if resolved_customer else None,
        timestamp=body.timestamp or datetime.utcnow(),
        total_amount=total_amount,
        items_count=len(body.items),
        items_data=items_json,  # Lưu JSON để query nhanh dashboard
    )
    db.add(new_tx)
    db.flush()  # flush để có ID của transaction phục vụ cho Foreign Key items

    # 3. Tạo TransactionItem records (để normalized data)
    for item in body.items:
        tx_item = TransactionItem(
            transaction_id=new_tx.id,  # Dùng ID tự tăng của bảng Transaction
            product_id=item.product_id,
            qty=item.qty,
            unit_price=item.unit_price,
        )
        db.add(tx_item)

    # 4. Update thông tin cơ bản của Customer (nếu có)
    if resolved_customer:
        resolved_customer.last_seen = new_tx.timestamp
        # Lưu ý: KHÔNG cộng dồn total_spent ở đây nữa, để Background Task lo

    # 5. Commit Transaction DB
    try:
        db.commit()
        db.refresh(new_tx)
    except Exception as e:
        db.rollback()
        logger.error(f"Error creating transaction: {e}")
        raise HTTPException(status_code=400, detail="Could not create transaction")

    # 6. KÍCH HOẠT BACKGROUND TASK
    # Chỉ chạy logic nặng nề này nếu có customer_id
    if resolved_customer:
        # FastAPI sẽ chạy hàm này SAU khi response đã được trả về cho client
        background_tasks.add_task(update_customer_stats, resolved_customer.id)

    return {
        "status": "success",
        "id": new_tx.id,
        "transaction_id": new_tx.transaction_id,
        "message": "Transaction created, stats will be updated in background",
    }


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


# Use for customer dashboard
class PurchaseItem(BaseModel):
    product_id: str
    name: str
    category: Optional[str] = None
    image_url: Optional[str] = None
    qty: int
    unit_price: Optional[float] = None
    line_total: float


class PurchaseInvoice(BaseModel):
    transaction_id: str
    timestamp: datetime
    branch_id: Optional[str] = None
    items_count: int
    total_amount: float
    items: List[PurchaseItem]


@router.get(
    "/customers/{customer_id}/purchase-history/grouped",
    response_model=List[PurchaseInvoice],
)
def get_purchase_history_grouped(
    customer_id: str,
    limit_invoices: int = Query(10, ge=1, le=200),
    limit_items_per_invoice: int = Query(200, ge=1, le=5000),
    db: Session = Depends(get_db),
):
    """
    Grouped purchase history by transaction (invoice).
    Each invoice contains items[].
    """
    # 1) Get latest transactions
    invoices = (
        db.query(
            Transaction.id,
            Transaction.transaction_id,
            Transaction.timestamp,
            Transaction.branch_id,
        )
        .join(Customer, Transaction.customer_id == Customer.id)
        .filter(Customer.customer_id == customer_id)
        .order_by(desc(Transaction.timestamp))
        .limit(limit_invoices)
        .all()
    )

    if not invoices:
        return []

    txn_ids = [x[0] for x in invoices]

    # 2) Get items of each transaction, join with Product to get name/category/image_url
    rows = (
        db.query(
            TransactionItem.transaction_id,  # FK -> Transaction.id (int)
            Product.id,
            Product.name,
            Product.category,
            Product.image_url,
            TransactionItem.qty,
            TransactionItem.unit_price,
        )
        .join(Product, Product.id == TransactionItem.product_id)
        .filter(TransactionItem.transaction_id.in_(txn_ids))
        .order_by(desc(TransactionItem.id))
        .limit(limit_in_items := limit_items_per_invoice * len(txn_ids))
        .all()
    )

    # 3) Group by transaction.id
    items_by_txn: Dict[int, List[PurchaseItem]] = {tid: [] for tid in txn_ids}

    for r in rows:
        txn_pk = r[0]
        qty = int(r[5] or 0)
        unit_price = float(r[6]) if r[6] is not None else 0.0
        line_total = qty * unit_price

        items_by_txn.setdefault(txn_pk, []).append(
            PurchaseItem(
                product_id=r[1],
                name=r[2],
                category=r[3],
                image_url=r[4],
                qty=qty,
                unit_price=(float(r[6]) if r[6] is not None else None),
                line_total=line_total,
            )
        )

    # 4) Build response in order of the invoices
    result: List[PurchaseInvoice] = []
    for txn_pk, txn_code, ts, branch_id in invoices:
        items = items_by_txn.get(txn_pk, [])
        # giới hạn items mỗi invoice (nếu cần)
        if len(items) > limit_items_per_invoice:
            items = items[:limit_items_per_invoice]

        total_amount = sum(i.line_total for i in items)

        result.append(
            PurchaseInvoice(
                transaction_id=txn_code,
                timestamp=ts,
                branch_id=branch_id,
                items_count=len(items),
                total_amount=total_amount,
                items=items,
            )
        )

    return result


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
@router.post("/recommendation-events", status_code=status.HTTP_201_CREATED)
def create_recommendation_events(
    body: RecommendationEventBulkCreate,
    db: Session = Depends(get_db),
):
    """Record recommendation impressions, clicks, and add-to-cart events."""
    if not body.events:
        raise HTTPException(status_code=400, detail="events must not be empty")

    if len(body.events) > 200:
        raise HTTPException(
            status_code=400, detail="events must contain at most 200 items"
        )

    product_ids = {event.product_id for event in body.events}
    existing_product_ids = {
        row[0] for row in db.query(Product.id).filter(Product.id.in_(product_ids)).all()
    }
    missing_product_ids = sorted(product_ids - existing_product_ids)
    if missing_product_ids:
        raise HTTPException(
            status_code=400,
            detail=f"Unknown product_id(s): {missing_product_ids[:10]}",
        )

    rows = [
        RecommendationEvent(
            event_type=event.event_type,
            product_id=event.product_id,
            customer_id=event.customer_id,
            branch_id=event.branch_id,
            device_id=event.device_id,
            surface=event.surface.strip(),
            algorithm=event.algorithm,
            position=event.position,
            session_id=event.session_id,
            recommendation_id=event.recommendation_id,
            event_metadata=event.event_metadata,
            timestamp=event.timestamp or datetime.utcnow(),
        )
        for event in body.events
    ]

    try:
        db.add_all(rows)
        db.commit()
    except Exception as e:
        db.rollback()
        logger.error(f"Error creating recommendation events: {e}")
        raise HTTPException(
            status_code=400, detail="Could not create recommendation events"
        )

    return {"inserted": len(rows)}


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

    total = len(recommendations)
    event_filters = [RecommendationEvent.timestamp >= start_date]
    if branch_id:
        event_filters.append(RecommendationEvent.branch_id == branch_id)

    event_stats = (
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
        .filter(*event_filters)
        .one()
    )
    impressions = int(event_stats[0] or 0)
    clicks = int(event_stats[1] or 0)
    accepted = int(event_stats[2] or 0)

    return {
        "total_recommendations": total,
        "acceptance_rate": (accepted / impressions * 100) if impressions > 0 else 0,
        "ctr": (clicks / impressions * 100) if impressions > 0 else 0,
        "impressions": impressions,
        "clicks": clicks,
        "accepted": accepted,
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
# Products
# =========================


@router.get("/products")
def list_products(
    q: Optional[str] = None,
    category: Optional[str] = None,
    limit: int = Query(50, ge=1, le=500),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),
):
    query = db.query(Product)

    if q:
        like = f"%{q.strip()}%"
        query = query.filter(
            or_(Product.name.ilike(like), Product.product_id.ilike(like))
        )

    if category:
        query = query.filter(Product.category == category)

    items = query.order_by(Product.id.desc()).offset(offset).limit(limit).all()

    return [
        {
            "id": p.id,
            "product_code": p.product_code,
            "name": p.name,
            "volume": p.volume,
            "price": p.price,
            "discount_price": p.discount_price,
            "discount_percent": p.discount_percent,
            "category": p.category,
            "stock": p.stock,
            "description": p.description,
            "image_url": p.image_url,
            "target_gender": p.target_gender,
            "target_age_group": p.target_age_group,
            "emotion": p.emotion,
            "usage_context": p.usage_context,
        }
        for p in items
    ]


MIN_SUPPORT = 0.001


@router.get("/products/{product_id}/related")
def get_related_products(
    product_id: int, limit: int = 5, db: Session = Depends(get_db)
):
    """
    API lấy danh sách các sản phẩm thường được mua kèm với một sản phẩm cụ thể.
    """
    # Check if product exists
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Sản phẩm không tồn tại")

    # Query association rules from product_associations table
    associations = (
        db.query(ProductAssociation)
        .filter(ProductAssociation.product_id == product_id)
        .filter(ProductAssociation.lift > 1)  # Only select product with Lift > 1
        .filter(
            ProductAssociation.support >= MIN_SUPPORT
        )  # Filter by minimum support threshold
        .order_by(
            ProductAssociation.lift.desc(),  # Priority 1: Lift
            ProductAssociation.confidence.desc(),  # Priority 2: Confidence
        )
        .limit(limit)
        .all()
    )

    # If there is no associations, return empty list
    if not associations:
        return []

    # Extract a detailed list of products from the association rule.
    recommended_products = [assoc.related_product for assoc in associations]

    # Return the list of recommended products (as JSON)
    return recommended_products


@router.post("/recommendations/cart-associations")
def get_cart_association_recommendations(
    body: CartAssociationRecommendationBody,
    db: Session = Depends(get_db),
):
    """
    Recommend products from cached non-1-1 association rules using the whole cart.
    """
    cart_product_ids = set(body.product_ids)
    candidate_rules = (
        db.query(CartAssociationRule)
        .filter(CartAssociationRule.antecedent_size <= len(cart_product_ids))
        .filter(CartAssociationRule.lift > 1)
        .filter(CartAssociationRule.support >= MIN_SUPPORT)
        .order_by(
            CartAssociationRule.antecedent_size.desc(),
            CartAssociationRule.lift.desc(),
            CartAssociationRule.confidence.desc(),
        )
        .limit(1000)
        .all()
    )

    scored_products: dict[int, dict] = {}
    for rule in candidate_rules:
        antecedents = {int(product_id) for product_id in rule.antecedent_product_ids}
        if not antecedents.issubset(cart_product_ids):
            continue

        for product_id in rule.consequent_product_ids:
            product_id = int(product_id)
            if product_id in cart_product_ids:
                continue

            score = (
                len(antecedents),
                float(rule.lift or 0),
                float(rule.confidence or 0),
                float(rule.support or 0),
            )
            current = scored_products.get(product_id)
            if current is None or score > current["score"]:
                scored_products[product_id] = {
                    "score": score,
                    "rule": rule,
                }

    ranked_ids = [
        product_id
        for product_id, _ in sorted(
            scored_products.items(),
            key=lambda item: item[1]["score"],
            reverse=True,
        )
    ][: body.limit]

    if not ranked_ids:
        return []

    products = db.query(Product).filter(Product.id.in_(ranked_ids)).all()
    product_by_id = {product.id: product for product in products}

    response = []
    for position, product_id in enumerate(ranked_ids, start=1):
        product = product_by_id.get(product_id)
        if not product:
            continue
        rule = scored_products[product_id]["rule"]
        response.append(
            {
                "id": product.id,
                "product_code": product.product_code,
                "name": product.name,
                "volume": product.volume,
                "price": float(product.price),
                "discount_price": product.discount_price,
                "discount_percent": product.discount_percent,
                "category": product.category,
                "stock": product.stock,
                "description": product.description,
                "image_url": product.image_url,
                "emotion": product.emotion,
                "target_age_group": product.target_age_group,
                "target_gender": product.target_gender,
                "usage_context": product.usage_context,
                "recommendation_rule": {
                    "rule_id": rule.id,
                    "source_rule_id": rule.source_rule_id,
                    "antecedent_product_ids": rule.antecedent_product_ids,
                    "consequent_product_ids": rule.consequent_product_ids,
                    "confidence": rule.confidence,
                    "lift": rule.lift,
                    "support": rule.support,
                },
                "recommendation_position": position,
            }
        )

    return response


def _attribute_age_match(
    product_group: Optional[str], age: Optional[int], age_group: Optional[str]
) -> bool:
    if not product_group or product_group.lower() in {"all", "any", "unisex"}:
        return True

    target = product_group.strip().upper().replace("-", "_")
    if age_group and target == age_group.strip().upper().replace("-", "_"):
        return True

    if age is None:
        return False

    if "_" in target:
        try:
            lo, hi = [int(x) for x in target.split("_", 1)]
            return lo <= age <= hi
        except ValueError:
            return False

    if target.endswith("_PLUS") or target.endswith("+"):
        try:
            lo = int(target.replace("_PLUS", "").replace("+", ""))
            return age >= lo
        except ValueError:
            return False

    return False


def _product_response(p: Product) -> dict:
    return {
        "id": p.id,
        "product_code": p.product_code,
        "name": p.name,
        "volume": p.volume,
        "price": p.price,
        "discount_price": p.discount_price,
        "discount_percent": p.discount_percent,
        "category": p.category,
        "stock": p.stock,
        "description": p.description,
        "image_url": p.image_url,
        "target_gender": p.target_gender,
        "target_age_group": p.target_age_group,
        "emotion": p.emotion,
        "usage_context": p.usage_context,
    }


@router.post("/recommendations/by-attributes")
def recommend_by_attributes(
    body: AttributeRecommendationBody,
    db: Session = Depends(get_db),
):
    gender = (body.gender or "").strip().lower()
    emotion = (body.emotion or "").strip().lower()
    top_k = max(1, min(int(body.top_k or 20), 100))

    products = db.query(Product).filter(Product.stock > 0).all()

    scored = []
    for idx, product in enumerate(products):
        score = 0.0
        reasons = []

        target_gender = (product.target_gender or "unisex").strip().lower()
        if gender:
            if target_gender == gender:
                score += 50
                reasons.append("gender")
            elif target_gender in {"unisex", "all", "any"}:
                score += 25
                reasons.append("unisex")

        if _attribute_age_match(product.target_age_group, body.age, body.age_group):
            score += 40
            reasons.append("age_group")

        product_emotion = (product.emotion or "").strip().lower()
        if emotion and product_emotion and product_emotion == emotion:
            score += 30
            reasons.append("emotion")

        if (
            product.discount_price
            and product.price
            and product.discount_price < float(product.price)
        ):
            score += 12
            reasons.append("promotion")

        score += min(int(product.stock or 0), 200) / 20

        payload = _product_response(product)
        payload["recommendation_score"] = round(score, 3)
        payload["recommendation_reasons"] = reasons
        scored.append((score, -idx, payload))

    scored.sort(key=lambda item: (item[0], item[1]), reverse=True)
    return {
        "branch_id": body.branch_id,
        "attributes": {
            "age": body.age,
            "age_group": body.age_group,
            "gender": body.gender,
            "emotion": body.emotion,
        },
        "products": [payload for _score, _idx, payload in scored[:top_k]],
    }


@router.post("/products/upload-excel")
async def upload_products_excel(
    file: UploadFile = File(...), db: Session = Depends(get_db)
):
    if not file.filename.endswith((".xlsx", ".xls")):
        raise HTTPException(
            status_code=400, detail="File must be Excel (.xlsx or .xls)"
        )

    try:
        contents = await file.read()
        df = pd.read_excel(io.BytesIO(contents))

        # In ra để debug nếu cần
        print("Columns:", df.columns)

        inserted_count = 0

        for _, row in df.iterrows():

            product = Product(
                product_code=str(row.get("product_code", "")).strip(),
                name=str(row.get("name", "")).strip(),
                volume=str(row.get("volume", "")).strip(),
                price=row.get("price", 0),
                discount_price=row.get("discount_price"),
                discount_percent=row.get("discount_percent"),
                category=str(row.get("category", "")).strip(),
                stock=int(row.get("stock", 0)),
                description=str(row.get("description", "")).strip(),
                image_url=str(row.get("image_url", "")).strip(),
            )

            db.add(product)
            inserted_count += 1

        db.commit()

        return {"message": "Upload thành công", "rows_inserted": inserted_count}

    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))


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
