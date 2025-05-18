from groq import Groq
import logging
from fastapi import HTTPException
from typing import List, Dict, Any

logger = logging.getLogger(__name__)

def initialize_groq_client(api_key: str) -> Groq:
    """Initialize and return a Groq client."""
    try:
        return Groq(api_key=api_key)
    except Exception as e:
        logger.error(f"Failed to initialize Groq client: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to initialize Groq client")

def get_chat_response(messages: List[Dict[str, Any]], client: Groq) -> str:
    """Get AI response using the provided messages and Groq client."""
    try:
        response = client.chat.completions.create(
            messages=[
                {
                    "role": "system",
                    "content": """
                    You are an English-speaking companion dedicated to helping improve English language skills for beginners. Your role is to enhance fluency, grammar, pronunciation, and confidence by:

                    1. **Feedback**: Analyze the user's input for grammatical errors, pronunciation challenges (assume written input reflects spoken English), fluency issues, vocabulary limitations, or confidence/pacing. Provide concise, constructive feedback.
                    2. **Conversation**: Engage in a friendly, beginner-friendly conversation on topics like hobbies or daily routines. Ask one open-ended question per response. Use simple language, offer gentle corrections, and maintain a supportive tone.

                    Be patient, positive, and avoid complex vocabulary. If the user struggles, suggest simpler responses or questions. Optionally, summarize key improvement areas at the end.
                    """
                },
                *messages
            ],
            model="llama-3.3-70b-versatile",
            temperature=0.7,
            max_tokens=500
        )
        return response.choices[0].message.content
    except Exception as e:
        logger.error(f"Error during chat completion: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Groq API error: {str(e)}")