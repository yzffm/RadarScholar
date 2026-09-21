"""RadarScholar core configuration.

Loads settings from environment variables with safe defaults for development.
Uses pydantic-settings for type-safe configuration.

NEVER populate real secrets here. Use .env files locally
and environment variables in production.
"""

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application settings loaded from environment."""

    # --- Application ---
    APP_NAME: str = "RadarScholar"
    APP_VERSION: str = "0.1.0"
    DEBUG: bool = True

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

    # --- Database (future milestones) ---
    DATABASE_URL: str = ""

    # --- Supabase ---
    SUPABASE_URL: str = ""
    SUPABASE_ANON_KEY: str = ""
    SUPABASE_SERVICE_ROLE_KEY: str = ""
    SUPABASE_JWT_SECRET: str = ""

    # --- AI Providers (future milestones) ---
    GEMINI_API_KEY: str = ""
    GROQ_API_KEY: str = ""

    model_config = {
        "env_file": ".env",
        "env_file_encoding": "utf-8",
        "case_sensitive": True,
    }


settings = Settings()
