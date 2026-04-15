from fastapi import APIRouter, HTTPException, Depends
from typing import Optional
from datetime import datetime, timedelta
from pydantic import BaseModel, ConfigDict
from sqlalchemy.orm import Session
from database.db import SessionLocal
from fastapi.concurrency import run_in_threadpool
from database.models import (
    CustomerConsent,
    PrivacyAuditLog,
    Customer,
    FaceEmbedding,
    Recommendation,
    Transaction,
)
import logging

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v1/consent", tags=["privacy"])


# Database dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# Pydantic models
class ConsentRequest(BaseModel):
    customer_id: str
    face_recognition_consent: bool = False
    data_collection_consent: bool = False
    marketing_consent: bool = False
    consent_method: str = "kiosk"  # kiosk, mobile, staff
    consent_location: Optional[str] = None
    ip_address: Optional[str] = None


class ConsentResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    customer_id: str
    face_recognition_consent: bool
    data_collection_consent: bool
    marketing_consent: bool
    opted_out: bool
    created_at: datetime


class OptOutRequest(BaseModel):
    customer_id: str
    reason: Optional[str] = None


class DataDeletionRequest(BaseModel):
    customer_id: str
    reason: str


# ============ Consent Management Endpoints ============


@router.post("/opt-in", response_model=ConsentResponse)
async def opt_in(request: ConsentRequest, db: Session = Depends(get_db)):
    """Customer opts in for data collection and processing"""
    from fastapi.concurrency import run_in_threadpool

    def create_consent():
        # Check if consent already exists
        consent = (
            db.query(CustomerConsent)
            .filter(CustomerConsent.customer_id == request.customer_id)
            .first()
        )

        if consent:
            # Update existing consent
            consent.face_recognition_consent = request.face_recognition_consent
            consent.data_collection_consent = request.data_collection_consent
            consent.marketing_consent = request.marketing_consent
            consent.opted_out = False
            consent.opted_out_at = None
            consent.updated_at = datetime.now()
        else:
            # Create new consent
            from config import get_settings

            settings = get_settings()

            consent = CustomerConsent(
                customer_id=request.customer_id,
                face_recognition_consent=request.face_recognition_consent,
                data_collection_consent=request.data_collection_consent,
                marketing_consent=request.marketing_consent,
                consent_method=request.consent_method,
                consent_ip_address=request.ip_address,
                consent_location=request.consent_location,
                data_retention_until=datetime.now()
                + timedelta(days=settings.DATA_RETENTION_DAYS),
            )
            db.add(consent)

        # Log the consent action
        audit_log = PrivacyAuditLog(
            customer_id=request.customer_id,
            operation_type="consent_given",
            operation_details={
                "face_recognition": request.face_recognition_consent,
                "data_collection": request.data_collection_consent,
                "marketing": request.marketing_consent,
            },
            performed_by=request.customer_id,
            performed_by_role="customer",
            ip_address=request.ip_address,
        )
        db.add(audit_log)

        db.commit()
        db.refresh(consent)

        return consent

    consent = await run_in_threadpool(create_consent)

    logger.info(f"Consent recorded for customer {request.customer_id}")

    return consent


@router.post("/opt-out")
async def opt_out(request: OptOutRequest, db: Session = Depends(get_db)):
    """Customer opts out of data collection"""
    from fastapi.concurrency import run_in_threadpool

    def update_consent():
        consent = (
            db.query(CustomerConsent)
            .filter(CustomerConsent.customer_id == request.customer_id)
            .first()
        )

        if not consent:
            raise HTTPException(
                status_code=404,
                detail=f"No consent record found for customer {request.customer_id}",
            )

        # Update consent
        consent.opted_out = True
        consent.opted_out_at = datetime.now()
        consent.opt_out_reason = request.reason
        consent.face_recognition_consent = False
        consent.data_collection_consent = False
        consent.marketing_consent = False

        # Log the opt-out action
        audit_log = PrivacyAuditLog(
            customer_id=request.customer_id,
            operation_type="consent_withdrawn",
            operation_details={"reason": request.reason},
            performed_by=request.customer_id,
            performed_by_role="customer",
        )
        db.add(audit_log)

        db.commit()

        return consent

    consent = await run_in_threadpool(update_consent)

    logger.info(f"Customer {request.customer_id} opted out")

    return {
        "status": "success",
        "customer_id": request.customer_id,
        "message": "You have been opted out. Your data will be anonymized.",
    }


@router.get("/{customer_id}", response_model=ConsentResponse)
async def get_consent(customer_id: str, db: Session = Depends(get_db)):
    """Get customer consent status"""

    def query_consent():
        return (
            db.query(CustomerConsent)
            .filter(CustomerConsent.customer_id == customer_id)
            .first()
        )

    consent = await run_in_threadpool(query_consent)

    if not consent:
        raise HTTPException(
            status_code=404,
            detail=f"No consent record found for customer {customer_id}",
        )

    return consent


@router.delete("/data/{customer_id}")
async def delete_customer_data(
    customer_id: str, request: DataDeletionRequest, db: Session = Depends(get_db)
):
    """Delete all customer data (GDPR Right to be Forgotten)"""
    from fastapi.concurrency import run_in_threadpool

    def delete_data():
        deleted_records = {}

        # Delete face embeddings
        face_count = (
            db.query(FaceEmbedding)
            .filter(FaceEmbedding.customer_id == customer_id)
            .delete(synchronize_session=False)
        )
        deleted_records["face_embeddings"] = face_count

        # Anonymize transactions (keep for analytics but remove customer link)
        transaction_count = (
            db.query(Transaction)
            .filter(Transaction.customer_id == customer_id)
            .update({"customer_id": "DELETED_USER"}, synchronize_session=False)
        )
        deleted_records["transactions"] = transaction_count

        # Anonymize recommendations
        rec_count = (
            db.query(Recommendation)
            .filter(Recommendation.customer_id == customer_id)
            .update(
                {"customer_id": "DELETED_USER", "face_attributes": {}},
                synchronize_session=False,
            )
        )
        deleted_records["recommendations"] = rec_count

        # Delete customer profile
        customer_count = (
            db.query(Customer)
            .filter(Customer.customer_id == customer_id)
            .delete(synchronize_session=False)
        )
        deleted_records["customer_profile"] = customer_count

        # Update consent record
        consent = (
            db.query(CustomerConsent)
            .filter(CustomerConsent.customer_id == customer_id)
            .first()
        )

        if consent:
            consent.opted_out = True
            consent.opted_out_at = datetime.now()
            consent.opt_out_reason = request.reason

        # Log the deletion
        audit_log = PrivacyAuditLog(
            customer_id=customer_id,
            operation_type="data_deleted",
            operation_details={
                "reason": request.reason,
                "deleted_records": deleted_records,
            },
            performed_by=customer_id,
            performed_by_role="customer",
            success=True,
        )
        db.add(audit_log)

        db.commit()

        return deleted_records

    try:
        deleted = await run_in_threadpool(delete_data)

        logger.info(f"Deleted data for customer {customer_id}: {deleted}")

        return {
            "status": "success",
            "customer_id": customer_id,
            "message": "All personal data has been deleted or anonymized",
            "deleted_records": deleted,
        }

    except Exception as e:
        logger.error(f"Error deleting customer data: {e}")

        # Log failed deletion attempt
        def log_failure():
            audit_log = PrivacyAuditLog(
                customer_id=customer_id,
                operation_type="data_deleted",
                operation_details={"reason": request.reason},
                performed_by=customer_id,
                performed_by_role="customer",
                success=False,
                error_message=str(e),
            )
            db.add(audit_log)
            db.commit()

        await run_in_threadpool(log_failure)

        raise HTTPException(
            status_code=500, detail=f"Failed to delete customer data: {str(e)}"
        )


@router.get("/audit/{customer_id}")
async def get_audit_log(
    customer_id: str, limit: int = 50, db: Session = Depends(get_db)
):
    """Get privacy audit log for a customer"""
    from fastapi.concurrency import run_in_threadpool

    def query_logs():
        return (
            db.query(PrivacyAuditLog)
            .filter(PrivacyAuditLog.customer_id == customer_id)
            .order_by(PrivacyAuditLog.timestamp.desc())
            .limit(limit)
            .all()
        )

    logs = await run_in_threadpool(query_logs)

    return {
        "customer_id": customer_id,
        "total_logs": len(logs),
        "logs": [
            {
                "operation": log.operation_type,
                "timestamp": log.timestamp,
                "performed_by": log.performed_by,
                "success": log.success,
                "details": log.operation_details,
            }
            for log in logs
        ],
    }
