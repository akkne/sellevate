# Карта экранов

Маршруты построены по `app/**/page.tsx`. Квадратные скобки означают параметр пути. Область указывает владельца интерфейса. Авторизация операций дополнительно проверяется на сервере.

| Маршрут | Область | Реализация |
| --- | --- | --- |
| `/admin/[...legacyAdminPath]` | Платформа | [Страница](../frontend/app/%28admin%29/admin/%5B...legacyAdminPath%5D/page.tsx) |
| `/admin/bulk-lessons` | Платформа | [Страница](../frontend/app/%28admin%29/admin/bulk-lessons/page.tsx) |
| `/admin/demo-requests` | Платформа | [Страница](../frontend/app/%28admin%29/admin/demo-requests/page.tsx) |
| `/admin/dialog/[bundleId]` | Платформа | [Страница](../frontend/app/%28admin%29/admin/dialog/%5BbundleId%5D/page.tsx) |
| `/admin/dialog` | Платформа | [Страница](../frontend/app/%28admin%29/admin/dialog/page.tsx) |
| `/admin/discuss` | Платформа | [Страница](../frontend/app/%28admin%29/admin/discuss/page.tsx) |
| `/admin/gamification` | Платформа | [Страница](../frontend/app/%28admin%29/admin/gamification/page.tsx) |
| `/admin/import` | Платформа | [Страница](../frontend/app/%28admin%29/admin/import/page.tsx) |
| `/admin/leagues/[id]` | Платформа | [Страница](../frontend/app/%28admin%29/admin/leagues/%5Bid%5D/page.tsx) |
| `/admin/leagues` | Платформа | [Страница](../frontend/app/%28admin%29/admin/leagues/page.tsx) |
| `/admin/leagues/tiers` | Платформа | [Страница](../frontend/app/%28admin%29/admin/leagues/tiers/page.tsx) |
| `/admin/lessons/[lessonId]/exercises` | Платформа | [Страница](../frontend/app/%28admin%29/admin/lessons/%5BlessonId%5D/exercises/page.tsx) |
| `/admin/lessons` | Платформа | [Страница](../frontend/app/%28admin%29/admin/lessons/page.tsx) |
| `/admin/organizations/[organizationId]/quota` | Платформа | [Страница](../frontend/app/%28admin%29/admin/organizations/%5BorganizationId%5D/quota/page.tsx) |
| `/admin/organizations` | Платформа | [Страница](../frontend/app/%28admin%29/admin/organizations/page.tsx) |
| `/admin` | Платформа | [Страница](../frontend/app/%28admin%29/admin/page.tsx) |
| `/admin/prompts` | Платформа | [Страница](../frontend/app/%28admin%29/admin/prompts/page.tsx) |
| `/admin/quotes` | Платформа | [Страница](../frontend/app/%28admin%29/admin/quotes/page.tsx) |
| `/admin/reference` | Платформа | [Страница](../frontend/app/%28admin%29/admin/reference/page.tsx) |
| `/admin/skill-stages` | Платформа | [Страница](../frontend/app/%28admin%29/admin/skill-stages/page.tsx) |
| `/admin/skills/[id]` | Платформа | [Страница](../frontend/app/%28admin%29/admin/skills/%5Bid%5D/page.tsx) |
| `/admin/skills/[id]/reference` | Платформа | [Страница](../frontend/app/%28admin%29/admin/skills/%5Bid%5D/reference/page.tsx) |
| `/admin/skills/[id]/topics/[topicId]/lessons/[lessonId]/exercises` | Платформа | [Страница](../frontend/app/%28admin%29/admin/skills/%5Bid%5D/topics/%5BtopicId%5D/lessons/%5BlessonId%5D/exercises/page.tsx) |
| `/admin/skills/[id]/topics/[topicId]` | Платформа | [Страница](../frontend/app/%28admin%29/admin/skills/%5Bid%5D/topics/%5BtopicId%5D/page.tsx) |
| `/admin/skills` | Платформа | [Страница](../frontend/app/%28admin%29/admin/skills/page.tsx) |
| `/admin/techniques` | Платформа | [Страница](../frontend/app/%28admin%29/admin/techniques/page.tsx) |
| `/admin/topics` | Платформа | [Страница](../frontend/app/%28admin%29/admin/topics/page.tsx) |
| `/admin/users` | Платформа | [Страница](../frontend/app/%28admin%29/admin/users/page.tsx) |
| `/admin/voice/usage` | Платформа | [Страница](../frontend/app/%28admin%29/admin/voice/usage/page.tsx) |
| `/invite/[token]` | Публичный вход | [Страница](../frontend/app/%28auth%29/invite/%5Btoken%5D/page.tsx) |
| `/login` | Публичный вход | [Страница](../frontend/app/%28auth%29/login/page.tsx) |
| `/onboarding` | Приложение | [Страница](../frontend/app/%28auth%29/onboarding/page.tsx) |
| `/register` | Публичный вход | [Страница](../frontend/app/%28auth%29/register/page.tsx) |
| `/verify-email` | Публичный вход | [Страница](../frontend/app/%28auth%29/verify-email/page.tsx) |
| `/companies/[id]` | Приложение | [Страница](../frontend/app/%28main%29/companies/%5Bid%5D/page.tsx) |
| `/companies` | Приложение | [Страница](../frontend/app/%28main%29/companies/page.tsx) |
| `/dialog/[bundleId]` | Приложение | [Страница](../frontend/app/%28main%29/dialog/%5BbundleId%5D/page.tsx) |
| `/dialog` | Приложение | [Страница](../frontend/app/%28main%29/dialog/page.tsx) |
| `/dialog-reviews` | Приложение | [Страница](../frontend/app/%28main%29/dialog-reviews/page.tsx) |
| `/discuss/[threadId]` | Приложение | [Страница](../frontend/app/%28main%29/discuss/%5BthreadId%5D/page.tsx) |
| `/discuss` | Приложение | [Страница](../frontend/app/%28main%29/discuss/page.tsx) |
| `/friends/[userId]` | Приложение | [Страница](../frontend/app/%28main%29/friends/%5BuserId%5D/page.tsx) |
| `/friends/chat/[conversationId]` | Приложение | [Страница](../frontend/app/%28main%29/friends/chat/%5BconversationId%5D/page.tsx) |
| `/friends` | Приложение | [Страница](../frontend/app/%28main%29/friends/page.tsx) |
| `/guidebook` | Приложение | [Страница](../frontend/app/%28main%29/guidebook/page.tsx) |
| `/profile` | Приложение | [Страница](../frontend/app/%28main%29/profile/page.tsx) |
| `/reference/[id]` | Приложение | [Страница](../frontend/app/%28main%29/reference/%5Bid%5D/page.tsx) |
| `/settings` | Приложение | [Страница](../frontend/app/%28main%29/settings/page.tsx) |
| `/skill/[id]/map` | Приложение | [Страница](../frontend/app/%28main%29/skill/%5Bid%5D/map/page.tsx) |
| `/skill/[id]` | Приложение | [Страница](../frontend/app/%28main%29/skill/%5Bid%5D/page.tsx) |
| `/tree` | Приложение | [Страница](../frontend/app/%28main%29/tree/page.tsx) |
| `/org/assignments/[assignmentId]` | Организация | [Страница](../frontend/app/%28org%29/org/assignments/%5BassignmentId%5D/page.tsx) |
| `/org/assignments/new` | Организация | [Страница](../frontend/app/%28org%29/org/assignments/new/page.tsx) |
| `/org/assignments` | Организация | [Страница](../frontend/app/%28org%29/org/assignments/page.tsx) |
| `/org/content/adaptations/[jobId]` | Организация | [Страница](../frontend/app/%28org%29/org/content/adaptations/%5BjobId%5D/page.tsx) |
| `/org/content/adaptations` | Организация | [Страница](../frontend/app/%28org%29/org/content/adaptations/page.tsx) |
| `/org/content/generation/[jobId]` | Организация | [Страница](../frontend/app/%28org%29/org/content/generation/%5BjobId%5D/page.tsx) |
| `/org/content/generation` | Организация | [Страница](../frontend/app/%28org%29/org/content/generation/page.tsx) |
| `/org/content/lessons/[lessonId]` | Организация | [Страница](../frontend/app/%28org%29/org/content/lessons/%5BlessonId%5D/page.tsx) |
| `/org/content/overrides/[kind]/[overrideId]` | Организация | [Страница](../frontend/app/%28org%29/org/content/overrides/%5Bkind%5D/%5BoverrideId%5D/page.tsx) |
| `/org/content/overrides` | Организация | [Страница](../frontend/app/%28org%29/org/content/overrides/page.tsx) |
| `/org/content` | Организация | [Страница](../frontend/app/%28org%29/org/content/page.tsx) |
| `/org/dialogs/[sessionId]` | Организация | [Страница](../frontend/app/%28org%29/org/dialogs/%5BsessionId%5D/page.tsx) |
| `/org/dialogs` | Организация | [Страница](../frontend/app/%28org%29/org/dialogs/page.tsx) |
| `/org` | Организация | [Страница](../frontend/app/%28org%29/org/page.tsx) |
| `/org/people` | Организация | [Страница](../frontend/app/%28org%29/org/people/page.tsx) |
| `/org/profile` | Организация | [Страница](../frontend/app/%28org%29/org/profile/page.tsx) |
| `/org/program` | Организация | [Страница](../frontend/app/%28org%29/org/program/page.tsx) |
| `/org/reviews` | Организация | [Страница](../frontend/app/%28org%29/org/reviews/page.tsx) |
| `/org/usage` | Организация | [Страница](../frontend/app/%28org%29/org/usage/page.tsx) |
| `/companies/[id]/call/chat` | Приложение | [Страница](../frontend/app/companies/%5Bid%5D/call/chat/page.tsx) |
| `/companies/[id]/call/voice` | Приложение | [Страница](../frontend/app/companies/%5Bid%5D/call/voice/page.tsx) |
| `/demo` | Публичный вход | [Страница](../frontend/app/demo/page.tsx) |
| `/dialog/[bundleId]/[modeId]` | Приложение | [Страница](../frontend/app/dialog/%5BbundleId%5D/%5BmodeId%5D/page.tsx) |
| `/dialog/[bundleId]/[modeId]/voice` | Приложение | [Страница](../frontend/app/dialog/%5BbundleId%5D/%5BmodeId%5D/voice/page.tsx) |
| `/landing` | Публичный вход | [Страница](../frontend/app/landing/page.tsx) |
| `/` | Публичный вход | [Страница](../frontend/app/page.tsx) |
| `/session/[lessonId]` | Приложение | [Страница](../frontend/app/session/%5BlessonId%5D/page.tsx) |

Основные действия, ограничения ролей и ожидаемые состояния описаны в [сценариях](features-description.md) и [приёмке](testing/README.md).
