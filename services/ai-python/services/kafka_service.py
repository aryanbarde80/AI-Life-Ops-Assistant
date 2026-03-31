from confluent_kafka import Producer
import json
import os

class KafkaService:
    """
    Enterprise Event Bus (Kafka) for distributed task orchestration.
    """
    def __init__(self):
        self.conf = {
            'bootstrap.servers': os.getenv('KAFKA_BOOTSTRAP_SERVERS', 'kafka:9092'),
            'client.id': 'ai_service_producer'
        }
        try:
            self.producer = Producer(self.conf)
        except Exception as e:
            print(f"[Kafka] Failed to initialize: {e}")
            self.producer = None

    def emit_event(self, topic: str, data: dict):
        if not self.producer:
            return
        
        try:
            self.producer.produce(topic, key="event", value=json.dumps(data))
            self.producer.flush()
            print(f"[Kafka] Event emitted to {topic}")
        except Exception as e:
            print(f"[Kafka] Emit failed: {e}")
