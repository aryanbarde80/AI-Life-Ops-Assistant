import asyncio
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from services.agent_coordinator import AgentCoordinator
from services.firestore_service import save_message

from fastapi.responses import StreamingResponse
from services.streaming_service import StreamingService

from services.automation_engine import AutomationEngine

router = APIRouter()
coordinator = AgentCoordinator()
streamer = StreamingService()
automation = AutomationEngine()

@router.get("/stream")
async def stream_chat(user_id: str, message: str):
    """
    Server-Sent Events (SSE) endpoint for streaming AI responses.
    This also triggers the Automation Engine for background extraction.
    """
    # Background task extraction
    asyncio.create_task(automation.scan_for_tasks(user_id, message))
    
    return StreamingResponse(
        streamer.stream_chat(user_id, message),
        media_type="text/event-stream"
    )

class ChatRequest(BaseModel):
    message: str
    user_id: str

class ChatResponse(BaseModel):
    response: str

@router.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    if not request.message.strip():
        raise HTTPException(status_code=400, detail="Message cannot be empty.")

    try:
        # Step 1: Orchestrate Response via Multi-Agent Mesh
        ai_response = await coordinator.run_orchestration(request.user_id, request.message)
        
        # Step 2: Persistence (Async)
        asyncio.create_task(save_message(request.user_id, "user", request.message))
        asyncio.create_task(save_message(request.user_id, "assistant", ai_response))

        return ChatResponse(response=ai_response)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Orchestration Error: {str(e)}")
