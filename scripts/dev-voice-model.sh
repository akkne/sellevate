#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
binary=${LLAMA_SERVER_BIN:-.local-run/voice-lab/bin/llama-b12816/llama-server}
weights=${LOCAL_VOICE_WEIGHTS:-.local-run/voice-lab/qwen.gguf}
# Fill the shared instruction prefix once while the model starts. No session or microphone data is used.
(
  for ((attempt=0; attempt<100; attempt++)); do
    if curl -fsS --max-time 1 http://127.0.0.1:15142/health >/dev/null 2>&1; then
      jq -n --rawfile rules backend/ai-service/Ai/Features/Dialog/Helpers/local-voice-rules.txt \
        '{model:"qwen3-4b-instruct-2507", messages:[{role:"system",content:($rules|rtrimstr("\n"))},{role:"user",content:"Здравствуйте"}],max_tokens:1}' \
        | curl -fsS --max-time 8 -H 'Content-Type: application/json' --data-binary @- \
          http://127.0.0.1:15142/v1/chat/completions >/dev/null
      exit
    fi
    sleep 0.25
  done
) &
exec "$binary" --model "$weights" --alias qwen3-4b-instruct-2507 \
  --host 127.0.0.1 --port 15142 --parallel 1 --ctx-size 16384 \
  --no-webui --cors-origins http://host.docker.internal:15142 --reasoning off
