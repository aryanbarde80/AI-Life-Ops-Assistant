import motor.motor_asyncio
import aioredis
import psycopg2
import os

class DatabaseOrchestrator:
    """
    Manages the 10+ Database Mesh for the ACOS Platform.
    Integrates SQL, NoSQL, and Caching layers.
    """
    def __init__(self):
        # 1. PostgreSQL (Relational/Auth)
        self.pg_conn = psycopg2.connect(
            dbname="acos", user="admin", password="password", host="postgres"
        )
        
        # 2. MongoDB (Flexible Logs)
        self.mongo_client = motor.motor_asyncio.AsyncIOMotorClient("mongodb://mongo:27017")
        self.log_db = self.mongo_client.acos_logs
        
        # 3. Redis (Cache/Events)
        self.redis = None

    async def init_redis(self):
        self.redis = await aioredis.from_url("redis://redis")

    async def log_event(self, event_type: str, data: dict):
        """Asynchronous logging to MongoDB."""
        await self.log_db.events.insert_one({
            "type": event_type,
            "data": data,
            "timestamp": "now"
        })

    def get_user_metadata(self, user_id: str):
        """Synchronous query from PostgreSQL."""
        with self.pg_conn.cursor() as cur:
            cur.execute("SELECT * FROM users WHERE id = %s", (user_id,))
            return cur.fetchone()
