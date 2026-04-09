---
name: plan-engagement
description: "Command to initialise and plan a new engagement using the ADMS Planner agent."
allowed-tools:
  - read-file
  - write-file
  - create-file
  - run-script
---

# Command: Plan Engagement

## Purpose

Use this command to initialise a new engagement and produce the initial delivery plan with the help of an AI assistant (e.g., GitHub Copilot Chat or Claude).

## Prerequisites

- Engagement directory must exist (run `npm run delivery:init -- <slug>` first)
- You should have intake notes or a brief in `engagements/<slug>/inbox/`

## Invocation

Paste the following into your AI assistant chat:

```
@planner-agent Plan the engagement at engagements/<slug>/.

Context:
- Client: <client name>
- Engagement objective: <one sentence>
- Key constraints: <budget, timeline, technology>
- Available inputs: <list any files in inbox/>

Please:
1. Read engagement.yaml and apm/spec.md
2. Process any files in inbox/ using the inbox classifier
3. Draft the scope definition (DLV-002) based on the intake notes
4. Update apm/plan.md with the phased task list
5. Establish the initial RAID register (DLV-006)
6. Create a planner handoff note in apm/memory/
```

## Steps the Planner Agent Should Follow

1. **Read context files:**
   - `engagements/<slug>/engagement.yaml`
   - `delivery/_config/methodology.yaml`
   - `delivery/_config/deliverables.yaml`

2. **Process inbox:**
   - Run `delivery/_scripts/inbox-classifier.sh <slug>`
   - Review classified files

3. **Draft scope:**
   - Open `engagements/<slug>/01-discover-envision/<slug>-scope-definition.md`
   - Fill in sections based on intake notes

4. **Build plan:**
   - Open `engagements/<slug>/apm/plan.md`
   - Add phase-by-phase tasks with owners and due dates

5. **Establish RAID:**
   - Open `engagements/<slug>/01-discover-envision/<slug>-raid-register.md`
   - Log known risks, assumptions, and dependencies from intake

6. **Write handoff:**
   - Create `engagements/<slug>/apm/memory/planner-handoff.md`

## Expected Outputs

- Updated `apm/spec.md`
- Updated `apm/plan.md`
- Drafted `01-discover-envision/<slug>-scope-definition.md`
- Drafted `01-discover-envision/<slug>-raid-register.md`
- Created `apm/memory/planner-handoff.md`
