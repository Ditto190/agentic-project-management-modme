import * as fs from 'fs-extra';
import path from 'path';
import crypto from 'crypto';

/**
 * Artifact Sync Service
 * Synchronizes artifacts from local filesystem to Supabase database
 *
 * Features:
 * - Detect artifact type from file extension or content
 * - Calculate content hash for deduplication
 * - Extract metadata (title, description) from files
 * - Batch sync operations for performance
 * - Track sync state to avoid duplicates
 */

/**
 * Calculate SHA-256 hash of file content
 * Used for deduplication and integrity checking
 */
export async function calculateContentHash(filePath) {
  const content = await fs.readFile(filePath);
  return crypto.createHash('sha256').update(content).digest('hex');
}

/**
 * Extract artifact metadata from file
 * Looks for YAML frontmatter or comment blocks at the start of files
 */
export function extractMetadata(content, filePath) {
  const metadata = {
    title: path.basename(filePath, path.extname(filePath)),
    description: null,
    tags: [],
    publishedDate: null,
  };

  // Try to parse YAML frontmatter (markdown-style)
  const frontmatterMatch = content.match(/^---\n([\s\S]*?)\n---/);
  if (frontmatterMatch) {
    try {
      const fm = frontmatterMatch[1];
      const titleMatch = fm.match(/title:\s*["']?([^"\n]+)["']?/);
      const descMatch = fm.match(/description:\s*["']?([^"\n]+)["']?/);
      const tagsMatch = fm.match(/tags:\s*\[(.*?)\]/);

      if (titleMatch) metadata.title = titleMatch[1].trim();
      if (descMatch) metadata.description = descMatch[1].trim();
      if (tagsMatch) {
        metadata.tags = tagsMatch[1]
          .split(',')
          .map((t) => t.trim())
          .filter((t) => t);
      }
    } catch (e) {
      // Fallback to filename if parsing fails
    }
  }

  return metadata;
}

/**
 * Prepare artifact data for database insertion
 * Converts file metadata to database schema format
 */
export function prepareArtifactData(filePath, content, hash, workspaceId, userId) {
  const ext = path.extname(filePath).toLowerCase();
  const metadata = extractMetadata(content, filePath);

  // Auto-detect artifact type
  const typeMap = {
    '.pdf': 'research_paper',
    '.txt': 'note',
    '.md': 'note',
    '.json': 'note',
    '.py': 'code_repository',
    '.js': 'code_repository',
    '.ts': 'code_repository',
    '.zip': 'dataset',
    '.csv': 'dataset',
  };

  return {
    workspaceId,
    createdBy: userId,
    title: metadata.title,
    description: metadata.description,
    artifactType: typeMap[ext] || 'other',
    status: 'inbox',
    contentHash: hash,
    wordCount: content.split(/\s+/).length,
    plainTextContent: content.substring(0, 10000), // Store first 10K chars
    metadata: {
      originalPath: filePath,
      fileSize: content.length,
      fileType: ext,
      tags: metadata.tags,
      syncedAt: new Date().toISOString(),
    },
  };
}

/**
 * Sync artifacts from directory
 * Recursively finds and syncs artifact files
 */
export async function syncArtifactsFromDirectory(
  sourcePath,
  prismaClient,
  workspaceId,
  userId,
  options = {}
) {
  const {
    extensions = ['.pdf', '.txt', '.md', '.json', '.py', '.js'],
    dryRun = false,
    maxSize = 100 * 1024 * 1024, // 100MB
  } = options;

  const stats = {
    found: 0,
    synced: 0,
    skipped: 0,
    errors: 0,
    artifacts: [],
  };

  try {
    // Get all files recursively
    const files = await fs.readdir(sourcePath, { recursive: true });

    for (const file of files) {
      const fullPath = path.join(sourcePath, file);
      const stat = await fs.stat(fullPath);

      // Skip directories and large files
      if (stat.isDirectory() || stat.size > maxSize) {
        continue;
      }

      // Check file extension
      const ext = path.extname(file).toLowerCase();
      if (!extensions.includes(ext)) {
        continue;
      }

      stats.found++;

      try {
        const content = await fs.readFile(fullPath, 'utf-8');
        const hash = await calculateContentHash(fullPath);

        // Check if already exists (by content hash)
        if (!dryRun && prismaClient) {
          const existing = await prismaClient.artifact.findFirst({
            where: {
              contentHash: hash,
              workspaceId,
            },
          });

          if (existing) {
            stats.skipped++;
            continue;
          }
        }

        // Prepare data
        const artifactData = prepareArtifactData(
          fullPath,
          content,
          hash,
          workspaceId,
          userId
        );

        if (!dryRun && prismaClient) {
          // Create artifact in database
          const artifact = await prismaClient.artifact.create({
            data: artifactData,
          });
          stats.synced++;
          stats.artifacts.push({
            id: artifact.id,
            title: artifact.title,
            type: artifact.artifactType,
          });
        } else if (dryRun) {
          stats.synced++;
          stats.artifacts.push({
            title: artifactData.title,
            type: artifactData.artifactType,
          });
        }
      } catch (error) {
        console.error(`Error syncing ${file}: ${error.message}`);
        stats.errors++;
      }
    }
  } catch (error) {
    console.error(`Error reading directory: ${error.message}`);
  }

  return stats;
}

/**
 * Validate artifact integrity
 * Verifies content hash and database consistency
 */
export async function validateArtifactIntegrity(
  prismaClient,
  artifactId,
  expectedHash
) {
  const artifact = await prismaClient.artifact.findUnique({
    where: { id: artifactId },
  });

  if (!artifact) {
    return { valid: false, error: 'Artifact not found' };
  }

  if (artifact.contentHash !== expectedHash) {
    return {
      valid: false,
      error: 'Content hash mismatch',
      expected: expectedHash,
      actual: artifact.contentHash,
    };
  }

  return { valid: true };
}

/**
 * Deduplication: find duplicate artifacts by content hash
 */
export async function findDuplicateArtifacts(prismaClient, contentHash) {
  return prismaClient.artifact.findMany({
    where: { contentHash },
  });
}

/**
 * Merge duplicate artifacts
 * Keeps one artifact, redirects references from duplicates
 */
export async function mergeDuplicateArtifacts(
  prismaClient,
  primaryArtifactId,
  duplicateIds
) {
  const merged = { primary: primaryArtifactId, merged: 0, errors: 0 };

  for (const duplicateId of duplicateIds) {
    try {
      // Create relationship to primary artifact
      await prismaClient.artifactRelationship.create({
        data: {
          sourceId: duplicateId,
          targetId: primaryArtifactId,
          relationship: 'duplicate_of',
        },
      });

      // Soft delete duplicate
      await prismaClient.artifact.update({
        where: { id: duplicateId },
        data: { deletedAt: new Date() },
      });

      merged.merged++;
    } catch (error) {
      console.error(`Error merging duplicate: ${error.message}`);
      merged.errors++;
    }
  }

  return merged;
}

export default {
  calculateContentHash,
  extractMetadata,
  prepareArtifactData,
  syncArtifactsFromDirectory,
  validateArtifactIntegrity,
  findDuplicateArtifacts,
  mergeDuplicateArtifacts,
};
