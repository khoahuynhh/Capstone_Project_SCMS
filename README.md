# FBRS System - Edge AI Retail Platform

FBRS is a full-stack retail recommendation system with three deployment surfaces:

- **UI/POS**: React + Vite web application for checkout, face scan, products, transactions, and monitoring.
- **Cloud Server**: FastAPI service for authentication, products, recommendations, transactions, analytics, PostgreSQL, Redis, MQTT broker, Prometheus, and Grafana.
- **Edge Device**: lightweight FastAPI runtime for face attribute inference. The edge device returns `age`, `age_group`, `gender`, and `emotion`, then reports device health to the cloud through MQTT.

The production flow is intentionally split:

1. UI captures an image and calls the Edge HTTP API.
2. Edge runs the AI model and returns face attributes only.
3. UI calls Cloud HTTP API for product recommendations using those attributes.
4. UI sends transactions and business operations to Cloud.
5. Edge sends status and heartbeat events to Cloud through MQTT.

MQTT is used for machine-to-machine edge status and telemetry. It is not used by the UI and it is not the product recommendation path.

## Repository Layout

```text
.
|-- src/                         React/Vite UI
|-- public/                      Static frontend assets
|-- be/
|   |-- cloud-server/            FastAPI cloud application
|   |-- edge-device/             FastAPI edge inference runtime
|   |-- docker-compose.cloud.yml Cloud stack for server deployment
|   |-- docker-compose.edge.yml  Edge stack for Raspberry Pi or local edge testing
|   |-- docker-compose.yml       Legacy all-in-one local demo
|   |-- init-db/                 PostgreSQL initialization scripts
|   |-- monitoring/              Prometheus and Grafana provisioning
|   `-- mqtt-broker/             Mosquitto configuration
|-- .env.example                 Frontend environment template
`-- package.json                 Frontend scripts and dependencies
```

Use `be/docker-compose.cloud.yml` and `be/docker-compose.edge.yml` for the current deployment model. Keep `be/docker-compose.yml` only for older all-in-one local demos.

## Prerequisites

- Node.js 18+ and npm.
- Docker Desktop or Docker Engine with Compose v2.
- Python 3.11+ only when running services outside Docker.
- A trained edge model at `be/edge-device/models/best_model.pth`.
- Network access from the UI/POS machine to both Cloud API and Edge API.

## Environment Files

Copy the templates before running the system:

```powershell
Copy-Item .env.example .env
Copy-Item be\.env.example be\.env
Copy-Item be\edge-device\.env.docker.example be\edge-device\.env
```

Frontend `.env`:

```env
VITE_SERVER_API_BASE=http://localhost:8000
VITE_EDGE_API_BASE=http://localhost:8001
VITE_BRANCH_ID=HCM_Q1
VITE_DEVICE_ID=EDGE_HCM_Q1_01
VITE_GRAFANA_EMBED_URL=http://localhost:3000/d/edge-ai-retail-overview/edge-ai-retail-system-overview?orgId=1&kiosk
```

Cloud `.env` lives at `be/.env` and configures PostgreSQL, Redis, MQTT, JWT, admin API key, and monitoring ports.

Edge `.env` lives at `be/edge-device/.env` and configures device identity, model path, HTTP port, MQTT broker, and heartbeat interval.

## Local Development

Start the Cloud stack:

```powershell
cd be
docker compose -f docker-compose.cloud.yml up -d --build
```

Start the Edge stack:

```powershell
cd be
docker compose -f docker-compose.edge.yml up -d --build
```

Start the UI from the repository root:

```powershell
npm install
npm run dev -- --host
```

Open:

- UI: `http://localhost:5173`
- Cloud API: `http://localhost:8000`
- Cloud Swagger: `http://localhost:8000/docs`
- Edge API: `http://localhost:8001`
- Grafana: `http://localhost:3000`
- Prometheus: `http://localhost:9090`
- MQTT broker: `localhost:1883`
- PostgreSQL host port: `localhost:5433`

## Production Deployment Shape

### Cloud server

Run on the server that owns PostgreSQL, Redis, MQTT, Cloud API, Prometheus, and Grafana:

```powershell
cd be
docker compose -f docker-compose.cloud.yml up -d --build
```

Use strong production values in `be/.env`:

```env
POSTGRES_PASSWORD=<strong-password>
JWT_SECRET=<long-random-secret>
JWT_SECRET_KEY=<long-random-secret>
ADMIN_API_KEY=<admin-api-key>
GRAFANA_ADMIN_PASSWORD=<grafana-password>
API_KEY_ENABLED=true
```

### Edge device / Raspberry Pi

Run on the Raspberry Pi or edge computer:

```powershell
cd be
docker compose -f docker-compose.edge.yml up -d --build
```

In `be/edge-device/.env`, set:

```env
BRANCH_ID=HCM_Q1
BRANCH_NAME=Mart Quan 1
DEVICE_ID=EDGE_HCM_Q1_01
MQTT_BROKER=<cloud-server-ip-or-dns>
MQTT_PORT=1883
MODEL_STORAGE_PATH=./models
INFERENCE_DEVICE=cpu
```

Do not use `localhost` for `MQTT_BROKER` on a real Raspberry Pi unless the MQTT broker is also running on that same Pi.

### UI/POS

Build the UI:

```powershell
npm run build
```

For deployment, configure the UI environment so it can reach:

- Cloud API through `VITE_SERVER_API_BASE`.
- Local or LAN Edge API through `VITE_EDGE_API_BASE`.

## Main Runtime APIs

Cloud:

- `GET /health`
- `GET /products`
- `POST /recommendations/by-attributes`
- `POST /transactions`
- `GET /transactions`
- `GET /metrics/summary`
- `GET /metrics`

Edge:

- `GET /health`
- `GET /metrics`
- `POST /face/analysis`

Expected edge response shape:

```json
{
  "success": true,
  "branch_id": "HCM_Q1",
  "device_id": "EDGE_HCM_Q1_01",
  "age": 28,
  "age_group": "25_34",
  "gender": "female",
  "emotion": "happy",
  "source": "edge_face_attribute_model",
  "latency_ms": 120.5
}
```

## Data Backup And Restore

Back up the current PostgreSQL data:

```powershell
python be\cloud-server\scripts\export_postgres.py
```

Restore a plain SQL backup into a new PostgreSQL container:

```powershell
Get-Content .\be\cloud-server\data\backups\<backup-file>.sql | docker exec -i postgres-db psql -U admin -d retail_db
```

Never run `docker compose down -v` unless you intentionally want to remove volumes. PostgreSQL data lives in the Docker volume used by the `postgres` service.

## Verification

Check Cloud:

```powershell
curl http://localhost:8000/health
docker compose -f be/docker-compose.cloud.yml ps
```

Check Edge:

```powershell
curl http://localhost:8001/health
docker compose -f be/docker-compose.edge.yml logs -f edge-device
```

Check MQTT heartbeat from a machine that has Mosquitto clients installed:

```powershell
mosquitto_sub -h localhost -p 1883 -t "retail/#"
```

## Notes

- `be/edge-device/main.py` is legacy simulation code and is not the current production entrypoint.
- The current edge production entrypoint is `uvicorn edge_api:app --host 0.0.0.0 --port 8001`.
- Redis is part of the Cloud stack. It is not required on the Edge device.
- Product recommendation rendering belongs to the UI, using recommendation data returned by the Cloud API.
