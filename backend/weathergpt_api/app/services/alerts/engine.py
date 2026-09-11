"""
WeatherGPT — Smart Alert Engine  [Phase 6 — REAL]

Evaluates current weather and forecast data against configurable thresholds
and emits structured Alert objects.

Core principles:
  - Fully DETERMINISTIC — no LLM involved in the alert decision.
  - All thresholds are configurable via environment variables (Settings).
  - Takes already-mapped domain objects (WeatherCurrent, WeatherForecast)
    so it can be tested in complete isolation without any HTTP calls.
  - Deduplicates alerts by rule type — each rule fires at most once.

Alert rules (Phase 6):
  1. Extreme Heat     — current temp_c >= threshold
  2. Heavy Rain       — forecast daily_chance_of_rain >= threshold
  3. Strong Wind      — current or forecast wind_kph >= threshold
  4. High UV          — current uv_index >= threshold
  5. Thunderstorm     — current condition contains 'thunder'

Severity mapping:
  - info    → AlertSeverity.MINOR
  - warning → AlertSeverity.MODERATE
  - danger  → AlertSeverity.SEVERE
"""

import time
import uuid
import logging
from typing import List, Optional, Dict, Any

from app.schemas.alerts import Alert, AlertSeverity, AlertType
from app.schemas.weather import WeatherCurrent, WeatherForecast
from app.core.config import settings

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

def _make_alert(
    *,
    alert_type: AlertType,
    severity: AlertSeverity,
    title: str,
    description: str,
    area: str,
    relevant_value: Optional[float] = None,
    threshold: Optional[float] = None,
    source: str = "WeatherGPT Smart Alert Engine",
) -> Alert:
    """Create a new Alert with a unique ID and current timestamp."""
    now = int(time.time())
    return Alert(
        alert_id=f"sae-{uuid.uuid4().hex[:8]}",
        alert_type=alert_type,
        severity=severity,
        title=title,
        description=description,
        area=area,
        start_time=now,
        end_time=now + 86400,  # Valid for 24 hours
        source=source,
        relevant_value=relevant_value,
        threshold=threshold,
    )


# ---------------------------------------------------------------------------
# Alert Engine
# ---------------------------------------------------------------------------

class AlertEngine:
    """
    Deterministic weather alert engine.

    Call evaluate() with current weather and (optionally) forecast data.
    Returns a list of Alert objects — one per triggered rule at most.

    All thresholds are loaded from settings (app.core.config) and can be
    overridden via environment variables.

    [Phase 6 — REAL]
    """

    def __init__(self) -> None:
        self._cfg = settings

    def evaluate(
        self,
        current: WeatherCurrent,
        forecast: Optional[WeatherForecast] = None,
    ) -> List[Alert]:
        """
        Evaluate weather data against all rules and return triggered alerts.

        Args:
            current:  Current weather (always required).
            forecast: Optional forecast for rain probability checks.

        Returns:
            List of Alert objects, one per triggered rule (de-duplicated).
        """
        alerts: List[Alert] = []
        location_name = current.location.city or f"{current.location.lat},{current.location.lon}"

        # --- Rule 1: Extreme Heat ----------------------------------------
        heat_alert = self._check_heat(current.temperature, location_name)
        if heat_alert:
            alerts.append(heat_alert)

        # --- Rule 2: Heavy Rain ------------------------------------------
        rain_prob = self._max_rain_probability(current, forecast)
        rain_alert = self._check_rain(rain_prob, location_name)
        if rain_alert:
            alerts.append(rain_alert)

        # --- Rule 3: Strong Wind ------------------------------------------
        wind_kph = self._max_wind_kph(current, forecast)
        wind_alert = self._check_wind(wind_kph, location_name)
        if wind_alert:
            alerts.append(wind_alert)

        # --- Rule 4: High UV ---------------------------------------------
        if current.uv_index is not None:
            uv_alert = self._check_uv(current.uv_index, location_name)
            if uv_alert:
                alerts.append(uv_alert)

        # --- Rule 5: Thunderstorm ----------------------------------------
        thunder_alert = self._check_thunderstorm(
            current.description,
            location_name,
            condition_code=getattr(current, "condition_code", None),
        )
        if thunder_alert:
            alerts.append(thunder_alert)

        logger.debug(
            "AlertEngine: evaluated %d rules, %d alerts for %s",
            5, len(alerts), location_name,
        )
        return alerts

    # -----------------------------------------------------------------------
    # Individual rule checkers
    # -----------------------------------------------------------------------

    def _check_heat(self, temp_c: float, location: str) -> Optional[Alert]:
        """Fire heat alert if temperature meets or exceeds a threshold."""
        if temp_c >= self._cfg.alert_heat_danger_c:
            return _make_alert(
                alert_type=AlertType.HEAT,
                severity=AlertSeverity.SEVERE,
                title="Extreme Heat Alert",
                description=(
                    f"Dangerously high temperature of {temp_c:.1f}°C detected. "
                    "Avoid outdoor exposure during peak hours. Stay hydrated "
                    "and seek air-conditioned shelter."
                ),
                area=location,
                relevant_value=temp_c,
                threshold=self._cfg.alert_heat_danger_c,
            )
        if temp_c >= self._cfg.alert_heat_warning_c:
            return _make_alert(
                alert_type=AlertType.HEAT,
                severity=AlertSeverity.MODERATE,
                title="Heat Advisory",
                description=(
                    f"High temperature of {temp_c:.1f}°C expected. "
                    "Stay hydrated and limit prolonged exposure during afternoon hours."
                ),
                area=location,
                relevant_value=temp_c,
                threshold=self._cfg.alert_heat_warning_c,
            )
        return None

    def _check_rain(self, rain_pct: float, location: str) -> Optional[Alert]:
        """Fire rain alert if precipitation probability meets or exceeds threshold."""
        if rain_pct >= self._cfg.alert_rain_warning_pct:
            return _make_alert(
                alert_type=AlertType.RAIN,
                severity=AlertSeverity.MODERATE,
                title="Heavy Rain Advisory",
                description=(
                    f"High probability of rain ({rain_pct:.0f}%). "
                    "Carry an umbrella and avoid low-lying areas prone to waterlogging."
                ),
                area=location,
                relevant_value=rain_pct,
                threshold=self._cfg.alert_rain_warning_pct,
            )
        return None

    def _check_wind(self, wind_kph: float, location: str) -> Optional[Alert]:
        """Fire wind alert if wind speed meets or exceeds a threshold."""
        if wind_kph >= self._cfg.alert_wind_danger_kph:
            return _make_alert(
                alert_type=AlertType.WIND,
                severity=AlertSeverity.SEVERE,
                title="Dangerous Wind Alert",
                description=(
                    f"Extremely strong winds of {wind_kph:.0f} km/h forecast. "
                    "Avoid travel and outdoor activities. Secure loose objects."
                ),
                area=location,
                relevant_value=wind_kph,
                threshold=self._cfg.alert_wind_danger_kph,
            )
        if wind_kph >= self._cfg.alert_wind_warning_kph:
            return _make_alert(
                alert_type=AlertType.WIND,
                severity=AlertSeverity.MODERATE,
                title="Strong Wind Advisory",
                description=(
                    f"Strong winds of {wind_kph:.0f} km/h expected. "
                    "Use caution outdoors and secure unsecured items."
                ),
                area=location,
                relevant_value=wind_kph,
                threshold=self._cfg.alert_wind_warning_kph,
            )
        return None

    def _check_uv(self, uv_index: float, location: str) -> Optional[Alert]:
        """Fire UV alert if UV index meets or exceeds a threshold."""
        if uv_index >= self._cfg.alert_uv_danger_index:
            return _make_alert(
                alert_type=AlertType.UV,
                severity=AlertSeverity.SEVERE,
                title="Extreme UV Alert",
                description=(
                    f"Extreme UV index of {uv_index:.0f} — sunburn possible in "
                    "minutes. Wear SPF 50+ sunscreen, protective clothing, and "
                    "avoid direct sun between 10am–4pm."
                ),
                area=location,
                relevant_value=uv_index,
                threshold=self._cfg.alert_uv_danger_index,
            )
        if uv_index >= self._cfg.alert_uv_warning_index:
            return _make_alert(
                alert_type=AlertType.UV,
                severity=AlertSeverity.MODERATE,
                title="High UV Advisory",
                description=(
                    f"UV index of {uv_index:.0f} — high solar radiation. "
                    "Apply sunscreen (SPF 30+) and wear a hat if spending "
                    "time outdoors."
                ),
                area=location,
                relevant_value=uv_index,
                threshold=self._cfg.alert_uv_warning_index,
            )
        return None

    THUNDERSTORM_CODES = {1087, 1273, 1276, 1279, 1282}

    def _check_thunderstorm(
        self,
        condition_text: str,
        location: str,
        condition_code: Optional[int] = None,
    ) -> Optional[Alert]:
        """
        Fire thunderstorm alert.
        Prefers WeatherAPI structured condition codes (Rule 3),
        falling back to condition text keyword matching.
        """
        is_thunder = False
        if condition_code is not None:
            is_thunder = condition_code in self.THUNDERSTORM_CODES
        else:
            lower = (condition_text or "").lower()
            if "thunder" in lower or "lightning" in lower:
                is_thunder = True

        if is_thunder:
            return _make_alert(
                alert_type=AlertType.THUNDERSTORM,
                severity=AlertSeverity.SEVERE,
                title="Thunderstorm Alert",
                description=(
                    "Thunderstorm conditions detected. "
                    "Stay indoors, avoid open areas, and unplug sensitive electronics."
                ),
                area=location,
            )
        return None

    # -----------------------------------------------------------------------
    # Data extraction helpers
    # -----------------------------------------------------------------------

    def _max_rain_probability(
        self,
        current: WeatherCurrent,
        forecast: Optional[WeatherForecast],
    ) -> float:
        """
        Return the maximum rain probability (0–100) available.

        WeatherAPI does not provide rain probability on the current endpoint,
        so we look at forecast daily chance of rain.
        Hourly precipitation_probability is in [0,1] — we convert to percent.
        """
        max_prob: float = 0.0

        if forecast is None:
            return max_prob

        # Daily chance of rain — already stored as fraction 0.0–1.0 in our schema
        for day in forecast.daily:
            pct = day.precipitation_probability * 100.0
            if pct > max_prob:
                max_prob = pct

        # Hourly precipitation probability — also stored as 0.0–1.0
        for hour in forecast.hourly:
            pct = hour.precipitation_probability * 100.0
            if pct > max_prob:
                max_prob = pct

        return max_prob

    def _max_wind_kph(
        self,
        current: WeatherCurrent,
        forecast: Optional[WeatherForecast],
    ) -> float:
        """
        Return the maximum wind speed in kph across current and forecast.

        WeatherService converts wind_kph to m/s (÷ 3.6) when storing on the
        schema object.  We reverse this to compare against kph thresholds.
        """
        # current.wind_speed is in m/s — convert back to kph
        max_kph: float = current.wind_speed * 3.6

        if forecast:
            for day in forecast.daily:
                kph = day.wind_speed * 3.6
                if kph > max_kph:
                    max_kph = kph
            for hour in forecast.hourly:
                kph = hour.wind_speed * 3.6
                if kph > max_kph:
                    max_kph = kph

        return max_kph
