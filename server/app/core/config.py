from dotenv import load_dotenv
import os
import logging
from fastapi import HTTPException

logger = logging.getLogger(__name__)

def load_environment() -> str:
    """Load environment variables and return the Groq API key."""
    try:
        load_dotenv(override=True)
        api_key = os.getenv("GROQ_API_KEY")
        if not api_key:
            raise ValueError("GROQ_API_KEY is missing from .env file")
        logger.info("Environment variables loaded successfully")
        return api_key
    except Exception as e:
        logger.error(f"Error loading environment: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to load environment variables")
