# ─────────────────────────────────────────────────────────────────
#  Unified Dockerfile for AI Life Ops Assistant
#  Builds Flutter Frontend & Serves via FastAPI Backend
# ─────────────────────────────────────────────────────────────────

# --- Stage 1: Build Flutter Web ---
FROM ghcr.io/cirruslabs/flutter:stable AS build-env

WORKDIR /app
COPY frontend/pubspec.yaml frontend/pubspec.lock* ./
RUN flutter pub get

COPY frontend .
# Use relative API path since they are on the same origin (single container)
RUN flutter build web --release --dart-define=API_BASE_URL=

# --- Stage 2: Python Backend & Final Image ---
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libffi-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python requirements
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend code
COPY backend .

# Copy Flutter build output to the 'frontend_build' folder (where FastAPI expects it)
COPY --from=build-env /app/build/web ./frontend_build

# Expose port (Render defaults to 10000 for web services)
EXPOSE 10000

# Start unified app
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "10000"]
