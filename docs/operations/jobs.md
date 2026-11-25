# Фоновые задачи

Потребитель события восстанавливает контекст по конверту. Задача одной организации получает отдельный scope. Системное перечисление через outbox и проходы по срокам требуют прав, которые учитывают при включении RLS. Очереди генерации и адаптации используют сохранённые этапы выполнения, чтобы переживать перезапуск. При смене роли PostgreSQL проверьте обработку заданий для двух организаций.

| Сервис | Реализация фонового обработчика |
| --- | --- |
| `ai-service` | [UpstreamConnectionWarmupService](../../backend/ai-service/Ai/Infrastructure/Http/UpstreamConnectionWarmupService.cs) |
| `analytics-service` | [PresenceGaugeUpdaterService](../../backend/analytics-service/Analytics/Features/Presence/Services/Implementation/PresenceGaugeUpdaterService.cs) |
| `company-service` | [FollowUpReminderBackgroundService](../../backend/company-service/Company/Features/Companies/FollowUpReminders/FollowUpReminderBackgroundService.cs) |
| `identity-service` | [ExpiredEmailVerificationCleanupService](../../backend/identity-service/Identity/Features/Auth/ExpiredEmailVerificationCleanupService.cs) |
| `identity-service` | [ExpiredRefreshTokenCleanupService](../../backend/identity-service/Identity/Features/Auth/ExpiredRefreshTokenCleanupService.cs) |
| `learning-service` | [AssignmentDeadlineSweepService](../../backend/learning-service/Learning/Features/Assignments/AssignmentDeadlineSweepService.cs) |
| `learning-service` | [AssignmentRepeatSweepService](../../backend/learning-service/Learning/Features/Assignments/AssignmentRepeatSweepService.cs) |
| `learning-service` | [ContentAdaptationSweepService](../../backend/learning-service/Learning/Features/ContentAdaptation/ContentAdaptationSweepService.cs) |
| `learning-service` | [ContentGenerationSweepService](../../backend/learning-service/Learning/Features/ContentGeneration/ContentGenerationSweepService.cs) |
| `notification-service` | [DelayedChatEmailDispatcherService](../../backend/notification-service/Notification/Features/Notifications/Emails/Delayed/DelayedChatEmailDispatcherService.cs) |

Порядок выдачи прав и проверка зависших задач приведены в [процедуре раскатки](../../infra/tenancy/README.md).
