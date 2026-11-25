# Контракт API

Клиент работает через шлюз. В локальном профиле базовый адрес — `http://localhost:5001`. В production внешний адрес задают `DOMAIN` и настройка клиента. Маршруты сохраняют исходные имена. Клиент передаёт короткоживущий access token через `Authorization: Bearer`; identity обновляет сессию по refresh cookie. Браузер отправляет cookie на разрешённый origin.

## Реализованные маршруты

Таблицы получены из атрибутов контроллеров девяти сервисов. OpenAPI содержит параметры, объявленные модели запросов и ответов. Для методов с нетипизированным `IActionResult` уточняйте вариант ответа по реализации и тесту. Пометка «По конфигурации сервиса» означает, что атрибут метода не задаёт явную политику. Внутренние маршруты вызываются между сервисами. Публичную доступность определяет [таблица шлюза](../backend/gateway/Gateway/appsettings.json).

| Владелец | Маршруты и доступ | Тела и параметры |
| --- | --- | --- |
| Диалоги, оценка, квоты и голос | [ai](contracts/http/ai.md) | [OpenAPI](contracts/http/ai.json) |
| События и метрики | [analytics](contracts/http/analytics.md) | [OpenAPI](contracts/http/analytics.json) |
| Компании и контакты | [company](contracts/http/company.md) | [OpenAPI](contracts/http/company.json) |
| Достижения и баллы | [gamification](contracts/http/gamification.md) | [OpenAPI](contracts/http/gamification.json) |
| Вход, профиль, роли и приглашения | [identity](contracts/http/identity.md) | [OpenAPI](contracts/http/identity.json) |
| Уроки, программы и назначения | [learning](contracts/http/learning.md) | [OpenAPI](contracts/http/learning.json) |
| Уведомления | [notification](contracts/http/notification.md) | [OpenAPI](contracts/http/notification.json) |
| Организации и заявки на демо | [organization](contracts/http/organization.md) | [OpenAPI](contracts/http/organization.json) |
| Сообщения, друзья и обсуждения | [social](contracts/http/social.md) | [OpenAPI](contracts/http/social.json) |

## Примеры и ошибки

`POST /auth/login` принимает JSON с полями `email` и `password`. Успешный ответ содержит `accessToken`, идентификатор пользователя и сведения о членстве. Ошибка авторизации на самом входе остаётся ошибкой формы. Для защищённого запроса с истёкшим токеном клиент один раз обновляет сессию.

`GET /skills/{slug}/lessons` возвращает 404 для неизвестного навыка и пустой массив для существующего без уроков. Попытка упражнения принимается на сервере, правильный ответ передаётся после отправки. Пропуск записывает попытку с нулём без обращения к модели.

Ошибки валидации, авторизации и отказ внешнего провайдера имеют разные HTTP-коды. Параметры страниц и фильтров зависят от операции. Повторяемость фоновых назначений обеспечивают ключи данных и состояние сценария. Список операций, несовместимых с повторной оплатой, и правила повторов описаны в [материалах](product/generation.md).

После изменения DTO или маршрута запустите [обновление схем](../scripts/refresh-contracts.sh). CI сверяет результат побайтно.
