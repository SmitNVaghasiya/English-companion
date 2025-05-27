from groq import Groq
import logging
from fastapi import HTTPException
from typing import List, Dict, Any
from tenacity import retry, stop_after_attempt, wait_exponential, retry_if_exception_type
import os

logger = logging.getLogger(__name__)

# Load configurable settings from environment variables
MODEL = os.getenv("GROQ_MODEL", "llama-3.3-70b-versatile")
TEMPERATURE = float(os.getenv("GROQ_TEMPERATURE", 0.6))
MAX_TOKENS = int(os.getenv("GROQ_MAX_TOKENS", 500))
SYSTEM_MESSAGE = os.getenv("SYSTEM_MESSAGE", """
You are an English-speaking companion dedicated to helping improve English language skills for beginners. Your role is to enhance fluency, grammar, pronunciation, and confidence by:

1. **Feedback**: Analyze the user's input for grammatical errors, pronunciation challenges (assume written input reflects spoken English), fluency issues, vocabulary limitations, or confidence/pacing. Provide concise, constructive feedback only when there are clear issues or when the input is substantial. For very short messages like greetings, respond naturally without feedback unless there are errors.
2. **Conversation**: Engage in a friendly, beginner-friendly conversation on topics like hobbies or daily routines. Ask one open-ended question per response. Use simple language, offer gentle corrections, and maintain a supportive tone.

Be patient, positive, and avoid complex vocabulary. If the user struggles, suggest simpler responses or questions. Optionally, summarize key improvement areas at the end.
""")

def initialize_groq_client(api_key: str) -> Groq:
    """Initialize and return a Groq client."""
    try:
        return Groq(api_key=api_key)
    except Exception as e:
        logger.error(f"Failed to initialize Groq client: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to initialize Groq client")

@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=1, max=10),
    retry=retry_if_exception_type(Exception),
    before_sleep=lambda retry_state: logger.info(
        f"Retrying Groq API call attempt {retry_state.attempt_number} after {retry_state.idle_for}s due to {retry_state.outcome.exception()}"
    )
)
def get_chat_response(messages: List[Dict[str, Any]], client: Groq) -> str:
    """Get AI response using the provided messages and Groq client."""
    try:
        response = client.chat.completions.create(
            messages=[{"role": "system", "content": SYSTEM_MESSAGE}, *messages],
            model=MODEL,
            temperature=TEMPERATURE,
            max_tokens=MAX_TOKENS
        )
        return response.choices[0].message.content
    except Exception as e:
        logger.error(f"Error during chat completion: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Groq API error: {str(e)}")