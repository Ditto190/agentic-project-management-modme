# Copilot Instructions for APM Repository

Trust these instructions. Only search further if information here is incomplete or incorrect.

## Repository Summary

**Agentic Project Management (APM)** — An open-source CLI tool (`agentic-pm` on npm) and multi-agent workflow framework. The CLI installs AI assistant-specific "template bundles" (ZIP files containing prompts, guides, skills, and agents) into user project workspaces. Bundles are published as GitHub Releases and support six AI platforms: GitHub Copilot, Claude Code, Gemini CLI, Cursor, OpenCode, and Codex CLI.

- **Language:** JavaScript, ES Modules (`"type": "module"` — always use `import`/`export`, never `require`)
- **Runtime:** Node.js ≥18 (minimum per `package.json` `engines` field; CI and recommended development use 20.x)
- **Package manager:** npm
- **Repo size:** ~1.4 MB excluding `node_modules`/`dist`
- **No test suite** — there is no `test` script in `package.json`
- **No linter** — no ESLint or Prettier config present

## Build Instructions

**Always run `npm ci` before building** (installs all dependencies from `package-lock.json`).

```bash
npm ci               # install deps — run this first, every time
npm run build        # build all 6 platform bundles → dist/
npm run build:release  # same node command; in CI the VERSION env var is set to embed the release version into apm-release.json
```

Both `build` and `build:release` run `node build/index.js`. Build takes ~2 seconds and produces:
- `dist/copilot.zip`, `dist/claude.zip`, `dist/gemini.zip`, `dist/cursor.zip`, `dist/opencode.zip`, `dist/codex.zip`
- `dist/apm-release.json` (release manifest)

**`dist/` is gitignored** — never commit build artifacts.

Build output is clean: deletes and recreates `dist/` on each run. If the build fails, check `build/build-config.json` for target configuration and `templates/_standards/` for template rules.

## Validation

There is no test suite. Validate changes by:
1. Running `npm ci && npm run build` — must complete with `[SUCCESS] Build completed successfully!`
2. For CLI changes (`src/`): manually invoke `node src/index.js --help`

## CI / GitHub Workflow

One workflow: `.github/workflows/release-templates.yml`
- **Trigger:** Manual only (`workflow_dispatch`) — not on push or PR
- **Steps:** checkout → Node 20 setup → version determination → `npm ci` → `npm run build:release` → create GitHub Release with `dist/*.zip` and `dist/apm-release.json`

There are **no automated checks on pull requests** (no CI gates on PRs).

## Project Layout

```
.github/
  workflows/release-templates.yml  # Only CI workflow (manual trigger only)
build/                              # Build system (entry: build/index.js)
  build-config.json                 # 6 platform targets (id, bundleName, directories, format)
  core/     config.js, errors.js, constants.js
  generators/ archive.js (ZIP), manifest.js (apm-release.json)
  processors/ templates.js, frontmatter.js, placeholders.js
  utils/    files.js, logger.js
  _standards/BUILD.md               # Build system coding standards — read before editing build/
src/                                # CLI source (entry: src/index.js)
  commands/  init.js, custom.js, update.js, archive.js, add.js, remove.js, status.js
  core/      constants.js, errors.js, config.js (~/.apm/config.json), metadata.js (.apm/metadata.json)
  services/  github.js, releases.js, extractor.js, archive.js, cleanup.js
  ui/        logger.js, prompts.js
  schemas/   release.js (manifest validation)
  _standards/CLI.md                 # CLI coding standards — read before editing src/
templates/                          # Source templates (input to build system)
  commands/  apm-1-initiate-planner.md … apm-9-recover.md
  guides/    context-gathering.md, task-assignment.md, task-execution.md,
             task-logging.md, task-review.md, work-breakdown.md
  skills/    apm-communication/ (SKILL.md, bus-integration.md)
  agents/    apm-archive-explorer.md
  apm/       plan.md, spec.md, tracker.md, memory/index.md
  _standards/ WORKFLOW.md, TERMINOLOGY.md, STRUCTURE.md, WRITING.md (template authoring rules)
skills/                             # Standalone skills (not part of build output)
  apm-assist/SKILL.md
  apm-customization/SKILL.md
dist/                               # Build output — gitignored, never commit
```

## Architecture Notes

- **`build/`** and **`src/`** are independent JavaScript modules with separate logger instances (`build/utils/logger.js` vs `src/ui/logger.js`). Do not cross-import.
- **Template placeholders** (e.g., `{VERSION}`, `{ARGS}`, `{SKILL_PATH:name}`) are replaced per-target by `build/processors/placeholders.js`. See `build/_standards/BUILD.md` for the full placeholder list.
- **Template changes** follow top-down propagation: `templates/_standards/WORKFLOW.md` → `templates/commands/` → `templates/guides/` → `templates/skills/`
- **Error handling:** CLI uses `CLIError` (`src/core/errors.js`); build uses `BuildError` (`build/core/errors.js`). Always use factory methods (e.g., `CLIError.networkError(url, reason)`) rather than plain `new Error()`.
- **Async pattern:** Use `async/await` throughout; no Promise chains.
- **Output style:** Use `logger.info/success/warn/error()` — no `console.log` in commands, no emojis in output.
- **Global config:** `~/.apm/config.json` (custom repos). **Workspace state:** `.apm/metadata.json` (installed assistants, versions, file list).
- **Version filtering:** CLI v1.x only fetches v1.x.x releases from the official repo. Custom repos have no filtering.
