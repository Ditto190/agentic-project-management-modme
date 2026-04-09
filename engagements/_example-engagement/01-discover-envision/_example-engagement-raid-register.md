---
title: "RAID Register — Example Engagement"
type: deliverable
code: "DLV-006"
activity: raid-management-pre-signature
phase: discover-envision
tags:
  - phase:discover-envision
  - artefact_type:deliverable
  - activity:raid-management-pre-signature
status: draft
version: "1.0"
last_updated: "2025-01-20"
author: "John Doe"
reviewer: "Jane Smith"
engagement: "_example-engagement"
---

# RAID Register — Example Engagement

## Risks

| ID | Risk Description | Probability | Impact | Score | Mitigation | Owner | Status | Raised Date |
|----|-----------------|-------------|--------|-------|-----------|-------|--------|-------------|
| R-001 | Client SME availability constrained due to BAU commitments | H | H | Critical | Agree SME commitment in SoW; escalate to Sponsor if missed | PM | Open | 2025-01-15 |
| R-002 | AWS cost overrun if data volumes underestimated | M | H | High | Add volume-based contingency to estimation model | SA | Open | 2025-01-15 |
| R-003 | Legacy system documentation inadequate for migration planning | L | M | Low | Conduct data discovery sprint in Phase 1 | BA | Open | 2025-01-20 |

## Assumptions

| ID | Assumption | Owner | Validated? | Impact if False |
|----|-----------|-------|-----------|----------------|
| A-001 | AWS is the approved cloud provider | Client CTO | Yes | Fundamental rework of architecture |
| A-002 | Client data team provides 2 SMEs at 20% time | Client PM | Pending | Timeline extends 4-6 weeks |
| A-003 | 15 priority data domains confirmed | BA | Yes | WBS must be revised |

## Issues

| ID | Issue | Priority | Owner | Resolution Plan | Target Date | Status |
|----|-------|---------|-------|-----------------|-------------|--------|
| I-001 | Access to source system documentation delayed | H | PM | Escalated to Client Sponsor | 2025-01-28 | Open |

## Dependencies

| ID | Dependency | Type | Owner | Required By | Status |
|----|-----------|------|-------|------------|--------|
| D-001 | AWS account provisioning | External (Client) | Client IT | 2025-02-01 | Pending |
| D-002 | Data domain inventory from client data team | External (Client) | Client BA | 2025-01-25 | In Progress |
