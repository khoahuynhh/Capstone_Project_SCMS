# modules/kafka_client.py

import json
import os
from typing import Dict, Any, Optional

from kafka import KafkaProducer


class EdgeKafkaProducer:
    """
    Kafka producer chạy trên Raspberry Pi (edge).
    Dùng để đẩy event (face_recognized, unknown_face, ...) lên Kafka broker ở server.
    """

    def __init__(
        self,
        bootstrap_servers: Optional[str] = None,
        topic_face_events: Optional[str] = None,
    ):
        # Lấy config từ biến môi trường nếu không truyền trực tiếp
        bootstrap_servers = bootstrap_servers or os.getenv(
            "KAFKA_BOOTSTRAP_SERVERS", "localhost:9092"
        )
        topic_face_events = topic_face_events or os.getenv(
            "KAFKA_FACE_EVENTS_TOPIC", "face_events"
        )

        self.bootstrap_servers = bootstrap_servers
        self.topic_face_events = topic_face_events

        # KafkaProducer JSON
        self.producer = KafkaProducer(
            bootstrap_servers=self.bootstrap_servers.split(","),
            value_serializer=lambda v: json.dumps(v).encode("utf-8"),
            retries=5,
        )

    def publish_face_event(self, event: Dict[str, Any]):
        """
        Gửi 1 event face_recognized lên Kafka.
        event: dict dạng JSON-serializable.
        """
        self.producer.send(self.topic_face_events, event)
        # có thể bỏ flush() nếu muốn high throughput, nhưng demo thì flush luôn cho chắc
        self.producer.flush()
