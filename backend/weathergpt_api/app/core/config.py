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
    weather_base_url: str = ""

    # ---- LLM provider ----------------------------------------
    llm_api_key: str = ""

    # ---- Server ----------------------------------------------
    host: str = "0.0.0.0"
    port: int = 8000


settings = Settings()
