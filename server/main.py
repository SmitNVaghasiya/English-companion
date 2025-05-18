from fastapi import FastAPI
import uvicorn
from app.routes.api import router as api_router
from app.middleware.cors import add_cors_middleware
from app.middleware.logging import log_requests
from app.core.config import load_environment
from app.services.groq_service import initialize_groq_client
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="English Learning Companion API")

# Add middleware
add_cors_middleware(app)
app.middleware("http")(log_requests)

# Include API routes
app.include_router(api_router)

# Initialize Groq client at startup
try:
    api_key = load_environment()
    app.state.groq_client = initialize_groq_client(api_key)
    logger.info("Groq client initialized successfully")
except Exception as e:
    logger.error(f"Failed to start application: {str(e)}")
    raise

if __name__ == "__main__":
    try:
        logger.info("Starting English Companion API...")
        uvicorn.run(
            "main:app",
            host="0.0.0.0",
            port=8000,
            reload=True,
            log_level="info"
        )
    except Exception as e:
        logger.error(f"Application startup failed: {str(e)}")
        raise