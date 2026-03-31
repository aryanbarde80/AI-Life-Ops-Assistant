import asyncio

class WorkflowEngine:
    """
    Zapier-level Automation Engine.
    Supports IF -> THEN -> ELSE branching and background execution.
    """
    def __init__(self, kafka_service):
        self.kafka = kafka_service

    async def execute_workflow(self, workflow_id: str, trigger_data: dict):
        print(f"[Workflow] Executing: {workflow_id}")
        
        # Scenario: IF email from 'boss' -> THEN high priority alert
        if trigger_data.get("source") == "email" and "urgent" in trigger_data.get("subject", "").lower():
            print("[Workflow] Condition Matched: Urgent Email detected.")
            await self.apply_action("increase_priority", {"task_id": "current"})
        else:
            print("[Workflow] Default path: No critical triggers found.")

    async def apply_action(self, action_type: str, params: dict):
        """Executes atomic system actions."""
        print(f"[Workflow] Applying action: {action_type} with {params}")
        # Emit event to Kafka for other services to react
        self.kafka.emit_event("system_actions", {"action": action_type, "params": params})
