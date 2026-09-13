"""
WeatherGPT — Reliability, AI Fallback, Error Handling & API Security Tests (Phase 10)
Covers:
  - Primary model (gemini-3.7-flash) success
  - Primary model 503 retry and recovery
  - Fallback model (gemini-3.6-flash) invocation and success
  - Primary 429 -> fallback success
  - Both primary and fallback failure (503 and 429)
  - Permanent Gemini error (401/403) without retry or fallback
  - Timeout handling
  - AFC disabled configuration
  - Same weather context passed to primary and fallback
  - Configured model selection (GEMINI_MODEL and GEMINI_FALLBACK_MODEL)
  - WeatherAPI failure distinction vs Gemini failure
  - Log and credential sanitization
  - WeatherAPIClient deduplication cache and forecast reuse
"""

import pytest
import asyncio
from unittest.mock import AsyncMock, MagicMock, patch
from fastapi.testclient import TestClient
from fastapi import HTTPException

from app.main import app
from app.core.config import settings
from app.services.ai.gemini_service import GeminiChatService
from app.services.weather.client import WeatherAPIClient
from app.core.logging import SensitiveDataFilter

client = TestClient(app)

MOCK_WEATHER = {
    "location": "Madurai",
    "temperature_c": 32.0,
    "feels_like_c": 35.0,
    "humidity_pct": 65,
    "wind_speed_ms": 3.5,
    "wind_direction_deg": 180,
    "condition": "Sunny",
}


# ===========================================================================
# 1. Gemini Primary & Fallback Reliability Tests
# ===========================================================================

class TestGeminiServiceReliability:
    @pytest.mark.asyncio
    async def test_afc_is_disabled_in_config(self):
        """Verify that AFC is explicitly disabled in the generate_content config."""
        service = GeminiChatService()
        mock_client = MagicMock()
        mock_response = MagicMock()
        mock_response.text = "Grounded weather reply"
        mock_client.models.generate_content.return_value = mock_response

        with patch.object(service, "_get_client", return_value=mock_client):
            with patch.object(service, "_api_key", "test-key"):
                res = await service.generate_response("How hot is it?", MOCK_WEATHER)
                assert res == "Grounded weather reply"
                mock_client.models.generate_content.assert_called_once()
                call_kwargs = mock_client.models.generate_content.call_args.kwargs
                assert "config" in call_kwargs
                config = call_kwargs["config"]
                assert config.automatic_function_calling.disable is True

    @pytest.mark.asyncio
    async def test_configured_model_and_fallback_selection(self):
        """Verify primary and fallback models are configurable from settings."""
        with patch.object(settings, "gemini_model", "gemini-test-primary"):
            with patch.object(settings, "gemini_fallback_model", "gemini-test-fallback"):
                service = GeminiChatService()
                assert service._model == "gemini-test-primary"
                assert service._fallback_model == "gemini-test-fallback"

    @pytest.mark.asyncio
    async def test_primary_gemini_success(self):
        """Primary model (gemini-3.7-flash) succeeds on first attempt."""
        service = GeminiChatService()
        mock_client = MagicMock()
        mock_response = MagicMock()
        mock_response.text = "Primary model answer"
        mock_client.models.generate_content.return_value = mock_response

        with patch.object(service, "_get_client", return_value=mock_client):
            with patch.object(service, "_api_key", "test-key"):
                res = await service.generate_response("What is the weather?", MOCK_WEATHER)
                assert res == "Primary model answer"
                assert mock_client.models.generate_content.call_count == 1
                assert mock_client.models.generate_content.call_args.kwargs["model"] == settings.gemini_model

    @pytest.mark.asyncio
    async def test_gemini_503_retries_once_and_succeeds(self):
        """When Gemini fails with 503 on attempt 1, it should retry once and succeed on primary."""
        service = GeminiChatService()
        mock_client = MagicMock()
        mock_response = MagicMock()
        mock_response.text = "Recovered after retry"

        error_503 = Exception("503 This model is currently experiencing high demand.")
        mock_client.models.generate_content.side_effect = [error_503, mock_response]

        with patch.object(service, "_get_client", return_value=mock_client):
            with patch.object(service, "_api_key", "test-key"):
                with patch("asyncio.sleep", new_callable=AsyncMock) as mock_sleep:
                    res = await service.generate_response("Question?", MOCK_WEATHER)
                    assert res == "Recovered after retry"
                    assert mock_client.models.generate_content.call_count == 2
                    mock_sleep.assert_awaited_once_with(1.0)

    @pytest.mark.asyncio
    async def test_primary_503_fails_fallback_succeeds(self):
        """When primary fails with 503 twice, fallback model (gemini-3.6-flash) succeeds with same context."""
        service = GeminiChatService()
        mock_client = MagicMock()
        mock_response = MagicMock()
        mock_response.text = "Fallback model answer"

        error_503 = Exception("503 UNAVAILABLE High demand")
        # Attempt 1 (primary), Attempt 2 (primary retry), Attempt 3 (fallback success)
        mock_client.models.generate_content.side_effect = [error_503, error_503, mock_response]

        with patch.object(service, "_get_client", return_value=mock_client):
            with patch.object(service, "_api_key", "test-key"):
                with patch("asyncio.sleep", new_callable=AsyncMock):
                    res = await service.generate_response("Question?", MOCK_WEATHER)
                    assert res == "Fallback model answer"
                    assert mock_client.models.generate_content.call_count == 3
                    # Verify third call used the fallback model
                    third_call_kwargs = mock_client.models.generate_content.call_args_list[2].kwargs
                    assert third_call_kwargs["model"] == settings.gemini_fallback_model
                    # Verify prompt with weather context is identical across calls
                    first_call_prompt = mock_client.models.generate_content.call_args_list[0].kwargs["contents"]
                    third_call_prompt = third_call_kwargs["contents"]
                    assert first_call_prompt == third_call_prompt
                    assert "Madurai" in third_call_prompt

    @pytest.mark.asyncio
    async def test_primary_429_fails_fallback_succeeds(self):
        """When primary fails with 429, fallback model is tried and succeeds."""
        service = GeminiChatService()
        mock_client = MagicMock()
        mock_response = MagicMock()
        mock_response.text = "Fallback recovered from 429"

        error_429 = Exception("429 RESOURCE_EXHAUSTED Quota exceeded")
        mock_client.models.generate_content.side_effect = [error_429, error_429, mock_response]

        with patch.object(service, "_get_client", return_value=mock_client):
            with patch.object(service, "_api_key", "test-key"):
                with patch("asyncio.sleep", new_callable=AsyncMock):
                    res = await service.generate_response("Question?", MOCK_WEATHER)
                    assert res == "Fallback recovered from 429"
                    assert mock_client.models.generate_content.call_count == 3
                    assert mock_client.models.generate_content.call_args_list[2].kwargs["model"] == settings.gemini_fallback_model

    @pytest.mark.asyncio
    async def test_both_primary_and_fallback_fail_503(self):
        """When both primary and fallback fail with 503, returns 503 'WeatherGPT is temporarily busy'."""
        service = GeminiChatService()
        mock_client = MagicMock()
        error_503 = Exception("503 This model is currently experiencing high demand.")
        # Primary attempt 1, primary attempt 2, fallback attempt 1
        mock_client.models.generate_content.side_effect = [error_503, error_503, error_503]

        with patch.object(service, "_get_client", return_value=mock_client):
            with patch.object(service, "_api_key", "test-key"):
                with patch("asyncio.sleep", new_callable=AsyncMock):
                    with pytest.raises(HTTPException) as exc_info:
                        await service.generate_response("Question?", MOCK_WEATHER)
                    assert exc_info.value.status_code == 503
                    assert exc_info.value.detail == "WeatherGPT is temporarily busy. Please try again."

    @pytest.mark.asyncio
    async def test_both_primary_and_fallback_fail_429(self):
        """When both primary and fallback fail with 429, returns 429 'WeatherGPT is temporarily rate-limited'."""
        service = GeminiChatService()
        mock_client = MagicMock()
        error_429 = Exception("429 RESOURCE_EXHAUSTED Quota exceeded")
        mock_client.models.generate_content.side_effect = [error_429, error_429, error_429]

        with patch.object(service, "_get_client", return_value=mock_client):
            with patch.object(service, "_api_key", "test-key"):
                with patch("asyncio.sleep", new_callable=AsyncMock):
                    with pytest.raises(HTTPException) as exc_info:
                        await service.generate_response("Question?", MOCK_WEATHER)
                    assert exc_info.value.status_code == 429
                    assert exc_info.value.detail == "WeatherGPT is temporarily rate-limited. Please try again later."

    @pytest.mark.asyncio
    async def test_permanent_auth_error_fails_immediately_without_fallback(self):
        """Permanent auth/config errors fail immediately with status 500 without retrying or fallback."""
        service = GeminiChatService()
        mock_client = MagicMock()
        error_auth = Exception("401 API_KEY_INVALID The provided API key is invalid.")
        mock_client.models.generate_content.side_effect = error_auth

        with patch.object(service, "_get_client", return_value=mock_client):
            with patch.object(service, "_api_key", "test-key"):
                with patch("asyncio.sleep", new_callable=AsyncMock) as mock_sleep:
                    with pytest.raises(HTTPException) as exc_info:
                        await service.generate_response("Question?", MOCK_WEATHER)
                    assert exc_info.value.status_code == 500
                    assert exc_info.value.detail == "AI service configuration error."
                    assert mock_client.models.generate_content.call_count == 1
                    mock_sleep.assert_not_called()

    @pytest.mark.asyncio
    async def test_timeout_handling_after_fallback(self):
        """When timeout occurs on both models, raises 504 'taking longer than expected'."""
        service = GeminiChatService()
        mock_client = MagicMock()
        error_timeout = Exception("504 DEADLINE_EXCEEDED Request timed out")
        mock_client.models.generate_content.side_effect = [error_timeout, error_timeout, error_timeout]

        with patch.object(service, "_get_client", return_value=mock_client):
            with patch.object(service, "_api_key", "test-key"):
                with patch("asyncio.sleep", new_callable=AsyncMock):
                    with pytest.raises(HTTPException) as exc_info:
                        await service.generate_response("Question?", MOCK_WEATHER)
                    assert exc_info.value.status_code == 504
                    assert exc_info.value.detail == "WeatherGPT is taking longer than expected. Please try again."


# ===========================================================================
# 2. Endpoint Distinction Tests (Gemini vs WeatherAPI)
# ===========================================================================

class TestEndpointDistinction:
    def test_gemini_503_returns_busy_detail_to_client(self):
        """POST /chat when Gemini is 503 returns 'WeatherGPT is temporarily busy. Please try again.'"""
        with patch(
            "app.services.weather.client.WeatherAPIClient._request",
            new_callable=AsyncMock,
            return_value={
                "location": {"name": "Madurai", "country": "India", "lat": 9.93, "lon": 78.12},
                "current": {"temp_c": 30.0, "feelslike_c": 32.0, "humidity": 60, "wind_kph": 10.0, "wind_degree": 90, "condition": {"text": "Clear"}},
            }
        ):
            with patch(
                "app.services.chat_service.GeminiChatService.generate_response",
                new_callable=AsyncMock,
                side_effect=HTTPException(status_code=503, detail="WeatherGPT is temporarily busy. Please try again.")
            ):
                resp = client.post("/api/v1/chat", json={"message": "Weather?", "location": {"lat": 9.93, "lon": 78.12}})
                assert resp.status_code == 503
                assert resp.json()["detail"] == "WeatherGPT is temporarily busy. Please try again."

    def test_weatherapi_503_returns_weather_unavailable_detail(self):
        """POST /chat when WeatherAPI is down returns 'We're unable to retrieve current weather right now. Please try again.'"""
        with patch(
            "app.services.weather.client.WeatherAPIClient._request",
            new_callable=AsyncMock,
            side_effect=HTTPException(status_code=503, detail="Weather provider is currently unavailable.")
        ):
            resp = client.post("/api/v1/chat", json={"message": "Weather?", "location": {"lat": 9.93, "lon": 78.12}})
            assert resp.status_code == 503
            assert resp.json()["detail"] == "We're unable to retrieve current weather right now. Please try again."

    def test_chat_returns_structured_weather_card(self):
        """POST /chat for normal weather query returns structured weather_summary card."""
        with patch(
            "app.services.weather.client.WeatherAPIClient._request",
            new_callable=AsyncMock,
            return_value={
                "location": {"name": "Madurai", "country": "India", "lat": 9.9252, "lon": 78.1198},
                "current": {"temp_c": 29.0, "feelslike_c": 31.0, "humidity": 64, "wind_kph": 14.0, "wind_degree": 180, "condition": {"text": "Overcast", "icon": "//cdn.weatherapi.com/weather/64x64/day/122.png"}},
            }
        ):
            with patch(
                "app.services.chat_service.GeminiChatService.generate_response",
                new_callable=AsyncMock,
                return_value="It is currently 29°C in Madurai."
            ):
                resp = client.post("/api/v1/chat", json={"message": "What is the temperature?", "lat": 9.9252, "lon": 78.1198})
                assert resp.status_code == 200
                data = resp.json()
                assert data["message"] == "It is currently 29°C in Madurai."
                assert "weather_summary" in data
                summary = data["weather_summary"]
                assert summary["location"] == "Madurai"
                assert summary["temperature_c"] == 29.0
                assert summary["feels_like_c"] == 31.0
                assert summary["condition"] == "Overcast"
                assert summary["humidity_pct"] == 64
                assert summary["wind_kph"] == 14.0

    def test_chat_returns_structured_forecast_card(self):
        """POST /chat for forecast query returns structured forecast_summary card."""
        with patch(
            "app.services.weather.client.WeatherAPIClient._request",
            new_callable=AsyncMock,
            side_effect=[
                # current
                {
                    "location": {"name": "Madurai", "country": "India", "lat": 9.9252, "lon": 78.1198},
                    "current": {"temp_c": 29.0, "feelslike_c": 31.0, "humidity": 64, "wind_kph": 14.0, "wind_degree": 180, "condition": {"text": "Overcast"}},
                },
                # forecast
                {
                    "location": {"name": "Madurai", "country": "India", "lat": 9.9252, "lon": 78.1198},
                    "forecast": {
                        "forecastday": [
                            {
                                "date": "2026-09-13",
                                "day": {"mintemp_c": 24.0, "maxtemp_c": 32.0, "avghumidity": 70, "maxwind_kph": 15.0, "condition": {"text": "Partly Cloudy"}, "daily_chance_of_rain": 20},
                                "hour": [
                                    {"time_epoch": 1789286400, "temp_c": 29.0, "feelslike_c": 31.0, "humidity": 65, "wind_kph": 12.0, "condition": {"text": "Partly Cloudy"}, "chance_of_rain": 10},
                                    {"time_epoch": 1789290000, "temp_c": 31.0, "feelslike_c": 33.0, "humidity": 60, "wind_kph": 14.0, "condition": {"text": "Sunny"}, "chance_of_rain": 5},
                                    {"time_epoch": 1789293600, "temp_c": 30.0, "feelslike_c": 32.0, "humidity": 62, "wind_kph": 13.0, "condition": {"text": "Cloudy"}, "chance_of_rain": 15},
                                    {"time_epoch": 1789297200, "temp_c": 27.0, "feelslike_c": 29.0, "humidity": 70, "wind_kph": 10.0, "condition": {"text": "Rain"}, "chance_of_rain": 60},
                                ]
                            }
                        ]
                    }
                }
            ]
        ):
            with patch(
                "app.services.chat_service.GeminiChatService.generate_response",
                new_callable=AsyncMock,
                return_value="Tomorrow will see scattered showers."
            ):
                resp = client.post("/api/v1/chat", json={"message": "What is tomorrow's forecast?", "lat": 9.9252, "lon": 78.1198})
                assert resp.status_code == 200
                data = resp.json()
                assert "forecast_summary" in data
                f_summary = data["forecast_summary"]
                assert f_summary is not None
                assert len(f_summary["items"]) >= 2


# ===========================================================================
# 3. Security and Log Sanitization Tests
# ===========================================================================

class TestLogSanitization:
    def test_sensitive_data_filter_redacts_query_param(self):
        """SensitiveDataFilter must redact ?key=... and &key=... from log messages and args."""
        import logging
        flt = SensitiveDataFilter(sensitive_tokens=["MY_SECRET_KEY_xyz"])
        
        record = logging.LogRecord(
            name="test", level=logging.INFO, pathname="", lineno=0,
            msg="HTTP Request: GET https://api.weatherapi.com/v1/current.json?q=Madurai&key=MY_SECRET_KEY_xyz",
            args=(), exc_info=None
        )
        assert flt.filter(record)
        assert "MY_SECRET_KEY_xyz" not in record.msg
        assert "key=***" in record.msg

    def test_sensitive_data_filter_redacts_args(self):
        """SensitiveDataFilter redacts URLs in record.args."""
        import logging
        flt = SensitiveDataFilter(sensitive_tokens=["TOP_SECRET"])
        
        record = logging.LogRecord(
            name="httpx", level=logging.INFO, pathname="", lineno=0,
            msg="HTTP Request: %s %s",
            args=("GET", "https://api.weatherapi.com/v1/forecast.json?days=1&key=TOP_SECRET"),
            exc_info=None
        )
        assert flt.filter(record)
        assert "TOP_SECRET" not in str(record.args)
        assert "key=***" in str(record.args)


# ===========================================================================
# 4. WeatherAPIClient Deduplication & Forecast Reuse Cache Tests
# ===========================================================================

class TestWeatherDeduplicationCache:
    @pytest.mark.asyncio
    async def test_duplicate_requests_within_ttl_hit_cache(self):
        """Consecutive requests for same endpoint & params should hit in-memory cache."""
        client = WeatherAPIClient()
        WeatherAPIClient.clear_cache()

        mock_data = {"current": {"temp_c": 28.0}, "location": {"name": "Madurai"}}

        with patch("httpx.AsyncClient.get") as mock_get:
            mock_resp = MagicMock()
            mock_resp.status_code = 200
            mock_resp.json.return_value = mock_data
            mock_get.return_value = mock_resp

            # First request: should hit network
            res1 = await client.get_current("9.93,78.12")
            assert res1 == mock_data
            assert mock_get.call_count == 1

            # Second request within 30s: should hit in-memory cache
            res2 = await client.get_current("9.93,78.12")
            assert res2 == mock_data
            assert mock_get.call_count == 1  # Deduplicated!

    @pytest.mark.asyncio
    async def test_forecast_cache_satisfies_current_weather(self):
        """A cached forecast response satisfies a subsequent current weather query for the same location."""
        client = WeatherAPIClient()
        WeatherAPIClient.clear_cache()

        mock_forecast = {
            "location": {"name": "Madurai"},
            "current": {"temp_c": 29.0, "feelslike_c": 31.0},
            "forecast": {"forecastday": []}
        }

        with patch("httpx.AsyncClient.get") as mock_get:
            mock_resp = MagicMock()
            mock_resp.status_code = 200
            mock_resp.json.return_value = mock_forecast
            mock_get.return_value = mock_resp

            # 1. Fetch forecast
            await client.get_forecast("9.9252,78.1198", days=7)
            assert mock_get.call_count == 1

            # 2. Fetch current weather for same location -> should reuse forecast cache
            current = await client.get_current("9.9252,78.1198")
            assert current["location"]["name"] == "Madurai"
            assert current["current"]["temp_c"] == 29.0
            assert mock_get.call_count == 1  # Reused from forecast! Zero extra network calls!

    @pytest.mark.asyncio
    async def test_clear_cache_forces_network_call(self):
        """Clearing the cache forces a new network request."""
        client = WeatherAPIClient()
        WeatherAPIClient.clear_cache()

        mock_data = {"current": {"temp_c": 28.0}, "location": {"name": "Madurai"}}

        with patch("httpx.AsyncClient.get") as mock_get:
            mock_resp = MagicMock()
            mock_resp.status_code = 200
            mock_resp.json.return_value = mock_data
            mock_get.return_value = mock_resp

            await client.get_current("9.93,78.12")
            assert mock_get.call_count == 1

            WeatherAPIClient.clear_cache()
            await client.get_current("9.93,78.12")
            assert mock_get.call_count == 2
