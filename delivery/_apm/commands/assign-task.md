---
name: assign-task
description: "Command to assign a specific task to the Worker agent via the Manager."
allowed-tools:
  - read-file
  - write-file
  - create-file
---

# Command: Assign Task

## Purpose

Use this command to assign a specific delivery task to the Worker agent through the Manager. Produces a task brief that the Worker executes.

## Invocation

```
@manager-agent Assign the following task to a Worker:

Task: <description of what needs to be done>
Deliverable ID: <DLV-XXX if applicable>
Engagement: <slug>
Owner: <name or role>
Due: <YYYY-MM-DD>
Priority: <High/Medium/Low>

Input files:
- <list files the Worker needs to read>

Acceptance criteria:
- <criterion 1>
- <criterion 2>
```

## Manager Steps

1. Create task brief at `engagements/<slug>/apm/memory/task-T-XXX.md`
2. Add task to `apm/tracker.md` with status "Active"
3. Inform Worker of task brief location

## Task Brief Template

```markdown
---
task_id: T-XXX
engagement: <slug>
assigned_to: <Worker>
assigned_by: Manager
created: <date>
due: <date>
priority: High
status: active
---

# Task Brief: <description>

## What To Do
<Clear description of the task>

## Input Files
- `<file path>` — <what it contains>

## Output Files
- `<file path>` — <what to produce>

## Acceptance Criteria
- [ ] <criterion 1>
- [ ] <criterion 2>

## Notes
<Any additional context>
```
