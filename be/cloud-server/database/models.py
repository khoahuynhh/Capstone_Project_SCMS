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


# from sqlalchemy import Column, Integer, String, Float, DateTime, JSON, Boolean, Text, Index, ForeignKey, LargeBinary
# from sqlalchemy.ext.declarative import declarative_base
# from sqlalchemy.orm import relationship
# from datetime import datetime

# Base = declarative_base()

# class Transaction(Base):
#     """Transaction records from edge devices"""
#     __tablename__ = "transactions"
    
#     id = Column(Integer, primary_key=True, index=True)
#     branch_id = Column(String(50), index=True, nullable=False)
#     transaction_id = Column(String(100), unique=True, index=True, nullable=False)
#     timestamp = Column(DateTime, default=datetime.utcnow, index=True)
#     customer_id = Column(String(100), index=True)
    
#     # Transaction details
#     items_data = Column(JSON)  # List of purchased items
#     items_count = Column(Integer)
#     total_amount = Column(Float)
    
#     # Recommendation context
#     recommended_items = Column(JSON)  # What was recommended
#     accepted_recommendations = Column(Boolean, default=False)
    
#     # Metadata
#     created_at = Column(DateTime, default=datetime.utcnow)

# class Recommendation(Base):
#     """Recommendation events from edge devices"""
#     __tablename__ = "recommendations"
    
#     id = Column(Integer, primary_key=True, index=True)
#     branch_id = Column(String(50), index=True, nullable=False)
#     transaction_id = Column(String(100), index=True)
#     timestamp = Column(DateTime, default=datetime.utcnow, index=True)
#     customer_id = Column(String(100), index=True)
    
#     # Customer attributes
#     face_attributes = Column(JSON)  # Demographics, age, gender, etc.
    
#     # Recommendations
#     recommended_products = Column(JSON)  # List of recommended products
#     items_count = Column(Integer)
    
#     # Outcome
#     accepted = Column(Boolean, default=False)
#     purchased_items = Column(JSON)
    
#     # Metadata
#     created_at = Column(DateTime, default=datetime.utcnow)

# class Customer(Base):
#     """Anonymized customer profiles"""
#     __tablename__ = "customers"
    
#     id = Column(Integer, primary_key=True, index=True)
#     customer_id = Column(String(100), unique=True, index=True, nullable=False)
    
#     # Demographics (aggregated, anonymized)
#     age_group = Column(String(20))
#     gender = Column(String(20))
    
#     # Purchase behavior
#     total_transactions = Column(Integer, default=0)
#     total_spent = Column(Float, default=0)
#     favorite_categories = Column(JSON)
    
#     # Preferences
#     preferred_branch = Column(String(50))
#     avg_basket_size = Column(Float)
    
#     # Timestamps
#     first_seen = Column(DateTime, default=datetime.utcnow)
#     last_seen = Column(DateTime, default=datetime.utcnow)
#     created_at = Column(DateTime, default=datetime.utcnow)

# class BranchMetrics(Base):
#     """Daily aggregated metrics per branch"""
#     __tablename__ = "branch_metrics"
    
#     id = Column(Integer, primary_key=True, index=True)
#     branch_id = Column(String(50), index=True, nullable=False)
#     date = Column(DateTime, index=True, nullable=False)
    
#     # Transaction metrics
#     total_transactions = Column(Integer, default=0)
#     total_revenue = Column(Float, default=0)
#     avg_transaction_value = Column(Float, default=0)
    
#     # Recommendation metrics
#     total_recommendations = Column(Integer, default=0)
#     recommendations_accepted = Column(Integer, default=0)
#     acceptance_rate = Column(Float, default=0)
    
#     # Performance metrics
#     avg_latency_ms = Column(Float)
#     inference_count = Column(Integer, default=0)
    
#     # Inventory
#     top_selling_products = Column(JSON)
#     out_of_stock_items = Column(JSON)
    
#     created_at = Column(DateTime, default=datetime.utcnow)

# class ModelVersion(Base):
#     """Model version tracking"""
#     __tablename__ = "model_versions"
    
#     id = Column(Integer, primary_key=True, index=True)
#     version = Column(String(50), unique=True, nullable=False)
#     model_type = Column(String(50))  # 'face_detector', 'recommender', etc.
    
#     # Model info
#     model_path = Column(Text)
#     model_size_mb = Column(Float)
#     model_format = Column(String(20))  # 'onnx', 'tensorrt', 'pytorch'
    
#     # Performance
#     accuracy = Column(Float)
#     precision = Column(Float)
#     recall = Column(Float)
#     f1_score = Column(Float)
#     latency_ms = Column(Float)
    
#     # Metadata
#     training_date = Column(DateTime)
#     deployed_to_branches = Column(JSON)
#     is_active = Column(Boolean, default=False)
#     parent_version = Column(String(50))  # For rollback tracking
    
#     created_at = Column(DateTime, default=datetime.utcnow)
#     updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


# class FaceEmbedding(Base):
#     """Face embeddings for customer recognition"""
#     __tablename__ = "face_embeddings"
    
#     id = Column(Integer, primary_key=True, index=True)
#     customer_id = Column(String(100), index=True, nullable=False)
#     branch_id = Column(String(50), index=True)
    
#     # Embedding vector (stored as binary or JSON)
#     embedding = Column(LargeBinary)  # 512-dim float32 vector
#     embedding_model_version = Column(String(50))
    
#     # Face metadata
#     face_quality_score = Column(Float)  # 0-1 confidence
    
#     # Demographics (aggregated from multiple detections)
#     age_group = Column(String(20))
#     gender = Column(String(20))
    
#     # Timestamps
#     first_seen = Column(DateTime, default=datetime.utcnow)
#     last_seen = Column(DateTime, default=datetime.utcnow, index=True)
#     detection_count = Column(Integer, default=1)
    
#     created_at = Column(DateTime, default=datetime.utcnow)
#     updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
#     __table_args__ = (
#         Index('idx_customer_branch', 'customer_id', 'branch_id'),
#     )


# class ABExperiment(Base):
#     """A/B Testing experiments"""
#     __tablename__ = "ab_experiments"
    
#     id = Column(Integer, primary_key=True, index=True)
#     experiment_id = Column(String(100), unique=True, index=True, nullable=False)
#     experiment_name = Column(String(200), nullable=False)
    
#     # Experiment config
#     variant_a = Column(JSON)  # Control group config
#     variant_b = Column(JSON)  # Treatment group config
#     split_ratio = Column(Float, default=0.5)  # 0.5 = 50/50 split
    
#     # Status
#     status = Column(String(20), default='draft')  # draft, running, paused, completed
    
#     # Target
#     target_branches = Column(JSON)  # null = all branches
#     target_metric = Column(String(50))  # 'ctr', 'conversion', 'revenue'
    
#     # Results
#     total_participants_a = Column(Integer, default=0)
#     total_participants_b = Column(Integer, default=0)
#     metric_value_a = Column(Float)
#     metric_value_b = Column(Float)
#     statistical_significance = Column(Float)  # p-value
#     winner = Column(String(10))  # 'a', 'b', or 'no_difference'
    
#     # Dates
#     start_date = Column(DateTime)
#     end_date = Column(DateTime)
#     created_at = Column(DateTime, default=datetime.utcnow)
#     updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


# class ABExperimentEvent(Base):
#     """Individual events in A/B experiments"""
#     __tablename__ = "ab_experiment_events"
    
#     id = Column(Integer, primary_key=True, index=True)
#     experiment_id = Column(String(100), index=True, nullable=False)
#     customer_id = Column(String(100), index=True)
#     branch_id = Column(String(50), index=True)
    
#     # Assignment
#     variant = Column(String(10), nullable=False)  # 'a' or 'b'
    
#     # Interaction
#     recommendations_shown = Column(JSON)
#     item_clicked = Column(String(100))
#     items_purchased = Column(JSON)
#     transaction_value = Column(Float)
    
#     # Outcome
#     converted = Column(Boolean, default=False)
    
#     timestamp = Column(DateTime, default=datetime.utcnow, index=True)
    
#     __table_args__ = (
#         Index('idx_exp_variant', 'experiment_id', 'variant'),
#     )


# class ModelPerformanceLog(Base):
#     """Daily model performance metrics per branch"""
#     __tablename__ = "model_performance_logs"
    
#     id = Column(Integer, primary_key=True, index=True)
#     model_version = Column(String(50), index=True, nullable=False)
#     model_type = Column(String(50), nullable=False)
#     branch_id = Column(String(50), index=True, nullable=False)
#     date = Column(DateTime, index=True, nullable=False)
    
#     # Recommendation metrics
#     precision_at_5 = Column(Float)
#     recall_at_5 = Column(Float)
#     ndcg_at_5 = Column(Float)
#     map_score = Column(Float)
    
#     # CTR & Conversion
#     total_recommendations = Column(Integer, default=0)
#     total_clicks = Column(Integer, default=0)
#     total_conversions = Column(Integer, default=0)
#     ctr = Column(Float)  # Click-through rate
#     conversion_rate = Column(Float)
    
#     # Performance
#     avg_latency_ms = Column(Float)
#     p95_latency_ms = Column(Float)
#     p99_latency_ms = Column(Float)
#     inference_count = Column(Integer, default=0)
#     error_count = Column(Integer, default=0)
    
#     # Resource usage
#     avg_memory_mb = Column(Float)
#     peak_memory_mb = Column(Float)
#     avg_cpu_percent = Column(Float)
    
#     created_at = Column(DateTime, default=datetime.utcnow)
    
#     __table_args__ = (
#         Index('idx_model_branch_date', 'model_version', 'branch_id', 'date'),
#     )


# class CustomerConsent(Base):
#     """Customer privacy consent tracking"""
#     __tablename__ = "customer_consent"
    
#     id = Column(Integer, primary_key=True, index=True)
#     customer_id = Column(String(100), unique=True, index=True, nullable=False)
    
#     # Consent flags
#     face_recognition_consent = Column(Boolean, default=False)
#     data_collection_consent = Column(Boolean, default=False)
#     marketing_consent = Column(Boolean, default=False)
    
#     # Consent method
#     consent_method = Column(String(50))  # 'kiosk', 'mobile', 'staff'
#     consent_ip_address = Column(String(50))
#     consent_location = Column(String(100))
    
#     # Opt-out
#     opted_out = Column(Boolean, default=False)
#     opted_out_at = Column(DateTime)
#     opt_out_reason = Column(Text)
    
#     # Data retention
#     data_retention_until = Column(DateTime)
    
#     created_at = Column(DateTime, default=datetime.utcnow)
#     updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


# class PrivacyAuditLog(Base):
#     """Audit log for privacy-related operations"""
#     __tablename__ = "privacy_audit_logs"
    
#     id = Column(Integer, primary_key=True, index=True)
#     customer_id = Column(String(100), index=True)
    
#     # Operation
#     operation_type = Column(String(50), nullable=False)  # 'consent_given', 'consent_withdrawn', 'data_accessed', 'data_deleted'
#     operation_details = Column(JSON)
    
#     # Actor
#     performed_by = Column(String(100))  # user_id or 'system'
#     performed_by_role = Column(String(50))  # 'customer', 'staff', 'admin', 'system'
    
#     # Context
#     ip_address = Column(String(50))
#     user_agent = Column(Text)
#     branch_id = Column(String(50))
    
#     # Result
#     success = Column(Boolean, default=True)
#     error_message = Column(Text)
    
#     timestamp = Column(DateTime, default=datetime.utcnow, index=True)
    
#     __table_args__ = (
#         Index('idx_audit_customer_op', 'customer_id', 'operation_type'),
#     )


# class FederatedLearningRound(Base):
#     """Federated learning aggregation rounds"""
#     __tablename__ = "federated_learning_rounds"
    
#     id = Column(Integer, primary_key=True, index=True)
#     round_number = Column(Integer, unique=True, index=True, nullable=False)
#     model_type = Column(String(50), nullable=False)
    
#     # Round config
#     aggregation_method = Column(String(50))  # 'fedavg', 'krum', 'trimmed_mean', 'median'
#     participating_branches = Column(JSON)
#     total_branches = Column(Integer)
    
#     # Status
#     status = Column(String(20), default='pending')  # pending, aggregating, completed, failed
    
#     # Results
#     global_model_version = Column(String(50))
#     aggregation_metrics = Column(JSON)  # Loss, accuracy, etc.
    
#     # Byzantine detection
#     detected_malicious_clients = Column(JSON)
#     byzantine_tolerance_applied = Column(Boolean, default=False)
    
#     # Performance
#     aggregation_time_seconds = Column(Float)
#     communication_mb = Column(Float)
    
#     # Dates
#     started_at = Column(DateTime, default=datetime.utcnow)
#     completed_at = Column(DateTime)
    
#     created_at = Column(DateTime, default=datetime.utcnow)
    
#     __table_args__ = (
#         Index('idx_fl_round_model', 'round_number', 'model_type'),
#     )


# class FederatedClientUpdate(Base):
#     """Individual client updates in federated learning"""
#     __tablename__ = "federated_client_updates"
    
#     id = Column(Integer, primary_key=True, index=True)
#     round_number = Column(Integer, index=True, nullable=False)
#     branch_id = Column(String(50), index=True, nullable=False)
    
#     # Update data (gradients or model weights)
#     update_path = Column(Text)  # Path to stored gradients/weights file
#     update_size_mb = Column(Float)
    
#     # Training metrics
#     local_loss = Column(Float)
#     local_accuracy = Column(Float)
#     local_samples_count = Column(Integer)
#     local_epochs = Column(Integer)
    
#     # Quality metrics
#     gradient_norm = Column(Float)
#     is_malicious = Column(Boolean, default=False)  # Byzantine detection result
#     quality_score = Column(Float)  # For weighted aggregation
    
#     # Status
#     status = Column(String(20), default='pending')  # pending, received, aggregated, rejected
#     rejection_reason = Column(Text)
    
#     uploaded_at = Column(DateTime, default=datetime.utcnow)
#     processed_at = Column(DateTime)
    
#     __table_args__ = (
#         Index('idx_client_round', 'round_number', 'branch_id'),
#     )


# class InventoryOptimization(Base):
#     """Inventory optimization recommendations"""
#     __tablename__ = "inventory_optimization"
    
#     id = Column(Integer, primary_key=True, index=True)
#     date = Column(DateTime, index=True, nullable=False)
    
#     # Recommendations per branch
#     recommendations = Column(JSON)  # [{branch_id, product_id, action, quantity, reason}]
    
#     # Analysis
#     demand_forecast = Column(JSON)  # Predicted demand per product per branch
#     stock_out_risks = Column(JSON)  # Products at risk of stock-out
#     overstock_items = Column(JSON)  # Products with excess inventory
    
#     # Transfer recommendations
#     inter_branch_transfers = Column(JSON)  # [{from_branch, to_branch, product_id, quantity}]
    
#     # Metrics
#     potential_revenue_impact = Column(Float)
#     potential_cost_savings = Column(Float)
    
#     created_at = Column(DateTime, default=datetime.utcnow)
