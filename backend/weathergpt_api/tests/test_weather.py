import pytest
from unittest.mock import AsyncMock, patch
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

MOCK_CURRENT_RESPONSE = {
    "location": {
        "name": "Madurai",
        "region": "Tamil Nadu",
        "country": "India",
        "lat": 9.93,
        "lon": 78.12,
        "tz_id": "Asia/Kolkata"
    },
    "current": {
        "last_updated_epoch": 1690000000,
        "temp_c": 32.0,
        "condition": {
            "text": "Sunny",
            "icon": "//cdn.weatherapi.com/weather/64x64/day/113.png"
        },
        "wind_kph": 15.0,
        "wind_degree": 90,
        "humidity": 45,
        "feelslike_c": 34.0,
        "vis_km": 10.0,
        "uv": 8.0
    }
}

MOCK_FORECAST_RESPONSE = {
    "location": MOCK_CURRENT_RESPONSE["location"],
    "forecast": {
        "forecastday": [
            {
                "date": "2023-08-25",
                "day": {
                    "maxtemp_c": 35.0,
                    "mintemp_c": 26.0,
                    "maxwind_kph": 18.0,
                    "avghumidity": 50,
                    "daily_chance_of_rain": 20,
                    "condition": {
                        "text": "Partly cloudy",
                        "icon": "//cdn.weatherapi.com/weather/64x64/day/116.png"
                    },
                    "uv": 9.0
                },
                "astro": {
                    "sunrise_epoch": 1690000000,
                    "sunset_epoch": 1690040000
                },
                "hour": [
                    {
                        "time_epoch": 1690000000,
                        "temp_c": 28.0,
                        "condition": {
                            "text": "Clear",
                            "icon": "//cdn.weatherapi.com/weather/64x64/night/113.png"
                        },
                        "wind_kph": 10.0,
                        "humidity": 60,
                        "feelslike_c": 30.0,
                        "chance_of_rain": 0
                    }
                ]
            }
        ]
    }
}

# Phase 6: The smart engine calls get_current + get_forecast + get_alerts concurrently.
# We supply a full forecast response that embeds the native alert for test_get_alerts.
MOCK_ALERTS_FORECAST_RESPONSE = {
    "location": MOCK_CURRENT_RESPONSE["location"],
    "forecast": {
        "forecastday": [
            {
                "date": "2023-08-25",
                "day": {
                    "maxtemp_c": 32.0, "mintemp_c": 24.0,
                    "maxwind_kph": 15.0, "avghumidity": 50,
                    "daily_chance_of_rain": 20,
                    "condition": {"text": "Sunny", "icon": ""},
                    "uv": 5.0,
                },
                "astro": {"sunrise_epoch": 1690000000, "sunset_epoch": 1690040000},
                "hour": [],
            }
        ]
    },
    # Native WeatherAPI alert embedded in the forecast (for test_get_alerts)
    "alerts": {
        "alert": [
            {
                "headline": "Heat Wave Warning",
                "severity": "Severe",
                "urgency": "Expected",
                "event": "Heat Wave",
                "effective": "2023-08-25T10:00:00+05:30",
                "expires": "2023-08-26T18:00:00+05:30",
                "desc": "Severe heat wave conditions expected.",
                "instruction": "Avoid outdoor activities during afternoon.",
            }
        ]
    },
}

MOCK_SEARCH_RESPONSE = [
    {
        "id": 1,
        "name": "Madurai",
        "region": "Tamil Nadu",
        "country": "India",
        "lat": 9.93,
        "lon": 78.12,
        "url": "madurai-tamil-nadu-india"
    }
]

@pytest.fixture
def mock_request():
    with patch("app.services.weather.client.WeatherAPIClient._request", new_callable=AsyncMock) as mock:
        yield mock

def test_health_check():
    response = client.get("/api/v1/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok", "service": "weathergpt-api"}

def test_get_current_weather(mock_request):
    mock_request.return_value = MOCK_CURRENT_RESPONSE
    response = client.get("/api/v1/weather/current?lat=9.93&lon=78.12")
    assert response.status_code == 200
    data = response.json()
    assert data["location"]["city"] == "Madurai"
    assert data["temperature"] == 32.0
    # wind_speed should be in m/s (15 kph = ~4.17)
    assert round(data["wind_speed"], 2) == 4.17

def test_get_weather_forecast(mock_request):
    mock_request.return_value = MOCK_FORECAST_RESPONSE
    response = client.get("/api/v1/weather/forecast?lat=9.93&lon=78.12&days=3")
    assert response.status_code == 200
    data = response.json()
    assert len(data["daily"]) == 1
    assert data["daily"][0]["temp_max"] == 35.0
    assert len(data["hourly"]) == 1

def test_get_hourly_forecast(mock_request):
    # The endpoint fetches forecast for 2 days internally
    mock_request.return_value = MOCK_FORECAST_RESPONSE
    
    # We mock time.time() inside the service to match our mock data epoch
    with patch("app.services.weather.service.time.time", return_value=1689000000):
        response = client.get("/api/v1/weather/hourly?lat=9.93&lon=78.12")
        assert response.status_code == 200
        data = response.json()
        assert len(data) == 1
        assert data[0]["temperature"] == 28.0

def test_search_locations(mock_request):
    mock_request.return_value = MOCK_SEARCH_RESPONSE
    response = client.get("/api/v1/weather/search?q=Madurai")
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 1
    assert data[0]["name"] == "Madurai"
    assert data[0]["country"] == "India"

def test_get_alerts(mock_request):
    """
    Phase 6 upgrade: the /alerts route now calls get_alerts_smart() which:
      1. Fetches current weather
      2. Fetches 1-day forecast (with alerts=yes for passthrough)
      3. Runs deterministic engine
      4. Merges with native WeatherAPI alerts
    
    This test supplies MOCK_ALERTS_FORECAST_RESPONSE (which has a native Heat Wave
    alert embedded) and verifies the endpoint surfaces it through the merge logic.
    The data has temp=32°C (below heat threshold=38), so no engine heat alert fires,
    and the native alert from WeatherAPI is passed through.
    """
    def side_effect(endpoint, params):
        if "forecast" in endpoint:
            return MOCK_ALERTS_FORECAST_RESPONSE
        return MOCK_CURRENT_RESPONSE

    mock_request.side_effect = side_effect
    response = client.get("/api/v1/alerts?lat=9.93&lon=78.12")
    assert response.status_code == 200
    data = response.json()
    # The native "Heat Wave Warning" from WeatherAPI should be present
    titles = [a["title"] for a in data["alerts"]]
    assert "Heat Wave Warning" in titles
    heat_wave = next(a for a in data["alerts"] if a["title"] == "Heat Wave Warning")
    assert heat_wave["severity"] == "severe"
    assert heat_wave["alert_type"] == "heatwave"


def test_get_alerts_empty(mock_request):
    """
    Phase 6 upgrade: with mild weather (no thresholds exceeded) and no native
    WeatherAPI alerts, the endpoint should return an empty alert list.
    """
    mild_forecast = {
        "location": MOCK_CURRENT_RESPONSE["location"],
        "forecast": {
            "forecastday": [
                {
                    "date": "2023-08-25",
                    "day": {
                        "maxtemp_c": 25.0, "mintemp_c": 18.0,
                        "maxwind_kph": 15.0, "avghumidity": 50,
                        "daily_chance_of_rain": 20,
                        "condition": {"text": "Sunny", "icon": ""},
                        "uv": 4.0,
                    },
                    "astro": {"sunrise_epoch": 0, "sunset_epoch": 0},
                    "hour": [],
                }
            ]
        },
        "alerts": {"alert": []},
    }
    mild_current = {
        "location": MOCK_CURRENT_RESPONSE["location"],
        "current": {
            "last_updated_epoch": 1690000000,
            "temp_c": 24.0,
            "condition": {"text": "Sunny", "icon": ""},
            "wind_kph": 15.0,
            "wind_degree": 90,
            "humidity": 45,
            "feelslike_c": 24.0,
            "vis_km": 10.0,
            "uv": 3.0,
        },
    }

    def side_effect(endpoint, params):
        if "forecast" in endpoint:
            return mild_forecast
        return mild_current

    mock_request.side_effect = side_effect
    response = client.get("/api/v1/alerts?lat=9.93&lon=78.12")
    assert response.status_code == 200
    data = response.json()
    assert data["total"] == 0
    assert data["alerts"] == []

from fastapi import HTTPException
def test_provider_error(mock_request):
    mock_request.side_effect = HTTPException(status_code=503, detail="Weather provider is currently unavailable.")
    response = client.get("/api/v1/weather/current?lat=9.93&lon=78.12")
    assert response.status_code == 503
    assert response.json()["detail"] == "Weather provider is currently unavailable."
