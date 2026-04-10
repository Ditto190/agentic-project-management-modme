-- Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Artifact type enum
CREATE TYPE artifact_type AS ENUM (
    'research_paper', 'white_paper', 'url_bookmark',
    'code_repository', 'note', 'book', 'dataset',
    'presentation', 'video', 'podcast', 'other'
);

-- Artifact status enum
CREATE TYPE artifact_status AS ENUM (
    'inbox', 'reading', 'completed', 'archived', 'reference'
);

-- Core artifacts table with JSONB metadata
CREATE TABLE artifacts (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id    UUID NOT NULL,
    artifact_type   artifact_type NOT NULL,
    status          artifact_status NOT NULL DEFAULT 'inbox',
    created_by      UUID NOT NULL,

    -- Dublin Core-inspired core fields
    title           TEXT NOT NULL,
    description     TEXT,
    source_url      TEXT,
    doi             TEXT UNIQUE,
    isbn            TEXT,
    language        VARCHAR(10) DEFAULT 'en',
    published_date  DATE,

    -- Type-specific metadata in JSONB
    metadata        JSONB NOT NULL DEFAULT '{}',

    -- Content fields
    plain_text_content TEXT,
    content_hash    VARCHAR(64),
    word_count      INTEGER,

    -- Full-text search vector (auto-generated)
    search_vector   tsvector GENERATED ALWAYS AS (
        setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(description, '')), 'B') ||
        setweight(to_tsvector('english', coalesce(plain_text_content, '')), 'C')
    ) STORED,

    -- Versioning and audit
    version         INTEGER NOT NULL DEFAULT 1,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at      TIMESTAMPTZ
);

-- Performance-critical indexes
CREATE INDEX idx_artifacts_workspace ON artifacts(workspace_id);
CREATE INDEX idx_artifacts_type ON artifacts(artifact_type);
CREATE INDEX idx_artifacts_created_by ON artifacts(created_by);
CREATE INDEX idx_artifacts_created ON artifacts(created_at DESC);
CREATE INDEX idx_artifacts_doi ON artifacts(doi) WHERE doi IS NOT NULL;
CREATE INDEX idx_artifacts_not_deleted ON artifacts(id) WHERE deleted_at IS NULL;
CREATE INDEX idx_artifacts_metadata ON artifacts USING GIN(metadata jsonb_path_ops);
CREATE INDEX idx_artifacts_search ON artifacts USING GIN(search_vector);

-- Authors and contributors
CREATE TABLE persons (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name   TEXT NOT NULL,
    orcid       VARCHAR(20),
    affiliation TEXT,
    metadata    JSONB DEFAULT '{}'
);

CREATE TABLE artifact_contributors (
    artifact_id UUID NOT NULL REFERENCES artifacts(id) ON DELETE CASCADE,
    person_id   UUID NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    role        VARCHAR(20) NOT NULL DEFAULT 'author',
    position    INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY (artifact_id, person_id, role)
);

-- Tagging with AI confidence tracking
CREATE TABLE tags (
    id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name    TEXT NOT NULL,
    slug    TEXT NOT NULL UNIQUE,
    color   VARCHAR(7)
);

CREATE TABLE artifact_tags (
    artifact_id UUID NOT NULL REFERENCES artifacts(id) ON DELETE CASCADE,
    tag_id      UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    added_by    VARCHAR(20) DEFAULT 'user',
    confidence  REAL,
    PRIMARY KEY (artifact_id, tag_id)
);

-- Hierarchical collections
CREATE TABLE collections (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name        TEXT NOT NULL,
    parent_id   UUID REFERENCES collections(id) ON DELETE CASCADE,
    position    INTEGER DEFAULT 0,
    UNIQUE (parent_id, name)
);

CREATE TABLE artifact_collections (
    artifact_id   UUID NOT NULL REFERENCES artifacts(id) ON DELETE CASCADE,
    collection_id UUID NOT NULL REFERENCES collections(id) ON DELETE CASCADE,
    PRIMARY KEY (artifact_id, collection_id)
);

-- Inter-artifact relationships
CREATE TABLE artifact_relationships (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_id    UUID NOT NULL REFERENCES artifacts(id) ON DELETE CASCADE,
    target_id    UUID NOT NULL REFERENCES artifacts(id) ON DELETE CASCADE,
    relationship VARCHAR(30) NOT NULL,
    confidence   REAL,
    created_by   VARCHAR(20) DEFAULT 'user',
    UNIQUE (source_id, target_id, relationship),
    CHECK (source_id != target_id)
);

-- Version history table
CREATE TABLE artifacts_history (
    history_id    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id            UUID NOT NULL,
    title         TEXT,
    description   TEXT,
    metadata      JSONB,
    version       INTEGER,
    sys_period_start TIMESTAMPTZ,
    sys_period_end TIMESTAMPTZ,
    change_type   VARCHAR(10),
    changed_fields TEXT[],
    recorded_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_history_artifact ON artifacts_history(id);
CREATE INDEX idx_history_period ON artifacts_history USING GIST(
    tstzrange(sys_period_start, sys_period_end)
);
