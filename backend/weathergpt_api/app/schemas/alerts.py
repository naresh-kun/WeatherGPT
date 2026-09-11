"""
WeatherGPT — Alerts Schemas  [Phase 6: upgraded]
Pydantic models for weather alert request/response validation.

Phase 6 additions:
- AlertType: added heat, rain, wind, uv (Phase 3 types kept for backward compat)
- Alert:     added relevant_value, threshold (optional; used by smart engine)
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
    # Phase 3 — WeatherAPI alert passthrough types (kept for backward compat)
    THUNDERSTORM = "thunderstorm"
    FLOOD = "flood"
    CYCLONE = "cyclone"
    HEATWAVE = "heatwave"
    COLDWAVE = "coldwave"
    DROUGHT = "drought"
    FOG = "fog"
    OTHER = "other"
    # Phase 6 — Smart engine rule types
    HEAT = "heat"
    RAIN = "rain"
    WIND = "wind"
    UV = "uv"


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
    # Phase 6 additions — present on smart-engine alerts, None on passthrough alerts
    relevant_value: Optional[float] = Field(
        None, description="Observed value that triggered the alert (e.g. 42.1 °C)"
    )
    threshold: Optional[float] = Field(
        None, description="Threshold value that was exceeded (e.g. 42.0 °C)"
    )


class AlertsResponse(BaseModel):
    """Response envelope for the alerts endpoint."""
    alerts: List[Alert] = []
    total: int = Field(0, description="Total number of active alerts")
