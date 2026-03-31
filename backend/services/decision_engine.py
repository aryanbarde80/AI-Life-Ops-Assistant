from typing import List, Dict, Any
from pydantic import BaseModel

class Scenario(BaseModel):
    title: str
    pros: List[str]
    cons: List[str]
    risk_score: float  # 0.0 to 1.0
    reward_score: float # 0.0 to 1.0
    confidence: float # 0.0 to 1.0

class DecisionEngine:
    """
    Advanced scenario modeling and risk/reward evaluator.
    Provides multi-perspective reasoning for user choices.
    """
    
    async def evaluate_options(self, objective: str, options: List[str]) -> List[Scenario]:
        """Evaluates multiple paths for a single objective."""
        print(f"[DecisionEngine] Evaluating paths for: {objective}")
        
        # In a masterpiece, this would call the LLM with a specialized scoring prompt
        # Simulation:
        results = []
        for opt in options:
            results.append(Scenario(
                title=opt,
                pros=["High mastery potential", "Immediate career utility"],
                cons=["Steep learning curve", "Requires 4+ hours focus"],
                risk_score=0.35 if "Networking" in opt else 0.55,
                reward_score=0.92,
                confidence=0.89
            ))
        return results

    def get_recommendation(self, scenarios: List[Scenario]) -> Scenario:
        """Heuristic: Return scenario with highest Reward-to-Risk ratio."""
        return max(scenarios, key=lambda s: s.reward_score / (s.risk_score + 0.1))
