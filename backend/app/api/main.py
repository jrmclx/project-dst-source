from fastapi import APIRouter

from app.api.routes import items, login, private, users, utils, oauth
from app.core.config import settings
import os, logging

api_router = APIRouter()
api_router.include_router(login.router)
api_router.include_router(users.router)
api_router.include_router(utils.router)
api_router.include_router(items.router)

if settings.ENVIRONMENT == "local":
    api_router.include_router(private.router)


# -- masquer le endpoint oauth fictif si les variables sont manquantes --
def is_set(value: str | None) -> bool:
    return value is not None and value.strip() != ""


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

expected_id = os.getenv("OAUTH_CLIENT_ID")
expected_secret = os.getenv("OAUTH_CLIENT_SECRET")

if is_set(expected_id) and is_set(expected_secret):
    api_router.include_router(oauth.router)
else:
    logger.info("OAuth client_credentials Test Endpoint is disabled (missing env vars)")
