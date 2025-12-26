#!/bin/sh

# Ce script permet d'injecter l'URL de l'API Backend dans le code frontend au moment du démarrage du conteneur.
# Il récupère l'URL dans la variable VITE_API_URL et l'insère dans un fichier config.js.
# config.js est servi au client par Nginx via index.html.
# En exécutant config.js, le client configure dynamiquement l'URL de l'API.
# Enfin, le script termine en lançant Nginx.

cat <<EOF > /usr/share/nginx/html/config.js
window.APP_CONFIG = {
  API_URL: "${VITE_API_URL}"
};
EOF

echo "Runtime config generated:"
cat /usr/share/nginx/html/config.js

exec "$@"
