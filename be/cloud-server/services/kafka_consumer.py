import json
import os
from kafka import KafkaConsumer

from dotenv import load_dotenv

load_dotenv()

KAFKA_BOOTSTRAP_SERVERS = os.getenv("KAFKA_BOOTSTRAP_SERVERS", "localhost:9092")
KAFKA_FACE_EVENTS_TOPIC = os.getenv("KAFKA_FACE_EVENTS_TOPIC", "face_events")


def main():
    consumer = KafkaConsumer(
        KAFKA_FACE_EVENTS_TOPIC,
        bootstrap_servers=KAFKA_BOOTSTRAP_SERVERS.split(","),
        value_deserializer=lambda m: json.loads(m.decode("utf-8")),
        auto_offset_reset="earliest",  # hoặc "latest"
        enable_auto_commit=True,
        group_id="face_events_group",
    )

    print(f"[Consumer] Listening on topic={KAFKA_FACE_EVENTS_TOPIC}")

    for msg in consumer:
        event = msg.value
        print("[Consumer] Received event:", event)

        # TODO: xử lý event:
        # - ghi vào PostgreSQL / MongoDB
        # - cập nhật bảng history
        # - bắn tiếp sang recommendation-service, v.v.


if __name__ == "__main__":
    main()
