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
    cors_origins = settings.CORS_ORIGINS
    if not settings.DEBUG:
        cors_origins = [
            origin
            for origin in cors_origins
            if not origin.startswith(("http://localhost", "http://127.0.0.1"))
        ]

    application = FastAPI(
        title=settings.APP_NAME,
        version=settings.APP_VERSION,
        description="RadarScholar — Scholarship Intelligence Platform API",
    )

    # Development localhost regex is intentionally disabled in production.
    application.add_middleware(
        CORSMiddleware,
        allow_origins=cors_origins,
        allow_origin_regex=(
            r"http://(localhost|127\.0\.0\.1):\d+" if settings.DEBUG else None
        ),
        allow_credentials=True,
        allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
        allow_headers=["Authorization", "Content-Type", "Accept"],
    )

    # Register routers
    application.include_router(health_router, tags=["Health"])
    application.include_router(users_router)

    from app.admin.router import router as admin_router
    from app.ai.router import applications_router as ai_applications_router
    from app.ai.router import router as ai_router
    from app.applications.router import router as applications_router
    from app.scholarships.router import router as scholarships_router

    application.include_router(scholarships_router, prefix="/api/v1")
    application.include_router(applications_router, prefix="/api/v1")
    application.include_router(ai_router, prefix="/api/v1")
    application.include_router(ai_applications_router, prefix="/api/v1")
    application.include_router(admin_router)

    return application


app = create_app()
