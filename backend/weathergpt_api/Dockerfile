FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Install system dependencies (curl used for HEALTHCHECK)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend application source and data (data/climate/historical_weather.csv is included)
COPY . .

# Create a non-root user for production security
RUN adduser --disabled-password --gecos "" appuser \
    && chown -R appuser:appuser /app
USER appuser

# Default port for local testing; Railway overrides $PORT at runtime
ENV PORT=8000

EXPOSE 8000

# Container liveness probe — hits /api/v1/health every 30 s
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD curl -f http://localhost:${PORT}/api/v1/health || exit 1

# Bind to 0.0.0.0:$PORT using shell expansion for Railway dynamic PORT
CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT}"]
