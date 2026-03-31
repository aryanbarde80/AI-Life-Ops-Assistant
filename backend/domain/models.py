from typing import Optional, List
from pydantic import BaseModel, Field

class UserProfile(BaseModel):
    id: str
    username: str
    level: int = 1
    xp: int = 0
    rank: str = "Recruit"

class Task(BaseModel):
    id: str
    title: str
    description: Optional[str] = None
    priority: str = "medium"
    status: str = "pending"
    tags: List[str] = []

class SystemHealth(BaseModel):
    mesh_status: str = "ACTIVE"
    active_agents: int = 4
    latency_ms: int
    memory_usage: str
