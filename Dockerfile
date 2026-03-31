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
    g++ \
    cmake \
    libffi-dev \
    libssl-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Python requirements
COPY services/ai-python/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Download tiny local LLM (Qwen2.5-0.5B-Instruct-GGUF)
RUN mkdir -p models && \
    curl -L "https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/qwen2.5-0.5b-instruct-q4_k_m.gguf?download=true" \
    -o models/qwen2.5-0.5b-instruct-q4_k_m.gguf

# Copy backend code
COPY services/ai-python .

# Copy Flutter build output to the 'frontend_build' folder (where FastAPI expects it)
COPY --from=build-env /app/build/web ./frontend_build

# Expose port (Render defaults to 10000 for web services)
EXPOSE 10000

# Start unified app
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "10000"]
