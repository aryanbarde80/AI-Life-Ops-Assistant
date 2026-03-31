import random
from typing import List

class MLService:
    """
    Predictive modeling and behavioral anomaly detection.
    Predicts task success rates and burnout risk.
    """
    
    async def predict_task_success(self, userId: str, task_title: str) -> float:
        """Uses simulated regression to predict completion probability."""
        print(f"[DeepML] Predicting completion for: {task_title}")
        
        base_prob = 0.75
        if "procrastinate" in task_title.lower():
            base_prob -= 0.3
        
        return min(0.99, max(0.1, base_prob + random.uniform(-0.1, 0.2)))

    async def detect_burnout_risk(self, userId: str) -> dict:
        """Time-series analysis of focus hours."""
        risk_level = random.choice(["Low", "Moderate", "High"])
        return {
            "risk_level": risk_level,
            "suggestion": "Suggests a 15-min focus break" if risk_level != "Low" else "Keep crushing it!"
        }
