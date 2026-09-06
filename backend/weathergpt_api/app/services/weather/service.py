"""
Weather Service
Business logic layer mapping WeatherAPI data to application schemas.
"""
import time
from typing import List, Dict, Any, Optional
from app.services.weather.client import WeatherAPIClient
from app.schemas.weather import (
    WeatherCurrent, Location, HourlyForecast, DailyForecast, 
    WeatherForecast, LocationSearchResult
)
from app.schemas.alerts import Alert, AlertsResponse, AlertSeverity, AlertType
import uuid

class WeatherService:
    def __init__(self):
        self.client = WeatherAPIClient()

    def _map_location(self, loc_data: Dict[str, Any]) -> Location:
        """Map WeatherAPI location to our Location schema."""
        return Location(
            lat=loc_data.get("lat", 0.0),
            lon=loc_data.get("lon", 0.0),
            city=loc_data.get("name"),
            country=loc_data.get("country"),
            timezone=loc_data.get("tz_id")
        )

    def _get_q(self, lat: float, lon: float) -> str:
        """Format lat/lon into WeatherAPI q parameter."""
        return f"{lat},{lon}"

    async def get_current(self, lat: float, lon: float) -> WeatherCurrent:
        """Get current weather for coordinates."""
        q = self._get_q(lat, lon)
        data = await self.client.get_current(q)
        
        loc = self._map_location(data["location"])
        current = data["current"]
        
        return WeatherCurrent(
            location=loc,
            temperature=current.get("temp_c", 0.0),
            feels_like=current.get("feelslike_c", 0.0),
            humidity=current.get("humidity", 0),
            wind_speed=current.get("wind_kph", 0.0) * 1000 / 3600, # Convert kph to m/s
            wind_direction=current.get("wind_degree", 0),
            description=current.get("condition", {}).get("text", "Unknown"),
            icon=current.get("condition", {}).get("icon", ""),
            uv_index=current.get("uv"),
            visibility=current.get("vis_km"),
            timestamp=current.get("last_updated_epoch", int(time.time()))
        )

    async def get_forecast(self, lat: float, lon: float, days: int) -> WeatherForecast:
        """Get multi-day forecast for coordinates."""
        q = self._get_q(lat, lon)
        data = await self.client.get_forecast(q, days=days)
        
        loc = self._map_location(data["location"])
        forecast_days = data.get("forecast", {}).get("forecastday", [])
        
        daily_list = []
        hourly_list = []
        
        for fday in forecast_days:
            day_data = fday["day"]
            
            # Map daily
            daily_list.append(DailyForecast(
                date=fday["date"],
                temp_min=day_data.get("mintemp_c", 0.0),
                temp_max=day_data.get("maxtemp_c", 0.0),
                humidity=day_data.get("avghumidity", 0),
                wind_speed=day_data.get("maxwind_kph", 0.0) * 1000 / 3600,
                description=day_data.get("condition", {}).get("text", ""),
                icon=day_data.get("condition", {}).get("icon", ""),
                sunrise=fday.get("astro", {}).get("sunrise_epoch", 0),  # Not always provided in epoch by WeatherAPI, but let's assume if it exists or use default
                sunset=fday.get("astro", {}).get("sunset_epoch", 0),
                precipitation_probability=day_data.get("daily_chance_of_rain", 0) / 100.0
            ))
            
            # Map hourly for this day
            for hour_data in fday.get("hour", []):
                hourly_list.append(HourlyForecast(
                    timestamp=hour_data.get("time_epoch", 0),
                    temperature=hour_data.get("temp_c", 0.0),
                    feels_like=hour_data.get("feelslike_c", 0.0),
                    humidity=hour_data.get("humidity", 0),
                    wind_speed=hour_data.get("wind_kph", 0.0) * 1000 / 3600,
                    description=hour_data.get("condition", {}).get("text", ""),
                    icon=hour_data.get("condition", {}).get("icon", ""),
                    precipitation_probability=hour_data.get("chance_of_rain", 0) / 100.0
                ))
                
        return WeatherForecast(
            location=loc,
            hourly=hourly_list,
            daily=daily_list,
            units="metric"
        )

    async def get_hourly_forecast(self, lat: float, lon: float, limit: int = 24) -> List[HourlyForecast]:
        """Convenience method to just get hourly data for the next N hours."""
        # Need at least 2 days to get 24 hours from current time
        forecast = await self.get_forecast(lat, lon, days=2)
        
        current_time = int(time.time())
        future_hours = [h for h in forecast.hourly if h.timestamp >= current_time]
        
        return future_hours[:limit]

    async def search_locations(self, query: str) -> List[LocationSearchResult]:
        """Search for locations by name."""
        data = await self.client.search(query)
        results = []
        for item in data:
            results.append(LocationSearchResult(
                name=item.get("name", ""),
                region=item.get("region", ""),
                country=item.get("country", ""),
                lat=item.get("lat", 0.0),
                lon=item.get("lon", 0.0),
                url=item.get("url")
            ))
        return results

    def _map_severity(self, severity_str: str) -> AlertSeverity:
        severity_str = severity_str.lower() if severity_str else ""
        if "extreme" in severity_str:
            return AlertSeverity.EXTREME
        elif "severe" in severity_str:
            return AlertSeverity.SEVERE
        elif "moderate" in severity_str:
            return AlertSeverity.MODERATE
        return AlertSeverity.MINOR

    async def get_alerts(self, lat: float, lon: float) -> AlertsResponse:
        """Get active weather alerts."""
        q = self._get_q(lat, lon)
        data = await self.client.get_alerts(q)
        
        alerts_data = data.get("alerts", {}).get("alert", [])
        
        mapped_alerts = []
        for a in alerts_data:
            # WeatherAPI returns strings for fields like event, severity, certainty
            severity = self._map_severity(a.get("severity", ""))
            
            # Simple heuristic for alert type mapping
            event = a.get("event", "").lower()
            if "thunder" in event:
                alert_type = AlertType.THUNDERSTORM
            elif "flood" in event:
                alert_type = AlertType.FLOOD
            elif "cyclone" in event or "hurricane" in event or "typhoon" in event:
                alert_type = AlertType.CYCLONE
            elif "heat" in event:
                alert_type = AlertType.HEATWAVE
            elif "cold" in event or "freeze" in event or "winter" in event:
                alert_type = AlertType.COLDWAVE
            elif "drought" in event:
                alert_type = AlertType.DROUGHT
            elif "fog" in event:
                alert_type = AlertType.FOG
            else:
                alert_type = AlertType.OTHER

            # Attempt to parse effective/expires (often provided as ISO strings or we use current time as fallback)
            # WeatherAPI typically gives 'effective' and 'expires' as ISO format strings.
            # For simplicity, we just use the current epoch and current+24h if they are hard to parse.
            # In a real app we would parse datetime.fromisoformat(a.get("effective"))
            from datetime import datetime
            
            start_time = int(time.time())
            if a.get("effective"):
                try:
                    # WeatherAPI sometimes uses format like '2023-08-25T13:42:00+01:00'
                    start_time = int(datetime.fromisoformat(a["effective"]).timestamp())
                except:
                    pass
                    
            end_time = start_time + 86400
            if a.get("expires"):
                try:
                    end_time = int(datetime.fromisoformat(a["expires"]).timestamp())
                except:
                    pass

            alert_id = f"alert-{uuid.uuid4().hex[:8]}"

            mapped_alerts.append(Alert(
                alert_id=alert_id,
                alert_type=alert_type,
                severity=severity,
                title=a.get("headline", event.title() or "Weather Alert"),
                description=a.get("desc", ""),
                area=a.get("areas", ""),
                start_time=start_time,
                end_time=end_time,
                source=a.get("instruction", "Meteorological Authority") # Using instruction as source fallback if needed or keep None. actually WeatherAPI doesn't usually provide strict 'source', so we leave it empty.
            ))
            
        return AlertsResponse(
            alerts=mapped_alerts,
            total=len(mapped_alerts)
        )
