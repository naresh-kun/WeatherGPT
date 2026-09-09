"""
WeatherGPT — Backend Chat Tests (Phase 5)

Tests for POST /api/v1/chat covering:
  - Valid chat request with location → Gemini response
  - Weather context retrieval via WeatherService
  - Missing Gemini API key → 503
  - Gemini API failure → 503
  - Weather provider failure → 503
  - Invalid/empty message → 400/422
  - Invalid coordinates → 400
  - No location → uses default location
  - Timeout/error handling

All external calls (WeatherAPIClient, Gemini SDK) are mocked.
No live network connections are made.
"""

import pytest
from unittest.mock import AsyncMock, MagicMock, patch
from fastapi.testclient import TestClient
from fastapi import HTTPException
from app.main import app

client = TestClient(app)

# ---------------------------------------------------------------------------
# Shared mock data
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
        "temp_c": 31.0,
        "condition": {"text": "Partly cloudy", "icon": "//cdn.weatherapi.com/weather/64x64/day/116.png"},
        "wind_kph": 14.0,
        "wind_degree": 180,
        "humidity": 68,
        "feelslike_c": 34.0,
        "vis_km": 10.0,
        "uv": 7.0,
    },
}

GEMINI_REPLY = "It is currently 31°C and partly cloudy in Madurai with 68% humidity."

VALID_CHAT_BODY = {
    "message": "What is the weather like?",
    "location": {"lat": 9.93, "lon": 78.12},
}


# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------

@pytest.fixture
def mock_weather_client():
    """Mock WeatherAPIClient._request so no live HTTP calls are made."""
    with patch(
        "app.services.weather.client.WeatherAPIClient._request",
        new_callable=AsyncMock,
    ) as mock:
        mock.return_value = MOCK_WEATHER_RESPONSE
        yield mock


@pytest.fixture
def mock_gemini_ok():
    """Mock GeminiChatService.generate_response to return a canned reply."""
    with patch(
        "app.services.chat_service.GeminiChatService.generate_response",
        new_callable=AsyncMock,
    ) as mock:
        mock.return_value = GEMINI_REPLY
        yield mock


@pytest.fixture
def mock_gemini_fail():
    """Mock GeminiChatService.generate_response to raise 503."""
    with patch(
        "app.services.chat_service.GeminiChatService.generate_response",
        new_callable=AsyncMock,
    ) as mock:
        mock.side_effect = HTTPException(
            status_code=503, detail="AI assistant is temporarily unavailable. Please try again."
        )
        yield mock


@pytest.fixture
def mock_gemini_no_key():
    """Mock GeminiChatService.generate_response to raise 503 (missing key)."""
    with patch(
        "app.services.chat_service.GeminiChatService.generate_response",
        new_callable=AsyncMock,
    ) as mock:
        mock.side_effect = HTTPException(
            status_code=503, detail="AI service is not configured. Contact the administrator."
        )
        yield mock


# ---------------------------------------------------------------------------
# Tests: valid requests
# ---------------------------------------------------------------------------

class TestChatValid:
    def test_valid_request_returns_ai_response(self, mock_weather_client, mock_gemini_ok):
        """A well-formed request returns the Gemini-generated message."""
        response = client.post("/api/v1/chat", json=VALID_CHAT_BODY)
        assert response.status_code == 200
        data = response.json()
        assert data["message"] == GEMINI_REPLY
        assert "conversation_id" in data
        assert data["language"] == "en"
        assert isinstance(data["suggestions"], list)

    def test_weather_context_is_fetched_for_location(self, mock_weather_client, mock_gemini_ok):
        """WeatherAPIClient._request is called for the provided coordinates."""
        response = client.post("/api/v1/chat", json=VALID_CHAT_BODY)
        assert response.status_code == 200
        mock_weather_client.assert_called_once()

    def test_conversation_id_preserved(self, mock_weather_client, mock_gemini_ok):
        """If a conversation_id is supplied it appears in the response."""
        body = {**VALID_CHAT_BODY, "conversation_id": "conv-test-123"}
        response = client.post("/api/v1/chat", json=body)
        assert response.status_code == 200
        assert response.json()["conversation_id"] == "conv-test-123"

    def test_conversation_id_auto_generated_when_absent(self, mock_weather_client, mock_gemini_ok):
        """If conversation_id is omitted the backend generates one."""
        response = client.post("/api/v1/chat", json=VALID_CHAT_BODY)
        assert response.status_code == 200
        conv_id = response.json()["conversation_id"]
        assert conv_id  # non-empty
        assert conv_id != "stub-id"  # not the old stub value

    def test_no_location_uses_default(self, mock_weather_client, mock_gemini_ok):
        """When no location is provided the request still succeeds using the default."""
        body = {"message": "How hot is it?"}
        response = client.post("/api/v1/chat", json=body)
        assert response.status_code == 200
        mock_weather_client.assert_called_once()

    def test_gemini_is_called_with_weather_context(self, mock_weather_client, mock_gemini_ok):
        """GeminiChatService.generate_response is called with weather_context dict."""
        response = client.post("/api/v1/chat", json=VALID_CHAT_BODY)
        assert response.status_code == 200
        mock_gemini_ok.assert_called_once()
        call_kwargs = mock_gemini_ok.call_args
        # weather_context should be in kwargs
        weather_ctx = call_kwargs.kwargs.get("weather_context") or call_kwargs.args[1]
        assert "temperature_c" in weather_ctx
        assert "condition" in weather_ctx
        assert weather_ctx["temperature_c"] == 31.0

    def test_gemini_model_is_gemini_3_7_flash(self):
        """Verify that GeminiChatService is configured with gemini-3.7-flash."""
        from app.services.ai.gemini_service import GeminiChatService
        from app.core.config import settings
        service = GeminiChatService()
        assert service._model == "gemini-3.7-flash"
        assert settings.gemini_model == "gemini-3.7-flash"


# ---------------------------------------------------------------------------
# Tests: validation errors
# ---------------------------------------------------------------------------

class TestChatValidation:
    def test_empty_message_returns_400(self, mock_weather_client, mock_gemini_ok):
        """An empty string message is rejected with HTTP 400."""
        response = client.post("/api/v1/chat", json={"message": "   ", "location": {"lat": 9.93, "lon": 78.12}})
        assert response.status_code == 400
        assert "empty" in response.json()["detail"].lower()

    def test_missing_message_field_returns_422(self):
        """A request without the 'message' field fails schema validation (422)."""
        response = client.post("/api/v1/chat", json={"location": {"lat": 9.93, "lon": 78.12}})
        assert response.status_code == 422

    def test_invalid_coordinates_returns_400(self, mock_weather_client, mock_gemini_ok):
        """Out-of-range coordinates are rejected with HTTP 400."""
        response = client.post(
            "/api/v1/chat",
            json={"message": "Rain?", "location": {"lat": 999, "lon": 78.12}},
        )
        assert response.status_code == 400

    def test_non_numeric_coordinates_returns_400(self, mock_weather_client, mock_gemini_ok):
        """Non-numeric lat/lon is rejected with HTTP 400."""
        response = client.post(
            "/api/v1/chat",
            json={"message": "Rain?", "location": {"lat": "abc", "lon": 78.12}},
        )
        assert response.status_code == 400


# ---------------------------------------------------------------------------
# Tests: provider failures
# ---------------------------------------------------------------------------

class TestChatProviderFailures:
    def test_gemini_missing_key_returns_503(self, mock_weather_client, mock_gemini_no_key):
        """Missing Gemini API key → 503 (no secrets exposed in response)."""
        response = client.post("/api/v1/chat", json=VALID_CHAT_BODY)
        assert response.status_code == 503
        body = response.json()["detail"]
        # Key must NOT appear in the response
        assert "GEMINI_API_KEY" not in body
        assert "sk-" not in body

    def test_gemini_api_failure_returns_503(self, mock_weather_client, mock_gemini_fail):
        """Gemini API failure → 503 with a user-friendly message."""
        response = client.post("/api/v1/chat", json=VALID_CHAT_BODY)
        assert response.status_code == 503
        assert "unavailable" in response.json()["detail"].lower()

    def test_weather_provider_failure_returns_503(self, mock_gemini_ok):
        """If WeatherAPI fails the chat endpoint returns 503."""
        with patch(
            "app.services.weather.client.WeatherAPIClient._request",
            new_callable=AsyncMock,
        ) as mock_wx:
            mock_wx.side_effect = HTTPException(
                status_code=503, detail="Weather provider is currently unavailable."
            )
            response = client.post("/api/v1/chat", json=VALID_CHAT_BODY)
        assert response.status_code == 503

    def test_weather_network_error_returns_503(self, mock_gemini_ok):
        """Network-level weather failure surfaces as 503 without exposing internals."""
        with patch(
            "app.services.weather.client.WeatherAPIClient._request",
            new_callable=AsyncMock,
        ) as mock_wx:
            mock_wx.side_effect = Exception("Connection refused")
            response = client.post("/api/v1/chat", json=VALID_CHAT_BODY)
        assert response.status_code == 503
        assert "Connection refused" not in response.json()["detail"]
