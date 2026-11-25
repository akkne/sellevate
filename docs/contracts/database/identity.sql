CREATE TABLE "DefaultAvatars" (
    "Id" uuid NOT NULL,
    "Index" integer NOT NULL,
    "ObjectKey" text NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_DefaultAvatars" PRIMARY KEY ("Id")
);


CREATE TABLE "EmailVerificationCodes" (
    "Id" uuid NOT NULL,
    "Email" text NOT NULL,
    "CodeHash" text NOT NULL,
    "ExpiresAt" timestamp with time zone NOT NULL,
    "AttemptCount" integer NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_EmailVerificationCodes" PRIMARY KEY ("Id")
);


CREATE TABLE "ImpersonationAuditEntries" (
    "Id" uuid NOT NULL,
    "ActorUserId" uuid NOT NULL,
    "ActorEmail" character varying(320) NOT NULL,
    "OrganizationId" uuid NOT NULL,
    "OrganizationName" character varying(200) NOT NULL,
    "Reason" character varying(500) NOT NULL,
    "IssuedAt" timestamp with time zone NOT NULL,
    "ExpiresAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_ImpersonationAuditEntries" PRIMARY KEY ("Id")
);


CREATE TABLE "Invites" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid NOT NULL,
    "Email" character varying(320) NOT NULL,
    "Role" integer NOT NULL,
    "TokenHash" character varying(64) NOT NULL,
    "ExpiresAt" timestamp with time zone NOT NULL,
    "AcceptedAt" timestamp with time zone,
    "RevokedAt" timestamp with time zone,
    "InvitedBy" uuid,
    "CreatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_Invites" PRIMARY KEY ("Id")
);


CREATE TABLE "OrganizationAuthConfigurations" (
    "OrganizationId" uuid NOT NULL,
    "Method" character varying(32) NOT NULL,
    "ProviderSettings" jsonb,
    "AllowedEmailDomains" text[] NOT NULL,
    "IsJustInTimeProvisioningEnabled" boolean NOT NULL,
    "SessionLifetime" interval,
    "IsMultiFactorAuthenticationRequired" boolean NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_OrganizationAuthConfigurations" PRIMARY KEY ("OrganizationId")
);


CREATE TABLE "OrganizationReplicas" (
    "OrganizationId" uuid NOT NULL,
    "Name" character varying(200) NOT NULL,
    "Slug" character varying(100) NOT NULL,
    "Status" integer NOT NULL,
    "UpdatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_OrganizationReplicas" PRIMARY KEY ("OrganizationId")
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


CREATE TABLE "UserProfiles" (
    "Id" uuid NOT NULL,
    "UserId" uuid NOT NULL,
    "SalesType" text NOT NULL,
    "ExperienceLevel" text NOT NULL,
    "Goal" text NOT NULL,
    "IsOnboardingCompleted" boolean NOT NULL,
    "Persona" text,
    CONSTRAINT "PK_UserProfiles" PRIMARY KEY ("Id")
);


CREATE TABLE "Users" (
    "Id" uuid NOT NULL,
    "Email" text NOT NULL,
    "PasswordHash" text,
    "DisplayName" text NOT NULL,
    "GoogleId" text,
    "CreatedAt" timestamp with time zone NOT NULL,
    "IsEmailVerified" boolean NOT NULL DEFAULT FALSE,
    "Role" integer NOT NULL,
    "AvatarType" integer NOT NULL DEFAULT 0,
    "AvatarKey" text,
    "DefaultAvatarIndex" integer NOT NULL DEFAULT 0,
    CONSTRAINT "PK_Users" PRIMARY KEY ("Id")
);


CREATE TABLE "Memberships" (
    "UserId" uuid NOT NULL,
    "OrganizationId" uuid NOT NULL,
    "Role" integer NOT NULL,
    "Status" integer NOT NULL DEFAULT 0,
    "InvitedBy" uuid,
    "JoinedAt" timestamp with time zone NOT NULL,
    "DeactivatedAt" timestamp with time zone,
    CONSTRAINT "PK_Memberships" PRIMARY KEY ("UserId", "OrganizationId"),
    CONSTRAINT "FK_Memberships_Users_UserId" FOREIGN KEY ("UserId") REFERENCES "Users" ("Id") ON DELETE CASCADE
);


CREATE TABLE "RefreshTokens" (
    "Id" uuid NOT NULL,
    "UserId" uuid NOT NULL,
    "Token" text NOT NULL,
    "ExpiresAt" timestamp with time zone NOT NULL,
    "IsRevoked" boolean NOT NULL,
    CONSTRAINT "PK_RefreshTokens" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_RefreshTokens_Users_UserId" FOREIGN KEY ("UserId") REFERENCES "Users" ("Id") ON DELETE CASCADE
);


CREATE UNIQUE INDEX "IX_DefaultAvatars_Index" ON "DefaultAvatars" ("Index");


CREATE INDEX "IX_EmailVerificationCodes_Email" ON "EmailVerificationCodes" ("Email");


CREATE INDEX "IX_ImpersonationAuditEntries_IssuedAt" ON "ImpersonationAuditEntries" ("IssuedAt" DESC);


CREATE INDEX "IX_ImpersonationAuditEntries_OrganizationId_IssuedAt" ON "ImpersonationAuditEntries" ("OrganizationId", "IssuedAt" DESC);


CREATE INDEX "IX_Invites_OrganizationId_Email" ON "Invites" ("OrganizationId", "Email");


CREATE UNIQUE INDEX "IX_Invites_TokenHash" ON "Invites" ("TokenHash");


CREATE INDEX "IX_Memberships_OrganizationId" ON "Memberships" ("OrganizationId");


CREATE INDEX "IX_OrganizationAuthConfigurations_AllowedEmailDomains" ON "OrganizationAuthConfigurations" USING gin ("AllowedEmailDomains");


CREATE INDEX "IX_OutboxMessages_DispatchedAt" ON "OutboxMessages" ("DispatchedAt");


CREATE UNIQUE INDEX "IX_RefreshTokens_Token" ON "RefreshTokens" ("Token");


CREATE INDEX "IX_RefreshTokens_UserId" ON "RefreshTokens" ("UserId");


CREATE UNIQUE INDEX "IX_UserProfiles_UserId" ON "UserProfiles" ("UserId");


CREATE UNIQUE INDEX "IX_Users_Email" ON "Users" ("Email");
