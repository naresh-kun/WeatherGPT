"""
WeatherGPT — Climate Routes (Phase 7)
Endpoints for deterministic historical climate trends, comparisons, and insights.
"""

from typing import Optional
from fastapi import APIRouter, HTTPException, Query

from app.schemas.climate import ClimateResponse
from app.services.climate.service import ClimateService

router = APIRouter()

# Singleton service instance
_climate_service = ClimateService()


@router.get(
    "",
    response_model=ClimateResponse,
    summary="Get historical climate analysis",
    description=(
        "Returns deterministic historical climate trends (temperature and rainfall), "
        "historical comparisons against long-term baselines, calculated anomalies, "
        "seasonal context, and rule-based insights. Powered by a curated reference "
        "dataset without LLM involvement."
    ),
)
@router.get(
    "/",
    response_model=ClimateResponse,
    include_in_schema=False,
)
async def get_climate(
    location: str = Query(
        "Madurai",
        description="City name (e.g. Madurai, Chennai, Coimbatore, Tirunelveli)",
    ),
    year_from: int = Query(2000, ge=1990, le=2030, description="Start year of analysis"),
    year_to: int = Query(2023, ge=1990, le=2030, description="End year of analysis"),
    month: Optional[int] = Query(
        None, ge=1, le=12, description="Calendar month (1–12); omit for whole year"
    ),
    metric: Optional[str] = Query(
        None, description="Optional metric focus: 'temperature' or 'rainfall'"
    ),
) -> ClimateResponse:
    """Return comprehensive historical climate analysis for a location."""
    if year_from > year_to:
        raise HTTPException(
            status_code=400,
            detail=f"year_from ({year_from}) cannot be greater than year_to ({year_to})",
        )

    try:
        response = _climate_service.get_climate(
            location=location,
            year_from=year_from,
            year_to=year_to,
            month=month,
        )
        return response
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc))
    except Exception as exc:
        raise HTTPException(
            status_code=500, detail=f"Climate analysis error: {str(exc)}"
        )


@router.get(
    "/trends",
    summary="Get historical climate trends (legacy / specific)",
    description="Returns climate trends for a given parameter and range.",
)
async def get_climate_trends(
    location: str = Query("Madurai", description="City name"),
    parameter: str = Query(
        "temperature", description="Climate parameter: 'temperature' | 'rainfall'"
    ),
    start_year: int = Query(2000, ge=1990, le=2030, description="Start year"),
    end_year: int = Query(2023, ge=1990, le=2030, description="End year"),
) -> dict:
    """Convenience / legacy endpoint for trend data."""
    if start_year > end_year:
        raise HTTPException(
            status_code=400,
            detail=f"start_year ({start_year}) cannot be greater than end_year ({end_year})",
        )

    try:
        full = _climate_service.get_climate(
            location=location,
            year_from=start_year,
            year_to=end_year,
        )
        if parameter.lower() == "rainfall":
            trend_data = full.rainfall_trend.model_dump()
        else:
            trend_data = full.temperature_trend.model_dump()

        return {
            "status": "success",
            "location": full.location,
            "parameter": parameter,
            "start_year": start_year,
            "end_year": end_year,
            "trend": trend_data,
            "season": full.season,
            "data_source": full.data_source,
        }
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc))
