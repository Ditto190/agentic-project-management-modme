-- Enable Row-Level Security on all artifact tables
ALTER TABLE artifacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE artifact_contributors ENABLE ROW LEVEL SECURITY;
ALTER TABLE artifact_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE artifact_collections ENABLE ROW LEVEL SECURITY;
ALTER TABLE artifact_relationships ENABLE ROW LEVEL SECURITY;
ALTER TABLE artifacts_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE collections ENABLE ROW LEVEL SECURITY;
ALTER TABLE persons ENABLE ROW LEVEL SECURITY;

-- Helper function to get user's workspace IDs
-- This function caches the auth.uid() result to avoid per-row function calls
CREATE OR REPLACE FUNCTION auth.user_workspace_ids()
RETURNS SETOF UUID LANGUAGE sql SECURITY DEFINER STABLE AS $$
    SELECT DISTINCT workspace_id FROM artifacts
    WHERE created_by = (SELECT auth.uid())
    UNION
    SELECT DISTINCT workspace_id FROM artifacts
    WHERE workspace_id IN (
        -- Future: Add workspace_members table for collaborative access
        SELECT workspace_id FROM artifacts WHERE created_by = (SELECT auth.uid())
    );
$$;

-- RLS Policy: Users can read their own artifacts
CREATE POLICY "Users can read artifacts in their workspace" ON artifacts
    FOR SELECT TO authenticated
    USING (
        workspace_id IN (SELECT auth.user_workspace_ids())
    );

-- RLS Policy: Users can insert artifacts to their workspace
CREATE POLICY "Users can create artifacts in their workspace" ON artifacts
    FOR INSERT TO authenticated
    WITH CHECK (
        created_by = (SELECT auth.uid())
    );

-- RLS Policy: Users can update their own artifacts
CREATE POLICY "Users can update their own artifacts" ON artifacts
    FOR UPDATE TO authenticated
    USING (
        created_by = (SELECT auth.uid()) AND
        workspace_id IN (SELECT auth.user_workspace_ids())
    )
    WITH CHECK (
        created_by = (SELECT auth.uid()) AND
        workspace_id IN (SELECT auth.user_workspace_ids())
    );

-- RLS Policy: Users can delete their own artifacts (soft delete)
CREATE POLICY "Users can delete their own artifacts" ON artifacts
    FOR DELETE TO authenticated
    USING (
        created_by = (SELECT auth.uid()) AND
        workspace_id IN (SELECT auth.user_workspace_ids())
    );

-- RLS Policies for artifact_contributors
CREATE POLICY "Users can read contributors of accessible artifacts" ON artifact_contributors
    FOR SELECT TO authenticated
    USING (
        artifact_id IN (
            SELECT id FROM artifacts WHERE workspace_id IN (SELECT auth.user_workspace_ids())
        )
    );

CREATE POLICY "Users can manage contributors of their artifacts" ON artifact_contributors
    FOR INSERT TO authenticated
    WITH CHECK (
        artifact_id IN (
            SELECT id FROM artifacts
            WHERE created_by = (SELECT auth.uid())
        )
    );

-- RLS Policies for artifact_tags
CREATE POLICY "Users can read tags of accessible artifacts" ON artifact_tags
    FOR SELECT TO authenticated
    USING (
        artifact_id IN (
            SELECT id FROM artifacts WHERE workspace_id IN (SELECT auth.user_workspace_ids())
        )
    );

CREATE POLICY "Users can manage tags on their artifacts" ON artifact_tags
    FOR INSERT TO authenticated
    WITH CHECK (
        artifact_id IN (
            SELECT id FROM artifacts
            WHERE created_by = (SELECT auth.uid())
        )
    );

-- RLS Policies for artifact_collections
CREATE POLICY "Users can read collections of accessible artifacts" ON artifact_collections
    FOR SELECT TO authenticated
    USING (
        artifact_id IN (
            SELECT id FROM artifacts WHERE workspace_id IN (SELECT auth.user_workspace_ids())
        )
    );

CREATE POLICY "Users can manage collections of their artifacts" ON artifact_collections
    FOR INSERT TO authenticated
    WITH CHECK (
        artifact_id IN (
            SELECT id FROM artifacts
            WHERE created_by = (SELECT auth.uid())
        )
    );

-- RLS Policies for artifact_relationships
CREATE POLICY "Users can read relationships of accessible artifacts" ON artifact_relationships
    FOR SELECT TO authenticated
    USING (
        source_id IN (
            SELECT id FROM artifacts WHERE workspace_id IN (SELECT auth.user_workspace_ids())
        ) OR
        target_id IN (
            SELECT id FROM artifacts WHERE workspace_id IN (SELECT auth.user_workspace_ids())
        )
    );

CREATE POLICY "Users can create relationships between their artifacts" ON artifact_relationships
    FOR INSERT TO authenticated
    WITH CHECK (
        source_id IN (
            SELECT id FROM artifacts WHERE created_by = (SELECT auth.uid())
        ) AND
        target_id IN (
            SELECT id FROM artifacts WHERE workspace_id IN (SELECT auth.user_workspace_ids())
        )
    );

-- RLS Policy for artifacts_history
CREATE POLICY "Users can read history of accessible artifacts" ON artifacts_history
    FOR SELECT TO authenticated
    USING (
        id IN (
            SELECT id FROM artifacts WHERE workspace_id IN (SELECT auth.user_workspace_ids())
        )
    );

-- Note: history is insert-only (via triggers), no direct user INSERT allowed
CREATE POLICY "System can record history" ON artifacts_history
    FOR INSERT TO service_role
    WITH CHECK (true);

-- Public read-only access for tags (can be customized)
CREATE POLICY "Tags are publicly readable" ON tags
    FOR SELECT
    USING (true);

-- Storage policies for Supabase Storage (artifact bucket)
-- Users can upload to their workspace folder
CREATE POLICY "Users can upload artifacts to workspace folder" ON storage.objects
    FOR INSERT TO authenticated
    WITH CHECK (
        bucket_id = 'artifacts' AND
        (storage.foldername(name))[1]::uuid IN (SELECT auth.user_workspace_ids())
    );

-- Users can read artifacts from their workspace
CREATE POLICY "Users can read artifacts from their workspace" ON storage.objects
    FOR SELECT TO authenticated
    USING (
        bucket_id = 'artifacts' AND
        (storage.foldername(name))[1]::uuid IN (SELECT auth.user_workspace_ids())
    );

-- Users can update their own artifact files
CREATE POLICY "Users can update their own artifact files" ON storage.objects
    FOR UPDATE TO authenticated
    USING (
        bucket_id = 'artifacts' AND
        (storage.foldername(name))[1]::uuid IN (SELECT auth.user_workspace_ids())
    )
    WITH CHECK (
        bucket_id = 'artifacts' AND
        (storage.foldername(name))[1]::uuid IN (SELECT auth.user_workspace_ids())
    );

-- Users can delete their own artifact files
CREATE POLICY "Users can delete their own artifact files" ON storage.objects
    FOR DELETE TO authenticated
    USING (
        bucket_id = 'artifacts' AND
        (storage.foldername(name))[1]::uuid IN (SELECT auth.user_workspace_ids())
    );
