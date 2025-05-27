from fastapi import APIRouter, HTTPException, UploadFile, File, Request, Form, status
from app.models.message import ChatInput
from app.services.groq_service import get_chat_response
from app.services.stt_service import voice_to_text
from datetime import datetime
import logging
import json
from typing import Dict
from app.core.limiter import limiter

logger = logging.getLogger(__name__)
router = APIRouter()

def get_current_timestamp() -> str:
    """Get current ISO formatted timestamp."""
    try:
        return datetime.now().isoformat()
    except Exception as e:
        logger.error(f"Error getting timestamp: {str(e)}")
        return datetime.now().isoformat()

@router.post("/chat")
async def chat(input: ChatInput, request: Request):
    """Handle text-based chat messages and return AI response."""
    try:
        logger.debug("Received /chat request")
        messages = [{"role": msg.role, "content": msg.content} for msg in input.messages]
        response_content = get_chat_response(messages, request.app.state.groq_client)
        logger.debug(f"Chat response generated: {response_content}")
        return {
            "role": "assistant",
            "content": response_content,
            "timestamp": get_current_timestamp()
        }
    except ValueError as ve:
        logger.error(f"Invalid input in /chat: {str(ve)}")
        raise HTTPException(status_code=400, detail=f"Invalid input: {str(ve)}")
    except HTTPException as he:
        logger.error(f"HTTPException in /chat: {str(he)}")
        raise he
    except Exception as e:
        logger.error(f"Error in /chat: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail="Failed to process chat request")

@router.post("/voice_chat")
@limiter.limit("2/30seconds")
async def voice_chat(request: Request, history: str = Form(...), file: UploadFile = File(...)):
    """Handle voice input from an uploaded audio file and return AI response."""
    try:
        logger.debug("Received /voice_chat request")
        if not file.filename:
            logger.error("No file provided in the request")
            raise HTTPException(status_code=400, detail="No file provided")
        
        if not file.filename.endswith('.m4a'):
            logger.error(f"Unsupported file type: {file.filename}")
            raise HTTPException(status_code=400, detail="Only .m4a files are supported")

        audio_bytes = await file.read()
        if not audio_bytes:
            logger.error("Empty audio file provided")
            raise HTTPException(status_code=400, detail="Empty audio file provided")
        
        logger.debug(f"Audio file received, size: {len(audio_bytes)} bytes")
        user_text = voice_to_text(audio_bytes)
        logger.debug(f"Transcribed text: {user_text}")
        
        messages = json.loads(history)
        if not isinstance(messages, list):
            raise ValueError("History must be a list of messages")
        for msg in messages:
            if not isinstance(msg, dict) or "role" not in msg or "content" not in msg:
                raise ValueError("Each message must have 'role' and 'content'")
        messages.append({"role": "user", "content": user_text})
        
        response_content = get_chat_response(messages, request.app.state.groq_client)
        logger.debug(f"Voice chat response generated: {response_content}")
        return {
            "role": "assistant",
            "content": response_content,
            "transcribed_text": user_text,
            "timestamp": get_current_timestamp()
        }
    except ValueError as ve:
        logger.error(f"Invalid input in /voice_chat: {str(ve)}")
        raise HTTPException(status_code=400, detail=f"Invalid input: {str(ve)}")
    except HTTPException as he:
        logger.error(f"HTTPException in /voice_chat: {str(he)}")
        raise he
    except Exception as e:
        logger.error(f"Error in /voice_chat: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail="Failed to process voice request")

@router.post("/end")
async def end_conversation():
    """End the conversation."""
    try:
        logger.debug("Received /end request")
        return {
            "role": "system",
            "content": "Thank you for practicing! Start a new session anytime.",
            "timestamp": get_current_timestamp()
        }
    except Exception as e:
        logger.error(f"Error in /end: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to end conversation")

@router.get("/")
@router.get("/health")
async def health_check():
    """Health check endpoint."""
    try:
        logger.debug("Received /health request")
        return {
            "status": "ok",
            "timestamp": get_current_timestamp(),
            "service": "English Companion API",
            "version": "1.0.0"
        }
    except Exception as e:
        logger.error(f"Error in /health: {str(e)}")
        raise HTTPException(status_code=500, detail="Health check failed")