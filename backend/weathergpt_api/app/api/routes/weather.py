"""
Routes: Weather endpoints
  GET /api/v1/weather/current  — Current weather conditions
  GET /api/v1/weather/forecast — Multi-day forecast
  GET /api/v1/weather/hourly   — Hourly forecast
  GET /api/v1/weather/search   — Location search
"""

from fastapi import APIRouter, Depends, Query
from typing import List

from app.schemas.weather import WeatherCurrent, WeatherForecast, HourlyForecast, LocationSearchResult
from app.services.weather.service import WeatherService

router = APIRouter()

def get_weather_service() -> WeatherService:
    return WeatherService()

@router.get("/current", summary="Get current weather", response_model=WeatherCurrent)
async def get_current_weather(
    lat: float = Query(0.0, description="Latitude"), 
    lon: float = Query(0.0, description="Longitude"), 
    units: str = Query("metric", description="Unit system — 'metric' | 'imperial' | 'standard'"),
    service: WeatherService = Depends(get_weather_service)
):
    """Returns current weather conditions for the given coordinates."""
    return await service.get_current(lat, lon)


@router.get("/forecast", summary="Get weather forecast", response_model=WeatherForecast)
async def get_weather_forecast(
    lat: float = Query(0.0, description="Latitude"),
    lon: float = Query(0.0, description="Longitude"),
    days: int = Query(7, description="Number of forecast days"),
    units: str = Query("metric", description="Unit system — 'metric' | 'imperial' | 'standard'"),
    service: WeatherService = Depends(get_weather_service)
):
    """Returns a multi-day weather forecast for the given coordinates."""
    return await service.get_forecast(lat, lon, days)


@router.get("/hourly", summary="Get hourly forecast", response_model=List[HourlyForecast])
async def get_hourly_forecast(
    lat: float = Query(0.0, description="Latitude"),
    lon: float = Query(0.0, description="Longitude"),
    limit: int = Query(24, description="Number of hours to return"),
    service: WeatherService = Depends(get_weather_service)
):
    """Returns hourly forecast for the next N hours."""
    return await service.get_hourly_forecast(lat, lon, limit)


@router.get("/search", summary="Search locations", response_model=List[LocationSearchResult])
async def search_locations(
    q: str = Query(..., description="Location name query"),
    service: WeatherService = Depends(get_weather_service)
):
    """Search for locations by name."""
    return await service.search_locations(q)
