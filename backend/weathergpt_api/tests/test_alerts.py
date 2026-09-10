"""
WeatherGPT — Backend Alert Engine Tests  [Phase 6]

Tests for the Smart Alert Engine covering every rule and edge case:

Alert rule tests:
  - Normal temperature → no heat alert
  - Heat warning threshold → moderate heat alert
  - Extreme heat → severe heat alert
  - Low rain probability → no rain alert
  - High rain probability → rain alert
  - Normal wind → no wind alert
  - Strong wind → moderate wind alert
  - Dangerous wind → severe wind alert
  - Normal UV → no UV alert
  - High UV → moderate UV alert
  - Extreme UV → severe UV alert
  - Clear condition → no thunder alert
  - Thunderstorm condition → thunderstorm alert
  - Multiple alerts simultaneously
  - No alerts (all clear)
  - Missing/None optional fields (graceful handling)

API endpoint tests:
  - GET /api/v1/alerts returns smart alerts
  - GET /api/v1/alerts with WeatherAPI failure → 503
  - GET /api/v1/advisory returns real advisories
  - GET /api/v1/advisory with category filter

All external calls (WeatherAPIClient) are mocked.
No live network connections are made.
"""

from typing import Optional
import pytest
from unittest.mock import AsyncMock, patch
from fastapi.testclient import TestClient
from fastapi import HTTPException

from app.main import app
from app.services.alerts.engine import AlertEngine
from app.schemas.weather import WeatherCurrent, WeatherForecast, Location, DailyForecast, HourlyForecast
from app.core.config import settings

client = TestClient(app)

# ---------------------------------------------------------------------------
# Helper: build WeatherCurrent fixtures
# ---------------------------------------------------------------------------

def _make_current(
    *,
    temp_c: float = 25.0,
    wind_kph: float = 10.0,
    uv: float = 3.0,
    condition: str = "Sunny",
    city: str = "TestCity",
    condition_code: Optional[int] = None,
) -> WeatherCurrent:
    """Build a minimal WeatherCurrent for engine tests."""
    return WeatherCurrent(
        location=Location(lat=9.93, lon=78.12, city=city),
        temperature=temp_c,
        feels_like=temp_c - 1,
        humidity=50,
        wind_speed=wind_kph / 3.6,   # engine converts back to kph internally
        wind_direction=180,
        description=condition,
        icon="//cdn.example.com/sunny.png",
        uv_index=uv,
        visibility=10.0,
        condition_code=condition_code,
        timestamp=1690000000,
    )


def _make_forecast(
    *,
    rain_pct: float = 0.0,
    wind_kph: float = 10.0,
) -> WeatherForecast:
    """Build a minimal WeatherForecast for engine tests."""
    return WeatherForecast(
        location=Location(lat=9.93, lon=78.12, city="TestCity"),
        daily=[
            DailyForecast(
                date="2026-09-10",
                temp_min=20.0,
                temp_max=30.0,
                humidity=50,
                wind_speed=wind_kph / 3.6,
                description="Partly cloudy",
                icon="",
                sunrise=0,
                sunset=0,
                precipitation_probability=rain_pct / 100.0,
            )
        ],
        hourly=[],
        units="metric",
    )


# ---------------------------------------------------------------------------
# Shared mock WeatherAPI response for HTTP tests
# ---------------------------------------------------------------------------

MOCK_CURRENT_RESPONSE = {
    "location": {
        "name": "Madurai", "region": "Tamil Nadu", "country": "India",
        "lat": 9.93, "lon": 78.12, "tz_id": "Asia/Kolkata",
    },
    "current": {
        "last_updated_epoch": 1690000000,
        "temp_c": 32.0,
        "condition": {"text": "Sunny", "icon": ""},
        "wind_kph": 20.0,
        "wind_degree": 90,
        "humidity": 45,
        "feelslike_c": 34.0,
        "vis_km": 10.0,
        "uv": 5.0,
    },
}

MOCK_FORECAST_RESPONSE = {
    "location": MOCK_CURRENT_RESPONSE["location"],
    "forecast": {
        "forecastday": [
            {
                "date": "2026-09-10",
                "day": {
                    "maxtemp_c": 33.0, "mintemp_c": 24.0,
                    "maxwind_kph": 22.0, "avghumidity": 50,
                    "daily_chance_of_rain": 30,
                    "condition": {"text": "Sunny", "icon": ""},
                    "uv": 5.0,
                },
                "astro": {"sunrise_epoch": 1690000000, "sunset_epoch": 1690040000},
                "hour": [
                    {
                        "time_epoch": 1690000000,
                        "temp_c": 28.0, "feelslike_c": 30.0,
                        "humidity": 50,
                        "wind_kph": 20.0,
                        "condition": {"text": "Sunny", "icon": ""},
                        "chance_of_rain": 30,
                    }
                ],
            }
        ]
    },
    "alerts": {"alert": []},
}

# Same response but with alerts=yes (for get_alerts passthrough)
MOCK_ALERTS_API_RESPONSE = {
    **MOCK_FORECAST_RESPONSE,
    "alerts": {"alert": []},
}


@pytest.fixture
def mock_wx_client():
    """Mock WeatherAPIClient._request to return benign weather data."""
    with patch(
        "app.services.weather.client.WeatherAPIClient._request",
        new_callable=AsyncMock,
    ) as mock:
        mock.return_value = MOCK_CURRENT_RESPONSE  # default for get_current
        yield mock


@pytest.fixture
def mock_wx_client_full():
    """Mock _request returning different data based on endpoint."""
    def side_effect(endpoint, params):
        if "forecast" in endpoint:
            return MOCK_FORECAST_RESPONSE
        return MOCK_CURRENT_RESPONSE

    with patch(
        "app.services.weather.client.WeatherAPIClient._request",
        new_callable=AsyncMock,
    ) as mock:
        mock.side_effect = side_effect
        yield mock


# ===========================================================================
# Unit Tests — AlertEngine (no HTTP, no FastAPI)
# ===========================================================================

class TestAlertEngineHeat:
    """Rule 1: Extreme Heat."""

    def test_normal_temperature_no_heat_alert(self):
        engine = AlertEngine()
        current = _make_current(temp_c=25.0)
        alerts = engine.evaluate(current)
        types = [a.alert_type.value for a in alerts]
        assert "heat" not in types

    def test_below_warning_threshold_no_heat_alert(self):
        engine = AlertEngine()
        current = _make_current(temp_c=settings.alert_heat_warning_c - 0.1)
        alerts = engine.evaluate(current)
        types = [a.alert_type.value for a in alerts]
        assert "heat" not in types

    def test_at_warning_threshold_moderate_heat_alert(self):
        engine = AlertEngine()
        current = _make_current(temp_c=settings.alert_heat_warning_c)
        alerts = engine.evaluate(current)
        heat_alerts = [a for a in alerts if a.alert_type.value == "heat"]
        assert len(heat_alerts) == 1
        assert heat_alerts[0].severity.value == "moderate"
        assert heat_alerts[0].relevant_value == settings.alert_heat_warning_c
        assert heat_alerts[0].threshold == settings.alert_heat_warning_c

    def test_above_warning_threshold_moderate_heat_alert(self):
        engine = AlertEngine()
        current = _make_current(temp_c=40.0)  # between 38 and 42
        alerts = engine.evaluate(current)
        heat_alerts = [a for a in alerts if a.alert_type.value == "heat"]
        assert len(heat_alerts) == 1
        assert heat_alerts[0].severity.value == "moderate"

    def test_at_danger_threshold_severe_heat_alert(self):
        engine = AlertEngine()
        current = _make_current(temp_c=settings.alert_heat_danger_c)
        alerts = engine.evaluate(current)
        heat_alerts = [a for a in alerts if a.alert_type.value == "heat"]
        assert len(heat_alerts) == 1
        assert heat_alerts[0].severity.value == "severe"
        assert "Extreme Heat" in heat_alerts[0].title

    def test_above_danger_threshold_severe_heat_alert(self):
        engine = AlertEngine()
        current = _make_current(temp_c=45.0)
        alerts = engine.evaluate(current)
        heat_alerts = [a for a in alerts if a.alert_type.value == "heat"]
        assert len(heat_alerts) == 1
        assert heat_alerts[0].severity.value == "severe"

    def test_heat_alert_has_alert_id(self):
        engine = AlertEngine()
        current = _make_current(temp_c=settings.alert_heat_warning_c)
        alerts = engine.evaluate(current)
        assert alerts[0].alert_id.startswith("sae-")


class TestAlertEngineRain:
    """Rule 2: Heavy Rain."""

    def test_no_forecast_no_rain_alert(self):
        engine = AlertEngine()
        current = _make_current()
        alerts = engine.evaluate(current, forecast=None)
        types = [a.alert_type.value for a in alerts]
        assert "rain" not in types

    def test_low_rain_probability_no_alert(self):
        engine = AlertEngine()
        current = _make_current()
        forecast = _make_forecast(rain_pct=50.0)
        alerts = engine.evaluate(current, forecast)
        types = [a.alert_type.value for a in alerts]
        assert "rain" not in types

    def test_at_warning_threshold_rain_alert(self):
        engine = AlertEngine()
        current = _make_current()
        forecast = _make_forecast(rain_pct=settings.alert_rain_warning_pct)
        alerts = engine.evaluate(current, forecast)
        rain_alerts = [a for a in alerts if a.alert_type.value == "rain"]
        assert len(rain_alerts) == 1
        assert rain_alerts[0].severity.value == "moderate"
        assert rain_alerts[0].relevant_value == settings.alert_rain_warning_pct

    def test_high_rain_probability_rain_alert(self):
        engine = AlertEngine()
        current = _make_current()
        forecast = _make_forecast(rain_pct=90.0)
        alerts = engine.evaluate(current, forecast)
        rain_alerts = [a for a in alerts if a.alert_type.value == "rain"]
        assert len(rain_alerts) == 1
        assert "umbrella" in rain_alerts[0].description.lower()


class TestAlertEngineWind:
    """Rule 3: Strong Wind."""

    def test_low_wind_no_alert(self):
        engine = AlertEngine()
        current = _make_current(wind_kph=20.0)
        alerts = engine.evaluate(current)
        types = [a.alert_type.value for a in alerts]
        assert "wind" not in types

    def test_at_warning_threshold_moderate_wind_alert(self):
        engine = AlertEngine()
        current = _make_current(wind_kph=settings.alert_wind_warning_kph)
        alerts = engine.evaluate(current)
        wind_alerts = [a for a in alerts if a.alert_type.value == "wind"]
        assert len(wind_alerts) == 1
        assert wind_alerts[0].severity.value == "moderate"

    def test_at_danger_threshold_severe_wind_alert(self):
        engine = AlertEngine()
        current = _make_current(wind_kph=settings.alert_wind_danger_kph)
        alerts = engine.evaluate(current)
        wind_alerts = [a for a in alerts if a.alert_type.value == "wind"]
        assert len(wind_alerts) == 1
        assert wind_alerts[0].severity.value == "severe"
        assert "Dangerous" in wind_alerts[0].title

    def test_forecast_wind_triggers_alert(self):
        """Engine should consider forecast wind, not just current."""
        engine = AlertEngine()
        current = _make_current(wind_kph=10.0)  # low current wind
        forecast = _make_forecast(wind_kph=settings.alert_wind_warning_kph + 5)
        alerts = engine.evaluate(current, forecast)
        wind_alerts = [a for a in alerts if a.alert_type.value == "wind"]
        assert len(wind_alerts) == 1


class TestAlertEngineUV:
    """Rule 4: High UV."""

    def test_low_uv_no_alert(self):
        engine = AlertEngine()
        current = _make_current(uv=3.0)
        alerts = engine.evaluate(current)
        types = [a.alert_type.value for a in alerts]
        assert "uv" not in types

    def test_at_warning_threshold_moderate_uv_alert(self):
        engine = AlertEngine()
        current = _make_current(uv=settings.alert_uv_warning_index)
        alerts = engine.evaluate(current)
        uv_alerts = [a for a in alerts if a.alert_type.value == "uv"]
        assert len(uv_alerts) == 1
        assert uv_alerts[0].severity.value == "moderate"
        assert "High UV" in uv_alerts[0].title

    def test_at_danger_threshold_severe_uv_alert(self):
        engine = AlertEngine()
        current = _make_current(uv=settings.alert_uv_danger_index)
        alerts = engine.evaluate(current)
        uv_alerts = [a for a in alerts if a.alert_type.value == "uv"]
        assert len(uv_alerts) == 1
        assert uv_alerts[0].severity.value == "severe"
        assert "Extreme" in uv_alerts[0].title

    def test_none_uv_index_no_crash(self):
        """UV index may be None from WeatherAPI — engine must handle gracefully."""
        engine = AlertEngine()
        current = _make_current()
        current = current.model_copy(update={"uv_index": None})
        alerts = engine.evaluate(current)  # must not raise
        types = [a.alert_type.value for a in alerts]
        assert "uv" not in types


class TestAlertEngineThunderstorm:
    """Rule 5: Thunderstorm condition."""

    def test_sunny_condition_no_thunder_alert(self):
        engine = AlertEngine()
        current = _make_current(condition="Sunny")
        alerts = engine.evaluate(current)
        types = [a.alert_type.value for a in alerts]
        assert "thunderstorm" not in types

    def test_thunder_in_condition_triggers_alert(self):
        engine = AlertEngine()
        current = _make_current(condition="Thundery outbreaks possible")
        alerts = engine.evaluate(current)
        thunder_alerts = [a for a in alerts if a.alert_type.value == "thunderstorm"]
        assert len(thunder_alerts) == 1
        assert thunder_alerts[0].severity.value == "severe"

    def test_thunderstorm_condition_triggers_alert(self):
        engine = AlertEngine()
        current = _make_current(condition="Heavy thunderstorm")
        alerts = engine.evaluate(current)
        thunder_alerts = [a for a in alerts if a.alert_type.value == "thunderstorm"]
        assert len(thunder_alerts) == 1

    def test_condition_case_insensitive(self):
        engine = AlertEngine()
        current = _make_current(condition="THUNDER AND LIGHTNING")
        alerts = engine.evaluate(current)
        thunder_alerts = [a for a in alerts if a.alert_type.value == "thunderstorm"]
        assert len(thunder_alerts) == 1

    def test_condition_code_triggers_alert(self):
        """Rule 3: Structured condition codes (e.g. 1087, 1273, 1276) trigger thunderstorm alert."""
        engine = AlertEngine()
        for code in (1087, 1273, 1276, 1279, 1282):
            current = _make_current(condition="Showers", condition_code=code)
            alerts = engine.evaluate(current)
            thunder_alerts = [a for a in alerts if a.alert_type.value == "thunderstorm"]
            assert len(thunder_alerts) == 1, f"Failed for code {code}"

    def test_non_thunder_condition_code_no_alert(self):
        engine = AlertEngine()
        current = _make_current(condition="Sunny", condition_code=1000)
        alerts = engine.evaluate(current)
        types = [a.alert_type.value for a in alerts]
        assert "thunderstorm" not in types

    def test_empty_condition_no_crash(self):
        engine = AlertEngine()
        current = _make_current(condition="")
        alerts = engine.evaluate(current)  # must not raise


class TestAlertEngineMultiple:
    """Test multiple simultaneous alerts and edge cases."""

    def test_all_clear_returns_empty_list(self):
        engine = AlertEngine()
        current = _make_current(temp_c=25.0, wind_kph=10.0, uv=3.0, condition="Sunny")
        forecast = _make_forecast(rain_pct=10.0)
        alerts = engine.evaluate(current, forecast)
        assert alerts == []

    def test_multiple_alerts_simultaneously(self):
        """Extreme heat + heavy rain + high UV should all fire at once."""
        engine = AlertEngine()
        current = _make_current(
            temp_c=45.0,   # extreme heat
            wind_kph=10.0,
            uv=12.0,       # extreme UV
            condition="Sunny",
        )
        forecast = _make_forecast(rain_pct=85.0)  # heavy rain
        alerts = engine.evaluate(current, forecast)
        types = {a.alert_type.value for a in alerts}
        assert "heat" in types
        assert "rain" in types
        assert "uv" in types
        assert len(alerts) >= 3

    def test_each_rule_fires_at_most_once(self):
        """No duplicate alert types in a single evaluation."""
        engine = AlertEngine()
        current = _make_current(
            temp_c=50.0,  # very extreme heat
            wind_kph=100.0,  # very extreme wind
            uv=15.0,  # very extreme UV
            condition="Thunderstorm",
        )
        forecast = _make_forecast(rain_pct=100.0)
        alerts = engine.evaluate(current, forecast)
        types = [a.alert_type.value for a in alerts]
        assert len(types) == len(set(types)), "Duplicate alert types found"

    def test_alert_has_area_set(self):
        engine = AlertEngine()
        current = _make_current(temp_c=45.0, city="Chennai")
        alerts = engine.evaluate(current)
        assert all(a.area == "Chennai" for a in alerts)

    def test_alert_has_timestamps(self):
        engine = AlertEngine()
        current = _make_current(temp_c=45.0)
        alerts = engine.evaluate(current)
        for a in alerts:
            assert a.start_time > 0
            assert a.end_time is not None
            assert a.end_time > a.start_time


# ===========================================================================
# API Endpoint Tests — GET /api/v1/alerts
# ===========================================================================

class TestAlertsEndpoint:

    def test_alerts_endpoint_returns_200(self, mock_wx_client_full):
        """Smart alerts endpoint returns HTTP 200 with AlertsResponse shape."""
        response = client.get("/api/v1/alerts?lat=9.93&lon=78.12")
        assert response.status_code == 200
        data = response.json()
        assert "alerts" in data
        assert "total" in data
        assert isinstance(data["alerts"], list)
        assert data["total"] == len(data["alerts"])

    def test_alerts_endpoint_no_alerts_for_mild_weather(self, mock_wx_client_full):
        """Mild weather data triggers no smart alerts."""
        response = client.get("/api/v1/alerts?lat=9.93&lon=78.12")
        assert response.status_code == 200
        data = response.json()
        # MOCK_CURRENT_RESPONSE has temp=32, wind=20kph, uv=5 — below all thresholds
        # MOCK_FORECAST_RESPONSE has rain=30% — below 70% threshold
        assert data["total"] == 0
        assert data["alerts"] == []

    def test_alerts_endpoint_with_high_temp_triggers_alert(self):
        """Hot weather triggers heat alert from the engine."""
        hot_current = {
            **MOCK_CURRENT_RESPONSE,
            "current": {**MOCK_CURRENT_RESPONSE["current"], "temp_c": 43.0},
        }
        hot_forecast = {
            **MOCK_FORECAST_RESPONSE,
            "forecast": {
                "forecastday": [{
                    **MOCK_FORECAST_RESPONSE["forecast"]["forecastday"][0],
                    "day": {
                        **MOCK_FORECAST_RESPONSE["forecast"]["forecastday"][0]["day"],
                        "maxtemp_c": 43.0,
                    },
                }]
            },
        }

        def side_effect(endpoint, params):
            if "forecast" in endpoint:
                return hot_forecast
            return hot_current

        with patch(
            "app.services.weather.client.WeatherAPIClient._request",
            new_callable=AsyncMock,
            side_effect=side_effect,
        ):
            response = client.get("/api/v1/alerts?lat=9.93&lon=78.12")
        assert response.status_code == 200
        data = response.json()
        types = [a["alert_type"] for a in data["alerts"]]
        assert "heat" in types

    def test_alerts_endpoint_weather_failure_returns_503(self):
        """If WeatherAPI fails, the endpoint returns 503."""
        with patch(
            "app.services.weather.client.WeatherAPIClient._request",
            new_callable=AsyncMock,
            side_effect=HTTPException(status_code=503, detail="Weather provider is currently unavailable."),
        ):
            response = client.get("/api/v1/alerts?lat=9.93&lon=78.12")
        assert response.status_code == 503

    def test_alerts_response_schema_has_required_fields(self, mock_wx_client_full):
        """Verify the response schema includes all mandatory alert fields."""
        # Force a heat alert by patching a high temperature
        hot_current = {
            **MOCK_CURRENT_RESPONSE,
            "current": {**MOCK_CURRENT_RESPONSE["current"], "temp_c": 43.0, "uv": 12.0},
        }

        def side_effect(endpoint, params):
            if "forecast" in endpoint:
                return MOCK_FORECAST_RESPONSE
            return hot_current

        with patch(
            "app.services.weather.client.WeatherAPIClient._request",
            new_callable=AsyncMock,
            side_effect=side_effect,
        ):
            response = client.get("/api/v1/alerts?lat=9.93&lon=78.12")

        data = response.json()
        assert data["total"] >= 1
        for alert in data["alerts"]:
            assert "alert_id" in alert
            assert "alert_type" in alert
            assert "severity" in alert
            assert "title" in alert
            assert "description" in alert
            assert "area" in alert
            assert "start_time" in alert


# ===========================================================================
# API Endpoint Tests — GET /api/v1/advisory
# ===========================================================================

class TestAdvisoryEndpoint:

    def test_advisory_endpoint_returns_200(self, mock_wx_client_full):
        """Advisory endpoint returns HTTP 200 with AdvisoryResponse shape."""
        response = client.get("/api/v1/advisory?lat=9.93&lon=78.12")
        assert response.status_code == 200
        data = response.json()
        assert "advisories" in data
        assert "total" in data
        assert isinstance(data["advisories"], list)
        assert data["total"] >= 1  # at least an all-clear advisory

    def test_advisory_mild_weather_returns_all_clear(self, mock_wx_client_full):
        """Mild weather returns an all-clear advisory."""
        response = client.get("/api/v1/advisory?lat=9.93&lon=78.12")
        assert response.status_code == 200
        data = response.json()
        titles = [a["title"] for a in data["advisories"]]
        assert "All Clear" in titles

    def test_advisory_hot_weather_includes_heat_advisory(self):
        """High temperature triggers a heat advisory."""
        hot_current = {
            **MOCK_CURRENT_RESPONSE,
            "current": {**MOCK_CURRENT_RESPONSE["current"], "temp_c": 43.0},
        }

        def side_effect(endpoint, params):
            if "forecast" in endpoint:
                return MOCK_FORECAST_RESPONSE
            return hot_current

        with patch(
            "app.services.weather.client.WeatherAPIClient._request",
            new_callable=AsyncMock,
            side_effect=side_effect,
        ):
            response = client.get("/api/v1/advisory?lat=9.93&lon=78.12&category=health")
        assert response.status_code == 200
        data = response.json()
        titles = [a["title"] for a in data["advisories"]]
        assert any("Heat" in t for t in titles)

    def test_advisory_weather_failure_returns_503(self):
        """WeatherAPI failure bubbles up as 503."""
        with patch(
            "app.services.weather.client.WeatherAPIClient._request",
            new_callable=AsyncMock,
            side_effect=HTTPException(status_code=503, detail="Weather provider is currently unavailable."),
        ):
            response = client.get("/api/v1/advisory?lat=9.93&lon=78.12")
        assert response.status_code == 503

    def test_advisory_fields_present(self, mock_wx_client_full):
        """Each advisory has required fields."""
        response = client.get("/api/v1/advisory?lat=9.93&lon=78.12")
        data = response.json()
        for adv in data["advisories"]:
            assert "advisory_id" in adv
            assert "category" in adv
            assert "title" in adv
            assert "message" in adv
            assert "recommendation" in adv
