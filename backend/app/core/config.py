"""RadarScholar core configuration.

Loads settings from environment variables with safe defaults for development.
Uses pydantic-settings for type-safe configuration.

NEVER populate real secrets here. Use .env files locally
and environment variables in production.
"""

import contextlib
import json
from pathlib import Path

from pydantic import field_validator
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application settings loaded from environment."""

    # --- Application ---
    APP_NAME: str = "RadarScholar"
    APP_VERSION: str = "0.1.0"
    DEBUG: bool = False

    # --- CORS ---
    # Default allows Flutter Web dev server origins.
    CORS_ORIGINS: list[str] = [
        "http://localhost:3000",
        "http://localhost:5000",
        "http://localhost:8080",
        "http://127.0.0.1:3000",
        "http://127.0.0.1:5000",
        "http://127.0.0.1:8080",
    ]

    # --- Database ---
    DATABASE_URL: str = "sqlite:///./radarscholar.db"

    @field_validator("CORS_ORIGINS", mode="before")
    @classmethod
    def parse_cors_origins(cls, v: object) -> list[str] | object:
        if isinstance(v, str):
            v_str = v.strip()
            if v_str.startswith("[") and v_str.endswith("]"):
                with contextlib.suppress(json.JSONDecodeError):
                    parsed = json.loads(v_str)
                    if isinstance(parsed, list):
                        return [str(item).strip() for item in parsed if str(item).strip()]
            return [origin.strip() for origin in v_str.split(",") if origin.strip()]
        return v

    @field_validator("DATABASE_URL", mode="before")
    @classmethod
    def normalize_database_url(cls, v: object) -> str | object:
        if isinstance(v, str):
            if v.startswith("postgres://"):
                return v.replace("postgres://", "postgresql+psycopg://", 1)
            if v.startswith("postgresql://") and not v.startswith("postgresql+"):
                return v.replace("postgresql://", "postgresql+psycopg://", 1)
        return v

    # --- Supabase ---
    SUPABASE_URL: str = ""
    SUPABASE_ANON_KEY: str = ""
    SUPABASE_SERVICE_ROLE_KEY: str = ""
    SUPABASE_JWT_SECRET: str = ""

    # --- AI Providers (future milestones) ---
    GEMINI_API_KEY: str = ""
    GEMINI_MODEL: str = "gemini-3.6-flash"

    GROQ_API_KEY: str = ""
    GROQ_MODEL: str = "qwen/qwen3.8-27b"

    AI_ENABLED: bool = True
    AI_PRIMARY_PROVIDER: str = "gemini"
    AI_RATE_LIMIT_REQUESTS: int = 10
    AI_RATE_LIMIT_WINDOW_SECONDS: int = 60

    model_config = {
        # Resolve the project env file from this module, not the process CWD.
        # This keeps `uvicorn`, Alembic, and CI consistent when launched from
        # either the repository root or the backend directory.
        "env_file": Path(__file__).resolve().parents[2] / ".env",
        "env_file_encoding": "utf-8",
        "case_sensitive": True,
    }


settings = Settings()
