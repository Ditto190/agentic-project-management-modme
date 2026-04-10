import { PrismaClient } from '@prisma/client';

/**
 * Database client factory for PostgreSQL/Supabase
 * Handles connection pooling and multi-environment setup
 */

let prismaInstance: PrismaClient | null = null;

/**
 * Get or create a Prisma client instance
 * Reuses the same connection across the application
 */
export function getPrismaClient(): PrismaClient {
  if (!prismaInstance) {
    prismaInstance = new PrismaClient({
      log:
        process.env.NODE_ENV === 'development'
          ? ['query', 'error', 'warn']
          : ['error'],
    });
  }
  return prismaInstance;
}

/**
 * Close the database connection
 * Call this before process exit in CLI/serverless
 */
export async function closePrismaClient(): Promise<void> {
  if (prismaInstance) {
    await prismaInstance.$disconnect();
    prismaInstance = null;
  }
}

/**
 * Initialize Prisma client with optional logging
 * Useful for debugging connection issues
 */
export function initializePrismaClient(verbose = false): PrismaClient {
  const client = getPrismaClient();

  if (verbose) {
    client.$on('query', (e) => {
      console.log('[Prisma Query]', e.query);
      console.log('[Duration]', `${e.duration}ms`);
    });
  }

  return client;
}

export default getPrismaClient;
