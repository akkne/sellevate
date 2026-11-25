# Git и проверка изменений

Перед работой выполните `git status --short --branch`, `git diff` и `git diff --cached`. Создайте ветку от актуальной `main`. Добавляйте файлы явно и просматривайте полный индекс. Перед коммитом выполните `git diff --cached --check`.

Используйте настроенные в Git имя и почту. Сообщение состоит из одной строки Conventional Commits до 100 знаков. Например, `fix(learning): preserve lesson progress`. Содержательные пояснения к изменению помещайте в PR или решение. Подписи инструментов и строки соавторства исключены.

## Локальная проверка

```sh
scripts/verify-backend.sh
(cd frontend && npm ci && npm run lint && npx tsc --noEmit && npm test && npm run build)
python3 scripts/verify-docs.py
docker compose --env-file .env.example config --quiet
```

Для интеграционных тестов нужны отдельные PostgreSQL, MongoDB и Redis. Порты и параметры приведены в [руководстве тестирования](../testing/README.md). Для быстрого модульного запуска передайте `--filter 'TestCategory!=Integration'` в серверный скрипт. После изменения API или схемы выполните `scripts/refresh-contracts.sh` и проверьте разницу.

## GitHub

Откройте PR в `main`. [Verify](../../.github/workflows/verify.yml) проверяет клиент, сервер и репозиторий. При обновлении ветки PR GitHub отменяет проверку предыдущей ревизии. Итоговая задача `verify` требует успеха всех трёх. Для защиты основной ветки администратор включает обязательный PR, актуальную ветку, проверку `verify`, ноль обязательных одобрений, merge-коммиты и Allow auto-merge. [Автослияние](../../.github/workflows/auto-merge.yml) предназначено для готового PR из этого репозитория и сверяет SHA проверенной версии. Черновики и PR из форков проходят обычное ревью.

После слияния обновите `main` командой `git pull --ff-only`. Обновление уже работающего локального экземпляра и условия серверной выкладки описаны в [эксплуатации](../../infra/README.md).
