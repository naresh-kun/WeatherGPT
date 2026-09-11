"""
WeatherAPI Client
Handles HTTP communication with WeatherAPI.com.
"""
import httpx
from fastapi import HTTPException
import logging
import re
import time
from typing import Dict, Any, List, Optional, Tuple

from app.core.config import settings

logger = logging.getLogger(__name__)

class WeatherAPIClient:
    """Client for WeatherAPI.com REST API with deduplication caching and security sanitization."""

    # Class-level cache shared across WeatherService instances within the process
    _shared_cache: Dict[str, Tuple[float, Any]] = {}
    _cache_ttl: float = 30.0  # 30-second TTL prevents duplicate calls during single user actions

    def __init__(self):
        self.base_url = settings.weather_base_url.rstrip("/")
        self.api_key = settings.weather_api_key
        self.timeout = settings.weather_api_timeout
        if not self.api_key:
            logger.warning("WEATHER_API_KEY is not set. WeatherAPI calls will fail.")

    def _sanitize(self, text: str) -> str:
        s = str(text)
        s = re.sub(r'([?&]key=)[^&\s\'"]+', r'\g<1>***', s)
        if self.api_key and self.api_key in s:
            s = s.replace(self.api_key, "***")
        return s

    @classmethod
    def clear_cache(cls) -> None:
        """Clear the in-memory response cache (useful for testing)."""
        cls._shared_cache.clear()

    async def _request(self, endpoint: str, params: Dict[str, Any]) -> Dict[str, Any]:
        if not self.api_key:
            raise HTTPException(status_code=500, detail="Weather API key is not configured on the server.")

        # Check in-memory deduplication cache for weather endpoints
        is_cacheable = endpoint in ("/current.json", "/forecast.json")
        cache_key = f"{endpoint}?" + "&".join(f"{k}={v}" for k, v in sorted(params.items()) if k != "key")
        now = time.monotonic()

        if is_cacheable and cache_key in self._shared_cache:
            cached_time, cached_data = self._shared_cache[cache_key]
            if now - cached_time < self._cache_ttl:
                logger.debug("WeatherAPI cache hit for %s", endpoint)
                return cached_data

        params["key"] = self.api_key
        url = f"{self.base_url}{endpoint}"

        try:
            async with httpx.AsyncClient(timeout=self.timeout) as client:
                response = await client.get(url, params=params)
                
                if response.status_code == 400:
                    safe_text = self._sanitize(response.text)
                    logger.warning(f"WeatherAPI 400: {safe_text}")
                    raise HTTPException(status_code=400, detail="Invalid location or request parameters.")
                elif response.status_code == 401 or response.status_code == 403:
                    logger.error("WeatherAPI auth error. Check API key.")
                    raise HTTPException(status_code=500, detail="Weather provider configuration error.")
                elif response.status_code != 200:
                    safe_text = self._sanitize(response.text)
                    logger.error(f"WeatherAPI Error {response.status_code}: {safe_text}")
                    raise HTTPException(status_code=503, detail="Weather provider is currently unavailable.")
                
                data = response.json()
                if is_cacheable:
                    self._shared_cache[cache_key] = (now, data)
                return data
        except httpx.TimeoutException:
            logger.error("WeatherAPI request timed out for %s", endpoint)
            raise HTTPException(status_code=504, detail="Weather provider request timed out.")
        except httpx.RequestError as e:
            safe_error = self._sanitize(str(e))
            logger.error("WeatherAPI request error: %s", safe_error)
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
