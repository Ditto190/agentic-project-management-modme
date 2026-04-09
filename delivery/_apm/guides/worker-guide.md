---
title: "Worker Guide"
type: knowledge
date: ""
tags:
  - apm
  - guide
  - worker
status: draft
---

# Worker Guide

## Overview

The Worker executes bounded tasks assigned by the Manager. This guide covers task execution patterns and quality standards.

## Task Execution Flow

```
Read task brief (apm/memory/task-T-XXX.md)
       ↓
Read all input files listed in brief
       ↓
Execute the task (produce deliverable / classify / draft)
       ↓
Quality check (frontmatter, completeness, consistency)
       ↓
Save output to specified path
       ↓
Update apm/tracker.md (mark task complete / in-review)
```

## Deliverable Production

When producing a deliverable:

1. **Get the template:** Run `generate-deliverable.sh` or copy from `delivery/_templates/`
2. **Read engagement context:** `engagement.yaml`, `apm/spec.md`
3. **Fill frontmatter first:** `author`, `engagement`, `last_updated`, `status: draft`
4. **Work section by section:** Don't skip sections — write TBC or N/A if not applicable
5. **Cross-reference other deliverables:** Use `[[wikilinks]]` to related docs
6. **Quality check before marking complete**

## Quality Checklist

Before marking any task complete:

- [ ] YAML frontmatter present and all fields populated
- [ ] `title`, `type`, `date`, `tags`, `status` all present
- [ ] No HTML comment placeholders remaining in final draft
- [ ] File saved to correct directory (check phase and engagement slug)
- [ ] Internal links use `[[wikilink]]` format for Foam/Obsidian compatibility
- [ ] Tables are properly formatted (no broken Markdown table syntax)
- [ ] No sensitive data (credentials, PII) committed to the repo

## Common Tasks

### Classify Inbox
```bash
bash delivery/_scripts/inbox-classifier.sh <slug>
```
Review output. For `raw-note` items, manually determine correct type.

### Generate Deliverable
```bash
bash delivery/_scripts/generate-deliverable.sh DLV-006 <slug>
```
Then fill in engagement-specific content.

### Update Tracker
Open `apm/tracker.md` and update the task row:
- Change `Status` column to `Completed` or `In Review`
- Add output file path in notes

## Frontmatter Standards

Every Markdown file in `engagements/` and `knowledge/` must have:
```yaml
---
title: "<Human readable title>"
type: <valid-type>
date: "<YYYY-MM-DD>"
tags:
  - <at-least-one-tag>
status: draft
---
```

Valid types: `deliverable`, `meeting-note`, `decision-record`, `risk-entry`, `status-update`, `raw-note`, `action-item`, `knowledge`, `apm-spec`, `apm-plan`, `apm-tracker`
