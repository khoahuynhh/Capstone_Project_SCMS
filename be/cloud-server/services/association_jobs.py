from datetime import datetime
from threading import Lock
from typing import Any
from uuid import uuid4

from database.db import SessionLocal
from services.association_mining import regenerate_product_associations


_jobs: dict[str, dict[str, Any]] = {}
_lock = Lock()
_running_job_id: str | None = None


def _now_iso() -> str:
    return datetime.utcnow().isoformat()


def start_product_association_job(
    min_support: float,
    min_confidence: float,
    min_lift: float,
    min_items_per_transaction: int,
    max_rules: int,
) -> dict[str, Any]:
    global _running_job_id

    with _lock:
        if _running_job_id:
            running = _jobs.get(_running_job_id)
            if running and running.get("status") in {"pending", "running"}:
                return {**running, "already_running": True}

        job_id = str(uuid4())
        job = {
            "job_id": job_id,
            "status": "pending",
            "created_at": _now_iso(),
            "started_at": None,
            "finished_at": None,
            "params": {
                "min_support": min_support,
                "min_confidence": min_confidence,
                "min_lift": min_lift,
                "min_items_per_transaction": min_items_per_transaction,
                "max_rules": max_rules,
            },
            "result": None,
            "error": "",
        }
        _jobs[job_id] = job
        _running_job_id = job_id
        return {**job, "already_running": False}


def run_product_association_job(job_id: str) -> None:
    global _running_job_id

    with _lock:
        job = _jobs.get(job_id)
        if not job:
            return
        job["status"] = "running"
        job["started_at"] = _now_iso()
        params = dict(job["params"])

    db = SessionLocal()
    try:
        result = regenerate_product_associations(db=db, **params)
        with _lock:
            job = _jobs[job_id]
            job["status"] = "success"
            job["finished_at"] = _now_iso()
            job["result"] = result
            job["error"] = ""
    except Exception as exc:
        db.rollback()
        with _lock:
            job = _jobs[job_id]
            job["status"] = "failed"
            job["finished_at"] = _now_iso()
            job["error"] = str(exc)
    finally:
        db.close()
        with _lock:
            if _running_job_id == job_id:
                _running_job_id = None


def get_product_association_job(job_id: str) -> dict[str, Any] | None:
    with _lock:
        job = _jobs.get(job_id)
        return job.copy() if job else None
