"""
WeatherGPT — Multilingual Backend Tests (Phase 8)

Tests covering:
  - Chat: language field accepted ('ta' and 'en')
  - Chat: default language is English when omitted
  - Chat: Tamil instruction applied to Gemini prompt when language='ta'
  - Chat: English chat instruction applied when language='en'
  - Chat: invalid language handled gracefully (falls back to English)
  - Chat: backward compatibility when location or coordinates are passed
  - Alerts: localized alert titles and descriptions for 'ta' and 'en'
  - Alerts: numerical values and thresholds preserved in Tamil
  - Advisories: localized advisory title, message, and recommendation for 'ta' and 'en'
  - Climate: localized season and insight for 'ta' and 'en' while preserving anomalies
"""

import pytest
from unittest.mock import AsyncMock, patch
from fastapi.testclient import TestClient
from app.main import app
from app.services.alerts.engine import AlertEngine
from app.schemas.weather import WeatherCurrent, Location, WeatherForecast, DailyForecast
from app.services.climate.service import ClimateService

client = TestClient(app)

# ---------------------------------------------------------------------------
# Shared test data
# ---------------------------------------------------------------------------

MOCK_WEATHER_RESPONSE = {
    "location": {
        "name": "Madurai",
        "region": "Tamil Nadu",
        "country": "India",
        "lat": 9.93,
        "lon": 78.12,
        "tz_id": "Asia/Kolkata",
    },
    "current": {
        "last_updated_epoch": 1690000000,
        "temp_c": 32.0,
        "condition": {"text": "Sunny", "icon": "//cdn.weatherapi.com/weather/64x64/day/113.png"},
        "wind_kph": 15.0,
        "wind_degree": 180,
        "humidity": 60,
        "feelslike_c": 35.0,
        "vis_km": 10.0,
        "uv": 8.0,
    },
}


# ---------------------------------------------------------------------------
# Chat Multilingual Tests
# ---------------------------------------------------------------------------

class TestChatMultilingual:
    @patch("app.services.weather.client.WeatherAPIClient._request", new_callable=AsyncMock)
    @patch("app.services.chat_service.GeminiChatService.generate_response", new_callable=AsyncMock)
    def test_tamil_chat_request_returns_ta_language(self, mock_gemini, mock_weather):
        mock_weather.return_value = MOCK_WEATHER_RESPONSE
        mock_gemini.return_value = "மதுரையில் தற்போது 32°C வெயில் நிலவுகிறது."

        payload = {
            "message": "இப்போது வானிலை எப்படி இருக்கிறது?",
            "location": {"lat": 9.93, "lon": 78.12},
            "language": "ta",
        }
        response = client.post("/api/v1/chat", json=payload)
        assert response.status_code == 200
        data = response.json()
        assert data["language"] == "ta"
        assert data["message"] == "மதுரையில் தற்போது 32°C வெயில் நிலவுகிறது."

        # Verify GeminiChatService was called with language="ta"
        mock_gemini.assert_called_once()
        assert mock_gemini.call_args.kwargs.get("language") == "ta"

    @patch("app.services.weather.client.WeatherAPIClient._request", new_callable=AsyncMock)
    @patch("app.services.chat_service.GeminiChatService.generate_response", new_callable=AsyncMock)
    def test_default_language_is_english(self, mock_gemini, mock_weather):
        mock_weather.return_value = MOCK_WEATHER_RESPONSE
        mock_gemini.return_value = "It is currently 32°C and sunny in Madurai."

        payload = {
            "message": "What is the weather?",
            "location": {"lat": 9.93, "lon": 78.12},
        }
        response = client.post("/api/v1/chat", json=payload)
        assert response.status_code == 200
        data = response.json()
        assert data["language"] == "en"

        mock_gemini.assert_called_once()
        assert mock_gemini.call_args.kwargs.get("language") == "en"

    @patch("app.services.weather.client.WeatherAPIClient._request", new_callable=AsyncMock)
    @patch("app.services.chat_service.GeminiChatService.generate_response", new_callable=AsyncMock)
    def test_invalid_language_falls_back_to_english(self, mock_gemini, mock_weather):
        mock_weather.return_value = MOCK_WEATHER_RESPONSE
        mock_gemini.return_value = "Sunny and 32°C."

        payload = {
            "message": "What is the weather?",
            "location": {"lat": 9.93, "lon": 78.12},
            "language": "unsupported_xyz",
        }
        response = client.post("/api/v1/chat", json=payload)
        assert response.status_code == 200
        data = response.json()
        assert data["language"] == "en"

        mock_gemini.assert_called_once()
        assert mock_gemini.call_args.kwargs.get("language") == "en"

    @patch("app.services.weather.client.WeatherAPIClient._request", new_callable=AsyncMock)
    @patch("app.services.chat_service.GeminiChatService.generate_response", new_callable=AsyncMock)
    def test_top_level_lat_lon_accepted(self, mock_gemini, mock_weather):
        mock_weather.return_value = MOCK_WEATHER_RESPONSE
        mock_gemini.return_value = "32°C."

        payload = {
            "message": "Weather?",
            "lat": 9.93,
            "lon": 78.12,
            "language": "ta",
        }
        response = client.post("/api/v1/chat", json=payload)
        assert response.status_code == 200
        data = response.json()
        assert data["language"] == "ta"

    def test_gemini_service_prompt_contains_tamil_instructions(self):
        from app.services.ai.gemini_service import _TAMIL_INSTRUCTION, _ENGLISH_INSTRUCTION
        assert "தமிழ்" in _TAMIL_INSTRUCTION
        assert "வெப்பநிலை" in _TAMIL_INSTRUCTION
        assert "English" in _ENGLISH_INSTRUCTION


# ---------------------------------------------------------------------------
# Alerts Multilingual Tests
# ---------------------------------------------------------------------------

class TestAlertsMultilingual:
    def _make_dummy_weather(self, temp: float = 42.0, rain: float = 85.0):
        current = WeatherCurrent(
            location=Location(lat=9.9252, lon=78.1198, city="Madurai"),
            temperature=temp,
            feels_like=temp + 3,
            humidity=75,
            wind_speed=8.0,
            wind_direction=180,
            description="Sunny",
            icon="//cdn.weatherapi.com/weather/64x64/day/113.png",
            uv_index=11.0,
            timestamp=1690000000,
        )
        forecast = WeatherForecast(
            location=Location(lat=9.9252, lon=78.1198, city="Madurai"),
            hourly=[],
            daily=[
                DailyForecast(
                    date="2026-09-12",
                    temp_min=26.0,
                    temp_max=temp,
                    humidity=80,
                    wind_speed=8.0,
                    description="Heavy rain",
                    icon="//cdn.weatherapi.com/weather/64x64/day/308.png",
                    sunrise=1690000000,
                    sunset=1690040000,
                    precipitation_probability=rain / 100.0,
                )
            ],
        )
        return current, forecast

    def test_alert_engine_tamil_localization(self):
        engine = AlertEngine()
        current, forecast = self._make_dummy_weather(temp=42.5, rain=85.0)

        # English
        en_alerts = engine.evaluate(current, forecast, language="en")
        assert any("Extreme Heat Alert" in a.title for a in en_alerts)
        assert any("42.5°C" in a.description for a in en_alerts)

        # Tamil
        ta_alerts = engine.evaluate(current, forecast, language="ta")
        assert any("அதிக வெப்ப எச்சரிக்கை" in a.title for a in ta_alerts)
        assert any("42.5°C" in a.description for a in ta_alerts)
        assert any("கனமழை அறிவுரை" in a.title for a in ta_alerts)
        assert any("85%" in a.description for a in ta_alerts)

    @patch("app.services.weather.service.WeatherService.get_alerts_smart", new_callable=AsyncMock)
    def test_alerts_route_accepts_language_param(self, mock_get_alerts):
        from app.schemas.alerts import AlertsResponse, Alert, AlertSeverity, AlertType
        mock_get_alerts.return_value = AlertsResponse(
            alerts=[
                Alert(
                    alert_id="sae-001",
                    alert_type=AlertType.HEAT,
                    severity=AlertSeverity.SEVERE,
                    title="அதிக வெப்ப எச்சரிக்கை",
                    description="அபாயகரமான அதிக வெப்பநிலை 42.0°C பதிவாகியுள்ளது.",
                    area="Madurai",
                    start_time=1690000000,
                )
            ],
            total=1,
        )
        response = client.get("/api/v1/alerts?lat=9.93&lon=78.12&language=ta")
        assert response.status_code == 200
        data = response.json()
        assert data["total"] == 1
        assert data["alerts"][0]["title"] == "அதிக வெப்ப எச்சரிக்கை"
        mock_get_alerts.assert_called_once_with(9.93, 78.12, language="ta")


# ---------------------------------------------------------------------------
# Advisories Multilingual Tests
# ---------------------------------------------------------------------------

class TestAdvisoryMultilingual:
    @patch("app.services.weather.service.WeatherService.get_current", new_callable=AsyncMock)
    @patch("app.services.weather.service.WeatherService.get_forecast", new_callable=AsyncMock)
    def test_advisory_tamil_route(self, mock_forecast, mock_current):
        loc = Location(lat=9.93, lon=78.12, city="Madurai")
        current = WeatherCurrent(
            location=loc,
            temperature=41.5,
            feels_like=45.0,
            humidity=60,
            wind_speed=5.0,
            wind_direction=180,
            description="Sunny",
            icon="//cdn.weatherapi.com/weather/64x64/day/113.png",
            uv_index=11.0,
            timestamp=1690000000,
        )
        forecast = WeatherForecast(
            location=loc,
            hourly=[],
            daily=[],
        )
        mock_current.return_value = current
        mock_forecast.return_value = forecast

        response = client.get("/api/v1/advisory?lat=9.93&lon=78.12&category=health&language=ta")
        assert response.status_code == 200
        data = response.json()
        assert data["total"] >= 1
        heat_adv = next(a for a in data["advisories"] if "வெப்ப" in a["title"])
        assert "41.5°C" in heat_adv["message"]
        assert "தண்ணீர்" in heat_adv["recommendation"]


# ---------------------------------------------------------------------------
# Climate Multilingual Tests
# ---------------------------------------------------------------------------

class TestClimateMultilingual:
    def test_climate_service_tamil_localization(self):
        service = ClimateService()
        en_res = service.get_climate(location="Madurai", year_from=2000, year_to=2023, language="en")
        ta_res = service.get_climate(location="Madurai", year_from=2000, year_to=2023, language="ta")

        # Numerical calculations must be identical
        assert en_res.temperature_anomaly == ta_res.temperature_anomaly
        assert en_res.rainfall_anomaly == ta_res.rainfall_anomaly
        assert en_res.temperature_comparison.current_value == ta_res.temperature_comparison.current_value

        # Season is localized in Tamil
        assert ta_res.season in ("குளிர்காலம்", "கோடைகாலம்", "தென்மேற்கு பருவமழை", "வடகிழக்கு பருவமழை")

        # Insight is localized in Tamil
        assert "வெப்பநிலை" in ta_res.insight
        assert "மழைப்பொழிவு" in ta_res.insight

    def test_climate_route_accepts_language_query(self):
        response = client.get("/api/v1/climate?location=Madurai&language=ta")
        assert response.status_code == 200
        data = response.json()
        assert data["location"] == "Madurai"
        assert "வெப்பநிலை" in data["insight"]
