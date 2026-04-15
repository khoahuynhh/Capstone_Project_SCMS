from fastapi import FastAPI, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import logging
from api import routes
from services.mqtt_cloud import MQTTSubscriber
from database.db import init_db
from prometheus_client import make_asgi_app
from database.db import SessionLocal

# Configure logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

# Global MQTT subscriber
mqtt_subscriber = None


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup and shutdown events"""
    global mqtt_subscriber

    # Startup
    logger.info("Starting Cloud Server...")

    # Initialize database
    init_db()
    logger.info("Database initialized")

    # Start MQTT subscriber
    mqtt_subscriber = MQTTSubscriber()
    mqtt_subscriber.start()
    logger.info("MQTT subscriber started")

    yield

    # Shutdown
    logger.info("Shutting down Cloud Server...")
    if mqtt_subscriber:
        mqtt_subscriber.stop()


# Create FastAPI app
app = FastAPI(
    title="Edge AI Retail - Cloud Server",
    description="Central server for Edge AI retail system",
    version="1.0.0",
    lifespan=lifespan,
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount Prometheus metrics
metrics_app = make_asgi_app()
app.mount("/metrics", metrics_app)

# Include routers
app.include_router(routes.router)

# Include new API modules
from api.v1 import models as models_api
from api.v1 import consent as consent_api
from api.v1 import ab_testing
from api.v1 import federated
from api.v1 import analytics

app.include_router(models_api.router)
app.include_router(consent_api.router)
app.include_router(ab_testing.router)
app.include_router(federated.router)
app.include_router(analytics.router)


@app.get("/")
async def root():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "Edge AI Retail Cloud Server",
        "version": "1.0.0",
    }


@app.get("/health")
async def health_check():
    db_ok = False
    try:
        db = SessionLocal()
        db.execute("SELECT 1")
        db_ok = True
    except:
        db_ok = False
    finally:
        db.close()

    return {
        "status": "healthy",
        "mqtt": mqtt_subscriber.connected if mqtt_subscriber else False,
        "database": db_ok,
    }


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
