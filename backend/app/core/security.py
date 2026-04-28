from datetime import datetime, timedelta, timezone
from typing import Any
import jwt
from passlib.context import CryptContext
from app.core.config import settings

from fastapi.openapi.models import OAuthFlows, OAuthFlowClientCredentials
from fastapi.security import OAuth2
from fastapi import HTTPException, Request, Form
from fastapi.security.utils import get_authorization_scheme_param
from typing import Optional
from starlette.status import HTTP_401_UNAUTHORIZED


pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


ALGORITHM = "HS256"


def create_access_token(subject: str | Any, expires_delta: timedelta) -> str:
    expire = datetime.now(timezone.utc) + expires_delta
    to_encode = {"exp": expire, "sub": str(subject)}
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)


# Added to support client_credentials
class Oauth2ClientCredentials(OAuth2):
    def __init__(
        self,
        token_url: str,
        scheme_name: str = None,
        scopes: dict = None,
        auto_error: bool = True,
    ):
        if not scopes:
            scopes = {}

        flows = OAuthFlows(
            clientCredentials=OAuthFlowClientCredentials(
                tokenUrl=token_url,
                scopes=scopes
            )
        )

        super().__init__(flows=flows, scheme_name=scheme_name, auto_error=auto_error)

    async def __call__(self, request: Request) -> Optional[str]:
        authorization: str = request.headers.get("Authorization")
        scheme, param = get_authorization_scheme_param(authorization)

        if not authorization or scheme.lower() != "bearer":
            if self.auto_error:
                raise HTTPException(
                    status_code=HTTP_401_UNAUTHORIZED,
                    detail="Not authenticated",
                    headers={"WWW-Authenticate": "Bearer"},
                )
            return None

        return param

# Added to support client_credentials
class OAuth2ClientCredentialsRequestForm:
    def __init__(
        self,
        grant_type: str = Form(default="client_credentials", regex="client_credentials"),
        scope: str = Form(default=""),
        client_id: Optional[str] = Form(None),
        client_secret: Optional[str] = Form(None),
    ):
        self.grant_type = grant_type
        self.scopes = scope.split()
        self.client_id = client_id
        self.client_secret = client_secret
