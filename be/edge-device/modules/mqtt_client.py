import paho.mqtt.client as mqtt
import json
import logging
import os
import time
import uuid
import base64
import numpy as np
from threading import Event, Lock

logger = logging.getLogger(__name__)


class MQTTClient:
    """MQTT client for Edge-Cloud communication"""

    def __init__(self, branch_id):
        self.branch_id = branch_id
        broker = os.getenv("MQTT_BROKER", "mosquitto:1883")
        if ":" in broker:
            self.broker_host, broker_port = broker.rsplit(":", 1)
            self.broker_port = int(broker_port)
        else:
            self.broker_host = broker
            self.broker_port = int(os.getenv("MQTT_PORT", "1883"))

        # MQTT topics
        self.topics = {
            "face_identify_req": f"retail/{branch_id}/face/identify/request",
            "face_identify_resp": f"retail/{branch_id}/face/identify/response/{os.getenv('DEVICE_ID','device_1')}",
            "recommendations": f"retail/{branch_id}/recommendations",
            "transactions": f"retail/{branch_id}/transactions",
            "metrics": f"retail/{branch_id}/metrics",
            "events": f"retail/{branch_id}/events",
            "model_update": f"retail/{branch_id}/model/update",
            "config_update": f"retail/{branch_id}/config/update",
        }

        # Create MQTT client
        self.client = mqtt.Client(client_id=f"edge_{branch_id}")
        self.client.on_connect = self._on_connect
        self.client.on_message = self._on_message
        self.client.on_disconnect = self._on_disconnect
        self.client.will_set(
            self.topics["events"],
            payload=json.dumps(
                {
                    "event_type": "edge_offline",
                    "branch_id": self.branch_id,
                    "device_id": os.getenv("DEVICE_ID", "device_1"),
                    "timestamp": time.time(),
                }
            ),
            qos=1,
            retain=False,
        )

        self.connected = False
        self._pending = {}
        self._lock = Lock()

    def connect(self):
        """Connect to MQTT broker"""
        try:
            logger.info(
                f"Connecting to MQTT broker at {self.broker_host}:{self.broker_port}"
            )
            self.client.connect(self.broker_host, self.broker_port, 60)
            self.client.loop_start()

            # Wait for connection
            timeout = 10
            start = time.time()
            while not self.connected and (time.time() - start) < timeout:
                time.sleep(0.1)

            if self.connected:
                logger.info("MQTT connected successfully")
            else:
                logger.error("MQTT connection timeout")

        except Exception as e:
            logger.error(f"MQTT connection error: {e}")

    def _on_connect(self, client, userdata, flags, rc):
        """Callback when connected to broker"""
        if rc == 0:
            self.connected = True
            logger.info(f"Connected to MQTT broker with result code {rc}")

            # Subscribe to relevant topics
            self.client.subscribe(self.topics["model_update"])
            self.client.subscribe(self.topics["config_update"])
            self.client.subscribe(self.topics["face_identify_resp"])
            logger.info(
                f"Subscribed to: {self.topics['model_update']}, {self.topics['config_update']}"
            )
        else:
            logger.error(f"Connection failed with code {rc}")

    def _on_message(self, client, userdata, msg):
        """Callback when message received"""
        try:
            topic = msg.topic
            payload = json.loads(msg.payload.decode())

            logger.info(f"Received message on topic: {topic}")

            if "model/update" in topic:
                self._handle_model_update(payload)
            elif "config/update" in topic:
                self._handle_config_update(payload)
            elif "face/identify/response" in topic:
                corr = payload.get("correlation_id")
                if corr:
                    with self._lock:
                        p = self._pending.get(corr)
                        if p:
                            p["data"] = payload
                            p["event"].set()
            else:
                logger.debug(f"Unhandled topic: {topic}")

        except Exception as e:
            logger.error(f"Error processing message: {e}")

    def _on_disconnect(self, client, userdata, rc):
        """Callback when disconnected"""
        self.connected = False
        if rc != 0:
            logger.warning(f"Unexpected disconnect with code {rc}")
        else:
            logger.info("Disconnected from MQTT broker")

    def request_face_identify(self, embedding, attributes=None, timeout=1.0):
        corr = str(uuid.uuid4())
        ev = Event()
        with self._lock:
            self._pending[corr] = {"event": ev, "data": None}

        emb = np.asarray(embedding, dtype=np.float32)
        emb_b64 = base64.b64encode(emb.tobytes()).decode("ascii")

        req = {
            "event_type": "face_identify_request",
            "branch_id": self.branch_id,
            "device_id": os.getenv("DEVICE_ID", "device_1"),
            "timestamp": time.time(),
            "correlation_id": corr,
            "reply_to": self.topics["face_identify_resp"],
            "embedding_dim": int(emb.shape[0]),
            "dtype": "float32",
            "embedding_b64": emb_b64,
        }

        ok = self._publish(self.topics["face_identify_req"], req, qos=1)
        if not ok:
            with self._lock:
                self._pending.pop(corr, None)
            return {"success": False, "reason": "mqtt_publish_failed"}

        # Wait response
        if not ev.wait(timeout):
            with self._lock:
                self._pending.pop(corr, None)
            return {"success": False, "reason": "timeout"}

        with self._lock:
            resp = self._pending.pop(corr, {}).get("data")

        return resp or {"success": False, "reason": "empty_response"}

    def publish_recommendation(self, data: dict):
        """Publish recommendation event"""
        return self._publish(self.topics["recommendations"], data)

    def publish_transaction(self, data: dict):
        """Publish transaction data"""
        return self._publish(self.topics["transactions"], data)

    def publish_metrics(self, data: dict):
        """Publish performance metrics"""
        return self._publish(self.topics["metrics"], data)

    def publish_event(self, event_type: str, data: dict):
        """Publish custom event"""
        event_data = {
            "event_type": event_type,
            "branch_id": self.branch_id,
            "device_id": os.getenv("DEVICE_ID", "device_1"),
            "data": data,
        }
        return self._publish(self.topics["events"], event_data)

    def _publish(self, topic: str, data: dict, qos: int = 1):
        """Internal publish method"""
        try:
            if not self.connected:
                logger.warning("MQTT not connected, cannot publish")
                return False

            payload = json.dumps(data)
            result = self.client.publish(topic, payload, qos=qos)

            if result.rc == mqtt.MQTT_ERR_SUCCESS:
                logger.debug(f"Published to {topic}")
                return True
            else:
                logger.error(f"Publish failed with code {result.rc}")
                return False

        except Exception as e:
            logger.error(f"Publish error: {e}")
            return False

    def _handle_model_update(self, payload: dict):
        """Handle model update notification from cloud"""
        logger.info(f"Model update received: {payload}")

        model_url = payload.get("model_url")
        model_version = payload.get("version")

        # In production, download and load new model
        logger.info(f"Would download model from: {model_url} (version {model_version})")

        # Acknowledge update
        ack_data = {
            "branch_id": self.branch_id,
            "model_version": model_version,
            "status": "updated",
            "timestamp": time.time(),
        }
        self.publish_event("model_update_ack", ack_data)

    def _handle_config_update(self, payload: dict):
        """Handle configuration update from cloud"""
        logger.info(f"Config update received: {payload}")

        # Apply new configuration
        # In production, this would update inference parameters, thresholds, etc.

        # Acknowledge update
        ack_data = {
            "branch_id": self.branch_id,
            "status": "applied",
            "timestamp": time.time(),
        }
        self.publish_event("config_update_ack", ack_data)

    def disconnect(self):
        """Disconnect from broker"""
        self.client.loop_stop()
        self.client.disconnect()
        logger.info("MQTT client disconnected")
