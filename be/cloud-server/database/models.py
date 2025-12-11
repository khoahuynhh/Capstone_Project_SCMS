from sqlalchemy import (
    Column,
    Integer,
    String,
    Float,
    DateTime,
    JSON,
    Boolean,
    Text,
    ForeignKey,
)
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime

Base = declarative_base()


class Store(Base):
    __tablename__ = "stores"
    id = Column(String(50), primary_key=True)
    name = Column(String(100))
    address = Column(String(200))


class Product(Base):
    __tablename__ = "products"
    id = Column(String(50), primary_key=True)
    name = Column(String(200), nullable=False)
    category = Column(String(100))
    price = Column(Float)
    product_meta = Column(JSON)


class Transaction(Base):
    """Transaction records from edge devices"""

    __tablename__ = "transactions"

    id = Column(Integer, primary_key=True, index=True)
    branch_id = Column(String(50), ForeignKey("stores.id"), index=True, nullable=False)
    transaction_id = Column(String(100), unique=True, index=True, nullable=False)
    timestamp = Column(DateTime, default=datetime.utcnow, index=True)
    customer_id = Column(String(100), index=True)
    device_id = Column(
        String(50), ForeignKey("edge_devices.id"), index=True, nullable=False
    )

    # Transaction details
    items_data = Column(JSON)  # List of purchased items
    items_count = Column(Integer)
    total_amount = Column(Float)

    # Recommendation context
    recommended_items = Column(JSON)  # What was recommended
    accepted_recommendations = Column(Boolean, default=False)

    # Metadata
    created_at = Column(DateTime, default=datetime.utcnow)


class TransactionItem(Base):
    __tablename__ = "transaction_items"
    id = Column(Integer, primary_key=True)
    transaction_id = Column(Integer, ForeignKey("transactions.id"))
    product_id = Column(String(50), ForeignKey("products.id"))
    qty = Column(Integer)
    unit_price = Column(Float)


class Recommendation(Base):
    """Recommendation events from edge devices"""

    __tablename__ = "recommendations"

    id = Column(Integer, primary_key=True, index=True)
    branch_id = Column(String(50), ForeignKey("stores.id"), index=True, nullable=False)
    transaction_id = Column(String(100), index=True)
    timestamp = Column(DateTime, default=datetime.utcnow, index=True)
    customer_id = Column(String(100), index=True)
    device_id = Column(
        String(50), ForeignKey("edge_devices.id"), index=True, nullable=False
    )

    # Customer attributes
    face_attributes = Column(JSON)  # Demographics, age, gender, etc.

    # Recommendations
    recommended_products = Column(JSON)  # List of recommended products
    items_count = Column(Integer)

    # Outcome
    accepted = Column(Boolean, default=False)
    purchased_items = Column(JSON)

    # Metadata
    created_at = Column(DateTime, default=datetime.utcnow)


class Customer(Base):
    """Anonymized customer profiles"""

    __tablename__ = "customers"

    id = Column(Integer, primary_key=True, index=True)
    customer_id = Column(String(100), unique=True, index=True, nullable=False)

    # Demographics (aggregated, anonymized)
    age_group = Column(String(20))
    gender = Column(String(20))

    # Purchase behavior
    total_transactions = Column(Integer, default=0)
    total_spent = Column(Float, default=0)
    favorite_categories = Column(JSON)

    # Preferences
    preferred_branch = Column(String(50), ForeignKey("stores.id"))
    avg_basket_size = Column(Float)

    # Timestamps
    first_seen = Column(DateTime, default=datetime.utcnow)
    last_seen = Column(DateTime, default=datetime.utcnow)
    created_at = Column(DateTime, default=datetime.utcnow)


class BranchMetrics(Base):
    """Daily aggregated metrics per branch"""

    __tablename__ = "branch_metrics"

    id = Column(Integer, primary_key=True, index=True)
    branch_id = Column(String(50), ForeignKey("stores.id"), index=True, nullable=False)
    date = Column(DateTime, index=True, nullable=False)

    # Transaction metrics
    total_transactions = Column(Integer, default=0)
    total_revenue = Column(Float, default=0)
    avg_transaction_value = Column(Float, default=0)

    # Recommendation metrics
    total_recommendations = Column(Integer, default=0)
    recommendations_accepted = Column(Integer, default=0)
    acceptance_rate = Column(Float, default=0)

    # Performance metrics
    avg_latency_ms = Column(Float)
    inference_count = Column(Integer, default=0)

    # Inventory
    top_selling_products = Column(JSON)
    out_of_stock_items = Column(JSON)

    created_at = Column(DateTime, default=datetime.utcnow)


class ModelVersion(Base):
    """Model version tracking"""

    __tablename__ = "model_versions"

    id = Column(Integer, primary_key=True, index=True)
    version = Column(String(50), unique=True, nullable=False)
    model_type = Column(String(50))  # 'face_detector', 'recommender', etc.

    # Model info
    model_path = Column(Text)
    model_size_mb = Column(Float)

    # Performance
    accuracy = Column(Float)
    precision = Column(Float)
    recall = Column(Float)
    f1_score = Column(Float)

    # Metadata
    training_date = Column(DateTime)
    deployed_to_branches = Column(JSON)
    is_active = Column(Boolean, default=False)

    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class EdgeDevice(Base):
    __tablename__ = "edge_devices"

    id = Column(String(50), primary_key=True)  # device_id từ .env
    branch_id = Column(String(50), ForeignKey("stores.id"), index=True, nullable=False)
    name = Column(String(100))
    description = Column(Text)
    ip_address = Column(String(50))
    status = Column(String(20), default="active")  # active, offline, error
    last_seen = Column(DateTime, default=datetime.utcnow, index=True)
    created_at = Column(DateTime, default=datetime.utcnow)


class FaceEvent(Base):
    __tablename__ = "face_events"

    id = Column(Integer, primary_key=True, index=True)
    branch_id = Column(String(50), ForeignKey("stores.id"), index=True, nullable=False)
    device_id = Column(String(50), ForeignKey("edge_devices.id"), index=True)

    event_type = Column(String(50), nullable=False)  # 'face_recognized', 'no_face'
    timestamp = Column(DateTime, default=datetime.utcnow, index=True)

    customer_id = Column(String(100), index=True)  # có thể None nếu unknown
    similarity = Column(Float)
    face_attributes = Column(JSON)  # age_group, gender, ...

    # Liên kết với transaction nếu có (sau khi mua xong)
    transaction_id = Column(String(100), index=True, nullable=True)

    created_at = Column(DateTime, default=datetime.utcnow)
