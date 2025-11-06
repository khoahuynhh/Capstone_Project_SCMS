import json
from datetime import datetime

from database.db import SessionLocal, engine
from database.models import Base, Store, Product, Customer, Transaction


def seed():
    # Ensure tables exist
    Base.metadata.create_all(bind=engine)

    db = SessionLocal()
    try:
        # Upsert helper by primary/unique key
        def get_or_create(model, defaults=None, **kwargs):
            instance = db.query(model).filter_by(**kwargs).first()
            if instance:
                return instance, False
            params = dict(kwargs)
            if defaults:
                params.update(defaults)
            instance = model(**params)
            db.add(instance)
            db.commit()
            db.refresh(instance)
            return instance, True

        # Stores
        store1, _ = get_or_create(
            Store,
            id="branch_001",
            defaults={"name": "Chi nhánh Quận 1", "address": "Q1, HCM"},
        )
        store2, _ = get_or_create(
            Store,
            id="branch_002",
            defaults={"name": "Chi nhánh Quận 7", "address": "Q7, HCM"},
        )

        # Products
        p1, _ = get_or_create(
            Product,
            id="prod_001",
            defaults={
                "name": "Sữa tươi 1L",
                "category": "Dairy",
                "price": 32000,
                "product_meta": {"brand": "MilkCo"},
            },
        )
        p2, _ = get_or_create(
            Product,
            id="prod_002",
            defaults={
                "name": "Bánh mì",
                "category": "Bakery",
                "price": 15000,
                "product_meta": {"brand": "BakeHouse"},
            },
        )

        # Customers
        c1, _ = get_or_create(
            Customer,
            customer_id="cust_abc123",
            defaults={
                "age_group": "25-34",
                "gender": "female",
                "total_transactions": 0,
                "total_spent": 0.0,
                "favorite_categories": {},
                "preferred_branch": store1.id,
            },
        )

        # One sample transaction
        items = [
            {
                "product_id": p1.id,
                "name": p1.name,
                "category": p1.category,
                "qty": 1,
                "unit_price": p1.price,
            },
            {
                "product_id": p2.id,
                "name": p2.name,
                "category": p2.category,
                "qty": 2,
                "unit_price": p2.price,
            },
        ]
        total_amount = sum(i["qty"] * i["unit_price"] for i in items)

        tx, created = get_or_create(
            Transaction,
            transaction_id="tx_demo_0001",
            defaults={
                "branch_id": store1.id,
                "timestamp": datetime.utcnow(),
                "customer_id": c1.customer_id,
                "items_data": items,
                "items_count": len(items),
                "total_amount": total_amount,
                "recommended_items": [p2.id],
                "accepted_recommendations": True,
            },
        )

        # Update customer aggregates if we just created the transaction
        if created:
            c1.total_transactions = (c1.total_transactions or 0) + 1
            c1.total_spent = (c1.total_spent or 0.0) + total_amount
            db.commit()

        print("Seeding completed.")
    except Exception as e:
        db.rollback()
        raise
    finally:
        db.close()


if __name__ == "__main__":
    seed()
