"""RadarScholar FastAPI Application Entry Point.

Creates and configures the FastAPI application with:
- CORS middleware for Flutter web development
- API routers
- Health endpoint
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.health import router as health_router
from app.core.config import settings
from app.users.router import router as users_router


def create_app() -> FastAPI:
    """Create and configure the FastAPI application."""
    application = FastAPI(
        title=settings.APP_NAME,
        version=settings.APP_VERSION,
        description="RadarScholar — Scholarship Intelligence Platform API",
    )

    # CORS middleware for Flutter Web development.
    # In production, origins should be restricted.
    application.add_middleware(
        CORSMiddleware,
        allow_origins=settings.CORS_ORIGINS,
        allow_origin_regex=r"http://(localhost|127\.0\.0\.1):\d+",
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # Register routers
    application.include_router(health_router, tags=["Health"])
    application.include_router(users_router)

    from app.scholarships.router import router as scholarships_router
    from app.applications.router import router as applications_router
    application.include_router(scholarships_router, prefix="/api/v1")
    application.include_router(applications_router, prefix="/api/v1")

    return application


app = create_app()
