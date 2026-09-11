"""
WeatherGPT — Climate Schemas (Phase 7)
Pydantic models for historical climate analysis request/response validation.

All calculations are deterministic and data-driven (no LLM involvement).
"""

from pydantic import BaseModel, Field
from typing import List, Optional


# ---------------------------------------------------------------------------
# Records — raw dataset row representation
# ---------------------------------------------------------------------------

class HistoricalClimateRecord(BaseModel):
    """A single monthly climate record from the historical dataset."""

    location: str = Field(..., description="City name")
    year: int = Field(..., description="Year of the record")
    month: int = Field(..., ge=1, le=12, description="Month (1–12)")
    avg_temp_c: float = Field(..., description="Average temperature (°C)")
    max_temp_c: float = Field(..., description="Maximum temperature (°C)")
    min_temp_c: float = Field(..., description="Minimum temperature (°C)")
    rainfall_mm: float = Field(..., description="Total rainfall (mm)")


# ---------------------------------------------------------------------------
# Trend — yearly or monthly aggregated series
# ---------------------------------------------------------------------------

class ClimateTrendPoint(BaseModel):
    """A single year's aggregated value in a trend series."""

    year: int = Field(..., description="Year")
    value: float = Field(..., description="Aggregated metric value")


class ClimateTrend(BaseModel):
    """Aggregated climate trend for a specific metric over a period."""

    location: str = Field(..., description="City name")
    metric: str = Field(..., description="'temperature' or 'rainfall'")
    unit: str = Field(..., description="Unit of measurement (e.g. '°C', 'mm')")
    period: str = Field(..., description="Human-readable period e.g. '2000–2023'")
    values: List[ClimateTrendPoint] = Field(
        default_factory=list, description="Year-by-year aggregated values"
    )


# ---------------------------------------------------------------------------
# Comparison — current period vs historical baseline
# ---------------------------------------------------------------------------

class ClimateComparison(BaseModel):
    """Comparison of a recent period against the long-term historical baseline."""

    metric: str = Field(..., description="'temperature' or 'rainfall'")
    current_value: float = Field(..., description="Recent period average/total")
    historical_average: float = Field(..., description="Long-term baseline average/total")
    difference: float = Field(..., description="current_value − historical_average")
    difference_percent: float = Field(
        ..., description="Percentage difference relative to baseline"
    )
    interpretation: str = Field(
        ..., description="'above_average' | 'near_average' | 'below_average'"
    )


# ---------------------------------------------------------------------------
# Full API response
# ---------------------------------------------------------------------------

class ClimateResponse(BaseModel):
    """
    Full climate analysis response returned by GET /api/v1/climate.

    Contains temperature and rainfall trends, historical comparisons,
    anomalies, seasonal context, and a rule-based textual insight.
    """

    location: str = Field(..., description="Requested city name")
    year_from: int = Field(..., description="Start year of the analysis")
    year_to: int = Field(..., description="End year of the analysis")

    temperature_trend: ClimateTrend
    rainfall_trend: ClimateTrend

    temperature_comparison: ClimateComparison
    rainfall_comparison: ClimateComparison

    temperature_anomaly: float = Field(
        ..., description="Temperature deviation from the full-period baseline (°C)"
    )
    rainfall_anomaly: float = Field(
        ..., description="Rainfall deviation from the full-period baseline (mm)"
    )

    season: str = Field(
        ...,
        description=(
            "Dominant Tamil Nadu season for the queried period: "
            "'Winter' | 'Summer' | 'Southwest Monsoon' | 'Northeast Monsoon'"
        ),
    )
    insight: str = Field(
        ..., description="Rule-based textual climate insight (no LLM)"
    )
    data_source: str = Field(
        default=(
            "Prototype/reference dataset — derived from publicly available "
            "climatological summaries for Tamil Nadu cities. "
            "Not official meteorological observations."
        ),
        description="Data provenance notice",
    )

    available_locations: List[str] = Field(
        default_factory=list,
        description="All locations available in the dataset",
    )


# ---------------------------------------------------------------------------
# Query schema (for documentation purposes; FastAPI reads query params directly)
# ---------------------------------------------------------------------------

class ClimateQueryParams(BaseModel):
    """Query parameters accepted by the climate endpoint."""

    location: str = Field("Madurai", description="City name")
    year_from: int = Field(2000, ge=1990, le=2030, description="Start year")
    year_to: int = Field(2023, ge=1990, le=2030, description="End year")
    month: Optional[int] = Field(
        None, ge=1, le=12, description="Filter to a single month (1–12); omit for full year"
    )
