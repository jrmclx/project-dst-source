#!/bin/sh

# Create runtime config
cat <<EOF > /usr/share/nginx/html/config.js
window.APP_CONFIG = {
  API_URL: "${VITE_API_URL}"
};
EOF

echo "Runtime config generated:"
cat /usr/share/nginx/html/config.js

exec "$@"
