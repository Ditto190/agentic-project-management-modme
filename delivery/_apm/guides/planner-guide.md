---
title: "Planner Guide"
type: knowledge
date: ""
tags:
  - apm
  - guide
  - planner
status: draft
---

# Planner Guide

## Overview

The Planner is the strategic agent in ADMS. This guide describes the end-to-end planning flow from engagement intake to plan baseline.

## When to Invoke the Planner

- At engagement inception (after `init-engagement.sh` has been run)
- When a significant scope change occurs (re-planning event)
- At each phase gate to re-baseline the forward plan
- When a new workstream is added to the engagement

## End-to-End Planning Flow

```
Client Brief / RFP
       ↓
Intake Processing (inbox-classifier)
       ↓
Scope Definition Workshops
       ↓
Draft Scope Definition (DLV-002)
       ↓
WBS Decomposition (DLV-004)
       ↓
RAID Register Established (DLV-006)
       ↓
Assumptions Logged (DLV-014)
       ↓
Estimation Model (DLV-012)
       ↓
SoW Drafted (DLV-005)
       ↓
Plan Baselined (apm/plan.md)
       ↓
Handoff to Manager
```

## Key Artefacts

| Artefact | File | When Created |
|---------|------|-------------|
| Engagement Spec | `apm/spec.md` | Day 1 |
| Delivery Plan | `apm/plan.md` | Week 1 |
| Scope Definition | `01-discover-envision/[slug]-scope-definition.md` | Week 1-2 |
| WBS | `01-discover-envision/[slug]-wbs.md` | Week 1-2 |
| RAID Register | `01-discover-envision/[slug]-raid-register.md` | Week 1 |
| Assumptions Log | `01-discover-envision/[slug]-assumptions-log.md` | Week 1 |

## Handoff Pattern

When planning is complete:
1. Write `apm/memory/planner-handoff.md`
2. Update `engagement.yaml` status to `active`
3. Update `01-discover-envision/_phase.yaml` to `in-progress`
4. Notify Manager agent of handoff

## Common Pitfalls

- **Scope creep at planning stage:** Anything not explicitly in the scope definition is out of scope. Document it.
- **Assumption-as-fact:** Log every assumption. If it is not validated, it is a risk.
- **Optimistic estimation:** Apply contingency. Use three-point estimation for uncertain items.
- **Missing dependencies:** Map all external dependencies before baseline. They are your highest-risk items.
