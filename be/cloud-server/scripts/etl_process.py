import pandas as pd
import json
from sqlalchemy import create_engine, text
from database.db import SQLALCHEMY_DATABASE_URL  # Dùng chung config với FastAPI

engine = create_engine(SQLALCHEMY_DATABASE_URL)


def run_etl():
    print("Start ETL process...")

    # --- BƯỚC 1: EXTRACT (Trích xuất) ---
    # Chỉ lấy dữ liệu Transaction trong vòng 30 ngày để xử lý
    query = (
        "SELECT id, branch_id, timestamp, items_data, total_amount FROM transactions"
    )
    df_raw = pd.read_sql(query, engine)

    if df_raw.empty:
        print("Empty data. Skipping...")
        return

    # --- BƯỚC 2: TRANSFORM (Biến đổi) ---
    print("Transforming data...")

    # Chuyển JSON items_data thành các dòng riêng biệt
    rows = []
    for _, row in df_raw.iterrows():
        items = row["items_data"]
        # Xử lý nếu items_data là string hoặc dict
        if isinstance(items, str):
            items = json.loads(items)

        for item in items:
            rows.append(
                {
                    "transaction_id": row["id"],
                    "branch_id": row["branch_id"],
                    "timestamp": row["timestamp"],
                    "product_id": item.get("product_id"),
                    "price": item.get("price", 0),
                    "quantity": item.get("quantity", 1),
                }
            )

    df_fact = pd.DataFrame(rows)
    df_fact["timestamp"] = pd.to_datetime(df_fact["timestamp"])

    # Tính toán vận tốc bán hàng (Inventory Velocity) ngay tại đây
    # Velocity = Tổng số lượng bán / 30 ngày
    velocity_df = (
        df_fact.groupby(["branch_id", "product_id"])
        .agg(total_qty=("quantity", "sum"))
        .reset_index()
    )
    velocity_df["velocity"] = velocity_df["total_qty"] / 30

    # Phân loại Priority (Logic từ file analytics của bạn)
    def classify_priority(v):
        if v > 5:
            return "high"
        if v < 0.5:
            return "low"
        return "medium"

    velocity_df["priority"] = velocity_df["velocity"].apply(classify_priority)
    velocity_df["suggested_action"] = velocity_df["velocity"].apply(
        lambda v: "restock" if v > 5 else ("markdown" if v < 0.5 else "maintain")
    )

    # --- BƯỚC 3: LOAD (Nạp vào Warehouse) ---
    print("Loading to Warehouse...")
    with engine.begin() as conn:
        # Ghi đè vào bảng fact_sales (bảng đã làm phẳng)
        df_fact.to_sql("fact_sales", conn, if_exists="replace", index=False)

        # Ghi đè vào bảng báo cáo vận tốc kho
        velocity_df.to_sql(
            "dim_inventory_velocity", conn, if_exists="replace", index=False
        )

    print("ETL completed!")


if __name__ == "__main__":
    run_etl()
