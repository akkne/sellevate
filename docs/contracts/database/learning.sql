CREATE TABLE "Assignments" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid NOT NULL,
    "CreatedBy" uuid,
    "Title" character varying(200) NOT NULL,
    "Goal" character varying(2000),
    "SourceType" character varying(16) NOT NULL,
    "SourceRef" character varying(200),
    "Content" jsonb NOT NULL,
    "Audience" jsonb NOT NULL,
    "OpensAt" timestamp with time zone,
    "Deadline" timestamp with time zone,
    "CompletionRule" jsonb NOT NULL,
    "RepeatSchedule" jsonb,
    "RepeatOfAssignmentId" uuid,
    "RepeatWaveIndex" integer,
    "Status" character varying(16) NOT NULL DEFAULT 'draft',
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone NOT NULL,
    "ActivatedAt" timestamp with time zone,
    "ClosedAt" timestamp with time zone,
    "DeadlineNoticeSentAt" timestamp with time zone,
    CONSTRAINT "PK_Assignments" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_Assignments_Assignments_RepeatOfAssignmentId" FOREIGN KEY ("RepeatOfAssignmentId") REFERENCES "Assignments" ("Id") ON DELETE RESTRICT
);


CREATE TABLE "ContentAdaptationJobs" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid NOT NULL,
    "CreatedBy" uuid,
    "Mode" character varying(32) NOT NULL DEFAULT 'tone_rewrite',
    "StageKey" character varying(64) NOT NULL,
    "Status" character varying(20) NOT NULL DEFAULT 'preparing',
    "ItemCount" integer NOT NULL,
    "ClaimedAt" timestamp with time zone,
    "FailureReason" character varying(1000),
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone NOT NULL,
    "CompletedAt" timestamp with time zone,
    CONSTRAINT "PK_ContentAdaptationJobs" PRIMARY KEY ("Id")
);


CREATE TABLE "ContentGenerationJobs" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid NOT NULL,
    "CreatedBy" uuid,
    "Title" character varying(200) NOT NULL,
    "SourceMaterial" text NOT NULL,
    "GapSourceRef" character varying(200),
    "Status" character varying(20) NOT NULL DEFAULT 'structuring',
    "Structure" jsonb,
    "StructuredAt" timestamp with time zone,
    "StructuredMaterialLength" integer NOT NULL,
    "Insufficiency" jsonb,
    "ApprovedAt" timestamp with time zone,
    "ApprovedBy" uuid,
    "ProducedLessonId" uuid,
    "ProducedLessonVersionId" uuid,
    "ProducedExerciseCount" integer NOT NULL,
    "GeneratedAt" timestamp with time zone,
    "FailureReason" character varying(1000),
    "Attempts" integer NOT NULL,
    "ClaimedAt" timestamp with time zone,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_ContentGenerationJobs" PRIMARY KEY ("Id")
);


CREATE TABLE "DailyQuotes" (
    "Id" uuid NOT NULL,
    "Date" date NOT NULL,
    "Text" text NOT NULL,
    "Author" character varying(120) NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_DailyQuotes" PRIMARY KEY ("Id")
);


CREATE TABLE "DialogReviewNotes" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid NOT NULL,
    "Kind" character varying(20) NOT NULL DEFAULT 'coaching_note',
    "SessionId" character varying(64) NOT NULL,
    "DialogModeKey" character varying(100) NOT NULL,
    "SubjectUserId" uuid NOT NULL,
    "AuthorUserId" uuid NOT NULL,
    "QuotedFromMessageIndex" integer,
    "QuotedToMessageIndex" integer,
    "QuotedText" character varying(8000),
    "Comment" character varying(4000) NOT NULL,
    "DisputedScore" integer,
    "Status" character varying(20) NOT NULL DEFAULT 'open',
    "Resolution" character varying(4000),
    "AdjustedScore" integer,
    "ResolvedBy" uuid,
    "ResolvedAt" timestamp with time zone,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_DialogReviewNotes" PRIMARY KEY ("Id")
);


CREATE TABLE "ExerciseTypePrompts" (
    "Id" uuid NOT NULL,
    "ExerciseType" text NOT NULL,
    "SystemPrompt" text NOT NULL,
    "UpdatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_ExerciseTypePrompts" PRIMARY KEY ("Id")
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


CREATE TABLE "ProgramVersions" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid NOT NULL,
    "VersionNumber" integer NOT NULL,
    "Status" character varying(16) NOT NULL DEFAULT 'draft',
    "CreatedBy" uuid,
    "CreatedAt" timestamp with time zone NOT NULL,
    "PublishedAt" timestamp with time zone,
    CONSTRAINT "PK_ProgramVersions" PRIMARY KEY ("Id")
);


CREATE TABLE "ReferenceMaterials" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid,
    "ParentMaterialId" uuid,
    "BaseContentHash" character varying(64),
    "IsArchived" boolean NOT NULL DEFAULT FALSE,
    "SkillId" uuid NOT NULL,
    "Title" text NOT NULL,
    "MarkdownContent" text NOT NULL,
    "SortOrder" integer NOT NULL,
    "Category" text,
    "Tags" text,
    CONSTRAINT "PK_ReferenceMaterials" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_ReferenceMaterials_ReferenceMaterials_ParentMaterialId" FOREIGN KEY ("ParentMaterialId") REFERENCES "ReferenceMaterials" ("Id") ON DELETE RESTRICT
);


CREATE TABLE "Skills" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid,
    "IconicName" text NOT NULL,
    "OrderInTree" integer NOT NULL,
    "Title" text NOT NULL,
    "Description" text,
    "Stage" text NOT NULL DEFAULT 'general',
    CONSTRAINT "PK_Skills" PRIMARY KEY ("Id")
);


CREATE TABLE "SkillStages" (
    "Id" uuid NOT NULL,
    "Key" character varying(40) NOT NULL,
    "Label" character varying(60) NOT NULL,
    "Accent" character varying(40) NOT NULL,
    "Order" integer NOT NULL,
    CONSTRAINT "PK_SkillStages" PRIMARY KEY ("Id")
);


CREATE TABLE "TeamSkillGapDismissals" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid NOT NULL,
    "StageKey" character varying(64) NOT NULL,
    "DismissedBy" uuid,
    "DismissedAt" timestamp with time zone NOT NULL,
    "ExpiresAt" timestamp with time zone NOT NULL,
    "AccuracyPercentAtDismissal" integer NOT NULL,
    "AttemptCountAtDismissal" integer NOT NULL,
    "Note" character varying(500),
    CONSTRAINT "PK_TeamSkillGapDismissals" PRIMARY KEY ("Id")
);


CREATE TABLE "Techniques" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid,
    "ParentTechniqueId" uuid,
    "BaseContentHash" character varying(64),
    "IsArchived" boolean NOT NULL DEFAULT FALSE,
    "Slug" character varying(120) NOT NULL,
    "Name" character varying(200) NOT NULL,
    "Summary" text NOT NULL,
    "Body" text NOT NULL,
    "Tags" text[] NOT NULL,
    "PrimarySkillId" uuid,
    "Difficulty" integer NOT NULL,
    "DialogJson" jsonb,
    "CaseJson" jsonb,
    "SortOrder" integer NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_Techniques" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_Techniques_Techniques_ParentTechniqueId" FOREIGN KEY ("ParentTechniqueId") REFERENCES "Techniques" ("Id") ON DELETE RESTRICT
);


CREATE TABLE "UserDialogScores" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid NOT NULL,
    "UserId" uuid NOT NULL,
    "SessionId" character varying(64) NOT NULL,
    "DialogModeKey" character varying(100) NOT NULL,
    "DialogModeId" uuid NOT NULL,
    "Score" integer NOT NULL,
    "EvaluatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_UserDialogScores" PRIMARY KEY ("Id")
);


CREATE TABLE "UserExerciseAttempts" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid NOT NULL,
    "UserId" uuid NOT NULL,
    "LessonVersionId" uuid,
    "ExerciseId" uuid NOT NULL,
    "SerializedAnswer" jsonb NOT NULL,
    "IsCorrect" boolean NOT NULL,
    "Score" integer NOT NULL,
    "SerializedAiFeedback" jsonb,
    "AttemptedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_UserExerciseAttempts" PRIMARY KEY ("Id")
);


CREATE TABLE "UserLessonProgressRecords" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid NOT NULL,
    "UserId" uuid NOT NULL,
    "LessonId" uuid NOT NULL,
    "LessonVersionId" uuid,
    "Status" text NOT NULL,
    "BestScore" integer NOT NULL,
    "CompletedAt" timestamp with time zone,
    CONSTRAINT "PK_UserLessonProgressRecords" PRIMARY KEY ("Id")
);


CREATE TABLE "UserReplicas" (
    "UserId" uuid NOT NULL,
    "Email" character varying(320) NOT NULL,
    "DisplayName" character varying(200) NOT NULL,
    "AvatarKey" text,
    "UpdatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_UserReplicas" PRIMARY KEY ("UserId")
);


CREATE TABLE "UserSkillProgressRecords" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid NOT NULL,
    "UserId" uuid NOT NULL,
    "SkillId" uuid NOT NULL,
    "Status" text NOT NULL,
    "CompletedLessonCount" integer NOT NULL,
    "TotalLessonCount" integer NOT NULL,
    CONSTRAINT "PK_UserSkillProgressRecords" PRIMARY KEY ("Id")
);


CREATE TABLE "UserTechniqueProgress" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid NOT NULL,
    "UserId" uuid NOT NULL,
    "TechniqueId" uuid NOT NULL,
    "Level" integer NOT NULL,
    "MasteryPercent" integer NOT NULL,
    "PracticeCount" integer NOT NULL,
    "LastPracticedAt" timestamp with time zone,
    "FirstSeenAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_UserTechniqueProgress" PRIMARY KEY ("Id")
);


CREATE TABLE "AssignmentProgressRecords" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid NOT NULL,
    "AssignmentId" uuid NOT NULL,
    "UserId" uuid NOT NULL,
    "Status" character varying(20) NOT NULL DEFAULT 'not_started',
    "BestScore" integer,
    "AttemptCount" integer NOT NULL,
    "FirstOpenedAt" timestamp with time zone,
    "CompletedAt" timestamp with time zone,
    CONSTRAINT "PK_AssignmentProgressRecords" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_AssignmentProgressRecords_Assignments_AssignmentId" FOREIGN KEY ("AssignmentId") REFERENCES "Assignments" ("Id") ON DELETE RESTRICT
);


CREATE TABLE "ContentAdaptationItems" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid NOT NULL,
    "JobId" uuid NOT NULL,
    "ExerciseId" uuid NOT NULL,
    "LessonId" uuid NOT NULL,
    "LessonTitle" character varying(300) NOT NULL,
    "ExerciseType" character varying(50) NOT NULL,
    "OrderInLesson" integer NOT NULL,
    "BaseContentHash" character varying(64) NOT NULL,
    "Status" character varying(20) NOT NULL DEFAULT 'pending',
    "ProposedContent" jsonb,
    "ChangeSummary" character varying(500),
    "ChangedFieldCount" integer NOT NULL,
    "Findings" jsonb,
    "AppliedExerciseId" uuid,
    "AppliedAt" timestamp with time zone,
    "ResolvedBy" uuid,
    "ResolvedAt" timestamp with time zone,
    "Attempts" integer NOT NULL,
    "FailureReason" character varying(1000),
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_ContentAdaptationItems" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_ContentAdaptationItems_ContentAdaptationJobs_JobId" FOREIGN KEY ("JobId") REFERENCES "ContentAdaptationJobs" ("Id") ON DELETE CASCADE
);


CREATE TABLE "ProgramEnrollments" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid NOT NULL,
    "UserId" uuid NOT NULL,
    "ProgramVersionId" uuid NOT NULL,
    "PreviousProgramVersionId" uuid,
    "EnrolledAt" timestamp with time zone NOT NULL,
    "SwitchedAt" timestamp with time zone,
    CONSTRAINT "PK_ProgramEnrollments" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_ProgramEnrollments_ProgramVersions_ProgramVersionId" FOREIGN KEY ("ProgramVersionId") REFERENCES "ProgramVersions" ("Id") ON DELETE RESTRICT
);


CREATE TABLE "ProgramItems" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid NOT NULL,
    "ProgramVersionId" uuid NOT NULL,
    "SkillId" uuid NOT NULL,
    "LessonId" uuid NOT NULL,
    "LessonVersionId" uuid NOT NULL,
    "OrderIndex" integer NOT NULL,
    CONSTRAINT "PK_ProgramItems" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_ProgramItems_ProgramVersions_ProgramVersionId" FOREIGN KEY ("ProgramVersionId") REFERENCES "ProgramVersions" ("Id") ON DELETE CASCADE
);


CREATE TABLE "Topics" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid,
    "SkillId" uuid NOT NULL,
    "IconicName" text NOT NULL,
    "OrderInSkill" integer NOT NULL,
    "Title" text NOT NULL,
    CONSTRAINT "PK_Topics" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_Topics_Skills_SkillId" FOREIGN KEY ("SkillId") REFERENCES "Skills" ("Id") ON DELETE CASCADE
);


CREATE TABLE "TechniqueCoaches" (
    "Id" uuid NOT NULL,
    "TechniqueId" uuid NOT NULL,
    "AvatarSeed" character varying(64) NOT NULL,
    "Name" character varying(120) NOT NULL,
    "Role" character varying(120) NOT NULL,
    "Quote" text NOT NULL,
    "ChallengesJson" jsonb,
    CONSTRAINT "PK_TechniqueCoaches" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_TechniqueCoaches_Techniques_TechniqueId" FOREIGN KEY ("TechniqueId") REFERENCES "Techniques" ("Id") ON DELETE CASCADE
);


CREATE TABLE "TechniqueSkills" (
    "TechniqueId" uuid NOT NULL,
    "SkillId" uuid NOT NULL,
    CONSTRAINT "PK_TechniqueSkills" PRIMARY KEY ("TechniqueId", "SkillId"),
    CONSTRAINT "FK_TechniqueSkills_Techniques_TechniqueId" FOREIGN KEY ("TechniqueId") REFERENCES "Techniques" ("Id") ON DELETE CASCADE
);


CREATE TABLE "Lessons" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid,
    "ParentLessonId" uuid,
    "Slug" character varying(160) NOT NULL,
    "IsArchived" boolean NOT NULL DEFAULT FALSE,
    "TopicId" uuid NOT NULL,
    "OrderInTopic" integer NOT NULL,
    "Title" text NOT NULL,
    CONSTRAINT "PK_Lessons" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_Lessons_Lessons_ParentLessonId" FOREIGN KEY ("ParentLessonId") REFERENCES "Lessons" ("Id") ON DELETE RESTRICT,
    CONSTRAINT "FK_Lessons_Topics_TopicId" FOREIGN KEY ("TopicId") REFERENCES "Topics" ("Id") ON DELETE CASCADE
);


CREATE TABLE "Exercises" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid,
    "LessonId" uuid NOT NULL,
    "Type" text NOT NULL,
    "OrderInLesson" integer NOT NULL,
    "SerializedContent" jsonb NOT NULL,
    "CustomAiPrompt" text,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_Exercises" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_Exercises_Lessons_LessonId" FOREIGN KEY ("LessonId") REFERENCES "Lessons" ("Id") ON DELETE CASCADE
);


CREATE TABLE "LessonVersions" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid,
    "LessonId" uuid NOT NULL,
    "VersionNumber" integer NOT NULL,
    "Content" jsonb NOT NULL,
    "ContentHash" character varying(64) NOT NULL,
    "Status" character varying(16) NOT NULL DEFAULT 'draft',
    "BaseVersionId" uuid,
    "IsBreaking" boolean NOT NULL,
    "CreatedBy" uuid,
    "CreatedAt" timestamp with time zone NOT NULL,
    "PublishedAt" timestamp with time zone,
    CONSTRAINT "PK_LessonVersions" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_LessonVersions_LessonVersions_BaseVersionId" FOREIGN KEY ("BaseVersionId") REFERENCES "LessonVersions" ("Id") ON DELETE SET NULL,
    CONSTRAINT "FK_LessonVersions_Lessons_LessonId" FOREIGN KEY ("LessonId") REFERENCES "Lessons" ("Id") ON DELETE CASCADE
);


CREATE INDEX "IX_AssignmentProgressRecords_AssignmentId_Status" ON "AssignmentProgressRecords" ("AssignmentId", "Status");


CREATE UNIQUE INDEX "IX_AssignmentProgressRecords_OrganizationId_AssignmentId_UserId" ON "AssignmentProgressRecords" ("OrganizationId", "AssignmentId", "UserId");


CREATE INDEX "IX_AssignmentProgressRecords_OrganizationId_UserId_Status" ON "AssignmentProgressRecords" ("OrganizationId", "UserId", "Status");


CREATE INDEX "IX_Assignments_OrganizationId_CreatedAt" ON "Assignments" ("OrganizationId", "CreatedAt");


CREATE INDEX "IX_Assignments_OrganizationId_Status_Deadline" ON "Assignments" ("OrganizationId", "Status", "Deadline");


CREATE UNIQUE INDEX "IX_Assignments_RepeatOfAssignmentId_RepeatWaveIndex" ON "Assignments" ("RepeatOfAssignmentId", "RepeatWaveIndex") WHERE "RepeatOfAssignmentId" IS NOT NULL;


CREATE INDEX "IX_ContentAdaptationItems_JobId" ON "ContentAdaptationItems" ("JobId");


CREATE INDEX "IX_ContentAdaptationItems_OrganizationId_ExerciseId_Status" ON "ContentAdaptationItems" ("OrganizationId", "ExerciseId", "Status");


CREATE INDEX "IX_ContentAdaptationItems_OrganizationId_JobId_LessonId_OrderI~" ON "ContentAdaptationItems" ("OrganizationId", "JobId", "LessonId", "OrderInLesson");


CREATE INDEX "IX_ContentAdaptationItems_OrganizationId_JobId_Status" ON "ContentAdaptationItems" ("OrganizationId", "JobId", "Status");


CREATE INDEX "IX_ContentAdaptationJobs_OrganizationId_CreatedAt" ON "ContentAdaptationJobs" ("OrganizationId", "CreatedAt");


CREATE INDEX "IX_ContentAdaptationJobs_OrganizationId_Status_CreatedAt" ON "ContentAdaptationJobs" ("OrganizationId", "Status", "CreatedAt");


CREATE UNIQUE INDEX "UX_ContentAdaptationJobs_Live" ON "ContentAdaptationJobs" ("OrganizationId", "Mode", "StageKey") WHERE "Status" IN ('preparing', 'awaiting_review');


CREATE INDEX "IX_ContentGenerationJobs_OrganizationId_CreatedAt" ON "ContentGenerationJobs" ("OrganizationId", "CreatedAt");


CREATE INDEX "IX_ContentGenerationJobs_OrganizationId_GapSourceRef" ON "ContentGenerationJobs" ("OrganizationId", "GapSourceRef") WHERE "GapSourceRef" IS NOT NULL;


CREATE INDEX "IX_ContentGenerationJobs_OrganizationId_ProducedLessonId" ON "ContentGenerationJobs" ("OrganizationId", "ProducedLessonId");


CREATE INDEX "IX_ContentGenerationJobs_OrganizationId_Status_CreatedAt" ON "ContentGenerationJobs" ("OrganizationId", "Status", "CreatedAt");


CREATE UNIQUE INDEX "IX_DailyQuotes_Date" ON "DailyQuotes" ("Date");


CREATE INDEX "IX_DialogReviewNotes_OrganizationId_Kind_Status_CreatedAt" ON "DialogReviewNotes" ("OrganizationId", "Kind", "Status", "CreatedAt");


CREATE INDEX "IX_DialogReviewNotes_OrganizationId_SessionId" ON "DialogReviewNotes" ("OrganizationId", "SessionId");


CREATE INDEX "IX_DialogReviewNotes_OrganizationId_SubjectUserId_Status" ON "DialogReviewNotes" ("OrganizationId", "SubjectUserId", "Status");


CREATE INDEX "IX_Exercises_LessonId" ON "Exercises" ("LessonId");


CREATE INDEX "IX_Exercises_OrganizationId_LessonId_OrderInLesson" ON "Exercises" ("OrganizationId", "LessonId", "OrderInLesson");


CREATE UNIQUE INDEX "IX_ExerciseTypePrompts_ExerciseType" ON "ExerciseTypePrompts" ("ExerciseType");


CREATE UNIQUE INDEX "IX_Lessons_OrganizationId_Slug" ON "Lessons" ("OrganizationId", "Slug");


CREATE INDEX "IX_Lessons_OrganizationId_TopicId_OrderInTopic" ON "Lessons" ("OrganizationId", "TopicId", "OrderInTopic");


CREATE INDEX "IX_Lessons_ParentLessonId" ON "Lessons" ("ParentLessonId");


CREATE UNIQUE INDEX "IX_Lessons_Slug_Global" ON "Lessons" ("Slug") WHERE "OrganizationId" IS NULL;


CREATE INDEX "IX_Lessons_TopicId" ON "Lessons" ("TopicId");


CREATE INDEX "IX_LessonVersions_BaseVersionId" ON "LessonVersions" ("BaseVersionId");


CREATE UNIQUE INDEX "IX_LessonVersions_LessonId_Draft" ON "LessonVersions" ("LessonId") WHERE "Status" = 'draft';


CREATE UNIQUE INDEX "IX_LessonVersions_LessonId_VersionNumber" ON "LessonVersions" ("LessonId", "VersionNumber");


CREATE INDEX "IX_LessonVersions_OrganizationId_LessonId_VersionNumber" ON "LessonVersions" ("OrganizationId", "LessonId", "VersionNumber");


CREATE INDEX "IX_OutboxMessages_DispatchedAt" ON "OutboxMessages" ("DispatchedAt");


CREATE UNIQUE INDEX "IX_ProgramEnrollments_OrganizationId_UserId" ON "ProgramEnrollments" ("OrganizationId", "UserId");


CREATE INDEX "IX_ProgramEnrollments_ProgramVersionId" ON "ProgramEnrollments" ("ProgramVersionId");


CREATE INDEX "IX_ProgramItems_LessonVersionId" ON "ProgramItems" ("LessonVersionId");


CREATE INDEX "IX_ProgramItems_OrganizationId_ProgramVersionId_OrderIndex" ON "ProgramItems" ("OrganizationId", "ProgramVersionId", "OrderIndex");


CREATE UNIQUE INDEX "IX_ProgramItems_ProgramVersionId_LessonId" ON "ProgramItems" ("ProgramVersionId", "LessonId");


CREATE UNIQUE INDEX "IX_ProgramVersions_OrganizationId_Draft" ON "ProgramVersions" ("OrganizationId") WHERE "Status" = 'draft';


CREATE UNIQUE INDEX "IX_ProgramVersions_OrganizationId_VersionNumber" ON "ProgramVersions" ("OrganizationId", "VersionNumber");


CREATE INDEX "IX_ReferenceMaterials_OrganizationId_SkillId_SortOrder" ON "ReferenceMaterials" ("OrganizationId", "SkillId", "SortOrder");


CREATE INDEX "IX_ReferenceMaterials_ParentMaterialId" ON "ReferenceMaterials" ("ParentMaterialId");


CREATE UNIQUE INDEX "IX_Skills_IconicName_Global" ON "Skills" ("IconicName") WHERE "OrganizationId" IS NULL;


CREATE UNIQUE INDEX "IX_Skills_OrganizationId_IconicName" ON "Skills" ("OrganizationId", "IconicName");


CREATE INDEX "IX_Skills_OrganizationId_Stage" ON "Skills" ("OrganizationId", "Stage");


CREATE UNIQUE INDEX "IX_SkillStages_Key" ON "SkillStages" ("Key");


CREATE UNIQUE INDEX "IX_TeamSkillGapDismissals_OrganizationId_StageKey" ON "TeamSkillGapDismissals" ("OrganizationId", "StageKey");


CREATE UNIQUE INDEX "IX_TechniqueCoaches_TechniqueId" ON "TechniqueCoaches" ("TechniqueId");


CREATE INDEX "IX_Techniques_OrganizationId_PrimarySkillId" ON "Techniques" ("OrganizationId", "PrimarySkillId");


CREATE UNIQUE INDEX "IX_Techniques_OrganizationId_Slug" ON "Techniques" ("OrganizationId", "Slug");


CREATE INDEX "IX_Techniques_OrganizationId_SortOrder" ON "Techniques" ("OrganizationId", "SortOrder");


CREATE INDEX "IX_Techniques_ParentTechniqueId" ON "Techniques" ("ParentTechniqueId");


CREATE UNIQUE INDEX "IX_Techniques_Slug_Global" ON "Techniques" ("Slug") WHERE "OrganizationId" IS NULL;


CREATE INDEX "IX_TechniqueSkills_SkillId" ON "TechniqueSkills" ("SkillId");


CREATE UNIQUE INDEX "IX_Topics_IconicName_Global" ON "Topics" ("IconicName") WHERE "OrganizationId" IS NULL;


CREATE UNIQUE INDEX "IX_Topics_OrganizationId_IconicName" ON "Topics" ("OrganizationId", "IconicName");


CREATE INDEX "IX_Topics_OrganizationId_SkillId_OrderInSkill" ON "Topics" ("OrganizationId", "SkillId", "OrderInSkill");


CREATE INDEX "IX_Topics_SkillId" ON "Topics" ("SkillId");


CREATE INDEX "IX_UserDialogScores_OrganizationId_UserId_DialogModeKey_Evalua~" ON "UserDialogScores" ("OrganizationId", "UserId", "DialogModeKey", "EvaluatedAt");


CREATE UNIQUE INDEX "IX_UserDialogScores_OrganizationId_UserId_SessionId" ON "UserDialogScores" ("OrganizationId", "UserId", "SessionId");


CREATE INDEX "IX_UserExerciseAttempts_OrganizationId_LessonVersionId_Exercis~" ON "UserExerciseAttempts" ("OrganizationId", "LessonVersionId", "ExerciseId");


CREATE INDEX "IX_UserExerciseAttempts_OrganizationId_UserId_ExerciseId" ON "UserExerciseAttempts" ("OrganizationId", "UserId", "ExerciseId");


CREATE INDEX "IX_UserLessonProgressRecords_OrganizationId_LessonVersionId" ON "UserLessonProgressRecords" ("OrganizationId", "LessonVersionId");


CREATE INDEX "IX_UserLessonProgressRecords_OrganizationId_UserId_LessonId" ON "UserLessonProgressRecords" ("OrganizationId", "UserId", "LessonId");


CREATE INDEX "IX_UserSkillProgressRecords_OrganizationId_UserId_SkillId" ON "UserSkillProgressRecords" ("OrganizationId", "UserId", "SkillId");


CREATE INDEX "IX_UserTechniqueProgress_OrganizationId_UserId" ON "UserTechniqueProgress" ("OrganizationId", "UserId");


CREATE UNIQUE INDEX "IX_UserTechniqueProgress_OrganizationId_UserId_TechniqueId" ON "UserTechniqueProgress" ("OrganizationId", "UserId", "TechniqueId");
