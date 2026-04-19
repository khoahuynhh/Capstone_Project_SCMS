from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from database.models import Base
from config import settings
import logging

logger = logging.getLogger(__name__)

# Database URL from settings (loads from .env via pydantic_settings)
DATABASE_URL = settings.DATABASE_URL
if not DATABASE_URL:
    raise RuntimeError("DATABASE_URL is not set (set env or be/.env)")

# Create engine
engine = create_engine(DATABASE_URL, pool_pre_ping=True, pool_size=10, max_overflow=20)

# Create session factory
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def init_db():
    """Initialize database tables"""
    try:
        with engine.begin() as conn:
            conn.execute(text("CREATE EXTENSION IF NOT EXISTS vector"))
        Base.metadata.create_all(bind=engine)
        logger.info("Database tables created successfully")
    except Exception as e:
        logger.error(f"Error creating database tables: {e}")
        raise


def get_db():
    """Dependency for FastAPI routes"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# from sqlalchemy import create_engine
# from sqlalchemy.orm import sessionmaker
# from database.models import Base
# import os
# import logging

# logger = logging.getLogger(__name__)

# # Database URL from environment
# DATABASE_URL = os.getenv(
#     'DATABASE_URL',
#     'postgresql://admin:admin123@postgres:5432/retail_db'
# )

# # Create engine
# engine = create_engine(
#     DATABASE_URL,
#     pool_pre_ping=True,
#     pool_size=10,
#     max_overflow=20
# )

# # Create session factory
# SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# def init_db():
#     """Initialize database tables"""
#     try:
#         Base.metadata.create_all(bind=engine)
#         logger.info("Database tables created successfully")
#     except Exception as e:
#         logger.error(f"Error creating database tables: {e}")
#         raise

# def get_db():
#     """Dependency for FastAPI routes"""
#     db = SessionLocal()
#     try:
#         yield db
#     finally:
#         db.close()
