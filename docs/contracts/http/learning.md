# HTTP Sellevate.Learning

| Метод | Маршрут | Доступ и политики |
| --- | --- | --- |
| GET | `/admin/assignments` | RequireOrgAdmin, Контекст организации |
| POST | `/admin/assignments` | RequireOrgAdmin, Контекст организации |
| DELETE | `/admin/assignments/{assignmentId}` | RequireOrgAdmin, Контекст организации |
| GET | `/admin/assignments/{assignmentId}` | RequireOrgAdmin, Контекст организации |
| PUT | `/admin/assignments/{assignmentId}` | RequireOrgAdmin, Контекст организации |
| POST | `/admin/assignments/{assignmentId}/activate` | RequireOrgAdmin, Контекст организации |
| POST | `/admin/assignments/{assignmentId}/close` | RequireOrgAdmin, Контекст организации |
| GET | `/admin/assignments/{assignmentId}/dashboard` | RequireOrgAdmin, Контекст организации |
| GET | `/admin/assignments/{assignmentId}/progress` | RequireOrgAdmin, Контекст организации |
| POST | `/admin/assignments/{assignmentId}/remind` | RequireOrgAdmin, Контекст организации |
| GET | `/admin/content-generation` | RequireOrgAdmin, Контекст организации |
| POST | `/admin/content-generation` | RequireOrgAdmin, Контекст организации |
| GET | `/admin/content-generation/{jobId}` | RequireOrgAdmin, Контекст организации |
| POST | `/admin/content-generation/{jobId}/approve` | RequireOrgAdmin, Контекст организации |
| POST | `/admin/content-generation/{jobId}/material` | RequireOrgAdmin, Контекст организации |
| POST | `/admin/content-generation/{jobId}/retry` | RequireOrgAdmin, Контекст организации |
| PUT | `/admin/content-generation/{jobId}/structure` | RequireOrgAdmin, Контекст организации |
| GET | `/admin/content/adaptations` | RequireOrgAdmin, Контекст организации |
| POST | `/admin/content/adaptations` | RequireOrgAdmin, Контекст организации |
| GET | `/admin/content/adaptations/{jobId}` | RequireOrgAdmin, Контекст организации |
| GET | `/admin/content/adaptations/{jobId}/items/{itemId}` | RequireOrgAdmin, Контекст организации |
| POST | `/admin/content/adaptations/{jobId}/items/{itemId}/accept` | RequireOrgAdmin, Контекст организации |
| POST | `/admin/content/adaptations/{jobId}/items/{itemId}/reject` | RequireOrgAdmin, Контекст организации |
| POST | `/admin/content/adaptations/{jobId}/retry` | RequireOrgAdmin, Контекст организации |
| GET | `/admin/content/overrides` | RequireOrgAdmin, Контекст организации |
| POST | `/admin/content/overrides/{kind}/{baseId}` | RequireOrgAdmin, Контекст организации |
| GET | `/admin/content/overrides/{kind}/{overrideId}` | RequireOrgAdmin, Контекст организации |
| POST | `/admin/content/overrides/{kind}/{overrideId}/accept-base` | RequireOrgAdmin, Контекст организации |
| POST | `/admin/content/overrides/{kind}/{overrideId}/keep-override` | RequireOrgAdmin, Контекст организации |
| GET | `/admin/daily-quotes` | RequirePlatformAdmin |
| POST | `/admin/daily-quotes` | RequirePlatformAdmin |
| DELETE | `/admin/daily-quotes/{id}` | RequirePlatformAdmin |
| PUT | `/admin/daily-quotes/{id}` | RequirePlatformAdmin |
| GET | `/admin/dialog-reviews` | RequireOrgAdmin, Контекст организации |
| POST | `/admin/dialog-reviews` | RequireOrgAdmin, Контекст организации |
| POST | `/admin/dialog-reviews/{noteId}/resolve` | RequireOrgAdmin, Контекст организации |
| GET | `/admin/exercise-type-prompts` | RequirePlatformAdmin |
| GET | `/admin/exercise-type-prompts/{exerciseType}` | RequirePlatformAdmin |
| PUT | `/admin/exercise-type-prompts/{exerciseType}` | RequirePlatformAdmin |
| DELETE | `/admin/exercises/{id}` | RequireOrgAdmin, Контекст организации |
| PUT | `/admin/exercises/{id}` | RequireOrgAdmin, Контекст организации |
| GET | `/admin/lessons` | RequireOrgAdmin, Контекст организации |
| DELETE | `/admin/lessons/{id}` | RequireOrgAdmin, Контекст организации |
| PUT | `/admin/lessons/{id}` | RequireOrgAdmin, Контекст организации |
| GET | `/admin/lessons/{lessonId}/accuracy` | RequireOrgAdmin, Контекст организации |
| GET | `/admin/lessons/{lessonId}/exercises` | RequireOrgAdmin, Контекст организации |
| POST | `/admin/lessons/{lessonId}/exercises` | RequireOrgAdmin, Контекст организации |
| POST | `/admin/lessons/{lessonId}/exercises/import` | RequireOrgAdmin, Контекст организации |
| PUT | `/admin/lessons/{lessonId}/exercises/reorder` | RequireOrgAdmin, Контекст организации |
| GET | `/admin/lessons/{lessonId}/versions` | RequireOrgAdmin, Контекст организации |
| POST | `/admin/lessons/{lessonId}/versions/draft` | RequireOrgAdmin, Контекст организации |
| POST | `/admin/lessons/{lessonId}/versions/publish` | RequireOrgAdmin, Контекст организации |
| GET | `/admin/lessons/{lessonId}/versions/{versionId}` | RequireOrgAdmin, Контекст организации |
| GET | `/admin/program/enrollments` | RequireOrgAdmin, Контекст организации |
| POST | `/admin/program/enrollments` | RequireOrgAdmin, Контекст организации |
| GET | `/admin/program/versions` | RequireOrgAdmin, Контекст организации |
| POST | `/admin/program/versions/draft` | RequireOrgAdmin, Контекст организации |
| POST | `/admin/program/versions/publish` | RequireOrgAdmin, Контекст организации |
| GET | `/admin/program/versions/{programVersionId}` | RequireOrgAdmin, Контекст организации |
| GET | `/admin/program/versions/{programVersionId}/diff/{baselineProgramVersionId}` | RequireOrgAdmin, Контекст организации |
| GET | `/admin/reference` | RequireOrgAdmin, Контекст организации |
| GET | `/admin/reference/categories` | RequireOrgAdmin, Контекст организации |
| DELETE | `/admin/reference/{id}` | RequireOrgAdmin, Контекст организации |
| PUT | `/admin/reference/{id}` | RequireOrgAdmin, Контекст организации |
| POST | `/admin/seeder/bundle` | RequirePlatformAdmin |
| GET | `/admin/seeder/bundle/export` | RequirePlatformAdmin |
| POST | `/admin/seeder/lessons` | RequirePlatformAdmin |
| GET | `/admin/seeder/lessons/export` | RequirePlatformAdmin |
| POST | `/admin/seeder/skills` | RequirePlatformAdmin |
| GET | `/admin/seeder/skills/export` | RequirePlatformAdmin |
| POST | `/admin/seeder/topics` | RequirePlatformAdmin |
| GET | `/admin/seeder/topics/export` | RequirePlatformAdmin |
| GET | `/admin/skill-stages` | RequirePlatformAdmin |
| POST | `/admin/skill-stages` | RequirePlatformAdmin |
| DELETE | `/admin/skill-stages/{id}` | RequirePlatformAdmin |
| PUT | `/admin/skill-stages/{id}` | RequirePlatformAdmin |
| GET | `/admin/skills` | RequirePlatformAdmin |
| POST | `/admin/skills` | RequirePlatformAdmin |
| DELETE | `/admin/skills/{id}` | RequirePlatformAdmin |
| PUT | `/admin/skills/{id}` | RequirePlatformAdmin |
| GET | `/admin/skills/{skillIconicName}/topics` | RequirePlatformAdmin |
| POST | `/admin/skills/{skillIconicName}/topics` | RequirePlatformAdmin |
| PUT | `/admin/skills/{skillIconicName}/topics/{topicIconicName}` | RequirePlatformAdmin |
| GET | `/admin/skills/{skillId}/reference` | RequireOrgAdmin, Контекст организации |
| POST | `/admin/skills/{skillId}/reference` | RequireOrgAdmin, Контекст организации |
| GET | `/admin/team/skill-gaps` | RequireOrgAdmin, Контекст организации |
| POST | `/admin/team/skill-gaps/{stageKey}/content` | RequireOrgAdmin, Контекст организации |
| DELETE | `/admin/team/skill-gaps/{stageKey}/dismiss` | RequireOrgAdmin, Контекст организации |
| POST | `/admin/team/skill-gaps/{stageKey}/dismiss` | RequireOrgAdmin, Контекст организации |
| GET | `/admin/team/skill-map` | RequireOrgAdmin, Контекст организации |
| GET | `/admin/techniques` | RequireOrgAdmin, Контекст организации |
| POST | `/admin/techniques` | RequireOrgAdmin, Контекст организации |
| GET | `/admin/techniques/export` | RequireOrgAdmin, Контекст организации |
| POST | `/admin/techniques/import` | RequireOrgAdmin, Контекст организации |
| DELETE | `/admin/techniques/{id}` | RequireOrgAdmin, Контекст организации |
| GET | `/admin/techniques/{id}` | RequireOrgAdmin, Контекст организации |
| PUT | `/admin/techniques/{id}` | RequireOrgAdmin, Контекст организации |
| GET | `/admin/topics` | RequirePlatformAdmin |
| DELETE | `/admin/topics/{id}` | RequirePlatformAdmin |
| PUT | `/admin/topics/{id}` | RequirePlatformAdmin |
| GET | `/admin/topics/{topicIconicName}/lessons` | RequireOrgAdmin, Контекст организации |
| POST | `/admin/topics/{topicIconicName}/lessons` | RequireOrgAdmin, Контекст организации |
| GET | `/assignments/active` | JWT, Контекст организации |
| GET | `/daily-quote` | JWT, Контекст организации |
| GET | `/dialog-reviews` | JWT, Контекст организации |
| POST | `/dialog-reviews/disputes` | JWT, Контекст организации |
| POST | `/dialog-reviews/{noteId}/acknowledge` | JWT, Контекст организации |
| POST | `/exercises/{exerciseId}/chat` | JWT, Контекст организации |
| POST | `/exercises/{exerciseId}/submit` | JWT, Контекст организации |
| POST | `/exercises/{exerciseId}/voice/stream` | JWT, Контекст организации |
| GET | `/internal/assignments/practice-context` | Контекст организации, Межсервисный ключ |
| GET | `/internal/skills/lookup` | Межсервисный ключ |
| GET | `/lessons` | JWT, Контекст организации |
| GET | `/lessons/{lessonId}/exercises` | JWT, Контекст организации |
| GET | `/program` | JWT, Контекст организации |
| POST | `/program/switch` | JWT, Контекст организации |
| GET | `/reference` | JWT, Контекст организации |
| GET | `/reference/categories` | JWT, Контекст организации |
| GET | `/skill-tree` | JWT, Контекст организации |
| GET | `/skills` | JWT, Контекст организации |
| PUT | `/skills/enrolled` | JWT, Контекст организации |
| GET | `/skills/progress-summary` | JWT, Контекст организации |
| GET | `/skills/stages` | JWT, Контекст организации |
| GET | `/skills/{skillIdentifier}/reference` | JWT, Контекст организации |
| GET | `/skills/{skillId}/topics` | JWT, Контекст организации |
| GET | `/skills/{skillSlug}/lessons` | JWT, Контекст организации |
| GET | `/techniques` | JWT, Контекст организации |
| GET | `/techniques/meta` | JWT, Контекст организации |
| GET | `/techniques/{slug}` | JWT, Контекст организации |
| POST | `/techniques/{slug}/seen` | JWT, Контекст организации |
| GET | `/topics/{topicId}/lessons` | JWT, Контекст организации |
