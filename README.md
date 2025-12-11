# SMCS System – Edge AI Retail Platform

A full-stack showcase that combines a React/Vite web console with a cloud backend, simulated edge devices, and a monitoring stack. The system streams customer interactions from multiple branches, runs face identification + recommendations at the edge, synchronizes data to a FastAPI cloud service, and exposes real-time metrics over Prometheus/Grafana.

## Repository Layout

- `src/` – React application (camera capture, monitoring, transaction explorer).
- `.env` – Frontend configuration (`VITE_SERVER_API_BASE`, `VITE_EDGE_API_BASE`).
- `be/` – Backend mono-folder that contains everything needed to run the services:
  - `docker-compose.yml` – Cloud API, two edge-device simulators, Mosquitto, PostgreSQL, Redis, Prometheus, Grafana.
  - `cloud-server/` – FastAPI app (`uvicorn main:app`) with PostgreSQL + Redis.
  - `edge-device/` – Python edge runtime (camera/face identification simulation + branch level metrics).
  - `monitoring/` – Prometheus scrape config and Grafana provisioning.
  - `mqtt-broker/`, `data/` – Local volumes persisted on the host.

> The quickest way to spin up every component (cloud + edges + monitoring + UI) is to run Docker Compose inside `be/` and then start the frontend dev server from repo root.

---

## Prerequisites

- Node.js 18+ and npm.
- Docker Desktop (Compose v2) with enough memory for 8 services.
- Python 3.11+ only if you plan to run `cloud-server` or `edge-device` outside Docker.
- Webcam permission (Chrome/Edge/Safari) if you want to use the face-recognition widget from the UI.

---

## Quick Start (All-in-one stack)

1. **Clone & install dependencies**
   ```bash
   git clone <repo-url> && cd smcs-system
   npm install
   ```
2. **Configure environment variables**
   - Frontend: `cp .env.example .env` and edit values (sample below).
   - Backend: `cd be && cp .env.example .env`. If you want to customize edge settings, also copy `edge-device/.env.example` to `edge-device/.env`.
3. **Start every backend service**
   ```bash
   cd be
   ./start.sh             # optional helper; runs the steps below
   docker compose up -d   # build + start: cloud-server, edge devices, db, mqtt, monitoring
   docker compose ps      # verify all 8 services are "running"
   ```
4. **Launch the frontend**
   ```bash
   cd ..                  # back to repo root
   npm run dev -- --host
   ```
5. **Open the interfaces**
   - Web console: http://localhost:5173 (or whichever host Vite prints).
   - Cloud API: http://localhost:8000
   - API Docs (Swagger): http://localhost:8000/docs
   - Edge devices: http://localhost:8001 (branch 1), http://localhost:8002 (branch 2)
   - Grafana: http://localhost:3000 (admin / admin)
   - Prometheus: http://localhost:9090
   - Mosquitto broker: `localhost:1883`
   - PostgreSQL: `postgresql://admin:admin123@localhost:5432/retail_db`

Stop everything with:

```bash
cd be
docker compose down
```

Add `-v` if you also want to delete volumes/data.

---

## Environment Configuration

### Frontend `.env`

```ini
VITE_SERVER_API_BASE=http://localhost:8000    # FastAPI cloud server
VITE_EDGE_API_BASE=http://localhost:8001      # Edge device HTTP API the UI should talk to
```

Set `VITE_EDGE_API_BASE` to `http://localhost:8002` if you want to observe the second branch instead.

### Cloud server `.env` (inside `be/`)

Key options from `be/.env.example`:

```ini
DATABASE_URL=postgresql://admin:admin123@postgres:5432/retail_db
REDIS_URL=redis://redis:6379
MQTT_BROKER=mosquitto
DATA_RETENTION_DAYS=90
FL_AGGREGATION_METHOD=fedavg
JWT_SECRET_KEY=change-me
```

Most defaults already match the Docker Compose network aliases. Override when deploying to another environment.

### Edge device `.env`

```ini
BRANCH_ID=branch_001
BRANCH_NAME="Chi nhánh Quận 1"
DEVICE_ID=edge_001
CLOUD_API=http://cloud-server:8000
MQTT_BROKER=mosquitto:1883
CAMERA_MOCK=true        # disable when using a real webcam
INFERENCE_DEVICE=cpu    # cpu, cuda, tensorrt
```

Each edge container (or physical device) needs its own identity and cloud credentials. Branch 2 is configured via Compose env overrides.

---

## Backend Stack Breakdown

| Service         | Purpose & Port                                                    | How to check                                          |
| --------------- | ----------------------------------------------------------------- | ----------------------------------------------------- |
| `cloud-server`  | FastAPI app on `:8000` for transactions, consent, model mgmt      | `curl http://localhost:8000/health`                   |
| `edge-device-1` | Branch 1 simulator exposing `:8001` (`/face/identify`, `/health`) | `curl http://localhost:8001/health`                   |
| `edge-device-2` | Branch 2 simulator at host `:8002`                                | `curl http://localhost:8002/health`                   |
| `mosquitto`     | MQTT broker `1883/9001` for telemetry                             | `docker logs mqtt-broker`                             |
| `postgres`      | Transaction storage                                               | `docker exec postgres-db psql -U admin -c "SELECT 1"` |
| `redis`         | Cache/event buffer                                                | `docker exec redis-cache redis-cli ping`              |
| `prometheus`    | Metrics scrape `:9090`                                            | `curl http://localhost:9090/-/healthy`                |
| `grafana`       | Dashboards `:3000`                                                | Login `admin/admin`                                   |

Docker volumes `be/data`, `mqtt-data`, `postgres-data`, etc. keep state between runs.

---

## Frontend Development Workflow

1. Install deps at repo root: `npm install`.
2. Start Vite dev server: `npm run dev -- --host`.
3. Camera widget:
   - Browsers require HTTPS or `localhost` to grant camera permission.
   - When no webcam is available, enable the mock mode on the edge device (`CAMERA_MOCK=true`) so it replays stored frames.
4. API client modules live in `src/core/api`. They read the `VITE_*` URLs once on boot, so restart Vite after editing `.env`.
5. Production build: `npm run build` (outputs to `dist/`). Preview locally with `npm run preview`.

---

## Running Services Outside Docker (optional)

### Cloud server

```bash
cd be/cloud-server
python -m venv .venv && source .venv/Scripts/activate   # or bin/activate on mac/linux
pip install -r requirements.txt
cp ../.env.example .env && edit values
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### Edge device

```bash
cd be/edge-device
python -m venv .venv && source .venv/Scripts/activate
pip install -r requirements.txt
cp .env.example .env
python main.py
```

Point `CLOUD_API`, `REDIS_URL`, and `MQTT_BROKER` to the services you want the device to talk to. Real hardware can be swapped in by turning `CAMERA_MOCK` off and configuring `CAMERA_INDEX`.

---

## Monitoring & Verification

- **Grafana** dashboards are pre-provisioned in `be/monitoring/grafana`. Branch KPIs, model performance, and federated learning progress are available after a few minutes of data.
- **Prometheus** scrapes the cloud + edges. Custom metrics (e.g., `edge_inference_latency_seconds`, `edge_recommendations_total`) are visible at http://localhost:9090/graph.
- **Health scripts**
  - `be/full_verification.sh` – Runs end-to-end checks (Docker services, cloud health, MQTT, DB, edge telemetry, Prometheus, Grafana). Re-run after the stack is up to confirm readiness.
  - `be/verify_api.sh` – Quick smoke test for health, transactions, branches, and metrics summary.

---

## Useful Commands

- Tail logs for one service: `cd be && docker compose logs -f cloud-server`.
- Rebuild everything after backend changes: `docker compose up -d --build`.
- Reset persistent data (dangerous): `docker compose down -v && rm -rf data postgres-data mqtt-data`.
- List active containers: `docker compose ps`.
- Inspect metrics from an edge device: `curl http://localhost:8001/metrics`.

---

## Troubleshooting

- **Port already in use** – Stop any process using 5173/8000/8001/5432/etc., or change the exposed ports in `be/docker-compose.yml`.
- **Cloud server unhealthy** – Check `.env` (DB/MQTT URLs), then run `docker compose logs -f cloud-server`.
- **Edge device not producing data** – Ensure MQTT and Redis are reachable, give it ~30 seconds, and watch logs with `docker compose logs -f edge-device-1`.
- **Frontend cannot reach APIs** – Confirm `.env` URLs match the ports exposed on your machine and that Vite was restarted after changes.
- **Camera not accessible** – Use Chrome/Edge on `https://localhost` or allow camera permissions. For headless demos, enable `CAMERA_MOCK=true` on the edge devices.
- **Grafana login fails** – The default credentials are `admin/admin`. If overridden, inspect `GF_SECURITY_ADMIN_PASSWORD` in Compose.

---

## Next Steps

- Customize the data and model files stored under `be/data/` & `be/edge-device/models/`.
- Extend the React UI (pages live in `src/pages`) to surface more APIs (consent, FL rounds, etc.).
- Wire CI to run `npm run build` and `docker compose build` to ensure future changes keep the stack healthy.

Enjoy hacking on SMCS!
