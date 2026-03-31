import time
import logging
from starlette.middleware.base import BaseHTTPMiddleware
from fastapi import Request

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("SystemMesh")

class EnterpriseLoggingMiddleware(BaseHTTPMiddleware):
    """
    Enterprise-grade middleware for system diagnostics, 
    latency tracking, and high-fidelity request logging.
    """
    async def dispatch(self, request: Request, call_next):
        start_time = time.time()
        
        # Request Diagnostics
        logger.info(f"[DIAG] Request: {request.method} {request.url.path}")
        
        response = await call_next(request)
        
        process_time = (time.time() - start_time) * 1000
        logger.info(f"[DIAG] Latency: {process_time:.2f}ms | Status: {response.status_code}")
        
        # Add latency header for client-side monitoring
        response.headers["X-Process-Time"] = str(process_time)
        return response
