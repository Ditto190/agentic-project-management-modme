---
name: generate-deliverable
description: "Command to generate a deliverable document from the ADMS template library."
allowed-tools:
  - read-file
  - write-file
  - run-script
---

# Command: Generate Deliverable

## Purpose

Generate a deliverable document from the ADMS template library, pre-populated with engagement context.

## Via Script (Recommended)

```bash
npm run delivery:init -- <deliverable-id> <engagement-slug>
# or directly:
bash delivery/_scripts/generate-deliverable.sh DLV-006 my-engagement
```

## Via AI Assistant

```
@worker-agent Generate deliverable DLV-006 for engagement <slug>.

Please:
1. Run: bash delivery/_scripts/generate-deliverable.sh DLV-006 <slug>
2. Open the generated file
3. Using the context from engagement.yaml and apm/spec.md, fill in:
   - All frontmatter fields (author, last_updated, engagement)
   - Section 1: Executive summary based on spec.md
   - Any risks already identified from inbox notes
4. Set status to "draft"
5. Update apm/tracker.md to note this deliverable is in progress
```

## Available Deliverables

| ID | Name | Template |
|----|------|----------|
| DLV-001 | Feasibility Assessment Report | scope-definition.md |
| DLV-002 | Scope Definition Document | scope-definition.md |
| DLV-003 | Project Scope Baseline | project-scope.md |
| DLV-004 | Work Breakdown Structure | wbs.md |
| DLV-005 | Statement of Work | sow-template.md |
| DLV-006 | RAID Register | raid-register.md |
| DLV-007 | Governance Framework | governance-framework.md |
| DLV-008 | Mobilisation Plan | mobilisation-plan.md |
| DLV-009 | Change Log | change-log.md |
| DLV-010 | Requirements Plan | requirements-plan.md |
| DLV-011 | Delivery Approach Narrative | delivery-approach.md |
| DLV-012 | Estimation Model | estimation-model.md |
| DLV-013 | Financial Management Setup | financial-setup.md |
| DLV-014 | Assumptions Log | assumptions-log.md |
