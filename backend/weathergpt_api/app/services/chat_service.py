"""
WeatherGPT — Chat Service (Phase 5)
Orchestrates the chat pipeline:
  1. Validate user message
  2. Fetch real-time weather for the user's location (via existing WeatherService)
  3. Build weather context dict from the WeatherCurrent response
  4. Call GeminiChatService to generate a grounded response
  5. Return a ChatResponse

This service reuses the existing WeatherService and does NOT create
a second WeatherAPI client.

[REAL — Phase 5]
"""

import logging
import uuid
from typing import Optional, Dict, Any

from fastapi import HTTPException

from app.schemas.chat import ChatRequest, ChatResponse
from app.services.weather.service import WeatherService
from app.services.ai.gemini_service import GeminiChatService

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Default fallback location if none supplied (Madurai, Tamil Nadu)
# ---------------------------------------------------------------------------
_DEFAULT_LAT = 9.9252
_DEFAULT_LON = 78.1198


class ChatService:
    """
    Orchestrates the full WeatherGPT chat pipeline.

    Reuses WeatherService — does not create a second WeatherAPI client.
    """

    def __init__(
        self,
        weather_service: Optional[WeatherService] = None,
        gemini_service: Optional[GeminiChatService] = None,
    ) -> None:
        self._weather = weather_service or WeatherService()
        self._gemini = gemini_service or GeminiChatService()

    async def handle_chat(self, request: ChatRequest) -> ChatResponse:
        """
        Handle an incoming chat request end-to-end.

        Steps:
          1. Validate message
          2. Resolve coordinates
          3. Fetch current weather from WeatherService
          4. Build weather context
          5. Generate Gemini response
          6. Return ChatResponse
        """
        # Step 1 — validate message
        message = request.message.strip()
        if not message:
            raise HTTPException(status_code=400, detail="Message cannot be empty.")

        # Step 2 — resolve coordinates
        lat, lon = self._resolve_location(request.location)

        # Step 3 — fetch live weather (reuses existing WeatherService)
        weather_context = await self._fetch_weather_context(lat, lon)

        # Step 4 — generate Gemini response
        ai_reply = await self._gemini.generate_response(
            user_message=message,
            weather_context=weather_context,
        )

        # Step 5 — build and return response
        conversation_id = request.conversation_id or f"conv-{uuid.uuid4().hex[:12]}"
        return ChatResponse(
            message=ai_reply,
            conversation_id=conversation_id,
            language=request.language,
            suggestions=[],  # Phase 6+: AI-generated follow-up suggestions
        )

    def _resolve_location(
        self, location: Optional[Dict[str, Any]]
    ) -> tuple[float, float]:
        """
        Extract lat/lon from the optional location dict.
        Falls back to default (Madurai) if not provided.
        """
        if location and "lat" in location and "lon" in location:
            try:
                lat = float(location["lat"])
                lon = float(location["lon"])
                if not (-90 <= lat <= 90 and -180 <= lon <= 180):
                    raise ValueError("Coordinates out of range")
                return lat, lon
            except (ValueError, TypeError) as exc:
                logger.warning("Invalid location in chat request: %s", exc)
                raise HTTPException(
                    status_code=400,
                    detail="Invalid location coordinates.",
                )
        # No location provided — use default
        logger.debug("No location in chat request; using default (Madurai)")
        return _DEFAULT_LAT, _DEFAULT_LON

    async def _fetch_weather_context(
        self, lat: float, lon: float
    ) -> Dict[str, Any]:
        """
        Fetch current weather via WeatherService and convert to a context dict.

        Only exposes the fields defined in WeatherCurrent — does not invent
        fields that don't exist in the model.
        """
        try:
            current = await self._weather.get_current(lat, lon)
        except HTTPException:
            raise  # propagate FastAPI HTTP errors as-is
        except Exception as exc:
            logger.error("Weather fetch failed for chat: %s", exc)
            raise HTTPException(
                status_code=503,
                detail="Unable to retrieve weather data for your location.",
            )

        # Build the context dict from WeatherCurrent fields
        context: Dict[str, Any] = {
            "location": current.location.city or f"{lat},{lon}",
            "latitude": current.location.lat,
            "longitude": current.location.lon,
            "temperature_c": current.temperature,
            "feels_like_c": current.feels_like,
            "humidity_pct": current.humidity,
            "wind_speed_ms": round(current.wind_speed, 2),
            "wind_direction_deg": current.wind_direction,
            "condition": current.description,
        }
        if current.uv_index is not None:
            context["uv_index"] = current.uv_index
        if current.visibility is not None:
            context["visibility_km"] = current.visibility
        if current.location.country:
            context["country"] = current.location.country
        if current.location.timezone:
            context["timezone"] = current.location.timezone

        return context
