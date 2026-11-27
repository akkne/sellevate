#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
binary=${LLAMA_SERVER_BIN:-.local-run/voice-lab/bin/llama-b12816/llama-server}
weights=${LOCAL_VOICE_WEIGHTS:-.local-run/voice-lab/qwen.gguf}
exec "$binary" --model "$weights" --alias qwen3-4b-instruct-2507 \
  --host 127.0.0.1 --port 15142 --parallel 1 --ctx-size 16384 \
  --no-webui --cors-origins http://host.docker.internal:15142 --reasoning off
