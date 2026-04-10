# Artifact Management Database Setup

This guide walks you through setting up the production artifact management database for Supabase PostgreSQL.

## Overview

The artifact system provides:
- **Multi-tenant artifact storage** with JSONB metadata
- **Row-Level Security** for workspace-based access control
- **Hybrid search** (full-text + semantic) via pgvector
- **Version history** tracking with temporal tables
- **Type discrimination** for diverse content (papers, repos, URLs, etc.)

## Prerequisites

1. **Supabase Project** - Create a free project at https://supabase.com
2. **Node.js ≥18** - For running the CLI and migrations
3. **Environment Variables** - Copy `.env.example` to `.env.local` and fill in your Supabase credentials

## Phase 1: Initial Database Setup

### Step 1: Create Supabase Project

1. Go to https://supabase.com and create a new project
2. Save your project URL and API keys
3. Note the database connection string (visible in Database settings)

### Step 2: Set Environment Variables

```bash
# Copy the template
cp .env.example .env.local

# Fill in your Supabase credentials
export DATABASE_URL="postgresql://postgres:[password]@db.[project-id].supabase.co:5432/postgres"
export SUPABASE_URL="https://[project-id].supabase.co"
export SUPABASE_ANON_KEY="your-anon-key"
export SUPABASE_SERVICE_ROLE_KEY="your-service-role-key"
```

### Step 3: Run Database Migrations

```bash
# This applies the Prisma migrations (via supabase/migrations)
npx prisma migrate deploy

# Or for development with auto-creation:
npx prisma migrate dev --name init
```

### Step 4: Verify Schema

```bash
# Open Prisma Studio to view tables
npx prisma studio

# Or query directly in Supabase dashboard:
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';
```

## Phase 1: Using the Artifacts CLI

### Initialize Artifact Database

```bash
# Initialize with auto-generated workspace ID
apm artifacts init

# Or specify workspace ID
apm artifacts init --workspace f47ac10b-58cc-4372-a567-0e02b2c3d479
```

### Add Artifacts

```bash
# Add from file
apm artifacts add ./paper.pdf --title "My Research Paper" --tags "machine-learning,nlp"

# Add from URL
apm artifacts add https://arxiv.org/abs/2301.00000 --type research_paper

# Add entire directory
apm artifacts add ./documents/ --type note
```

### List Your Artifacts

```bash
# List all artifacts
apm artifacts list

# Filter by status
apm artifacts list --status reading

# Filter by type
apm artifacts list --type research_paper

# Limit results
apm artifacts list --limit 20
```

### Search Artifacts (Phase 2+)

```bash
# Full-text search
apm artifacts search "machine learning"

# With filters
apm artifacts search "neural networks" --type research_paper --limit 10
```

### Sync with Database

```bash
# Sync artifacts from .apm directory to Supabase
apm artifacts sync

# Dry run (see what would be synced)
apm artifacts sync --dry-run
```

## Database Schema Overview

### Core Tables

**`artifacts`** - Main artifact storage
- `id` (UUID) - Primary key
- `workspace_id` (UUID) - Multi-tenant isolation
- `artifact_type` (enum) - Type discrimination (paper, repo, URL, etc.)
- `status` (enum) - Workflow state (inbox, reading, completed, archived)
- `title`, `description` - Dublin Core fields
- `metadata` (JSONB) - Type-specific flexible fields
- `created_at`, `updated_at` - Audit timestamps
- `deleted_at` - Soft delete tracking

**`persons`** - Authors and contributors
- `id` (UUID)
- `full_name`, `orcid`, `affiliation`
- `metadata` (JSONB)

**`artifact_contributors`** - M2M junction for authors
- `artifact_id`, `person_id` (PKs)
- `role` (author, editor, translator, etc.)
- `position` (author order)

**`tags`** - Tagging system
- `id` (UUID)
- `name`, `slug` (unique)
- `color` (for UI)

**`artifact_tags`** - M2M junction for tags
- `artifact_id`, `tag_id` (PKs)
- `added_by` (user, ai, import)
- `confidence` (for AI-generated tags)

**`collections`** - Hierarchical organization
- `id` (UUID)
- `parent_id` (self-referencing for hierarchy)
- `position` (sort order)

**`artifact_relationships`** - Inter-artifact links
- `source_id`, `target_id` (UUIDs)
- `relationship` (enum: cites, references, supersedes, etc.)
- `confidence` (float, 0-1)

**`artifacts_history`** - Version tracking
- Mirrors artifact schema
- Tracks `sys_period_start`, `sys_period_end`
- Records `changed_fields` array

### Indexes

**Performance indexes:**
- `workspace_id` - For multi-tenant queries
- `artifact_type` - For type filtering
- `created_by` - For ownership verification
- `created_at DESC` - For recent-first sorting
- `search_vector GIN` - For full-text search
- `metadata JSONB` - For flexible field queries

## Row-Level Security (RLS)

RLS policies automatically enforce multi-tenant access control:

1. **Users read only artifacts in their workspace**
   - `workspace_id IN (SELECT user_workspace_ids())`

2. **Users create artifacts with their own user_id**
   - `created_by = auth.uid()`

3. **Users can only update/delete their own artifacts**
   - `created_by = auth.uid()`

4. **Storage policies mirror table policies**
   - Upload to workspace-specific folder paths

### Testing RLS

```bash
# View active policies
SELECT * FROM pg_policies WHERE schemaname = 'public';

# Check policy performance
EXPLAIN ANALYZE SELECT * FROM artifacts
WHERE workspace_id = '...' AND deleted_at IS NULL;
```

## Troubleshooting

### `PrismaClientInitializationError: Can't reach database server`

**Solution:** Check DATABASE_URL and ensure Supabase project is running
```bash
# Verify connection
psql $DATABASE_URL -c "SELECT 1"
```

### `Row-level security violation`

**Cause:** Query attempted to access artifact from different workspace

**Solution:** RLS policies are working correctly. Ensure you're using the correct workspace_id

### Migration fails with "relation already exists"

**Cause:** Schema already created from previous migration

**Solution:** Check migration status or reset database
```bash
npx prisma migrate status
npx prisma migrate reset  # WARNING: Deletes all data
```

### Slow queries on large datasets

**Solution:** Ensure indexes are created and analyze query plans
```bash
ANALYZE artifacts;
EXPLAIN ANALYZE SELECT * FROM artifacts WHERE workspace_id = '...';
```

## Advanced: Custom Configuration

### Connection Pooling

Edit `supabase/config.toml`:
```toml
[pooling]
enabled = true
max_pool_size = 20
min_pool_size = 5
mode = "transaction"
```

### Performance Tuning

For large artifact collections (>100K items):

1. **Increase work_mem** for complex queries
2. **Enable partial indexes** for soft-deletes
3. **Use CLUSTER** to optimize frequent access patterns
4. **Monitor query performance** with `pg_stat_statements`

### Custom Metadata Schema

Extend the `metadata JSONB` column for domain-specific fields:

```javascript
// Example: Research paper metadata
const paperMetadata = {
  journal: "Nature",
  volume: "123",
  issue: "4",
  pages: "45-67",
  conference: "ICML 2024",
  arxiv_id: "2301.00000",
  keywords: ["machine-learning", "transformers"],
  citations: 42,
  impact_factor: 42.5
};

await prisma.artifact.create({
  data: {
    title: "Attention Is All You Need",
    artifactType: "research_paper",
    metadata: paperMetadata
  }
});
```

## Next Steps: Phase 2

After Phase 1 is complete:

1. **Add Vector Embeddings** - Generate embeddings via OpenAI
2. **Implement Hybrid Search** - Combine full-text + semantic search via RRF
3. **Build Search UI** - Query artifacts with relevance ranking
4. **Track Query Performance** - Ensure <100ms response times

See `docs/PHASE_2_SEARCH.md` for details.

## Support & Resources

- **Supabase Docs:** https://supabase.com/docs
- **Prisma Docs:** https://www.prisma.io/docs
- **PostgreSQL pgvector:** https://github.com/pgvector/pgvector
- **RLS Best Practices:** https://makerkit.dev/blog/tutorials/supabase-rls-best-practices

---

**Status:** Phase 1 MVP ✅  
**Last Updated:** 2026-04-10  
**Branch:** `claude/artifact-db-design-t5Nhx`
