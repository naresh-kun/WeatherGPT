"""
Route: GET /api/v1/health
Purpose: Liveness / readiness probe for the WeatherGPT API.
"""

from fastapi import APIRouter

router = APIRouter()


@router.get("", summary="Health check")
async def health_check() -> dict:
    """Returns the current health status of the API."""
    return {"status": "ok", "service": "weathergpt-api"}
