"""Small in-process rate limiter for authenticated AI requests."""

from collections import defaultdict, deque
from threading import Lock
from time import monotonic

from fastapi import Depends, HTTPException, status

from app.auth.dependencies import get_current_user
from app.auth.models import AuthUser
from app.core.config import settings


class AIRateLimiter:
    """Fixed-window limiter keyed by verified user identity.

    This is appropriate for the current single-process MVP. A shared store is
    required later if the API is deployed across multiple worker instances.
    """

    def __init__(self) -> None:
        self._requests: dict[str, deque[float]] = defaultdict(deque)
        self._lock = Lock()

    def check(self, user_id: str) -> int:
        now = monotonic()
        window = settings.AI_RATE_LIMIT_WINDOW_SECONDS
        limit = settings.AI_RATE_LIMIT_REQUESTS

        with self._lock:
            timestamps = self._requests[user_id]
            while timestamps and now - timestamps[0] >= window:
                timestamps.popleft()

            if len(timestamps) >= limit:
                retry_after = max(1, int(window - (now - timestamps[0])))
                raise HTTPException(
                    status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                    detail="Batas penggunaan AI tercapai. Silakan coba lagi nanti.",
                    headers={"Retry-After": str(retry_after)},
                )

            timestamps.append(now)
            return limit - len(timestamps)

    def reset(self) -> None:
        """Clear limiter state; intended for tests and controlled maintenance."""
        with self._lock:
            self._requests.clear()


ai_rate_limiter = AIRateLimiter()


def require_ai_rate_limit(user: AuthUser = Depends(get_current_user)) -> None:
    """Reject authenticated AI requests above the configured quota."""
    ai_rate_limiter.check(user.id)
