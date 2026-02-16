# backend/api/routes/chat.py
from fastapi import APIRouter, HTTPException, Request
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
import logging
import uuid

# Import the agent runner
from google.adk.agents import Agent

# IMPORT MISSING SERVICE
from services.session_service import SessionService

# Import the root agent
from agent.agent import root_agent

# Configure logging
logger = logging.getLogger(__name__)

# Create router
router = APIRouter()

# INITIALIZE SERVICE
session_service = SessionService()

class ChatMessage(BaseModel):
    role: str
    content: str

class ChatRequest(BaseModel):
    message: str
    session_id: Optional[str] = None
    user_id: str = "user"  # Default user ID
    stream: bool = False

class ChatResponse(BaseModel):
    response: str
    session_id: str

@router.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    """
    Chat endpoint that processes user messages using the agent.
    """
    try:
        user_id = request.user_id
        session_id = request.session_id
        
        # 1. Create or get session
        if not session_id:
            # Create new session if none provided
            session = await session_service.create_session(
                user_id=user_id, 
                app_name="survivor-network"
            )
            session_id = session.session_id
            logger.info(f"Created new session: {session_id}")
        else:
            # Verify existing session
            session = await session_service.get_session(session_id)
            if not session:
                logger.warning(f"Session {session_id} not found, creating new one")
                session = await session_service.create_session(
                    user_id=user_id, 
                    app_name="survivor-network"
                )
                session_id = session.session_id

        # 2. Add user message to history
        await session_service.add_message(
            session_id=session_id,
            role="user",
            content=request.message
        )
        
        # 3. Get agent response
        # Run the agent with the user's message
        response_text = ""
        
        # Run the agent
        # We need to construct the context properly
        # In a real app, you might load history here to pass to the agent
        
        # Simple invocation for now - the agent should handle history via memory tool if configured
        result = root_agent.run(request.message)
        
        if isinstance(result, str):
            response_text = result
        else:
            # Handle object response if needed
            response_text = str(result)
            
        # 4. Add assistant response to history
        await session_service.add_message(
            session_id=session_id,
            role="model",
            content=response_text
        )
        
        return ChatResponse(
            response=response_text,
            session_id=session_id
        )

    except Exception as e:
        logger.error(f"Error in chat endpoint: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Error processing message: {str(e)}")

@router.get("/history/{session_id}")
async def get_history(session_id: str):
    """Get chat history for a session."""
    try:
        messages = await session_service.get_chat_history(session_id)
        return {"messages": messages}
    except Exception as e:
        logger.error(f"Error getting history: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))