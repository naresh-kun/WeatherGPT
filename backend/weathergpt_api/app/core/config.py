"""
WeatherGPT — Application Configuration
Reads all settings from environment variables.
No secrets are hardcoded here.
"""

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings loaded from environment variables / .env file."""

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
    )

    # ---- API metadata ----------------------------------------
    app_name: str = "WeatherGPT API"
    app_version: str = "0.1.0"
    debug: bool = False

    # ---- Weather provider ------------------------------------
    weather_api_key: str = ""
    weather_base_url: str = "https://api.weatherapi.com/v1"
    weather_api_timeout: int = 15

    # ---- LLM / Gemini provider (Phase 5) --------------------
    gemini_api_key: str = ""    # Mapped from GEMINI_API_KEY env var
    gemini_model: str = "gemini-3.7-flash"  # Google Gemini 3.7 Flash (current)
    llm_api_key: str = ""       # Legacy alias — kept for backward compatibility

    # ---- Server ----------------------------------------------
    host: str = "0.0.0.0"
    port: int = 8000


settings = Settings()
