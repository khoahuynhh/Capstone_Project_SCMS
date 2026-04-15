from sqlalchemy.orm import Session
from sqlalchemy import func, desc
from database.models import CustomerStats, Transaction, TransactionItem, Product
from database.db import SessionLocal


def update_customer_stats(customer_id: str):
    """
    Hàm này sẽ được gọi trong Background Task sau khi Transaction thành công
    """
    db = SessionLocal()  # Tạo session mới cho background task

    try:
        # 1. Tính tổng chi tiêu và tổng số đơn (Aggregation cơ bản)
        # SELECT count(id), sum(total_amount), max(timestamp) ...
        stats = (
            db.query(
                func.count(Transaction.id).label("total_tx"),
                func.sum(Transaction.total_amount).label("total_spent"),
                func.max(Transaction.timestamp).label("last_purchase"),
            )
            .filter(Transaction.customer_id == customer_id)
            .first()
        )

        total_transactions = stats.total_tx or 0
        total_spent = stats.total_spent or 0
        last_purchase = stats.last_purchase

        # Tính trung bình giỏ hàng
        avg_basket = total_spent / total_transactions if total_transactions > 0 else 0

        # 2. Tính Favorite Categories (Aggregation phức tạp)
        # Join Transaction -> Item -> Product để group by Category
        cat_stats = (
            db.query(
                Product.category, func.count(TransactionItem.id).label("buy_count")
            )
            .join(TransactionItem, Product.id == TransactionItem.product_id)
            .join(Transaction, Transaction.id == TransactionItem.transaction_id)
            .filter(Transaction.customer_id == customer_id)
            .group_by(Product.category)
            .order_by(desc("buy_count"))
            .limit(3)
            .all()
        )

        # Chuyển về JSON: {"Electronics": 10, "Fashion": 5}
        fav_categories = {c[0]: c[1] for c in cat_stats if c[0]}

        # 3. Update hoặc Create vào bảng CustomerStats
        customer_stat = (
            db.query(CustomerStats).filter_by(customer_id=customer_id).first()
        )

        if not customer_stat:
            customer_stat = CustomerStats(customer_id=customer_id)
            db.add(customer_stat)

        # Cập nhật giá trị
        customer_stat.total_transactions = total_transactions
        customer_stat.total_spent = total_spent
        customer_stat.avg_basket_size = avg_basket
        customer_stat.last_purchase_date = last_purchase
        customer_stat.favorite_categories = fav_categories

        # Commit
        db.commit()
        db.refresh(customer_stat)

    finally:
        db.close()

    return customer_stat
