"""
Route: GET /api/v1/advisory
Purpose: Return weather-based advisories (travel, agriculture, health, etc.).
"""

from fastapi import APIRouter

router = APIRouter()


@router.get("", summary="Get weather advisories")
async def get_advisory(lat: float = 0.0, lon: float = 0.0, category: str = "general") -> dict:
    """
    Returns weather-based advisories for the given coordinates.

    Parameters:
        lat      (float): Latitude of the location.
        lon      (float): Longitude of the location.
        category (str):   Advisory category — 'general' | 'travel' | 'agriculture' | 'health'.

    Note: Not yet implemented — returns a stub response.
    """
    return {
        "status": "stub",
        "message": "Advisory service not yet implemented.",
        "advisories": [],
        "params": {"lat": lat, "lon": lon, "category": category},
    }
