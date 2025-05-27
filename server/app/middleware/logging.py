from fastapi import Request
import logging
from datetime import datetime
import json

logger = logging.getLogger(__name__)

async def log_requests(request: Request, call_next):
    """Middleware to log incoming requests and responses in JSON format."""
    try:
        start_time = datetime.now()
        response = await call_next(request)
        process_time = (datetime.now() - start_time).total_seconds()
        log_data = {
            "method": request.method,
            "url": str(request.url),
            "status_code": response.status_code,
            "process_time": process_time
        }
        logger.info(json.dumps(log_data))
        return response
    except Exception as e:
        logger.error(f"Error in logging middleware: {str(e)}")
        raise