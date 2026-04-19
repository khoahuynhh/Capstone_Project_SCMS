# Deployment Guide

This guide describes the current production-oriented deployment for FBRS.

Use separate stacks:

- Cloud stack: `docker-compose.cloud.yml`
- Edge stack: `docker-compose.edge.yml`

`docker-compose.yml` is the legacy all-in-one local demo and should not be used as the main production deployment file.

## 1. Deployment Topology

```text
UI/POS
  |-- HTTP -> Edge API /face/analysis
  `-- HTTP -> Cloud API /products, /recommendations/by-attributes, /transactions

Edge Device
  |-- HTTP API for face attribute inference
  `-- MQTT -> Cloud broker for online/heartbeat/offline status

Cloud Server
  |-- FastAPI business API
  |-- PostgreSQL
  |-- Redis
  |-- Mosquitto MQTT broker
  |-- Prometheus
  `-- Grafana
```

## 2. Local End-To-End Test

From `be/`:

```powershell
Copy-Item .env.example .env
Copy-Item edge-device\.env.docker.example edge-device\.env
docker compose -f docker-compose.cloud.yml up -d --build
docker compose -f docker-compose.edge.yml up -d --build
```

From the repository root:

```powershell
Copy-Item .env.example .env
npm install
npm run dev -- --host
```

Default local URLs:

```text
UI:         http://localhost:5173
Cloud API:  http://localhost:8000
Edge API:   http://localhost:8001
Grafana:    http://localhost:3000
Prometheus: http://localhost:9090
MQTT:       localhost:1883
PostgreSQL: localhost:5433
```

## 3. Cloud Server Deployment

Run this on the cloud/server machine.

Prepare environment:

```powershell
cd be
Copy-Item .env.example .env
```

Edit `be/.env`:

```env
ENVIRONMENT=production
DEBUG=false
POSTGRES_PASSWORD=<strong-password>
DATABASE_URL=postgresql://admin:<strong-password>@postgres:5432/retail_db
JWT_SECRET=<long-random-secret>
JWT_SECRET_KEY=<long-random-secret>
ADMIN_API_KEY=<admin-api-key>
API_KEY_ENABLED=true
GRAFANA_ADMIN_PASSWORD=<grafana-password>
```

Start Cloud:

```powershell
docker compose -f docker-compose.cloud.yml up -d --build
```

Verify:

```powershell
docker compose -f docker-compose.cloud.yml ps
curl http://localhost:8000/health
```

Recommended production hardening:

- Put Cloud API and Grafana behind HTTPS.
- Do not expose PostgreSQL or Redis to the public internet.
- Restrict MQTT port `1883` to trusted edge device networks or use a VPN/private network.
- Use strong secrets and rotate them before final deployment.
- Back up PostgreSQL before any compose or server migration.

## 4. Raspberry Pi Edge Deployment

Run this on the Raspberry Pi or edge computer.

Install Docker if needed:

```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
```

Log out and log in again, then prepare the edge environment:

```bash
cd fbrs_system/be
cp edge-device/.env.docker.example edge-device/.env
```

Edit `edge-device/.env`:

```env
BRANCH_ID=HCM_Q1
BRANCH_NAME=Mart Quan 1
DEVICE_ID=EDGE_HCM_Q1_01
API_HOST=0.0.0.0
API_PORT=8001
MODEL_STORAGE_PATH=./models
INFERENCE_DEVICE=cpu
HEARTBEAT_ENABLED=true
HEARTBEAT_INTERVAL=60
MQTT_BROKER=<cloud-server-ip-or-dns>
MQTT_PORT=1883
MQTT_KEEPALIVE=60
MQTT_QOS=1
```

Place the model file:

```text
be/edge-device/models/best_model.pth
```

Start Edge:

```bash
docker compose -f docker-compose.edge.yml up -d --build
```

Verify from the Raspberry Pi:

```bash
curl http://localhost:8001/health
```

Verify from the UI/POS or Cloud network:

```bash
curl http://<EDGE_IP>:8001/health
```

## 5. UI/POS Deployment

The UI needs access to both Cloud and Edge:

```env
VITE_SERVER_API_BASE=http://<cloud-ip-or-domain>:8000
VITE_EDGE_API_BASE=http://<edge-ip-or-domain>:8001
VITE_BRANCH_ID=HCM_Q1
VITE_DEVICE_ID=EDGE_HCM_Q1_01
```

Build:

```powershell
npm run build
```

Deploy the generated `dist/` folder using your chosen static hosting or kiosk/POS runtime.

## 6. Database Backup And Migration

Create a backup from the current PostgreSQL container:

```powershell
python cloud-server\scripts\export_postgres.py
```

Or choose a specific output path:

```powershell
python cloud-server\scripts\export_postgres.py --output cloud-server\data\backups\retail_db_backup.sql --overwrite
```

Restore to a new server after PostgreSQL is running:

```powershell
Get-Content .\cloud-server\data\backups\retail_db_backup.sql | docker exec -i postgres-db psql -U admin -d retail_db
```

Do not run:

```powershell
docker compose down -v
```

unless you intentionally want to delete Docker volumes, including PostgreSQL data.

## 7. Connectivity Checks

From Edge to Cloud:

```bash
ping <cloud-ip>
nc -vz <cloud-ip> 1883
```

From UI/POS to Cloud:

```bash
curl http://<cloud-ip>:8000/health
```

From UI/POS to Edge:

```bash
curl http://<edge-ip>:8001/health
```

MQTT heartbeat check:

```bash
mosquitto_sub -h <cloud-ip> -p 1883 -t "retail/#"
```

## 8. Operational Commands

Cloud logs:

```powershell
docker compose -f docker-compose.cloud.yml logs -f cloud-server
```

Edge logs:

```powershell
docker compose -f docker-compose.edge.yml logs -f edge-device
```

Stop Cloud without deleting data:

```powershell
docker compose -f docker-compose.cloud.yml down
```

Stop Edge:

```powershell
docker compose -f docker-compose.edge.yml down
```
