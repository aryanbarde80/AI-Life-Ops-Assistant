import os
import json
import base64
from typing import Optional
import firebase_admin
from firebase_admin import credentials, firestore
from google.cloud.firestore_v1.async_client import AsyncClient

_db: Optional[AsyncClient] = None


def _initialize_firestore() -> AsyncClient:
    """Initialize Firebase Admin SDK from the FIREBASE_CONFIG env variable."""
    global _db

    if _db is not None:
        return _db

    firebase_config_b64 = os.environ.get("FIREBASE_CONFIG")
    if not firebase_config_b64:
        raise ValueError(
            "FIREBASE_CONFIG environment variable not set. "
            "Set it to the base64-encoded Firebase service account JSON."
        )

    try:
        service_account_json = base64.b64decode(firebase_config_b64).decode("utf-8")
        service_account_dict = json.loads(service_account_json)
    except Exception as e:
        raise ValueError(f"Failed to decode FIREBASE_CONFIG: {e}")

    if not firebase_admin._apps:
        cred = credentials.Certificate(service_account_dict)
        firebase_admin.initialize_app(cred)

    _db = firestore.AsyncClient(
        project=service_account_dict.get("project_id")
    )
    return _db


def get_db() -> AsyncClient:
    """Return Firestore async client, initializing if necessary."""
    return _initialize_firestore()


async def save_message(user_id: str, role: str, content: str) -> None:
    """
    Save a single chat message to Firestore.

    Collection path: users/{user_id}/messages (auto-ID)
    Document fields: role, content, timestamp
    """
    try:
        db = get_db()
        messages_ref = db.collection("users").document(user_id).collection("messages")
        await messages_ref.add({
            "role": role,
            "content": content,
            "timestamp": firestore.SERVER_TIMESTAMP,
        })
    except Exception as e:
        # Non-fatal: log but don't break the chat flow
        print(f"[Firestore] Warning: could not save message for {user_id}: {e}")


async def get_history(user_id: str, limit: int = 50):
    """
    Retrieve the last `limit` messages for a user, ordered by timestamp.

    Returns a list of dicts: [{role, content, timestamp}, ...]
    """
    try:
        db = get_db()
        messages_ref = (
            db.collection("users")
            .document(user_id)
            .collection("messages")
            .order_by("timestamp")
            .limit(limit)
        )
        docs = messages_ref.stream()
        history = []
        async for doc in docs:
            history.append(doc.to_dict())
        return history
    except Exception as e:
        print(f"[Firestore] Warning: could not retrieve history for {user_id}: {e}")
        return []


async def save_task(user_id: str, task: dict) -> str:
    """
    Save a task to Firestore.

    Collection path: users/{user_id}/tasks
    Returns the new document ID.
    """
    try:
        db = get_db()
        tasks_ref = db.collection("users").document(user_id).collection("tasks")
        doc_ref = await tasks_ref.add({
            **task,
            "created_at": firestore.SERVER_TIMESTAMP,
            "completed": task.get("completed", False),
        })
        return doc_ref[1].id
    except Exception as e:
        print(f"[Firestore] Warning: could not save task for {user_id}: {e}")
        return ""


async def get_tasks(user_id: str):
    """
    Retrieve all tasks for a user.

    Returns list of dicts including document id.
    """
    try:
        db = get_db()
        tasks_ref = (
            db.collection("users")
            .document(user_id)
            .collection("tasks")
            .order_by("created_at")
        )
        docs = tasks_ref.stream()
        tasks = []
        async for doc in docs:
            task_data = doc.to_dict()
            task_data["id"] = doc.id
            tasks.append(task_data)
        return tasks
    except Exception as e:
        print(f"[Firestore] Warning: could not retrieve tasks for {user_id}: {e}")
        return []


async def get_recent_context(user_id: str, limit: int = 5) -> str:
    """Fetches recent tasks and messages to provide context for RAG."""
    try:
        db = get_db()
        
        # Get active tasks
        tasks_ref = (
            db.collection("users")
            .document(user_id)
            .collection("tasks")
            .where("completed", "==", False)
            .limit(limit)
        )
        task_docs = await tasks_ref.get()
        
        # Get recent messages
        msgs_ref = (
            db.collection("users")
            .document(user_id)
            .collection("messages")
            .order_by("timestamp", direction=firestore.Query.DESCENDING)
            .limit(limit)
        )
        msg_docs = await msgs_ref.get()
        
        context = "[PERSONAL CONTEXT]\n"
        if task_docs:
            context += "ACTIVE OBJECTIVES: " + ", ".join([d.to_dict().get("title", "") for d in task_docs]) + "\n"
        if msg_docs:
            context += "RECENT HISTORY: " + " | ".join([d.to_dict().get("content", "")[:50] for d in msg_docs]) + "\n"
        
        return context
    except Exception as e:
        print(f"[Firestore] RAG context error: {e}")
        return ""
