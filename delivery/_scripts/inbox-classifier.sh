#!/bin/bash
# inbox-classifier.sh — Rule-based inbox classifier
# Usage: ./inbox-classifier.sh <engagement-dir>
# Processes .txt and .md files in <engagement-dir>/inbox/
# Classifies them by type and adds YAML frontmatter

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../" && pwd)"

# ── Argument validation ────────────────────────────────────────────────────────
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <engagement-slug-or-path>" >&2
  echo "Example: $0 data-platform-modernisation" >&2
  exit 1
fi

INPUT="$1"

# Resolve engagement directory
if [[ -d "${INPUT}" ]]; then
  ENGAGEMENT_DIR="${INPUT}"
elif [[ -d "${REPO_ROOT}/engagements/${INPUT}" ]]; then
  ENGAGEMENT_DIR="${REPO_ROOT}/engagements/${INPUT}"
else
  echo "ERROR: Cannot find engagement directory: ${INPUT}" >&2
  exit 1
fi

INBOX_DIR="${ENGAGEMENT_DIR}/inbox"
MEETINGS_DIR="${ENGAGEMENT_DIR}/meetings"
DECISIONS_DIR="${ENGAGEMENT_DIR}/decisions"
STATUS_DIR="${ENGAGEMENT_DIR}/status"
TODAY=$(date +%Y-%m-%d)
NOW=$(date +%Y-%m-%dT%H:%M:%S)

mkdir -p "${MEETINGS_DIR}" "${DECISIONS_DIR}" "${STATUS_DIR}"

echo "Processing inbox: ${INBOX_DIR}"
echo ""

PROCESSED=0
FAILED=0

# ── Classification function ────────────────────────────────────────────────────
classify_file() {
  local filepath="$1"
  local filename
  filename=$(basename "${filepath}")
  local content
  content=$(cat "${filepath}" 2>/dev/null || echo "")
  local lower_content
  lower_content=$(echo "${content}" | tr '[:upper:]' '[:lower:]')
  local lower_name
  lower_name=$(echo "${filename}" | tr '[:upper:]' '[:lower:]')

  # Skip files that already have frontmatter
  if head -1 "${filepath}" | grep -q "^---"; then
    echo "  SKIP (has frontmatter): ${filename}"
    return 0
  fi

  local file_type="raw-note"
  local dest_dir="${INBOX_DIR}"
  local tags="raw-note"

  # ── Pattern matching for classification ──────────────────────────────────────
  # Meeting note: keywords suggest a meeting occurred
  if echo "${lower_content}" | grep -qE "(meeting|attendees|participants|agenda|minutes|action items|discussed|standup|stand-up|scrum|retro|retrospective)" || \
     echo "${lower_name}" | grep -qE "(meeting|minutes|standup|retro)"; then
    file_type="meeting-note"
    dest_dir="${MEETINGS_DIR}"
    tags="meeting-note"

  # Decision record: keywords suggest a decision was made
  elif echo "${lower_content}" | grep -qE "(decision:|decided|agreed|resolution:|we have decided|rationale:|options considered|option selected)" || \
       echo "${lower_name}" | grep -qE "(decision|adr|agreed)"; then
    file_type="decision-record"
    dest_dir="${DECISIONS_DIR}"
    tags="decision-record"

  # Risk entry: risk-related content
  elif echo "${lower_content}" | grep -qE "(risk:|risk identified|probability|impact|mitigation|likelihood|threat|vulnerability|risk register)" || \
       echo "${lower_name}" | grep -qE "(risk|raid)"; then
    file_type="risk-entry"
    dest_dir="${INBOX_DIR}"
    tags="risk-entry"

  # Status update: progress and status keywords
  elif echo "${lower_content}" | grep -qE "(status:|progress|completed|blockers?:|this week|last week|rag status|green|amber|red|on track|at risk|off track)" || \
       echo "${lower_name}" | grep -qE "(status|update|progress|weekly|monthly)"; then
    file_type="status-update"
    dest_dir="${STATUS_DIR}"
    tags="status-update"

  # Action item: actions and to-dos
  elif echo "${lower_content}" | grep -qE "(action:|to do:|todo:|next steps?:|actions?:|follow.?up|assigned to)" || \
       echo "${lower_name}" | grep -qE "(action|todo|tasks?)"; then
    file_type="action-item"
    dest_dir="${INBOX_DIR}"
    tags="action-item"
  fi

  # ── Build output filename ─────────────────────────────────────────────────────
  local base_name
  base_name=$(echo "${filename%.*}" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')
  local ext="${filename##*.}"
  [[ "${ext}" == "${filename}" ]] && ext="md"
  local out_filename="${TODAY}-${base_name}.md"
  local out_path="${dest_dir}/${out_filename}"

  # Guard against overwriting
  if [[ -f "${out_path}" ]]; then
    out_path="${dest_dir}/${TODAY}-${base_name}-$(date +%H%M%S).md"
  fi

  # ── Build title from filename ─────────────────────────────────────────────────
  local title
  title=$(echo "${base_name}" | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')

  # ── Write frontmatter + content ───────────────────────────────────────────────
  {
    echo "---"
    echo "title: \"${title}\""
    echo "type: ${file_type}"
    echo "date: \"${TODAY}\""
    echo "classified_at: \"${NOW}\""
    echo "classified_by: inbox-pipeline"
    echo "tags:"
    echo "  - ${tags}"
    echo "  - status:draft"
    echo "status: draft"
    echo "source_file: \"${filename}\""
    echo "---"
    echo ""
    cat "${filepath}"
  } > "${out_path}"

  # Remove original from inbox (move semantics)
  rm -f "${filepath}"

  echo "  [${file_type}] ${filename} → ${out_path#${ENGAGEMENT_DIR}/}"
  PROCESSED=$((PROCESSED + 1))
}

# ── Process all .txt and .md files in inbox ────────────────────────────────────
if [[ ! -d "${INBOX_DIR}" ]]; then
  echo "No inbox directory found at: ${INBOX_DIR}"
  exit 0
fi

FILE_COUNT=0
while IFS= read -r -d '' filepath; do
  FILE_COUNT=$((FILE_COUNT + 1))
  classify_file "${filepath}" || FAILED=$((FAILED + 1))
done < <(find "${INBOX_DIR}" -maxdepth 1 \( -name "*.txt" -o -name "*.md" \) -type f -print0 2>/dev/null)

if [[ ${FILE_COUNT} -eq 0 ]]; then
  echo "No files to process in inbox."
else
  echo ""
  echo "Done. Processed: ${PROCESSED}, Skipped/Failed: ${FAILED}"
fi
