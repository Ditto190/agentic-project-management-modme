/**
 * Row-Level Security (RLS) helper functions for Supabase
 * Provides utilities for implementing multi-tenant access control
 */

import { PrismaClient } from '@prisma/client';

/**
 * Context for RLS-aware database queries
 * Contains user ID and workspace ID
 */
export interface RLSContext {
  userId: string;
  workspaceId: string;
}

/**
 * Create a Prisma client with RLS context
 * Note: Actual RLS enforcement happens at the database level via policies
 * This context is useful for client-side validation and query building
 */
export function createRLSContext(
  userId: string,
  workspaceId: string
): RLSContext {
  if (!userId) {
    throw new Error('RLS Context: userId is required');
  }
  if (!workspaceId) {
    throw new Error('RLS Context: workspaceId is required');
  }

  return {
    userId,
    workspaceId,
  };
}

/**
 * Query only artifacts that belong to the user's workspace
 * Always filters by workspace_id as primary security measure
 * RLS policies on the database provide the enforcement layer
 */
export async function getWorkspaceArtifacts(
  prisma: PrismaClient,
  context: RLSContext,
  options?: {
    status?: string;
    type?: string;
    limit?: number;
  }
) {
  const { workspaceId } = context;

  return prisma.artifact.findMany({
    where: {
      workspaceId,
      deletedAt: null,
      ...(options?.status && { status: options.status as any }),
      ...(options?.type && { artifactType: options.type as any }),
    },
    take: options?.limit || 50,
    orderBy: {
      createdAt: 'desc',
    },
  });
}

/**
 * Get a single artifact with RLS checks
 * Verifies the artifact belongs to the user's workspace
 */
export async function getArtifactById(
  prisma: PrismaClient,
  context: RLSContext,
  artifactId: string
) {
  const { workspaceId } = context;

  const artifact = await prisma.artifact.findUnique({
    where: { id: artifactId },
    include: {
      contributors: {
        include: {
          person: true,
        },
      },
      tags: {
        include: {
          tag: true,
        },
      },
    },
  });

  // RLS check: verify artifact belongs to user's workspace
  if (!artifact) {
    return null;
  }

  if (artifact.workspaceId !== workspaceId) {
    throw new Error(
      'RLS Violation: Artifact does not belong to your workspace'
    );
  }

  return artifact;
}

/**
 * Create an artifact with RLS checks
 * Automatically sets workspace_id and created_by from context
 */
export async function createArtifactWithRLS(
  prisma: PrismaClient,
  context: RLSContext,
  data: {
    title: string;
    description?: string;
    artifactType: string;
    sourceUrl?: string;
    doi?: string;
    isbn?: string;
    metadata?: Record<string, any>;
  }
) {
  const { userId, workspaceId } = context;

  return prisma.artifact.create({
    data: {
      ...data,
      workspaceId,
      createdBy: userId,
      artifactType: data.artifactType as any,
    },
  });
}

/**
 * Update an artifact with RLS checks
 * Verifies the artifact belongs to the user's workspace
 * Only creator can update (can be extended to allow workspace admins)
 */
export async function updateArtifactWithRLS(
  prisma: PrismaClient,
  context: RLSContext,
  artifactId: string,
  data: {
    title?: string;
    description?: string;
    status?: string;
    metadata?: Record<string, any>;
  }
) {
  const { userId, workspaceId } = context;

  // Verify ownership
  const existing = await prisma.artifact.findUnique({
    where: { id: artifactId },
  });

  if (!existing) {
    throw new Error('Artifact not found');
  }

  if (existing.workspaceId !== workspaceId) {
    throw new Error(
      'RLS Violation: Artifact does not belong to your workspace'
    );
  }

  if (existing.createdBy !== userId) {
    throw new Error(
      'RLS Violation: Only the artifact creator can update it'
    );
  }

  return prisma.artifact.update({
    where: { id: artifactId },
    data: {
      ...data,
      status: data.status as any,
      updatedAt: new Date(),
    },
  });
}

/**
 * Delete an artifact (soft delete)
 * Sets deleted_at timestamp instead of removing row
 */
export async function deleteArtifactWithRLS(
  prisma: PrismaClient,
  context: RLSContext,
  artifactId: string
) {
  const { userId, workspaceId } = context;

  const existing = await prisma.artifact.findUnique({
    where: { id: artifactId },
  });

  if (!existing) {
    throw new Error('Artifact not found');
  }

  if (existing.workspaceId !== workspaceId) {
    throw new Error(
      'RLS Violation: Artifact does not belong to your workspace'
    );
  }

  if (existing.createdBy !== userId) {
    throw new Error(
      'RLS Violation: Only the artifact creator can delete it'
    );
  }

  return prisma.artifact.update({
    where: { id: artifactId },
    data: {
      deletedAt: new Date(),
    },
  });
}

/**
 * Validate RLS context
 * Useful for middleware and guard functions
 */
export function validateRLSContext(context: RLSContext): void {
  if (!context.userId || typeof context.userId !== 'string') {
    throw new Error('Invalid RLS Context: userId must be a non-empty string');
  }

  if (!context.workspaceId || typeof context.workspaceId !== 'string') {
    throw new Error(
      'Invalid RLS Context: workspaceId must be a non-empty string'
    );
  }
}
