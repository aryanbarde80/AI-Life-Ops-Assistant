import grpc
from concurrent import futures
import acos_pb2
import acos_pb2_grpc
from models.xgboost_model import XGBoostTaskScorer
from models.lstm_model import estimate_time

class InferenceService(acos_pb2_grpc.InferenceServiceServicer):
    def __init__(self):
        self.scorer = XGBoostTaskScorer()

    def PredictTask(self, request, context):
        print(f"[gRPC] Predicting for User: {request.user_id}")
        
        # XGBoost Success Prediction
        success_prob = self.scorer.predict(complexity=request.complexity, priority=2)
        
        # LSTM Time Estimation
        est_time = int(estimate_time([]))
        
        return acos_pb2.PredictResponse(
            success_probability=success_prob,
            estimated_time_minutes=est_time,
            confidence_score=0.95,
            intent="AUTO_DETECT"
        )

def serve():
    server = grpc.server(futures.ThreadPoolExecutor(max_features=10))
    acos_pb2_grpc.add_InferenceServiceServicer_to_server(InferenceService(), server)
    server.add_insecure_port('[::]:50051')
    print("🚀 ML gRPC Server running on port 50051")
    server.start()
    server.wait_for_termination()

if __name__ == '__main__':
    serve()
