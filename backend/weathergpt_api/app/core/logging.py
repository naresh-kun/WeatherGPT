"""
WeatherGPT — Logging Configuration
Sets up structured logging for the application.
"""

import logging
import sys


def configure_logging(level: int = logging.INFO) -> None:
    """Configure application-wide logging with a structured format."""
    logging.basicConfig(
        level=level,
        format="%(asctime)s | %(levelname)-8s | %(name)s — %(message)s",
        datefmt="%Y-%m-%dT%H:%M:%S",
        stream=sys.stdout,
    )
    # Reduce noise from third-party libraries
    logging.getLogger("uvicorn.access").setLevel(logging.WARNING)
