from fastapi import HTTPException

from app.core.config import Settings, settings
from app.main import create_app


def test_debug_is_disabled_by_default():
    assert Settings.model_fields["DEBUG"].default is False


def test_production_cors_does_not_allow_localhost_regex(monkeypatch):
    monkeypatch.setattr(settings, "DEBUG", False)
    monkeypatch.setattr(
        settings,
        "CORS_ORIGINS",
        ["https://app.example.com", "http://localhost:3000"],
    )

    application = create_app()
    cors = next(
        middleware
        for middleware in application.user_middleware
        if middleware.cls.__name__ == "CORSMiddleware"
    )

    assert cors.kwargs["allow_origins"] == ["https://app.example.com"]
    assert cors.kwargs["allow_origin_regex"] is None
    assert cors.kwargs["allow_methods"] == [
        "GET",
        "POST",
        "PUT",
        "PATCH",
        "DELETE",
        "OPTIONS",
    ]


def test_ai_rate_limiter_rejects_requests_over_quota(monkeypatch):
    from app.ai.rate_limit import AIRateLimiter

    limiter = AIRateLimiter()
    monkeypatch.setattr(settings, "AI_RATE_LIMIT_REQUESTS", 2)
    monkeypatch.setattr(settings, "AI_RATE_LIMIT_WINDOW_SECONDS", 60)

    assert limiter.check("user-1") == 1
    assert limiter.check("user-1") == 0

    try:
        limiter.check("user-1")
    except HTTPException as error:
        assert error.status_code == 429
        assert error.headers["Retry-After"]
    else:
        raise AssertionError("Expected AI rate limiter to reject the third request")

    # Quotas are isolated by verified user ID.
    assert limiter.check("user-2") == 1
