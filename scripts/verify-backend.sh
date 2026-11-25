#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
dotnet tool restore
dotnet build backend/Sellevate.sln --configuration Release
dotnet format backend/Sellevate.sln --no-restore --verify-no-changes
for rule in codestyle architecture ai-provider tenancy-boundary tenancy-pool; do
  python3 "scripts/${rule}-lint.py" backend
done
for project in tests/backend/*/*.csproj; do
  dotnet test "$project" --configuration Release --no-build "$@"
done
for project in backend/*-service/*/*.csproj; do
  if [[ -d "$(dirname "$project")/Infrastructure/Data/Migrations" ]]; then
    dotnet ef migrations has-pending-model-changes --project "$project" --configuration Release --no-build
  fi
done
