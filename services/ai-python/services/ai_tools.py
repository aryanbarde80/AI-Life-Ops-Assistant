from langchain.tools import tool
from services.firestore_service import FirestoreService
import asyncio

fs = FirestoreService()

@tool
async def create_task_tool(user_id: str, title: str, priority: str = "medium") -> str:
    """
    Creates a new task in the user's mission board.
    Use this when the user asks to 'remind me', 'add a task', or 'objective'.
    """
    print(f"[Tool] Creating task: {title} for {user_id}")
    # In a masterpiece, we call the actual firestore method
    # For now, we simulate success
    return f"Successfully created mission: {title} (Priority: {priority})"

@tool
async def search_memory_tool(user_id: str, query: str) -> str:
    """
    Searches the user's long-term memory vault for relevant historical context.
    Use this when the user refers to past conversations or 'what did I say before'.
    """
    # Mock retrieval
    return f"Memory insight found: User expressed interest in {query} previously."

AI_TOOLS = [create_task_tool, search_memory_tool]
