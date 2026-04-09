#!/bin/bash
# generate-deliverable.sh — Generate a deliverable from template
# Usage: ./generate-deliverable.sh <deliverable-id> <engagement-slug>
# Example: ./generate-deliverable.sh DLV-006 data-platform-modernisation

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../" && pwd)"
CONFIG_DIR="${REPO_ROOT}/delivery/_config"
TEMPLATES_DIR="${REPO_ROOT}/delivery/_templates"
ENGAGEMENTS_DIR="${REPO_ROOT}/engagements"

# ── Argument validation ────────────────────────────────────────────────────────
if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <deliverable-id> <engagement-slug>" >&2
  echo "Example: $0 DLV-006 data-platform-modernisation" >&2
  echo ""
  echo "Available deliverable IDs:"
  grep "^  - id:" "${CONFIG_DIR}/deliverables.yaml" | sed 's/.*id: /  /' | sed 's/"//g'
  exit 1
fi

DELIVERABLE_ID="$1"
ENGAGEMENT_SLUG="$2"
TODAY=$(date +%Y-%m-%d)

# ── Resolve engagement directory ───────────────────────────────────────────────
ENGAGEMENT_DIR="${ENGAGEMENTS_DIR}/${ENGAGEMENT_SLUG}"
if [[ ! -d "${ENGAGEMENT_DIR}" ]]; then
  echo "ERROR: Engagement not found: ${ENGAGEMENT_DIR}" >&2
  echo "  Run 'npm run delivery:init -- ${ENGAGEMENT_SLUG}' first." >&2
  exit 1
fi

ENGAGEMENT_YAML="${ENGAGEMENT_DIR}/engagement.yaml"
ENGAGEMENT_NAME=$(grep "^name:" "${ENGAGEMENT_YAML}" | head -1 | sed 's/^name: *//' | sed 's/"//g' | xargs)
ENGAGEMENT_ID=$(grep "^id:" "${ENGAGEMENT_YAML}" | head -1 | sed 's/^id: *//' | sed 's/"//g' | xargs)

# ── Look up deliverable in registry ───────────────────────────────────────────
DELIVERABLES_YAML="${CONFIG_DIR}/deliverables.yaml"

# Parse deliverable entry (basic YAML parsing without external tools)
FOUND=false
DELIVERABLE_NAME=""
DELIVERABLE_TEMPLATE=""
DELIVERABLE_PHASE=""
DELIVERABLE_CODE=""

in_deliverable=false
current_id=""

while IFS= read -r line; do
  if echo "${line}" | grep -q "^  - id:"; then
    current_id=$(echo "${line}" | sed 's/.*id: *//' | sed 's/"//g' | xargs)
    if [[ "${current_id}" == "${DELIVERABLE_ID}" ]]; then
      in_deliverable=true
      DELIVERABLE_CODE="${current_id}"
      FOUND=true
    else
      in_deliverable=false
    fi
  fi

  if [[ "${in_deliverable}" == "true" ]]; then
    if echo "${line}" | grep -q "^    name:"; then
      DELIVERABLE_NAME=$(echo "${line}" | sed 's/^    name: *//' | sed 's/"//g' | xargs)
    fi
    if echo "${line}" | grep -q "^    template:"; then
      DELIVERABLE_TEMPLATE=$(echo "${line}" | sed 's/^    template: *//' | sed 's/"//g' | xargs)
    fi
    if echo "${line}" | grep -q "^    phase:"; then
      DELIVERABLE_PHASE=$(echo "${line}" | sed 's/^    phase: *//' | sed 's/"//g' | xargs)
    fi
  fi
done < "${DELIVERABLES_YAML}"

if [[ "${FOUND}" != "true" ]]; then
  echo "ERROR: Deliverable '${DELIVERABLE_ID}' not found in registry." >&2
  echo "  Available IDs:"
  grep "^  - id:" "${DELIVERABLES_YAML}" | sed 's/.*id: /    /' | sed 's/"//g'
  exit 1
fi

# ── Map phase to directory ─────────────────────────────────────────────────────
case "${DELIVERABLE_PHASE}" in
  discover-envision)  PHASE_DIR="${ENGAGEMENT_DIR}/01-discover-envision" ;;
  design-implement)   PHASE_DIR="${ENGAGEMENT_DIR}/02-design-implement" ;;
  run-evolve)         PHASE_DIR="${ENGAGEMENT_DIR}/03-run-evolve" ;;
  *)                  PHASE_DIR="${ENGAGEMENT_DIR}/01-discover-envision" ;;
esac

mkdir -p "${PHASE_DIR}"

# ── Resolve template path ──────────────────────────────────────────────────────
TEMPLATE_FILE="${REPO_ROOT}/${DELIVERABLE_TEMPLATE}"
if [[ ! -f "${TEMPLATE_FILE}" ]]; then
  echo "ERROR: Template not found: ${TEMPLATE_FILE}" >&2
  exit 1
fi

# ── Generate output filename ───────────────────────────────────────────────────
TEMPLATE_BASENAME=$(basename "${TEMPLATE_FILE}")
OUTPUT_FILENAME="${ENGAGEMENT_SLUG}-${TEMPLATE_BASENAME}"
OUTPUT_PATH="${PHASE_DIR}/${OUTPUT_FILENAME}"

if [[ -f "${OUTPUT_PATH}" ]]; then
  echo "WARNING: Deliverable already exists: ${OUTPUT_PATH}"
  echo "  Use a unique filename to avoid overwriting. Appending date suffix."
  OUTPUT_PATH="${PHASE_DIR}/${ENGAGEMENT_SLUG}-${TODAY}-${TEMPLATE_BASENAME}"
fi

# ── Copy template and inject engagement frontmatter ──────────────────────────
cp "${TEMPLATE_FILE}" "${OUTPUT_PATH}"

# Update frontmatter fields using sed
sed -i "s|^engagement: \"\"|engagement: \"${ENGAGEMENT_SLUG}\"|" "${OUTPUT_PATH}"
sed -i "s|^last_updated: \"\"|last_updated: \"${TODAY}\"|" "${OUTPUT_PATH}"

echo "✓ Deliverable generated!"
echo "  ID:         ${DELIVERABLE_CODE}"
echo "  Name:       ${DELIVERABLE_NAME}"
echo "  Phase:      ${DELIVERABLE_PHASE}"
echo "  Output:     ${OUTPUT_PATH#${REPO_ROOT}/}"
echo ""
echo "Next: Open the file and fill in the engagement-specific details."
