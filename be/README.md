# Start all services

docker compose up -d

# Check logs

docker compose logs -f cloud-server

# Access services:

# - Cloud API: http://localhost:8000

# - API Docs: http://localhost:8000/docs

# - Grafana: http://localhost:3000 (admin/admin)

# - Prometheus: http://localhost:9090

# Run server

uvicorn main:app --reload --host 0.0.0.0 --port 8002

#### Edge Device

````bash

# Create virtual environment
# Set environment variables
export BRANCH_ID=branch_001
export BRANCH_NAME="Chi nhánh 1"
export MQTT_BROKER=localhost
export CLOUD_API=http://localhost:8000

### 2. Upload Model
```bash
# Upload face detector model
curl -X POST "http://localhost:8000/api/v1/models/upload" \
  -F "version=v1.0.0" \
  -F "model_type=face_detector" \
  -F "model_format=onnx" \
  -F "file=@models/face_detector.onnx"

# Upload recommender model
curl -X POST "http://localhost:8000/api/v1/models/upload" \
  -F "version=v1.0.0" \
  -F "model_type=recommender" \
  -F "model_format=onnx" \
  -F "file=@models/recommender.onnx"
````

### 3. Deploy Model to Edge

```bash
curl -X POST "http://localhost:8000/api/v1/models/deploy" \
  -H "Content-Type: application/json" \
  -d '{
    "version": "v1.0.0",
    "target_branches": ["branch_001", "branch_002"]
  }'
```

### 4. Create A/B Test

```bash
curl -X POST "http://localhost:8000/api/v1/experiments/create" \
  -H "Content-Type: application/json" \
  -d '{
    "experiment_name": "New Recommendation Algorithm",
    "variant_a": {"algorithm": "collaborative_filtering"},
    "variant_b": {"algorithm": "deep_learning"},
    "split_ratio": 0.5,
    "target_metric": "ctr"
  }'
```

### 5. Trigger Federated Learning

```bash
curl -X POST "http://localhost:8000/api/v1/federated/aggregate" \
  -H "Content-Type: application/json" \
  -d '{
    "model_type": "recommender",
    "aggregation_method": "fedavg",
    "min_clients": 2
  }'
```

---

## API Documentation

### Interactive API Docs

Truy cập: http://localhost:8000/docs (Swagger UI)

### Main Endpoints

#### Transactions

- `GET /api/v1/transactions` - List transactions
- `GET /api/v1/transactions/{id}` - Get transaction details

#### Model Management

- `POST /api/v1/models/upload` - Upload model
- `POST /api/v1/models/deploy` - Deploy model
- `POST /api/v1/models/rollback` - Rollback model
- `GET /api/v1/models/list` - List models
- `GET /api/v1/models/active/{type}` - Get active model

#### Privacy & Consent

- `POST /api/v1/consent/opt-in` - Customer opt-in
- `POST /api/v1/consent/opt-out` - Customer opt-out
- `DELETE /api/v1/consent/data/{customer_id}` - Delete customer data (GDPR)
- `GET /api/v1/consent/{customer_id}` - Get consent status

#### A/B Testing

- `POST /api/v1/experiments/create` - Create experiment
- `POST /api/v1/experiments/{id}/start` - Start experiment
- `GET /api/v1/experiments/{id}/results` - Get results
- `POST /api/v1/experiments/{id}/conclude` - Conclude experiment

#### Federated Learning

- `POST /api/v1/federated/upload-update` - Upload client update
- `POST /api/v1/federated/aggregate` - Trigger aggregation
- `GET /api/v1/federated/status/{round}` - Get round status
- `GET /api/v1/federated/history` - Get FL history

#### Analytics

- `GET /api/v1/analytics/ctr` - CTR metrics
- `GET /api/v1/analytics/inventory-optimization` - Inventory recommendations
- `GET /api/v1/analytics/model-performance` - Model performance over time
- `GET /api/v1/analytics/demand-forecast` - Demand forecast
- `GET /api/v1/analytics/top-products` - Top selling products

---

## Cấu hình

### Environment Variables (cloud-server/.env)

```bash
# Application
DEBUG=False
ENVIRONMENT=production
PORT=8000

# Database
DATABASE_URL=postgresql://user:pass@host:5432/retail_db

# Redis
REDIS_URL=redis://localhost:6379

# MQTT
MQTT_BROKER=mosquitto
MQTT_PORT=1883

# Federated Learning
FL_AGGREGATION_INTERVAL_HOURS=24
FL_MIN_CLIENTS=2
FL_AGGREGATION_METHOD=fedavg  # fedavg, krum, trimmed_mean

# Privacy
DATA_RETENTION_DAYS=90
FACE_IMAGE_RETENTION_HOURS=0
GDPR_ENABLED=True

# Security
API_KEY_ENABLED=True
JWT_SECRET_KEY=<your-secret-key>

# Performance
RECOMMENDATION_TIMEOUT_MS=200
RECOMMENDATION_TOP_K=5
```

### Edge Device Config (edge-device/.env)

```bash
# Device Identity
BRANCH_ID=branch_001
BRANCH_NAME=Chi nhánh Quận 1
DEVICE_ID=edge_001

# Cloud Connection
CLOUD_API=http://cloud-server:8000
MQTT_BROKER=mosquitto

# Performance
INFERENCE_DEVICE=cpu  # cpu, cuda, tensorrt
RECOMMENDATION_TIMEOUT_MS=200

# Camera
CAMERA_ENABLED=True
CAMERA_MOCK=False  # Set to True for simulation
```

---

## Monitoring

### Grafana Dashboards

1. Access: http://localhost:3000
2. Login: admin/admin
3. Dashboards:
   - **System Overview**: Total transactions, active branches, latency
   - **Model Performance**: Precision@K, latency by branch
   - **Federated Learning**: Round progress, client updates

### Prometheus Metrics

- `edge_inference_total` - Total inferences
- `edge_inference_latency_seconds` - Inference latency histogram
- `edge_recommendations_total` - Total recommendations
- `edge_recommendations_accepted` - Accepted recommendations
- `federated_learning_round_number` - Current FL round

## Bảo mật & Privacy

### Privacy Features

- **Opt-in/Opt-out mechanism** tại quầy
- **Face images không lưu** (chỉ embeddings)
- **Data anonymization** cho analytics
- **GDPR Right to be Forgotten** (DELETE /api/v1/consent/data/{id})
- **Audit logs** cho mọi data access
- **Data retention policies** (tự động xóa sau X ngày)

### Security Best Practices

1. Đổi `JWT_SECRET_KEY` trong production
2. Enable HTTPS/TLS cho APIs
3. Set `API_KEY_ENABLED=True` và tạo keys cho edge devices
4. Restrict PostgreSQL access (không expose port 5432 ra ngoài)
5. Regular security audits

---

## Phát triển

### Database Migrations

```bash
# Create migration
alembic revision --autogenerate -m "Add new table"

# Apply migration
alembic upgrade head

# Rollback
alembic downgrade -1
```

### Running Tests

```bash
# Unit tests
pytest tests/

# Integration tests
pytest tests/integration/

# Coverage
pytest --cov=cloud-server --cov-report=html
```
