"""
Tests for WeatherGPT Climate Intelligence (Phase 7).

Covers:
- Valid climate data
- Temperature calculations & trends
- Rainfall calculations & trends
- Temperature anomaly
- Rainfall anomaly & interpretation
- Seasonal analysis (Winter, Summer, SW Monsoon, NE Monsoon)
- Multiple locations (Madurai, Chennai, Coimbatore, Tirunelveli)
- Empty dataset handling
- Invalid location handling (ValueError & 404)
- Malformed / missing values in CSV
- API response structure & validation
- API query parameters & error cases
"""

import os
import tempfile
import pytest
from fastapi.testclient import TestClient

from app.main import app
from app.schemas.climate import ClimateResponse
from app.services.climate.service import ClimateService, _SEASON_MAP

client = TestClient(app)


# ---------------------------------------------------------------------------
# Unit tests — ClimateService
# ---------------------------------------------------------------------------


class TestClimateService:
    @pytest.fixture(autouse=True)
    def setup_service(self):
        self.service = ClimateService()

    def test_valid_climate_data(self):
        """Test default climate request returns complete and valid response."""
        res = self.service.get_climate("Madurai")
        assert isinstance(res, ClimateResponse)
        assert res.location == "Madurai"
        assert res.year_from == 2000
        assert res.year_to == 2023
        assert len(res.temperature_trend.values) > 0
        assert len(res.rainfall_trend.values) > 0
        assert res.data_source is not None
        assert "prototype" in res.data_source.lower() or "reference" in res.data_source.lower()

    def test_temperature_calculations(self):
        """Verify temperature trend values are calculated correctly."""
        res = self.service.get_climate("Madurai", year_from=2000, year_to=2005)
        trend = res.temperature_trend
        assert trend.metric == "temperature"
        assert trend.unit == "°C"
        assert len(trend.values) == 6
        assert trend.values[0].year == 2000
        # Check temperature is within realistic range for Madurai (20-40°C)
        for pt in trend.values:
            assert 20.0 <= pt.value <= 40.0

        # Verify comparison
        comp = res.temperature_comparison
        assert comp.metric == "temperature"
        assert comp.current_value > 0
        assert comp.historical_average > 0
        assert comp.difference == round(comp.current_value - comp.historical_average, 2)
        assert comp.interpretation in ("above_average", "near_average", "below_average")

    def test_rainfall_calculations(self):
        """Verify rainfall totals and trends are calculated correctly."""
        res = self.service.get_climate("Madurai", year_from=2000, year_to=2005)
        trend = res.rainfall_trend
        assert trend.metric == "rainfall"
        assert trend.unit == "mm"
        assert len(trend.values) == 6
        for pt in trend.values:
            assert pt.value >= 0  # Rainfall cannot be negative

        # Verify comparison
        comp = res.rainfall_comparison
        assert comp.metric == "rainfall"
        assert comp.current_value >= 0
        assert comp.historical_average >= 0
        assert comp.difference == round(comp.current_value - comp.historical_average, 2)
        assert comp.interpretation in ("above_average", "near_average", "below_average")

    def test_temperature_anomaly(self):
        """Verify temperature anomaly equals current minus baseline."""
        res = self.service.get_climate("Madurai", year_from=2015, year_to=2023)
        expected_diff = round(
            res.temperature_comparison.current_value
            - res.temperature_comparison.historical_average,
            2,
        )
        assert res.temperature_anomaly == expected_diff

    def test_rainfall_anomaly(self):
        """Verify rainfall anomaly equals current minus baseline."""
        res = self.service.get_climate("Madurai", year_from=2015, year_to=2023)
        expected_diff = round(
            res.rainfall_comparison.current_value
            - res.rainfall_comparison.historical_average,
            1,
        )
        assert res.rainfall_anomaly == expected_diff
        assert res.rainfall_comparison.interpretation in (
            "above_average",
            "near_average",
            "below_average",
        )

    def test_seasonal_analysis(self):
        """Verify season mapping for different months."""
        # Winter months: Dec, Jan, Feb
        assert _SEASON_MAP[1] == "Winter"
        assert _SEASON_MAP[2] == "Winter"
        assert _SEASON_MAP[12] == "Winter"

        # Summer months: Mar, Apr, May
        assert _SEASON_MAP[3] == "Summer"
        assert _SEASON_MAP[4] == "Summer"
        assert _SEASON_MAP[5] == "Summer"

        # Southwest Monsoon: Jun, Jul, Aug, Sep
        assert _SEASON_MAP[6] == "Southwest Monsoon"
        assert _SEASON_MAP[7] == "Southwest Monsoon"
        assert _SEASON_MAP[8] == "Southwest Monsoon"
        assert _SEASON_MAP[9] == "Southwest Monsoon"

        # Northeast Monsoon: Oct, Nov
        assert _SEASON_MAP[10] == "Northeast Monsoon"
        assert _SEASON_MAP[11] == "Northeast Monsoon"

        # Check response has season when querying specific month
        res_jan = self.service.get_climate("Madurai", month=1)
        assert res_jan.season == "Winter"

        res_may = self.service.get_climate("Madurai", month=5)
        assert res_may.season == "Summer"

        res_oct = self.service.get_climate("Madurai", month=10)
        assert res_oct.season == "Northeast Monsoon"

    def test_multiple_locations(self):
        """Verify service handles all supported Tamil Nadu cities."""
        locations = ["Madurai", "Chennai", "Coimbatore", "Tirunelveli"]
        available = self.service.get_available_locations()
        for loc in locations:
            assert loc in available
            res = self.service.get_climate(loc)
            assert res.location == loc
            assert len(res.temperature_trend.values) > 0
            assert len(res.rainfall_trend.values) > 0

    def test_case_insensitive_location(self):
        """Verify case-insensitive location resolution."""
        res_lower = self.service.get_climate("chennai")
        assert res_lower.location == "Chennai"

        res_upper = self.service.get_climate("MADURAI")
        assert res_upper.location == "Madurai"

    def test_invalid_location_raises_value_error(self):
        """Verify unknown location raises ValueError with available choices."""
        with pytest.raises(ValueError) as exc_info:
            self.service.get_climate("Atlantis")
        assert "not found" in str(exc_info.value).lower()
        assert "Madurai" in str(exc_info.value)

    def test_deterministic_insights(self):
        """Verify insights are reproducible and rule-based (no randomness)."""
        res1 = self.service.get_climate("Madurai", year_from=2010, year_to=2020)
        res2 = self.service.get_climate("Madurai", year_from=2010, year_to=2020)
        assert res1.insight == res2.insight
        assert len(res1.insight) > 10

    def test_empty_dataset_handling(self):
        """Test service behaviour when data path points to empty file."""
        with tempfile.NamedTemporaryFile(mode="w", suffix=".csv", delete=False) as tmp:
            tmp.write("location,year,month,avg_temp_c,max_temp_c,min_temp_c,rainfall_mm\n")
            tmp_path = tmp.name

        try:
            # Create a separate instance with temporary path
            empty_svc = ClimateService(data_path=tmp_path)
            # Reset class cache temporarily
            orig_records = ClimateService._records
            orig_locations = ClimateService._available_locations
            ClimateService._records = None
            ClimateService._available_locations = None

            records = empty_svc._load_records()
            assert len(records) == 0

            # Restore cache
            ClimateService._records = orig_records
            ClimateService._available_locations = orig_locations
        finally:
            if os.path.exists(tmp_path):
                os.remove(tmp_path)

    def test_missing_or_malformed_csv_rows(self):
        """Verify service skips malformed rows without crashing."""
        with tempfile.NamedTemporaryFile(
            mode="w", suffix=".csv", delete=False, encoding="utf-8"
        ) as tmp:
            tmp.write("location,year,month,avg_temp_c,max_temp_c,min_temp_c,rainfall_mm\n")
            tmp.write("Madurai,2020,1,25.0,30.0,20.0,10.0\n")
            tmp.write("Madurai,invalid_year,1,25.0,30.0,20.0,10.0\n")  # bad row
            tmp.write("Madurai,2020,2,26.0,31.0,21.0,12.0\n")
            tmp_path = tmp.name

        try:
            test_svc = ClimateService(data_path=tmp_path)
            orig_records = ClimateService._records
            orig_locations = ClimateService._available_locations
            ClimateService._records = None
            ClimateService._available_locations = None

            records = test_svc._load_records()
            assert len(records) == 2  # skipped bad row

            ClimateService._records = orig_records
            ClimateService._available_locations = orig_locations
        finally:
            if os.path.exists(tmp_path):
                os.remove(tmp_path)


# ---------------------------------------------------------------------------
# API Integration tests
# ---------------------------------------------------------------------------


class TestClimateAPI:
    def test_get_climate_success(self):
        """GET /api/v1/climate returns 200 with complete ClimateResponse."""
        response = client.get("/api/v1/climate?location=Madurai")
        assert response.status_code == 200
        data = response.json()
        assert data["location"] == "Madurai"
        assert data["year_from"] == 2000
        assert data["year_to"] == 2023
        assert "temperature_trend" in data
        assert "rainfall_trend" in data
        assert "temperature_comparison" in data
        assert "rainfall_comparison" in data
        assert "temperature_anomaly" in data
        assert "rainfall_anomaly" in data
        assert "season" in data
        assert "insight" in data
        assert "data_source" in data
        assert isinstance(data["available_locations"], list)
        assert "Madurai" in data["available_locations"]

    def test_get_climate_with_year_filter(self):
        """GET /api/v1/climate with custom year_from and year_to."""
        response = client.get(
            "/api/v1/climate?location=Chennai&year_from=2010&year_to=2015"
        )
        assert response.status_code == 200
        data = response.json()
        assert data["location"] == "Chennai"
        assert data["year_from"] == 2010
        assert data["year_to"] == 2015
        assert len(data["temperature_trend"]["values"]) == 6

    def test_get_climate_with_month_filter(self):
        """GET /api/v1/climate with month=10 (Northeast Monsoon)."""
        response = client.get("/api/v1/climate?location=Madurai&month=10")
        assert response.status_code == 200
        data = response.json()
        assert data["season"] == "Northeast Monsoon"

    def test_get_climate_invalid_location_404(self):
        """GET /api/v1/climate with invalid location returns 404."""
        response = client.get("/api/v1/climate?location=UnknownCity")
        assert response.status_code == 404
        assert "not found" in response.json()["detail"].lower()

    def test_get_climate_invalid_year_range_400(self):
        """GET /api/v1/climate with year_from > year_to returns 400."""
        response = client.get(
            "/api/v1/climate?location=Madurai&year_from=2020&year_to=2010"
        )
        assert response.status_code == 400
        assert "cannot be greater than" in response.json()["detail"]

    def test_get_climate_trends_legacy_endpoint(self):
        """GET /api/v1/climate/trends returns trend data."""
        response = client.get("/api/v1/climate/trends?location=Madurai&parameter=temperature")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "success"
        assert data["location"] == "Madurai"
        assert "trend" in data
        assert data["trend"]["metric"] == "temperature"

    def test_get_climate_trends_rainfall(self):
        """GET /api/v1/climate/trends for rainfall returns rainfall metric."""
        response = client.get("/api/v1/climate/trends?location=Madurai&parameter=rainfall")
        assert response.status_code == 200
        data = response.json()
        assert data["trend"]["metric"] == "rainfall"
