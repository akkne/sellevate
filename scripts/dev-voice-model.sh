#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
binary=${LLAMA_SERVER_BIN:-.local-run/voice-lab/bin/llama-b12816/llama-server}
model=${LOCAL_VOICE_LLM_MODEL:-}
if [[ -z "$model" && -f .env ]]; then
  model=$(sed -n 's/^LOCAL_VOICE_LLM_MODEL=//p' .env | tail -n 1)
fi
model=${model:-qwen3-4b-instruct-2507}
options=(--reasoning off)
case "$model" in
  qwen3-4b-instruct-2507) default_weights=.local-run/voice-lab/qwen.gguf ;;
  qwen3.5-9b)
    default_weights=.local-run/voice-lab/qwen3.5-9b.gguf
    options+=(--chat-template-kwargs '{"enable_thinking":false}' --cache-ram 256 --ubatch-size 128)
    ;;
  *) default_weights=${LOCAL_VOICE_WEIGHTS:?Set LOCAL_VOICE_WEIGHTS for this model} ;;
esac
weights=${LOCAL_VOICE_WEIGHTS:-$default_weights}
[[ -r "$weights" ]] || { echo "Missing voice model weights: $weights" >&2; exit 1; }
# Fill the shared instruction prefix once while the model starts. No session or microphone data is used.
(
  for ((attempt=0; attempt<100; attempt++)); do
    if curl -fsS --max-time 1 http://127.0.0.1:15142/health >/dev/null 2>&1; then
      jq -n --arg model "$model" --rawfile rules backend/ai-service/Ai/Features/Dialog/Helpers/local-voice-rules.txt \
        '{model:$model, messages:[{role:"system",content:($rules|rtrimstr("\n"))},{role:"user",content:"Здравствуйте"}],max_tokens:1}' \
        | curl -fsS --max-time 8 -H 'Content-Type: application/json' --data-binary @- \
          http://127.0.0.1:15142/v1/chat/completions >/dev/null
      exit
    fi
    sleep 0.25
  done
) &
exec "$binary" --model "$weights" --alias "$model" \
  --host 127.0.0.1 --port 15142 --parallel 1 --ctx-size 16384 \
  --no-webui --cors-origins http://host.docker.internal:15142 "${options[@]}"
