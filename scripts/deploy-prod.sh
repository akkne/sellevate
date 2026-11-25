#!/usr/bin/env bash
# Production deploy on the server: pull latest code, rebuild, restart, then
# reclaim disk by removing ONLY safe leftovers (old image layers + build cache).
#
# It NEVER touches volumes, so databases / MinIO / Let's Encrypt certs are safe.
#
# Usage (on the server, from the repo root):
#   ./scripts/deploy-prod.sh
set -euo pipefail

cd "$(dirname "$0")/.."

COMPOSE="docker compose -f compose.yaml -f docker-compose.prod.yml"

echo "==> Pulling latest code"
if [[ "${1:-}" == "--checked-revision" ]]; then
  test "$(git rev-parse HEAD)" = "${2:?missing commit}"
else
  git pull --ff-only
fi

echo "==> Building & starting (zero-ish downtime: only changed services restart)"
$COMPOSE up --build -d --wait

echo "==> Reclaiming disk: dangling images"
docker image prune -f

echo "==> Reclaiming disk: build cache older than 72h"
docker builder prune -f --filter 'until=72h'

echo "==> Current Docker disk usage:"
docker system df

echo "==> Done."
