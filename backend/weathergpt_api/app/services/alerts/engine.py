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
        language: str = "en",
    ) -> List[Alert]:
        """
        Evaluate weather data against all rules and return triggered alerts.

        Args:
            current:  Current weather (always required).
            forecast: Optional forecast for rain probability checks.
            language: Requested language ('en' or 'ta'). Defaults to 'en'.

        Returns:
            List of Alert objects, one per triggered rule (de-duplicated).
        """
        lang = "ta" if (language or "en").lower().strip() in ("ta", "tamil") else "en"
        alerts: List[Alert] = []
        location_name = current.location.city or f"{current.location.lat},{current.location.lon}"

        # --- Rule 1: Extreme Heat ----------------------------------------
        heat_alert = self._check_heat(current.temperature, location_name, language=lang)
        if heat_alert:
            alerts.append(heat_alert)

        # --- Rule 2: Heavy Rain ------------------------------------------
        rain_prob = self._max_rain_probability(current, forecast)
        rain_alert = self._check_rain(rain_prob, location_name, language=lang)
        if rain_alert:
            alerts.append(rain_alert)

        # --- Rule 3: Strong Wind ------------------------------------------
        wind_kph = self._max_wind_kph(current, forecast)
        wind_alert = self._check_wind(wind_kph, location_name, language=lang)
        if wind_alert:
            alerts.append(wind_alert)

        # --- Rule 4: High UV ---------------------------------------------
        if current.uv_index is not None:
            uv_alert = self._check_uv(current.uv_index, location_name, language=lang)
            if uv_alert:
                alerts.append(uv_alert)

        # --- Rule 5: Thunderstorm ----------------------------------------
        thunder_alert = self._check_thunderstorm(
            current.description,
            location_name,
            condition_code=getattr(current, "condition_code", None),
            language=lang,
        )
        if thunder_alert:
            alerts.append(thunder_alert)

        logger.debug(
            "AlertEngine: evaluated %d rules, %d alerts for %s (lang=%s)",
            5, len(alerts), location_name, lang,
        )
        return alerts

    # -----------------------------------------------------------------------
    # Individual rule checkers
    # -----------------------------------------------------------------------

    def _check_heat(self, temp_c: float, location: str, language: str = "en") -> Optional[Alert]:
        """Fire heat alert if temperature meets or exceeds a threshold."""
        if temp_c >= self._cfg.alert_heat_danger_c:
            title = "அதிக வெப்ப எச்சரிக்கை" if language == "ta" else "Extreme Heat Alert"
            description = (
                f"அபாயகரமான அதிக வெப்பநிலை {temp_c:.1f}°C பதிவாகியுள்ளது. உச்ச நேரங்களில் வெயிலில் செல்வதைத் தவிர்க்கவும். போதுமான அளவு தண்ணீர் குடித்து பாதுகாப்பாக இருக்கவும்."
                if language == "ta"
                else (
                    f"Dangerously high temperature of {temp_c:.1f}°C detected. "
                    "Avoid outdoor exposure during peak hours. Stay hydrated "
                    "and seek air-conditioned shelter."
                )
            )
            return _make_alert(
                alert_type=AlertType.HEAT,
                severity=AlertSeverity.SEVERE,
                title=title,
                description=description,
                area=location,
                relevant_value=temp_c,
                threshold=self._cfg.alert_heat_danger_c,
            )
        if temp_c >= self._cfg.alert_heat_warning_c:
            title = "வெப்பநிலை அறிவுரை" if language == "ta" else "Heat Advisory"
            description = (
                f"அதிக வெப்பநிலை {temp_c:.1f}°C எதிர்பார்க்கப்படுகிறது. போதுமான தண்ணீர் குடித்து மதிய வேளையில் வெயிலில் நீண்ட நேரம் இருப்பதைத் தவிர்க்கவும்."
                if language == "ta"
                else (
                    f"High temperature of {temp_c:.1f}°C expected. "
                    "Stay hydrated and limit prolonged exposure during afternoon hours."
                )
            )
            return _make_alert(
                alert_type=AlertType.HEAT,
                severity=AlertSeverity.MODERATE,
                title=title,
                description=description,
                area=location,
                relevant_value=temp_c,
                threshold=self._cfg.alert_heat_warning_c,
            )
        return None

    def _check_rain(self, rain_pct: float, location: str, language: str = "en") -> Optional[Alert]:
        """Fire rain alert if precipitation probability meets or exceeds threshold."""
        if rain_pct >= self._cfg.alert_rain_warning_pct:
            title = "கனமழை அறிவுரை" if language == "ta" else "Heavy Rain Advisory"
            description = (
                f"மழை பெய்வதற்கான அதிக வாய்ப்பு உள்ளது ({rain_pct:.0f}%). குடை எடுத்துச் செல்லவும் மற்றும் தாழ்வான பகுதிகளைத் தவிர்க்கவும்."
                if language == "ta"
                else (
                    f"High probability of rain ({rain_pct:.0f}%). "
                    "Carry an umbrella and avoid low-lying areas prone to waterlogging."
                )
            )
            return _make_alert(
                alert_type=AlertType.RAIN,
                severity=AlertSeverity.MODERATE,
                title=title,
                description=description,
                area=location,
                relevant_value=rain_pct,
                threshold=self._cfg.alert_rain_warning_pct,
            )
        return None

    def _check_wind(self, wind_kph: float, location: str, language: str = "en") -> Optional[Alert]:
        """Fire wind alert if wind speed meets or exceeds a threshold."""
        if wind_kph >= self._cfg.alert_wind_danger_kph:
            title = "அபாயகரமான காற்று எச்சரிக்கை" if language == "ta" else "Dangerous Wind Alert"
            description = (
                f"மிகப் பலத்த காற்று {wind_kph:.0f} km/h வீசக்கூடும். பயணம் மற்றும் வெளிப்புற நடவடிக்கைகளைத் தவிர்க்கவும். தளர்வான பொருட்களைப் பாதுகாப்பாக வைக்கவும்."
                if language == "ta"
                else (
                    f"Extremely strong winds of {wind_kph:.0f} km/h forecast. "
                    "Avoid travel and outdoor activities. Secure loose objects."
                )
            )
            return _make_alert(
                alert_type=AlertType.WIND,
                severity=AlertSeverity.SEVERE,
                title=title,
                description=description,
                area=location,
                relevant_value=wind_kph,
                threshold=self._cfg.alert_wind_danger_kph,
            )
        if wind_kph >= self._cfg.alert_wind_warning_kph:
            title = "பலத்த காற்று அறிவுரை" if language == "ta" else "Strong Wind Advisory"
            description = (
                f"பலத்த காற்று {wind_kph:.0f} km/h எதிர்பார்க்கப்படுகிறது. வெளியில் செல்லும்போது எச்சரிக்கையுடன் இருக்கவும்."
                if language == "ta"
                else (
                    f"Strong winds of {wind_kph:.0f} km/h expected. "
                    "Use caution outdoors and secure unsecured items."
                )
            )
            return _make_alert(
                alert_type=AlertType.WIND,
                severity=AlertSeverity.MODERATE,
                title=title,
                description=description,
                area=location,
                relevant_value=wind_kph,
                threshold=self._cfg.alert_wind_warning_kph,
            )
        return None

    def _check_uv(self, uv_index: float, location: str, language: str = "en") -> Optional[Alert]:
        """Fire UV alert if UV index meets or exceeds a threshold."""
        if uv_index >= self._cfg.alert_uv_danger_index:
            title = "தீவிர UV எச்சரிக்கை" if language == "ta" else "Extreme UV Alert"
            description = (
                f"தீவிர UV குறியீடு {uv_index:.0f} பதிவாகியுள்ளது — சில நிமிடங்களில் தோல் பாதிப்பு ஏற்படலாம். பாதுகாப்பு ஆடைகளை அணியவும், பகல் 10 மணி முதல் மாலை 4 மணி வரை நேரடி வெயிலைத் தவிர்க்கவும்."
                if language == "ta"
                else (
                    f"Extreme UV index of {uv_index:.0f} — sunburn possible in "
                    "minutes. Wear SPF 50+ sunscreen, protective clothing, and "
                    "avoid direct sun between 10am–4pm."
                )
            )
            return _make_alert(
                alert_type=AlertType.UV,
                severity=AlertSeverity.SEVERE,
                title=title,
                description=description,
                area=location,
                relevant_value=uv_index,
                threshold=self._cfg.alert_uv_danger_index,
            )
        if uv_index >= self._cfg.alert_uv_warning_index:
            title = "அதிக UV அறிவுரை" if language == "ta" else "High UV Advisory"
            description = (
                f"UV குறியீடு {uv_index:.0f} — அதிக சூரிய கதிர்வீச்சு. வெளியில் செல்லும்போது தொப்பி மற்றும் சன்ஸ்கிரீன் பயன்படுத்தவும்."
                if language == "ta"
                else (
                    f"UV index of {uv_index:.0f} — high solar radiation. "
                    "Apply sunscreen (SPF 30+) and wear a hat if spending "
                    "time outdoors."
                )
            )
            return _make_alert(
                alert_type=AlertType.UV,
                severity=AlertSeverity.MODERATE,
                title=title,
                description=description,
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
        language: str = "en",
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
            title = "இடிமின்னல் எச்சரிக்கை" if language == "ta" else "Thunderstorm Alert"
            description = (
                "இடிமின்னலுடன் கூடிய வானிலை கண்டறியப்பட்டுள்ளது. வீட்டிற்குள் பாதுகாப்பாக இருக்கவும், திறந்தவெளிகளைத் தவிர்க்கவும்."
                if language == "ta"
                else (
                    "Thunderstorm conditions detected. "
                    "Stay indoors, avoid open areas, and unplug sensitive electronics."
                )
            )
            return _make_alert(
                alert_type=AlertType.THUNDERSTORM,
                severity=AlertSeverity.SEVERE,
                title=title,
                description=description,
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
