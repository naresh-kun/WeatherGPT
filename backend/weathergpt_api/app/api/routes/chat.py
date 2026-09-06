"""
Route: POST /api/v1/chat
Purpose: Accept a user weather query, route it through intent understanding,
         weather data retrieval, and an LLM to produce a natural-language response.
"""

from fastapi import APIRouter
from app.schemas.chat import ChatRequest, ChatResponse

router = APIRouter()


@router.post("", summary="Send a weather chat message", response_model=ChatResponse)
async def chat(request: ChatRequest) -> ChatResponse:
    """
    Accepts a natural-language weather query and returns an AI-generated response.

    Note: Not yet implemented — returns a stub response.
    """
    return ChatResponse(
        message="Chat service not yet implemented.",
        conversation_id=request.conversation_id or "stub-id",
        language=request.language,
    )
