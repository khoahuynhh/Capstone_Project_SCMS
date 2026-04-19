# seed_test_data.py
import os
import random
import uuid
from decimal import Decimal
from datetime import datetime, timedelta, date

import pandas as pd
from passlib.context import CryptContext
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from database.models import (
    Base,
    Store,
    Product,
    ProductAssociation,
    Transaction,
    TransactionItem,
    Recommendation,
    UserAccount,
    Customer,
    CustomerStats,
    BranchMetrics,
    BranchInventory,
    ModelVersion,
    EdgeDevice,
    FaceEvent,
    Promotion,
    PromotionBranch,
    PromotionProduct,
    CustomerConsent,
    PrivacyAuditLog,
    ABExperiment,
    ABExperimentEvent,
    FederatedLearningRound,
    FederatedClientUpdate,
    ModelPerformanceLog,
    InventoryOptimization,
)

DATABASE_URL = os.getenv(
    "DATABASE_URL", "postgresql+psycopg2://admin:admin123@localhost:5433/retail_db"
)
PRODUCT_CSV_PATH = os.getenv("PRODUCT_CSV_PATH", "./data/Products.csv")
RANDOM_SEED = int(os.getenv("SEED", "42"))
SEED_DEFAULT_PASSWORD = os.getenv("SEED_DEFAULT_PASSWORD", "12345678")

random.seed(RANDOM_SEED)
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def rand_bool(p=0.5):
    return random.random() < p


def rand_date_within(days_back=90):
    return datetime.utcnow() - timedelta(
        days=random.randint(0, days_back),
        hours=random.randint(0, 23),
        minutes=random.randint(0, 59),
    )


def chunked(lst, n):
    for i in range(0, len(lst), n):
        yield lst[i : i + n]


def create_session():
    engine = create_engine(DATABASE_URL, future=True)
    Base.metadata.create_all(engine)
    SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)
    return SessionLocal()


def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def seed_stores_and_devices(db):
    stores = [
        Store(
            id="HCM_Q1",
            name="Mart Quận 1",
            address="12 Nguyễn Huệ, Quận 1, HCM",
        ),
        Store(
            id="HCM_Q7",
            name="Mart Quận 7",
            address="99 Nguyễn Thị Thập, Quận 7, HCM",
        ),
        Store(
            id="HN_CG",
            name="Mart Cầu Giấy",
            address="45 Trần Thái Tông, Cầu Giấy, Hà Nội",
        ),
    ]
    db.add_all(stores)
    db.flush()

    devices = [
        EdgeDevice(
            id="EDGE_HCM_Q1_01",
            branch_id="HCM_Q1",
            name="Edge Cam Q1 - 01",
            description="Thiết bị edge nhận diện tại cửa vào",
            ip_address="192.168.1.11",
            status="active",
            last_seen=datetime.utcnow(),
        ),
        EdgeDevice(
            id="EDGE_HCM_Q7_01",
            branch_id="HCM_Q7",
            name="Edge Cam Q7 - 01",
            description="Thiết bị edge nhận diện tại quầy thanh toán",
            ip_address="192.168.1.21",
            status="active",
            last_seen=datetime.utcnow(),
        ),
        EdgeDevice(
            id="EDGE_HN_CG_01",
            branch_id="HN_CG",
            name="Edge Cam Cầu Giấy - 01",
            description="Thiết bị edge nhận diện tại cửa vào",
            ip_address="192.168.1.31",
            status="active",
            last_seen=datetime.utcnow(),
        ),
    ]
    db.add_all(devices)
    db.flush()
    return stores, devices


def seed_products_from_csv(db):
    df = pd.read_csv(PRODUCT_CSV_PATH)

    products = []
    for _, row in df.iterrows():
        base_price = Decimal(str(round(float(row["price"]), 2)))
        has_discount = rand_bool(0.35)

        discount_percent = (
            round(random.choice([5, 10, 15, 20]), 2) if has_discount else 0.0
        )
        discount_price = (
            float(base_price) * (1 - discount_percent / 100) if has_discount else None
        )

        description = (
            f"{row['name']} thuộc nhóm {row['category']}, "
            f"phù hợp cho ngữ cảnh '{row.get('usage_context', 'daily')}'."
        )

        product = Product(
            product_code=str(row["product_code"]),
            name=str(row["name"]),
            volume=None if pd.isna(row.get("volume")) else str(row.get("volume")),
            price=base_price,
            discount_price=round(discount_price, 2) if discount_price else None,
            discount_percent=discount_percent if has_discount else None,
            category=None if pd.isna(row.get("category")) else str(row.get("category")),
            stock=(
                int(row["stock"])
                if not pd.isna(row.get("stock"))
                else random.randint(5, 100)
            ),
            description=description,
            image_url=(
                None if pd.isna(row.get("image_url")) else str(row.get("image_url"))
            ),
            emotion=None if pd.isna(row.get("mood_tag")) else str(row.get("mood_tag")),
            target_age_group=(
                None
                if pd.isna(row.get("target_age_group"))
                else str(row.get("target_age_group"))
            ),
            target_gender=(
                None
                if pd.isna(row.get("target_gender"))
                else str(row.get("target_gender"))
            ),
            usage_context=(
                None
                if pd.isna(row.get("usage_context"))
                else str(row.get("usage_context"))
            ),
        )
        products.append(product)

    db.add_all(products)
    db.flush()
    return products


def seed_branch_inventory(db, stores, products):
    rows = []
    for store in stores:
        for p in products:
            stock = max(0, int((p.stock or 0) * random.uniform(0.4, 1.2)))
            reserved = random.randint(0, min(stock, 8)) if stock > 0 else 0
            rows.append(
                BranchInventory(
                    branch_id=store.id,
                    product_id=p.id,
                    stock=stock,
                    reserved=reserved,
                )
            )
    db.add_all(rows)
    db.flush()


def seed_product_associations(db, products):
    by_category = {}
    for p in products:
        by_category.setdefault(p.category or "Khác", []).append(p)

    associations = []
    for _, group in by_category.items():
        if len(group) < 2:
            continue

        sample_group = random.sample(group, min(len(group), 8))
        for product in sample_group:
            related_candidates = [x for x in sample_group if x.id != product.id]
            for related in random.sample(
                related_candidates, min(3, len(related_candidates))
            ):
                associations.append(
                    ProductAssociation(
                        product_id=product.id,
                        related_product_id=related.id,
                        confidence=round(random.uniform(0.45, 0.92), 2),
                        lift=round(random.uniform(1.05, 2.4), 2),
                        support=round(random.uniform(0.02, 0.25), 3),
                    )
                )

    unique_pairs = {}
    for a in associations:
        unique_pairs[(a.product_id, a.related_product_id)] = a

    db.add_all(list(unique_pairs.values()))
    db.flush()


FIRST_NAMES = [
    "An",
    "Bình",
    "Chi",
    "Dũng",
    "Hà",
    "Huy",
    "Khánh",
    "Lan",
    "Linh",
    "Minh",
    "My",
    "Nam",
    "Ngọc",
    "Phúc",
    "Quân",
    "Trang",
    "Vy",
]
LAST_NAMES = ["Nguyễn", "Trần", "Lê", "Phạm", "Hoàng", "Phan", "Vũ", "Đặng"]
SEGMENTS = ["VIP", "Potential", "Churn Risk", "Loyal", "New"]
AGE_GROUPS = ["18_24", "25_34", "35_44", "45_54"]
GENDERS = ["male", "female", "unisex"]


def seed_customers(db, stores, count=60):
    customers = []
    stats_rows = []
    consent_rows = []
    user_accounts = []
    audit_logs = []

    for i in range(1, count + 1):
        first_name = random.choice(FIRST_NAMES)
        last_name = random.choice(LAST_NAMES)
        age = random.randint(18, 54)
        birth_year = datetime.utcnow().year - age

        customer = Customer(
            customer_id=f"CUS{i:04d}",
            first_name=first_name,
            last_name=last_name,
            phone=f"09{random.randint(10000000, 99999999)}",
            email=f"customer{i:04d}@gmail.com",
            cccd=f"{random.randint(100000000000, 999999999999)}",
            address=f"{random.randint(1, 300)} Demo Street",
            birth_date=date(birth_year, random.randint(1, 12), random.randint(1, 28)),
            age=age,
            age_group=random.choice(AGE_GROUPS),
            gender=random.choice(GENDERS),
            description="Khách hàng seed để test UI",
            preferred_branch=random.choice(stores).id,
            avg_basket_size=round(random.uniform(80000, 450000), 2),
            first_seen=rand_date_within(180),
            last_seen=rand_date_within(10),
            created_at=rand_date_within(180),
        )
        customers.append(customer)

    db.add_all(customers)
    db.flush()

    for customer in customers:
        stats_rows.append(
            CustomerStats(
                customer_id=customer.id,
                total_transactions=random.randint(0, 25),
                total_spent=Decimal(str(round(random.uniform(100000, 7000000), 2))),
                avg_basket_size=Decimal(str(round(random.uniform(80000, 450000), 2))),
                favorite_categories=random.sample(
                    [
                        "Snack",
                        "Nước giải khát",
                        "Sữa & chế phẩm",
                        "Gia vị",
                        "Chăm sóc cá nhân",
                    ],
                    k=3,
                ),
                last_purchase_date=rand_date_within(30),
                rank_score=round(random.uniform(10, 100), 2),
                segment=random.choice(SEGMENTS),
            )
        )

        consent = CustomerConsent(
            customer_id=customer.id,
            face_recognition_consent=rand_bool(0.75),
            data_collection_consent=rand_bool(0.85),
            marketing_consent=rand_bool(0.55),
            opted_out=rand_bool(0.1),
            opted_out_at=rand_date_within(60) if rand_bool(0.1) else None,
            opt_out_reason="Không muốn nhận marketing" if rand_bool(0.08) else None,
            consent_method=random.choice(["kiosk", "mobile", "staff"]),
            consent_ip_address=f"10.0.0.{random.randint(2, 254)}",
            consent_location=random.choice(["Q1 kiosk", "Q7 kiosk", "HN app"]),
            data_retention_until=datetime.utcnow()
            + timedelta(days=random.randint(90, 365)),
        )
        consent_rows.append(consent)

        user_accounts.append(
            UserAccount(
                email=customer.email,
                password_hash=hash_password(SEED_DEFAULT_PASSWORD),
                customer_pk=customer.id,
            )
        )

        audit_logs.append(
            PrivacyAuditLog(
                customer_id=customer.id,
                operation_type=random.choice(
                    ["consent_given", "consent_updated", "data_accessed"]
                ),
                operation_details={
                    "source": "seed_script",
                    "note": "Generated for UI testing",
                },
                performed_by=customer.customer_id,
                performed_by_role="customer",
                ip_address=f"10.0.1.{random.randint(2, 254)}",
                success=True,
                timestamp=rand_date_within(30),
            )
        )

    db.add_all(stats_rows)
    db.add_all(consent_rows)
    db.add_all(user_accounts)
    db.add_all(audit_logs)
    db.flush()
    return customers


def seed_promotions(db, stores, products):
    promos = [
        Promotion(
            code="WEEKEND10",
            name="Cuối tuần giảm 10%",
            discount_type="PERCENT",
            start_at=datetime.utcnow() - timedelta(days=3),
            end_at=datetime.utcnow() + timedelta(days=7),
            is_active=True,
        ),
        Promotion(
            code="COMBOFIX",
            name="Combo ưu đãi giá cố định",
            discount_type="FIXED",
            start_at=datetime.utcnow() - timedelta(days=5),
            end_at=datetime.utcnow() + timedelta(days=10),
            is_active=True,
        ),
    ]
    db.add_all(promos)
    db.flush()

    for promo in promos:
        target_stores = random.sample(stores, k=random.randint(1, len(stores)))
        for store in target_stores:
            db.add(PromotionBranch(promotion_id=promo.id, branch_id=store.id))

        target_products = random.sample(products, k=min(12, len(products)))
        for p in target_products:
            value = (
                10
                if promo.discount_type == "PERCENT"
                else random.choice([5000, 10000, 15000])
            )
            db.add(
                PromotionProduct(
                    promotion_id=promo.id,
                    product_id=p.id,
                    discount_value=float(value),
                    max_qty_per_customer=random.choice([1, 2, 3, None]),
                )
            )
    db.flush()


def seed_transactions_and_related(db, stores, devices, products, customers, count=180):
    transactions = []
    recommendations = []
    face_events = []
    branch_metrics_map = {}

    for i in range(1, count + 1):
        store = random.choice(stores)
        device = random.choice([d for d in devices if d.branch_id == store.id])
        customer = random.choice(customers) if rand_bool(0.8) else None

        purchased_products = random.sample(products, k=random.randint(1, 5))
        transaction_time = rand_date_within(45)

        items = []
        items_data = []
        total_amount = 0.0

        for p in purchased_products:
            qty = random.randint(1, 3)
            unit_price = float(p.discount_price or p.price)
            total_amount += qty * unit_price
            items_data.append(
                {
                    "product_id": p.id,
                    "product_code": p.product_code,
                    "name": p.name,
                    "qty": qty,
                    "unit_price": unit_price,
                }
            )

        tx = Transaction(
            branch_id=store.id,
            transaction_id=f"TXN-{transaction_time.strftime('%Y%m%d')}-{i:05d}",
            timestamp=transaction_time,
            customer_id=customer.id if customer else None,
            device_id=device.id,
            items_data=items_data,
            items_count=len(items_data),
            total_amount=round(total_amount, 2),
            recommended_items=[],
            created_at=transaction_time,
        )
        db.add(tx)
        db.flush()

        for item_data in items_data:
            items.append(
                TransactionItem(
                    transaction_id=tx.id,
                    product_id=item_data["product_id"],
                    qty=item_data["qty"],
                    unit_price=item_data["unit_price"],
                )
            )
        db.add_all(items)

        rec_candidates = random.sample(products, k=random.randint(2, 4))
        recommended_payload = [
            {
                "product_id": p.id,
                "product_code": p.product_code,
                "name": p.name,
                "score": round(random.uniform(0.6, 0.98), 2),
            }
            for p in rec_candidates
        ]
        tx.recommended_items = recommended_payload

        rec = Recommendation(
            branch_id=store.id,
            transaction_id=tx.transaction_id,
            timestamp=transaction_time - timedelta(minutes=random.randint(1, 10)),
            customer_id=customer.id if customer else None,
            device_id=device.id,
            face_attributes={
                "age_group": (
                    customer.age_group if customer else random.choice(AGE_GROUPS)
                ),
                "gender": (
                    customer.gender if customer else random.choice(["male", "female"])
                ),
            },
            recommended_products=recommended_payload,
            items_count=len(recommended_payload),
            created_at=transaction_time,
        )
        recommendations.append(rec)

        face_events.append(
            FaceEvent(
                branch_id=store.id,
                device_id=device.id,
                event_type=random.choice(["face_recognized", "no_face"]),
                timestamp=transaction_time - timedelta(minutes=random.randint(1, 20)),
                customer_id=customer.id if (customer and rand_bool(0.7)) else None,
                similarity=round(random.uniform(0.72, 0.98), 2) if customer else None,
                face_attributes={
                    "age_group": (
                        customer.age_group if customer else random.choice(AGE_GROUPS)
                    ),
                    "gender": (
                        customer.gender
                        if customer
                        else random.choice(["male", "female"])
                    ),
                },
                transaction_id=tx.transaction_id,
                created_at=transaction_time,
            )
        )

        metric_key = (store.id, transaction_time.date())
        if metric_key not in branch_metrics_map:
            branch_metrics_map[metric_key] = {
                "total_transactions": 0,
                "total_revenue": 0.0,
                "total_recommendations": 0,
            }

        branch_metrics_map[metric_key]["total_transactions"] += 1
        branch_metrics_map[metric_key]["total_revenue"] += total_amount
        branch_metrics_map[metric_key]["total_recommendations"] += 1

        transactions.append(tx)

    db.add_all(recommendations)
    db.add_all(face_events)
    db.flush()

    metrics_rows = []
    for (branch_id, metric_date), agg in branch_metrics_map.items():
        total_tx = agg["total_transactions"]
        total_recs = agg["total_recommendations"]

        metrics_rows.append(
            BranchMetrics(
                branch_id=branch_id,
                date=metric_date,
                total_transactions=total_tx,
                total_revenue=round(agg["total_revenue"], 2),
                avg_transaction_value=(
                    round(agg["total_revenue"] / total_tx, 2) if total_tx else 0
                ),
                total_recommendations=total_recs,
                avg_latency_ms=round(random.uniform(60, 220), 2),
                inference_count=random.randint(50, 500),
                top_selling_products=random.sample(
                    [p.name for p in products], k=min(5, len(products))
                ),
                out_of_stock_items=random.sample(
                    [p.name for p in products if (p.stock or 0) < 5],
                    k=min(3, len([p for p in products if (p.stock or 0) < 5])),
                ),
                created_at=datetime.utcnow(),
            )
        )

    db.add_all(metrics_rows)
    db.flush()
    return transactions


def seed_modeling_tables(db, stores, products, devices, customers):
    model_versions = [
        ModelVersion(
            version="recommender_v1.0.0",
            model_type="recommender",
            model_path="/models/recommender_v1.pkl",
            model_size_mb=128.4,
            accuracy=0.84,
            precision=0.81,
            recall=0.78,
            f1_score=0.79,
            training_date=datetime.utcnow() - timedelta(days=30),
            deployed_to_branches=[s.id for s in stores],
            is_active=False,
        ),
        ModelVersion(
            version="recommender_v1.1.0",
            model_type="recommender",
            model_path="/models/recommender_v1_1.pkl",
            model_size_mb=132.1,
            accuracy=0.88,
            precision=0.85,
            recall=0.83,
            f1_score=0.84,
            training_date=datetime.utcnow() - timedelta(days=7),
            deployed_to_branches=[s.id for s in stores],
            is_active=True,
        ),
    ]
    db.add_all(model_versions)
    db.flush()

    perf_logs = []
    for mv in model_versions:
        for store in stores:
            for days_ago in range(7):
                perf_logs.append(
                    ModelPerformanceLog(
                        model_version=mv.version,
                        date=datetime.utcnow() - timedelta(days=days_ago),
                        branch_id=store.id,
                        precision_at_5=round(random.uniform(0.65, 0.93), 3),
                        recall_at_5=round(random.uniform(0.5, 0.9), 3),
                        ndcg_at_5=round(random.uniform(0.55, 0.95), 3),
                        ctr=round(random.uniform(0.08, 0.31), 3),
                        avg_latency_ms=round(random.uniform(45, 140), 2),
                        p95_latency_ms=round(random.uniform(100, 240), 2),
                    )
                )
    db.add_all(perf_logs)

    exp = ABExperiment(
        experiment_id="EXP_REC_001",
        experiment_name="Recommendation Ranking UI Test",
        variant_a={"model_version": "recommender_v1.0.0", "layout": "control"},
        variant_b={"model_version": "recommender_v1.1.0", "layout": "carousel_v2"},
        split_ratio=0.5,
        target_branches=[s.id for s in stores],
        target_metric="ctr",
        status="running",
        start_date=datetime.utcnow() - timedelta(days=14),
        end_date=datetime.utcnow() + timedelta(days=14),
    )
    db.add(exp)
    db.flush()

    ab_events = []
    for _ in range(120):
        customer = random.choice(customers) if rand_bool(0.7) else None
        store = random.choice(stores)
        device = random.choice([d for d in devices if d.branch_id == store.id])

        variant = random.choice(["a", "b"])
        converted = rand_bool(0.38 if variant == "a" else 0.48)
        metric_value = round(random.uniform(0, 500000), 2) if converted else 0.0

        ab_events.append(
            ABExperimentEvent(
                experiment_id=exp.experiment_id,
                variant=variant,
                branch_id=store.id,
                customer_id=customer.id if customer else None,
                device_id=device.id,
                converted=converted,
                metric_value=metric_value,
                timestamp=rand_date_within(20),
            )
        )
    db.add_all(ab_events)

    fl_rounds = []
    for round_num in range(1, 4):
        fl_rounds.append(
            FederatedLearningRound(
                round_number=round_num,
                model_type="recommender",
                aggregation_method="fedavg",
                participating_branches=[s.id for s in stores],
                total_branches=len(stores),
                status="completed" if round_num < 3 else "aggregating",
                started_at=datetime.utcnow() - timedelta(days=10 - round_num),
                completed_at=(
                    datetime.utcnow() - timedelta(days=9 - round_num)
                    if round_num < 3
                    else None
                ),
            )
        )
    db.add_all(fl_rounds)
    db.flush()

    updates = []
    for round_num in range(1, 4):
        for store in stores:
            updates.append(
                FederatedClientUpdate(
                    round_number=round_num,
                    branch_id=store.id,
                    update_path=f"/fl/round_{round_num}/{store.id}.npy",
                    update_size_mb=round(random.uniform(3.2, 18.5), 2),
                    local_loss=round(random.uniform(0.1, 0.8), 4),
                    local_accuracy=round(random.uniform(0.7, 0.96), 4),
                    local_samples_count=random.randint(100, 2000),
                    status=random.choice(["received", "aggregated", "received"]),
                )
            )
    db.add_all(updates)

    optimizations = []
    for store in stores:
        for p in random.sample(products, k=min(20, len(products))):
            action = random.choice(["restock", "transfer", "markdown"])
            qty = (
                random.randint(5, 50) if action != "markdown" else random.randint(1, 20)
            )
            optimizations.append(
                InventoryOptimization(
                    branch_id=store.id,
                    product_id=p.id,
                    action=action,
                    quantity=qty,
                    priority=random.choice(["high", "medium", "low"]),
                    reason=random.choice(
                        [
                            "High demand in last 7 days",
                            "Low stock threshold reached",
                            "Excess inventory detected",
                            "Cross-branch balancing suggestion",
                        ]
                    ),
                    status=random.choice(["pending", "applied", "ignored"]),
                )
            )
    unique_opts = {}
    for row in optimizations:
        unique_opts[(row.branch_id, row.product_id, row.action)] = row

    db.add_all(list(unique_opts.values()))
    db.flush()


def truncate_all(db):
    # Dùng cho SQLite/Postgres đơn giản khi seed lại
    # Nếu bạn không muốn xoá dữ liệu cũ thì bỏ function này đi.
    tables = [
        TransactionItem,
        Transaction,
        Recommendation,
        FaceEvent,
        ProductAssociation,
        BranchInventory,
        PromotionProduct,
        PromotionBranch,
        Promotion,
        CustomerConsent,
        PrivacyAuditLog,
        UserAccount,
        CustomerStats,
        Customer,
        BranchMetrics,
        ModelPerformanceLog,
        InventoryOptimization,
        ABExperimentEvent,
        ABExperiment,
        FederatedClientUpdate,
        FederatedLearningRound,
        ModelVersion,
        EdgeDevice,
        Product,
        Store,
    ]
    for model in tables:
        db.query(model).delete()
    db.commit()


def main():
    db = create_session()

    reset = os.getenv("RESET_DB", "true").lower() == "true"
    if reset:
        truncate_all(db)

    stores, devices = seed_stores_and_devices(db)
    products = seed_products_from_csv(db)
    seed_branch_inventory(db, stores, products)
    seed_product_associations(db, products)
    customers = seed_customers(db, stores, count=60)
    seed_promotions(db, stores, products)
    seed_transactions_and_related(db, stores, devices, products, customers, count=180)
    seed_modeling_tables(db, stores, products, devices, customers)

    db.commit()

    print("Seed completed successfully.")
    print(f"Stores: {db.query(Store).count()}")
    print(f"Products: {db.query(Product).count()}")
    print(f"Customers: {db.query(Customer).count()}")
    print(f"Transactions: {db.query(Transaction).count()}")
    print(f"Recommendations: {db.query(Recommendation).count()}")
    print(f"Promotions: {db.query(Promotion).count()}")


if __name__ == "__main__":
    main()
