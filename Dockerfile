FROM python:3.10-slim
WORKDIR /app
COPY backend/weathergpt_api/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY backend/weathergpt_api /app
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
