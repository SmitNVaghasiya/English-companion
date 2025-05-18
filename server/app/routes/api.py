from fastapi import APIRouter, HTTPException, Request, status
from app.models.message import ChatInput
from app.services.groq_service import get_chat_response
from app.services.tts_service import text_to_speech
from app.services.stt_service import voice_to_text
from datetime import datetime
import logging
from typing import Dict

logger = logging.getLogger(__name__)
router = APIRouter()

def get_current_timestamp() -> str:
    """Get current ISO formatted timestamp."""
    return datetime.now().isoformat()

@router.post("/chat")
async def chat(input: ChatInput, request: Request):
    """Handle text-based chat messages and return AI response."""
    try:
        messages = [{"role": msg.role, "content": msg.content} for msg in input.messages]
        response_content = get_chat_response(messages, request.app.state.groq_client)
        return {
            "role": "assistant",
            "content": response_content,
            "timestamp": get_current_timestamp()
        }
    except HTTPException as he:
        raise he
    except Exception as e:
        logger.error(f"Error in /chat: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Error processing chat request: {str(e)}")

@router.post("/voice_chat")
async def voice_chat(request: Request):
    """Handle voice input, process it to text, get AI response, and speak it."""
    try:
        # Get user input via STT
        user_text = voice_to_text()
        messages = [{"role": "user", "content": user_text}]
        response_content = get_chat_response(messages, request.app.state.groq_client)
        text_to_speech(response_content)
        return {
            "role": "assistant",
            "content": response_content,
            "timestamp": get_current_timestamp()
        }
    except HTTPException as he:
        raise he
    except Exception as e:
        logger.error(f"Error in /voice_chat: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to process voice request")

@router.post("/end")
async def end_conversation():
    """End the conversation."""
    try:
        return {
            "role": "system",
            "content": "Thank you for practicing! Start a new session anytime.",
            "timestamp": get_current_timestamp()
        }
    except Exception as e:
        logger.error(f"Error in /end: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to end conversation")

@router.get("/health")
async def health_check():
    """Health check endpoint."""
    try:
        return {
            "status": "ok",
            "timestamp": get_current_timestamp(),
            "service": "English Companion API",
            "version": "1.0.0"
        }
    except Exception as e:
        logger.error(f"Error in /health: {str(e)}")
        raise HTTPException(status_code=500, detail="Health check failed")