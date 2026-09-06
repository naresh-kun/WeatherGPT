"""
WeatherGPT — Weather Schemas
Pydantic models for weather-related request/response validation.
"""

from pydantic import BaseModel, Field
from typing import Optional, List


class Location(BaseModel):
    """Geographic location."""
    lat: float = Field(..., description="Latitude", ge=-90.0, le=90.0)
    lon: float = Field(..., description="Longitude", ge=-180.0, le=180.0)
    city: Optional[str] = Field(None, description="City name")
    country: Optional[str] = Field(None, description="ISO 3166-1 alpha-2 country code")
    timezone: Optional[str] = Field(None, description="IANA timezone string")


class WeatherCurrent(BaseModel):
    """Current weather conditions at a location."""
    location: Location
    temperature: float = Field(..., description="Temperature in the requested unit system")
    feels_like: float = Field(..., description="Apparent temperature")
    humidity: int = Field(..., description="Relative humidity in %", ge=0, le=100)
    wind_speed: float = Field(..., description="Wind speed")
    wind_direction: int = Field(..., description="Wind direction in degrees", ge=0, le=360)
    description: str = Field(..., description="Short weather description")
    icon: str = Field(..., description="Weather icon code")
    uv_index: Optional[float] = Field(None, description="UV index")
    visibility: Optional[float] = Field(None, description="Visibility in km")
    timestamp: int = Field(..., description="Unix UTC timestamp of the observation")


class HourlyForecast(BaseModel):
    """Weather forecast for a single hour."""
    timestamp: int = Field(..., description="Unix UTC timestamp")
    temperature: float
    feels_like: float
    humidity: int = Field(..., ge=0, le=100)
    wind_speed: float
    description: str
    icon: str
    precipitation_probability: float = Field(0.0, ge=0.0, le=1.0)


class DailyForecast(BaseModel):
    """Weather forecast for a single day."""
    date: str = Field(..., description="Date in YYYY-MM-DD format")
    temp_min: float
    temp_max: float
    humidity: int = Field(..., ge=0, le=100)
    wind_speed: float
    description: str
    icon: str
    sunrise: int = Field(..., description="Unix UTC timestamp")
    sunset: int = Field(..., description="Unix UTC timestamp")
    precipitation_probability: float = Field(0.0, ge=0.0, le=1.0)


class WeatherForecast(BaseModel):
    """Full forecast response containing hourly and daily data."""
    location: Location
    hourly: List[HourlyForecast] = []
    daily: List[DailyForecast] = []
    units: str = Field("metric", description="Unit system used")
