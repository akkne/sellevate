#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib-local-env.sh"
load_root_env
export ASPNETCORE_URLS="http://127.0.0.1:${LOCAL_CODEX_PORT:-5010}"
export InternalAuth__ServiceSecret="${INTERNAL_SERVICE_SECRET:?Set INTERNAL_SERVICE_SECRET in .env}"
export Codex__ReasoningEffort="${CODEX_REASONING_EFFORT:-high}"
export Codex__TimeoutSeconds="${CODEX_TIMEOUT_SECONDS:-180}"
export Codex__Executable="${CODEX_EXECUTABLE:-codex}"
exec "$DOTNET_BIN" run --project "$REPO_ROOT/backend/codex-service/Codex" --no-launch-profile "$@"
