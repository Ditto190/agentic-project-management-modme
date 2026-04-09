#!/bin/bash
# validate-frontmatter.sh — Validate YAML frontmatter in Markdown files
# Walks all .md files in engagements/ and knowledge/
# Confirms they start with --- and contain title, type, date, tags, status
# Exit non-zero on failure

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../" && pwd)"

ERRORS=0
WARNINGS=0
CHECKED=0
SKIPPED=0

REQUIRED_FIELDS=("title" "type" "date" "tags" "status")

echo "Validating frontmatter in Markdown files..."
echo ""

check_file() {
  local filepath="$1"
  local rel_path="${filepath#${REPO_ROOT}/}"
  local file_errors=0

  # Check if file starts with ---
  if ! head -1 "${filepath}" | grep -q "^---"; then
    echo "  [ERROR] Missing frontmatter: ${rel_path}"
    ERRORS=$((ERRORS + 1))
    return
  fi

  # Extract frontmatter block (between first and second ---)
  local frontmatter
  frontmatter=$(awk '/^---/{n++; if(n==2) exit} n==1 && !/^---/{print}' "${filepath}")

  # Check required fields
  for field in "${REQUIRED_FIELDS[@]}"; do
    if ! echo "${frontmatter}" | grep -q "^${field}:"; then
      echo "  [WARN] Missing field '${field}': ${rel_path}"
      WARNINGS=$((WARNINGS + 1))
      file_errors=$((file_errors + 1))
    fi
  done

  # Check status is a valid value
  local status
  status=$(echo "${frontmatter}" | grep "^status:" | head -1 | sed 's/^status: *//' | sed 's/"//g' | xargs)
  if [[ -n "${status}" ]]; then
    case "${status}" in
      draft|in-review|approved|superseded|active|not-started|completed|cancelled) ;;
      *)
        echo "  [WARN] Unknown status value '${status}': ${rel_path}"
        WARNINGS=$((WARNINGS + 1))
        ;;
    esac
  fi

  CHECKED=$((CHECKED + 1))
}

# ── Scan directories ───────────────────────────────────────────────────────────
for scan_dir in "engagements" "knowledge"; do
  target="${REPO_ROOT}/${scan_dir}"
  if [[ ! -d "${target}" ]]; then
    echo "  [INFO] Directory not found, skipping: ${scan_dir}"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  while IFS= read -r -d '' filepath; do
    # Skip .gitkeep and binary files
    [[ "${filepath}" == *".gitkeep" ]] && continue

    check_file "${filepath}"
  done < <(find "${target}" -name "*.md" -type f -print0 2>/dev/null)
done

# ── Summary ────────────────────────────────────────────────────────────────────
echo ""
echo "Frontmatter validation complete."
echo "  Files checked: ${CHECKED}"
echo "  Warnings:      ${WARNINGS}"
echo "  Errors:        ${ERRORS}"

if [[ ${ERRORS} -gt 0 ]]; then
  echo ""
  echo "FAILED: ${ERRORS} file(s) have missing or invalid frontmatter."
  exit 1
fi

if [[ ${WARNINGS} -gt 0 ]]; then
  echo ""
  echo "Completed with ${WARNINGS} warning(s)."
  exit 0
fi

echo ""
echo "All files passed frontmatter validation."
