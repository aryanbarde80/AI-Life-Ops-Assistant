from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from routes.chat import router as chat_router
from middleware.logging_middleware import EnterpriseLoggingMiddleware
import os

app = FastAPI(
    title="AI Life Ops Masterpiece",
    description="Enterprise-grade Multi-Agent System Mesh",
    version="2.0.0",
)

# Enterprise Middleware
app.add_middleware(EnterpriseLoggingMiddleware)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(chat_router, prefix="")

# Serve static files from the 'frontend_build' directory
if os.path.exists("frontend_build"):
    app.mount("/", StaticFiles(directory="frontend_build", html=True), name="frontend")


@app.get("/health")
async def health_check():
    return {"status": "ok", "service": "AI System Mesh active"}


@app.get("/")
async def root():
    return {
        "message": "AI Life Ops Assistant API",
        "endpoints": {
            "chat": "POST /chat",
            "health": "GET /health",
        },
    }
