from fastapi import APIRouter, HTTPException
from datetime import timedelta
from app.models import Token
import os
from app.core.security import OAuth2ClientCredentialsRequestForm
from fastapi import Depends
from app.core import security

router = APIRouter(tags=["audit"])

#--------------------------------------------------------------------------------------------
# ajoute un endpoint conforme OAuth2 Client Credentials permettant de tester la récupération d'un Token par les scripts et applications de test
# -- IMPORTANT : le token délivré n'a aucune validité dans le système car n'est associé à aucun utilisateur
#
# le 'client_id' et 'le client_secret' sont définis à l'exécution par les variables d'environnement suivantes:
#  - OAUTH_CLIENT_ID
#  - OAUTH_CLIENT_SECRET
#--------------------------------------------------------------------------------------------


@router.post("/login/client-credentials")
def login_client_credentials(
    form_data: OAuth2ClientCredentialsRequestForm = Depends()
):
    """
    OAuth2 client credentials token retrieval test endpoint.
    """
    # 1. Vérification du grant
    if form_data.grant_type != "client_credentials":
        raise HTTPException(
            status_code=400,
            detail="unsupported_grant_type"
        )

    # 2. Vérification credentials (env)
    expected_id = os.getenv("OAUTH_CLIENT_ID")
    expected_secret = os.getenv("OAUTH_CLIENT_SECRET")

    if not expected_id or not expected_secret:
        raise HTTPException(
            status_code=500,
            detail="OAuth not configured"
        )

    if (
        form_data.client_id != expected_id
        or form_data.client_secret != expected_secret
    ):
        raise HTTPException(
            status_code=401,
            detail="invalid_client"
        )

    # 3. Génération token
    expires_minutes = int(os.getenv("OAUTH_TOKEN_EXPIRE_MINUTES", "5"))
    expires = timedelta(minutes=expires_minutes)

    access_token = security.create_access_token(
        subject=f"client:{form_data.client_id}",
        expires_delta=expires,
    )

    return Token(
        access_token=access_token,
        token_type="bearer",
        expires_in=int(expires.total_seconds())
    )