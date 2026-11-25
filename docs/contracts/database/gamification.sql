CREATE TABLE "Achievements" (
    "Id" uuid NOT NULL,
    "Key" text NOT NULL,
    "Title" text NOT NULL,
    "Description" text NOT NULL,
    "IconEmoji" text NOT NULL,
    "ConditionType" text NOT NULL,
    "ConditionThreshold" integer NOT NULL,
    "SortOrder" integer NOT NULL,
    CONSTRAINT "PK_Achievements" PRIMARY KEY ("Id")
);


CREATE TABLE "ExerciseTypeRewards" (
    "Id" uuid NOT NULL,
    "ExerciseType" character varying(40) NOT NULL,
    "BaseXpReward" integer NOT NULL,
    CONSTRAINT "PK_ExerciseTypeRewards" PRIMARY KEY ("Id")
);


CREATE TABLE "GamificationSettings" (
    "Id" uuid NOT NULL,
    "DailyXpGoal" integer NOT NULL,
    "WeeklyXpGoal" integer NOT NULL,
    "DialogXpMultiplier" double precision NOT NULL,
    "DialogWeightConfidence" integer NOT NULL,
    "DialogWeightStructure" integer NOT NULL,
    "DialogWeightObjection" integer NOT NULL,
    "DialogWeightGoal" integer NOT NULL,
    CONSTRAINT "PK_GamificationSettings" PRIMARY KEY ("Id")
);


CREATE TABLE "LeagueMemberships" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid NOT NULL,
    "UserId" uuid NOT NULL,
    "LeagueId" uuid NOT NULL,
    "WeeklyXpAmount" integer NOT NULL,
    "Rank" integer NOT NULL,
    "PromotionOutcome" text,
    CONSTRAINT "PK_LeagueMemberships" PRIMARY KEY ("Id")
);


CREATE TABLE "Leagues" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid NOT NULL,
    "Tier" text NOT NULL,
    "WeekStartDate" date NOT NULL,
    "WeekEndDate" date NOT NULL,
    CONSTRAINT "PK_Leagues" PRIMARY KEY ("Id")
);


CREATE TABLE "LeagueSettings" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid NOT NULL,
    "MaximumLeagueParticipantCount" integer NOT NULL,
    "PromotionZoneSize" integer NOT NULL,
    "DemotionZoneSize" integer NOT NULL,
    "CurrentPeriodStartDate" date,
    "CurrentPeriodEndsAt" timestamp with time zone,
    "PeriodLengthDays" integer NOT NULL,
    CONSTRAINT "PK_LeagueSettings" PRIMARY KEY ("Id")
);


CREATE TABLE "LeagueTiers" (
    "Id" uuid NOT NULL,
    "Key" character varying(40) NOT NULL,
    "Name" character varying(60) NOT NULL,
    "Color" character varying(20) NOT NULL,
    "Order" integer NOT NULL,
    CONSTRAINT "PK_LeagueTiers" PRIMARY KEY ("Id")
);


CREATE TABLE "OutboxMessages" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid,
    "Topic" character varying(200) NOT NULL,
    "PartitionKey" character varying(200) NOT NULL,
    "Payload" text NOT NULL,
    "OccurredAt" timestamp with time zone NOT NULL,
    "DispatchedAt" timestamp with time zone,
    CONSTRAINT "PK_OutboxMessages" PRIMARY KEY ("Id")
);


CREATE TABLE "StreakMilestones" (
    "Id" uuid NOT NULL,
    "DayCount" integer NOT NULL,
    "XpReward" integer NOT NULL,
    CONSTRAINT "PK_StreakMilestones" PRIMARY KEY ("Id")
);


CREATE TABLE "UserAchievements" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid NOT NULL,
    "UserId" uuid NOT NULL,
    "AchievementId" uuid NOT NULL,
    "UnlockedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_UserAchievements" PRIMARY KEY ("Id")
);


CREATE TABLE "UserLearningProgress" (
    "UserId" uuid NOT NULL,
    "OrganizationId" uuid NOT NULL,
    "CompletedLessonCount" integer NOT NULL,
    "HasCompletedAnySkill" boolean NOT NULL,
    "UpdatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_UserLearningProgress" PRIMARY KEY ("OrganizationId", "UserId")
);


CREATE TABLE "UserReplicas" (
    "UserId" uuid NOT NULL,
    "Email" character varying(320) NOT NULL,
    "DisplayName" character varying(200) NOT NULL,
    "AvatarKey" text,
    "UpdatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_UserReplicas" PRIMARY KEY ("UserId")
);


CREATE TABLE "UserStreaks" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid NOT NULL,
    "UserId" uuid NOT NULL,
    "CurrentStreakDayCount" integer NOT NULL,
    "LongestStreakDayCount" integer NOT NULL,
    "LastActivityDate" date,
    CONSTRAINT "PK_UserStreaks" PRIMARY KEY ("Id")
);


CREATE TABLE "UserXpRecords" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid NOT NULL,
    "UserId" uuid NOT NULL,
    "Amount" integer NOT NULL,
    "Source" text NOT NULL,
    "EarnedAt" timestamp with time zone NOT NULL,
    "SourceEventId" uuid,
    CONSTRAINT "PK_UserXpRecords" PRIMARY KEY ("Id")
);


CREATE UNIQUE INDEX "IX_Achievements_Key" ON "Achievements" ("Key");


CREATE UNIQUE INDEX "IX_ExerciseTypeRewards_ExerciseType" ON "ExerciseTypeRewards" ("ExerciseType");


CREATE INDEX "IX_LeagueMemberships_OrganizationId_LeagueId" ON "LeagueMemberships" ("OrganizationId", "LeagueId");


CREATE UNIQUE INDEX "IX_LeagueMemberships_OrganizationId_UserId_LeagueId" ON "LeagueMemberships" ("OrganizationId", "UserId", "LeagueId");


CREATE UNIQUE INDEX "IX_Leagues_OrganizationId_WeekStartDate_Tier" ON "Leagues" ("OrganizationId", "WeekStartDate", "Tier");


CREATE UNIQUE INDEX "IX_LeagueSettings_OrganizationId" ON "LeagueSettings" ("OrganizationId");


CREATE UNIQUE INDEX "IX_LeagueTiers_Key" ON "LeagueTiers" ("Key");


CREATE INDEX "IX_OutboxMessages_DispatchedAt" ON "OutboxMessages" ("DispatchedAt");


CREATE UNIQUE INDEX "IX_StreakMilestones_DayCount" ON "StreakMilestones" ("DayCount");


CREATE UNIQUE INDEX "IX_UserAchievements_OrganizationId_UserId_AchievementId" ON "UserAchievements" ("OrganizationId", "UserId", "AchievementId");


CREATE UNIQUE INDEX "IX_UserStreaks_OrganizationId_UserId" ON "UserStreaks" ("OrganizationId", "UserId");


CREATE INDEX "IX_UserXpRecords_OrganizationId_UserId" ON "UserXpRecords" ("OrganizationId", "UserId");


CREATE UNIQUE INDEX "IX_UserXpRecords_SourceEventId" ON "UserXpRecords" ("SourceEventId") WHERE "SourceEventId" IS NOT NULL;
