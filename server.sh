#!/usr/bin/env bash

# the server for this goofy project
# listening using lighthttpd
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME_CONF="${PROJECT_ROOT}/.lighttpd.runtime.conf"

# Generate a runtime config by replacing the __PROJECT_ROOT__ placeholder
# with the actual project directory. This makes lighttpd.conf portable
# across machines without hardcoding any paths.
sed "s|__PROJECT_ROOT__|${PROJECT_ROOT}|g" "${PROJECT_ROOT}/lighttpd.conf" > "$RUNTIME_CONF"

# Clean up the generated config on exit
trap 'rm -f "$RUNTIME_CONF"' EXIT

LOCAL_IP=$(hostname -I 2>/dev/null | awk '{print $1}')

echo "Starting server on 0.0.0.0:8080..."
echo ""
echo "  → http://localhost:8080"
echo "  → http://127.0.0.1:8080"
[ -n "$LOCAL_IP" ] && echo "  → http://${LOCAL_IP}:8080"
echo ""

lighttpd -D -f "$RUNTIME_CONF"