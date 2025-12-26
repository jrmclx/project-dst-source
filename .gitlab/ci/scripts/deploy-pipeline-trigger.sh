#!/bin/sh

set -eu

ENV_FILE="$HOME/.gitlab-trigger.env"


# ---------------------------------------------------------------------------
# Chargement du fichier d'environnement s'il existe
# ---------------------------------------------------------------------------

if [ -f "$ENV_FILE" ]; then
    # shellcheck disable=SC1090
    . "$ENV_FILE"
fi

# ---------------------------------------------------------------------------
# Fonctions
# ---------------------------------------------------------------------------

require_secret() {
    VAR_NAME="$1"
    PROMPT="$2"

    VAR_VALUE="$(eval "printf '%s' \"\${$VAR_NAME-}\"")"

    if [ -z "$VAR_VALUE" ]; then
        printf "%s: " "$PROMPT"
        read VAR_VALUE

        if [ -z "$VAR_VALUE" ]; then
            echo "Erreur: $VAR_NAME ne peut pas etre vide."
            exit 1
        fi
    fi

    eval "export $VAR_NAME=\"\$VAR_VALUE\""
}

confirm_or_update() {
    VAR_NAME="$1"
    PROMPT="$2"

    CURRENT_VALUE="$(eval "printf '%s' \"\${$VAR_NAME-}\"")"

    if [ -n "$CURRENT_VALUE" ]; then
        printf "%s [%s]: " "$PROMPT" "$CURRENT_VALUE"
        read NEW_VALUE

        if [ -z "$NEW_VALUE" ]; then
            VAR_VALUE="$CURRENT_VALUE"
        else
            VAR_VALUE="$NEW_VALUE"
        fi
    else
        printf "%s: " "$PROMPT"
        read VAR_VALUE

        if [ -z "$VAR_VALUE" ]; then
            echo "Erreur: $VAR_NAME ne peut pas etre vide."
            exit 1
        fi
    fi

    eval "export $VAR_NAME=\"\$VAR_VALUE\""
}

persist_env() {
    cat > "$ENV_FILE" <<EOF
GITLAB_TRIGGER_TOKEN=$GITLAB_TRIGGER_TOKEN
GITLAB_ACCESS_TOKEN=$GITLAB_ACCESS_TOKEN
UPDATED_IMAGENAME=$UPDATED_IMAGENAME
UPDATED_TAG=$UPDATED_TAG
PROJECT_ID=$PROJECT_ID
REF=$REF
EOF

    chmod 600 "$ENV_FILE"
}

# ---------------------------------------------------------------------------
# Variables requises
# ---------------------------------------------------------------------------

# Tokens : jamais redemandés si existants
require_secret GITLAB_TRIGGER_TOKEN "Saisir le GitLab trigger token"
require_secret GITLAB_ACCESS_TOKEN  "Saisir le GitLab access token"

# Variables métier : confirmation interactive
confirm_or_update UPDATED_IMAGENAME "Nom de l image a mettre a jour"
confirm_or_update UPDATED_TAG       "Tag de l image a mettre a jour"
confirm_or_update PROJECT_ID        "ID du projet GitLab a mettre a jour"
confirm_or_update REF               "Branche de travail"


# Sauvegarde finale
persist_env


# ---------------------------------------------------------------------------
# Trigger pipeline GitLab
# ---------------------------------------------------------------------------

RESPONSE="$(curl -s -X POST \
     --fail \
     --form "token=$GITLAB_TRIGGER_TOKEN" \
     --form "ref=$REF" \
     --form "variables[UPDATED_IMAGENAME]=$UPDATED_IMAGENAME" \
     --form "variables[UPDATED_TAG]=$UPDATED_TAG" \
     --url "https://gitlab.com/api/v4/projects/$PROJECT_ID/trigger/pipeline")"

PIPELINE_ID="$(printf '%s' "$RESPONSE" | jq -r '.id')"
REF_VALUE="$(printf '%s' "$RESPONSE" | jq -r '.ref')"
STATUS="$(printf '%s' "$RESPONSE" | jq -r '.status')"
SOURCE="$(printf '%s' "$RESPONSE" | jq -r '.source')"
WEB_URL="$(printf '%s' "$RESPONSE" | jq -r '.web_url')"
USERNAME="$(printf '%s' "$RESPONSE" | jq -r '.user.username')"

printf "\nPipeline declenche avec succes:\n"
printf -- "-------------------------------\n"
printf "  Pipeline   : %s\n" "$PIPELINE_ID"
printf "  ├─ Status  : %s\n" "$STATUS"
printf "  ├─ Source  : %s\n" "$SOURCE"
printf "  ├─ Web URL : %s\n" "$WEB_URL"
printf "  ├─ User    : %s\n" "$USERNAME"
printf "  └─ Ref     : %s\n" "$REF_VALUE"

# ---------------------------------------------------------------------------
# Consultation pipeline
# ---------------------------------------------------------------------------
# sleep 1 # attendre 1s avant de lire l'API

RESPONSE="$(curl -s \
  --header "PRIVATE-TOKEN: $GITLAB_ACCESS_TOKEN" \
  --url "https://gitlab.com/api/v4/projects/$PROJECT_ID/pipelines/$PIPELINE_ID/variables")"

printf "\nVariables transmises au pipeline:\n"
printf -- "-------------------------------\n"
printf '%s' "$RESPONSE" | jq -r '.[] | select(.variable_type == "env_var") | "  \(.key) = \(.value)"'
printf -- "-------------------------------\n"