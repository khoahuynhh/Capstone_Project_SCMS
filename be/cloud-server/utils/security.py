"""
Authentication and Authorization utilities
API Key and JWT token validation
"""
from fastapi import Security, HTTPException, status, Depends, Request
from fastapi.security import APIKeyHeader, HTTPBearer, HTTPAuthorizationCredentials
from typing import Optional
from datetime import datetime, timedelta
import jwt
from config import get_settings

settings = get_settings()

# API Key scheme for edge devices
api_key_header = APIKeyHeader(name="X-API-Key", auto_error=False)

# JWT Bearer scheme for admin/staff
security_bearer = HTTPBearer(auto_error=False)


def verify_api_key(api_key: str = Security(api_key_header)) -> Optional[str]:
    """
    Verify API key for edge device authentication
    
    Returns:
        branch_id if valid, raises HTTPException if invalid
    """
    if not settings.API_KEY_ENABLED:
        return None  # API key check disabled
    
    if not api_key:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="API Key required"
        )
    
    # TODO: Validate against database of registered devices
    # For now, accept any non-empty key in development
    if settings.ENVIRONMENT == "development":
        return "dev_branch"
    
    # In production, check against admin API key or database
    if api_key == settings.ADMIN_API_KEY:
        return "admin"
    
    raise HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Invalid API Key"
    )


def create_jwt_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """
    Create JWT access token
    
    Args:
        data: Payload data (e.g., {"sub": "user_id", "role": "admin"})
        expires_delta: Optional expiration time
    
    Returns:
        Encoded JWT token string
    """
    to_encode = data.copy()
    
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=settings.JWT_EXPIRATION_MINUTES)
    
    to_encode.update({"exp": expire})
    
    encoded_jwt = jwt.encode(
        to_encode,
        settings.JWT_SECRET_KEY,
        algorithm=settings.JWT_ALGORITHM
    )
    
    return encoded_jwt


def verify_jwt_token(
    credentials: HTTPAuthorizationCredentials = Security(security_bearer)
) -> dict:
    """
    Verify JWT token
    
    Returns:
        Decoded token payload if valid
    """
    if not credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication required"
        )
    
    token = credentials.credentials
    
    try:
        payload = jwt.decode(
            token,
            settings.JWT_SECRET_KEY,
            algorithms=[settings.JWT_ALGORITHM]
        )
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has expired"
        )
    except jwt.JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token"
        )


def require_admin(token_data: dict = Depends(verify_jwt_token)) -> dict:
    """
    Require admin role
    
    Usage:
        @router.post("/admin-only")
        async def admin_endpoint(user: dict = Depends(require_admin)):
            ...
    """
    role = token_data.get("role")
    
    if role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin access required"
        )
    
    return token_data


# Rate limiting (simple in-memory implementation)
from collections import defaultdict
from time import time

# In-memory rate limit tracker
rate_limit_tracker = defaultdict(list)


async def rate_limit_check(request: Request, limit_per_minute: int = None):
    """
    Simple rate limiting middleware
    
    Args:
        request: FastAPI request object
        limit_per_minute: Requests allowed per minute (defaults to config)
    """
    if not settings.RATE_LIMIT_ENABLED:
        return
    
    client_ip = request.client.host
    current_time = time()
    limit = limit_per_minute or settings.RATE_LIMIT_PER_MINUTE
    
    # Clean old entries (older than 1 minute)
    rate_limit_tracker[client_ip] = [
        t for t in rate_limit_tracker[client_ip]
        if current_time - t < 60
    ]
    
    # Check rate limit
    if len(rate_limit_tracker[client_ip]) >= limit:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail=f"Rate limit exceeded. Max {limit} requests per minute."
        )
    
    # Record this request
    rate_limit_tracker[client_ip].append(current_time)


# Dependency for rate-limited endpoints
async def rate_limited(request: Request):
    """
    Apply rate limiting to endpoint
    
    Usage:
        @router.get("/endpoint", dependencies=[Depends(rate_limited)])
        async def my_endpoint():
            ...
    """
    await rate_limit_check(request)
