import os
import asyncio
from typing import Dict
from langchain_openai import ChatOpenAI
from langchain.chains import ConversationChain
from langchain.memory import ConversationBufferMemory
from langchain.prompts import (
    ChatPromptTemplate,
    MessagesPlaceholder,
    HumanMessagePromptTemplate,
    SystemMessagePromptTemplate,
)

# Per-user conversation chains stored in memory
_user_chains: Dict[str, ConversationChain] = {}

SYSTEM_PROMPT = """You are an AI Life Ops Assistant — a highly capable personal productivity coach and life organizer.

Your role includes:
- Helping users plan and prioritize their tasks and goals
- Breaking down large projects into manageable action steps
- Offering motivational support and accountability
- Providing time-management and productivity strategies
- Helping users reflect on their habits and optimize their routines
- Tracking and managing tasks when asked
- Giving concise, actionable advice

Tone: Friendly, professional, and empowering. Keep responses clear and structured.
Always be proactive in asking clarifying questions when a user's goal is vague."""


def _create_chain_for_user(user_id: str) -> ConversationChain:
    """Create a new LangChain conversation chain for a given user."""
    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        raise ValueError("OPENAI_API_KEY environment variable not set.")

    llm = ChatOpenAI(
        model="gpt-4o-mini",
        temperature=0.7,
        api_key=api_key,
    )

    prompt = ChatPromptTemplate.from_messages([
        SystemMessagePromptTemplate.from_template(SYSTEM_PROMPT),
        MessagesPlaceholder(variable_name="history"),
        HumanMessagePromptTemplate.from_template("{input}"),
    ])

    memory = ConversationBufferMemory(return_messages=True)

    chain = ConversationChain(
        llm=llm,
        prompt=prompt,
        memory=memory,
        verbose=False,
    )

    return chain


def _get_or_create_chain(user_id: str) -> ConversationChain:
    """Retrieve existing chain or create a new one for the user."""
    if user_id not in _user_chains:
        _user_chains[user_id] = _create_chain_for_user(user_id)
    return _user_chains[user_id]


async def get_agent_response(user_id: str, message: str) -> str:
    """
    Generate an AI response for the given user message.
    Runs the synchronous LangChain chain in a thread pool to avoid blocking.
    """
    chain = _get_or_create_chain(user_id)

    loop = asyncio.get_event_loop()
    response = await loop.run_in_executor(
        None,
        lambda: chain.predict(input=message),
    )

    return response
