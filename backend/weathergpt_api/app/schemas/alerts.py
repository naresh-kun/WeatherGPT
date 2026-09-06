"""
WeatherGPT — Alerts Schemas
Pydantic models for weather alert request/response validation.
"""

from pydantic import BaseModel, Field
from typing import Optional, List
from enum import Enum


class AlertSeverity(str, Enum):
    MINOR = "minor"
    MODERATE = "moderate"
    SEVERE = "severe"
    EXTREME = "extreme"


class AlertType(str, Enum):
    THUNDERSTORM = "thunderstorm"
    FLOOD = "flood"
    CYCLONE = "cyclone"
    HEATWAVE = "heatwave"
    COLDWAVE = "coldwave"
    DROUGHT = "drought"
    FOG = "fog"
    OTHER = "other"


class Alert(BaseModel):
    """A single weather alert."""
    alert_id: str = Field(..., description="Unique alert identifier")
    alert_type: AlertType
    severity: AlertSeverity
    title: str = Field(..., description="Short alert title")
    description: str = Field(..., description="Detailed alert description")
    area: str = Field(..., description="Affected geographic area name")
    start_time: int = Field(..., description="Alert start — Unix UTC timestamp")
    end_time: Optional[int] = Field(None, description="Alert end — Unix UTC timestamp")
    source: Optional[str] = Field(None, description="Issuing authority")


class AlertsResponse(BaseModel):
    """Response envelope for the alerts endpoint."""
    alerts: List[Alert] = []
    total: int = Field(0, description="Total number of active alerts")
