import csv
import os
import random
import sys
from dataclasses import dataclass
from datetime import date, datetime, timedelta
from decimal import Decimal
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
CLOUD_SERVER_DIR = SCRIPT_DIR.parent
if str(CLOUD_SERVER_DIR) not in sys.path:
    sys.path.insert(0, str(CLOUD_SERVER_DIR))

from passlib.context import CryptContext
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker

from database.models import (
    ABExperiment,
    ABExperimentEvent,
    AssociationRuleRaw,
    Base,
    BranchInventory,
    BranchMetrics,
    CartAssociationRule,
    Customer,
    CustomerConsent,
    CustomerStats,
    EdgeDevice,
    FaceEvent,
    FederatedClientUpdate,
    FederatedLearningRound,
    InventoryOptimization,
    ModelPerformanceLog,
    ModelVersion,
    PrivacyAuditLog,
    Product,
    ProductAssociation,
    Promotion,
    PromotionBranch,
    PromotionProduct,
    Recommendation,
    RecommendationEvent,
    Store,
    Transaction,
    TransactionItem,
    UserAccount,
)

DEFAULT_PRODUCT_CSV_PATH = CLOUD_SERVER_DIR / "data" / "Products.csv"

DATABASE_URL = os.getenv(
    "DATABASE_URL", "postgresql+psycopg2://admin:admin123@localhost:5433/retail_db"
)
PRODUCT_CSV_PATH = Path(os.getenv("PRODUCT_CSV_PATH", str(DEFAULT_PRODUCT_CSV_PATH)))
RANDOM_SEED = int(os.getenv("SEED", "42"))
SEED_DEFAULT_PASSWORD = os.getenv("SEED_DEFAULT_PASSWORD", "12345678")

random.seed(RANDOM_SEED)
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


@dataclass(frozen=True)
class SeedConfig:
    profile: str
    max_products: int
    customer_count: int
    transaction_count: int
    recommendation_per_tx_min: int
    recommendation_per_tx_max: int
    max_items_per_tx: int
    max_assoc_products_per_category: int
    assoc_links_per_product: int
    promotion_product_count: int
    performance_days: int
    ab_event_count: int
    fl_round_count: int
    optimization_product_count: int
    include_privacy_logs: bool
    include_modeling_tables: bool
    include_promotions: bool


def load_seed_config() -> SeedConfig:
    profile = os.getenv("SEED_PROFILE", "render_free").strip().lower()

    profiles = {
        "render_free": SeedConfig(
            profile="render_free",
            max_products=160,
            customer_count=24,
            transaction_count=96,
            recommendation_per_tx_min=1,
            recommendation_per_tx_max=5,
            max_items_per_tx=5,
            max_assoc_products_per_category=8,
            assoc_links_per_product=2,
            promotion_product_count=10,
            performance_days=3,
            ab_event_count=18,
            fl_round_count=2,
            optimization_product_count=8,
            include_privacy_logs=False,
            include_modeling_tables=True,
            include_promotions=True,
        ),
        "compact": SeedConfig(
            profile="compact",
            max_products=120,
            customer_count=40,
            transaction_count=120,
            recommendation_per_tx_min=2,
            recommendation_per_tx_max=3,
            max_items_per_tx=4,
            max_assoc_products_per_category=6,
            assoc_links_per_product=2,
            promotion_product_count=8,
            performance_days=5,
            ab_event_count=40,
            fl_round_count=2,
            optimization_product_count=12,
            include_privacy_logs=True,
            include_modeling_tables=True,
            include_promotions=True,
        ),
        "full": SeedConfig(
            profile="full",
            max_products=300,
            customer_count=60,
            transaction_count=180,
            recommendation_per_tx_min=2,
            recommendation_per_tx_max=4,
            max_items_per_tx=5,
            max_assoc_products_per_category=8,
            assoc_links_per_product=3,
            promotion_product_count=12,
            performance_days=7,
            ab_event_count=120,
            fl_round_count=3,
            optimization_product_count=20,
            include_privacy_logs=True,
            include_modeling_tables=True,
            include_promotions=True,
        ),
    }

    config = profiles.get(profile, profiles["render_free"])
    return SeedConfig(
        profile=config.profile,
        max_products=int(os.getenv("SEED_PRODUCT_LIMIT", str(config.max_products))),
        customer_count=int(
            os.getenv("SEED_CUSTOMER_COUNT", str(config.customer_count))
        ),
        transaction_count=int(
            os.getenv("SEED_TRANSACTION_COUNT", str(config.transaction_count))
        ),
        recommendation_per_tx_min=int(
            os.getenv(
                "SEED_RECOMMENDATION_MIN",
                str(config.recommendation_per_tx_min),
            )
        ),
        recommendation_per_tx_max=int(
            os.getenv(
                "SEED_RECOMMENDATION_MAX",
                str(config.recommendation_per_tx_max),
            )
        ),
        max_items_per_tx=int(
            os.getenv("SEED_MAX_ITEMS_PER_TX", str(config.max_items_per_tx))
        ),
        max_assoc_products_per_category=int(
            os.getenv(
                "SEED_ASSOC_PRODUCTS_PER_CATEGORY",
                str(config.max_assoc_products_per_category),
            )
        ),
        assoc_links_per_product=int(
            os.getenv(
                "SEED_ASSOC_LINKS_PER_PRODUCT",
                str(config.assoc_links_per_product),
            )
        ),
        promotion_product_count=int(
            os.getenv(
                "SEED_PROMOTION_PRODUCT_COUNT",
                str(config.promotion_product_count),
            )
        ),
        performance_days=int(
            os.getenv("SEED_PERFORMANCE_DAYS", str(config.performance_days))
        ),
        ab_event_count=int(os.getenv("SEED_AB_EVENT_COUNT", str(config.ab_event_count))),
        fl_round_count=int(os.getenv("SEED_FL_ROUND_COUNT", str(config.fl_round_count))),
        optimization_product_count=int(
            os.getenv(
                "SEED_OPTIMIZATION_PRODUCT_COUNT",
                str(config.optimization_product_count),
            )
        ),
        include_privacy_logs=os.getenv(
            "SEED_INCLUDE_PRIVACY_LOGS",
            str(config.include_privacy_logs),
        ).lower()
        == "true",
        include_modeling_tables=os.getenv(
            "SEED_INCLUDE_MODELING_TABLES",
            str(config.include_modeling_tables),
        ).lower()
        == "true",
        include_promotions=os.getenv(
            "SEED_INCLUDE_PROMOTIONS",
            str(config.include_promotions),
        ).lower()
        == "true",
    )


SEED_CONFIG = load_seed_config()


FIRST_NAMES = [
    "An",
    "Binh",
    "Chi",
    "Dung",
    "Ha",
    "Huy",
    "Khanh",
    "Lan",
    "Linh",
    "Minh",
    "My",
    "Nam",
    "Ngoc",
    "Phuc",
    "Quan",
    "Trang",
    "Vy",
]
LAST_NAMES = ["Nguyen", "Tran", "Le", "Pham", "Hoang", "Phan", "Vu", "Dang"]
SEGMENTS = ["VIP", "Potential", "Churn Risk", "Loyal", "New"]
AGE_GROUPS = ["18_24", "25_34", "35_44", "45_54"]
GENDERS = ["male", "female", "unisex"]
FAVORITE_CATEGORIES = [
    "Snack",
    "Nước giải khát",
    "Sữa & chế phẩm",
    "Gia vị",
    "Chăm sóc cá nhân",
]
DEMO_BUNDLE_CATEGORY_GROUPS = [
    ["Mì / Bún / Phở", "Snack", "Nước giải khát"],
    ["Dầu ăn", "Gia vị", "Rau gia vị"],
    ["Sữa & chế phẩm", "Snack", "Nước giải khát"],
    ["Chăm sóc cá nhân", "Hóa phẩm tẩy rửa", "Sản phẩm giấy"],
    ["Đồ uống có cồn", "Snack", "Nước giải khát"],
    ["Văn phòng phẩm", "Pin", "Phụ kiện điện"],
]
DEMO_EMOTIONS = ["neutral", "happy", "tired", "anger", "sad", "fear"]


def rand_bool(probability: float = 0.5) -> bool:
    return random.random() < probability


def rand_date_within(days_back: int = 90) -> datetime:
    return datetime.utcnow() - timedelta(
        days=random.randint(0, max(days_back, 0)),
        hours=random.randint(0, 23),
        minutes=random.randint(0, 59),
    )


def create_session():
    engine = create_engine(DATABASE_URL, future=True)
    Base.metadata.create_all(engine)
    session_local = sessionmaker(bind=engine, autoflush=False, autocommit=False)
    return session_local()


def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def parse_decimal(value, fallback: str = "0") -> Decimal:
    try:
        return Decimal(str(round(float(value), 2)))
    except (TypeError, ValueError):
        return Decimal(fallback)


def nullable_str(value):
    if value is None:
        return None
    text = str(value).strip()
    return text or None


def load_product_rows(limit: int) -> list[dict]:
    csv_path = PRODUCT_CSV_PATH
    if not csv_path.exists() and DEFAULT_PRODUCT_CSV_PATH.exists():
        csv_path = DEFAULT_PRODUCT_CSV_PATH

    if not csv_path.exists():
        raise FileNotFoundError(f"Product CSV not found: {PRODUCT_CSV_PATH}")

    with csv_path.open("r", encoding="utf-8-sig", newline="") as handle:
        reader = csv.DictReader(handle)
        rows = list(reader)

    if limit <= 0:
        return rows
    return rows[:limit]


def build_demo_bundles(products, max_per_category: int = 3) -> list[list]:
    by_category = {}
    for product in products:
        by_category.setdefault(product.category or "General", []).append(product)

    bundles = []
    for category_group in DEMO_BUNDLE_CATEGORY_GROUPS:
        bundle = []
        for category in category_group:
            candidates = by_category.get(category, [])
            if not candidates:
                continue
            bundle.extend(candidates[:max_per_category])
        if len(bundle) >= 3:
            bundles.append(bundle)

    for category, candidates in by_category.items():
        if len(candidates) >= 3:
            bundles.append(candidates[: min(max_per_category + 2, len(candidates))])

    return bundles


def seed_stores_and_devices(db):
    stores = [
        Store(id="HCM_Q1", name="Mart Quan 1", address="12 Nguyen Hue, Quan 1, HCM"),
        Store(id="HCM_Q7", name="Mart Quan 7", address="99 Nguyen Thi Thap, Quan 7, HCM"),
        Store(id="HN_CG", name="Mart Cau Giay", address="45 Tran Thai Tong, Cau Giay, Ha Noi"),
    ]
    db.add_all(stores)
    db.flush()

    devices = [
        EdgeDevice(
            id="EDGE_HCM_Q1_01",
            branch_id="HCM_Q1",
            name="Edge Cam Q1 - 01",
            description="Entrance camera",
            ip_address="192.168.1.11",
            status="active",
            last_seen=datetime.utcnow(),
        ),
        EdgeDevice(
            id="EDGE_HCM_Q7_01",
            branch_id="HCM_Q7",
            name="Edge Cam Q7 - 01",
            description="Checkout camera",
            ip_address="192.168.1.21",
            status="active",
            last_seen=datetime.utcnow(),
        ),
        EdgeDevice(
            id="EDGE_HN_CG_01",
            branch_id="HN_CG",
            name="Edge Cam Cau Giay - 01",
            description="Entrance camera",
            ip_address="192.168.1.31",
            status="active",
            last_seen=datetime.utcnow(),
        ),
    ]
    db.add_all(devices)
    db.flush()
    return stores, devices


def seed_products_from_csv(db, config: SeedConfig):
    rows = load_product_rows(config.max_products)
    products = []

    for index, row in enumerate(rows):
        base_price = parse_decimal(row.get("price"), "0")
        has_discount = rand_bool(0.25)
        discount_percent = random.choice([5, 10, 15]) if has_discount else None
        discount_price = (
            round(float(base_price) * (1 - discount_percent / 100), 2)
            if discount_percent
            else None
        )

        stock_value = row.get("stock")
        try:
            stock = int(float(stock_value)) if stock_value not in (None, "") else random.randint(5, 60)
        except ValueError:
            stock = random.randint(5, 60)

        category = nullable_str(row.get("category")) or "General"

        target_gender = nullable_str(row.get("target_gender"))
        if not target_gender or target_gender == "unisex":
            target_gender = ["unisex", "female", "male", "unisex"][index % 4]

        target_age_group = nullable_str(row.get("target_age_group"))
        if not target_age_group:
            target_age_group = AGE_GROUPS[index % len(AGE_GROUPS)]

        emotion = nullable_str(row.get("mood_tag"))
        if not emotion or emotion == "neutral":
            emotion = DEMO_EMOTIONS[index % len(DEMO_EMOTIONS)]

        products.append(
            Product(
                product_code=str(row.get("product_code") or f"P{len(products) + 1:05d}"),
                name=str(row.get("name") or f"Product {len(products) + 1}"),
                volume=nullable_str(row.get("volume")),
                price=base_price,
                discount_price=discount_price,
                discount_percent=discount_percent,
                category=category,
                stock=stock,
                description=f"{category} product for demo data.",
                image_url=nullable_str(row.get("image_url")),
                emotion=emotion,
                target_age_group=target_age_group,
                target_gender=target_gender,
                usage_context=nullable_str(row.get("usage_context")),
            )
        )

    db.add_all(products)
    db.flush()
    return products


def seed_branch_inventory(db, stores, products):
    rows = []
    for store in stores:
        for product in products:
            stock = max(0, int((product.stock or 0) * random.uniform(0.5, 1.1)))
            reserved = random.randint(0, min(stock, 5)) if stock > 0 else 0
            rows.append(
                BranchInventory(
                    branch_id=store.id,
                    product_id=product.id,
                    stock=stock,
                    reserved=reserved,
                )
            )

    db.add_all(rows)
    db.flush()


def seed_product_associations(db, products, config: SeedConfig):
    by_category = {}
    for product in products:
        by_category.setdefault(product.category or "General", []).append(product)

    associations = {}
    cart_rules = []

    def add_seed_rule(antecedents, consequents, confidence, lift, support):
        raw_rule = AssociationRuleRaw(
            antecedent_product_ids=sorted({product.id for product in antecedents}),
            consequent_product_ids=sorted({product.id for product in consequents}),
            antecedent_size=len({product.id for product in antecedents}),
            consequent_size=len({product.id for product in consequents}),
            confidence=confidence,
            lift=lift,
            support=support,
            algorithm="seed",
            is_active=True,
        )
        db.add(raw_rule)
        db.flush()
        return raw_rule

    for bundle in build_demo_bundles(products):
        top_items = bundle[: min(len(bundle), 6)]

        for index, product in enumerate(top_items):
            related_candidates = [
                item for item in top_items if item.id != product.id
            ][:3]
            for related in related_candidates:
                raw_rule = add_seed_rule(
                    [product],
                    [related],
                    confidence=round(random.uniform(0.62, 0.92), 2),
                    lift=round(random.uniform(1.35, 2.8), 2),
                    support=round(random.uniform(0.08, 0.22), 3),
                )
                associations[(product.id, related.id)] = ProductAssociation(
                    source_rule_id=raw_rule.id,
                    product_id=product.id,
                    related_product_id=related.id,
                    confidence=raw_rule.confidence,
                    lift=raw_rule.lift,
                    support=raw_rule.support,
                )

            if index + 2 < len(top_items):
                antecedents = top_items[index : index + 2]
                consequent = top_items[index + 2]
                raw_rule = add_seed_rule(
                    antecedents,
                    [consequent],
                    confidence=round(random.uniform(0.55, 0.85), 2),
                    lift=round(random.uniform(1.4, 3.0), 2),
                    support=round(random.uniform(0.06, 0.18), 3),
                )
                cart_rules.append(
                    CartAssociationRule(
                        source_rule_id=raw_rule.id,
                        antecedent_product_ids=raw_rule.antecedent_product_ids,
                        consequent_product_ids=raw_rule.consequent_product_ids,
                        antecedent_size=raw_rule.antecedent_size,
                        consequent_size=raw_rule.consequent_size,
                        confidence=raw_rule.confidence,
                        lift=raw_rule.lift,
                        support=raw_rule.support,
                    )
                )

    for group in by_category.values():
        if len(group) < 2:
            continue

        sample_size = min(len(group), config.max_assoc_products_per_category)
        sample_group = random.sample(group, sample_size)
        for product in sample_group:
            related_candidates = [item for item in sample_group if item.id != product.id]
            if not related_candidates:
                continue

            related_count = min(config.assoc_links_per_product, len(related_candidates))
            for related in random.sample(related_candidates, related_count):
                raw_rule = AssociationRuleRaw(
                    antecedent_product_ids=[product.id],
                    consequent_product_ids=[related.id],
                    antecedent_size=1,
                    consequent_size=1,
                    confidence=round(random.uniform(0.45, 0.9), 2),
                    lift=round(random.uniform(1.05, 2.1), 2),
                    support=round(random.uniform(0.02, 0.18), 3),
                    algorithm="seed",
                    is_active=True,
                )
                db.add(raw_rule)
                db.flush()
                associations[(product.id, related.id)] = ProductAssociation(
                    source_rule_id=raw_rule.id,
                    product_id=product.id,
                    related_product_id=related.id,
                    confidence=raw_rule.confidence,
                    lift=raw_rule.lift,
                    support=raw_rule.support,
                )

        if len(sample_group) >= 3:
            for bundle in random.sample(
                sample_group,
                min(3, max(1, len(sample_group) // 4)),
            ):
                antecedents = [
                    item.id
                    for item in random.sample(
                        [item for item in sample_group if item.id != bundle.id],
                        2,
                    )
                ]
                raw_rule = AssociationRuleRaw(
                    antecedent_product_ids=sorted(antecedents),
                    consequent_product_ids=[bundle.id],
                    antecedent_size=2,
                    consequent_size=1,
                    confidence=round(random.uniform(0.35, 0.75), 2),
                    lift=round(random.uniform(1.05, 2.5), 2),
                    support=round(random.uniform(0.01, 0.12), 3),
                    algorithm="seed",
                    is_active=True,
                )
                db.add(raw_rule)
                db.flush()
                cart_rules.append(
                    CartAssociationRule(
                        source_rule_id=raw_rule.id,
                        antecedent_product_ids=raw_rule.antecedent_product_ids,
                        consequent_product_ids=raw_rule.consequent_product_ids,
                        antecedent_size=raw_rule.antecedent_size,
                        consequent_size=raw_rule.consequent_size,
                        confidence=raw_rule.confidence,
                        lift=raw_rule.lift,
                        support=raw_rule.support,
                    )
                )

    db.add_all(list(associations.values()))
    db.add_all(cart_rules)
    db.flush()


def seed_customers(db, stores, config: SeedConfig):
    customers = []
    stats_rows = []
    consent_rows = []
    user_accounts = []
    audit_logs = []

    for index in range(1, config.customer_count + 1):
        first_name = random.choice(FIRST_NAMES)
        last_name = random.choice(LAST_NAMES)
        age = random.randint(18, 54)
        birth_year = datetime.utcnow().year - age

        customer = Customer(
            customer_id=f"CUS{index:04d}",
            first_name=first_name,
            last_name=last_name,
            phone=f"09{random.randint(10000000, 99999999)}",
            email=f"customer{index:04d}@gmail.com",
            cccd=f"{random.randint(100000000000, 999999999999)}",
            address=f"{random.randint(1, 300)} Demo Street",
            birth_date=date(birth_year, random.randint(1, 12), random.randint(1, 28)),
            age=age,
            age_group=random.choice(AGE_GROUPS),
            gender=random.choice(GENDERS),
            description="Demo customer",
            preferred_branch=random.choice(stores).id,
            avg_basket_size=round(random.uniform(80000, 350000), 2),
            first_seen=rand_date_within(120),
            last_seen=rand_date_within(10),
            created_at=rand_date_within(120),
        )
        customers.append(customer)

    db.add_all(customers)
    db.flush()

    for customer in customers:
        stats_rows.append(
            CustomerStats(
                customer_id=customer.id,
                total_transactions=random.randint(0, 12),
                total_spent=Decimal(str(round(random.uniform(100000, 3000000), 2))),
                avg_basket_size=Decimal(str(round(random.uniform(80000, 350000), 2))),
                favorite_categories=random.sample(FAVORITE_CATEGORIES, k=3),
                last_purchase_date=rand_date_within(30),
                rank_score=round(random.uniform(10, 100), 2),
                segment=random.choice(SEGMENTS),
            )
        )

        consent_rows.append(
            CustomerConsent(
                customer_id=customer.id,
                face_recognition_consent=rand_bool(0.75),
                data_collection_consent=rand_bool(0.85),
                marketing_consent=rand_bool(0.55),
                opted_out=rand_bool(0.08),
                opted_out_at=rand_date_within(60) if rand_bool(0.08) else None,
                opt_out_reason="No marketing" if rand_bool(0.05) else None,
                consent_method=random.choice(["kiosk", "mobile", "staff"]),
                consent_ip_address=f"10.0.0.{random.randint(2, 254)}",
                consent_location=random.choice(["Q1 kiosk", "Q7 kiosk", "HN app"]),
                data_retention_until=datetime.utcnow()
                + timedelta(days=random.randint(90, 365)),
            )
        )

        user_accounts.append(
            UserAccount(
                email=customer.email,
                password_hash=hash_password(SEED_DEFAULT_PASSWORD),
                customer_pk=customer.id,
            )
        )

        if config.include_privacy_logs:
            audit_logs.append(
                PrivacyAuditLog(
                    customer_id=customer.id,
                    operation_type=random.choice(
                        ["consent_given", "consent_updated", "data_accessed"]
                    ),
                    operation_details={"source": "seed_script"},
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
    if audit_logs:
        db.add_all(audit_logs)
    db.flush()
    return customers


def seed_promotions(db, stores, products, config: SeedConfig):
    promotions = [
        Promotion(
            code="WEEKEND10",
            name="Weekend 10 percent off",
            discount_type="PERCENT",
            start_at=datetime.utcnow() - timedelta(days=3),
            end_at=datetime.utcnow() + timedelta(days=7),
            is_active=True,
        ),
        Promotion(
            code="COMBOFIX",
            name="Fixed combo discount",
            discount_type="FIXED",
            start_at=datetime.utcnow() - timedelta(days=5),
            end_at=datetime.utcnow() + timedelta(days=10),
            is_active=True,
        ),
    ]
    db.add_all(promotions)
    db.flush()

    for promotion in promotions:
        target_stores = random.sample(stores, k=random.randint(1, len(stores)))
        for store in target_stores:
            db.add(PromotionBranch(promotion_id=promotion.id, branch_id=store.id))

        target_products = random.sample(
            products, k=min(config.promotion_product_count, len(products))
        )
        for product in target_products:
            discount_value = (
                10
                if promotion.discount_type == "PERCENT"
                else random.choice([5000, 10000])
            )
            db.add(
                PromotionProduct(
                    promotion_id=promotion.id,
                    product_id=product.id,
                    discount_value=float(discount_value),
                    max_qty_per_customer=random.choice([1, 2, None]),
                )
            )

    db.flush()


def build_recommendation_payload(products):
    return [
        {
            "product_id": product.id,
            "product_code": product.product_code,
            "score": round(random.uniform(0.6, 0.98), 2),
        }
        for product in products
    ]


def seed_transactions_and_related(db, stores, devices, products, customers, config: SeedConfig):
    recommendations = []
    recommendation_events = []
    face_events = []
    branch_metrics_map = {}

    devices_by_branch = {}
    for device in devices:
        devices_by_branch.setdefault(device.branch_id, []).append(device)

    demo_bundles = build_demo_bundles(products)
    no_history_count = min(5, len(customers))
    no_history_customer_ids = {
        customer.id for customer in customers[:no_history_count]
    }
    customers_with_history = [
        customer for customer in customers if customer.id not in no_history_customer_ids
    ]

    scheduled_customers = []
    for customer in customers_with_history:
        scheduled_customers.extend([customer] * random.randint(1, 3))

    random.shuffle(scheduled_customers)

    target_total_transactions = max(config.transaction_count, len(scheduled_customers))
    scheduled_customer_iter = iter(scheduled_customers)
    customer_purchase_stats = {
        customer.id: {
            "total_transactions": 0,
            "total_spent": 0.0,
            "category_counts": {},
            "last_purchase_date": None,
        }
        for customer in customers
    }

    for index in range(1, target_total_transactions + 1):
        store = random.choice(stores)
        device = random.choice(devices_by_branch[store.id])
        customer = next(scheduled_customer_iter, None)
        if demo_bundles and rand_bool(0.75):
            bundle = random.choice(demo_bundles)
            purchased_products = random.sample(
                bundle,
                k=random.randint(2, min(config.max_items_per_tx, len(bundle))),
            )
        else:
            purchased_products = random.sample(
                products,
                k=random.randint(1, min(config.max_items_per_tx, len(products))),
            )
        transaction_time = rand_date_within(45)

        items_data = []
        total_amount = 0.0
        transaction = Transaction(
            branch_id=store.id,
            transaction_id=f"TXN-{transaction_time.strftime('%Y%m%d')}-{index:05d}",
            timestamp=transaction_time,
            customer_id=customer.id if customer else None,
            device_id=device.id,
            items_data=[],
            items_count=0,
            total_amount=0,
            recommended_items=[],
            created_at=transaction_time,
        )
        db.add(transaction)
        db.flush()

        for product in purchased_products:
            qty = random.randint(1, 3)
            unit_price = float(product.discount_price or product.price)
            total_amount += qty * unit_price
            items_data.append(
                {
                    "product_id": product.id,
                    "product_code": product.product_code,
                    "qty": qty,
                    "unit_price": unit_price,
                }
            )
            db.add(
                TransactionItem(
                    transaction_id=transaction.id,
                    product_id=product.id,
                    qty=qty,
                    unit_price=unit_price,
                )
            )

        rec_count = random.randint(
            config.recommendation_per_tx_min,
            min(config.recommendation_per_tx_max, len(products)),
        )
        recommended_products = random.sample(products, k=rec_count)
        recommended_payload = build_recommendation_payload(recommended_products)

        transaction.items_data = items_data
        transaction.items_count = len(items_data)
        transaction.total_amount = round(total_amount, 2)
        transaction.recommended_items = recommended_payload
        if customer:
            customer_stats = customer_purchase_stats[customer.id]
            customer_stats["total_transactions"] += 1
            customer_stats["total_spent"] += total_amount
            customer_stats["last_purchase_date"] = max(
                customer_stats["last_purchase_date"] or transaction_time,
                transaction_time,
            )
            for product in purchased_products:
                category = product.category or "General"
                category_counts = customer_stats["category_counts"]
                category_counts[category] = category_counts.get(category, 0) + 1

        recommendations.append(
            Recommendation(
                branch_id=store.id,
                transaction_id=transaction.transaction_id,
                timestamp=transaction_time - timedelta(minutes=random.randint(1, 10)),
                customer_id=customer.id if customer else None,
                device_id=device.id,
                recommendation_context={
                    "age_group": customer.age_group if customer else random.choice(AGE_GROUPS),
                    "gender": customer.gender if customer else random.choice(["male", "female"]),
                },
                recommended_products=recommended_payload,
                items_count=len(recommended_payload),
                created_at=transaction_time,
            )
        )

        face_events.append(
            FaceEvent(
                branch_id=store.id,
                device_id=device.id,
                event_type=random.choice(["face_recognized", "no_face"]),
                timestamp=transaction_time - timedelta(minutes=random.randint(1, 20)),
                customer_id=customer.id if (customer and rand_bool(0.7)) else None,
                similarity=round(random.uniform(0.72, 0.98), 2) if customer else None,
                face_attributes={
                    "age_group": customer.age_group if customer else random.choice(AGE_GROUPS),
                    "gender": customer.gender if customer else random.choice(["male", "female"]),
                },
                transaction_id=transaction.transaction_id,
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

    for customer_id, stats in customer_purchase_stats.items():
        stats_row = (
            db.query(CustomerStats)
            .filter(CustomerStats.customer_id == customer_id)
            .first()
        )
        if not stats_row:
            continue

        total_transactions = stats["total_transactions"]
        total_spent = round(stats["total_spent"], 2)
        favorite_categories = [
            category
            for category, _ in sorted(
                stats["category_counts"].items(),
                key=lambda item: item[1],
                reverse=True,
            )[:3]
        ]

        stats_row.total_transactions = total_transactions
        stats_row.total_spent = Decimal(str(total_spent))
        stats_row.avg_basket_size = Decimal(
            str(round(total_spent / total_transactions, 2))
        ) if total_transactions else Decimal("0")
        stats_row.favorite_categories = favorite_categories
        stats_row.last_purchase_date = stats["last_purchase_date"]

    db.add_all(recommendations)
    db.add_all(face_events)
    db.flush()

    for recommendation in recommendations:
        products_payload = recommendation.recommended_products or []
        for position, product_payload in enumerate(products_payload, start=1):
            product_id = product_payload.get("product_id")
            if not product_id:
                continue

            recommendation_events.append(
                RecommendationEvent(
                    event_type="impression",
                    product_id=int(product_id),
                    customer_id=recommendation.customer_id,
                    branch_id=recommendation.branch_id,
                    device_id=recommendation.device_id,
                    surface="seed_customer_recommendation",
                    algorithm="seed_hybrid",
                    position=position,
                    session_id=recommendation.transaction_id,
                    recommendation_id=recommendation.id,
                    event_metadata={"source": "seed_data"},
                    timestamp=recommendation.timestamp,
                    created_at=recommendation.created_at,
                )
            )

            if rand_bool(0.35):
                recommendation_events.append(
                    RecommendationEvent(
                        event_type="click",
                        product_id=int(product_id),
                        customer_id=recommendation.customer_id,
                        branch_id=recommendation.branch_id,
                        device_id=recommendation.device_id,
                        surface="seed_customer_recommendation",
                        algorithm="seed_hybrid",
                        position=position,
                        session_id=recommendation.transaction_id,
                        recommendation_id=recommendation.id,
                        event_metadata={"source": "seed_data"},
                        timestamp=recommendation.timestamp + timedelta(seconds=30),
                        created_at=recommendation.created_at,
                    )
                )

            if rand_bool(0.18):
                recommendation_events.append(
                    RecommendationEvent(
                        event_type="add_to_cart",
                        product_id=int(product_id),
                        customer_id=recommendation.customer_id,
                        branch_id=recommendation.branch_id,
                        device_id=recommendation.device_id,
                        surface="seed_customer_recommendation",
                        algorithm="seed_hybrid",
                        position=position,
                        session_id=recommendation.transaction_id,
                        recommendation_id=recommendation.id,
                        event_metadata={"source": "seed_data"},
                        timestamp=recommendation.timestamp + timedelta(seconds=90),
                        created_at=recommendation.created_at,
                    )
                )

    if recommendation_events:
        db.add_all(recommendation_events)
        db.flush()

    metrics_rows = []
    product_names = [product.name for product in products]
    low_stock_names = [product.name for product in products if (product.stock or 0) < 5]

    for (branch_id, metric_date), aggregated in branch_metrics_map.items():
        total_transactions = aggregated["total_transactions"]
        metrics_rows.append(
            BranchMetrics(
                branch_id=branch_id,
                date=metric_date,
                total_transactions=total_transactions,
                total_revenue=round(aggregated["total_revenue"], 2),
                avg_transaction_value=(
                    round(aggregated["total_revenue"] / total_transactions, 2)
                    if total_transactions
                    else 0
                ),
                total_recommendations=aggregated["total_recommendations"],
                avg_latency_ms=round(random.uniform(60, 220), 2),
                inference_count=random.randint(20, 200),
                top_selling_products=random.sample(
                    product_names, k=min(3, len(product_names))
                ),
                out_of_stock_items=random.sample(
                    low_stock_names, k=min(2, len(low_stock_names))
                )
                if low_stock_names
                else [],
                created_at=datetime.utcnow(),
            )
        )

    db.add_all(metrics_rows)
    db.flush()


def seed_modeling_tables(db, stores, products, devices, customers, config: SeedConfig):
    model_versions = [
        ModelVersion(
            version="recommender_v1.0.0",
            model_type="recommender",
            model_path="/models/recommender_v1.pkl",
            model_size_mb=96.4,
            accuracy=0.84,
            precision=0.81,
            recall=0.78,
            f1_score=0.79,
            training_date=datetime.utcnow() - timedelta(days=30),
            deployed_to_branches=[store.id for store in stores],
            is_active=False,
        ),
        ModelVersion(
            version="recommender_v1.1.0",
            model_type="recommender",
            model_path="/models/recommender_v1_1.pkl",
            model_size_mb=101.2,
            accuracy=0.88,
            precision=0.85,
            recall=0.83,
            f1_score=0.84,
            training_date=datetime.utcnow() - timedelta(days=7),
            deployed_to_branches=[store.id for store in stores],
            is_active=True,
        ),
    ]
    db.add_all(model_versions)
    db.flush()

    performance_logs = []
    for model_version in model_versions:
        for store in stores:
            for days_ago in range(config.performance_days):
                performance_logs.append(
                    ModelPerformanceLog(
                        model_version=model_version.version,
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
    db.add_all(performance_logs)

    experiment = ABExperiment(
        experiment_id="EXP_REC_001",
        experiment_name="Recommendation Ranking UI Test",
        variant_a={"model_version": "recommender_v1.0.0", "layout": "control"},
        variant_b={"model_version": "recommender_v1.1.0", "layout": "carousel_v2"},
        split_ratio=0.5,
        target_branches=[store.id for store in stores],
        target_metric="ctr",
        status="running",
        start_date=datetime.utcnow() - timedelta(days=14),
        end_date=datetime.utcnow() + timedelta(days=14),
    )
    db.add(experiment)
    db.flush()

    device_by_branch = {}
    for device in devices:
        device_by_branch.setdefault(device.branch_id, []).append(device)

    ab_events = []
    for _ in range(config.ab_event_count):
        customer = random.choice(customers) if rand_bool(0.7) else None
        store = random.choice(stores)
        device = random.choice(device_by_branch[store.id])
        variant = random.choice(["a", "b"])
        converted = rand_bool(0.38 if variant == "a" else 0.48)

        ab_events.append(
            ABExperimentEvent(
                experiment_id=experiment.experiment_id,
                variant=variant,
                branch_id=store.id,
                customer_id=customer.id if customer else None,
                device_id=device.id,
                converted=converted,
                metric_value=round(random.uniform(0, 250000), 2) if converted else 0.0,
                timestamp=rand_date_within(20),
            )
        )
    db.add_all(ab_events)

    rounds = []
    for round_number in range(1, config.fl_round_count + 1):
        rounds.append(
            FederatedLearningRound(
                round_number=round_number,
                model_type="recommender",
                aggregation_method="fedavg",
                participating_branches=[store.id for store in stores],
                total_branches=len(stores),
                status="completed" if round_number < config.fl_round_count else "aggregating",
                started_at=datetime.utcnow() - timedelta(days=10 - round_number),
                completed_at=(
                    datetime.utcnow() - timedelta(days=9 - round_number)
                    if round_number < config.fl_round_count
                    else None
                ),
            )
        )
    db.add_all(rounds)
    db.flush()

    updates = []
    for round_number in range(1, config.fl_round_count + 1):
        for store in stores:
            updates.append(
                FederatedClientUpdate(
                    round_number=round_number,
                    branch_id=store.id,
                    update_path=f"/fl/round_{round_number}/{store.id}.npy",
                    update_size_mb=round(random.uniform(3.2, 12.0), 2),
                    local_loss=round(random.uniform(0.1, 0.8), 4),
                    local_accuracy=round(random.uniform(0.7, 0.96), 4),
                    local_samples_count=random.randint(100, 800),
                    status=random.choice(["received", "aggregated"]),
                )
            )
    db.add_all(updates)

    optimizations = {}
    for store in stores:
        target_products = random.sample(
            products, k=min(config.optimization_product_count, len(products))
        )
        for product in target_products:
            action = random.choice(["restock", "transfer", "markdown"])
            quantity = (
                random.randint(5, 30) if action != "markdown" else random.randint(1, 10)
            )
            optimizations[(store.id, product.id, action)] = InventoryOptimization(
                branch_id=store.id,
                product_id=product.id,
                action=action,
                quantity=quantity,
                priority=random.choice(["high", "medium", "low"]),
                reason=random.choice(
                    [
                        "High demand in last 7 days",
                        "Low stock threshold reached",
                        "Excess inventory detected",
                    ]
                ),
                status=random.choice(["pending", "applied", "ignored"]),
            )

    db.add_all(list(optimizations.values()))
    db.flush()


def truncate_all(db):
    table_names = [
        model.__tablename__
        for model in (
            TransactionItem,
            Transaction,
            RecommendationEvent,
            Recommendation,
            FaceEvent,
            ProductAssociation,
            CartAssociationRule,
            AssociationRuleRaw,
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
        )
    ]
    quoted_tables = ", ".join(f'"{name}"' for name in table_names)
    db.execute(text(f"TRUNCATE TABLE {quoted_tables} RESTART IDENTITY CASCADE"))
    db.commit()


def main():
    db = create_session()

    reset = os.getenv("RESET_DB", "true").lower() == "true"
    if reset:
        truncate_all(db)

    stores, devices = seed_stores_and_devices(db)
    products = seed_products_from_csv(db, SEED_CONFIG)
    seed_branch_inventory(db, stores, products)
    seed_product_associations(db, products, SEED_CONFIG)
    customers = seed_customers(db, stores, SEED_CONFIG)

    if SEED_CONFIG.include_promotions:
        seed_promotions(db, stores, products, SEED_CONFIG)

    seed_transactions_and_related(
        db,
        stores,
        devices,
        products,
        customers,
        SEED_CONFIG,
    )

    if SEED_CONFIG.include_modeling_tables:
        seed_modeling_tables(
            db,
            stores,
            products,
            devices,
            customers,
            SEED_CONFIG,
        )

    db.commit()

    print("Seed completed successfully.")
    print(f"Profile: {SEED_CONFIG.profile}")
    print(f"Stores: {db.query(Store).count()}")
    print(f"Products: {db.query(Product).count()}")
    print(f"Customers: {db.query(Customer).count()}")
    print(f"Transactions: {db.query(Transaction).count()}")
    print(f"Recommendations: {db.query(Recommendation).count()}")
    print(f"Promotions: {db.query(Promotion).count()}")


if __name__ == "__main__":
    main()
