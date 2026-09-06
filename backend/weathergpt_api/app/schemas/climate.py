"""
WeatherGPT — Climate Schemas
Pydantic models for historical climate trend request/response validation.
"""

from pydantic import BaseModel, Field
from typing import List


class ClimateTrendPoint(BaseModel):
    """A single data point in a climate trend series."""
    year: int = Field(..., description="Year of the observation")
    value: float = Field(..., description="Observed value for the climate parameter")
    anomaly: float = Field(0.0, description="Deviation from the long-term baseline")


class ClimateTrend(BaseModel):
    """Climate trend data for a single parameter over a period."""
    parameter: str = Field(..., description="Climate parameter (e.g., temperature, precipitation)")
    unit: str = Field(..., description="Unit of measurement")
    baseline_period: str = Field(..., description="Baseline reference period, e.g., '1981-2010'")
    data_points: List[ClimateTrendPoint] = []


class ClimateTrendsResponse(BaseModel):
    """Response envelope for the climate trends endpoint."""
    location_name: str = Field("", description="Human-readable location name")
    lat: float
    lon: float
    trends: List[ClimateTrend] = []
