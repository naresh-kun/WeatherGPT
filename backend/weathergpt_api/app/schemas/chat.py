"""
WeatherGPT — Chat Schemas
Pydantic models for conversational weather query request/response validation.
"""

from pydantic import BaseModel, Field
from typing import Optional, List
from enum import Enum


class MessageRole(str, Enum):
    USER = "user"
    ASSISTANT = "assistant"
    SYSTEM = "system"


class ConversationMessage(BaseModel):
    """A single message in a conversation."""
    role: MessageRole
    content: str = Field(..., description="Message text")
    timestamp: Optional[int] = Field(None, description="Unix UTC timestamp")


class ChatRequest(BaseModel):
    """Incoming chat request from the Flutter frontend."""
    message: str = Field(..., description="User's natural-language weather query", min_length=1)
    conversation_id: Optional[str] = Field(None, description="ID to continue an existing conversation")
    language: str = Field("en", description="BCP-47 language tag for the response")
    location: Optional[dict] = Field(None, description="Optional location context {lat, lon}")
    voice: bool = Field(False, description="Whether the response should be optimised for TTS")


class ChatResponse(BaseModel):
    """Outgoing chat response to the Flutter frontend."""
    message: str = Field(..., description="AI-generated natural-language response")
    conversation_id: str = Field(..., description="Conversation identifier")
    language: str = Field("en", description="Language of the response")
    suggestions: List[str] = Field(default_factory=list, description="Follow-up query suggestions")


class Conversation(BaseModel):
    """Full conversation history."""
    conversation_id: str
    messages: List[ConversationMessage] = []
    language: str = "en"
