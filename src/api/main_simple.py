from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from src.config import settings

# Create FastAPI application
app = FastAPI(
    title=settings.app_name,
    description="Elite conversational AI system for sales automation",
    version=settings.app_version,
    docs_url="/docs" if not settings.is_production else None,
    redoc_url="/redoc" if not settings.is_production else None,
)

# Configure CORS from settings
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins,
    allow_credentials=settings.allow_credentials,
    allow_methods=settings.allow_methods,
    allow_headers=settings.allow_headers,
    expose_headers=["X-Request-ID", "X-Rate-Limit-Limit", "X-Rate-Limit-Remaining", "X-Rate-Limit-Reset"]
)

# Health check endpoint
@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "service": settings.app_name,
        "version": settings.app_version,
        "environment": settings.environment.value
    }

# Root endpoint
@app.get("/")
async def root():
    return {
        "message": "Welcome to NGX Voice Sales Agent API",
        "version": settings.app_version,
        "docs": "/docs" if not settings.is_production else "Disabled in production"
    }