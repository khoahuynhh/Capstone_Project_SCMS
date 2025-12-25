# kafka_producer.py (CLOUD version)

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


class CloudKafkaProducer:
    """
    Kafka producer for CLOUD services.

    Default behavior (recommended on cloud):
      - publish to Kafka (fast, reliable)
      - if send fails: return False (and you can retry upstream)

    Optional:
      - enable_offline_queue=True to store failed events into a JSONL file
        (useful for extreme safety; usually unnecessary on stable cloud infra)
    """

    def __init__(
        self,
        bootstrap_servers: Optional[str] = None,
        client_id: Optional[str] = None,
        default_branch_id: Optional[str] = None,
        # topics
        topic_face_events: Optional[str] = None,
        topic_transactions: Optional[str] = None,
        topic_recommendations: Optional[str] = None,
        topic_metrics: Optional[str] = None,
        topic_events: Optional[str] = None,
        # offline queue (optional)
        enable_offline_queue: Optional[bool] = None,
        offline_queue_path: Optional[str] = None,
    ):
        self.bootstrap_servers = (
            bootstrap_servers or _env("KAFKA_BOOTSTRAP_SERVERS", "localhost:9092")
        ).split(",")

        self.client_id = client_id or _env("KAFKA_CLIENT_ID", "cloud-producer")
        self.default_branch_id = default_branch_id or _env("BRANCH_ID", "unknown")

        # Topics (separate topics are optional; keep defaults simple)
        self.topic_face_events = topic_face_events or _env(
            "KAFKA_FACE_EVENTS_TOPIC", "face_events"
        )
        self.topic_transactions = topic_transactions or _env(
            "KAFKA_TRANSACTIONS_TOPIC", "transactions"
        )
        self.topic_recommendations = topic_recommendations or _env(
            "KAFKA_RECOMMENDATIONS_TOPIC", "recommendations"
        )
        self.topic_metrics = topic_metrics or _env("KAFKA_METRICS_TOPIC", "metrics")
        self.topic_events = topic_events or _env("KAFKA_EVENTS_TOPIC", "events")

        # Offline queue is OFF by default on cloud
        self.enable_offline_queue = (
            enable_offline_queue
            if enable_offline_queue is not None
            else _env("KAFKA_ENABLE_OFFLINE_QUEUE", "0")
            in ("1", "true", "TRUE", "yes", "YES")
        )
        self.offline_queue_path = offline_queue_path or _env(
            "KAFKA_OFFLINE_QUEUE_PATH", "./kafka_offline_queue.jsonl"
        )
        self._queue_lock = threading.Lock()

        # Producer configuration tuned for cloud
        # Notes:
        # - acks="all" + retries makes delivery robust
        # - linger_ms/batch_size improves throughput
        # - request_timeout/max_block_ms avoid hanging too long
        self.producer = KafkaProducer(
            bootstrap_servers=self.bootstrap_servers,
            client_id=self.client_id,
            key_serializer=lambda k: str(k).encode("utf-8"),
            value_serializer=lambda v: json.dumps(v, ensure_ascii=False).encode(
                "utf-8"
            ),
            acks="all",
            retries=int(_env("KAFKA_RETRIES", "10")),
            retry_backoff_ms=int(_env("KAFKA_RETRY_BACKOFF_MS", "200")),
            request_timeout_ms=int(_env("KAFKA_REQUEST_TIMEOUT_MS", "15000")),
            max_block_ms=int(_env("KAFKA_MAX_BLOCK_MS", "15000")),
            linger_ms=int(_env("KAFKA_LINGER_MS", "5")),
            batch_size=int(_env("KAFKA_BATCH_SIZE", "65536")),
            compression_type=_env("KAFKA_COMPRESSION", "gzip"),
        )

    # -------------------- public API --------------------

    def publish_event(
        self,
        topic: str,
        payload: Dict[str, Any],
        *,
        key: Optional[str] = None,
        sync: bool = False,
        timeout: float = 5.0,
    ) -> bool:
        """
        Generic publish.

        - sync=False: fire-and-forget (buffered) but still gets async error callback
        - sync=True : block until broker ack (safer, slower)
        """
        if not isinstance(payload, dict):
            raise TypeError("payload must be a dict (JSON-serializable)")

        payload.setdefault("branch_id", self.default_branch_id)
        msg_key = key or str(payload.get("branch_id") or self.default_branch_id)

        try:
            future = self.producer.send(topic, key=msg_key, value=payload)

            if sync:
                _ = future.get(timeout=timeout)
                return True

            # async callbacks
            future.add_callback(self._on_send_success)
            future.add_errback(
                self._on_send_error, payload=payload, msg_key=msg_key, topic=topic
            )
            return True

        except KafkaError as e:
            # Immediate client-side failure
            if self.enable_offline_queue:
                self._persist_offline(
                    payload, msg_key=msg_key, topic=topic, reason=f"send() error: {e}"
                )
            return False

    # Convenience wrappers (optional)
    def publish_face_event(
        self, event: Dict[str, Any], *, key: Optional[str] = None
    ) -> bool:
        return self.publish_event(self.topic_face_events, event, key=key, sync=False)

    def publish_transaction(
        self, tx: Dict[str, Any], *, key: Optional[str] = None
    ) -> bool:
        return self.publish_event(self.topic_transactions, tx, key=key, sync=False)

    def publish_recommendation(
        self, rec: Dict[str, Any], *, key: Optional[str] = None
    ) -> bool:
        return self.publish_event(self.topic_recommendations, rec, key=key, sync=False)

    def publish_metrics(
        self, metrics: Dict[str, Any], *, key: Optional[str] = None
    ) -> bool:
        return self.publish_event(self.topic_metrics, metrics, key=key, sync=False)

    def publish_custom_event(
        self, evt: Dict[str, Any], *, key: Optional[str] = None
    ) -> bool:
        return self.publish_event(self.topic_events, evt, key=key, sync=False)

    def flush(self, timeout: float = 10.0) -> None:
        self.producer.flush(timeout=timeout)

    def close(self, timeout: float = 10.0) -> None:
        try:
            self.producer.flush(timeout=timeout)
        finally:
            self.producer.close(timeout=timeout)

    # -------------------- callbacks --------------------

    @staticmethod
    def _on_send_success(record_metadata):
        # Keep silent in production; enable if you want debug logs
        # print(f"[KafkaProducer] sent topic={record_metadata.topic} "
        #       f"partition={record_metadata.partition} offset={record_metadata.offset}")
        pass

    def _on_send_error(
        self, excp: BaseException, *, payload: Dict[str, Any], msg_key: str, topic: str
    ):
        if self.enable_offline_queue:
            self._persist_offline(
                payload,
                msg_key=msg_key,
                topic=topic,
                reason=f"async delivery error: {excp}",
            )
        # If you prefer: log here (but keep it minimal to avoid noisy logs)
        # print(f"[KafkaProducer] delivery failed topic={topic} key={msg_key} err={excp}")

    # -------------------- offline persistence (optional) --------------------

    def _persist_offline(
        self, payload: Dict[str, Any], *, msg_key: str, topic: str, reason: str
    ) -> None:
        """
        Append failed payload to offline JSONL queue.

        Each line is:
          { "ts": ..., "reason": ..., "topic": ..., "msg_key": ..., "payload": {...} }
        """
        item = {
            "ts": time.time(),
            "reason": reason,
            "topic": topic,
            "msg_key": msg_key,
            "payload": payload,
        }

        try:
            os.makedirs(os.path.dirname(self.offline_queue_path) or ".", exist_ok=True)
            line = json.dumps(item, ensure_ascii=False) + "\n"
            with self._queue_lock:
                with open(self.offline_queue_path, "a", encoding="utf-8") as f:
                    f.write(line)
        except Exception:
            # last-resort: drop silently (or print if you want)
            pass

    def drain_local_queue(
        self,
        *,
        max_items: int = 200,
        per_item_timeout: float = 3.0,
        backoff_seconds: float = 0.05,
    ) -> int:
        """
        Optional: resend offline-queued items (if enable_offline_queue is used).

        Safe strategy:
          - read up to max_items
          - send sync
          - rewrite remaining
        """
        if not self.enable_offline_queue:
            return 0

        with self._queue_lock:
            if not os.path.exists(self.offline_queue_path):
                return 0

            with open(self.offline_queue_path, "r", encoding="utf-8") as f:
                lines = f.readlines()

            if not lines:
                return 0

            batch_lines = lines[:max_items]
            remaining_lines = lines[max_items:]

        parsed: List[Dict[str, Any]] = []
        for line in batch_lines:
            line = line.strip()
            if not line:
                continue
            try:
                parsed.append(json.loads(line))
            except json.JSONDecodeError:
                continue

        sent = 0
        kept: List[str] = []
        for item in parsed:
            topic = item.get("topic")
            msg_key = item.get("msg_key")
            payload = item.get("payload")

            if not (isinstance(topic, str) and isinstance(payload, dict)):
                kept.append(json.dumps(item, ensure_ascii=False) + "\n")
                continue

            ok = self.publish_event(
                topic, payload, key=msg_key, sync=True, timeout=per_item_timeout
            )
            if ok:
                sent += 1
                time.sleep(backoff_seconds)
            else:
                # keep this + rest, stop early
                kept.append(json.dumps(item, ensure_ascii=False) + "\n")
                idx = parsed.index(item)
                for rest in parsed[idx + 1 :]:
                    kept.append(json.dumps(rest, ensure_ascii=False) + "\n")
                break

        with self._queue_lock:
            new_lines = kept + remaining_lines
            if new_lines:
                with open(self.offline_queue_path, "w", encoding="utf-8") as f:
                    f.writelines(new_lines)
            else:
                try:
                    os.remove(self.offline_queue_path)
                except OSError:
                    pass

        return sent
