from services.ml_grpc_client import MLGrpcClient
import os

class MLService:
    """
    Client for the ACOS ML Engine via high-perf gRPC.
    Integrates binary-level inference into the reasoning mesh.
    """
    def __init__(self):
        self.grpc_client = MLGrpcClient()

    async def predict_task_success(self, user_id: str, query: str) -> dict:
        """Calls the ML engine via binary gRPC for sub-millisecond scoring."""
        print(f"[gRPC-AI] Requesting inference for {user_id}")
        response = self.grpc_client.predict(user_id, query)
        
        if response:
            return {
                "success_probability": response.success_probability,
                "estimated_time_minutes": response.estimated_time_minutes,
                "confidence": response.confidence_score,
                "intent": response.intent
            }
        
        return {"success_probability": 0.5, "estimated_time_minutes": 60}
