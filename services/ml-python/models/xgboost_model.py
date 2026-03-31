import numpy as np

class XGBoostTaskScorer:
    """
    Simulation of an XGBoost Booster for task success prediction.
    In a real masterpiece, this would load a .json model file.
    """
    def __init__(self):
        self.feature_names = ["complexity", "priority", "user_engagement", "historical_velocity"]

    def predict(self, complexity: float, priority: int) -> float:
        # Mock logic: Success decreases with complexity, increases with priority focus
        # Normalizing features
        c = max(0.1, min(1.0, complexity))
        p = max(1, min(3, priority)) / 3.0
        
        # Simulated XGBoost inference
        base_score = 0.85
        success_prob = base_score - (0.4 * c) + (0.2 * p)
        return float(np.clip(success_prob, 0.0, 1.0))
