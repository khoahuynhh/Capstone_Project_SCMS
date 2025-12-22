# modules/kafka_client.py

import json
import os
import threading
import time
from typing import Any, Dict, Optional, List

from kafka import KafkaProducer
from kafka.errors import KafkaError


def _env(name: str, default: str) -> str:
    """Read env var with a fallback default (trim whitespace)."""
    v = os.getenv(name)
    return v.strip() if v and v.strip() else default


class EdgeKafkaProducer:
    """
    Kafka producer for edge devices with simple store-and-forward.

    If Kafka send fails, events are persisted to a local JSONL queue file.
    Later, you can call drain_local_queue() to resend queued events.
    """

    def __init__(
        self,
        bootstrap_servers: Optional[str] = None,
        topic_face_events: Optional[str] = None,
        client_id: Optional[str] = None,
        default_branch_id: Optional[str] = None,
        offline_queue_path: Optional[str] = None,
    ):
        # Kafka configs
        self.bootstrap_servers = (
            bootstrap_servers or _env("KAFKA_BOOTSTRAP_SERVERS", "localhost:9092")
        ).split(",")
        self.topic_face_events = topic_face_events or _env(
            "KAFKA_FACE_EVENTS_TOPIC", "face_events"
        )
        self.client_id = client_id or _env("KAFKA_CLIENT_ID", "edge-producer")
        self.default_branch_id = default_branch_id or _env("BRANCH_ID", "unknown")

        # Local offline queue (JSONL): one JSON object per line
        self.offline_queue_path = offline_queue_path or _env(
            "KAFKA_OFFLINE_QUEUE_PATH", "./kafka_offline_queue.jsonl"
        )

        # A process-wide lock to avoid concurrent writes/reads to the queue file
        self._queue_lock = threading.Lock()

        # Producer configuration tuned for edge
        self.producer = KafkaProducer(
            bootstrap_servers=self.bootstrap_servers,
            client_id=self.client_id,
            key_serializer=lambda k: str(k).encode("utf-8"),
            value_serializer=lambda v: json.dumps(v, ensure_ascii=False).encode(
                "utf-8"
            ),
            acks="all",
            retries=int(_env("KAFKA_RETRIES", "10")),
            retry_backoff_ms=int(_env("KAFKA_RETRY_BACKOFF_MS", "300")),
            request_timeout_ms=int(_env("KAFKA_REQUEST_TIMEOUT_MS", "15000")),
            max_block_ms=int(_env("KAFKA_MAX_BLOCK_MS", "15000")),
            linger_ms=int(_env("KAFKA_LINGER_MS", "10")),
            batch_size=int(_env("KAFKA_BATCH_SIZE", "32768")),
            compression_type=_env("KAFKA_COMPRESSION", "gzip"),
        )

    # -------------------- public API --------------------

    def publish_face_event(
        self, event: Dict[str, Any], *, key: Optional[str] = None
    ) -> bool:
        """
        Publish a face event asynchronously.

        Returns True if the message was accepted into producer buffer.
        If delivery fails later, _on_send_error will persist the event locally.
        """
        if not isinstance(event, dict):
            raise TypeError("event must be a dict (JSON-serializable)")

        event.setdefault("branch_id", self.default_branch_id)

        msg_key = key or str(event.get("branch_id") or self.default_branch_id)

        try:
            future = self.producer.send(
                self.topic_face_events, key=msg_key, value=event
            )
            future.add_callback(self._on_send_success)
            future.add_errback(self._on_send_error, event=event, msg_key=msg_key)
            return True
        except KafkaError as e:
            # Immediate client-side failure -> persist locally right away
            self._persist_offline(
                event, msg_key=msg_key, reason=f"send() immediate error: {e}"
            )
            return False

    def publish_face_event_sync(
        self,
        event: Dict[str, Any],
        *,
        key: Optional[str] = None,
        timeout: float = 5.0,
    ) -> bool:
        """
        Publish a face event synchronously (blocking) and wait for broker ack.
        If it fails, persist locally.
        """
        if not isinstance(event, dict):
            raise TypeError("event must be a dict (JSON-serializable)")

        event.setdefault("branch_id", self.default_branch_id)
        msg_key = key or str(event.get("branch_id") or self.default_branch_id)

        try:
            future = self.producer.send(
                self.topic_face_events, key=msg_key, value=event
            )
            _ = future.get(timeout=timeout)
            return True
        except KafkaError as e:
            self._persist_offline(
                event, msg_key=msg_key, reason=f"sync publish error: {e}"
            )
            return False

    def drain_local_queue(
        self,
        *,
        max_events: int = 200,
        per_event_timeout: float = 3.0,
        backoff_seconds: float = 0.2,
    ) -> int:
        """
        Try to resend events stored in the offline JSONL queue.

        Strategy (simple + safe):
        - Read up to max_events from queue file.
        - Attempt to send them synchronously (wait for ack).
        - If sending succeeds: remove them from queue file.
        - If sending fails: stop early (Kafka likely still down), keep remaining.

        Returns: number of events successfully resent and removed from local queue.
        """
        with self._queue_lock:
            if not os.path.exists(self.offline_queue_path):
                return 0

            # Read all lines (could optimize further, but ok for small edge queue)
            with open(self.offline_queue_path, "r", encoding="utf-8") as f:
                lines = f.readlines()

            if not lines:
                return 0

            # Parse up to max_events
            batch_lines = lines[:max_events]
            remaining_lines = lines[max_events:]

            parsed: List[Dict[str, Any]] = []
            for line in batch_lines:
                line = line.strip()
                if not line:
                    continue
                try:
                    parsed.append(json.loads(line))
                except json.JSONDecodeError:
                    # Corrupted line: skip it (or you can move to a dead-letter file)
                    continue

        # NOTE: we release the lock while sending to avoid blocking concurrent app publishes too long
        sent_count = 0
        kept_from_batch: List[str] = []

        for item in parsed:
            # Each stored item contains: event, msg_key, meta...
            event = item.get("event")
            msg_key = item.get("msg_key") or str(
                (event or {}).get("branch_id") or self.default_branch_id
            )

            if not isinstance(event, dict):
                # Keep it (or drop it). We'll keep to be safe.
                kept_from_batch.append(json.dumps(item, ensure_ascii=False) + "\n")
                continue

            ok = self.publish_face_event_sync(
                event, key=msg_key, timeout=per_event_timeout
            )
            if ok:
                sent_count += 1
                time.sleep(backoff_seconds)  # tiny pacing
            else:
                # Kafka likely still not available -> keep this and the rest (stop)
                kept_from_batch.append(json.dumps(item, ensure_ascii=False) + "\n")
                # also keep remaining not-yet-sent items from batch
                idx = parsed.index(item)
                for rest in parsed[idx + 1 :]:
                    kept_from_batch.append(json.dumps(rest, ensure_ascii=False) + "\n")
                break

        # Rewrite queue file: kept_from_batch + remaining_lines (that we didn't even try)
        with self._queue_lock:
            new_lines = kept_from_batch + remaining_lines
            if new_lines:
                with open(self.offline_queue_path, "w", encoding="utf-8") as f:
                    f.writelines(new_lines)
            else:
                # Queue fully drained
                try:
                    os.remove(self.offline_queue_path)
                except OSError:
                    pass

        return sent_count

    def flush(self, timeout: float = 10.0) -> None:
        """Force sending all buffered Kafka messages."""
        self.producer.flush(timeout=timeout)

    def close(self, timeout: float = 10.0) -> None:
        """Gracefully shutdown producer."""
        try:
            self.producer.flush(timeout=timeout)
        finally:
            self.producer.close(timeout=timeout)

    # -------------------- callbacks --------------------

    @staticmethod
    def _on_send_success(record_metadata):
        """Called when a message is successfully delivered to Kafka."""
        # Uncomment for debugging:
        # print(f"[KafkaProducer] sent topic={record_metadata.topic} "
        #       f"partition={record_metadata.partition} offset={record_metadata.offset}")
        pass

    def _on_send_error(
        self, excp: BaseException, *, event: Dict[str, Any], msg_key: str
    ):
        """
        Called when Kafka delivery fails (async failure).

        Store-and-forward implementation:
        - Persist the event to a local JSONL file so it can be resent later.
        """
        reason = f"async delivery error: {excp}"
        self._persist_offline(event, msg_key=msg_key, reason=reason)

    # -------------------- offline persistence --------------------

    def _persist_offline(
        self, event: Dict[str, Any], *, msg_key: str, reason: str
    ) -> None:
        """
        Append a failed event to the offline queue file (JSONL).

        Each line is a JSON object with:
        - event: original event dict
        - msg_key: Kafka key used for partitioning
        - ts: local timestamp
        - reason: why it was queued
        """
        payload = {
            "ts": time.time(),
            "reason": reason,
            "msg_key": msg_key,
            "event": event,
        }

        try:
            os.makedirs(os.path.dirname(self.offline_queue_path) or ".", exist_ok=True)
            line = json.dumps(payload, ensure_ascii=False) + "\n"
            with self._queue_lock:
                with open(self.offline_queue_path, "a", encoding="utf-8") as f:
                    f.write(line)
            print(
                f"[KafkaProducer] queued offline -> {self.offline_queue_path} | "
                f"branch={event.get('branch_id')} event_type={event.get('event_type')} | {reason}"
            )
        except Exception as e:
            # Last-resort: if we cannot persist offline, at least print the event
            print(
                f"[KafkaProducer] FAILED to persist offline queue: {e} | event={event}"
            )
