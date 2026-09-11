"""
WeatherGPT FastAPI — Application Entry Point
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
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

app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"^https?://(localhost|127\.0\.0\.1|10\.0\.2\.2)(:\d+)?$",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router, prefix="/api/v1")


@app.get("/", tags=["root"])
async def root() -> dict:
    """Root endpoint — confirms the API is running."""
    return {"message": "WeatherGPT API is running", "version": "0.1.0"}
