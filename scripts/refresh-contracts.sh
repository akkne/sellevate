#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
dotnet tool restore
output="${1:-$PWD/docs/contracts}"
mkdir -p "$output/http" "$output/database"
dotnet run --project scripts/contracts -c Release -- "$output/http"
for project in backend/*-service/*/*.csproj; do
  directory=$(dirname "$project")
  if [[ -d "$directory/Infrastructure/Data/Migrations" ]]; then
    service=$(basename "$(dirname "$directory")" -service)
    schema="$output/database/$service.sql"
    dotnet ef dbcontext script --project "$project" --configuration Release --no-build --output "$schema"
    python3 -c 'from pathlib import Path; import sys; p = Path(sys.argv[1]); p.write_bytes(p.read_bytes().rstrip() + b"\n")' "$schema"
  fi
done
