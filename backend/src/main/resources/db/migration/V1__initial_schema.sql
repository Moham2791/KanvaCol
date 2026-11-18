-- =====================================================================
-- KanvaCol: initial database schema (Milestone 1: sign up, draft, publish)
--
-- Flyway migration. Put this file in:
--   backend/src/main/resources/db/migration/V1__initial_schema.sql
-- Flyway runs it once, on app start-up, and records that it ran.
-- Never edit this file after it has run; add V2__..., V3__... instead.
--
-- Requires PostgreSQL 13+ (gen_random_uuid() is built in from 13).
-- =====================================================================


-- ---------------------------------------------------------------------
-- USERS
-- One table for everyone. Guest/Member/Admin are roles, not tables.
-- Every other table points to users.id, never to email or google_id.
-- ---------------------------------------------------------------------
CREATE TABLE users (
    id                  UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    email               VARCHAR(320) NOT NULL,
    username            VARCHAR(30)  NOT NULL,            -- public handle, e.g. jacob
    first_name          VARCHAR(100) NOT NULL,
    last_name           VARCHAR(100) NOT NULL,            -- real name shown only on PUBLIC profiles
    password_hash       VARCHAR(100),                     -- bcrypt hash; NULL for Google-only users
    google_id           VARCHAR(255),                     -- Google account ID; NULL for password-only users
    role                VARCHAR(20)  NOT NULL DEFAULT 'MEMBER',
    profile_visibility  VARCHAR(10)  NOT NULL DEFAULT 'PRIVATE',
    created_at          TIMESTAMPTZ  NOT NULL DEFAULT now(),

    CONSTRAINT users_role_valid        CHECK (role IN ('MEMBER', 'ADMIN')),
    CONSTRAINT users_visibility_valid  CHECK (profile_visibility IN ('PUBLIC', 'PRIVATE')),
    -- every account needs at least one way to log in
    CONSTRAINT users_has_login_method  CHECK (password_hash IS NOT NULL OR google_id IS NOT NULL)
);

-- Unique "ignoring case": Jacob@mail.com and jacob@mail.com are the same person.
-- These are indexes on lower(...), so they also make login lookups fast.
CREATE UNIQUE INDEX users_email_unique    ON users (lower(email));
CREATE UNIQUE INDEX users_username_unique ON users (lower(username));
-- UNIQUE allows many NULLs, so password-only users don't conflict with each other.
CREATE UNIQUE INDEX users_google_id_unique ON users (google_id);


-- ---------------------------------------------------------------------
-- TOPICS
-- One official list. Posts point to it by id, so renaming a topic
-- changes one row instead of every post.
-- ---------------------------------------------------------------------
CREATE TABLE topics (
    id    BIGINT       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name  VARCHAR(80)  NOT NULL
);

CREATE UNIQUE INDEX topics_name_unique ON topics (lower(name));

-- Starter topics (edit freely)
INSERT INTO topics (name) VALUES
    ('System design'),
    ('Home fixes'),
    ('Cooking'),
    ('Workflows');


-- ---------------------------------------------------------------------
-- USER_TOPICS (junction table: users <-> topics, many-to-many)
-- A user's favorite topics, chosen at sign-up. Drives the focused feed.
-- ---------------------------------------------------------------------
CREATE TABLE user_topics (
    user_id   UUID   NOT NULL REFERENCES users(id)  ON DELETE CASCADE,
    topic_id  BIGINT NOT NULL REFERENCES topics(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, topic_id)        -- fast: "what are this user's topics?"
);

-- Leftmost-column rule: the primary key starts with user_id,
-- so this extra index makes "who follows this topic?" fast too.
CREATE INDEX user_topics_topic_idx ON user_topics (topic_id);


-- ---------------------------------------------------------------------
-- POSTS
-- One row per idea. Holds facts about the post itself.
-- The drawing lives in post_versions (published) and post_drafts (work in progress).
-- ---------------------------------------------------------------------
CREATE TABLE posts (
    id            UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id      UUID          NOT NULL REFERENCES users(id),
    topic_id      BIGINT        REFERENCES topics(id),   -- required once published (see check below)
    title         VARCHAR(150),                          -- required once published
    problem       VARCHAR(300),                          -- one sentence: what is this idea trying to solve?
    status        VARCHAR(10)   NOT NULL DEFAULT 'DRAFT',
    created_at    TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ   NOT NULL DEFAULT now(),  -- set by the app (e.g. @UpdateTimestamp in JPA)
    published_at  TIMESTAMPTZ,                           -- first time it was published

    CONSTRAINT posts_status_valid CHECK (status IN ('DRAFT', 'PUBLISHED')),
    -- a brand-new draft can be incomplete; a published post cannot
    CONSTRAINT posts_published_is_complete CHECK (
        status = 'DRAFT'
        OR (topic_id IS NOT NULL AND title IS NOT NULL AND problem IS NOT NULL AND published_at IS NOT NULL)
    )
);

CREATE INDEX posts_owner_idx ON posts (owner_id);          -- "my posts"

-- The feed: newest published posts in a topic.
-- A partial index only contains PUBLISHED rows, so it stays small and fast.
CREATE INDEX posts_feed_idx ON posts (topic_id, published_at DESC)
    WHERE status = 'PUBLISHED';


-- ---------------------------------------------------------------------
-- POST_VERSIONS
-- Every published version is kept forever (history for the Time Machine).
-- The newest version_number is the one the feed shows.
-- ---------------------------------------------------------------------
CREATE TABLE post_versions (
    post_id         UUID         NOT NULL REFERENCES posts(id),
    version_number  INT          NOT NULL,
    author_id       UUID         NOT NULL REFERENCES users(id),  -- may be a contributor whose change was merged
    drawing         JSONB        NOT NULL,                       -- Excalidraw scene
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT now(),

    PRIMARY KEY (post_id, version_number),                       -- "post 11, version 3" exists once
    CONSTRAINT post_versions_number_positive CHECK (version_number > 0)
);

CREATE INDEX post_versions_author_idx ON post_versions (author_id);  -- "versions this person authored"


-- ---------------------------------------------------------------------
-- POST_DRAFTS
-- Work in progress. Overwritten on every save (UPDATE, not INSERT).
-- One draft per person per post. The post stays PUBLISHED and visible
-- in the feed while someone drafts its next version.
-- On publish: copy the draft into post_versions, then delete the draft row.
-- ---------------------------------------------------------------------
CREATE TABLE post_drafts (
    post_id     UUID         NOT NULL REFERENCES posts(id),
    author_id   UUID         NOT NULL REFERENCES users(id),
    drawing     JSONB        NOT NULL,
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),

    PRIMARY KEY (post_id, author_id)                             -- one draft per person per post
);

CREATE INDEX post_drafts_author_idx ON post_drafts (author_id);  -- "my drafts"


-- ---------------------------------------------------------------------
-- POST_LINKS (junction table: posts <-> posts)
-- "This post builds on that post." A post can have several parents.
-- Links always point to older posts, so the graph can never loop.
-- Not used until linking is built (after Milestone 1).
-- OPEN DECISION: should a link point to the parent post, or to the
-- specific parent version it was built on?
-- ---------------------------------------------------------------------
CREATE TABLE post_links (
    post_id     UUID         NOT NULL REFERENCES posts(id),   -- the newer post
    parent_id   UUID         NOT NULL REFERENCES posts(id),   -- the post it builds on
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),

    PRIMARY KEY (post_id, parent_id),                         -- no duplicate links
    CONSTRAINT post_links_not_self CHECK (post_id <> parent_id)
);

CREATE INDEX post_links_parent_idx ON post_links (parent_id); -- "what was built on this post?"


-- ---------------------------------------------------------------------
-- POST_COLLABORATORS (junction table: posts <-> users)
-- People whose merged contributions are credited on a post.
-- Not used until merging is built (after Milestone 1).
-- ---------------------------------------------------------------------
CREATE TABLE post_collaborators (
    post_id  UUID NOT NULL REFERENCES posts(id),
    user_id  UUID NOT NULL REFERENCES users(id),

    PRIMARY KEY (post_id, user_id)                            -- fast: "who worked on this post?"
);

CREATE INDEX post_collaborators_user_idx ON post_collaborators (user_id); -- "what did this user work on?"


-- ---------------------------------------------------------------------
-- NOTE ON DELETING
-- Deleting a post that others built on is still an open decision, so
-- post tables use the default (block the delete if rows depend on it).
-- Decide the rule, then change it in a later migration (V2__...).
-- ---------------------------------------------------------------------
