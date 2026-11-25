# Технологии

| Область | Реализация | Источник версий |
| --- | --- | --- |
| Клиент | Next.js 16, React 19, TypeScript, Tailwind CSS 4, TanStack Query, Zustand | [Зависимости](../frontend/package.json), [точные версии](../frontend/package-lock.json) |
| Сервер | C# и ASP.NET Core 9, шлюз YARP, внедрение зависимостей ASP.NET | [Решение](../backend/Sellevate.sln) |
| Реляционные данные | PostgreSQL 17, EF Core 9, Npgsql, миграции на сервис | [Схема](database-schema.md) |
| Другие хранилища | MongoDB, Redis, MinIO/S3 | [Compose](../compose.yaml) |
| События и наблюдаемость | Kafka, Prometheus, Grafana, Loki | [Инфраструктура](../infra/README.md) |
| Проверки | ESLint, TypeScript, Vitest, NUnit, FluentAssertions, dotnet format, Python 3.9+ | [Проверки](git/README.md) |
| Доставка | Docker, Compose, GitHub Actions, опциональные Helm-релизы | [Выкладка](../infra/README.md) |
