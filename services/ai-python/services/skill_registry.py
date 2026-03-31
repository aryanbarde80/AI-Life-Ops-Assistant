from typing import Dict, Any, List

class SkillRegistry:
    """
    Advanced Skill System allowing the AI to dynamically 'load' 
    capabilities based on user intent. This is the foundation 
    of the Multi-Domain expansion.
    """
    
    def __init__(self):
        self._skills = {
            "task_breakdown": {
                "name": "Decomposition Engine",
                "domain": "Productivity",
                "complexity": "HIGH"
            },
            "sentiment_analysis": {
                "name": "Empathy Matrix",
                "domain": "Psychology",
                "complexity": "MEDIUM"
            },
            "financial_planner": {
                "name": "Wealth Agent",
                "domain": "Finance",
                "complexity": "CRITICAL"
            }
        }

    def get_skill_set(self, domain: str) -> List[Dict[str, Any]]:
        return [v for k, v in self._skills.items() if v["domain"] == domain]

    def register_skill(self, key: str, data: Dict[str, Any]):
        self._skills[key] = data
