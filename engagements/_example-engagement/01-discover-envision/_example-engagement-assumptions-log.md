---
title: "Assumptions Log — Example Engagement"
type: deliverable
code: "DLV-014"
activity: assumptions-dependencies-logging
phase: discover-envision
tags:
  - phase:discover-envision
  - artefact_type:deliverable
  - activity:assumptions-dependencies-logging
status: draft
version: "1.0"
last_updated: "2025-01-20"
author: "John Doe"
reviewer: "Jane Smith"
engagement: "_example-engagement"
---

# Assumptions Log — Example Engagement

## Summary

| Metric | Count |
|--------|-------|
| Total assumptions | 3 |
| Validated | 2 |
| Invalidated | 0 |
| Pending validation | 1 |
| Total dependencies | 2 |

## Assumptions Register

| ID | Assumption | Owner | Date Logged | Validated? | Impact if False | Status |
|----|-----------|-------|------------|-----------|----------------|--------|
| A-001 | AWS is the approved cloud provider | Client CTO | 2025-01-15 | Yes | Fundamental rework required | Validated |
| A-002 | Client data team provides 2 SMEs at 20% time | Client PM | 2025-01-15 | Pending | 4-6 week timeline extension | Open |
| A-003 | 15 priority data domains confirmed and stable | BA | 2025-01-15 | Yes | WBS revision required | Validated |

## Dependencies Register

| ID | Dependency | Type | Owner | Required By | Status |
|----|-----------|------|-------|------------|--------|
| D-001 | AWS account provisioning | External | Client IT | 2025-02-01 | Pending |
| D-002 | Data domain inventory | External | Client BA | 2025-01-25 | In Progress |
