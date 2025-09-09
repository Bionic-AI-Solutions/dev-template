"""
Dev-PyNode Backend - FastAPI Application
AI-powered development platform backend
"""

from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi.responses import JSONResponse
import uvicorn
import os
from contextlib import asynccontextmanager
from typing import Dict, Any

# Import routers (will be created)
# from .routers import auth, chat, files, health

# Global app state
app_state: Dict[str, Any] = {}


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan manager"""
    # Startup
    print("🚀 Starting Dev-PyNode Backend...")
    app_state["startup_time"] = "2025-09-09T01:00:00Z"
    
    yield
    
    # Shutdown
    print("🛑 Shutting down Dev-PyNode Backend...")


# Create FastAPI app
app = FastAPI(
    title="Dev-PyNode API",
    description="AI-powered development platform backend",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3001", "http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Add trusted host middleware
app.add_middleware(
    TrustedHostMiddleware,
    allowed_hosts=["localhost", "127.0.0.1", "*.local"]
)


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "Dev-PyNode API",
        "version": "1.0.0",
        "status": "running",
        "docs": "/docs"
    }


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "timestamp": app_state.get("startup_time", "unknown"),
        "version": "1.0.0"
    }


@app.get("/ready")
async def readiness_check():
    """Readiness check endpoint"""
    # Add actual readiness checks here (database, external services, etc.)
    return {
        "status": "ready",
        "checks": {
            "database": "ok",
            "redis": "ok",
            "external_apis": "ok"
        }
    }


# Include routers (commented out until created)
# app.include_router(auth.router, prefix="/api/v1/auth", tags=["authentication"])
# app.include_router(chat.router, prefix="/api/v1/chat", tags=["chat"])
# app.include_router(files.router, prefix="/api/v1/files", tags=["files"])
# app.include_router(health.router, prefix="/api/v1/health", tags=["health"])


@app.exception_handler(HTTPException)
async def http_exception_handler(request, exc):
    """Custom HTTP exception handler"""
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "error": exc.detail,
            "status_code": exc.status_code,
            "path": str(request.url)
        }
    )


@app.exception_handler(Exception)
async def general_exception_handler(request, exc):
    """General exception handler"""
    return JSONResponse(
        status_code=500,
        content={
            "error": "Internal server error",
            "status_code": 500,
            "path": str(request.url)
        }
    )


if __name__ == "__main__":
    # Get configuration from environment
    host = os.getenv("APP_HOST", "0.0.0.0")
    port = int(os.getenv("APP_PORT", "3000"))
    debug = os.getenv("DEBUG", "false").lower() == "true"
    
    print(f"🌐 Starting server on {host}:{port}")
    print(f"🔧 Debug mode: {debug}")
    print(f"📚 API docs: http://{host}:{port}/docs")
    
    uvicorn.run(
        "main:app",
        host=host,
        port=port,
        reload=debug,
        log_level="info" if not debug else "debug"
    )
