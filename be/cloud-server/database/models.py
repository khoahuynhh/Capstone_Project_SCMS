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
    Index,
    Numeric,
)
from sqlalchemy.orm import declarative_base
from pgvector.sqlalchemy import Vector
from datetime import datetime
from sqlalchemy import Date
from sqlalchemy.schema import UniqueConstraint
from sqlalchemy.orm import relationship


Base = declarative_base()


class Store(Base):
    __tablename__ = "stores"
    id = Column(String(50), primary_key=True)
    name = Column(String(100))
    address = Column(String(200))


class Product(Base):
    __tablename__ = "products"

    id = Column(Integer, primary_key=True, index=True)
    product_code = Column(String, unique=True, index=True)
    name = Column(String, nullable=False)
    volume = Column(String)
    price = Column(Numeric(12, 2), nullable=False)
    discount_price = Column(Float)
    discount_percent = Column(Float)
    category = Column(String)
    stock = Column(Integer, default=0)
    description = Column(Text)
    image_url = Column(String)
    emotion = Column(String)
    target_age_group = Column(String(20))
    target_gender = Column(String(20))
    usage_context = Column(String)


class ProductAssociation(Base):
    """
    Lưu trữ kết quả từ thuật toán Data Mining (Apriori / FP-Growth).
    Dùng để gợi ý: "Sản phẩm thường được mua cùng nhau".
    """

    __tablename__ = "product_associations"

    id = Column(Integer, primary_key=True, index=True)

    # Sản phẩm gốc (sản phẩm khách đang xem)
    product_id = Column(
        Integer,
        ForeignKey("products.id", ondelete="CASCADE"),
        index=True,
        nullable=False,
    )

    # Sản phẩm gợi ý mua kèm
    related_product_id = Column(
        Integer,
        ForeignKey("products.id", ondelete="CASCADE"),
        index=True,
        nullable=False,
    )

    # Độ tin cậy (Confidence): Xác suất mua B khi đã mua A (0.0 -> 1.0)
    confidence = Column(Float, nullable=False)

    # Độ mạnh của luật (Lift): Lift > 1 nghĩa là A và B có liên quan tích cực
    lift = Column(Float, nullable=True)

    # Tần suất xuất hiện cùng nhau (Support)
    support = Column(Float, nullable=True)

    # Quan hệ để dễ dàng lấy thông tin sản phẩm liên quan khi query
    product = relationship("Product", foreign_keys=[product_id])
    related_product = relationship("Product", foreign_keys=[related_product_id])

    # Đảm bảo không lưu lặp lại một cặp luật
    __table_args__ = (
        UniqueConstraint(
            "product_id", "related_product_id", name="_product_related_uc"
        ),
    )


class Transaction(Base):
    """Transaction records from edge devices"""

    __tablename__ = "transactions"
    # Relationship
    items = relationship(
        "TransactionItem",
        backref="transaction",
        cascade="all, delete-orphan",
        lazy="selectin",
    )
    store = relationship("Store")

    id = Column(Integer, primary_key=True, index=True)
    branch_id = Column(String(50), ForeignKey("stores.id"), index=True, nullable=False)
    transaction_id = Column(String(100), unique=True, index=True, nullable=False)
    timestamp = Column(DateTime(timezone=True), default=datetime.utcnow, index=True)
    customer_id = Column(Integer, ForeignKey("customers.id"), index=True)
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
    transaction_id = Column(Integer, ForeignKey("transactions.id"), index=True)
    product_id = Column(Integer, ForeignKey("products.id"), index=True, nullable=False)
    qty = Column(Integer)
    unit_price = Column(Float)


class Recommendation(Base):
    """Recommendation events from edge devices"""

    __tablename__ = "recommendations"

    id = Column(Integer, primary_key=True, index=True)
    branch_id = Column(String(50), ForeignKey("stores.id"), index=True, nullable=False)
    transaction_id = Column(String(100), index=True)
    timestamp = Column(DateTime(timezone=True), default=datetime.utcnow, index=True)
    customer_id = Column(Integer, ForeignKey("customers.id"), index=True, nullable=True)
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


class UserAccount(Base):
    __tablename__ = "user_accounts"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(120), unique=True, index=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    is_admin = Column(Boolean, default=False)

    customer_pk = Column(Integer, ForeignKey("customers.id"), nullable=True)

    created_at = Column(DateTime, default=datetime.utcnow)


class Customer(Base):
    __tablename__ = "customers"

    id = Column(Integer, primary_key=True, index=True)
    customer_id = Column(String(100), unique=True, index=True, nullable=False)

    # Basic info
    first_name = Column(String(50))
    last_name = Column(String(50))
    phone = Column(String(20))
    email = Column(String(120))

    # Demographics (aggregated, anonymized)
    cccd = Column(String(20), unique=True, nullable=True)
    address = Column(String(255), nullable=True)
    birth_date = Column(Date, nullable=True)
    age = Column(Integer, nullable=True)
    age_group = Column(String(20))
    gender = Column(String(20))
    description = Column(Text, nullable=True)

    # Purchase behavior
    stats = relationship(
        "CustomerStats",
        back_populates="customer",
        uselist=False,
        cascade="all, delete-orphan",
    )

    # Preferences
    preferred_branch = Column(String(50), ForeignKey("stores.id"))
    avg_basket_size = Column(Float)

    # Timestamps
    first_seen = Column(DateTime(timezone=True), default=datetime.utcnow)
    last_seen = Column(DateTime(timezone=True), default=datetime.utcnow)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)


class CustomerStats(Base):
    __tablename__ = "customer_stats"

    id = Column(Integer, primary_key=True, index=True)
    customer_id = Column(
        Integer, ForeignKey("customers.id"), unique=True, nullable=False
    )

    # Purchase behavior
    total_transactions = Column(Integer, default=0)
    total_spent = Column(Numeric(15, 2), default=0)  # Use Numeric for price
    avg_basket_size = Column(Numeric(12, 2), default=0)  # Average spend per transaction

    # Logic phức tạp
    favorite_categories = Column(JSON)  # Top 3 category
    last_purchase_date = Column(DateTime)

    # Loyalty / Segmentation
    rank_score = Column(Float, default=0)  # Points to rank customers
    segment = Column(String(50))  # VIP, Potential, Churn...

    updated_at = Column(
        DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow
    )

    customer = relationship("Customer", back_populates="stats")


class BranchMetrics(Base):
    """Daily aggregated metrics per branch"""

    __tablename__ = "branch_metrics"

    id = Column(Integer, primary_key=True, index=True)
    branch_id = Column(String(50), ForeignKey("stores.id"), index=True, nullable=False)
    date = Column(Date, index=True, nullable=False)

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
    __table_args__ = (
        UniqueConstraint("branch_id", "date", name="uq_branch_metrics_branch_date"),
    )


class BranchInventory(Base):
    __tablename__ = "branch_inventory"

    id = Column(Integer, primary_key=True, index=True)

    branch_id = Column(String(50), ForeignKey("stores.id"), nullable=False, index=True)
    product_id = Column(Integer, ForeignKey("products.id"), nullable=False, index=True)

    stock = Column(Integer, nullable=False, default=0)
    reserved = Column(Integer, nullable=False, default=0)
    updated_at = Column(
        DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False
    )

    # relationships
    branch = relationship("Store", backref="inventories")
    product = relationship("Product", backref="branch_inventories")

    __table_args__ = (
        UniqueConstraint(
            "branch_id", "product_id", name="uq_branch_inventory_branch_product"
        ),
        Index("ix_branch_inventory_branch_stock", "branch_id", "stock"),
    )


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
    timestamp = Column(DateTime(timezone=True), default=datetime.utcnow, index=True)

    customer_id = Column(
        Integer, ForeignKey("customers.id"), index=True
    )  # có thể None nếu unknown
    similarity = Column(Float)
    face_attributes = Column(JSON)  # age_group, gender, ...

    # Liên kết với transaction nếu có (sau khi mua xong)
    transaction_id = Column(String(100), index=True, nullable=True)

    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)


# ==== Promotions ==== #
class Promotion(Base):
    __tablename__ = "promotions"

    id = Column(Integer, primary_key=True, index=True)
    code = Column(String(50), unique=True, nullable=False, index=True)  
    name = Column(String(255), nullable=False)

    # PERCENT | FIXED | PROMO_PRICE
    discount_type = Column(String(20), nullable=False)

    start_at = Column(DateTime, nullable=False)
    end_at = Column(DateTime, nullable=False)

    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    branches = relationship(
        "PromotionBranch", back_populates="promotion", cascade="all, delete-orphan"
    )
    products = relationship(
        "PromotionProduct", back_populates="promotion", cascade="all, delete-orphan"
    )


class PromotionBranch(Base):
    __tablename__ = "promotion_branches"

    id = Column(Integer, primary_key=True, index=True)
    promotion_id = Column(
        Integer, ForeignKey("promotions.id", ondelete="CASCADE"), nullable=False
    )

    branch_id = Column(
        String(50),
        ForeignKey("stores.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    promotion = relationship("Promotion", back_populates="branches")
    store = relationship("Store")

    __table_args__ = (
        UniqueConstraint("promotion_id", "branch_id", name="uq_promotion_branch"),
    )


class PromotionProduct(Base):
    __tablename__ = "promotion_products"

    id = Column(Integer, primary_key=True, index=True)
    promotion_id = Column(
        Integer, ForeignKey("promotions.id", ondelete="CASCADE"), nullable=False
    )

    product_id = Column(
        Integer,
        ForeignKey("products.id", ondelete="CASCADE"),
        index=True,
        nullable=False,
    )

    # PERCENT => 10 (10%), FIXED => 5000, PROMO_PRICE => 39000
    discount_value = Column(Float, nullable=False)

    max_qty_per_customer = Column(Integer, nullable=True)

    promotion = relationship("Promotion", back_populates="products")
    product = relationship("Product")

    __table_args__ = (
        UniqueConstraint("promotion_id", "product_id", name="uq_promotion_product"),
    )


# models for consent.py
class CustomerConsent(Base):
    """
    Lưu trạng thái consent của khách hàng:
    - được dùng trong /opt-in, /opt-out, GET /{customer_id}
    - field created_at dùng để map ra ConsentResponse.created_at
    """

    __tablename__ = "customer_consents"

    id = Column(Integer, primary_key=True, index=True)
    customer_id = Column(
        Integer, ForeignKey("customers.id"), index=True, nullable=False
    )

    # Consent flags
    face_recognition_consent = Column(Boolean, default=False)
    data_collection_consent = Column(Boolean, default=False)
    marketing_consent = Column(Boolean, default=False)

    # Opt-out info
    opted_out = Column(Boolean, default=False)
    opted_out_at = Column(DateTime, nullable=True)
    opt_out_reason = Column(Text, nullable=True)

    # Metadata về cách thu consent
    consent_method = Column(String(50))  # kiosk, mobile, staff...
    consent_ip_address = Column(String(50))
    consent_location = Column(String(200))

    # Data retention policy
    data_retention_until = Column(DateTime(timezone=True), nullable=True)

    # Timestamps
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(
        DateTime(timezone=True),
        default=datetime.utcnow,
        onupdate=datetime.utcnow,
    )


class PrivacyAuditLog(Base):
    """
    Log mọi thao tác liên quan đến privacy:
    - consent_given / consent_withdrawn / data_deleted
    - được dùng trong delete_customer_data và get_audit_log
    """

    __tablename__ = "privacy_audit_logs"

    id = Column(Integer, primary_key=True, index=True)
    customer_id = Column(
        Integer, ForeignKey("customers.id"), index=True, nullable=False
    )

    operation_type = Column(String(50), nullable=False)
    operation_details = Column(
        JSON
    )  # lưu dict chi tiết (reason, flags, deleted_records, ...)

    performed_by = Column(String(100))  # ai thực hiện (thường là chính customer_id)
    performed_by_role = Column(String(50))  # customer / staff / system
    ip_address = Column(String(50), nullable=True)

    success = Column(Boolean, default=True)
    error_message = Column(Text, nullable=True)

    timestamp = Column(DateTime(timezone=True), default=datetime.utcnow, index=True)


class FaceEmbedding(Base):
    """
    Lưu embedding khuôn mặt gắn với customer_id
    - được xoá trong delete_customer_data
    """

    __tablename__ = "face_embeddings"

    id = Column(Integer, primary_key=True, index=True)
    customer_id = Column(
        Integer,
        ForeignKey("customers.id", ondelete="CASCADE"),
        index=True,
        nullable=False,
    )

    # Tuỳ bạn lưu kiểu gì: JSON, text, vector...
    # Ở đây dùng JSON cho đơn giản (list số float)
    embedding = Column(Vector(512), nullable=False)

    created_at = Column(DateTime, default=datetime.utcnow)


# models for ab_testing.py
class ABExperiment(Base):
    """
    Lưu thông tin cấu hình của một A/B test:
    - variant_a: cấu hình control (ví dụ model cũ, rule cũ)
    - variant_b: cấu hình treatment (model mới, rule mới)
    - split_ratio: tỉ lệ chia traffic (0.5 nghĩa là 50/50)
    """

    __tablename__ = "ab_experiments"

    id = Column(Integer, primary_key=True, index=True)
    experiment_id = Column(String(100), unique=True, index=True, nullable=False)
    experiment_name = Column(String(200), nullable=False)

    # Lưu JSON config cho từng variant (tham số model, rule, UI, v.v.)
    variant_a = Column(JSON, nullable=False)
    variant_b = Column(JSON, nullable=False)

    # 0.5 = 50/50, 0.2 = 20% A / 80% B hoặc tuỳ bạn quyết định cách dùng
    split_ratio = Column(Float, default=0.5)

    # Danh sách branch áp dụng (có thể None = all branches)
    target_branches = Column(JSON, nullable=True)

    # Metric chính để so sánh: "ctr", "conversion", "revenue", ...
    target_metric = Column(String(50), default="ctr")

    # Trạng thái: draft / running / completed
    status = Column(String(50), default="draft")

    # Thời gian chạy
    start_date = Column(DateTime(timezone=True), nullable=True)
    end_date = Column(DateTime(timezone=True), nullable=True)

    # Timestamps
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(
        DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow
    )


class ABExperimentEvent(Base):
    """
    Sự kiện/record tham gia A/B test:
    - Mỗi dòng tương ứng 1 lần hiển thị recommendation / 1 session
    - Dùng để tính conversion / CTR theo từng variant
    """

    __tablename__ = "ab_experiment_events"

    id = Column(Integer, primary_key=True, index=True)
    experiment_id = Column(
        String(100),
        ForeignKey("ab_experiments.experiment_id", ondelete="CASCADE"),
        index=True,
        nullable=False,
    )

    # 'a' hoặc 'b'
    variant = Column(String(1), nullable=False)

    # Có thể lưu thêm ngữ cảnh
    branch_id = Column(String(50), ForeignKey("stores.id"), nullable=True)
    customer_id = Column(Integer, ForeignKey("customers.id"), nullable=True)
    device_id = Column(String(50), ForeignKey("edge_devices.id"), nullable=True)

    # Cờ converted: True nếu user mua / click / action thành công
    converted = Column(Boolean, default=False)

    # Nếu bạn muốn lưu thêm metric số như revenue, click_value,... thì thêm bên dưới
    metric_value = Column(Float, nullable=True)

    timestamp = Column(DateTime(timezone=True), default=datetime.utcnow, index=True)


# models for federated_learning.py
class FederatedLearningRound(Base):
    """
    Thông tin một vòng (round) federated learning:
    - Ghi lại dùng model gì, phương pháp aggregation gì,
      các chi nhánh nào tham gia, trạng thái round.
    """

    __tablename__ = "federated_learning_rounds"

    id = Column(Integer, primary_key=True, index=True)

    # Số thứ tự round (1, 2, 3, ...)
    round_number = Column(Integer, unique=True, index=True, nullable=False)

    # Kiểu model: "face_recognition", "recommender", ...
    model_type = Column(String(100), nullable=False)

    # fedavg / krum / trimmed_mean / median ...
    aggregation_method = Column(String(50), default="fedavg")

    # Danh sách branch tham gia ở round này (["branch_1", "branch_2", ...])
    participating_branches = Column(JSON, nullable=True)
    total_branches = Column(Integer, default=0)

    # Trạng thái round: pending / aggregating / completed / failed
    status = Column(String(50), default="pending")

    started_at = Column(DateTime, nullable=True)
    completed_at = Column(DateTime, nullable=True)

    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class FederatedClientUpdate(Base):
    """
    Mỗi bản ghi là 1 lần client (branch/edge device) upload local update
    cho một round FL:
    - Lưu path file update, kích thước, loss/accuracy local, số sample train.
    """

    __tablename__ = "federated_client_updates"

    id = Column(Integer, primary_key=True, index=True)

    round_number = Column(
        Integer,
        ForeignKey("federated_learning_rounds.round_number", ondelete="CASCADE"),
        index=True,
        nullable=False,
    )

    # Chi nhánh gửi update (branch_id trong hệ thống)
    branch_id = Column(String(50), index=True, nullable=False)

    # Đường dẫn file update trên server (pkl, npy,...)
    update_path = Column(Text, nullable=False)
    update_size_mb = Column(Float, nullable=True)

    # Thông tin performance ở local
    local_loss = Column(Float, nullable=True)
    local_accuracy = Column(Float, nullable=True)
    local_samples_count = Column(Integer, nullable=True)

    # received / aggregated / rejected ...
    status = Column(String(50), default="received")

    created_at = Column(DateTime, default=datetime.utcnow)


# models for analytics.py
class ModelPerformanceLog(Base):
    """
    Log hiệu năng online của model theo thời gian & chi nhánh:
    - dùng cho API /analytics/model-performance
    """

    __tablename__ = "model_performance_logs"

    id = Column(Integer, primary_key=True, index=True)

    # version của model (map với ModelVersion.version)
    model_version = Column(
        String(100),
        ForeignKey("model_versions.version", ondelete="CASCADE"),
        index=True,
        nullable=False,
    )

    # theo ngày (hoặc datetime tuỳ bạn log)
    date = Column(DateTime, index=True, nullable=False)

    branch_id = Column(String(50), nullable=True)

    # metric top-k
    precision_at_5 = Column(Float, nullable=True)
    recall_at_5 = Column(Float, nullable=True)
    ndcg_at_5 = Column(Float, nullable=True)

    # behavior metrics
    ctr = Column(Float, nullable=True)
    avg_latency_ms = Column(Float, nullable=True)
    p95_latency_ms = Column(Float, nullable=True)

    created_at = Column(DateTime, default=datetime.utcnow)


class InventoryOptimization(Base):
    """
    Lưu lại các khuyến nghị tối ưu tồn kho:
    - restock / transfer / markdown
    - có thể sinh từ batch job rồi FE gọi ra hiển thị
    """

    __tablename__ = "inventory_optimizations"

    id = Column(Integer, primary_key=True, index=True)

    branch_id = Column(
        String(50),
        ForeignKey("stores.id", ondelete="CASCADE"),
        index=True,
        nullable=False,
    )
    product_id = Column(
        Integer,
        ForeignKey("products.id", ondelete="CASCADE"),
        index=True,
        nullable=False,
    )

    # 'restock', 'transfer', 'markdown', ...
    action = Column(String(50), nullable=False)

    # Số lượng đề xuất (dương/âm tuỳ logic bạn định nghĩa)
    quantity = Column(Integer, nullable=False)

    # priority: high / medium / low
    priority = Column(String(20), default="medium")

    # giải thích ngắn gọn: "High demand: 5.2 units/day", ...
    reason = Column(Text, nullable=True)

    # để biết đề xuất này còn hiệu lực không
    status = Column(String(20), default="pending")  # pending / applied / ignored

    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(
        DateTime,
        default=datetime.utcnow,
        onupdate=datetime.utcnow,
    )
    __table_args__ = (
        UniqueConstraint(
            "branch_id",
            "product_id",
            "action",
            name="uq_inventory_opt_branch_product_action",
        ),
    )
