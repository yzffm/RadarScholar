"""Authentication dependencies for FastAPI.

Provides `get_current_user` dependency that verifies Supabase JWT
tokens and returns the authenticated user identity.

Security rules (agents.md §12):
- Never trust client-provided user IDs for ownership.
- Identity is derived from verified JWT context only.
- No secrets are exposed in error messages.
"""

import httpx
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
import logging

from app.auth.models import AuthUser
from app.core.config import settings

_bearer_scheme = HTTPBearer(auto_error=False)
logger = logging.getLogger(__name__)

async def get_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(_bearer_scheme),
) -> AuthUser:
    """Verify Supabase JWT and return authenticated user.

    Raises:
        HTTPException 401: If token is missing, invalid, or expired.
    """
    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Autentikasi diperlukan. Silakan login terlebih dahulu.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    token = credentials.credentials

    if not settings.SUPABASE_URL or not settings.SUPABASE_ANON_KEY:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Layanan autentikasi belum dikonfigurasi.",
        )

    # Use Supabase /auth/v1/user endpoint to verify token
    # This securely handles asymmetric ES256/RS256 tokens used by newer Supabase projects
    headers = {
        "apikey": settings.SUPABASE_ANON_KEY,
        "Authorization": f"Bearer {token}",
    }
    
    try:
        async with httpx.AsyncClient(timeout=5.0) as client:
            response = await client.get(
                f"{settings.SUPABASE_URL}/auth/v1/user",
                headers=headers
            )
            if response.status_code != 200:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Token tidak valid atau sesi telah berakhir. Silakan login kembali.",
                    headers={"WWW-Authenticate": "Bearer"},
                )
            
            user_data = response.json()
            user_id = user_data.get("id")
            email = user_data.get("email", "")

            if not user_id:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Token tidak mengandung identitas pengguna.",
                    headers={"WWW-Authenticate": "Bearer"},
                )

            return AuthUser(id=user_id, email=email)
    except httpx.RequestError as e:
        logger.error(f"Error connecting to Supabase Auth: {e}")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Gagal menghubungi layanan autentikasi.",
        )
