# Deployment Guide

This repo now has two deployment targets:

- Cloud stack: `docker-compose.cloud.yml`
- Edge device stack: `docker-compose.edge.yml`

Keep using `docker-compose.yml` only if you want the older all-in-one local demo.

## 1. Local Development On One Machine

Use `localhost` when frontend, cloud, MQTT, Redis, database, and edge all run on the same machine.

From `be/`:

```bash
cp .env.example .env
cp edge-device/.env.docker.example edge-device/.env
docker compose -f docker-compose.cloud.yml up -d --build
docker compose -f docker-compose.edge.yml up -d --build
```

Frontend root `.env`:

```env
VITE_SERVER_API_BASE=http://localhost:8000
VITE_EDGE_API_BASE=http://localhost:8001
```

Edge `be/edge-device/.env` for local development with Docker:

```env
CLOUD_API=http://host.docker.internal:8000
MQTT_BROKER=host.docker.internal
MQTT_PORT=1883
```

If you run `python main.py` directly on the same machine instead of Docker, use `localhost`.

## 2. Cloud Server Deployment

Run this on the machine that will host PostgreSQL, Redis, MQTT, Cloud API, Prometheus, and Grafana.

From `be/`:

```bash
cp .env.example .env
```

Edit `.env` and change at least:

```env
POSTGRES_PASSWORD=your-strong-password
JWT_SECRET_KEY=your-long-random-secret
ADMIN_API_KEY=your-admin-key
GRAFANA_ADMIN_PASSWORD=your-grafana-password
```

Start cloud services:

```bash
docker compose -f docker-compose.cloud.yml up -d --build
```

Check services:

```bash
docker compose -f docker-compose.cloud.yml ps
```

Default cloud URLs:

```text
Cloud API:  http://<CLOUD_IP>:8000
MQTT:       <CLOUD_IP>:1883
Grafana:    http://<CLOUD_IP>:3000
Prometheus: http://<CLOUD_IP>:9090
```

## 3. Raspberry Pi Edge Deployment

Run this on the Raspberry Pi.

Install Docker:

```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
```

Log out and log in again, then prepare edge env:

```bash
cd fbrs_system/be
cp edge-device/.env.docker.example edge-device/.env
```

Edit `edge-device/.env`:

```env
BRANCH_ID=branch_001
BRANCH_NAME=Raspberry Pi Branch
DEVICE_ID=raspi_edge_001

API_HOST=0.0.0.0
API_PORT=8001

CLOUD_API=http://<CLOUD_IP>:8000
MQTT_BROKER=<CLOUD_IP>
MQTT_PORT=1883

CAMERA_ENABLED=true
CAMERA_MOCK=false
```

When edge and cloud are on different machines, do not use `localhost` for `CLOUD_API` or `MQTT_BROKER`. `localhost` would point back to the Raspberry Pi.

Start edge:

```bash
docker compose -f docker-compose.edge.yml up -d --build
```

## 4. Model Files

Do not commit local model artifacts to normal Git:

- `*.onnx`
- `*.pth`
- `*.pt`
- `*.ckpt`

Place runtime models manually under:

```text
be/edge-device/models/
```

For Raspberry Pi inference, ONNX is usually easier to deploy than PyTorch checkpoints.

## 5. Connectivity Checks

From Raspberry Pi:

```bash
ping <CLOUD_IP>
curl http://<CLOUD_IP>:8000/health
```

From the cloud machine or frontend machine:

```bash
ping <RASPBERRY_PI_IP>
curl http://<RASPBERRY_PI_IP>:8001/health
```

MQTT check:

```bash
mosquitto_sub -h <CLOUD_IP> -p 1883 -t "retail/#"
```

## 6. Useful Commands

Cloud logs:

```bash
docker compose -f docker-compose.cloud.yml logs -f cloud-server
```

Edge logs:

```bash
docker compose -f docker-compose.edge.yml logs -f edge-device
```

Stop cloud:

```bash
docker compose -f docker-compose.cloud.yml down
```

Stop edge:

```bash
docker compose -f docker-compose.edge.yml down
```
