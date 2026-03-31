import grpc
import acos_pb2
import acos_pb2_grpc
import os

class MLGrpcClient:
    """
    High-performance binary client for ACOS ML Engine.
    """
    def __init__(self):
        self.host = os.getenv("ML_GRPC_HOST", "ml_python:50051")
        self.channel = grpc.insecure_channel(self.host)
        self.stub = acos_pb2_grpc.InferenceServiceStub(self.channel)

    def predict(self, user_id: str, query: str, complexity: float = 0.5):
        request = acos_pb2.PredictRequest(
            user_id=user_id,
            query=query,
            complexity=complexity
        )
        try:
            response = self.stub.PredictTask(request)
            return response
        except Exception as e:
            print(f"[gRPC-Client] Error: {e}")
            return None
