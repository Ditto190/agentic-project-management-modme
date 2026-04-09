---
name: review-gate
description: "Command to conduct a phase gate review before transitioning to the next phase."
allowed-tools:
  - read-file
  - write-file
---

# Command: Review Gate

## Purpose

Conduct a phase gate review to confirm all exit criteria are met before transitioning to the next delivery phase.

## Invocation

```
@manager-agent Conduct a phase gate review for engagement <slug> — transitioning from <current-phase> to <next-phase>.

Please:
1. Check all exit criteria from delivery/_config/methodology.yaml
2. Verify all required deliverables are approved
3. Review the RAID register for any blocking items
4. Produce a gate review summary in status/<date>-gate-review-<phase>.md
5. Update engagement.yaml with the new current_phase if gate is passed
```

## Gate Review Checklist

### Phase 1 (Discover & Envision) Exit

- [ ] Scope definition document approved (DLV-002)
- [ ] Project scope baseline agreed (DLV-003)
- [ ] WBS produced (DLV-004)
- [ ] SoW agreed or in final review (DLV-005)
- [ ] RAID register established (DLV-006)
- [ ] Assumptions log complete (DLV-014)
- [ ] Delivery approach agreed (DLV-011)
- [ ] No critical unmitigated risks
- [ ] Client sponsor sign-off obtained

### Phase 2 (Design & Implement) Exit

- [ ] Governance framework operational (DLV-007)
- [ ] Mobilisation complete (DLV-008)
- [ ] Change log active (DLV-009)
- [ ] Financial tracking in place (DLV-013)
- [ ] All in-scope deliverables accepted
- [ ] UAT completed and signed off
- [ ] Transition plan agreed

## Output

Write gate review summary to:
`engagements/<slug>/status/<YYYY-MM-DD>-gate-review-<phase>.md`

With frontmatter:
```yaml
---
title: "Gate Review — <Phase>"
type: status-update
date: "<today>"
tags:
  - gate-review
  - phase:<phase>
  - status:draft
status: draft
---
```
