"""
Route: GET /api/v1/alerts
Purpose: Return active weather alerts for a location.
"""

from fastapi import APIRouter, Depends, Query
from app.schemas.alerts import AlertsResponse
from app.services.weather.service import WeatherService

router = APIRouter()

def get_weather_service() -> WeatherService:
    return WeatherService()

@router.get("", summary="Get weather alerts", response_model=AlertsResponse)
async def get_alerts(
    lat: float = Query(0.0, description="Latitude"), 
    lon: float = Query(0.0, description="Longitude"),
    service: WeatherService = Depends(get_weather_service)
):
    """
    Returns active weather alerts for the given coordinates.
    """
    return await service.get_alerts(lat, lon)
