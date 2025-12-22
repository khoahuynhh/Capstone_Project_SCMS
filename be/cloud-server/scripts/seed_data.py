import os
import random
import json
from datetime import datetime, timedelta, time
from typing import List, Dict, Optional, Tuple
from sqlalchemy.dialects.postgresql import insert
from dotenv import load_dotenv

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session

from database.models import (
    Store,
    Product,
    Customer,
    Transaction,
    TransactionItem,
    Recommendation,
    FaceEmbedding,
    Promotion,
    PromotionBranch,
    PromotionProduct,
    BranchInventory,
    EdgeDevice,
)

# -----------------------
# Config
# -----------------------
load_dotenv()
DAYS = 30
TX_PER_DAY = 100  # tổng 100 txn/ngày (chia cho các branch)
TOP_K = 5
PROMO_PRODUCTS_MIN = 10
PROMO_PRODUCTS_MAX = 30
EMBED_DIM = 512

RANDOM_SEED = 20251212
random.seed(RANDOM_SEED)

DATABASE_URL = os.getenv(
    "DATABASE_URL"
)  # ví dụ: postgresql+psycopg2://user:pass@host:5432/db
if not DATABASE_URL:
    raise RuntimeError("Missing DATABASE_URL env var")

engine = create_engine(DATABASE_URL, pool_pre_ping=True)
SessionLocal = sessionmaker(bind=engine, autocommit=False, autoflush=False)

DATA_DIR = "data"
CUSTOMERS_PATH = os.path.join(DATA_DIR, "customers.json")
EMBEDS_PATH = os.path.join(DATA_DIR, "face_embeddings.json")

customers_json = json.load(open(CUSTOMERS_PATH, "r", encoding="utf-8"))
embeds_json = json.load(open(EMBEDS_PATH, "r", encoding="utf-8"))


# -----------------------
# Helpers
# -----------------------
def build_branch_name_to_id(stores: list[Store]) -> dict[str, str]:
    """
    Map nhiều dạng key (address / name / id) -> stores.id
    Ví dụ:
      "HCM - Thu Duc" -> "branch_3"
      "Branch 3"      -> "branch_3"
      "branch_3"      -> "branch_3"
    """
    m: dict[str, str] = {}
    for st in stores:
        if st.id:
            m[str(st.id).strip()] = st.id
        if st.address:
            m[str(st.address).strip()] = st.id
        if st.name:
            m[str(st.name).strip()] = st.id
    return m


def import_customers_and_embeddings(
    db: Session,
    customers_json: list[dict],
    embeds_json: list[dict],
    branch_map: dict[str, str],
):
    # -------- 1) Upsert customers --------
    for c in customers_json:
        raw_branch = c.get("preferred_branch")
        preferred_branch = None
        if raw_branch is not None:
            preferred_branch = branch_map.get(str(raw_branch).strip())

        insert_stmt = insert(Customer).values(
            customer_id=c["customer_id"],
            first_name=c.get("first_name"),
            last_name=c.get("last_name"),
            phone=c.get("phone"),
            email=c.get("email"),
            age_group=c.get("age_group"),
            gender=c.get("gender"),
            total_transactions=c.get("total_transactions", 0),
            total_spent=c.get("total_spent", 0.0),
            favorite_categories=c.get("favorite_categories"),
            preferred_branch=preferred_branch,  # ✅ dùng branch_id đã map
            avg_basket_size=c.get("avg_basket_size"),
            first_seen=(
                datetime.fromisoformat(c["first_seen"]) if c.get("first_seen") else None
            ),
            last_seen=(
                datetime.fromisoformat(c["last_seen"]) if c.get("last_seen") else None
            ),
            created_at=(
                datetime.fromisoformat(c["created_at"]) if c.get("created_at") else None
            ),
        )

        excluded = insert_stmt.excluded

        upsert_stmt = insert_stmt.on_conflict_do_update(
            index_elements=[Customer.customer_id],
            set_={
                "first_name": excluded.first_name,
                "last_name": excluded.last_name,
                "phone": excluded.phone,
                "email": excluded.email,
                "age_group": excluded.age_group,
                "gender": excluded.gender,
                "total_transactions": excluded.total_transactions,
                "total_spent": excluded.total_spent,
                "favorite_categories": excluded.favorite_categories,
                "preferred_branch": excluded.preferred_branch,  # ✅ update đúng branch_id
                "avg_basket_size": excluded.avg_basket_size,
                "first_seen": excluded.first_seen,
                "last_seen": excluded.last_seen,
                "created_at": excluded.created_at,
            },
        )

        db.execute(upsert_stmt)

    db.commit()

    # -------- 2) Insert embeddings (skip existing) --------
    existing = set(x[0] for x in db.query(FaceEmbedding.customer_id).all())
    to_add: list[FaceEmbedding] = []

    for e in embeds_json:
        cid = e["customer_id"]
        emb = e["embedding"]

        if cid in existing:
            continue

        if not isinstance(emb, list) or len(emb) != EMBED_DIM:
            raise ValueError(f"Embedding for {cid} is not {EMBED_DIM}-dim")

        to_add.append(FaceEmbedding(customer_id=cid, embedding=emb))

    if to_add:
        db.add_all(to_add)
        db.commit()


def pick_weighted(items: List[Tuple[str, float]]) -> str:
    # items: [(value, weight)]
    total = sum(w for _, w in items)
    r = random.random() * total
    upto = 0.0
    for v, w in items:
        upto += w
        if upto >= r:
            return v
    return items[-1][0]


def is_weekend(dt: datetime) -> bool:
    return dt.weekday() >= 5


def rand_time_in_day(day: datetime) -> datetime:
    # peak hours: 10-12 and 18-21
    hour = pick_weighted(
        [
            ("10", 2.0),
            ("11", 2.0),
            ("12", 1.5),
            ("18", 2.2),
            ("19", 2.2),
            ("20", 1.8),
            ("21", 1.2),
            ("15", 0.8),
            ("16", 0.8),
            ("9", 0.6),
            ("13", 0.6),
            ("14", 0.6),
        ]
    )
    h = int(hour)
    m = random.randint(0, 59)
    s = random.randint(0, 59)
    return datetime.combine(day.date(), time(h, m, s))


def ensure_stores(db: Session) -> List[Store]:
    stores = db.query(Store).all()
    if stores:
        return stores
    # nếu bạn chưa seed stores thì tạo tạm 3 chi nhánh
    stores = [
        Store(id="branch_1", name="Branch 1", address="HCM - District 1"),
        Store(id="branch_2", name="Branch 2", address="HCM - District 7"),
        Store(id="branch_3", name="Branch 3", address="HCM - Thu Duc"),
    ]
    db.add_all(stores)
    db.commit()
    return stores


def ensure_edge_devices_for_branches(
    db: Session, stores: List[Store]
) -> dict[str, EdgeDevice]:
    """
    return mapping: {branch_id: EdgeDevice}
    """
    mapping: dict[str, EdgeDevice] = {}

    for idx, st in enumerate(stores, start=1):
        device_id = f"edge_{idx}"  # edge_1, edge_2, edge_3

        dev = db.query(EdgeDevice).filter(EdgeDevice.id == device_id).first()
        if not dev:
            dev = EdgeDevice(
                id=device_id,
                branch_id=st.id,  # ✅ gắn vào chi nhánh
                name=f"Edge Camera #{idx}",
                description=f"Seeded edge device for {st.name}",
                ip_address=f"192.168.1.{10+idx}",
                status="active",
            )
            db.add(dev)

        mapping[st.id] = dev

    db.commit()
    return mapping


def load_products(db: Session) -> List[Product]:
    products = db.query(Product).all()
    if len(products) < 50:
        raise RuntimeError(
            f"Need products in DB (found {len(products)}). You said you have ~200 products."
        )
    return products


def load_customers(db: Session) -> List[Customer]:
    customers = db.query(Customer).all()
    if len(customers) < 10:
        raise RuntimeError(
            f"Need customers in DB (found {len(customers)}). You said you have 100 customers."
        )
    return customers


def ensure_face_embeddings(db: Session, customers: List[Customer]):
    # nếu bạn đã có embedding thật thì phần này sẽ bỏ qua vì đã tồn tại
    existing = set(x[0] for x in db.query(FaceEmbedding.customer_id).all())
    to_add = []
    for c in customers:
        if c.customer_id in existing:
            continue
        emb = [round(random.uniform(-1, 1), 6) for _ in range(EMBED_DIM)]
        to_add.append(FaceEmbedding(customer_id=c.customer_id, embedding=emb))
    if to_add:
        db.add_all(to_add)
        db.commit()


def build_product_index(products: List[Product]):
    by_pk = {p.id: p for p in products}  # promo FK dùng Product.id (int)
    by_pid = {
        p.product_id: p for p in products
    }  # transaction_items FK dùng Product.product_id (string)
    by_cat: Dict[str, List[Product]] = {}
    for p in products:
        by_cat.setdefault(p.category or "Other", []).append(p)
    return by_pk, by_pid, by_cat


def create_weekly_promotions(
    db: Session, stores: List[Store], products: List[Product], start_day: datetime
):
    """
    Tạo promotion theo tuần (4-5 tuần tuỳ 30 ngày), áp theo branch.
    """
    by_pk, _, _ = build_product_index(products)
    for w in range(0, DAYS, 7):
        w_start = (start_day - timedelta(days=DAYS - 1)) + timedelta(days=w)
        w_end = w_start + timedelta(days=6, hours=23, minutes=59)

        for st in stores:
            code = f"SALE_{st.id}_{w_start.strftime('%Y%m%d')}"
            exist = db.query(Promotion).filter(Promotion.code == code).first()
            if exist:
                continue

            promo = Promotion(
                code=code,
                name=f"Weekly Promo {st.name} {w_start.strftime('%d/%m')}",
                discount_type="PERCENT",
                start_at=w_start,
                end_at=w_end,
                is_active=True,
            )
            db.add(promo)
            db.flush()  # get promo.id

            db.add(PromotionBranch(promotion_id=promo.id, branch_id=st.id))

            k = random.randint(PROMO_PRODUCTS_MIN, PROMO_PRODUCTS_MAX)
            chosen = random.sample(products, k=min(k, len(products)))

            for p in chosen:
                # PromotionProduct.product_id references products.id (int)
                db.add(
                    PromotionProduct(
                        promotion_id=promo.id,
                        product_id=p.id,
                        discount_value=random.choice([10, 15, 20, 25, 30]),
                    )
                )

    db.commit()


def get_active_promo_product_pks(
    db: Session, branch_id: str, now: datetime
) -> Dict[int, float]:
    """
    return {product_pk_id: promo_boost} where boost ~ percent/100
    """
    rows = (
        db.query(Product.id, PromotionProduct.discount_value)
        .join(PromotionProduct, PromotionProduct.product_id == Product.id)
        .join(Promotion, Promotion.id == PromotionProduct.promotion_id)
        .join(PromotionBranch, PromotionBranch.promotion_id == Promotion.id)
        .filter(
            Promotion.is_active.is_(True),
            Promotion.start_at <= now,
            Promotion.end_at >= now,
            PromotionBranch.branch_id == branch_id,
        )
        .all()
    )
    out = {}
    for pk, dv in rows:
        out[int(pk)] = max(out.get(int(pk), 0.0), float(dv) / 100.0)
    return out


def choose_basket(
    customer: Customer,
    by_cat: Dict[str, List[Product]],
    promo_pks: Dict[int, float],
    ts: datetime,
) -> List[Tuple[Product, int]]:
    """
    Sinh giỏ hàng:
    - ưu tiên favorite_categories nếu có
    - thêm co-occurrence đơn giản: nếu có Snack thì có xác suất thêm Beverage, v.v.
    - promo tăng xác suất được chọn
    """
    fav = customer.favorite_categories or []
    if isinstance(fav, str):
        try:
            fav = json.loads(fav)
        except:
            fav = []

    basket_size = 2 + (1 if is_weekend(ts) else 0) + random.randint(0, 3)
    basket: List[Tuple[Product, int]] = []

    def pick_product_from_cat(cat: str) -> Optional[Product]:
        pool = by_cat.get(cat) or []
        if not pool:
            return None
        # promo bias: nếu pool có promo thì tăng chance
        promo_pool = [p for p in pool if p.id in promo_pks]
        if promo_pool and random.random() < 0.55:
            return random.choice(promo_pool)
        return random.choice(pool)

    # 1) chọn theo sở thích
    for _ in range(basket_size):
        if not fav:
            return None
        if fav and random.random() < 0.7:
            cat = random.choice(list(fav.keys()))
        else:
            cat = random.choice(list(by_cat.keys()))
        p = pick_product_from_cat(cat) or random.choice(sum(by_cat.values(), []))
        qty = 1 if random.random() < 0.85 else 2
        basket.append((p, qty))

    # 2) basket rule đơn giản
    cats_in_basket = set((p.category or "Other") for p, _ in basket)
    if "Snack" in cats_in_basket and random.random() < 0.45:
        p = pick_product_from_cat("Beverage")
        if p:
            basket.append((p, 1))
    if "Instant Food" in cats_in_basket and random.random() < 0.35:
        p = pick_product_from_cat("Beverage")
        if p:
            basket.append((p, 1))

    # gộp trùng product
    merged: Dict[int, Tuple[Product, int]] = {}
    for p, q in basket:
        if p.id not in merged:
            merged[p.id] = (p, q)
        else:
            merged[p.id] = (p, merged[p.id][1] + q)

    return list(merged.values())


def build_recommendations(
    basket_items: List[Tuple[Product, int]],
    all_products: List[Product],
    promo_pks: Dict[int, float],
    top_k: int,
) -> List[dict]:
    """
    Sinh recommendations để log + mô phỏng accepted:
    - ưu tiên sản phẩm promo
    - ưu tiên sản phẩm cùng category với basket
    """
    basket_cats = set((p.category or "Other") for p, _ in basket_items)
    candidates = []

    for p in all_products:
        score = random.random() * 0.2
        if (p.category or "Other") in basket_cats:
            score += 0.35
        if p.id in promo_pks:
            score += 0.35 + promo_pks[p.id]  # promo boost
        candidates.append((p, score))

    candidates.sort(key=lambda x: x[1], reverse=True)
    picked = candidates[:top_k]

    return [
        {
            "product_id": p.product_id,
            "name": p.name,
            "category": p.category,
            "price": p.price,
            "score": round(float(score), 6),
            "promo_boost": round(float(promo_pks.get(p.id, 0.0)), 6),
        }
        for p, score in picked
    ]


def simulate_acceptance(recs: List[dict]) -> bool:
    """
    acceptance probability tăng nếu rec có promo_boost cao.
    """
    base = 0.10  # 10% baseline
    promo_max = max((r.get("promo_boost", 0.0) for r in recs), default=0.0)
    p = min(0.35, base + 0.25 * float(promo_max))  # cap 35%
    return random.random() < p


def seed_branch_inventory(db, stores, products):
    # nếu đã có inventory rồi thì bỏ qua
    existed = db.query(BranchInventory.id).first()
    if existed:
        return

    rows = []
    for st in stores:
        for p in products:
            # 15% hết hàng để test filter theo branch
            stock = 0 if random.random() < 0.15 else random.randint(5, 50)
            rows.append(
                BranchInventory(
                    branch_id=st.id,
                    product_id=p.id,  # chú ý: dùng Product.id (int)
                    stock=stock,
                    reserved=0,
                )
            )
    db.add_all(rows)
    db.commit()


def seed_30_days():
    db = SessionLocal()

    try:
        stores = ensure_stores(db)
        branch_map = build_branch_name_to_id(stores)
        branch_to_device = ensure_edge_devices_for_branches(db, stores)
        import_customers_and_embeddings(
            db,
            customers_json=customers_json,
            embeds_json=embeds_json,
            branch_map=branch_map,
        )
        products = load_products(db)
        customers = load_customers(db)

        # ensure_face_embeddings(db, customers)

        by_pk, by_pid, by_cat = build_product_index(products)
        seed_branch_inventory(db, stores, products)

        # tạo promotions theo tuần
        start_day = datetime.utcnow()
        create_weekly_promotions(db, stores, products, start_day)

        # seed transactions
        start_date = datetime.utcnow() - timedelta(days=DAYS - 1)

        # để tránh trùng transaction_id nếu chạy lại, dùng prefix thời gian
        run_prefix = datetime.utcnow().strftime("SEED%Y%m%d%H%M%S")

        total_tx = 0
        total_rec = 0

        for d in range(DAYS):
            day = start_date + timedelta(days=d)

            # phân bổ 100 tx/ngày cho các branch
            for i in range(TX_PER_DAY):
                st = random.choice(stores)
                device_id = branch_to_device[st.id].id
                cust = random.choice(customers)
                ts = rand_time_in_day(day)

                promo_pks = get_active_promo_product_pks(db, st.id, ts)

                basket = choose_basket(cust, by_cat, promo_pks, ts)

                txn_uid = f"{run_prefix}_{day.strftime('%Y%m%d')}_{i:04d}"
                total_amount = sum((p.price or 0) * qty for p, qty in basket)
                items_count = sum(qty for _, qty in basket)

                # recommendations + acceptance
                recs = build_recommendations(basket, products, promo_pks, TOP_K)
                accepted = simulate_acceptance(recs)

                txn = Transaction(
                    branch_id=st.id,
                    transaction_id=txn_uid,
                    timestamp=ts,
                    customer_id=cust.customer_id,
                    device_id=device_id,  # đổi nếu bạn có device thật
                    items_data=[
                        {"product_id": p.product_id, "qty": qty, "price": p.price}
                        for p, qty in basket
                    ],
                    items_count=items_count,
                    total_amount=total_amount,
                    recommended_items=recs,
                    accepted_recommendations=accepted,
                )
                db.add(txn)
                db.flush()  # txn.id

                for p, qty in basket:
                    # TransactionItem.product_id FK -> products.product_id (string)
                    db.add(
                        TransactionItem(
                            transaction_id=txn.id,
                            product_id=p.product_id,
                            qty=qty,
                            unit_price=p.price,
                        )
                    )

                # Log Recommendation event
                db.add(
                    Recommendation(
                        branch_id=st.id,
                        transaction_id=txn_uid,
                        timestamp=ts,
                        customer_id=cust.customer_id,
                        device_id=device_id,
                        face_attributes={
                            "age_group": cust.age_group,
                            "gender": cust.gender,
                        },
                        recommended_products=recs,
                        items_count=len(recs),
                        accepted=accepted,
                        purchased_items=txn.items_data if accepted else [],
                    )
                )

                total_tx += 1
                total_rec += 1

                # batch commit để nhanh
                if total_tx % 200 == 0:
                    db.commit()

        db.commit()
        print(
            f"✅ Done seeding: transactions={total_tx}, recommendations={total_rec}, days={DAYS}, tx/day={TX_PER_DAY}"
        )

    finally:
        db.close()


if __name__ == "__main__":
    seed_30_days()
