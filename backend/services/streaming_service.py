import asyncio
import json
from typing import AsyncGenerator
from services.agent_coordinator import AgentCoordinator
from core.prompts import SYSTEM_PROMPT

class StreamingService:
    """
    High-performance streaming engine for real-time AI interactions.
    Uses Async Generators to yield tokens as they are generated.
    """
    
    def __init__(self):
        self.coordinator = AgentCoordinator()

    async def stream_chat(self, user_id: str, message: str) -> AsyncGenerator[str, None]:
        """
        Streams live AI response tokens directly from the agentic mesh.
        """
        yield json.dumps({"type": "status", "content": "Mesh Synchronizing..."}) + "\n"
        
        try:
            async for chunk in self.coordinator.run_orchestration_stream(user_id, message):
                yield json.dumps({
                    "type": "chunk", 
                    "content": chunk,
                    "is_last": False
                }) + "\n"
        except Exception as e:
            yield json.dumps({"type": "error", "content": str(e)}) + "\n"
        
        yield json.dumps({"type": "done", "content": ""}) + "\n"

    async def stream_metrics(self) -> AsyncGenerator[str, None]:
        """Streams real-time system metrics to the dashboard."""
        while True:
            health = await self.coordinator.get_system_health()
            yield json.dumps(health.model_dump()) + "\n"
            await asyncio.sleep(5)
