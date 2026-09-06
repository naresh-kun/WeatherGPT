"""
Route: GET /api/v1/alerts
Purpose: Return active weather alerts for a location.
"""

from fastapi import APIRouter

router = APIRouter()


@router.get("", summary="Get weather alerts")
async def get_alerts(lat: float = 0.0, lon: float = 0.0) -> dict:
    """
    Returns active weather alerts for the given coordinates.

    Parameters:
        lat (float): Latitude of the location.
        lon (float): Longitude of the location.

    Note: Not yet implemented — returns a stub response.
    """
    return {
        "status": "stub",
        "message": "Alert service not yet implemented.",
        "alerts": [],
        "params": {"lat": lat, "lon": lon},
    }
