from collections import defaultdict
from typing import Any

import pandas as pd
from mlxtend.frequent_patterns import association_rules, fpgrowth
from mlxtend.preprocessing import TransactionEncoder
from sqlalchemy.orm import Session

from database.models import ProductAssociation, TransactionItem


def _get_transactions(db: Session, min_items: int) -> list[list[int]]:
    rows = (
        db.query(TransactionItem.transaction_id, TransactionItem.product_id)
        .filter(TransactionItem.product_id.isnot(None))
        .order_by(TransactionItem.transaction_id)
        .all()
    )

    grouped: dict[int, set[int]] = defaultdict(set)
    for transaction_id, product_id in rows:
        if transaction_id is None or product_id is None:
            continue
        grouped[int(transaction_id)].add(int(product_id))

    return [
        sorted(product_ids)
        for product_ids in grouped.values()
        if len(product_ids) >= min_items
    ]


def regenerate_product_associations(
    db: Session,
    min_support: float = 0.001,
    min_confidence: float = 0.03,
    min_lift: float = 1.0,
    min_items_per_transaction: int = 2,
    max_rules: int = 10000,
) -> dict[str, Any]:
    transactions = _get_transactions(db, min_items_per_transaction)
    if not transactions:
        db.query(ProductAssociation).delete(synchronize_session=False)
        db.commit()
        return {
            "status": "success",
            "transactions_used": 0,
            "frequent_itemsets": 0,
            "rules_generated": 0,
            "rules_inserted": 0,
            "message": "No transactions with enough products were found.",
        }

    encoder = TransactionEncoder()
    encoded = encoder.fit(transactions).transform(transactions)
    df_encoded = pd.DataFrame(encoded, columns=encoder.columns_)

    frequent_itemsets = fpgrowth(
        df_encoded,
        min_support=min_support,
        use_colnames=True,
    )

    if frequent_itemsets.empty:
        db.query(ProductAssociation).delete(synchronize_session=False)
        db.commit()
        return {
            "status": "success",
            "transactions_used": len(transactions),
            "frequent_itemsets": 0,
            "rules_generated": 0,
            "rules_inserted": 0,
            "message": "No frequent itemsets matched the configured support.",
        }

    rules = association_rules(
        frequent_itemsets,
        metric="confidence",
        min_threshold=min_confidence,
    )

    if rules.empty:
        db.query(ProductAssociation).delete(synchronize_session=False)
        db.commit()
        return {
            "status": "success",
            "transactions_used": len(transactions),
            "frequent_itemsets": int(len(frequent_itemsets)),
            "rules_generated": 0,
            "rules_inserted": 0,
            "message": "No association rules matched the configured confidence.",
        }

    one_to_one_rules = rules[
        (rules["antecedents"].apply(len) == 1)
        & (rules["consequents"].apply(len) == 1)
        & (rules["lift"] > min_lift)
    ].copy()

    one_to_one_rules = one_to_one_rules.sort_values(
        by=["lift", "confidence", "support"],
        ascending=False,
    ).head(max_rules)

    db.query(ProductAssociation).delete(synchronize_session=False)

    inserted = 0
    seen_pairs: set[tuple[int, int]] = set()
    for _, rule in one_to_one_rules.iterrows():
        product_id = int(next(iter(rule["antecedents"])))
        related_product_id = int(next(iter(rule["consequents"])))

        if product_id == related_product_id:
            continue

        pair = (product_id, related_product_id)
        if pair in seen_pairs:
            continue
        seen_pairs.add(pair)

        db.add(
            ProductAssociation(
                product_id=product_id,
                related_product_id=related_product_id,
                confidence=float(rule["confidence"]),
                lift=float(rule["lift"]),
                support=float(rule["support"]),
            )
        )
        inserted += 1

    db.commit()

    return {
        "status": "success",
        "transactions_used": len(transactions),
        "frequent_itemsets": int(len(frequent_itemsets)),
        "rules_generated": int(len(rules)),
        "one_to_one_rules": int(len(one_to_one_rules)),
        "rules_inserted": inserted,
        "min_support": min_support,
        "min_confidence": min_confidence,
        "min_lift": min_lift,
    }
