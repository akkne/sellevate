# MICROSERVICES.md — Service Architecture

Sellevate's backend is nine ASP.NET Core 9 services behind a single YARP API
gateway: one bounded context per service, one database per service, no shared
database and no cross-service foreign keys. Backend-to-backend communication is
async over Apache Kafka by default; the frontend only ever talks to the gateway
over REST. A shared `BuildingBlocks` library gives every service the same event
envelope, Kafka publisher/consumer base, outbox, tenancy middleware, and health
checks, so the services stay structurally consistent without a shared runtime.

Multi-tenancy: `Organization` is the tenant (see
[TENANCY/TENANCY.md](TENANCY/TENANCY.md)). `Company` is a per-tenant CRM entity
(a salesperson's prospect) owned by `company-service` — not to be confused with
`Organization`.

---

## 1. Service catalogue

| Service | Port (host:container) | Bounded context | Store |
|---|---|---|---|
| `gateway` | 5000:8080 | Single entry point: JWT validation, routing, identity-header forwarding | — |
| `identity-service` | 5002:8080 | Who the user is: auth, profile, onboarding, avatars. Sole JWT issuer | Postgres `identity` |
| `ai-service` | 5003:8080 | Everything that talks to an LLM/speech API: dialog roleplay, TTS, STT, AI grading | Postgres `ai` + Mongo `dialog_sessions`/`chat_messages` |
| `notification-service` | 5004:8080 | In-app notification inbox | Redis only |
| `analytics-service` | 5005:8080 | Product metrics, funnels, presence | Redis (`analytics-redis`) + Prometheus |
| `social-service` | 5006:8080 | User-to-user interaction: friends, Discuss forum, chat | Postgres `social` + Mongo `chat_conversations` |
| `gamification-service` | 5007:8080 | Progress points, activity streaks, achievements, leagues | Postgres `gamification` |
| `learning-service` | 5008:8080 | Content and the learner's progress through it: skills, lessons, exercises, assignments | Postgres `learning` |
| `company-service` | 5009:8080 | The salesperson's account book: companies, call log, practice calls, contacts | Postgres `company` |
| `organization-service` | 5010:8080 | The tenant registry: organizations, demo requests | Postgres `organization` |

All ports are bound to `127.0.0.1` only. Inside the Docker network every service
listens on `:8080` and is addressed by container name (`http://identity:8080`,
etc.); only the gateway is reachable from outside.

Shared infra: Postgres 17 (one instance, one logical database per relational
service — `Database=<service>` in each service's connection string), Mongo 8
(one instance, one logical database `sallevate` split by collection), Redis 7
(`redis` for identity/ai/notification/gamification/social/learning, a separate
`analytics-redis` instance for analytics), Kafka (single-broker KRaft) +
kafka-ui + kafka-exporter, MinIO (S3-compatible, for identity avatars and
social Discuss photos), Loki + Prometheus + Grafana for logs/metrics/dashboards.

### Repository layout

Each service is self-contained under `src/backend/`: `<service>/<Name>` (code)
+ `<service>/<Name>.Tests` (unit + integration tests for that service only).
Cross-service contract tests live in `building-blocks/BuildingBlocks.Tests`.

```
src/backend/
  building-blocks/         BuildingBlocks (shared lib) + BuildingBlocks.Tests
  gateway/                 Gateway + Gateway.Tests
  identity-service/        Identity + Identity.Tests
  ai-service/               Ai + Ai.Tests
  notification-service/    Notification + Notification.Tests
  analytics-service/       Analytics + Analytics.Tests
  social-service/          Social + Social.Tests
  gamification-service/    Gamification + Gamification.Tests
  learning-service/        Learning + Learning.Tests
  company-service/         Company + Company.Tests
  organization-service/    Organization + Organization.Tests
```

---

## 2. Services

### 2.1 Identity — `identity-service`
- **Owns (Postgres `identity`):** `Users`, `RefreshTokens`, `EmailVerificationCodes`,
  `UserProfiles`, `DefaultAvatars`, `Memberships`, `OrganizationAuthConfigurations`,
  `OrganizationReplicas`, `Invites`.
- **External:** Google OAuth, MailerSend (email), S3/MinIO (avatar blobs).
- **Frontend REST:** `/auth/*`, `/profile[/*]`, `/onboarding[/*]`, `/avatars[/*]`,
  `/invites[/*]`, `/memberships[/*]`, `/admin/platform/*`, `/admin/users[/*]`.
- **Role:** the only JWT issuer. Every other relational service keeps a local
  `UserReplica` read model instead of reading Identity's database directly.
- **Kafka produces:** `user.registered`, `user.updated`, `user.deleted`,
  `user.avatar.changed`.
- **Kafka consumes:** `organization.created`, `organization.updated`,
  `organization.suspended` (keeps `OrganizationReplicas` in sync).

### 2.2 AI Engine — `ai-service`
- **Owns:** Postgres `ai` (dialog bundle/mode config); Mongo `dialog_sessions` /
  `chat_messages` (roleplay transcripts). Otherwise largely stateless compute;
  Redis is used only as a TTS cache and for voice-usage-quota bookkeeping.
- **External:** OpenAI-compatible LLM API, OpenAI Whisper (STT), Yandex TTS.
- **Frontend REST (streaming):** `/dialog/*`, `/transcription/*`,
  `/admin/dialog/*`, `/admin/dialog-sessions[/*]`, `/admin/ai-usage[/*]`,
  `/admin/ai-quota[/*]`, `/admin/voice/*`.
- **Sync REST (internal):** `POST /ai/evaluate`, called by Learning to grade
  AI-graded exercise types; `StartSessionAsync`, called by Company to seed a
  practice-call roleplay with company context.
- **Kafka produces:** `dialog.evaluated`.
- **Kafka consumes:** `user.registered`/`updated`/`deleted` (replica),
  `organization.profile.updated` (content-substitution profile cache),
  `gamification.dialog-weights.updated` (caches the admin-tuned dialog scoring
  weights locally — this consumer opts out of tenant scoping, since scoring
  weights are platform config, not per-organization data).
- **Per-organization AI quota:** voice minutes (daily/monthly) and monthly LLM
  token budget are metered per organization; an organization with no quota row
  falls back to the platform default, never "unmetered". Configurable via
  `PUT /admin/ai-quota`.

### 2.3 Notifications — `notification-service` (Redis-only)
- **Owns (Redis):** a capped per-recipient inbox list and an unread counter,
  each key-prefixed `org:{organizationId}:notifications:inbox:{userId}` /
  `...notifications:unread:{userId}`, TTL 30 days. A handful of keys are
  deliberately un-prefixed because the identity they key on is cross-organization
  by product design (`notifications:user:{userId}` profile cache,
  `notifications:preferences:{userId}` reminder opt-outs) or because splitting
  them per organization would defeat their purpose (the chat-email pending
  queue, a single due-time-ordered work list).
- **Frontend REST:** `/notifications[/*]` (list, unread count, mark-read).
- **Kafka consumes:** `user.registered`/`updated`/`deleted` (profile cache for
  outbound email), `achievement.unlocked`, `streak.milestone`,
  `friend.request.received`, `friend.request.accepted`, `chat.message.sent`,
  `chat.message.read`, `discuss.reply.created`, `company.followup.due`,
  `assignment.issued`, `assignment.deadline.approaching`, `assignment.reminder`,
  `assignment.deadline.digest`, `dialog.review.commented`,
  `dialog.review.resolved`, `dialog.review.disputed` — writes an inbox entry
  and, for some event types, a MailerSend email. Pure consumer + thin read API.

### 2.4 Analytics — `analytics-service` (Redis + Prometheus)
- **Owns (Redis, its own instance `analytics-redis`):** presence sorted set,
  visit/event counters, a platform-wide operational funnel counter fed by
  Kafka; exports to Prometheus (Grafana dashboards).
- **Frontend REST:** `POST /tracking/{**catch-all}` (event tracking, presence
  ping).
- **Kafka consumes:** `user.registered`, `exercise.completed`, `xp.granted`,
  `assignment.issued`, `assignment.progress.changed`. Loss-tolerant by design —
  no durability guarantee needed for product-funnel counters.
- **Note:** the assignment funnel here is a platform-wide operational counter,
  not the per-organization manager view — that view reads progress rows
  directly out of `learning`'s database, where they live.

### 2.5 Social — `social-service`
- **Owns (Postgres `social`):** `Friendships`, `DiscussThreads`,
  `DiscussReplies`, `DiscussVotes`, `DiscussTags`, `DiscussThreadTags`,
  `DiscussPhotos`. **Owns (Mongo `chat_conversations`).**
- **External:** S3/MinIO (Discuss photos).
- **Frontend REST:** `/friends[/*]`, `/discuss/*`, `/admin/discuss/*`, `/chat/*`.
- **Kafka produces:** `friend.request.received`, `friend.request.accepted`,
  `chat.message.sent`, `chat.message.read`, `discuss.reply.created`.
- **Kafka consumes:** `user.registered`/`updated`/`deleted` (replica).

### 2.6 Gamification — `gamification-service`
Event-driven core: almost nothing here is written synchronously, it mostly
reacts to events from Learning and AI.
- **Owns (Postgres `gamification`):** `UserXpRecords`, `UserStreaks`,
  `GamificationSettings`, `ExerciseTypeRewards`, `StreakMilestones`,
  `Achievements`, `UserAchievements`, `Leagues`, `LeagueTiers`,
  `LeagueMemberships`, `LeagueSettings`.
- **Frontend REST:** `/gamification/*`, `/league[/*]`,
  `/profile/achievements[/*]`, `/admin/gamification/*`, `/admin/leagues[/*]`.
- **Kafka consumes:** `exercise.completed`, `lesson.completed`,
  `skill.completed`, `dialog.evaluated`, `user.registered`/`updated`/`deleted`/
  `avatar.changed` (replica) → grants progress points, updates the streak,
  unlocks achievements. Each grant is idempotent on the triggering event's id
  (a redelivered event cannot double-grant).
- **Kafka produces:** `xp.granted`, `achievement.unlocked`, `streak.milestone`,
  `gamification.dialog-weights.updated`.
- **Background jobs:** streak reset, weekly league closure (Hangfire, own DB).
- **Note (product):** progress points, streaks and leagues are gamification
  mechanics that exist end to end in this service and are returned by its API
  (including `/skill-tree`), but are **not surfaced anywhere in the product
  UI**. Do not describe them as user-visible.

### 2.7 Learning — `learning-service`
- **Owns (Postgres `learning`):** `Skills`, `SkillStages`, `Topics`, `Lessons`,
  `Exercises`, `ExerciseTypePrompts`, `UserSkillProgressRecords`,
  `UserLessonProgressRecords`, `UserExerciseAttempts`, `ReferenceMaterials`,
  `Techniques`, `TechniqueSkills`, `TechniqueCoaches`,
  `UserTechniqueProgressRecords`, `DailyQuotes`, assignments and dialog-review
  tables.
- **Frontend REST:** `/skills[/*]`, `/skill-tree`, `/program[/*]`,
  `/lessons[/*]`, `/topics/*`, `/exercises/*`, `/reference[/*]`,
  `/techniques[/*]`, `/daily-quote`, `/assignments/*`, `/dialog-reviews[/*]`,
  and the corresponding `/admin/*` routes for skills, skill-stages, topics,
  lessons, program, exercises, exercise-type-prompts, reference, techniques,
  daily-quotes, seeder, assignments, team, content-generation, content,
  dialog-reviews.
- **Sync dependency:** for AI-graded exercise types, calls AI Engine
  `POST /ai/evaluate` and awaits the verdict before persisting the attempt.
- **Kafka produces:** `exercise.completed`, `lesson.completed`,
  `skill.completed`, `assignment.issued`, `assignment.deadline.approaching`,
  `assignment.reminder`, `assignment.deadline.digest`,
  `assignment.progress.changed`, `dialog.review.commented`,
  `dialog.review.resolved`, `dialog.review.disputed`.
- **Kafka consumes:** `user.registered`/`updated`/`deleted`/`avatar.changed`
  (replica), `dialog.evaluated` + `exercise.completed` (assignment-threshold
  evaluation — the funnel state a person's assignment is in),
  `organization.profile.updated` (content-substitution profile cache).

### 2.8 Company — `company-service`
- **Owns (Postgres `company`):** `Company` (Id, UserId, Name, Description,
  Status, NextActionAt, NextActionNote, FollowUpNotifiedAt, CreatedAt,
  UpdatedAt), `CallLogEntry`, `PracticeCall` (links to an AI `DialogSession`
  with a goal), `CompanyContact`.
- **Frontend REST:** `/companies[/*]`.
- **Kafka produces (producer only):** a polling background service
  (`FollowUpReminderBackgroundService`, one scoped pass per organization)
  publishes `company.followup.due` for companies whose `NextActionAt` is due
  and not yet notified. Registers only the Kafka publisher + topic
  provisioner, not the full consumer stack, since it never consumes.
- **Sync dependency:** starting a practice call hands `companyName` /
  `companyDescription` / `callGoal` to AI Engine's `StartSessionAsync`, which
  composes it into the roleplay's system prompt.
- **No Redis or Mongo.** Every query is scoped to the caller's tenant and
  `UserId` at the service layer.

### 2.9 Organization — `organization-service`
- **Owns (Postgres `organization`):** `Organizations`, demo-request records.
- **Frontend REST:** `/organizations[/*]`, `/demo-requests[/*]`,
  `/admin/demo-requests[/*]`.
- **External:** MailerSend (demo-request lead notification).
- **Sync dependency:** provisioning a new organization from a demo request
  calls Identity's internal API to bootstrap the organization's first
  administrator.
- **Kafka produces:** `organization.created`, `organization.updated`,
  `organization.suspended`, `organization.profile.updated`.

### 2.10 API Gateway — `gateway` (YARP)
Single public entry point. Terminates TLS, validates the JWT once, and routes
by path prefix to the services above. Before forwarding a request it strips
any client-supplied `X-User-Id` / `X-User-Role` / `X-Organization-Id` headers
and re-adds them **only** from the validated JWT principal, so a caller cannot
spoof identity by setting the header itself.

**Each service still re-validates the JWT and authorizes off its own claims**
(shared signing key) — the gateway is not the sole authorization authority,
and the forwarded headers are defense-in-depth, not the trust boundary any
service actually relies on.

Admin routes (`/admin/*`) fan out by sub-path to each owning service's own
admin endpoints (e.g. `/admin/leagues/*` → gamification, `/admin/discuss/*` →
social, `/admin/users/*` → identity), which enforce their own `Admin`/
`SuperAdmin` authorization policy. There is no central admin service — the
frontend admin panel is a composition of these per-service admin APIs.

---

## 3. Kafka

### 3.1 Envelope

Every event on Kafka is wrapped the same way (`BuildingBlocks/Eventing/EventEnvelope.cs`):

```jsonc
{
  "eventId":        "guid",              // dedupe key for at-least-once delivery
  "occurredAt":     "2026-...Z",          // UTC
  "type":           "exercise.completed", // matches the topic name
  "version":        1,                    // payload schema version
  "organizationId": "guid | null",        // tenant; null only for platform-global events
  "data":           { ... }               // raw JSON, deserialized by the consumer after
                                           // it has looked at type/version
}
```

`organizationId` is populated from the publishing request's tenant context for
every tenant-scoped event. It stays `null` only for genuinely platform-global
events — Identity's cross-org user lifecycle stream, and the gamification
dialog-scoring-weights config replication. A consumer must know the tenant
*before* it deserializes `data`: `KafkaConsumerBackgroundService` sets the
tenant context from the envelope before invoking the handler, and by default a
consumer **throws** on a missing organization. A platform-global consumer opts
out explicitly by overriding `RequiresOrganization => false`.

Convention: topic name = `<aggregate>.<event>`; partition key = `userId`, so
one person's events are processed in order while different people's events
parallelize across partitions.

### 3.2 Delivery, retries, dead-lettering

Delivery is at-least-once, so **every consumer must be idempotent**
(`EventMessageProcessor` dedupes on `eventId` via a Redis-backed idempotency
store; gamification's progress-point grant additionally persists the
triggering event id in its own database for stronger guarantees than Redis
alone). A message that keeps failing after a bounded number of retries (3 by
default, backoff 500 ms × attempt) is published to `<topic>.dlt` and the
offset is committed anyway, so one poison message cannot block its partition.
An envelope whose `version` is higher than the consumer supports is
dead-lettered without being deserialized into the wrong shape.

Each service has its own Kafka consumer group, so the same event (e.g.
`exercise.completed`) is delivered independently to every interested service —
one topic, several independent readers.

Topics are provisioned by each service on startup (`KafkaTopicProvisioner`,
part of `AddSellevateEventing`) rather than relying on broker auto-create;
partition count / replication factor are configurable
(`Kafka:TopicPartitions` / `Kafka:TopicReplicationFactor`, default 1/1).

### 3.3 Outbox

`identity`, `learning` and `gamification` write outgoing events through the
transactional outbox pattern (`BuildingBlocks/Outbox`): the event row is
committed in the same database transaction as the business write, and a
background relay (`OutboxRelayBackgroundService`) forwards pending rows to
Kafka afterwards. This closes the dual-write gap (business write succeeds,
event publish is lost, or vice versa) for those three producers. `ai`,
`social`, `company` and `organization` publish directly through
`KafkaEventPublisher` (`Acks.All` + idempotent producer) without an outbox —
see the backlog for the residual dual-write risk this leaves on their events.

### 3.4 Topic catalogue

| Topic | Producer | Consumers |
|---|---|---|
| `user.registered` | Identity | AI, Learning, Gamification, Social, Notification, Analytics |
| `user.updated` | Identity | AI, Learning, Gamification, Social, Notification |
| `user.deleted` | Identity | AI, Learning, Gamification, Social, Notification |
| `user.avatar.changed` | Identity | Learning, Gamification |
| `exercise.completed` | Learning | Gamification, Learning (assignment threshold), Analytics |
| `lesson.completed` | Learning | Gamification |
| `skill.completed` | Learning | Gamification |
| `assignment.issued` | Learning | Notification, Analytics |
| `assignment.deadline.approaching` | Learning | Notification |
| `assignment.reminder` | Learning | Notification |
| `assignment.deadline.digest` | Learning | Notification |
| `assignment.progress.changed` | Learning | Analytics |
| `dialog.review.commented` | Learning | Notification |
| `dialog.review.resolved` | Learning | Notification |
| `dialog.review.disputed` | Learning | Notification |
| `dialog.evaluated` | AI | Gamification, Learning (assignment threshold) |
| `xp.granted` | Gamification | Analytics |
| `achievement.unlocked` | Gamification | Notification |
| `streak.milestone` | Gamification | Notification |
| `gamification.dialog-weights.updated` | Gamification | AI |
| `friend.request.received` | Social | Notification |
| `friend.request.accepted` | Social | Notification |
| `chat.message.sent` | Social | Notification |
| `chat.message.read` | Social | Notification |
| `discuss.reply.created` | Social | Notification |
| `company.followup.due` | Company | Notification |
| `organization.created` | Organization | Identity |
| `organization.updated` | Organization | Identity |
| `organization.suspended` | Organization | Identity |
| `organization.profile.updated` | Organization | AI, Learning |

### 3.5 Synchronous service-to-service REST (kept minimal)

| Caller → Callee | Endpoint | Why sync, not an event |
|---|---|---|
| Learning → AI | `POST /ai/evaluate` | The learner is waiting for the grade in real time |
| Company → AI | `StartSessionAsync` | Starting a roleplay needs the composed system prompt back before the session opens |
| Organization → Identity | internal provisioning call | Bootstrapping a new organization's first admin is part of the demo-request request/response |

Everything else that could be a synchronous read is instead a local
Kafka-fed read-model replica, so services stay independently deployable.

---

## 4. Data ownership

| Data | Owning service | Store |
|---|---|---|
| `User`, `RefreshToken`, `EmailVerificationCode`, `UserProfile`, `DefaultAvatar` | Identity | `identity` (PG) |
| `Membership`, `OrganizationAuthConfiguration`, `OrganizationReplica`, `Invite` | Identity | `identity` (PG) |
| `Skill`, `SkillStage`, `Topic`, `Lesson`, `Exercise`, `ExerciseTypePrompt`, `ReferenceMaterial`, `Technique`, `TechniqueSkill`, `TechniqueCoach`, `DailyQuote` | Learning | `learning` (PG) |
| `UserSkillProgress`, `UserLessonProgress`, `UserExerciseAttempt`, `UserTechniqueProgress`, assignments, dialog reviews | Learning | `learning` (PG) |
| `DialogBundle`, `DialogMode` (roleplay/config) | AI Engine | `ai` (PG) |
| `dialog_sessions`, `chat_messages` (roleplay transcripts) | AI Engine | Mongo `dialog_sessions` |
| `UserXpRecords`, `UserStreaks`, `GamificationSettings`, `ExerciseTypeReward`, `StreakMilestone`, `Achievement`, `UserAchievement`, `League`, `LeagueTier`, `LeagueMembership`, `LeagueSettings` | Gamification | `gamification` (PG) |
| `Friendship`, `DiscussThread`, `DiscussReply`, `DiscussVote`, `DiscussTag`, `DiscussThreadTag`, `DiscussPhoto` | Social | `social` (PG) |
| `chat_conversations` | Social | Mongo `chat_conversations` |
| Notification inbox + unread counter | Notifications | Redis (per-organization key prefix) |
| Presence, visit/event counters, funnel counter | Analytics | Redis (`analytics-redis`) |
| `Company`, `CallLogEntry`, `PracticeCall`, `CompanyContact` | Company | `company` (PG) |
| `Organization`, demo requests | Organization | `organization` (PG) |

**The shared-`User`-across-services problem** is solved with a replicated
read model, not a shared database: Identity is the sole writer of `User`;
every other relational service (`ai`, `learning`, `gamification`, `social`)
keeps a local `UserReplica { userId, displayName, avatarKey }` fed by the
`user.*` events above, and never reads Identity's database directly. Redis-only
services (`notification`, `analytics`) consume `user.*` events directly with
no replica table, since they have nothing to join it against.

---

## 5. BuildingBlocks (shared library)

`src/backend/building-blocks/BuildingBlocks` is referenced by every service.
It is not a runtime dependency between services — each service compiles its
own copy — but keeps the cross-cutting mechanics identical everywhere:

| Area | What it provides |
|---|---|
| `Eventing` | `EventEnvelope`, `Topics` (the single source of truth for topic name constants) |
| `Messaging` | `KafkaEventPublisher`, `KafkaConsumerBackgroundService` + `EventMessageProcessor` (retry/dedupe/DLT), `KafkaTopicProvisioner`, `ConsumerResilienceSettings` |
| `Outbox` | `OutboxMessage`, `IOutboxWriter`/`IOutboxStore`, `OutboxRelayBackgroundService` — the transactional-outbox implementation used by identity/learning/gamification |
| `Idempotency` | `IIdempotencyStore` / `RedisIdempotencyStore` — Redis-backed event-id dedupe for consumers |
| `Tenancy` | `ITenantContext`, tenant-scoping EF interceptors and middleware, row-level-security migration helpers, `TenantScopedAttribute` — see [TENANCY/TENANCY.md](TENANCY/TENANCY.md) |
| `Identity` | `IdentityHeaders` (the `X-User-Id`/`X-User-Role`/`X-Organization-Id` header contract), `UserReplica` |
| `Persistence` | `DatabaseBootstrapper` (create-database-if-missing), `DatabaseMigrator`, Postgres connection-string helpers |
| `HealthChecks` | Uniform `/healthz` (liveness) and `/readyz` (readiness: postgres/redis/kafka/mongo probes) across every service + gateway |
| `ContentTemplating` | Per-organization content-substitution rendering (e.g. company name into shared prompts/templates), fed by `organization.profile.updated` |
| `Email` | MailerSend client abstraction shared by identity/notification/organization |
| `DependencyInjection` | `AddSellevateEventing` and friends — the one-line wiring each service's `Program.cs` calls to register the pieces above |

---

## 6. Cross-cutting concerns

- **Auth:** JWT issued by Identity (short-lived access token, longer-lived
  refresh cookie), validated centrally at the gateway and again independently
  by each service off the same signing key.
- **Config/secrets:** per-service `.env` + `appsettings.json`, documented in
  [CONFIGURATION.md](CONFIGURATION.md).
- **Observability:** every service ships logs to Loki and metrics to
  Prometheus; Grafana carries a Kafka consumer-lag dashboard alongside the
  service dashboards. See [MONITORING.md](MONITORING.md).
- **Migrations:** each relational service runs its own EF Core migrations
  against its own database on startup.
- **Local dev:** infra (Postgres, Mongo, Redis ×2, Kafka, MinIO, Loki,
  Prometheus, Grafana) runs in Docker; each service runs individually on the
  host with hot reload. See [LOCAL_DEV.md](LOCAL_DEV.md).
