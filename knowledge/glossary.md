---
title: "Glossary"
type: knowledge
date: ""
tags:
  - glossary
  - reference
status: approved
---

# Glossary

<!-- ADMS terminology reference. Use [[wikilinks]] when referencing terms defined here. -->

## A

**Activity Area**
One of the 14 core delivery activity areas in ADMS. Each activity maps to specific deliverables and phases. See `delivery/_config/activities.yaml`.

**Assumptions Log (DLV-014)**
A living register of all assumptions underpinning the delivery plan. Assumptions that prove false must be escalated and may trigger a Change Request.

**ADMS**
Agentic Delivery Management System. The delivery framework implemented in this repository.

## C

**Change Control**
The formal process for reviewing, approving, and tracking changes to the agreed project baseline (scope, cost, schedule). See [[change-log]] and [[change-request]].

**Change Request (CR)**
A formal document requesting a change to the project baseline. Requires approval from Delivery Lead and Client Sponsor. See `delivery/_templates/change-request.md`.

## D

**Decision Record**
A document recording a significant decision made during the engagement — including context, options considered, the decision made, and rationale. Stored in `decisions/`.

**Deliverable**
A formally defined output produced during the engagement. Each deliverable has a code (DLV-XXX), template, and acceptance criteria. See `delivery/_config/deliverables.yaml`.

**DLV Code**
A unique identifier for a deliverable (e.g., DLV-002 = Scope Definition Document).

## E

**Engagement**
A time-boxed client delivery programme managed under ADMS. Each engagement has its own directory under `engagements/`.

**Estimation Model (DLV-012)**
A document recording effort, cost, and timeline estimates for the engagement, including assumptions and confidence levels.

## G

**Governance Framework (DLV-007)**
The document defining how decisions are made, how progress is reported, and how issues are escalated on the engagement.

## I

**Inbox Pipeline**
The automated classification pipeline that processes raw `.txt` and `.md` files dropped into `engagements/<slug>/inbox/`. Run via `npm run delivery:inbox`.

## M

**Macro Phase**
One of the three top-level delivery phases: Discover & Envision, Design & Implement, Run & Evolve.

**Mobilisation Plan (DLV-008)**
The plan for standing up the delivery team, tools, environments, and governance structures.

## P

**Phase Gate**
A formal review point at the end of each macro phase. All exit criteria must be met before transitioning to the next phase.

**Portfolio Dashboard**
An auto-generated summary of all active engagements. See `engagements/_portfolio-dashboard.md`.

## R

**RAID**
Risks, Assumptions, Issues, Dependencies. The four categories tracked in the RAID Register (DLV-006).

**RAG Status**
Red/Amber/Green — a traffic light status system for reporting delivery health.

## S

**SoW (Statement of Work)**
The primary contractual document defining services, deliverables, timeline, and commercial terms for an engagement.

**Scope Baseline**
The formally approved version of the project scope. Any changes require a formal Change Request.

**Sub-Phase**
A more granular delivery stage within a macro phase (e.g., "Confirm Scope" within "Discover & Envision").

## W

**WBS (Work Breakdown Structure)**
A hierarchical decomposition of the project scope into manageable work packages.

**Wikilink**
A `[[double-bracket]]` link format used in Foam/Obsidian for cross-referencing notes and documents.
