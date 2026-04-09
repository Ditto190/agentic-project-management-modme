---
title: "Manager Guide"
type: knowledge
date: ""
tags:
  - apm
  - guide
  - manager
status: draft
---

# Manager Guide

## Overview

The Manager coordinates day-to-day delivery execution. This guide describes the weekly operating rhythm and escalation model.

## Weekly Operating Rhythm

### Monday
- Review `apm/tracker.md` — update task statuses
- Process `inbox/` — run inbox classifier
- Update RAID register with any new items
- Identify blocked tasks and initiate unblocking actions

### Wednesday
- Mid-week progress check — are we on track for week's commitments?
- Brief Planner on any risks to the plan

### Friday
- Update phase completion percentages in `_phase.yaml`
- Prepare status report if due
- Run `npm run delivery:status` to update portfolio dashboard
- Capture any decisions made this week in `decisions/`

## Escalation Model

```
Task blocked > 2 days → Manager escalates to Planner
Risk score Critical → Manager escalates to Planner → SteerCo
Scope change requested → Manager raises Change Request → Planner reviews → Client approves
Financial variance > 10% → Manager flags to Delivery Lead
```

## Governance Pack Preparation

For each SteerCo/Programme Board:
1. Open status report template from `delivery/_templates/`
2. Fill in RAG status for each workstream
3. Summarise RAID status (open risks, new issues)
4. Report financial position (actuals vs budget)
5. List decisions needed from governance forum
6. Note actions from last meeting and their status

## State Management

Update these files regularly:

| File | Update Frequency | What to Update |
|------|-----------------|---------------|
| `apm/tracker.md` | Daily | Task status |
| `[phase]/_phase.yaml` | Weekly | Completion %, deliverable status |
| `[phase]/[slug]-raid-register.md` | Weekly | New/resolved RAID items |
| `engagement.yaml` | On phase change | current_phase, status |

## Handoff Pattern

Manager → Worker:
1. Create `apm/memory/task-T-XXX.md`
2. Add task to `apm/tracker.md` with status "Active"
3. Worker reads task brief and executes
4. Worker updates tracker on completion
