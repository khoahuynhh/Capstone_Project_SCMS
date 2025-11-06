#!/bin/bash

echo "==================================="
echo "Edge AI Retail System - Startup"
echo "==================================="

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running!"
    exit 1
fi

# Create necessary directories
echo "Creating directories..."
mkdir -p data/transactions data/embeddings data/models
mkdir -p mqtt-broker monitoring/grafana/dashboards

# Create mosquitto.conf if not exists
if [ ! -f mqtt-broker/mosquitto.conf ]; then
    echo "Creating mosquitto.conf..."
    cat > mqtt-broker/mosquitto.conf << 'EOFMQTT'
listener 1883
allow_anonymous true
persistence true
persistence_location /mosquitto/data/
log_dest file /mosquitto/log/mosquitto.log
log_dest stdout

listener 9001
protocol websockets
EOFMQTT
fi

# Build and start services
echo "Building Docker images..."
docker compose build

echo "Starting services..."
docker compose up -d

# Wait for services to be ready
echo "Waiting for services to start..."
sleep 10

# Check service status
echo ""
echo "==================================="
echo "Service Status:"
echo "==================================="
docker compose ps

echo ""
echo "==================================="
echo "Access Points:"
echo "==================================="
echo "Cloud Server API:      http://localhost:8000"
echo "API Documentation:     http://localhost:8000/docs"
echo "Grafana Dashboard:     http://localhost:3000 (admin/admin)"
echo "Prometheus:            http://localhost:9090"
echo "MQTT Broker:           localhost:1883"
echo "PostgreSQL:            localhost:5432"

echo ""
echo "==================================="
echo "Logs:"
echo "==================================="
echo "View all logs:       docker compose logs -f"
echo "Cloud server logs:   docker compose logs -f cloud-server"
echo "Edge device 1 logs:  docker compose logs -f edge-device-1"
echo "Edge device 2 logs:  docker compose logs -f edge-device-2"

echo ""
echo "==================================="
echo "To stop the system:"
echo "docker compose down"
echo "==================================="

