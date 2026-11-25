#!/bin/sh
# CodexNet supplies exec, model, effort, output schema and stdin. Keep service
# instructions out of argv and turn off workstation configuration and agent tools.
set -eu
cd "$SELLEVATE_WORKDIR"
exec "$SELLEVATE_CODEX" "$@" --ephemeral --ignore-user-config --ignore-rules \
    --disable shell_tool --disable unified_exec --disable multi_agent --disable multi_agent_v2 \
    --disable apps --disable plugins --disable js_repl --enable skip_host_skill_discovery \
    -c 'default_permissions="prompt"' -c 'permissions.prompt.filesystem={":root"="deny"}' \
    -c 'permissions.prompt.network.enabled=false' -c 'shell_environment_policy.inherit="none"' \
    -c 'project_doc_max_bytes=0' -c 'model_instructions_file="instructions.txt"'
