# AI Life Ops Assistant — Deep System Design

## 🏗️ Core Architecture (Clean Architecture)

The project follows the principles of **Clean Architecture**, separating concerns into layers to ensure testability, scalability, and maintainability.

### 1. Presentation Layer (Flutter)
- **State Management**: `Provider` + `ChangeNotifier` for reactive UI.
- **Atomic Design**: Small, reusable widgets (e.g., `GlassCard`, `AnimatedBadge`).
- **Routing**: Sophisticated shell-based navigation for seamless Landing → App transitions.

### 2. Domain Layer (FastAPI)
- **Entities**: Core data models (Task, User, Message).
- **Service Layer**: Business logic (e.g., `ChatService`, `TaskService`).
- **Repositories**: Abstract interfaces for data access (Firestore, VectorDB).

### 3. Data Layer
- **Persistence**: Firebase Firestore (Async).
- **Knowledge Base (RAG)**: Retrieval-Augmented Generation using a local embedding-based context store.

---

## 🤖 Agentic AI Framework

We use an **Agent-Centric** approach rather than simple prompt-response.

### The Reasoning Loop
1.  **Input Parsing**: System identifies intent (Task, Query, or Meta-talk).
2.  **Knowledge Retrieval (RAG)**: If the query relates to the user's past data or stored "knowledge", the RAG engine fetches relevant context.
3.  **Tool Execution**: The agent can (mocked or actual) interact with tools like "Task Manager" or "Calendar".
4.  **Consolidated Output**: Final response generated using GPT-4o-mini (Primary) or Qwen-0.5B (Fallback).

---

## 📚 RAG Pipeline (Retrieval-Augmented Generation)

To provide "long-term memory":
- **Ingestion**: Every task and significant chat is indexed.
- **Context Window**: Before every AI call, we inject the most relevant "Snippets" of knowledge into the system prompt.
- **Optimization**: We use semantic similarity to prune the context, keeping the token count low and relevance high.

---

## 📦 Deployment Strategy (Docker All-In-One)

- **Build Pipeline**: Multi-stage Docker build to build the Flutter static files.
- **Runtime**: FastAPI serves both the API and the Static Assets.
- **Performance**: Nginx-like serving via `StaticFiles` with Gzip compression enabled.
