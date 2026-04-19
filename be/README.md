# Backend Services

This folder contains the backend runtime for FBRS:

- `cloud-server/`: FastAPI Cloud API for products, recommendations, transactions, analytics, authentication, and monitoring.
- `edge-device/`: FastAPI Edge API for face attribute inference.
- `docker-compose.cloud.yml`: production-style Cloud stack.
- `docker-compose.edge.yml`: production-style Edge stack.
- `docker-compose.yml`: legacy all-in-one local demo.

## Architecture

The backend is split by responsibility:

| Surface | Responsibility |
| --- | --- |
| Cloud Server | Business data, product catalog, recommendations, transactions, users, analytics, metrics |
| Edge Device | Run the face attribute model and return `age`, `age_group`, `gender`, `emotion` |
| MQTT Broker | Receive edge status events such as `edge_online`, `edge_heartbeat`, and `edge_offline` |
| PostgreSQL | Main persistent data store |
| Redis | Cloud-side cache/runtime support |
| Prometheus/Grafana | Metrics and dashboards |

The UI calls Edge over HTTP for inference and calls Cloud over HTTP for recommendations and business operations. Edge does not render product recommendations and does not own product data.

## Compose Files

### Cloud stack

Use this on the server:

```powershell
docker compose -f docker-compose.cloud.yml up -d --build
```

Services:

- `cloud-server` on host port `8000`.
- `postgres-db` on host port `5433`.
- `redis-cache` on host port `6379`.
- `mqtt-broker` on host ports `1883` and `9001`.
- `prometheus` on host port `9090`.
- `grafana` on host port `3000`.

### Edge stack

Use this on Raspberry Pi or on a local machine for edge testing:

```powershell
docker compose -f docker-compose.edge.yml up -d --build
```

Service:

- `edge-device` on host port `8001`.

### Legacy all-in-one stack

`docker-compose.yml` is kept only for older local demos. Do not use it as the main production deployment file.

## Environment

Create environment files:

```powershell
Copy-Item .env.example .env
Copy-Item edge-device\.env.docker.example edge-device\.env
```

Cloud settings in `be/.env`:

```env
CLOUD_API_PORT=8000
POSTGRES_USER=admin
POSTGRES_PASSWORD=change-this-password
POSTGRES_DB=retail_db
POSTGRES_HOST_PORT=5433
DATABASE_URL=postgresql://admin:change-this-password@postgres:5432/retail_db
REDIS_URL=redis://redis:6379
MQTT_BROKER=mosquitto
MQTT_PORT=1883
JWT_SECRET_KEY=change-this-secret-key
ADMIN_API_KEY=change-this-admin-key
```

Edge settings in `be/edge-device/.env`:

```env
BRANCH_ID=HCM_Q1
BRANCH_NAME=Mart Quan 1
DEVICE_ID=EDGE_HCM_Q1_01
API_PORT=8001
MODEL_STORAGE_PATH=./models
INFERENCE_DEVICE=cpu
HEARTBEAT_ENABLED=true
HEARTBEAT_INTERVAL=60
MQTT_BROKER=host.docker.internal
MQTT_PORT=1883
```

For Raspberry Pi deployment, replace `MQTT_BROKER=host.docker.internal` with the Cloud server IP or DNS name.

## Health Checks

Cloud:

```powershell
curl http://localhost:8000/health
docker compose -f docker-compose.cloud.yml logs -f cloud-server
```

Edge:

```powershell
curl http://localhost:8001/health
docker compose -f docker-compose.edge.yml logs -f edge-device
```

PostgreSQL:

```powershell
docker exec postgres-db psql -U admin -d retail_db -c "SELECT 1;"
```

Redis:

```powershell
docker exec redis-cache redis-cli ping
```

## Main APIs

Cloud API:

- `GET /health`
- `GET /products`
- `POST /recommendations/by-attributes`
- `POST /transactions`
- `GET /transactions`
- `GET /branches`
- `GET /metrics/summary`
- `GET /metrics`

Edge API:

- `GET /health`
- `GET /metrics`
- `POST /face/analysis`

## Database Backup

Create a PostgreSQL backup from the running `postgres-db` container:

```powershell
python cloud-server\scripts\export_postgres.py
```

Restore a plain SQL backup:

```powershell
Get-Content .\cloud-server\data\backups\<backup-file>.sql | docker exec -i postgres-db psql -U admin -d retail_db
```

Do not use `docker compose down -v` unless you intentionally want to delete Docker volumes.

## Development Notes

- Current Edge production entrypoint: `uvicorn edge_api:app --host 0.0.0.0 --port 8001`.
- `edge-device/main.py` is legacy simulation code.
- Redis is used by the Cloud stack, not by the Edge stack.
- Model artifacts such as `*.pth`, `*.pt`, `*.onnx`, and `*.ckpt` should be copied to runtime environments manually, not committed to Git.
