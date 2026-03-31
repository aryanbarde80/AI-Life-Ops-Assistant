import asyncio
import re
from typing import List, Dict, Any
from services.firestore_service import FirestoreService

class AutomationEngine:
    """
    Zapier-level Workflow Engine.
    Detects patterns and triggers background automations.
    """
    
    def __init__(self):
        self.fs = FirestoreService()

    async def scan_for_tasks(self, user_id: str, text: str):
        """Auto-extracts tasks from conversational text."""
        patterns = [
            r"(?:remind me to|need to|don't forget to) (.+)",
            r"todo: (.+)",
        ]
        
        for pattern in patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                task_title = match.group(1).strip()
                print(f"[Automation] Extracted Task: {task_title}")
                # Save task to Firestore
                await self.fs.add_task(user_id, task_title, priority="medium")

    async def run_periodic_rules(self, user_id: str):
        """Checks IF/THEN rules for task optimization."""
        print(f"[Automation] Running periodic rules for {user_id}")
        tasks = await self.fs.get_tasks(user_id)
        for task in tasks:
            # Rule: If task is older than 24h and still 'low', bump to 'medium'
            if task.priority == "low":
                await self.fs.update_task_priority(user_id, task.id, "medium")
