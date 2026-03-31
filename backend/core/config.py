import os
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    """
    Enterprise-grade configuration management using Pydantic Settings.
    Ensures type safety and environment variable validation.
    """
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    # App Settings
    APP_NAME: str = "AI Life Ops Masterpiece"
    VERSION: str = "2.5.0"
    DEBUG: bool = False

    # AI Settings
    OPENAI_API_KEY: str = os.environ.get("OPENAI_API_KEY", "sk-placeholder")
    MODEL_PATH: str = "models/qwen2.5-0.5b-instruct-q4_k_m.gguf"

    # Infrastructure
    FIREBASE_CONFIG: str = os.environ.get("FIREBASE_CONFIG", "")
    RENDER_URL: str = os.environ.get("RENDER_URL", "http://localhost:10000")

settings = Settings()
