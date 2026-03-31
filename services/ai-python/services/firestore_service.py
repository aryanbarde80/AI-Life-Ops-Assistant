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
    firebase_config = os.environ.get("FIREBASE_CONFIG")
    
    if not firebase_config:
        print("[Firestore] Warning: FIREBASE_CONFIG not set. System running in OFFLINE mode (no persistence).")
        return None

    service_account_dict = None

    # Helper to attempt JSON extraction if someone pasted JS code
    def extract_json(s: str) -> Optional[dict]:
        import re
        try:
            # Look for the first { and last }
            match = re.search(r'\{.*\}', s, re.DOTALL)
            if match:
                # Still might need fixing if it's JS with unquoted keys
                return json.loads(match.group(0))
        except:
            pass
        return None

    try:
        # 1. Try direct JSON
        service_account_dict = json.loads(firebase_config)
    except json.JSONDecodeError:
        # 2. Try to extract JSON if it looks like JS code
        service_account_dict = extract_json(firebase_config)
        
        if not service_account_dict:
            # 3. Fallback to base64
            try:
                decoded_bytes = base64.b64decode(firebase_config)
                service_account_json = decoded_bytes.decode("utf-8")
                service_account_dict = json.loads(service_account_json)
            except Exception:
                print("[Firestore] Error: Could not parse FIREBASE_CONFIG. Check your Render environment variables.")
                return None

    if not service_account_dict:
        return None

    try:
        if not firebase_admin._apps:
            cred = credentials.Certificate(service_account_dict)
            firebase_admin.initialize_app(cred)

        _db = firestore.AsyncClient(
            project=service_account_dict.get("project_id", "bookify-c6c1b") # Fallback to user project id
        )
        return _db
    except Exception as e:
        print(f"[Firestore] Failed to initialize Admin SDK: {e}")
        return None


def get_db() -> Optional[AsyncClient]:
    """Return Firestore async client, initializing if necessary. Returns None if unreachable."""
    try:
        return _initialize_firestore()
    except Exception:
        return None


class FirestoreService:
    def __init__(self):
        self.db = get_db()
        self.enabled = (self.db is not None)

    async def save_message(self, user_id: str, role: str, content: str) -> None:
        """Saves a single chat message to Firestore."""
        if not self.enabled: return
        try:
            messages_ref = self.db.collection("users").document(user_id).collection("messages")
            await messages_ref.add({
                "role": role,
                "content": content,
                "timestamp": firestore.SERVER_TIMESTAMP,
            })
        except Exception as e:
            print(f"[Firestore] Warning: could not save message for {user_id}: {e}")

    async def get_history(self, user_id: str, limit: int = 50):
        """Retrieves history for a user."""
        try:
            messages_ref = (
                self.db.collection("users")
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

    async def save_task(self, user_id: str, task: dict) -> str:
        """Saves a task to Firestore."""
        try:
            tasks_ref = self.db.collection("users").document(user_id).collection("tasks")
            doc_ref = await tasks_ref.add({
                **task,
                "created_at": firestore.SERVER_TIMESTAMP,
                "completed": task.get("completed", False),
            })
            return doc_ref[1].id
        except Exception as e:
            print(f"[Firestore] Warning: could not save task for {user_id}: {e}")
            return ""

    async def get_tasks(self, user_id: str):
        """Retrieves tasks for a user."""
        try:
            tasks_ref = (
                self.db.collection("users")
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

    async def get_user_stats(self, user_id: str) -> dict:
        """Retrieves XP, Level, and Streak stats for a user."""
        try:
            doc = await self.db.collection("users").document(user_id).get()
            if doc.exists:
                data = doc.to_dict()
                return {
                    "xp": data.get("xp", 0),
                    "level": data.get("level", 1),
                    "streak": data.get("streak", 0),
                    "last_active": data.get("last_active"),
                }
            return {"xp": 0, "level": 1, "streak": 0}
        except Exception as e:
            print(f"[Firestore] Stats error: {e}")
            return {"xp": 0, "level": 1, "streak": 0}

    async def add_xp(self, user_id: str, amount: int) -> dict:
        """Increments user XP and handles leveling logic (1000 XP per level)."""
        try:
            user_ref = self.db.collection("users").document(user_id)
            
            @firestore.async_transactional
            async def update_in_transaction(transaction, ref):
                snapshot = await ref.get(transaction=transaction)
                current_xp = snapshot.get("xp") if snapshot.exists else 0
                new_xp = current_xp + amount
                new_level = (new_xp // 1000) + 1
                
                transaction.set(ref, {
                    "xp": new_xp,
                    "level": new_level,
                    "last_active": firestore.SERVER_TIMESTAMP,
                }, merge=True)
                return {"xp": new_xp, "level": new_level}

            return await update_in_transaction(self.db.transaction(), user_ref)
        except Exception as e:
            print(f"[Firestore] XP update failed: {e}")
            return {}

    async def get_recent_context(self, user_id: str, limit: int = 5) -> str:
        """Fetches recent tasks and messages to provide context for RAG."""
        try:
            # Get active tasks
            tasks_ref = (
                self.db.collection("users")
                .document(user_id)
                .collection("tasks")
                .where("completed", "==", False)
                .limit(limit)
            )
            task_docs = await tasks_ref.get()
            
            # Get recent messages
            msgs_ref = (
                self.db.collection("users")
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

# Provide standalone functions for backward compatibility
_shared_fs = FirestoreService()
async def save_message(user_id, role, content): return await _shared_fs.save_message(user_id, role, content)
async def get_history(user_id, limit=50): return await _shared_fs.get_history(user_id, limit)
async def save_task(user_id, task): return await _shared_fs.save_task(user_id, task)
async def get_tasks(user_id): return await _shared_fs.get_tasks(user_id)
async def get_user_stats(user_id): return await _shared_fs.get_user_stats(user_id)
async def add_xp(user_id, amount): return await _shared_fs.add_xp(user_id, amount)
async def get_recent_context(user_id, limit=5): return await _shared_fs.get_recent_context(user_id, limit)
