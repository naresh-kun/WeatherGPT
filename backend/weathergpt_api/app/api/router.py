"""
WeatherGPT API — Main Router
Aggregates all route modules under /api/v1
"""

from fastapi import APIRouter
from app.api.routes import health, weather, chat, alerts, advisory, climate

api_router = APIRouter()

api_router.include_router(health.router,    prefix="/health",   tags=["Health"])
api_router.include_router(weather.router,   prefix="/weather",  tags=["Weather"])
api_router.include_router(chat.router,      prefix="/chat",     tags=["Chat"])
api_router.include_router(alerts.router,    prefix="/alerts",   tags=["Alerts"])
api_router.include_router(advisory.router,  prefix="/advisory", tags=["Advisory"])
api_router.include_router(climate.router,   prefix="/climate",  tags=["Climate"])
