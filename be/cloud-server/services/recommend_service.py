from datetime import datetime, timedelta
from collections import defaultdict
from typing import Dict, List, Tuple, Optional

from sqlalchemy.orm import Session
from sqlalchemy import func, and_


from database.models import (
    Product,
    Transaction,
    TransactionItem,
    Promotion,
    PromotionBranch,
    PromotionProduct,
    BranchInventory,
)


# -----------------------------
# Helpers
# -----------------------------
def _minmax_norm(scores: Dict[int, float]) -> Dict[int, float]:
    if not scores:
        return {}
    vals = list(scores.values())
    mn, mx = min(vals), max(vals)
    if mx == mn:
        return {k: 1.0 for k in scores}
    return {k: (v - mn) / (mx - mn) for k, v in scores.items()}


def _now():
    return datetime.utcnow()


# -----------------------------
# 1) Personal candidates (history-based)
# -----------------------------
def get_personal_scores(
    db: Session,
    customer_id: str,
    days: int = 90,
    limit: int = 200,
) -> Dict[int, float]:
    """
    Return dict {product_pk_id: personal_score}
    Score = sum(qty) in last N days (simple & strong baseline)
    Uses Transaction + TransactionItem.
    """
    since = _now() - timedelta(days=days)

    rows = (
        db.query(
            Product.id.label("product_pk"),
            func.coalesce(func.sum(TransactionItem.qty), 0).label("qty_sum"),
        )
        .join(TransactionItem, TransactionItem.product_id == Product.product_id)
        .join(Transaction, TransactionItem.transaction_id == Transaction.id)
        .filter(
            Transaction.customer_id == customer_id,
            Transaction.timestamp >= since,
        )
        .group_by(Product.id)
        .order_by(func.sum(TransactionItem.qty).desc())
        .limit(limit)
        .all()
    )

    return {r.product_pk: float(r.qty_sum) for r in rows}


# -----------------------------
# 2) Basket / co-occurrence candidates
# -----------------------------
def get_basket_scores(
    db: Session,
    seed_product_pks: List[int],
    days: int = 180,
    limit_tx: int = 500,
    limit_items: int = 300,
) -> Dict[int, float]:
    """
    Build co-occurrence scores from transactions that contain any seed products.
    Returns {product_pk_id: cooc_count} (simple frequency).
    """
    if not seed_product_pks:
        return {}

    since = _now() - timedelta(days=days)

    # Map seed product PK -> product_id (string) to match TransactionItem.product_id
    seed_product_ids = [
        pid
        for (pid,) in db.query(Product.product_id)
        .filter(Product.id.in_(seed_product_pks))
        .all()
    ]
    seed_product_ids = [x for x in seed_product_ids if x]

    if not seed_product_ids:
        return {}

    # Find recent transactions that contain seed products
    tx_ids = (
        db.query(TransactionItem.transaction_id)
        .join(Transaction, TransactionItem.transaction_id == Transaction.id)
        .filter(
            Transaction.timestamp >= since,
            TransactionItem.product_id.in_(seed_product_ids),
        )
        .group_by(TransactionItem.transaction_id)
        .order_by(func.max(Transaction.timestamp).desc())
        .limit(limit_tx)
        .all()
    )
    tx_ids = [t[0] for t in tx_ids]
    if not tx_ids:
        return {}

    # Count other products appearing in those transactions
    rows = (
        db.query(
            Product.id.label("product_pk"),
            func.count(TransactionItem.id).label("cnt"),
        )
        .join(TransactionItem, TransactionItem.product_id == Product.product_id)
        .filter(TransactionItem.transaction_id.in_(tx_ids))
        .group_by(Product.id)
        .order_by(func.count(TransactionItem.id).desc())
        .limit(limit_items)
        .all()
    )

    scores = {r.product_pk: float(r.cnt) for r in rows}

    # Remove the seed products themselves (don’t recommend exact same as “co-occur”)
    for pk in seed_product_pks:
        scores.pop(pk, None)

    return scores


# -----------------------------
# 3) Promo boost per branch
# -----------------------------
def get_promo_boost_map(
    db: Session,
    branch_id: str,
    candidate_product_pks: List[int],
) -> Dict[int, float]:
    """
    Return {product_pk_id: promo_boost} in [0..1] approx.
    Only active promos within time window AND applied to this branch.
    """
    if not candidate_product_pks:
        return {}

    now = _now()

    # Join: Promotion -> PromotionBranch (branch) -> PromotionProduct -> Product
    rows = (
        db.query(
            Product.id.label("product_pk"),
            Promotion.discount_type,
            PromotionProduct.discount_value,
            Product.price,
        )
        .join(PromotionProduct, PromotionProduct.product_id == Product.id)
        .join(Promotion, Promotion.id == PromotionProduct.promotion_id)
        .join(PromotionBranch, PromotionBranch.promotion_id == Promotion.id)
        .filter(
            Product.id.in_(candidate_product_pks),
            Promotion.is_active.is_(True),
            Promotion.start_at <= now,
            Promotion.end_at >= now,
            PromotionBranch.branch_id == branch_id,
        )
        .all()
    )

    boost: Dict[int, float] = {}

    for r in rows:
        price = float(r.price or 0.0)
        dv = float(r.discount_value or 0.0)
        dtype = (r.discount_type or "").upper()

        b = 0.0
        if price > 0:
            if dtype == "PERCENT":
                b = dv / 100.0
            elif dtype == "FIXED":
                b = min(dv / price, 0.5)  # cap to avoid overpowering relevance
            elif dtype == "PROMO_PRICE":
                # dv here is promo price in your comment
                b = max(0.0, min((price - dv) / price, 0.7))
        boost[r.product_pk] = max(boost.get(r.product_pk, 0.0), b)

    return boost


# -----------------------------
# 4) Main recommend
# -----------------------------
def recommend_products(
    db: Session,
    branch_id: str,
    customer_id: Optional[str],
    top_k: int = 5,
    w_personal: float = 0.65,
    w_basket: float = 0.25,
    w_promo: float = 0.10,
) -> List[dict]:
    """
    Hybrid recommender (sync):
    - base candidates from purchase history (personal)
    - expand by basket co-occurrence
    - re-rank with promo boost (branch-specific)
    - filter by stock > 0
    """
    if not customer_id:
        # Fallback: just branch trending or popularity (you can implement later)
        return []

    personal = get_personal_scores(db, customer_id=customer_id, days=90, limit=200)

    # Seed products: top few from personal (for co-occurrence expansion)
    seed_pks = sorted(personal.keys(), key=lambda k: personal[k], reverse=True)[:3]
    basket = get_basket_scores(db, seed_product_pks=seed_pks, days=180)

    # Merge candidate set
    candidate_pks = list(set(list(personal.keys()) + list(basket.keys())))

    # Filter by stock > 0
    products = (
        db.query(Product, BranchInventory.stock)
        .join(BranchInventory, BranchInventory.product_id == Product.id)
        .filter(
            Product.id.in_(candidate_pks),
            BranchInventory.branch_id == branch_id,
            BranchInventory.stock > 0,
        )
        .all()
    )

    product_map = {p.id: p for p, _stock in products}
    stock_map = {p.id: int(_stock) for p, _stock in products}
    candidate_pks = [pk for pk in candidate_pks if pk in product_map]

    # Promo boost map (branch-specific)
    promo_boost = get_promo_boost_map(
        db, branch_id=branch_id, candidate_product_pks=candidate_pks
    )

    # Normalize personal & basket to [0..1]
    personal_n = _minmax_norm({k: personal.get(k, 0.0) for k in candidate_pks})
    basket_n = _minmax_norm({k: basket.get(k, 0.0) for k in candidate_pks})

    scored: List[Tuple[int, float]] = []
    for pk in candidate_pks:
        score = (
            w_personal * personal_n.get(pk, 0.0)
            + w_basket * basket_n.get(pk, 0.0)
            + w_promo * promo_boost.get(pk, 0.0)
        )
        scored.append((pk, score))

    scored.sort(key=lambda x: x[1], reverse=True)
    top = scored[:top_k]

    # Build response
    out = []
    for pk, s in top:
        p = product_map[pk]
        out.append(
            {
                "product_pk": pk,
                "product_id": p.product_id,
                "name": p.name,
                "category": p.category,
                "price": p.price,
                "branch_stock": stock_map.get(pk, 0),
                "score": round(float(s), 6),
                "promo_boost": round(float(promo_boost.get(pk, 0.0)), 6),
                "source": {
                    "personal": round(float(personal_n.get(pk, 0.0)), 6),
                    "basket": round(float(basket_n.get(pk, 0.0)), 6),
                },
            }
        )
    return out
