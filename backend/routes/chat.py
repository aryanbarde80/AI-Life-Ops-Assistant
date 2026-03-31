from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from services.langchain_agent import get_agent_response
from services.firestore_service import save_message, get_history

router = APIRouter()


class ChatRequest(BaseModel):
    message: str
    user_id: str


class ChatResponse(BaseModel):
    response: str


@router.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    if not request.message.strip():
        raise HTTPException(status_code=400, detail="Message cannot be empty.")
    if not request.user_id.strip():
        raise HTTPException(status_code=400, detail="user_id cannot be empty.")

    try:
        # Save user message to Firestore
        await save_message(request.user_id, "user", request.message)

        # Get AI response from LangChain agent
        ai_response = await get_agent_response(request.user_id, request.message)

        # Save assistant response to Firestore
        await save_message(request.user_id, "assistant", ai_response)

        return ChatResponse(response=ai_response)

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Agent error: {str(e)}")
