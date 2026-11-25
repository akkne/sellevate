# HTTP Sellevate.Organization

| Метод | Маршрут | Доступ и политики |
| --- | --- | --- |
| GET | `/admin/demo-requests` | RequirePlatformAdmin |
| POST | `/admin/demo-requests/{id}/provision` | RequirePlatformAdmin, RequireSuperAdmin |
| PATCH | `/admin/demo-requests/{id}/status` | RequirePlatformAdmin |
| POST | `/demo-requests` | Публичный |
| GET | `/organizations` | RequirePlatformAdmin |
| POST | `/organizations` | RequirePlatformAdmin |
| GET | `/organizations/profile` | JWT, Контекст организации |
| PATCH | `/organizations/profile` | JWT, RequireOrgAdmin, Контекст организации |
| PUT | `/organizations/profile` | JWT, RequireOrgAdmin, Контекст организации |
| POST | `/organizations/profile/draft` | JWT, Контекст организации |
| POST | `/organizations/profile/draft/apply` | JWT, RequireOrgAdmin, Контекст организации |
| GET | `/organizations/profile/gaps` | JWT, Контекст организации |
| GET | `/organizations/{id}` | RequirePlatformAdmin |
| PUT | `/organizations/{id}` | RequirePlatformAdmin |
| POST | `/organizations/{id}/reactivate` | RequirePlatformAdmin |
| POST | `/organizations/{id}/suspend` | RequirePlatformAdmin |
