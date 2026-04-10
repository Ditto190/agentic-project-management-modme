/**
 * Tests for Artifact Database Operations
 *
 * Note: These tests require a running PostgreSQL/Supabase instance
 * Set DATABASE_URL environment variable before running tests
 *
 * Run: npm test -- tests/artifacts.test.js
 */

import { describe, it, before, after, expect } from '@jest/globals';
import { getPrismaClient, closePrismaClient } from '../src/db/client.js';
import {
  createRLSContext,
  validateRLSContext,
  createArtifactWithRLS,
  getArtifactById,
  getWorkspaceArtifacts,
  updateArtifactWithRLS,
  deleteArtifactWithRLS,
} from '../src/lib/rls.js';

describe('Artifact Database Operations', () => {
  let prisma;
  let testContext;
  let testArtifactId;

  // Test data
  const TEST_USER_ID = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';
  const TEST_WORKSPACE_ID = 'f47ac10b-58cc-4372-a567-0e02b2c3d480';

  before(() => {
    if (!process.env.DATABASE_URL) {
      console.warn(
        'Skipping tests: DATABASE_URL not set. Set it to run artifact tests.'
      );
      return;
    }
    prisma = getPrismaClient();
    testContext = createRLSContext(TEST_USER_ID, TEST_WORKSPACE_ID);
  });

  after(async () => {
    if (prisma) {
      await closePrismaClient();
    }
  });

  describe('RLS Context', () => {
    it('should create valid RLS context', () => {
      const context = createRLSContext(TEST_USER_ID, TEST_WORKSPACE_ID);
      expect(context.userId).toBe(TEST_USER_ID);
      expect(context.workspaceId).toBe(TEST_WORKSPACE_ID);
    });

    it('should validate RLS context', () => {
      expect(() => validateRLSContext(testContext)).not.toThrow();
    });

    it('should reject invalid context with missing userId', () => {
      expect(() => {
        createRLSContext('', TEST_WORKSPACE_ID);
      }).toThrow();
    });

    it('should reject invalid context with missing workspaceId', () => {
      expect(() => {
        createRLSContext(TEST_USER_ID, '');
      }).toThrow();
    });
  });

  describe('Artifact CRUD Operations', () => {
    it('should create artifact', async () => {
      if (!prisma) return;

      const artifact = await createArtifactWithRLS(prisma, testContext, {
        title: 'Test Research Paper',
        description: 'A test artifact for unit tests',
        artifactType: 'research_paper',
        sourceUrl: 'https://example.com/paper.pdf',
        metadata: { keywords: ['test', 'research'] },
      });

      expect(artifact).toBeDefined();
      expect(artifact.title).toBe('Test Research Paper');
      expect(artifact.workspaceId).toBe(TEST_WORKSPACE_ID);
      expect(artifact.createdBy).toBe(TEST_USER_ID);

      testArtifactId = artifact.id;
    });

    it('should retrieve artifact by ID', async () => {
      if (!prisma || !testArtifactId) return;

      const artifact = await getArtifactById(
        prisma,
        testContext,
        testArtifactId
      );

      expect(artifact).toBeDefined();
      expect(artifact.id).toBe(testArtifactId);
      expect(artifact.title).toBe('Test Research Paper');
    });

    it('should list artifacts in workspace', async () => {
      if (!prisma) return;

      const artifacts = await getWorkspaceArtifacts(prisma, testContext);

      expect(Array.isArray(artifacts)).toBe(true);
      expect(artifacts.length).toBeGreaterThan(0);
      expect(artifacts.every((a) => a.workspaceId === TEST_WORKSPACE_ID)).toBe(
        true
      );
    });

    it('should update artifact', async () => {
      if (!prisma || !testArtifactId) return;

      const updated = await updateArtifactWithRLS(
        prisma,
        testContext,
        testArtifactId,
        {
          status: 'reading',
          description: 'Updated description',
        }
      );

      expect(updated.status).toBe('reading');
      expect(updated.description).toBe('Updated description');
    });

    it('should delete artifact (soft delete)', async () => {
      if (!prisma || !testArtifactId) return;

      const deleted = await deleteArtifactWithRLS(
        prisma,
        testContext,
        testArtifactId
      );

      expect(deleted.deletedAt).toBeDefined();
    });
  });

  describe('RLS Policy Enforcement', () => {
    it('should prevent access to artifacts from different workspace', async () => {
      if (!prisma) return;

      const otherContext = createRLSContext(
        TEST_USER_ID,
        'f47ac10b-58cc-4372-a567-0e02b2c3d481' // Different workspace
      );

      const artifact = await createArtifactWithRLS(prisma, testContext, {
        title: 'Private Artifact',
        artifactType: 'note',
      });

      expect(() =>
        getArtifactById(prisma, otherContext, artifact.id)
      ).rejects.toThrow(/does not belong to your workspace/);
    });

    it('should prevent non-creators from updating artifacts', async () => {
      if (!prisma) return;

      const artifact = await createArtifactWithRLS(prisma, testContext, {
        title: 'Creator Protected Artifact',
        artifactType: 'note',
      });

      const otherUserContext = createRLSContext(
        'other-user-id',
        TEST_WORKSPACE_ID
      );

      expect(() =>
        updateArtifactWithRLS(prisma, otherUserContext, artifact.id, {
          status: 'completed',
        })
      ).rejects.toThrow(/Only the artifact creator can update it/);
    });

    it('should prevent non-creators from deleting artifacts', async () => {
      if (!prisma) return;

      const artifact = await createArtifactWithRLS(prisma, testContext, {
        title: 'Delete Protected Artifact',
        artifactType: 'note',
      });

      const otherUserContext = createRLSContext(
        'other-user-id',
        TEST_WORKSPACE_ID
      );

      expect(() =>
        deleteArtifactWithRLS(prisma, otherUserContext, artifact.id)
      ).rejects.toThrow(/Only the artifact creator can delete it/);
    });
  });

  describe('Artifact Metadata (JSONB)', () => {
    it('should store and retrieve metadata', async () => {
      if (!prisma) return;

      const metadata = {
        journal: 'Nature',
        volume: '123',
        issue: '4',
        pages: '45-67',
        keywords: ['machine learning', 'neural networks'],
        citations: 42,
      };

      const artifact = await createArtifactWithRLS(prisma, testContext, {
        title: 'Test Paper with Metadata',
        artifactType: 'research_paper',
        metadata,
      });

      expect(artifact.metadata).toEqual(metadata);
    });

    it('should handle complex nested metadata', async () => {
      if (!prisma) return;

      const metadata = {
        repository: {
          owner: 'user',
          name: 'test-repo',
          url: 'https://github.com/user/test-repo',
        },
        stats: {
          stars: 100,
          forks: 20,
          issues: 5,
        },
        languages: {
          TypeScript: 45,
          JavaScript: 30,
          Python: 25,
        },
      };

      const artifact = await createArtifactWithRLS(prisma, testContext, {
        title: 'GitHub Repository',
        artifactType: 'code_repository',
        metadata,
      });

      expect(artifact.metadata.repository.owner).toBe('user');
      expect(artifact.metadata.stats.stars).toBe(100);
    });
  });

  describe('Artifact Soft Delete', () => {
    it('should soft delete artifacts', async () => {
      if (!prisma) return;

      const artifact = await createArtifactWithRLS(prisma, testContext, {
        title: 'To Be Deleted',
        artifactType: 'note',
      });

      const id = artifact.id;
      await deleteArtifactWithRLS(prisma, testContext, id);

      const deleted = await prisma.artifact.findUnique({
        where: { id },
      });

      expect(deleted).toBeDefined();
      expect(deleted.deletedAt).not.toBeNull();
    });

    it('should not return soft-deleted artifacts in queries', async () => {
      if (!prisma) return;

      await createArtifactWithRLS(prisma, testContext, {
        title: 'Hidden Artifact',
        artifactType: 'note',
      });

      const artifacts = await getWorkspaceArtifacts(prisma, testContext);

      const hasDeleted = artifacts.some((a) => a.deletedAt !== null);
      expect(hasDeleted).toBe(false);
    });
  });

  describe('Artifact Status Transitions', () => {
    const statuses = ['inbox', 'reading', 'completed', 'archived', 'reference'];

    statuses.forEach((status) => {
      it(`should support ${status} status`, async () => {
        if (!prisma) return;

        const artifact = await createArtifactWithRLS(prisma, testContext, {
          title: `Test ${status}`,
          artifactType: 'note',
          status: status,
        });

        expect(artifact.status).toBe(status);
      });
    });
  });

  describe('Artifact Types', () => {
    const types = [
      'research_paper',
      'white_paper',
      'url_bookmark',
      'code_repository',
      'note',
      'book',
      'dataset',
      'presentation',
      'video',
      'podcast',
      'other',
    ];

    types.forEach((type) => {
      it(`should support ${type} artifact type`, async () => {
        if (!prisma) return;

        const artifact = await createArtifactWithRLS(prisma, testContext, {
          title: `Test ${type}`,
          artifactType: type,
        });

        expect(artifact.artifactType).toBe(type);
      });
    });
  });
});
