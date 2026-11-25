# HTTP Sellevate.Notification

| Метод | Маршрут | Доступ и политики |
| --- | --- | --- |
| GET | `/notifications` | JWT, Контекст организации |
| GET | `/notifications/preferences` | JWT |
| PUT | `/notifications/preferences` | JWT |
| PUT | `/notifications/read-all` | JWT, Контекст организации |
| GET | `/notifications/unread-count` | JWT, Контекст организации |
| PUT | `/notifications/{notificationId}/read` | JWT, Контекст организации |
