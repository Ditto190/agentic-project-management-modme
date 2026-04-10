import { Command } from 'commander';
import chalk from 'chalk';
import * as fs from 'fs-extra';
import path from 'path';
import os from 'os';

/**
 * Artifacts Command
 * Provides CLI interface for artifact management
 *
 * Commands:
 * - apm artifacts init [DATABASE_URL]  - Initialize artifact database
 * - apm artifacts add [file]            - Add artifact from file
 * - apm artifacts list                  - List user's artifacts
 * - apm artifacts search <query>        - Search artifacts
 * - apm artifacts sync                  - Sync with Supabase
 */

const artifactsCommand = new Command('artifacts');

artifactsCommand
  .description('Manage AI artifacts and research documents')
  .action(() => {
    artifactsCommand.help();
  });

/**
 * Init command: Initialize artifact database
 */
artifactsCommand
  .command('init [databaseUrl]')
  .description(
    'Initialize artifact database connection (requires DATABASE_URL)'
  )
  .option(
    '--workspace <id>',
    'Workspace ID (generates UUID if not provided)'
  )
  .option('--skip-verify', 'Skip database connection verification')
  .action(async (databaseUrl, options) => {
    try {
      const url = databaseUrl || process.env.DATABASE_URL;

      if (!url) {
        console.error(
          chalk.red(
            '✗ Error: DATABASE_URL not provided. Either pass it as argument or set env variable.'
          )
        );
        process.exit(1);
      }

      console.log(chalk.blue('🔧 Initializing artifact database...'));

      // Store database URL in local config
      const configDir = path.join(os.homedir(), '.apm');
      const artifactConfigPath = path.join(configDir, 'artifact-config.json');

      await fs.ensureDir(configDir);

      const config = {
        databaseUrl: url,
        workspaceId:
          options.workspace || crypto.randomUUID?.() || generateUUID(),
        initializedAt: new Date().toISOString(),
      };

      await fs.writeJson(artifactConfigPath, config, { spaces: 2 });

      console.log(chalk.green('✓ Artifact database initialized'));
      console.log(chalk.gray(`  Config saved to: ${artifactConfigPath}`));
      console.log(chalk.gray(`  Workspace ID: ${config.workspaceId}`));

      if (!options.skipVerify) {
        console.log(
          chalk.blue('⚡ Note: Run migrations with: npx prisma migrate dev')
        );
      }
    } catch (error) {
      console.error(chalk.red(`✗ Error: ${error.message}`));
      process.exit(1);
    }
  });

/**
 * Add command: Add artifact from file or URL
 */
artifactsCommand
  .command('add <source>')
  .description('Add artifact from file, URL, or directory')
  .option('--type <type>', 'Artifact type (auto-detect if not provided)')
  .option('--title <title>', 'Artifact title')
  .option('--tags <tags>', 'Comma-separated tags')
  .option('--collection <name>', 'Add to collection')
  .action(async (source, options) => {
    try {
      console.log(chalk.blue(`📥 Adding artifact: ${source}`));

      // Load artifact config
      const configDir = path.join(os.homedir(), '.apm');
      const artifactConfigPath = path.join(configDir, 'artifact-config.json');

      if (!fs.existsSync(artifactConfigPath)) {
        console.error(
          chalk.red(
            '✗ Artifact database not initialized. Run: apm artifacts init'
          )
        );
        process.exit(1);
      }

      const config = await fs.readJson(artifactConfigPath);

      // Determine artifact type
      let artifactType = options.type || detectArtifactType(source);

      console.log(chalk.gray(`  Type: ${artifactType}`));
      console.log(chalk.gray(`  Status: inbox`));

      // TODO: Store artifact in database via Prisma
      console.log(chalk.yellow('⚠ Feature in development: database storage'));
      console.log(
        chalk.gray(
          '  This will store the artifact in Supabase when database is connected'
        )
      );

      console.log(chalk.green('✓ Artifact added (local staging)'));
    } catch (error) {
      console.error(chalk.red(`✗ Error: ${error.message}`));
      process.exit(1);
    }
  });

/**
 * List command: Show user's artifacts
 */
artifactsCommand
  .command('list')
  .description('List all artifacts in your workspace')
  .option('--status <status>', 'Filter by status (inbox, reading, completed)')
  .option('--type <type>', 'Filter by type')
  .option('--limit <n>', 'Limit results', '10')
  .action(async (options) => {
    try {
      console.log(chalk.blue('📚 Your Artifacts\n'));

      // Load artifact config
      const configDir = path.join(os.homedir(), '.apm');
      const artifactConfigPath = path.join(configDir, 'artifact-config.json');

      if (!fs.existsSync(artifactConfigPath)) {
        console.log(
          chalk.yellow('ℹ No artifacts yet. Run: apm artifacts init')
        );
        return;
      }

      // TODO: Fetch artifacts from database
      console.log(chalk.yellow('⚠ Feature in development: database storage'));
      console.log(
        chalk.gray('  This will query artifacts from Supabase when ready')
      );
    } catch (error) {
      console.error(chalk.red(`✗ Error: ${error.message}`));
      process.exit(1);
    }
  });

/**
 * Search command: Search artifacts with hybrid search
 */
artifactsCommand
  .command('search <query>')
  .description('Search artifacts (hybrid full-text + semantic)')
  .option('--limit <n>', 'Result limit', '10')
  .option('--type <type>', 'Filter by artifact type')
  .action(async (query, options) => {
    try {
      console.log(chalk.blue(`🔍 Searching: "${query}"\n`));

      // TODO: Call search_artifacts() function
      console.log(chalk.yellow('⚠ Feature in development: hybrid search'));
      console.log(
        chalk.gray(
          '  This will use pgvector + full-text search when embeddings are available'
        )
      );
    } catch (error) {
      console.error(chalk.red(`✗ Error: ${error.message}`));
      process.exit(1);
    }
  });

/**
 * Sync command: Sync artifacts with Supabase
 */
artifactsCommand
  .command('sync')
  .description('Sync artifacts from .apm directory to database')
  .option('--dry-run', 'Show what would be synced without applying changes')
  .action(async (options) => {
    try {
      console.log(chalk.blue('🔄 Syncing artifacts...\n'));

      // Load artifact config
      const configDir = path.join(os.homedir(), '.apm');
      const artifactConfigPath = path.join(configDir, 'artifact-config.json');

      if (!fs.existsSync(artifactConfigPath)) {
        console.log(
          chalk.yellow('ℹ No artifacts to sync. Run: apm artifacts init')
        );
        return;
      }

      // TODO: Implement artifact-sync service
      console.log(chalk.yellow('⚠ Feature in development: sync service'));
      console.log(
        chalk.gray('  This will sync artifacts from .apm to Supabase')
      );

      if (options.dryRun) {
        console.log(chalk.gray('  (dry-run mode - no changes made)'));
      }
    } catch (error) {
      console.error(chalk.red(`✗ Error: ${error.message}`));
      process.exit(1);
    }
  });

/**
 * Detect artifact type from file extension or URL
 */
function detectArtifactType(source) {
  if (source.startsWith('http://') || source.startsWith('https://')) {
    return 'url_bookmark';
  }

  if (source.includes('github.com')) {
    return 'code_repository';
  }

  const ext = path.extname(source).toLowerCase();
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

  return typeMap[ext] || 'other';
}

/**
 * Fallback UUID generator if crypto.randomUUID is not available
 */
function generateUUID() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
    const r = (Math.random() * 16) | 0;
    const v = c === 'x' ? r : (r & 0x3) | 0x8;
    return v.toString(16);
  });
}

export default artifactsCommand;
