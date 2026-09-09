"""
Route: POST /api/v1/chat
Purpose: Accept a user weather query, retrieve real-time weather for their
         location, and generate a grounded AI response via Gemini.

Phase 5: REAL implementation (replaces stub).
"""

from fastapi import APIRouter, HTTPException
from app.schemas.chat import ChatRequest, ChatResponse
from app.services.chat_service import ChatService

router = APIRouter()

# Single service instance — reuses WeatherService internally.
_chat_service = ChatService()


@router.post("", summary="Send a weather chat message", response_model=ChatResponse)
async def chat(request: ChatRequest) -> ChatResponse:
    """
    Accepts a natural-language weather query and returns a Gemini-generated
    response grounded in real-time weather data for the user's location.

    Pipeline:
      1. Validate message (non-empty)
      2. Fetch current weather via WeatherService for the provided location
      3. Pass weather context + user message to Gemini
      4. Return AI-generated ChatResponse

    Errors:
      - 400: Empty or invalid message / invalid coordinates
      - 503: Weather provider or Gemini unavailable
    """
    return await _chat_service.handle_chat(request)
