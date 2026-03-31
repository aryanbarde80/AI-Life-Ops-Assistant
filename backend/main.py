from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routes.chat import router as chat_router

app = FastAPI(
    title="AI Life Ops Assistant",
    description="Backend for the AI Life Ops Assistant powered by LangChain and OpenAI",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(chat_router, prefix="")


@app.get("/health")
async def health_check():
    return {"status": "ok", "service": "AI Life Ops Assistant Backend"}


@app.get("/")
async def root():
    return {
        "message": "AI Life Ops Assistant API",
        "endpoints": {
            "chat": "POST /chat",
            "health": "GET /health",
        },
    }
