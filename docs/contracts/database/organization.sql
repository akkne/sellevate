CREATE TABLE "DemoRequests" (
    "Id" uuid NOT NULL,
    "FullName" character varying(120) NOT NULL,
    "WorkEmail" character varying(200) NOT NULL,
    "Phone" character varying(40) NOT NULL,
    "CompanyName" character varying(200) NOT NULL,
    "JobTitle" character varying(120),
    "SalesTeamSize" character varying(32) NOT NULL,
    "Comment" character varying(2000),
    "Status" character varying(32) NOT NULL DEFAULT 'New',
    "ConsentGivenAt" timestamp with time zone NOT NULL,
    "MarketingConsentGivenAt" timestamp with time zone,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone NOT NULL,
    "OrganizationId" uuid,
    "ProvisioningState" character varying(32) NOT NULL DEFAULT 'NotProvisioned',
    "BootstrapInviteId" uuid,
    "BootstrapAdminEmail" character varying(200),
    "ProvisionedAt" timestamp with time zone,
    CONSTRAINT "PK_DemoRequests" PRIMARY KEY ("Id")
);


CREATE TABLE "OrganizationProfiles" (
    "OrganizationId" uuid NOT NULL,
    "Product" text,
    "Icp" text,
    "ObjectionsJson" jsonb NOT NULL DEFAULT '[]',
    "ScriptJson" jsonb NOT NULL DEFAULT '[]',
    "Tone" text,
    "GlossaryJson" jsonb NOT NULL DEFAULT '{}',
    "BannedClaimsJson" jsonb NOT NULL DEFAULT '[]',
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_OrganizationProfiles" PRIMARY KEY ("OrganizationId")
);


CREATE TABLE "Organizations" (
    "Id" uuid NOT NULL,
    "Name" character varying(200) NOT NULL,
    "Slug" character varying(120) NOT NULL,
    "Status" character varying(32) NOT NULL DEFAULT 'Active',
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_Organizations" PRIMARY KEY ("Id")
);


CREATE INDEX "IX_DemoRequests_CreatedAt" ON "DemoRequests" ("CreatedAt" DESC);


CREATE UNIQUE INDEX "IX_DemoRequests_OrganizationId" ON "DemoRequests" ("OrganizationId") WHERE "OrganizationId" IS NOT NULL;


CREATE INDEX "IX_DemoRequests_WorkEmail" ON "DemoRequests" ("WorkEmail");


CREATE UNIQUE INDEX "IX_Organizations_Slug" ON "Organizations" ("Slug");
