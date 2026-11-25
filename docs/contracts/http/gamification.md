# HTTP Sellevate.Gamification

| Метод | Маршрут | Доступ и политики |
| --- | --- | --- |
| GET | `/admin/gamification/exercise-rewards` | RequirePlatformAdmin, Контекст организации |
| PUT | `/admin/gamification/exercise-rewards/{exerciseType}` | RequirePlatformAdmin, Контекст организации |
| GET | `/admin/gamification/settings` | RequirePlatformAdmin, Контекст организации |
| PUT | `/admin/gamification/settings` | RequirePlatformAdmin, Контекст организации |
| GET | `/admin/gamification/streak-milestones` | RequirePlatformAdmin, Контекст организации |
| POST | `/admin/gamification/streak-milestones` | RequirePlatformAdmin, Контекст организации |
| DELETE | `/admin/gamification/streak-milestones/{id}` | RequirePlatformAdmin, Контекст организации |
| PUT | `/admin/gamification/streak-milestones/{id}` | RequirePlatformAdmin, Контекст организации |
| GET | `/admin/leagues` | RequirePlatformAdmin, Контекст организации |
| POST | `/admin/leagues/close-current` | RequirePlatformAdmin, Контекст организации |
| DELETE | `/admin/leagues/memberships/{membershipId}` | RequirePlatformAdmin, Контекст организации |
| PUT | `/admin/leagues/memberships/{membershipId}/tier` | RequirePlatformAdmin, Контекст организации |
| PUT | `/admin/leagues/memberships/{membershipId}/xp` | RequirePlatformAdmin, Контекст организации |
| GET | `/admin/leagues/settings` | RequirePlatformAdmin, Контекст организации |
| PUT | `/admin/leagues/settings` | RequirePlatformAdmin, Контекст организации |
| GET | `/admin/leagues/tiers` | RequirePlatformAdmin, Контекст организации |
| POST | `/admin/leagues/tiers` | RequirePlatformAdmin, Контекст организации |
| DELETE | `/admin/leagues/tiers/{id}` | RequirePlatformAdmin, Контекст организации |
| PUT | `/admin/leagues/tiers/{id}` | RequirePlatformAdmin, Контекст организации |
| GET | `/admin/leagues/weeks` | RequirePlatformAdmin, Контекст организации |
| GET | `/admin/leagues/{id}` | RequirePlatformAdmin, Контекст организации |
| POST | `/admin/leagues/{id}/resync` | RequirePlatformAdmin, Контекст организации |
| GET | `/gamification/progress` | JWT, Контекст организации |
| GET | `/league` | JWT, Контекст организации |
| GET | `/profile/achievements` | JWT, Контекст организации |
