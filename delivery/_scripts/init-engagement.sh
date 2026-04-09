#!/bin/bash
# init-engagement.sh — Initialise a new engagement directory structure
# Usage: ./init-engagement.sh <engagement-name> [client-name]
# Example: ./init-engagement.sh "data-platform-modernisation" "Acme Corp"

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../" && pwd)"
ENGAGEMENTS_DIR="${REPO_ROOT}/engagements"
CONFIG_DIR="${REPO_ROOT}/delivery/_config"
TEMPLATES_DIR="${REPO_ROOT}/delivery/_templates"

# ── Argument validation ────────────────────────────────────────────────────────
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <engagement-name> [client-name]" >&2
  echo "Example: $0 data-platform-modernisation 'Acme Corp'" >&2
  exit 1
fi

ENGAGEMENT_NAME="$1"
CLIENT_NAME="${2:-Unknown Client}"

# Slugify the engagement name (lowercase, hyphens, no special chars)
SLUG=$(echo "${ENGAGEMENT_NAME}" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')
ENGAGEMENT_DIR="${ENGAGEMENTS_DIR}/${SLUG}"
CREATED_DATE=$(date +%Y-%m-%d)
ENGAGEMENT_ID="ENG-$(date +%Y%m%d)-$(echo "${SLUG}" | cut -c1-8 | tr '-' '_' | tr '[:lower:]' '[:upper:]')"

echo "Initialising engagement: ${ENGAGEMENT_NAME}"
echo "  Slug:   ${SLUG}"
echo "  Client: ${CLIENT_NAME}"
echo "  ID:     ${ENGAGEMENT_ID}"
echo "  Path:   ${ENGAGEMENT_DIR}"
echo ""

# ── Guard: do not overwrite existing engagement ────────────────────────────────
if [[ -d "${ENGAGEMENT_DIR}" ]]; then
  echo "ERROR: Engagement directory already exists: ${ENGAGEMENT_DIR}" >&2
  echo "  To re-initialise, remove the directory first." >&2
  exit 1
fi

# ── Create directory structure ─────────────────────────────────────────────────
mkdir -p \
  "${ENGAGEMENT_DIR}/01-discover-envision" \
  "${ENGAGEMENT_DIR}/02-design-implement" \
  "${ENGAGEMENT_DIR}/03-run-evolve" \
  "${ENGAGEMENT_DIR}/apm" \
  "${ENGAGEMENT_DIR}/apm/memory" \
  "${ENGAGEMENT_DIR}/inbox" \
  "${ENGAGEMENT_DIR}/meetings" \
  "${ENGAGEMENT_DIR}/decisions" \
  "${ENGAGEMENT_DIR}/status"

# ── Create .gitkeep placeholders ───────────────────────────────────────────────
touch \
  "${ENGAGEMENT_DIR}/apm/memory/.gitkeep" \
  "${ENGAGEMENT_DIR}/inbox/.gitkeep" \
  "${ENGAGEMENT_DIR}/meetings/.gitkeep" \
  "${ENGAGEMENT_DIR}/decisions/.gitkeep" \
  "${ENGAGEMENT_DIR}/status/.gitkeep"

# ── Create engagement.yaml ─────────────────────────────────────────────────────
cat > "${ENGAGEMENT_DIR}/engagement.yaml" <<YAML
# Engagement Metadata
id: "${ENGAGEMENT_ID}"
name: "${ENGAGEMENT_NAME}"
slug: "${SLUG}"
client: "${CLIENT_NAME}"
created: "${CREATED_DATE}"
status: active
current_phase: discover-envision
delivery_lead: ""
project_manager: ""
solution_architect: ""
commercial_model: ""
contract_reference: ""
start_date: ""
end_date: ""
budget: ""
tags: []
notes: ""
YAML

# ── Create _phase.yaml for each phase directory ────────────────────────────────
cat > "${ENGAGEMENT_DIR}/01-discover-envision/_phase.yaml" <<YAML
phase: discover-envision
phase_name: "Discover & Envision"
status: not-started
start_date: ""
end_date: ""
completion_percentage: 0
deliverables:
  - id: DLV-002
    name: Scope Definition Document
    status: not-started
  - id: DLV-003
    name: Project Scope Baseline
    status: not-started
  - id: DLV-004
    name: Work Breakdown Structure
    status: not-started
  - id: DLV-005
    name: Statement of Work
    status: not-started
  - id: DLV-006
    name: RAID Register
    status: not-started
  - id: DLV-010
    name: Requirements Plan
    status: not-started
  - id: DLV-011
    name: Delivery Approach Narrative
    status: not-started
  - id: DLV-012
    name: Estimation Model
    status: not-started
  - id: DLV-014
    name: Assumptions Log
    status: not-started
notes: ""
YAML

cat > "${ENGAGEMENT_DIR}/02-design-implement/_phase.yaml" <<YAML
phase: design-implement
phase_name: "Design & Implement"
status: not-started
start_date: ""
end_date: ""
completion_percentage: 0
deliverables:
  - id: DLV-007
    name: Governance Framework
    status: not-started
  - id: DLV-008
    name: Mobilisation Plan
    status: not-started
  - id: DLV-009
    name: Change Log
    status: not-started
  - id: DLV-013
    name: Financial Management Setup
    status: not-started
notes: ""
YAML

cat > "${ENGAGEMENT_DIR}/03-run-evolve/_phase.yaml" <<YAML
phase: run-evolve
phase_name: "Run & Evolve"
status: not-started
start_date: ""
end_date: ""
completion_percentage: 0
deliverables: []
notes: ""
YAML

# ── Copy templates into relevant phase directories ─────────────────────────────
echo "Copying templates..."
# Phase 1 templates
for tmpl in scope-definition.md project-scope.md wbs.md raid-register.md sow-template.md requirements-plan.md delivery-approach.md estimation-model.md assumptions-log.md; do
  if [[ -f "${TEMPLATES_DIR}/${tmpl}" ]]; then
    cp "${TEMPLATES_DIR}/${tmpl}" "${ENGAGEMENT_DIR}/01-discover-envision/${SLUG}-${tmpl}"
    echo "  Copied ${tmpl} → 01-discover-envision/"
  fi
done

# Phase 2 templates
for tmpl in governance-framework.md mobilisation-plan.md change-log.md financial-setup.md; do
  if [[ -f "${TEMPLATES_DIR}/${tmpl}" ]]; then
    cp "${TEMPLATES_DIR}/${tmpl}" "${ENGAGEMENT_DIR}/02-design-implement/${SLUG}-${tmpl}"
    echo "  Copied ${tmpl} → 02-design-implement/"
  fi
done

# ── Create APM files ───────────────────────────────────────────────────────────
cat > "${ENGAGEMENT_DIR}/apm/spec.md" <<MD
---
title: "${ENGAGEMENT_NAME} — Engagement Spec"
type: apm-spec
engagement: "${SLUG}"
date: "${CREATED_DATE}"
status: draft
tags:
  - apm
  - spec
---

# ${ENGAGEMENT_NAME} — Engagement Spec

## Objective
<!-- One clear sentence describing what success looks like for this engagement. -->

## Context
<!-- Client context, strategic drivers, and background. -->

## Scope Summary
<!-- High-level in-scope and out-of-scope items. Detailed scope in DLV-002. -->

## Key Constraints
<!-- Budget, timeline, technical, or organisational constraints. -->

## Key Stakeholders
<!-- List the 3-5 most important stakeholders and their interest in this engagement. -->

## Success Criteria
<!-- Measurable criteria by which engagement success will be assessed. -->

## Related Documents
- [[engagement.yaml]] — Engagement metadata
- [[apm/plan.md]] — Delivery plan
- [[apm/tracker.md]] — Task tracker
MD

cat > "${ENGAGEMENT_DIR}/apm/plan.md" <<MD
---
title: "${ENGAGEMENT_NAME} — Delivery Plan"
type: apm-plan
engagement: "${SLUG}"
date: "${CREATED_DATE}"
status: draft
tags:
  - apm
  - plan
---

# ${ENGAGEMENT_NAME} — Delivery Plan

## Phase 1: Discover & Envision

### Tasks
- [ ] Conduct stakeholder interviews
- [ ] Run scope definition workshops
- [ ] Produce Scope Definition Document (DLV-002)
- [ ] Establish RAID register (DLV-006)
- [ ] Draft SoW (DLV-005)
- [ ] Complete Assumptions Log (DLV-014)

## Phase 2: Design & Implement

### Tasks
- [ ] Finalise governance framework (DLV-007)
- [ ] Complete mobilisation plan (DLV-008)
- [ ] Set up change log (DLV-009)
- [ ] Set up financial tracking (DLV-013)

## Phase 3: Run & Evolve

### Tasks
- [ ] Transition planning
- [ ] Knowledge transfer
- [ ] Lessons learned
- [ ] Engagement close-out

## Notes
<!-- Add planning notes, decisions, and context here. -->
MD

cat > "${ENGAGEMENT_DIR}/apm/tracker.md" <<MD
---
title: "${ENGAGEMENT_NAME} — Task Tracker"
type: apm-tracker
engagement: "${SLUG}"
date: "${CREATED_DATE}"
status: active
tags:
  - apm
  - tracker
---

# ${ENGAGEMENT_NAME} — Task Tracker

## Active Tasks

| ID | Task | Owner | Phase | Due | Status |
|----|------|-------|-------|-----|--------|
| T-001 | Initialise engagement directory | | discover-envision | ${CREATED_DATE} | Done |

## Completed Tasks

| ID | Task | Owner | Completed Date |
|----|------|-------|---------------|
| | | | |

## Blocked Tasks

| ID | Task | Blocker | Owner | Raised Date |
|----|------|---------|-------|------------|
| | | | | |
MD

# ── Create README.md ───────────────────────────────────────────────────────────
cat > "${ENGAGEMENT_DIR}/README.md" <<MD
# ${ENGAGEMENT_NAME}

**Client:** ${CLIENT_NAME}  
**Engagement ID:** ${ENGAGEMENT_ID}  
**Created:** ${CREATED_DATE}  
**Status:** Active

## Quick Links

| Resource | Link |
|----------|------|
| Engagement Metadata | [engagement.yaml](engagement.yaml) |
| APM Spec | [apm/spec.md](apm/spec.md) |
| Delivery Plan | [apm/plan.md](apm/plan.md) |
| Task Tracker | [apm/tracker.md](apm/tracker.md) |
| RAID Register | [01-discover-envision/${SLUG}-raid-register.md](01-discover-envision/${SLUG}-raid-register.md) |
| Scope Definition | [01-discover-envision/${SLUG}-scope-definition.md](01-discover-envision/${SLUG}-scope-definition.md) |

## Phase Status

| Phase | Status | Completion |
|-------|--------|-----------|
| 01 Discover & Envision | Not Started | 0% |
| 02 Design & Implement | Not Started | 0% |
| 03 Run & Evolve | Not Started | 0% |

## Directory Structure

\`\`\`
${SLUG}/
├── engagement.yaml          # Engagement metadata
├── README.md                # This file
├── 01-discover-envision/    # Phase 1 deliverables
├── 02-design-implement/     # Phase 2 deliverables
├── 03-run-evolve/           # Phase 3 deliverables
├── apm/                     # APM plan, spec, tracker
│   └── memory/
├── inbox/                   # Drop raw notes here for classification
├── meetings/                # Classified meeting notes
├── decisions/               # Decision records
└── status/                  # Status reports
\`\`\`

## Inbox Usage

Drop \`.txt\` or \`.md\` files into the \`inbox/\` directory. Run the inbox classifier to auto-tag and move them:

\`\`\`bash
npm run delivery:inbox -- ${SLUG}
\`\`\`
MD

# ── Append to _catalogue.yaml ──────────────────────────────────────────────────
CATALOGUE="${ENGAGEMENTS_DIR}/_catalogue.yaml"
if [[ ! -f "${CATALOGUE}" ]]; then
  cat > "${CATALOGUE}" <<YAML
# Engagement Catalogue
# Auto-maintained by init-engagement.sh
engagements: []
YAML
fi

# Append the new engagement to the catalogue using a simple sed approach
# Insert before the end of the engagements list
CATALOGUE_ENTRY="  - id: \"${ENGAGEMENT_ID}\"
    name: \"${ENGAGEMENT_NAME}\"
    slug: \"${SLUG}\"
    client: \"${CLIENT_NAME}\"
    created: \"${CREATED_DATE}\"
    status: active
    path: \"engagements/${SLUG}\""

# If engagements list is empty, replace "engagements: []" with the entry
if grep -q "^engagements: \[\]" "${CATALOGUE}"; then
  sed -i "s|^engagements: \[\]|engagements:\n${CATALOGUE_ENTRY}|" "${CATALOGUE}"
else
  # Append to the end of the file
  echo "" >> "${CATALOGUE}"
  echo "${CATALOGUE_ENTRY}" >> "${CATALOGUE}"
fi

echo ""
echo "✓ Engagement initialised successfully!"
echo "  Directory: ${ENGAGEMENT_DIR}"
echo "  Catalogue: ${CATALOGUE}"
echo ""
echo "Next steps:"
echo "  1. Edit ${SLUG}/engagement.yaml to fill in team details"
echo "  2. Edit ${SLUG}/apm/spec.md to define the engagement objective"
echo "  3. Run 'npm run delivery:status' to update the portfolio dashboard"
