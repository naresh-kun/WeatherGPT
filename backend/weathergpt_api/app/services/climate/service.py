"""
WeatherGPT — Climate Service (Phase 7)

Provides deterministic, data-driven climate analysis from a local curated
CSV dataset.  No external API calls and no LLM involvement.

Dataset: data/climate/historical_weather.csv
  - Prototype/reference data derived from publicly available climatological
    summaries for Tamil Nadu cities.
  - NOT official meteorological observations.

Columns: location, year, month, avg_temp_c, max_temp_c, min_temp_c, rainfall_mm

Season mapping (Tamil Nadu):
  Winter         → December, January, February
  Summer         → March, April, May
  Southwest (SW) Monsoon → June, July, August, September
  Northeast (NE) Monsoon → October, November
"""

import csv
import logging
import os
from pathlib import Path
from statistics import mean
from typing import Dict, List, Optional, Tuple

from app.schemas.climate import (
    ClimateComparison,
    ClimateResponse,
    ClimateTrend,
    ClimateTrendPoint,
    HistoricalClimateRecord,
)

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Season definition (Tamil Nadu calendar)
# ---------------------------------------------------------------------------

_SEASON_MAP: Dict[int, str] = {
    1: "Winter",
    2: "Winter",
    3: "Summer",
    4: "Summer",
    5: "Summer",
    6: "Southwest Monsoon",
    7: "Southwest Monsoon",
    8: "Southwest Monsoon",
    9: "Southwest Monsoon",
    10: "Northeast Monsoon",
    11: "Northeast Monsoon",
    12: "Winter",
}

_SEASON_MAP_TA: Dict[int, str] = {
    1: "குளிர்காலம்",
    2: "குளிர்காலம்",
    3: "கோடைகாலம்",
    4: "கோடைகாலம்",
    5: "கோடைகாலம்",
    6: "தென்மேற்கு பருவமழை",
    7: "தென்மேற்கு பருவமழை",
    8: "தென்மேற்கு பருவமழை",
    9: "தென்மேற்கு பருவமழை",
    10: "வடகிழக்கு பருவமழை",
    11: "வடகிழக்கு பருவமழை",
    12: "குளிர்காலம்",
}

# ---------------------------------------------------------------------------
# Near-average band: ±5 % of the baseline is considered "near average"
# ---------------------------------------------------------------------------
_NEAR_AVERAGE_PCT = 5.0


class ClimateService:
    """
    Deterministic climate analysis service.

    Loads the historical CSV on first use and caches all records in memory
    for the lifetime of the process.
    """

    # Class-level cache shared across instances (singleton pattern)
    _records: Optional[List[HistoricalClimateRecord]] = None
    _available_locations: Optional[List[str]] = None

    def __init__(self, data_path: Optional[str] = None) -> None:
        if data_path is None:
            # Resolve relative to this file: ../../data/climate/historical_weather.csv
            base = Path(__file__).resolve().parent.parent.parent.parent
            data_path = str(base / "data" / "climate" / "historical_weather.csv")
        self._data_path = data_path

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def get_climate(
        self,
        location: str,
        year_from: int = 2000,
        year_to: int = 2023,
        month: Optional[int] = None,
        language: str = "en",
    ) -> ClimateResponse:
        """
        Return a full climate analysis for the requested location and period.

        Parameters
        ----------
        location  : City name (case-insensitive match against dataset).
        year_from : First year of the analysis window.
        year_to   : Last year of the analysis window (inclusive).
        month     : Optional — restrict analysis to a single calendar month.
        language  : Response language ('en' or 'ta').
        """
        lang = "ta" if (language or "en").lower().strip() in ("ta", "tamil") else "en"
        records = self._load_records()
        available = self._available_locations or []

        # --- Normalise / validate location ---
        canonical = self._resolve_location(location, available)
        if canonical is None:
            raise ValueError(
                f"Location '{location}' not found. "
                f"Available: {', '.join(sorted(available))}"
            )

        # --- Filter dataset ---
        window = self._filter(records, canonical, year_from, year_to, month)
        all_loc = self._filter(records, canonical, month=month)

        # --- Compute trends (yearly aggregates in the requested window) ---
        temp_trend = self._calc_trend(window, "temperature", year_from, year_to)
        rain_trend = self._calc_trend(window, "rainfall", year_from, year_to)

        # --- Compute baselines from the full location dataset ---
        baseline_avg_temp = self._baseline_avg_temp(all_loc)
        baseline_avg_rain = self._baseline_avg_rain(all_loc)

        # --- Compute window averages ---
        window_avg_temp = (
            mean(r.avg_temp_c for r in window) if window else baseline_avg_temp
        )
        window_avg_rain = (
            self._yearly_avg_rain(window) if window else baseline_avg_rain
        )

        # --- Comparisons ---
        temp_comparison = self._build_comparison(
            "temperature", window_avg_temp, baseline_avg_temp
        )
        rain_comparison = self._build_comparison(
            "rainfall", window_avg_rain, baseline_avg_rain
        )

        # --- Anomalies ---
        temp_anomaly = round(window_avg_temp - baseline_avg_temp, 2)
        rain_anomaly = round(window_avg_rain - baseline_avg_rain, 1)

        # --- Season (use the middle month of the range or the specified month) ---
        ref_month = month if month else 6  # default to June (SW Monsoon)
        season = (
            _SEASON_MAP_TA.get(ref_month, "தென்மேற்கு பருவமழை")
            if lang == "ta"
            else _SEASON_MAP.get(ref_month, "Southwest Monsoon")
        )

        # --- Insight (rule-based, no LLM) ---
        insight = self._generate_insight(
            temp_comparison.interpretation,
            rain_comparison.interpretation,
            temp_anomaly,
            rain_anomaly,
            language=lang,
        )

        return ClimateResponse(
            location=canonical,
            year_from=year_from,
            year_to=year_to,
            temperature_trend=temp_trend,
            rainfall_trend=rain_trend,
            temperature_comparison=temp_comparison,
            rainfall_comparison=rain_comparison,
            temperature_anomaly=temp_anomaly,
            rainfall_anomaly=rain_anomaly,
            season=season,
            insight=insight,
            available_locations=sorted(available),
        )

    def get_available_locations(self) -> List[str]:
        """Return all city names present in the dataset."""
        self._load_records()
        return sorted(self._available_locations or [])

    # ------------------------------------------------------------------
    # Data loading
    # ------------------------------------------------------------------

    def _load_records(self) -> List[HistoricalClimateRecord]:
        """Load and cache all records from the CSV file."""
        if ClimateService._records is not None:
            return ClimateService._records

        if not os.path.exists(self._data_path):
            logger.error("Climate dataset not found at %s", self._data_path)
            ClimateService._records = []
            ClimateService._available_locations = []
            return []

        records: List[HistoricalClimateRecord] = []
        locations: set = set()

        try:
            with open(self._data_path, newline="", encoding="utf-8") as f:
                reader = csv.DictReader(f)
                for row in reader:
                    try:
                        rec = HistoricalClimateRecord(
                            location=row["location"].strip(),
                            year=int(row["year"]),
                            month=int(row["month"]),
                            avg_temp_c=float(row["avg_temp_c"]),
                            max_temp_c=float(row["max_temp_c"]),
                            min_temp_c=float(row["min_temp_c"]),
                            rainfall_mm=float(row["rainfall_mm"]),
                        )
                        records.append(rec)
                        locations.add(rec.location)
                    except (KeyError, ValueError) as exc:
                        logger.warning("Skipping malformed row %s: %s", row, exc)
        except OSError as exc:
            logger.error("Failed to read climate dataset: %s", exc)

        ClimateService._records = records
        ClimateService._available_locations = list(locations)
        logger.info(
            "Climate dataset loaded: %d records, %d locations",
            len(records),
            len(locations),
        )
        return records

    # ------------------------------------------------------------------
    # Filtering helpers
    # ------------------------------------------------------------------

    @staticmethod
    def _filter(
        records: List[HistoricalClimateRecord],
        location: str,
        year_from: Optional[int] = None,
        year_to: Optional[int] = None,
        month: Optional[int] = None,
    ) -> List[HistoricalClimateRecord]:
        result = [r for r in records if r.location == location]
        if year_from is not None:
            result = [r for r in result if r.year >= year_from]
        if year_to is not None:
            result = [r for r in result if r.year <= year_to]
        if month is not None:
            result = [r for r in result if r.month == month]
        return result

    @staticmethod
    def _resolve_location(
        requested: str, available: List[str]
    ) -> Optional[str]:
        """Case-insensitive location match."""
        req_lower = requested.strip().lower()
        for loc in available:
            if loc.lower() == req_lower:
                return loc
        return None

    # ------------------------------------------------------------------
    # Trend calculation
    # ------------------------------------------------------------------

    def _calc_trend(
        self,
        records: List[HistoricalClimateRecord],
        metric: str,
        year_from: int,
        year_to: int,
    ) -> ClimateTrend:
        """Aggregate records by year into a trend series."""
        # Group by year
        by_year: Dict[int, List[HistoricalClimateRecord]] = {}
        for r in records:
            by_year.setdefault(r.year, []).append(r)

        points: List[ClimateTrendPoint] = []
        for year in sorted(by_year):
            recs = by_year[year]
            if metric == "temperature":
                value = round(mean(r.avg_temp_c for r in recs), 2)
                unit = "°C"
            else:  # rainfall
                value = round(sum(r.rainfall_mm for r in recs), 1)
                unit = "mm"
            points.append(ClimateTrendPoint(year=year, value=value))

        unit = "°C" if metric == "temperature" else "mm"
        location = records[0].location if records else ""
        period = f"{year_from}–{year_to}"

        return ClimateTrend(
            location=location,
            metric=metric,
            unit=unit,
            period=period,
            values=points,
        )

    # ------------------------------------------------------------------
    # Baseline helpers
    # ------------------------------------------------------------------

    @staticmethod
    def _baseline_avg_temp(records: List[HistoricalClimateRecord]) -> float:
        """Long-term monthly average temperature across all records."""
        if not records:
            return 0.0
        return round(mean(r.avg_temp_c for r in records), 2)

    @staticmethod
    def _yearly_avg_rain(records: List[HistoricalClimateRecord]) -> float:
        """Average annual rainfall across all years in the record set."""
        if not records:
            return 0.0
        by_year: Dict[int, float] = {}
        for r in records:
            by_year[r.year] = by_year.get(r.year, 0.0) + r.rainfall_mm
        return round(mean(by_year.values()), 1)

    @staticmethod
    def _baseline_avg_rain(records: List[HistoricalClimateRecord]) -> float:
        """Long-term average annual rainfall (same as _yearly_avg_rain over all data)."""
        return ClimateService._yearly_avg_rain(records)

    # ------------------------------------------------------------------
    # Comparison builder
    # ------------------------------------------------------------------

    @staticmethod
    def _build_comparison(
        metric: str, current: float, baseline: float
    ) -> ClimateComparison:
        difference = round(current - baseline, 2)
        if baseline != 0:
            difference_percent = round((difference / baseline) * 100, 1)
        else:
            difference_percent = 0.0

        if abs(difference_percent) <= _NEAR_AVERAGE_PCT:
            interpretation = "near_average"
        elif difference_percent > _NEAR_AVERAGE_PCT:
            interpretation = "above_average"
        else:
            interpretation = "below_average"

        return ClimateComparison(
            metric=metric,
            current_value=round(current, 2),
            historical_average=round(baseline, 2),
            difference=difference,
            difference_percent=difference_percent,
            interpretation=interpretation,
        )

    # ------------------------------------------------------------------
    # Rule-based insight generation (NO LLM)
    # ------------------------------------------------------------------

    @staticmethod
    def _generate_insight(
        temp_interp: str,
        rain_interp: str,
        temp_anomaly: float,
        rain_anomaly: float,
        language: str = "en",
    ) -> str:
        """
        Generate a human-readable climate insight purely from calculated values.
        No Gemini / LLM calls — the text is fully deterministic.
        Supports English ('en') and Tamil ('ta').
        """
        if language == "ta":
            parts: List[str] = []

            # Temperature insight
            if temp_interp == "above_average":
                parts.append(
                    f"வெப்பநிலை வரலாற்று சராசரியை விட அதிகமாக உள்ளது "
                    f"(+{temp_anomaly:.1f}°C சராசரியை விட அதிகம்)."
                )
            elif temp_interp == "below_average":
                parts.append(
                    f"வெப்பநிலை வரலாற்று சராசரியை விட குறைவாக உள்ளது "
                    f"({temp_anomaly:.1f}°C சராசரியை விட குறைவு)."
                )
            else:
                parts.append(
                    "சமீபத்திய வெப்பநிலை வரலாற்று சராசரியுடன் ஒப்பிடும்போது நிலையாக உள்ளது."
                )

            # Rainfall insight
            if rain_interp == "above_average":
                parts.append(
                    f"தேர்ந்தெடுக்கப்பட்ட காலத்தில் மழைப்பொழிவு வரலாற்று சராசரியை விட அதிகமாக உள்ளது "
                    f"(+{rain_anomaly:.0f} mm சராசரியை விட அதிகம்)."
                )
            elif rain_interp == "below_average":
                parts.append(
                    f"மழைப்பொழிவு வரலாற்று சராசரியை விட குறைவாக உள்ளது "
                    f"({rain_anomaly:.0f} mm சராசரியை விட குறைவு)."
                )
            else:
                parts.append("மழைப்பொழிவு இந்த காலத்திற்கான வரலாற்று சராசரிக்கு அருகில் உள்ளது.")

            return " ".join(parts)

        # English
        parts: List[str] = []

        # Temperature insight
        if temp_interp == "above_average":
            parts.append(
                f"Temperature is above the historical average "
                f"(+{temp_anomaly:.1f}°C above baseline)."
            )
        elif temp_interp == "below_average":
            parts.append(
                f"Temperature is below the historical average "
                f"({temp_anomaly:.1f}°C below baseline)."
            )
        else:
            parts.append(
                "Recent temperatures are relatively stable compared with the "
                "historical baseline."
            )

        # Rainfall insight
        if rain_interp == "above_average":
            parts.append(
                f"Rainfall during the selected period is higher than the historical "
                f"average (+{rain_anomaly:.0f} mm above baseline)."
            )
        elif rain_interp == "below_average":
            parts.append(
                f"Rainfall is below the historical average "
                f"({rain_anomaly:.0f} mm below baseline)."
            )
        else:
            parts.append("Rainfall is near the historical average for this period.")

        return " ".join(parts)
