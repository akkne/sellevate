# HTTP Sellevate.Ai

| Метод | Маршрут | Доступ и политики |
| --- | --- | --- |
| GET | `/admin/ai-quota` | RequirePlatformAdmin, Контекст организации |
| PUT | `/admin/ai-quota` | RequirePlatformAdmin, Контекст организации |
| GET | `/admin/ai-quota/{organizationId}` | RequirePlatformAdmin, Контекст организации |
| GET | `/admin/ai-usage` | RequireOrgAdmin, Контекст организации |
| GET | `/admin/dialog-sessions` | RequireOrgAdmin, Контекст организации |
| GET | `/admin/dialog-sessions/{sessionId}` | RequireOrgAdmin, Контекст организации |
| GET | `/admin/dialog/bundles` | RequirePlatformAdmin |
| POST | `/admin/dialog/bundles` | RequirePlatformAdmin |
| DELETE | `/admin/dialog/bundles/{bundleId}` | RequirePlatformAdmin |
| GET | `/admin/dialog/bundles/{bundleId}` | RequirePlatformAdmin |
| PUT | `/admin/dialog/bundles/{bundleId}` | RequirePlatformAdmin |
| GET | `/admin/dialog/bundles/{bundleId}/modes` | RequirePlatformAdmin |
| POST | `/admin/dialog/bundles/{bundleId}/modes` | RequirePlatformAdmin |
| GET | `/admin/dialog/export` | RequirePlatformAdmin |
| POST | `/admin/dialog/import` | RequirePlatformAdmin |
| DELETE | `/admin/dialog/modes/{modeId}` | RequirePlatformAdmin |
| GET | `/admin/dialog/modes/{modeId}` | RequirePlatformAdmin |
| PUT | `/admin/dialog/modes/{modeId}` | RequirePlatformAdmin |
| GET | `/admin/dialog/overrides/modes` | RequireOrgAdmin |
| POST | `/admin/dialog/overrides/modes/{baseModeId}` | RequireOrgAdmin |
| GET | `/admin/dialog/overrides/modes/{overrideId}` | RequireOrgAdmin |
| PUT | `/admin/dialog/overrides/modes/{overrideId}` | RequireOrgAdmin |
| POST | `/admin/dialog/overrides/modes/{overrideId}/accept-base` | RequireOrgAdmin |
| POST | `/admin/dialog/overrides/modes/{overrideId}/keep-override` | RequireOrgAdmin |
| GET | `/admin/voice/usage` | RequirePlatformAdmin |
| POST | `/ai/chat` | Межсервисный ключ |
| POST | `/ai/chat/stream` | Межсервисный ключ |
| POST | `/ai/companies/briefing` | Межсервисный ключ |
| POST | `/ai/companies/parse-log` | Межсервисный ключ |
| POST | `/ai/companies/persona` | Межсервисный ключ |
| POST | `/ai/companies/readiness` | Межсервисный ключ |
| POST | `/ai/content/generate` | Межсервисный ключ |
| POST | `/ai/content/review` | Межсервисный ключ |
| POST | `/ai/content/rewrite` | Межсервисный ключ |
| POST | `/ai/content/structure` | Межсервисный ключ |
| POST | `/ai/evaluate` | Межсервисный ключ |
| GET | `/ai/quota/preflight` | Межсервисный ключ |
| POST | `/ai/tts` | Межсервисный ключ |
| GET | `/dialog/bundles` | JWT, Контекст организации |
| GET | `/dialog/bundles/{bundleId}/modes` | JWT, Контекст организации |
| GET | `/dialog/company-call-mode` | JWT, Контекст организации |
| GET | `/dialog/custom-scenario-mode` | JWT, Контекст организации |
| POST | `/dialog/scenario/validate` | JWT, Контекст организации |
| GET | `/dialog/sessions` | JWT, Контекст организации |
| POST | `/dialog/sessions` | JWT, Контекст организации |
| DELETE | `/dialog/sessions/{sessionId}` | JWT, Контекст организации |
| GET | `/dialog/sessions/{sessionId}` | JWT, Контекст организации |
| POST | `/dialog/sessions/{sessionId}/complete` | JWT, Контекст организации |
| POST | `/dialog/sessions/{sessionId}/messages` | JWT, Контекст организации |
| POST | `/dialog/sessions/{sessionId}/voice/stream` | JWT |
| GET | `/dialog/voice/config` | JWT |
| GET | `/dialog/voice/usage` | JWT |
| POST | `/transcription/transcribe` | JWT |
