from collections import defaultdict
from typing import Any

import pandas as pd
from mlxtend.frequent_patterns import association_rules, fpgrowth
from mlxtend.preprocessing import TransactionEncoder
from sqlalchemy.orm import Session

from database.models import (
    AssociationRuleRaw,
    CartAssociationRule,
    ProductAssociation,
    TransactionItem,
)


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


def _clear_association_tables(db: Session) -> None:
    db.query(ProductAssociation).delete(synchronize_session=False)
    db.query(CartAssociationRule).delete(synchronize_session=False)
    db.query(AssociationRuleRaw).delete(synchronize_session=False)


def _sorted_product_ids(value: Any) -> list[int]:
    return sorted(int(product_id) for product_id in value)


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
        _clear_association_tables(db)
        db.commit()
        return {
            "status": "success",
            "transactions_used": 0,
            "frequent_itemsets": 0,
            "rules_generated": 0,
            "raw_rules_inserted": 0,
            "cache_candidates": 0,
            "one_to_one_rules": 0,
            "cart_rules": 0,
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
        _clear_association_tables(db)
        db.commit()
        return {
            "status": "success",
            "transactions_used": len(transactions),
            "frequent_itemsets": 0,
            "rules_generated": 0,
            "raw_rules_inserted": 0,
            "cache_candidates": 0,
            "one_to_one_rules": 0,
            "cart_rules": 0,
            "rules_inserted": 0,
            "message": "No frequent itemsets matched the configured support.",
        }

    rules = association_rules(
        frequent_itemsets,
        metric="confidence",
        min_threshold=min_confidence,
    )

    if rules.empty:
        _clear_association_tables(db)
        db.commit()
        return {
            "status": "success",
            "transactions_used": len(transactions),
            "frequent_itemsets": int(len(frequent_itemsets)),
            "rules_generated": 0,
            "raw_rules_inserted": 0,
            "cache_candidates": 0,
            "one_to_one_rules": 0,
            "cart_rules": 0,
            "rules_inserted": 0,
            "message": "No association rules matched the configured confidence.",
        }

    ranked_rules = rules.sort_values(
        by=["lift", "confidence", "support"],
        ascending=False,
    )

    _clear_association_tables(db)

    raw_inserted = 0
    one_to_one_inserted = 0
    cart_inserted = 0
    seen_pairs: set[tuple[int, int]] = set()
    cache_candidates: list[tuple[AssociationRuleRaw, list[int], list[int]]] = []

    for _, rule in ranked_rules.iterrows():
        antecedents = _sorted_product_ids(rule["antecedents"])
        consequents = _sorted_product_ids(rule["consequents"])

        if not antecedents or not consequents:
            continue
        if set(antecedents) & set(consequents):
            continue

        raw_rule = AssociationRuleRaw(
            antecedent_product_ids=antecedents,
            consequent_product_ids=consequents,
            antecedent_size=len(antecedents),
            consequent_size=len(consequents),
            confidence=float(rule["confidence"]),
            lift=float(rule["lift"]),
            support=float(rule["support"]),
            algorithm="fp-growth",
            is_active=True,
        )
        db.add(raw_rule)
        db.flush()
        raw_inserted += 1

        if float(rule["lift"]) > min_lift:
            cache_candidates.append((raw_rule, antecedents, consequents))

    for raw_rule, antecedents, consequents in cache_candidates[:max_rules]:
        if len(antecedents) == 1 and len(consequents) == 1:
            product_id = antecedents[0]
            related_product_id = consequents[0]
            pair = (product_id, related_product_id)
            if pair in seen_pairs:
                continue
            seen_pairs.add(pair)

            db.add(
                ProductAssociation(
                    source_rule_id=raw_rule.id,
                    product_id=product_id,
                    related_product_id=related_product_id,
                    confidence=raw_rule.confidence,
                    lift=raw_rule.lift,
                    support=raw_rule.support,
                )
            )
            one_to_one_inserted += 1
        else:
            db.add(
                CartAssociationRule(
                    source_rule_id=raw_rule.id,
                    antecedent_product_ids=antecedents,
                    consequent_product_ids=consequents,
                    antecedent_size=len(antecedents),
                    consequent_size=len(consequents),
                    confidence=raw_rule.confidence,
                    lift=raw_rule.lift,
                    support=raw_rule.support,
                )
            )
            cart_inserted += 1

    db.commit()

    return {
        "status": "success",
        "transactions_used": len(transactions),
        "frequent_itemsets": int(len(frequent_itemsets)),
        "rules_generated": int(len(rules)),
        "raw_rules_inserted": raw_inserted,
        "cache_candidates": len(cache_candidates),
        "one_to_one_rules": one_to_one_inserted,
        "cart_rules": cart_inserted,
        "rules_inserted": raw_inserted,
        "min_support": min_support,
        "min_confidence": min_confidence,
        "min_lift": min_lift,
    }
