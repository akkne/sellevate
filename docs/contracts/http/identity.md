# HTTP Sellevate.Identity

| Метод | Маршрут | Доступ и политики |
| --- | --- | --- |
| GET | `/admin/platform/impersonation` | RequireSuperAdmin |
| POST | `/admin/platform/impersonation` | RequireSuperAdmin |
| POST | `/admin/platform/organizations/bootstrap-admin` | RequireSuperAdmin |
| GET | `/admin/users` | RequirePlatformAdmin |
| GET | `/admin/users/{id}` | RequirePlatformAdmin |
| PUT | `/admin/users/{id}` | RequirePlatformAdmin, RequireSuperAdmin |
| DELETE | `/admin/users/{id}/avatar` | RequirePlatformAdmin, RequireSuperAdmin |
| PUT | `/admin/users/{id}/role` | RequirePlatformAdmin, RequireSuperAdmin |
| POST | `/auth/google` | По конфигурации сервиса |
| POST | `/auth/invites/{token}/accept` | Публичный |
| GET | `/auth/invites/{token}/status` | Публичный |
| POST | `/auth/login` | По конфигурации сервиса |
| POST | `/auth/login/start` | По конфигурации сервиса |
| POST | `/auth/logout` | По конфигурации сервиса |
| GET | `/auth/me` | JWT |
| POST | `/auth/refresh` | По конфигурации сервиса |
| POST | `/auth/register` | Публичный |
| POST | `/auth/resend-code` | По конфигурации сервиса |
| POST | `/auth/verify-email` | По конфигурации сервиса |
| DELETE | `/avatars` | JWT |
| POST | `/avatars` | JWT |
| GET | `/avatars/{userId}` | Публичный |
| POST | `/demo/token` | По конфигурации сервиса |
| GET | `/internal/memberships/active` | Контекст организации, Межсервисный ключ |
| POST | `/internal/organizations/{organizationId}/bootstrap-admin` | Межсервисный ключ |
| GET | `/invites` | RequireOrgAdmin, Контекст организации |
| POST | `/invites` | RequireOrgAdmin, RequireOrgSuperAdmin, Контекст организации |
| DELETE | `/invites/{inviteId}` | RequireOrgAdmin, RequireOrgSuperAdmin, Контекст организации |
| GET | `/memberships` | RequireOrgAdmin, Контекст организации |
| DELETE | `/memberships/{userId}` | RequireOrgAdmin, RequireOrgSuperAdmin, Контекст организации |
| POST | `/onboarding` | JWT |
| GET | `/profile` | JWT |
| PUT | `/profile` | JWT |
| PUT | `/profile/persona` | JWT |
