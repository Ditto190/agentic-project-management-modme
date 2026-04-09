---
name: classify-inbox
description: "Command to process and classify files dropped into an engagement inbox."
allowed-tools:
  - read-file
  - write-file
  - run-script
---

# Command: Classify Inbox

## Purpose

Process raw `.txt` and `.md` files dropped into an engagement's `inbox/` directory. Classifies each file by type, adds YAML frontmatter, and moves it to the correct folder.

## Usage

Drop your meeting notes, decision records, risk entries, or any raw text into:
```
engagements/<slug>/inbox/
```

Then run the classifier:

```bash
# Rule-based (offline, no dependencies):
npm run delivery:inbox -- <slug>

# AI-enhanced (requires local ollama):
npm run delivery:inbox:ai -- <slug>
```

## What Gets Classified

| Content Detected | Classified As | Destination |
|-----------------|---------------|-------------|
| Meeting notes, attendees, agenda | `meeting-note` | `meetings/` |
| Decision, agreed, rationale | `decision-record` | `decisions/` |
| Risk, probability, mitigation | `risk-entry` | `inbox/` (review manually) |
| Status, progress, RAG, this week | `status-update` | `status/` |
| Action items, to-do, next steps | `action-item` | `inbox/` |
| Everything else | `raw-note` | `inbox/` |

## Frontmatter Added

Every processed file gets:
```yaml
---
title: "<derived from filename>"
type: <classified-type>
date: "<today>"
classified_at: "<timestamp>"
classified_by: inbox-pipeline
tags:
  - <type>
  - status:draft
status: draft
source_file: "<original filename>"
---
```

## Via AI Assistant

```
@worker-agent Process the inbox for engagement <slug>.

1. Run: bash delivery/_scripts/inbox-classifier.sh <slug>
2. List the classified files and their types
3. Review any files left in inbox/ that were classified as raw-note
4. For each raw-note, ask me what type it should be
5. Update apm/tracker.md noting the inbox was processed today
```
