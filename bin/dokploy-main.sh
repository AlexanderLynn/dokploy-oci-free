#!/bin/bash
set -e

# Install Dokploy with retry (up to 3 minutes, every 15 seconds)
MAX_ATTEMPTS=12
ATTEMPT=1

until curl -sSL https://dokploy.com/install.sh | sh; do
  if [ "${ATTEMPT}" -ge "${MAX_ATTEMPTS}" ]; then
    echo "Dokploy install failed after ${MAX_ATTEMPTS} attempts."
    exit 1
  fi
  echo "Dokploy install attempt ${ATTEMPT}/${MAX_ATTEMPTS} failed. Retrying in 15 seconds..."
  ATTEMPT=$((ATTEMPT + 1))
  sleep 15
done
