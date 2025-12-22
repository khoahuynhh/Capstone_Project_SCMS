import json
import os
import signal
import sys
import time
from typing import Any, Dict

from kafka import KafkaConsumer
from kafka.errors import KafkaError
from dotenv import load_dotenv

load_dotenv()

KAFKA_BOOTSTRAP_SERVERS = os.getenv("KAFKA_BOOTSTRAP_SERVERS", "localhost:9092")
KAFKA_FACE_EVENTS_TOPIC = os.getenv("KAFKA_FACE_EVENTS_TOPIC", "face_events")
KAFKA_GROUP_ID = os.getenv("KAFKA_FACE_GROUP_ID", "face_events_group")

# Optional: control from env
AUTO_OFFSET_RESET = os.getenv("KAFKA_AUTO_OFFSET_RESET", "earliest")  # earliest|latest
POLL_TIMEOUT_MS = int(os.getenv("KAFKA_POLL_TIMEOUT_MS", "1000"))


_running = True


def _shutdown(*_):
    global _running
    _running = False
    print("\n[Consumer] Shutting down...")


def handle_face_event(event: Dict[str, Any]) -> None:
    """
    TODO: Your real business logic here.

    Examples:
    - Validate schema
    - Write to PostgreSQL (orders/history/branch_metrics)
    - Trigger downstream pipeline (e.g., publish to reco_events topic)
    """
    # Example validation
    event_type = event.get("event_type")
    branch_id = event.get("branch_id")

    if not event_type:
        raise ValueError("Missing event_type")
    if not branch_id:
        raise ValueError("Missing branch_id")

    # Simulate work
    # time.sleep(0.05)
    print(f"[Consumer]: event_type={event_type}, branch_id={branch_id}")


def main():
    # Graceful shutdown signals
    signal.signal(signal.SIGINT, _shutdown)
    signal.signal(signal.SIGTERM, _shutdown)

    consumer = KafkaConsumer(
        KAFKA_FACE_EVENTS_TOPIC,
        bootstrap_servers=KAFKA_BOOTSTRAP_SERVERS.split(","),
        value_deserializer=lambda m: json.loads(m.decode("utf-8")),
        key_deserializer=lambda k: k.decode("utf-8") if k else None,
        # IMPORTANT: manual commit for "at-least-once" processing
        enable_auto_commit=False,
        # If this group has no committed offset yet, start from:
        auto_offset_reset=AUTO_OFFSET_RESET,
        group_id=KAFKA_GROUP_ID,
        # Optional consumer tuning
        consumer_timeout_ms=1000,  # let loop break occasionally to check _running
        max_poll_records=int(os.getenv("KAFKA_MAX_POLL_RECORDS", "50")),
    )

    print(
        f"[Consumer] Listening topic={KAFKA_FACE_EVENTS_TOPIC} "
        f"servers={KAFKA_BOOTSTRAP_SERVERS} group_id={KAFKA_GROUP_ID}"
    )

    try:
        while _running:
            # Poll in batches (more controllable than 'for msg in consumer')
            records = consumer.poll(timeout_ms=POLL_TIMEOUT_MS)

            if not records:
                continue

            for tp, msgs in records.items():
                for msg in msgs:
                    event = msg.value
                    msg_key = msg.key  # already deserialized by key_deserializer

                    try:
                        # 1) Process event (DB write, etc.)
                        handle_face_event(event)

                        # 2) Commit ONLY after successful processing
                        consumer.commit()

                        # Debug info
                        print(
                            f"[Consumer] OK key={msg_key} "
                            f"topic={msg.topic} partition={msg.partition} offset={msg.offset}"
                        )

                    except Exception as e:
                        # Don't commit -> message will be re-delivered later (at-least-once)
                        print(
                            f"[Consumer] ERROR {e} | "
                            f"key={msg_key} topic={msg.topic} p={msg.partition} off={msg.offset} | event={event}"
                        )
                        # Optionally: sleep/backoff to avoid tight error loops
                        time.sleep(0.5)

    except KafkaError as e:
        print(f"[Consumer] KafkaError: {e}")
    finally:
        try:
            consumer.close()
        except Exception:
            pass
        print("[Consumer] Closed.")


if __name__ == "__main__":
    main()
