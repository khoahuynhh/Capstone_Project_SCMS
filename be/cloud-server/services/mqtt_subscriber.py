import paho.mqtt.client as mqtt
import json
import logging
import os
from datetime import datetime
from database.db import SessionLocal
from database.models import Transaction, Recommendation, Customer
from threading import Thread

logger = logging.getLogger(__name__)

class MQTTSubscriber:
    """MQTT subscriber to receive data from edge devices"""
    
    def __init__(self):
        self.broker_host = os.getenv('MQTT_BROKER', 'mosquitto').split(':')[0]
        self.broker_port = int(os.getenv('MQTT_BROKER', 'mosquitto:1883').split(':')[1])
        
        # Subscribe to all branches
        self.topics = [
            'retail/+/transactions',
            'retail/+/recommendations',
            'retail/+/metrics',
            'retail/+/events'
        ]
        
        self.client = mqtt.Client(client_id="cloud_server")
        self.client.on_connect = self._on_connect
        self.client.on_message = self._on_message
        self.client.on_disconnect = self._on_disconnect
        
        self.connected = False
        self.running = False
        
    def start(self):
        """Start MQTT subscriber in background thread"""
        try:
            logger.info(f"Connecting to MQTT broker at {self.broker_host}:{self.broker_port}")
            self.client.connect(self.broker_host, self.broker_port, 60)
            self.running = True
            
            # Start network loop in background thread
            self.client.loop_start()
            logger.info("MQTT subscriber started")
            
        except Exception as e:
            logger.error(f"Failed to start MQTT subscriber: {e}")
    
    def stop(self):
        """Stop MQTT subscriber"""
        self.running = False
        self.client.loop_stop()
        self.client.disconnect()
        logger.info("MQTT subscriber stopped")
    
    def _on_connect(self, client, userdata, flags, rc):
        """Callback when connected to broker"""
        if rc == 0:
            self.connected = True
            logger.info("Connected to MQTT broker")
            
            # Subscribe to all topics
            for topic in self.topics:
                self.client.subscribe(topic)
                logger.info(f"Subscribed to: {topic}")
        else:
            logger.error(f"Connection failed with code {rc}")
    
    def _on_disconnect(self, client, userdata, rc):
        """Callback when disconnected"""
        self.connected = False
        if rc != 0:
            logger.warning(f"Unexpected disconnect with code {rc}")
    
    def _on_message(self, client, userdata, msg):
        """Callback when message received"""
        try:
            topic = msg.topic
            payload = json.loads(msg.payload.decode())
            
            logger.debug(f"Received message on topic: {topic}")
            
            # Route to appropriate handler
            if '/transactions' in topic:
                self._handle_transaction(payload)
            elif '/recommendations' in topic:
                self._handle_recommendation(payload)
            elif '/metrics' in topic:
                self._handle_metrics(payload)
            elif '/events' in topic:
                self._handle_event(payload)
            
        except Exception as e:
            logger.error(f"Error processing message: {e}", exc_info=True)
    
    def _handle_transaction(self, data: dict):
        """Handle transaction data from edge device"""
        db = SessionLocal()
        try:
            # Create transaction record
            transaction = Transaction(
                branch_id=data['branch_id'],
                transaction_id=data['transaction_id'],
                timestamp=datetime.fromisoformat(data['timestamp']),
                customer_id=data.get('customer_id'),
                items_data=data.get('items', []),
                items_count=len(data.get('items', [])),
                total_amount=data.get('total_amount', 0),
                recommended_items=data.get('recommended_items', [])
            )
            
            db.add(transaction)
            db.commit()
            
            logger.info(f"Transaction saved: {data['transaction_id']} from {data['branch_id']}")
            
            # Update customer profile if exists
            if data.get('customer_id'):
                self._update_customer_profile(db, data)
            
        except Exception as e:
            logger.error(f"Error saving transaction: {e}")
            db.rollback()
        finally:
            db.close()
    
    def _handle_recommendation(self, data: dict):
        """Handle recommendation event from edge device"""
        db = SessionLocal()
        try:
            # Create recommendation record
            recommendation = Recommendation(
                branch_id=data['branch_id'],
                transaction_id=data.get('transaction_id'),
                timestamp=datetime.fromisoformat(data['timestamp']),
                customer_id=data.get('customer_id'),
                face_attributes=data.get('face_attributes', {}),
                recommended_products=data.get('recommendations', []),
                items_count=len(data.get('recommendations', []))
            )
            
            db.add(recommendation)
            db.commit()
            
            logger.info(f"Recommendation saved: {data.get('transaction_id')} from {data['branch_id']}")
            
        except Exception as e:
            logger.error(f"Error saving recommendation: {e}")
            db.rollback()
        finally:
            db.close()
    
    def _handle_metrics(self, data: dict):
        """Handle metrics data from edge device"""
        # Store metrics for monitoring
        logger.info(f"Metrics received from {data.get('branch_id')}: {data}")
        
        # In production, you would store these in time-series database
        # or send to Prometheus
    
    def _handle_event(self, data: dict):
        """Handle custom events from edge device"""
        event_type = data.get('event_type')
        logger.info(f"Event received: {event_type} from {data.get('branch_id')}")
        
        # Handle specific event types
        if event_type == 'model_update_ack':
            logger.info(f"Model update acknowledged by {data.get('branch_id')}")
        elif event_type == 'error':
            logger.error(f"Error reported by {data.get('branch_id')}: {data.get('data')}")
    
    def _update_customer_profile(self, db, transaction_data: dict):
        """Update or create customer profile"""
        try:
            customer_id = transaction_data.get('customer_id')
            if not customer_id:
                return
            
            customer = db.query(Customer).filter(
                Customer.customer_id == customer_id
            ).first()
            
            if customer:
                # Update existing customer
                customer.total_transactions += 1
                customer.total_spent += transaction_data.get('total_amount', 0)
                customer.last_seen = datetime.now()
                
                # Update favorite categories (simplified)
                items = transaction_data.get('items', [])
                if items:
                    categories = [item.get('category') for item in items if item.get('category')]
                    if categories:
                        if not customer.favorite_categories:
                            customer.favorite_categories = {}
                        for cat in categories:
                            current = customer.favorite_categories.get(cat, 0)
                            customer.favorite_categories[cat] = current + 1
                
            else:
                # Create new customer
                customer = Customer(
                    customer_id=customer_id,
                    total_transactions=1,
                    total_spent=transaction_data.get('total_amount', 0),
                    first_seen=datetime.now(),
                    last_seen=datetime.now()
                )
                db.add(customer)
            
            db.commit()
            
        except Exception as e:
            logger.error(f"Error updating customer profile: {e}")
            db.rollback()
