"""
WeatherGPT — Reliability, Error Handling & API Logging Fix Tests
Covers:
  - Gemini 503 retry behavior (succeeds on attempt 2)
  - Gemini 503 exhaustion (fails after 1 retry with distinguished message)
  - Gemini 429 rate limiting (no retry, distinct 429 message)
  - AFC disabled configuration check
  - WeatherAPI failure distinction vs Gemini failure
  - Log and credential sanitization
  - WeatherAPIClient deduplication cache
"""

import pytest
import asyncio
from unittest.mock import AsyncMock, MagicMock, patch
from fastapi.testclient import TestClient
from fastapi import HTTPException

from app.main import app
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
# 1. Gemini Service Unit Tests: 503, Retry, 429, AFC
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
    async def test_gemini_503_retries_once_and_succeeds(self):
        """When Gemini fails with 503 on attempt 1, it should retry once and succeed."""
        service = GeminiChatService()
        mock_client = MagicMock()
        mock_response = MagicMock()
        mock_response.text = "Recovered after retry"

        # Attempt 1: 503 error; Attempt 2: success
        error_503 = Exception("503 This model is currently experiencing high demand.")
        mock_client.models.generate_content.side_effect = [error_503, mock_response]

        with patch.object(service, "_get_client", return_value=mock_client):
            with patch.object(service, "_api_key", "test-key"):
                with patch("asyncio.sleep", new_callable=AsyncMock) as mock_sleep:
                    res = await service.generate_response("Question?", MOCK_WEATHER)
                    assert res == "Recovered after retry"
                    assert mock_client.models.generate_content.call_count == 2
                    mock_sleep.assert_awaited_once_with(1.5)

    @pytest.mark.asyncio
    async def test_gemini_503_retries_once_and_fails_with_busy_message(self):
        """When Gemini 503 persists after 1 retry, returns 503 'temporarily busy'."""
        service = GeminiChatService()
        mock_client = MagicMock()
        error_503 = Exception("503 This model is currently experiencing high demand.")
        mock_client.models.generate_content.side_effect = [error_503, error_503]

        with patch.object(service, "_get_client", return_value=mock_client):
            with patch.object(service, "_api_key", "test-key"):
                with patch("asyncio.sleep", new_callable=AsyncMock):
                    with pytest.raises(HTTPException) as exc_info:
                        await service.generate_response("Question?", MOCK_WEATHER)
                    assert exc_info.value.status_code == 503
                    assert exc_info.value.detail == "WeatherGPT is temporarily busy. Please try again."
                    assert mock_client.models.generate_content.call_count == 2

    @pytest.mark.asyncio
    async def test_gemini_429_does_not_retry_and_returns_limit_message(self):
        """Gemini 429 quota exhaustion fails immediately without retry."""
        service = GeminiChatService()
        mock_client = MagicMock()
        error_429 = Exception("429 RESOURCE_EXHAUSTED Quota exceeded.")
        mock_client.models.generate_content.side_effect = error_429

        with patch.object(service, "_get_client", return_value=mock_client):
            with patch.object(service, "_api_key", "test-key"):
                with patch("asyncio.sleep", new_callable=AsyncMock) as mock_sleep:
                    with pytest.raises(HTTPException) as exc_info:
                        await service.generate_response("Question?", MOCK_WEATHER)
                    assert exc_info.value.status_code == 429
                    assert exc_info.value.detail == "WeatherGPT request limit reached. Please try again later."
                    assert mock_client.models.generate_content.call_count == 1
                    mock_sleep.assert_not_called()


# ===========================================================================
# 2. Endpoint Distinction Tests (Gemini vs WeatherAPI)
# ===========================================================================

class TestEndpointDistinction:
    def test_gemini_503_returns_busy_detail_to_client(self):
        """POST /chat when Gemini is 503 returns 'WeatherGPT is temporarily busy.'"""
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
        """POST /chat when WeatherAPI is down returns 'Weather service is temporarily unavailable.'"""
        with patch(
            "app.services.weather.client.WeatherAPIClient._request",
            new_callable=AsyncMock,
            side_effect=HTTPException(status_code=503, detail="Weather provider is currently unavailable.")
        ):
            resp = client.post("/api/v1/chat", json={"message": "Weather?", "location": {"lat": 9.93, "lon": 78.12}})
            assert resp.status_code == 503
            assert resp.json()["detail"] == "Weather service is temporarily unavailable."


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
# 4. WeatherAPIClient Deduplication Cache Tests
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
            assert mock_get.call_count == 1  # Still 1! Deduplicated!

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
