# Запуск и выкладка

## Локальный Compose

Из корня скопируйте [.env.example](../.env.example) в `.env` и задайте свои значения. [Основной Compose](../compose.yaml) включает приложения, PostgreSQL, MongoDB, Redis, Kafka, MinIO и мониторинг. [Локальное наложение](../docker-compose.local.yml) публикует шлюз на порту 5001 и встраивает локальный адрес API в клиентскую сборку. `scripts/docker-local-up.sh` собирает сервисы последовательно. Откройте [интерфейс](http://localhost:3000) и [шлюз](http://localhost:5001/healthz).

В режиме разработки `scripts/dev-infra.sh` запускает хранилища, `scripts/dev-frontend.sh` — Next.js, `scripts/dev-gateway.sh` и `scripts/dev-<сервис>.sh` запускают процессы .NET. Установите SDK .NET 9 и Node.js 22, выполните `npm ci` в клиенте. Переменные и порты определяет [общий скрипт окружения](../scripts/lib-local-env.sh). Локальное демонаполнение выполняется `python3 scripts/seed-demo-data.py`. Обновляя рабочий экземпляр, сначала посмотрите `docker compose ps --status running`, пересоберите затронутые сервисы, проверьте `/healthz`, `/readyz` и изменённый сценарий. Для остановленного экземпляра выкладка пропускается.

## Авторизация Codex

В режиме `OPENAI_PROVIDER=OPENAI_CODEX` контейнер `codex` использует собственную учётную запись. Задайте `INTERNAL_SERVICE_SECRET` в `.env`. Для входа по подписке выполните команду в каталоге проекта и завершите вход в браузере под аккаунтом с доступом к выбранной модели.

```sh
docker compose run --rm --build --entrypoint codex codex login --device-auth
```

Compose сохраняет авторизацию в томе `codex_home`. Для входа по ключу заполните `CODEX_API_KEY` в `.env`. При запуске на хосте установите Codex CLI 0.172.0, выполните `codex login`, запустите [воркер](../scripts/dev-codex.sh) и [AI-сервис](../scripts/dev-ai.sh) в отдельных терминалах. По умолчанию воркер слушает `127.0.0.1:5010`.

`CODEX_MODEL`, `CODEX_REASONING_EFFORT`, `CODEX_TIMEOUT_SECONDS` и `CODEX_EXECUTABLE` управляют запуском. Чтобы использовать HTTP, укажите `OPENAI_PROVIDER=OpenAi` или `F5Ai`, заполните прежние `OPENAI_API_KEY`, `OPENAI_BASE_URL` и параметры моделей. Пересоздайте сервисы после изменения окружения. Для существующей установки Codex включается после изменения явно заданного `OPENAI_PROVIDER`. [Пример окружения](../.env.example).

## Сервер

Для сервера используются `compose.yaml` и `docker-compose.prod.yml`. Traefik выпускает TLS для настроенного домена. DNS и порты 80/443 должны вести на сервер. Секреты, резервные копии PostgreSQL, MongoDB, MinIO и файлы сертификатов хранятся на стороне установки. При переходе со старой структуры Git сначала перенесите незакоммиченные изменения и согласуйте локальную базовую ревизию с переписанной `origin/main`.

Выкладка из Actions включается переменной репозитория `DEPLOY_PRODUCTION=true`. В окружении `production` нужны `DEPLOY_HOST`, `DEPLOY_USER`, `DEPLOY_KEY`, `DEPLOY_KNOWN_HOSTS`. Последнее значение содержит заранее сверенный открытый ключ SSH-сервера. Репозиторий должен быть в `~/sellevate` на ветке main, пользователь должен иметь доступ к Git и Docker. После успешного verify задача проверяет актуальность SHA, обновляет сервер только fast-forward и вызывает [скрипт выкладки](../scripts/deploy-prod.sh). На чистой установке сначала подготовьте `.env`, роли, базы и тома. [Порядок миграции организаций](tenancy/README.md).

## Наблюдаемость

[Prometheus](prometheus) собирает метрики, [Grafana](grafana) загружает панели и источники, [Loki](loki) принимает журналы. Для диагностики сверьте статус контейнеров, готовность шлюза, зависимые хранилища и ошибки конкретного сервиса. Helm-профиль и его доступные values описаны в [инструкции Kubernetes](helm/README.md).
