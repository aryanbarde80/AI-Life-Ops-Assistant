from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List
import random

app = FastAPI(title="ACOS ML Service")

class PredictionRequest(BaseModel):
    user_id: str
    query: str

class PredictionResponse(BaseModel):
    success_probability: float
    estimated_time_minutes: int
    confidence_score: float

from models.xgboost_model import XGBoostTaskScorer
from models.lstm_model import estimate_time

scorer = XGBoostTaskScorer()

@app.post("/predict", response_model=PredictionResponse)
async def predict_task(request: PredictionRequest):
    # Intent Detection (Stub for BERT)
    intent = "task_creation" if "do" in request.query.lower() else "query"
    
    # XGBoost Success Prediction
    success_prob = scorer.predict(complexity=0.5, priority=2)
    
    # LSTM Time Estimation
    est_time = int(estimate_time([]))
    
    return PredictionResponse(
        success_probability=success_prob,
        estimated_time_minutes=est_time,
        confidence_score=0.92 if intent == "task_creation" else 0.85
    )

@app.get("/health")
async def health():
    return {"status": "healthy", "service": "ml-service"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)
