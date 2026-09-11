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

    # ---- Smart Alert Engine thresholds (Phase 6) -----------
    # Temperatures in °C (WeatherAPI: temp_c field)
    alert_heat_warning_c: float = 38.0   # ≥38°C → Heat Advisory (moderate)
    alert_heat_danger_c: float = 42.0    # ≥42°C → Extreme Heat Alert (severe)
    # Rain probability 0–100 (WeatherAPI: daily_chance_of_rain / chance_of_rain)
    alert_rain_warning_pct: float = 70.0  # ≥70% → Heavy Rain Advisory (moderate)
    # Wind in kph (WeatherAPI: wind_kph / maxwind_kph — engine converts internally)
    alert_wind_warning_kph: float = 50.0  # ≥50 kph → Strong Wind Advisory (moderate)
    alert_wind_danger_kph: float = 80.0   # ≥80 kph → Dangerous Wind Alert (severe)
    # UV index (WeatherAPI: uv field)
    alert_uv_warning_index: float = 8.0   # ≥8 → High UV Advisory (moderate)
    alert_uv_danger_index: float = 11.0   # ≥11 → Extreme UV Alert (severe)

    # ---- Server ----------------------------------------------
    host: str = "0.0.0.0"
    port: int = 8000


settings = Settings()
