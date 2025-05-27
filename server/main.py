from fastapi import FastAPI
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import uvicorn
from app.routes.api import router as api_router
from app.middleware.cors import add_cors_middleware
from app.middleware.logging import log_requests
from app.core.config import load_environment
from app.services.groq_service import initialize_groq_client
import logging
from app.core.limiter import limiter
from slowapi.errors import RateLimitExceeded
from slowapi import _rate_limit_exceeded_handler
from zeroconf import ServiceInfo, Zeroconf
import socket
import atexit
import os

# Configure logging
log_level = os.getenv("LOG_LEVEL", "INFO").upper()
logging.basicConfig(level=log_level)
logger = logging.getLogger(__name__)
logger.setLevel(log_level)

app = FastAPI(
    title="English Learning Companion API",
    description="API for the English Learning Companion application",
    version="1.0.0",
    docs_url="/api/docs",
    redoc_url="/api/redoc",
    openapi_url="/api/openapi.json"
)

# Add rate limit exception handler
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# mDNS service setup
zeroconf = None
service_info = None

def setup_mdns():
    global zeroconf, service_info
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        local_ip = s.getsockname()[0]
        s.close()

        service_type = "_englishcompanion._tcp.local."
        service_name = "EnglishCompanion._englishcompanion._tcp.local."
        service_info = ServiceInfo(
            type_=service_type,
            name=service_name,
            addresses=[socket.inet_aton(local_ip)],
            port=8000,
            properties={},
        )

        zeroconf = Zeroconf()
        zeroconf.register_service(service_info)
        logger.info(f"mDNS service registered: {service_name} at {local_ip}:8000")
    except Exception as e:
        logger.error(f"Failed to setup mDNS: {str(e)}")

def shutdown_mdns():
    global zeroconf, service_info
    if zeroconf and service_info:
        try:
            zeroconf.unregister_service(service_info)
            zeroconf.close()
            logger.info("mDNS service unregistered and closed")
        except Exception as e:
            logger.error(f"Failed to shutdown mDNS: {str(e)}")

atexit.register(shutdown_mdns)

@app.get("/")
async def root():
    return {
        "message": "Welcome to English Learning Companion API",
        "documentation": "/api/docs",
        "health_check": "/api/health"
    }

add_cors_middleware(app)
app.middleware("http")(log_requests)
app.include_router(api_router, prefix="/api")

try:
    api_key = load_environment()
    app.state.groq_client = initialize_groq_client(api_key)
    logger.info("Groq client initialized successfully")
    if os.getenv("ENV") == "development":
        setup_mdns()
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