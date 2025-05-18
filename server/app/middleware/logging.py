from fastapi import Request
import logging
from datetime import datetime

logger = logging.getLogger(__name__)

async def log_requests(request: Request, call_next):
    """Middleware to log incoming requests and responses."""
    try:
        safe_headers = {k: v for k, v in request.headers.items() if k.lower() not in ["authorization"]}
        logger.info(f"Incoming request: {request.method} {request.url}")
        logger.info(f"Headers: {safe_headers}")
        
        start_time = datetime.now()
        response = await call_next(request)
        
        process_time = (datetime.now() - start_time).total_seconds()
        logger.info(f"Processed request in {process_time:.2f}s - Status: {response.status_code}")
        
        return response
    except Exception as e:
        logger.error(f"Error in logging middleware: {str(e)}")
        raise