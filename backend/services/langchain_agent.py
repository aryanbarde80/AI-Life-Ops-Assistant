import os
import asyncio
from typing import Dict, Any
from langchain_openai import ChatOpenAI
from langchain_community.llms import LlamaCpp
from langchain.chains import ConversationChain
from langchain.memory import ConversationBufferMemory
from langchain.prompts import (
    ChatPromptTemplate,
    MessagesPlaceholder,
    HumanMessagePromptTemplate,
    SystemMessagePromptTemplate,
)

from core.config import settings
from core.prompts import SYSTEM_PROMPT

# Per-user conversation chains stored in memory
_user_chains: Dict[str, ConversationChain] = {}

def _get_llm(use_ollama: bool = False) -> Any:
    """Initialize OpenAI LLM, or fallback to local LlamaCpp if API fails."""
    api_key = settings.OPENAI_API_KEY

    if api_key and api_key.startswith("sk-") and not use_ollama:
        try:
            return ChatOpenAI(
                model="gpt-4o-mini",
                temperature=0.7,
                api_key=api_key,
                max_retries=1,
            )
        except Exception as e:
            print(f"[LLM] OpenAI failed: {e}. Falling back...")

    # Fallback: Local Tiny Model
    if os.path.exists(settings.MODEL_PATH):
        try:
            return LlamaCpp(
                model_path=settings.MODEL_PATH,
                temperature=0.7,
                max_tokens=512,
                n_ctx=2048,
                f16_kv=True,
                verbose=False,
                n_threads=1,
            )
        except Exception as e:
            print(f"[LLM] Local model failed load: {e}")

    raise ValueError("System Shutdown: No LLM available.")

from services.ai_tools import AI_TOOLS

def _create_chain_for_user(user_id: str) -> ConversationChain:
    """Enterprise chain creation with Tools and modular prompts."""
    llm = _get_llm()
    
    # Bind tools to the LLM (requires modern LangChain/OpenAI)
    # Note: LlamaCpp might need specialized prompting for tools
    llm_with_tools = llm.bind_tools(AI_TOOLS)

    prompt = ChatPromptTemplate.from_messages([
        SystemMessagePromptTemplate.from_template(SYSTEM_PROMPT),
        MessagesPlaceholder(variable_name="history"),
        HumanMessagePromptTemplate.from_template("{input}"),
    ])

    memory = ConversationBufferMemory(return_messages=True)
    return ConversationChain(llm=llm_with_tools, prompt=prompt, memory=memory, verbose=False)


def _get_or_create_chain(user_id: str) -> ConversationChain:
    """Retrieve existing chain or create a new one for the user."""
    if user_id not in _user_chains:
        _user_chains[user_id] = _create_chain_for_user(user_id)
    return _user_chains[user_id]


async def get_agent_response(user_id: str, message: str) -> str:
    """
    Generate an AI response with RAG context.
    """
    from services.firestore_service import FirestoreService
    fs = FirestoreService()
    
    # RAG: Fetch relevant personal context
    context = await fs.get_recent_context(user_id)
    enriched_message = f"{context}\n\nUSER MESSAGE: {message}"
    
    try:
        chain = _get_or_create_chain(user_id)
        loop = asyncio.get_event_loop()
        response = await loop.run_in_executor(
            None,
            lambda: chain.predict(input=enriched_message),
        )
        
        # Award 50 XP per message for engagement (Async)
        asyncio.create_task(fs.add_xp(user_id, 50))
        
        return response
    except Exception as e:
        print(f"[LLM] Chain prediction failed: {e}. Retrying with local fallback...")
        # Force re-creation with local model on error
        _user_chains[user_id] = _create_chain_for_user(user_id) 
        chain = _user_chains[user_id]
        loop = asyncio.get_event_loop()
        response = await loop.run_in_executor(
            None,
            lambda: chain.predict(input=message),
        )
        return response
