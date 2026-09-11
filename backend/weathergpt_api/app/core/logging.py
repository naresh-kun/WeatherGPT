"""
WeatherGPT — Logging Configuration
Sets up structured logging and security sanitization for the application.
"""

import logging
import re
import sys
from typing import Optional, List
import httpx

from app.core.config import settings


class SensitiveDataFilter(logging.Filter):
    """
    Sanitizes sensitive information (WeatherAPI key, Gemini API key, query strings)
    from all log records before output.
    """

    def __init__(self, sensitive_tokens: Optional[List[str]] = None) -> None:
        super().__init__()
        tokens = sensitive_tokens or [
            settings.weather_api_key,
            settings.gemini_api_key,
            settings.llm_api_key,
        ]
        self.sensitive_tokens = [t for t in tokens if t]

    def _redact_string(self, text: str) -> str:
        if not isinstance(text, str):
            text = str(text)
        # Redact query parameters like ?key=... or &key=...
        redacted = re.sub(r"([?&]key=)[^&\s\'\"]+", r"\g<1>***", text)
        # Redact known secret tokens
        for token in self.sensitive_tokens:
            if token and token in redacted:
                redacted = redacted.replace(token, "***")
        return redacted

    def filter(self, record: logging.LogRecord) -> bool:
        if isinstance(record.msg, str):
            record.msg = self._redact_string(record.msg)
        if record.args:
            if isinstance(record.args, tuple):
                record.args = tuple(
                    self._redact_string(str(arg)) if isinstance(arg, (str, httpx.URL)) else arg
                    for arg in record.args
                )
            elif isinstance(record.args, dict):
                record.args = {
                    k: self._redact_string(str(v)) if isinstance(v, (str, httpx.URL)) else v
                    for k, v in record.args.items()
                }
        return True


def configure_logging(level: int = logging.INFO) -> None:
    """Configure application-wide logging with a structured format and credential sanitization."""
    logging.basicConfig(
        level=level,
        format="%(asctime)s | %(levelname)-8s | %(name)s — %(message)s",
        datefmt="%Y-%m-%dT%H:%M:%S",
        stream=sys.stdout,
    )
    # Attach sensitive data filter to root handlers and key loggers
    sensitive_filter = SensitiveDataFilter()
    root_logger = logging.getLogger()
    root_logger.addFilter(sensitive_filter)
    for handler in root_logger.handlers:
        handler.addFilter(sensitive_filter)

    httpx_logger = logging.getLogger("httpx")
    httpx_logger.addFilter(sensitive_filter)
    for handler in httpx_logger.handlers:
        handler.addFilter(sensitive_filter)

    # Reduce noise from third-party libraries
    logging.getLogger("uvicorn.access").setLevel(logging.WARNING)

