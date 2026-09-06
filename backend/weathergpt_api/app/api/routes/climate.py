"""
Route: GET /api/v1/climate/trends
Purpose: Return historical climate trend data for a location.
"""

from fastapi import APIRouter

router = APIRouter()


@router.get("/trends", summary="Get climate trends")
async def get_climate_trends(
    lat: float = 0.0,
    lon: float = 0.0,
    start_year: int = 2000,
    end_year: int = 2025,
    parameter: str = "temperature",
) -> dict:
    """
    Returns historical climate trend data for the given coordinates and period.

    Parameters:
        lat        (float): Latitude of the location.
        lon        (float): Longitude of the location.
        start_year (int):   Start year for the trend period.
        end_year   (int):   End year for the trend period.
        parameter  (str):   Climate parameter — 'temperature' | 'precipitation' | 'humidity'.

    Note: Not yet implemented — returns a stub response.
    """
    return {
        "status": "stub",
        "message": "Climate service not yet implemented.",
        "trends": [],
        "params": {
            "lat": lat,
            "lon": lon,
            "start_year": start_year,
            "end_year": end_year,
            "parameter": parameter,
        },
    }
