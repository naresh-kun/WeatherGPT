"""
WeatherAPI Client
Handles HTTP communication with WeatherAPI.com.
"""
import httpx
from fastapi import HTTPException
import logging
from typing import Dict, Any, List

from app.core.config import settings

logger = logging.getLogger(__name__)

class WeatherAPIClient:
    """Client for WeatherAPI.com REST API."""

    def __init__(self):
        self.base_url = settings.weather_base_url.rstrip("/")
        self.api_key = settings.weather_api_key
        self.timeout = settings.weather_api_timeout
        if not self.api_key:
            logger.warning("WEATHER_API_KEY is not set. WeatherAPI calls will fail.")

    async def _request(self, endpoint: str, params: Dict[str, Any]) -> Dict[str, Any]:
        if not self.api_key:
            raise HTTPException(status_code=500, detail="Weather API key is not configured on the server.")

        params["key"] = self.api_key
        url = f"{self.base_url}{endpoint}"

        try:
            async with httpx.AsyncClient(timeout=self.timeout) as client:
                response = await client.get(url, params=params)
                
                if response.status_code == 400:
                    safe_text = response.text.replace(self.api_key, "***") if self.api_key else response.text
                    logger.warning(f"WeatherAPI 400: {safe_text}")
                    raise HTTPException(status_code=400, detail="Invalid location or request parameters.")
                elif response.status_code == 401 or response.status_code == 403:
                    logger.error("WeatherAPI auth error. Check API key.")
                    raise HTTPException(status_code=500, detail="Weather provider configuration error.")
                elif response.status_code != 200:
                    safe_text = response.text.replace(self.api_key, "***") if self.api_key else response.text
                    logger.error(f"WeatherAPI Error {response.status_code}: {safe_text}")
                    raise HTTPException(status_code=503, detail="Weather provider is currently unavailable.")
                
                return response.json()
        except httpx.TimeoutException:
            logger.error(f"WeatherAPI request timed out for {endpoint}")
            raise HTTPException(status_code=504, detail="Weather provider request timed out.")
        except httpx.RequestError as e:
            safe_error = str(e).replace(self.api_key, "***") if self.api_key else str(e)
            logger.error(f"WeatherAPI request error: {safe_error}")
            raise HTTPException(status_code=503, detail="Error communicating with weather provider.")

    async def get_current(self, q: str) -> Dict[str, Any]:
        """Fetch current weather data."""
        return await self._request("/current.json", {"q": q, "aqi": "no"})

    async def get_forecast(self, q: str, days: int) -> Dict[str, Any]:
        """Fetch forecast data."""
        # WeatherAPI requires alerts=yes to fetch alerts data inside forecast if needed,
        # but since alerts is a separate endpoint requirement we'll just get forecast here.
        return await self._request("/forecast.json", {"q": q, "days": days, "aqi": "no", "alerts": "no"})

    async def search(self, q: str) -> List[Dict[str, Any]]:
        """Search/Autocomplete location."""
        return await self._request("/search.json", {"q": q})

    async def get_alerts(self, q: str) -> Dict[str, Any]:
        """Fetch alerts for a location. WeatherAPI groups alerts under forecast.json with alerts=yes."""
        return await self._request("/forecast.json", {"q": q, "days": 1, "aqi": "no", "alerts": "yes"})
