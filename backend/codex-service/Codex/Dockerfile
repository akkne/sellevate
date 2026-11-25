ARG SDK_IMAGE=mcr.microsoft.com/dotnet/sdk:9.0
FROM node:22-bookworm-slim AS cli
RUN npm install --global @openai/codex@0.172.0 && \
    find /usr/local/lib/node_modules/@openai/codex -type f -name codex -exec cp {} /usr/local/bin/codex-native \; && \
    /usr/local/bin/codex-native --version

FROM ${SDK_IMAGE} AS build
WORKDIR /src
COPY Sellevate.Codex.csproj .
RUN dotnet restore
COPY . .
RUN dotnet publish -c Release --no-restore -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app
ENV CODEX_HOME=/home/app/.codex
RUN install -d -m 0700 -o app -g app "$CODEX_HOME"
COPY --from=cli /usr/local/bin/codex-native /usr/local/bin/codex
COPY --from=build /app/publish .
USER $APP_UID
ENTRYPOINT ["dotnet", "Sellevate.Codex.dll"]
