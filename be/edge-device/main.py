# main.py
import os
import time
import logging
from datetime import datetime

from modules.camera_simulator import CameraSimulator
from modules.face_detector import FaceDetector
from modules.recommender import ProductRecommender
from modules.kafka_client import EdgeKafkaProducer
from prometheus_client import Counter, Histogram, start_http_server

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)

# Prometheus metrics
INFERENCE_COUNTER = Counter("edge_inference_total", "Total inference requests")
INFERENCE_LATENCY = Histogram("edge_inference_latency_seconds", "Inference latency")
RECOMMENDATION_COUNTER = Counter("edge_recommendations_total", "Total recommendations")
KAFKA_PUBLISH_COUNTER = Counter(
    "edge_kafka_publish_total", "Kafka messages published from edge"
)


class EdgeDevice:
    def __init__(self):
        self.branch_id = os.getenv("BRANCH_ID", "branch_001")
        self.branch_name = os.getenv("BRANCH_NAME", "Test Branch")
        self.device_id = os.getenv("DEVICE_ID", "edge_001")

        logger.info(
            "Initializing Edge Device: %s (%s, device=%s)",
            self.branch_name,
            self.branch_id,
            self.device_id,
        )

        # Initialize components
        self.camera = CameraSimulator()
        self.face_detector = FaceDetector()
        self.recommender = ProductRecommender(self.branch_id)
        self.kafka_producer = EdgeKafkaProducer(
            branch_id=self.branch_id, device_id=self.device_id
        )

        # State
        self.running = False
        self.transaction_count = 0

    # ----------------------------------------------------- #
    # 1. Pipeline xử lý 1 khách tới quầy
    # ----------------------------------------------------- #
    def process_customer(self):
        """Main processing pipeline for one customer"""
        start_time = time.time()

        try:
            # Step 1: Capture frame from camera
            frame = self.camera.capture_frame()
            if frame is None:
                return

            # Step 2: Detect face and extract attributes / embedding
            face_data = self.face_detector.detect_and_extract(frame)

            if face_data is None:
                logger.debug("No face detected")
                # Có thể gửi event 'no_face' nếu muốn tracking
                self.kafka_producer.publish_face_event(
                    {
                        "event_type": "no_face",
                        "timestamp": datetime.now().isoformat(),
                    }
                )
                KAFKA_PUBLISH_COUNTER.inc()
                return

            INFERENCE_COUNTER.inc()

            # Step 3: Get product recommendations
            recommendations = self.recommender.get_recommendations(
                face_attributes=face_data["attributes"],
                customer_id=face_data.get("customer_id"),
            )

            RECOMMENDATION_COUNTER.inc()

            # Step 4: Gửi event face_recognized lên Kafka
            transaction_id = f"txn_{self.branch_id}_{int(time.time() * 1000)}"

            face_event = {
                "event_type": "face_recognized",
                "timestamp": datetime.now().isoformat(),
                "customer_id": face_data.get("customer_id", "unknown"),
                "face_attributes": face_data["attributes"],
                "embedding": face_data.get("embedding"),
                "recommendations": recommendations,
                "transaction_id": transaction_id,
            }

            self.kafka_producer.publish_face_event(face_event)
            KAFKA_PUBLISH_COUNTER.inc()

            # Step 5: Simulate customer interaction & purchase
            purchased_items = self.simulate_purchase(recommendations)

            if purchased_items:
                tx_event = {
                    "event_type": "transaction_completed",
                    "branch_id": self.branch_id,
                    "device_id": self.device_id,
                    "transaction_id": transaction_id,
                    "timestamp": datetime.now().isoformat(),
                    "customer_id": face_data.get("customer_id"),
                    "items": purchased_items,
                    "recommended_items": [r["product_id"] for r in recommendations],
                    "total_amount": sum(item["price"] for item in purchased_items),
                }

                self.kafka_producer.publish_transaction_event(tx_event)
                self.transaction_count += 1
                KAFKA_PUBLISH_COUNTER.inc()

                logger.info(
                    "Transaction completed: %d items, Total: %.2f VND",
                    len(purchased_items),
                    tx_event["total_amount"],
                )

            # Measure latency
            latency = time.time() - start_time
            INFERENCE_LATENCY.observe(latency)
            logger.info("Customer processed in %.2f ms", latency * 1000.0)

        except Exception as e:
            logger.error(f"Error processing customer: {e}", exc_info=True)

    # ----------------------------------------------------- #
    # 2. Hàm giả lập hành vi mua hàng
    # ----------------------------------------------------- #
    def simulate_purchase(self, recommendations):
        """Simulate customer purchasing decision"""
        import random

        # 40% chance customer buys something
        if random.random() < 0.4:
            # Buy 1-3 items from recommendations or random items
            num_items = random.randint(1, 3)

            if recommendations and random.random() < 0.6:
                # 60% chance to buy from recommendations
                purchased = random.sample(
                    recommendations,
                    min(num_items, len(recommendations)),
                )
            else:
                # Buy random items
                purchased = [
                    {
                        "product_id": f"PROD_{random.randint(1000, 9999)}",
                        "product_name": f"Product {random.randint(1, 100)}",
                        "price": random.randint(10_000, 500_000),
                        "category": random.choice(
                            ["Beverage", "Snack", "Personal Care", "Dairy"]
                        ),
                    }
                    for _ in range(num_items)
                ]

            return purchased

        return []

    # ----------------------------------------------------- #
    # 3. Main loop
    # ----------------------------------------------------- #
    def run(self):
        """Main event loop"""
        self.running = True
        logger.info(
            "Edge Device %s started (branch=%s, device=%s)",
            self.branch_name,
            self.branch_id,
            self.device_id,
        )

        # Start Prometheus metrics server
        start_http_server(8001)

        try:
            import random

            while self.running:
                # Simulate customer arrival (random interval 5-15 seconds)
                wait_time = random.uniform(5, 15)
                logger.info("Waiting %.1f s for next customer.", wait_time)
                time.sleep(wait_time)

                # Process customer
                self.process_customer()

        except KeyboardInterrupt:
            logger.info("Shutting down gracefully.")
        finally:
            self.cleanup()

    def cleanup(self):
        """Cleanup resources"""
        self.running = False
        self.kafka_producer.flush()
        logger.info("Total transactions: %d", self.transaction_count)


if __name__ == "__main__":
    device = EdgeDevice()
    device.run()
