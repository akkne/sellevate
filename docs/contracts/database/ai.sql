CREATE TABLE "AiUsageRecords" (
    "OrganizationId" uuid NOT NULL,
    "PeriodKey" character varying(7) NOT NULL,
    "Model" character varying(128) NOT NULL,
    "Kind" character varying(16) NOT NULL,
    "PromptTokens" bigint NOT NULL,
    "CompletionTokens" bigint NOT NULL,
    "CallCount" bigint NOT NULL,
    "EstimatedCallCount" bigint NOT NULL,
    "SpeechCharacters" bigint NOT NULL,
    "UpdatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_AiUsageRecords" PRIMARY KEY ("OrganizationId", "PeriodKey", "Model")
);


CREATE TABLE "DialogBundles" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid,
    "SkillId" uuid NOT NULL,
    "Title" character varying(200) NOT NULL,
    "Description" character varying(1000) NOT NULL,
    "IconEmoji" character varying(10) NOT NULL,
    "SortOrder" integer NOT NULL,
    "IsActive" boolean NOT NULL,
    "IsHidden" boolean NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_DialogBundles" PRIMARY KEY ("Id")
);


CREATE TABLE "OrganizationProfileReplicas" (
    "OrganizationId" uuid NOT NULL,
    "Product" text,
    "Icp" text,
    "Tone" text,
    "ObjectionsJson" jsonb NOT NULL DEFAULT '[]',
    "ScriptJson" jsonb NOT NULL DEFAULT '[]',
    "GlossaryJson" jsonb NOT NULL DEFAULT '{}',
    "BannedClaimsJson" jsonb NOT NULL DEFAULT '[]',
    "UpdatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_OrganizationProfileReplicas" PRIMARY KEY ("OrganizationId")
);


CREATE TABLE "OrganizationQuotas" (
    "OrganizationId" uuid NOT NULL,
    "VoiceDailyLimitMinutes" integer,
    "VoiceMonthlyLimitMinutes" integer,
    "LlmMonthlyTokenLimit" bigint,
    "BatchReservePercent" integer,
    "Note" character varying(1000),
    "UpdatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_OrganizationQuotas" PRIMARY KEY ("OrganizationId")
);


CREATE TABLE "UserReplicas" (
    "UserId" uuid NOT NULL,
    "Email" character varying(320) NOT NULL,
    "DisplayName" character varying(200) NOT NULL,
    "AvatarKey" text,
    "UpdatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_UserReplicas" PRIMARY KEY ("UserId")
);


CREATE TABLE "DialogModes" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid,
    "ParentModeId" uuid,
    "BaseContentHash" character varying(64),
    "BundleId" uuid NOT NULL,
    "Key" character varying(100) NOT NULL,
    "Title" character varying(200) NOT NULL,
    "Description" character varying(1000) NOT NULL,
    "ChatSystemPrompt" text NOT NULL,
    "FeedbackSystemPrompt" text NOT NULL,
    "SortOrder" integer NOT NULL,
    "IsActive" boolean NOT NULL,
    "VoiceEnabled" boolean NOT NULL,
    "VoiceId" text,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_DialogModes" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_DialogModes_DialogBundles_BundleId" FOREIGN KEY ("BundleId") REFERENCES "DialogBundles" ("Id") ON DELETE CASCADE,
    CONSTRAINT "FK_DialogModes_DialogModes_ParentModeId" FOREIGN KEY ("ParentModeId") REFERENCES "DialogModes" ("Id") ON DELETE RESTRICT
);


CREATE INDEX "IX_DialogBundles_OrganizationId_SortOrder" ON "DialogBundles" ("OrganizationId", "SortOrder");


CREATE INDEX "IX_DialogBundles_SkillId" ON "DialogBundles" ("SkillId");


CREATE INDEX "IX_DialogBundles_SortOrder" ON "DialogBundles" ("SortOrder");


CREATE INDEX "IX_DialogModes_BundleId" ON "DialogModes" ("BundleId");


CREATE UNIQUE INDEX "IX_DialogModes_BundleId_Key_Global" ON "DialogModes" ("BundleId", "Key") WHERE "OrganizationId" IS NULL;


CREATE UNIQUE INDEX "IX_DialogModes_OrganizationId_BundleId_Key" ON "DialogModes" ("OrganizationId", "BundleId", "Key") WHERE "OrganizationId" IS NOT NULL;


CREATE INDEX "IX_DialogModes_ParentModeId" ON "DialogModes" ("ParentModeId");
