CREATE TABLE "DiscussPhotos" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid NOT NULL,
    "OwnerType" integer NOT NULL,
    "OwnerId" uuid NOT NULL,
    "ObjectKey" character varying(512) NOT NULL,
    "ContentType" character varying(100) NOT NULL,
    "OrderIndex" integer NOT NULL,
    "SizeBytes" bigint NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_DiscussPhotos" PRIMARY KEY ("Id")
);


CREATE TABLE "DiscussTags" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid,
    "Slug" character varying(60) NOT NULL,
    "Name" character varying(60) NOT NULL,
    "IsCurated" boolean NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_DiscussTags" PRIMARY KEY ("Id")
);


CREATE TABLE "DiscussThreads" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid NOT NULL,
    "AuthorId" uuid NOT NULL,
    "Title" character varying(300) NOT NULL,
    "Body" character varying(20000) NOT NULL,
    "UpvoteCount" integer NOT NULL,
    "ReplyCount" integer NOT NULL,
    "ViewCount" integer NOT NULL,
    "AcceptedReplyId" uuid,
    "IsPinned" boolean NOT NULL,
    "IsHot" boolean NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone NOT NULL,
    "LastActivityAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_DiscussThreads" PRIMARY KEY ("Id")
);


CREATE TABLE "DiscussVotes" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid NOT NULL,
    "UserId" uuid NOT NULL,
    "TargetType" integer NOT NULL,
    "TargetId" uuid NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_DiscussVotes" PRIMARY KEY ("Id")
);


CREATE TABLE "Friendships" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid NOT NULL,
    "RequesterId" uuid NOT NULL,
    "AddresseeId" uuid NOT NULL,
    "Status" integer NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    "AcceptedAt" timestamp with time zone,
    "CanonicalLowId" uuid GENERATED ALWAYS AS (LEAST("RequesterId", "AddresseeId")) STORED NOT NULL,
    "CanonicalHighId" uuid GENERATED ALWAYS AS (GREATEST("RequesterId", "AddresseeId")) STORED NOT NULL,
    CONSTRAINT "PK_Friendships" PRIMARY KEY ("Id"),
    CONSTRAINT "CK_Friendships_NoSelfFriendship" CHECK ("RequesterId" != "AddresseeId")
);


CREATE TABLE "UserReplicas" (
    "UserId" uuid NOT NULL,
    "Email" character varying(320) NOT NULL,
    "DisplayName" character varying(200) NOT NULL,
    "AvatarKey" text,
    "UpdatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_UserReplicas" PRIMARY KEY ("UserId")
);


CREATE TABLE "DiscussReplies" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid NOT NULL,
    "ThreadId" uuid NOT NULL,
    "AuthorId" uuid NOT NULL,
    "Body" character varying(20000) NOT NULL,
    "UpvoteCount" integer NOT NULL,
    "IsAccepted" boolean NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_DiscussReplies" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_DiscussReplies_DiscussThreads_ThreadId" FOREIGN KEY ("ThreadId") REFERENCES "DiscussThreads" ("Id") ON DELETE CASCADE
);


CREATE TABLE "DiscussThreadTags" (
    "Id" uuid NOT NULL,
    "OrganizationId" uuid NOT NULL,
    "ThreadId" uuid NOT NULL,
    "TagId" uuid NOT NULL,
    CONSTRAINT "PK_DiscussThreadTags" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_DiscussThreadTags_DiscussTags_TagId" FOREIGN KEY ("TagId") REFERENCES "DiscussTags" ("Id") ON DELETE CASCADE,
    CONSTRAINT "FK_DiscussThreadTags_DiscussThreads_ThreadId" FOREIGN KEY ("ThreadId") REFERENCES "DiscussThreads" ("Id") ON DELETE CASCADE
);


CREATE INDEX "IX_DiscussPhotos_OrganizationId_OwnerType_OwnerId_OrderIndex" ON "DiscussPhotos" ("OrganizationId", "OwnerType", "OwnerId", "OrderIndex");


CREATE INDEX "IX_DiscussReplies_OrganizationId_AuthorId" ON "DiscussReplies" ("OrganizationId", "AuthorId");


CREATE INDEX "IX_DiscussReplies_OrganizationId_ThreadId_CreatedAt" ON "DiscussReplies" ("OrganizationId", "ThreadId", "CreatedAt");


CREATE INDEX "IX_DiscussReplies_ThreadId" ON "DiscussReplies" ("ThreadId");


CREATE INDEX "IX_DiscussTags_OrganizationId_IsCurated" ON "DiscussTags" ("OrganizationId", "IsCurated");


CREATE UNIQUE INDEX "IX_DiscussTags_OrganizationId_Slug" ON "DiscussTags" ("OrganizationId", "Slug");


CREATE UNIQUE INDEX "IX_DiscussTags_Slug_Global" ON "DiscussTags" ("Slug") WHERE "OrganizationId" IS NULL;


CREATE INDEX "IX_DiscussThreads_OrganizationId_AuthorId" ON "DiscussThreads" ("OrganizationId", "AuthorId");


CREATE INDEX "IX_DiscussThreads_OrganizationId_CreatedAt" ON "DiscussThreads" ("OrganizationId", "CreatedAt");


CREATE INDEX "IX_DiscussThreads_OrganizationId_IsPinned" ON "DiscussThreads" ("OrganizationId", "IsPinned");


CREATE INDEX "IX_DiscussThreads_OrganizationId_LastActivityAt" ON "DiscussThreads" ("OrganizationId", "LastActivityAt");


CREATE INDEX "IX_DiscussThreads_OrganizationId_UpvoteCount" ON "DiscussThreads" ("OrganizationId", "UpvoteCount");


CREATE UNIQUE INDEX "IX_DiscussThreadTags_OrganizationId_ThreadId_TagId" ON "DiscussThreadTags" ("OrganizationId", "ThreadId", "TagId");


CREATE INDEX "IX_DiscussThreadTags_TagId" ON "DiscussThreadTags" ("TagId");


CREATE INDEX "IX_DiscussThreadTags_ThreadId" ON "DiscussThreadTags" ("ThreadId");


CREATE INDEX "IX_DiscussVotes_OrganizationId_TargetType_TargetId" ON "DiscussVotes" ("OrganizationId", "TargetType", "TargetId");


CREATE UNIQUE INDEX "IX_DiscussVotes_OrganizationId_UserId_TargetType_TargetId" ON "DiscussVotes" ("OrganizationId", "UserId", "TargetType", "TargetId");


CREATE UNIQUE INDEX "IX_Friendships_CanonicalPair" ON "Friendships" ("OrganizationId", "CanonicalLowId", "CanonicalHighId");


CREATE INDEX "IX_Friendships_OrganizationId_AddresseeId" ON "Friendships" ("OrganizationId", "AddresseeId");


CREATE INDEX "IX_Friendships_OrganizationId_RequesterId" ON "Friendships" ("OrganizationId", "RequesterId");


CREATE UNIQUE INDEX "IX_Friendships_OrganizationId_RequesterId_AddresseeId" ON "Friendships" ("OrganizationId", "RequesterId", "AddresseeId");
