# 🧠 AI Life Ops Assistant

A production-ready full-stack AI-powered personal productivity app.

**Stack:** Flutter Web · FastAPI · LangChain · OpenAI GPT-4o mini · Firebase Firestore · Docker · Render

---

## 📁 Project Structure

```
ai-life-ops-assistant/
├── backend/
│   ├── main.py                        # FastAPI app + CORS
│   ├── routes/chat.py                 # POST /chat endpoint
│   ├── services/langchain_agent.py    # LangChain ConversationChain per user
│   ├── services/firestore_service.py  # Firestore async read/write
│   ├── requirements.txt
│   ├── Dockerfile
│   └── .env.example
├── frontend/
│   ├── lib/
│   │   ├── main.dart                  # App entry + NavigationRail shell
│   │   ├── screens/
│   │   │   ├── chat_screen.dart       # Chat UI with markdown + typing indicator
│   │   │   ├── dashboard_screen.dart  # Stats, upcoming tasks, daily tips
│   │   │   └── tasks_screen.dart      # Full task CRUD with priority filters
│   │   ├── providers/
│   │   │   ├── chat_provider.dart
│   │   │   └── task_provider.dart
│   │   ├── models/
│   │   │   ├── chat_message.dart
│   │   │   └── task.dart
│   │   ├── services/api_service.dart
│   │   └── theme/app_theme.dart
│   ├── web/index.html
│   ├── nginx.conf
│   ├── pubspec.yaml
│   └── Dockerfile
├── docker-compose.yml
├── render.yaml
└── README.md
```

---

## ⚙️ Local Setup

### 1. Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- A Firebase project with Firestore enabled
- An OpenAI API key

### 2. Environment Variables

Copy and fill in the backend env file:

```bash
cp backend/.env.example backend/.env
```

Set these two values in `backend/.env`:

| Variable         | Description |
|-----------------|-------------|
| `OPENAI_API_KEY` | Your OpenAI API key from [platform.openai.com](https://platform.openai.com/api-keys) |
| `FIREBASE_CONFIG` | Base64-encoded Firebase service account JSON (see below) |

**Encoding your Firebase service account:**

```powershell
# Windows PowerShell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("path\to\service-account.json"))
```

```bash
# Linux / macOS
base64 -w 0 service-account.json
```

Paste the output as the value for `FIREBASE_CONFIG`.

### 3. Run with Docker Compose

```bash
# From the project root
docker compose --env-file backend/.env up --build
```

- **Frontend:** http://localhost:80
- **Backend API:** http://localhost:10000
- **Health check:** http://localhost:10000/health

---

## 🧪 Test the API

```bash
# Health check
curl http://localhost:10000/health

# Chat endpoint
curl -X POST http://localhost:10000/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Help me plan my day", "user_id": "test-user-1"}'
```

---

## 🚀 Deploy to Render (The Easy Way)

This project is configured for **Unified Deployment**. Your Frontend and Backend run in a single container on a single URL.

### 1. Push to GitHub
If you haven't yet, push your latest changes:
```bash
git add .
git commit -m "feat: unified deployment"
git push origin main
```

### 2. Connect on Render
1. Log in to [render.com](https://render.com).
2. Click **New → Blueprint**.
3. Connect this GitHub repository.
4. Render will read `render.yaml` and set everything up automatically.

### 3. Set Env Vars
In the Render dashboard for the new service, go to **Environment** and add:
- `OPENAI_API_KEY`: Your key.
- `FIREBASE_CONFIG`: Your base64-encoded service account JSON.

### 4. Done!
Once the build finishing, your app will be live on a single URL. No more hardcoded IP addresses or multiple services!

---

## 🎯 Features

| Feature | Description |
|---------|-------------|
| 📦 **Unified Container** | Frontend + Backend served from one port (10000) |
| 💬 **AI Chat** | Conversational AI with persistent memory |
| 📋 **Task Manager** | Add, complete, delete, filter by priority |
| 📊 **Dashboard** | Live stats and progress bar |
| 🌙 **Dark UI** | Premium indigo/violet theme |
| 🔒 **Firestore** | Data persisted to Firebase |

---

## 🔌 API Reference

### `POST /chat`

```json
// Request
{
  "message": "Help me set a goal for this month",
  "user_id": "user-123"
}

// Response
{
  "response": "Great! Let's start by identifying what matters most to you..."
}
```

### `GET /health`

```json
{ "status": "ok", "service": "AI Life Ops Assistant Backend" }
```
