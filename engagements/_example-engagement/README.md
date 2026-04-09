---
title: "Example Engagement"
type: deliverable
date: "2025-01-01"
tags:
  - example
  - reference
status: draft
---

# Example Engagement

> **This is a reference example.** Do not use this for real delivery work.
> To create a new engagement, run: `npm run delivery:init -- <name> [client]`

**Client:** Example Client Ltd  
**Engagement ID:** ENG-20250101-_EXAMPLE  
**Created:** 2025-01-01  
**Status:** Active (example)

## Quick Links

| Resource | Link |
|----------|------|
| Engagement Metadata | [engagement.yaml](engagement.yaml) |
| APM Spec | [apm/spec.md](apm/spec.md) |
| Delivery Plan | [apm/plan.md](apm/plan.md) |
| Task Tracker | [apm/tracker.md](apm/tracker.md) |
| RAID Register | [01-discover-envision/_example-engagement-raid-register.md](01-discover-envision/_example-engagement-raid-register.md) |
| Scope Definition | [01-discover-envision/_example-engagement-scope-definition.md](01-discover-envision/_example-engagement-scope-definition.md) |

## Phase Status

| Phase | Status | Completion |
|-------|--------|-----------|
| 01 Discover & Envision | In Progress | 30% |
| 02 Design & Implement | Not Started | 0% |
| 03 Run & Evolve | Not Started | 0% |

## Directory Structure

```
_example-engagement/
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
```

## Inbox Usage

Drop `.txt` or `.md` files into `inbox/` and run:

```bash
npm run delivery:inbox -- _example-engagement
```
