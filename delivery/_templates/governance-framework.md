---
title: "Governance Framework"
type: deliverable
code: "DLV-007"
activity: governance-pmo-design
phase: design-implement
tags:
  - phase:design-implement
  - artefact_type:deliverable
  - activity:governance-pmo-design
status: draft
version: "1.0"
last_updated: ""
author: ""
reviewer: ""
engagement: ""
---

# Governance Framework

<!-- The Governance Framework defines how decisions are made, how progress is reported, and how issues are escalated on this engagement. It must be agreed and operational before delivery begins. -->

## 1. Governance Principles

<!-- State the core governance principles for this engagement. -->

1. Decisions are made at the lowest appropriate level.
2. Issues are escalated proactively before they become blockers.
3. Governance meetings have clear agendas, actions, and owners.
4. All significant decisions are recorded in the decision log.

## 2. Governance Structure

### 2.1 Governance Tiers

| Tier | Forum | Frequency | Chair | Members | Purpose |
|------|-------|-----------|-------|---------|---------|
| Strategic | Steering Committee | Monthly | Client Sponsor | DL, SA, PM | Strategic decisions, phase gate approvals |
| Operational | Programme Board | Fortnightly | Delivery Lead | PM, WLs, PMO | Progress, risks, cross-workstream issues |
| Delivery | Workstream Reviews | Weekly | PM | Workstream Leads | Detailed delivery tracking |
| Team | Stand-ups | Daily | TL | Delivery team | Day-to-day coordination |

### 2.2 Steering Committee

**Purpose:** Strategic oversight and sponsorship of the engagement.

**Responsibilities:**
- Approve phase gates and major deliverables
- Make strategic decisions beyond Delivery Lead authority
- Resolve escalated issues
- Monitor benefit realisation

**Members:**

| Name | Organisation | Role | Attendance |
|------|-------------|------|-----------|
| | Client | Client Sponsor | Required |
| | Delivery | Delivery Lead | Required |

## 3. Decision Rights (RACI)

<!-- Define who is Responsible, Accountable, Consulted, and Informed for key decisions. -->

| Decision | DL | SA | PM | BA | TL | Client Sponsor |
|----------|----|----|----|----|----|----|
| Scope change approval | C | C | R | C | C | A |
| Technical architecture | C | A | I | I | R | I |
| Commercial escalation | A | I | C | I | I | C |
| Resource allocation | A | C | R | I | C | I |

*R = Responsible, A = Accountable, C = Consulted, I = Informed*

## 4. Reporting Framework

### 4.1 Status Report Cadence

| Report | Frequency | Owner | Distribution |
|--------|-----------|-------|-------------|
| Workstream Status | Weekly | Workstream Lead | PM, DL |
| Programme Status Report | Fortnightly | PM | SteerCo members |
| Executive Summary | Monthly | DL | Client Sponsor, Internal Leadership |
| Financial Report | Monthly | PM / PMO | DL, Client Sponsor |

### 4.2 RAG Status Definitions

| Status | Definition |
|--------|-----------|
| 🟢 Green | On track — no material risks to scope, schedule, cost, or quality |
| 🟡 Amber | At risk — one or more risks that could impact delivery without mitigation |
| 🔴 Red | Off track — confirmed impact to scope, schedule, cost, or quality; recovery plan required |

## 5. Escalation Path

```
Team Issue → Workstream Lead → PM → Delivery Lead → SteerCo
```

**Escalation triggers:**
- Issue cannot be resolved within 2 business days at current level
- Risk score is Critical or High
- Scope, cost, or schedule impact confirmed
- Client relationship risk identified

## 6. Meeting Operating Model

### Standard Meeting Agenda Template

1. Actions from last meeting (5 min)
2. Progress update (15 min)
3. RAID review (10 min)
4. Key decisions required (10 min)
5. AOB and next steps (5 min)

## 7. Document Management

<!-- Define where documents are stored, versioning conventions, and access controls. -->

**Repository:** <!-- e.g., GitHub repo, SharePoint -->  
**Versioning:** Semantic versioning (MAJOR.MINOR.PATCH)  
**Naming convention:** `[ENGAGEMENT-CODE]-[DLV-CODE]-[DOCUMENT-NAME]-v[VERSION].md`

## 8. Approval

| Role | Name | Date |
|------|------|------|
| Delivery Lead | | |
| Client Sponsor | | |
| PMO Lead | | |
