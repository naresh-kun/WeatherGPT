"""
WeatherGPT FastAPI — Application Entry Point
"""

from fastapi import FastAPI
from app.api.router import api_router
from app.core.logging import configure_logging

configure_logging()

app = FastAPI(
    title="WeatherGPT API",
    description=(
        "Conversational weather intelligence backend providing real-time weather, "
        "forecasts, chat, alerts, advisories, and climate trend data."
    ),
    version="0.1.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

app.include_router(api_router, prefix="/api/v1")


@app.get("/", tags=["root"])
async def root() -> dict:
    """Root endpoint — confirms the API is running."""
    return {"message": "WeatherGPT API is running", "version": "0.1.0"}
