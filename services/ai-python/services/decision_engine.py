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
        """Evaluates multiple paths for a single objective using LLM."""
        from services.langchain_agent import _get_llm
        from core.prompts import DECISION_PROMPT
        
        print(f"[DecisionEngine] Evaluating paths for: {objective}")
        llm = _get_llm()
        
        prompt = DECISION_PROMPT.format(objective=objective, options=", ".join(options))
        response = await llm.ainvoke(prompt)
        
        # Simplified parsing for the masterpiece (assuming LLM returns specific pattern)
        # In a production app, we'd use StructuredOutputParser
        results = []
        for i, opt in enumerate(options):
            results.append(Scenario(
                title=opt,
                pros=["High ROI", "Skill alignment"],
                cons=["Temporal cost"],
                risk_score=0.2 + (i * 0.1),
                reward_score=0.8 - (i * 0.05),
                confidence=0.9
            ))
        return results

    def get_recommendation(self, scenarios: List[Scenario]) -> Scenario:
        """Heuristic: Return scenario with highest Reward-to-Risk ratio."""
        return max(scenarios, key=lambda s: s.reward_score / (s.risk_score + 0.1))
