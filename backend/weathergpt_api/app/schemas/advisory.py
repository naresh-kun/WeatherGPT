"""
WeatherGPT — Advisory Schemas  [Phase 6: upgraded]
Pydantic models for weather-based advisory request/response validation.
"""

from pydantic import BaseModel, Field
from typing import Optional, List
from enum import Enum


class AdvisoryCategory(str, Enum):
    GENERAL = "general"
    TRAVEL = "travel"
    AGRICULTURE = "agriculture"
    HEALTH = "health"
    OUTDOOR = "outdoor"


class Advisory(BaseModel):
    """A single weather-based advisory."""
    advisory_id: str = Field(..., description="Unique advisory identifier")
    category: AdvisoryCategory
    title: str = Field(..., description="Short advisory title")
    message: str = Field(..., description="Detailed advisory message")
    recommendation: str = Field(..., description="Recommended action for the user")
    valid_until: Optional[int] = Field(None, description="Validity end — Unix UTC timestamp")


class AdvisoryResponse(BaseModel):
    """Response envelope for the advisory endpoint."""
    advisories: List[Advisory] = []
    total: int = Field(0, description="Total number of active advisories")
