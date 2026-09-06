"""
Routes: Weather endpoints
  GET /api/v1/weather/current  — Current weather conditions
  GET /api/v1/weather/forecast — Multi-day forecast
"""

from fastapi import APIRouter

router = APIRouter()


@router.get("/current", summary="Get current weather")
async def get_current_weather(lat: float = 0.0, lon: float = 0.0, units: str = "metric") -> dict:
    """
    Returns current weather conditions for the given coordinates.

    Parameters:
        lat   (float): Latitude of the location.
        lon   (float): Longitude of the location.
        units (str):   Unit system — 'metric' | 'imperial' | 'standard'.

    Note: Not yet implemented — returns a stub response.
    """
    return {
        "status": "stub",
        "message": "Weather service not yet implemented.",
        "params": {"lat": lat, "lon": lon, "units": units},
    }


@router.get("/forecast", summary="Get weather forecast")
async def get_weather_forecast(
    lat: float = 0.0,
    lon: float = 0.0,
    days: int = 7,
    units: str = "metric",
) -> dict:
    """
    Returns a multi-day weather forecast for the given coordinates.

    Parameters:
        lat   (float): Latitude of the location.
        lon   (float): Longitude of the location.
        days  (int):   Number of forecast days (1–16).
        units (str):   Unit system — 'metric' | 'imperial' | 'standard'.

    Note: Not yet implemented — returns a stub response.
    """
    return {
        "status": "stub",
        "message": "Forecast service not yet implemented.",
        "params": {"lat": lat, "lon": lon, "days": days, "units": units},
    }
