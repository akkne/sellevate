CREATE TABLE "Companies" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid NOT NULL,
    "UserId" uuid NOT NULL,
    "Name" character varying(200) NOT NULL,
    "Description" character varying(8000) NOT NULL DEFAULT '',
    "Status" character varying(32) NOT NULL DEFAULT 'Lead',
    "NextActionAt" timestamp with time zone,
    "NextActionNote" character varying(2000),
    "FollowUpNotifiedAt" timestamp with time zone,
    "BriefingContent" text,
    "BriefingGeneratedAt" timestamp with time zone,
    "ReadinessJson" text,
    "ReadinessGeneratedAt" timestamp with time zone,
    "ReadinessNoFeedbackUntil" timestamp with time zone,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_Companies" PRIMARY KEY ("Id")
);


CREATE TABLE "CompanyContacts" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid NOT NULL,
    "CompanyId" uuid NOT NULL,
    "UserId" uuid NOT NULL,
    "Name" character varying(200) NOT NULL,
    "Position" character varying(200) NOT NULL DEFAULT '',
    "Notes" character varying(2000) NOT NULL DEFAULT '',
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_CompanyContacts" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_CompanyContacts_Companies_CompanyId" FOREIGN KEY ("CompanyId") REFERENCES "Companies" ("Id") ON DELETE CASCADE
);


CREATE TABLE "CompanyPersonas" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid NOT NULL,
    "CompanyId" uuid NOT NULL,
    "UserId" uuid NOT NULL,
    "Name" character varying(200) NOT NULL,
    "Position" character varying(200) NOT NULL,
    "Personality" character varying(4000) NOT NULL,
    "Difficulty" character varying(16) NOT NULL DEFAULT 'Medium',
    "CreatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_CompanyPersonas" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_CompanyPersonas_Companies_CompanyId" FOREIGN KEY ("CompanyId") REFERENCES "Companies" ("Id") ON DELETE CASCADE
);


CREATE TABLE "PracticeCalls" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid NOT NULL,
    "CompanyId" uuid NOT NULL,
    "UserId" uuid NOT NULL,
    "DialogSessionId" character varying(100) NOT NULL,
    "Goal" character varying(1000) NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_PracticeCalls" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_PracticeCalls_Companies_CompanyId" FOREIGN KEY ("CompanyId") REFERENCES "Companies" ("Id") ON DELETE CASCADE
);


CREATE TABLE "CallLogEntries" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid NOT NULL,
    "CompanyId" uuid NOT NULL,
    "UserId" uuid NOT NULL,
    "ContactId" uuid,
    "ContactName" character varying(200) NOT NULL,
    "Subject" character varying(4000) NOT NULL,
    "Outcome" character varying(4000) NOT NULL,
    "OccurredAt" timestamp with time zone NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_CallLogEntries" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_CallLogEntries_Companies_CompanyId" FOREIGN KEY ("CompanyId") REFERENCES "Companies" ("Id") ON DELETE CASCADE,
    CONSTRAINT "FK_CallLogEntries_CompanyContacts_ContactId" FOREIGN KEY ("ContactId") REFERENCES "CompanyContacts" ("Id") ON DELETE SET NULL
);


CREATE INDEX "IX_CallLogEntries_CompanyId" ON "CallLogEntries" ("CompanyId");


CREATE INDEX "IX_CallLogEntries_ContactId" ON "CallLogEntries" ("ContactId");


CREATE INDEX "IX_CallLogEntries_OrganizationId_CompanyId_OccurredAt" ON "CallLogEntries" ("OrganizationId", "CompanyId", "OccurredAt" DESC);


CREATE INDEX "IX_CallLogEntries_OrganizationId_UserId" ON "CallLogEntries" ("OrganizationId", "UserId");


CREATE INDEX "IX_Companies_OrganizationId_NextActionAt" ON "Companies" ("OrganizationId", "NextActionAt") WHERE "NextActionAt" IS NOT NULL;


CREATE INDEX "IX_Companies_OrganizationId_UserId" ON "Companies" ("OrganizationId", "UserId");


CREATE INDEX "IX_CompanyContacts_CompanyId" ON "CompanyContacts" ("CompanyId");


CREATE INDEX "IX_CompanyContacts_OrganizationId_CompanyId_CreatedAt" ON "CompanyContacts" ("OrganizationId", "CompanyId", "CreatedAt" DESC);


CREATE INDEX "IX_CompanyContacts_OrganizationId_UserId" ON "CompanyContacts" ("OrganizationId", "UserId");


CREATE INDEX "IX_CompanyPersonas_CompanyId" ON "CompanyPersonas" ("CompanyId");


CREATE INDEX "IX_CompanyPersonas_OrganizationId_CompanyId_CreatedAt" ON "CompanyPersonas" ("OrganizationId", "CompanyId", "CreatedAt" DESC);


CREATE INDEX "IX_CompanyPersonas_OrganizationId_UserId" ON "CompanyPersonas" ("OrganizationId", "UserId");


CREATE INDEX "IX_PracticeCalls_CompanyId" ON "PracticeCalls" ("CompanyId");


CREATE INDEX "IX_PracticeCalls_OrganizationId_CompanyId_CreatedAt" ON "PracticeCalls" ("OrganizationId", "CompanyId", "CreatedAt" DESC);


CREATE INDEX "IX_PracticeCalls_OrganizationId_UserId" ON "PracticeCalls" ("OrganizationId", "UserId");
