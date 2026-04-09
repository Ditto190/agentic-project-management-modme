#!/usr/bin/env python3
"""
inbox-classifier.py — AI-enhanced inbox classifier using local ollama (optional).

Usage: python3 inbox-classifier.py <engagement-slug-or-path>

If ollama is not installed or fails, falls back to rule-based classification
(same logic as inbox-classifier.sh). This script is OPTIONAL and not required
for normal operation.

Requirements (optional): ollama (https://ollama.ai) running locally.
"""

import json
import os
import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path


# ── Constants ──────────────────────────────────────────────────────────────────
SCRIPT_DIR = Path(__file__).parent.resolve()
REPO_ROOT = (SCRIPT_DIR / "../..").resolve()
VALID_TYPES = [
    "meeting-note",
    "decision-record",
    "risk-entry",
    "status-update",
    "raw-note",
    "action-item",
]
DEST_MAP = {
    "meeting-note": "meetings",
    "decision-record": "decisions",
    "status-update": "status",
    "risk-entry": "inbox",
    "action-item": "inbox",
    "raw-note": "inbox",
}


# ── Helpers ────────────────────────────────────────────────────────────────────
def slugify(text: str) -> str:
    text = text.lower()
    text = re.sub(r"[^a-z0-9]+", "-", text)
    text = text.strip("-")
    return text


def load_tags_config() -> dict:
    tags_path = REPO_ROOT / "delivery/_config/tags.yaml"
    try:
        import yaml  # type: ignore
        with open(tags_path) as f:
            return yaml.safe_load(f) or {}
    except Exception:
        return {}


def rule_based_classify(content: str, filename: str) -> str:
    """Pure rule-based classification — offline fallback."""
    lower = content.lower()
    lower_name = filename.lower()

    if re.search(
        r"(meeting|attendees|participants|agenda|minutes|action items|discussed|standup|stand-up|scrum|retro)",
        lower,
    ) or re.search(r"(meeting|minutes|standup|retro)", lower_name):
        return "meeting-note"

    if re.search(
        r"(decision:|decided|agreed|resolution:|we have decided|rationale:|options considered|option selected)",
        lower,
    ) or re.search(r"(decision|adr|agreed)", lower_name):
        return "decision-record"

    if re.search(
        r"(risk:|risk identified|probability|impact|mitigation|likelihood|threat|vulnerability|risk register)",
        lower,
    ) or re.search(r"(risk|raid)", lower_name):
        return "risk-entry"

    if re.search(
        r"(status:|progress|completed|blockers?:|this week|last week|rag status|green|amber|red|on track|at risk|off track)",
        lower,
    ) or re.search(r"(status|update|progress|weekly|monthly)", lower_name):
        return "status-update"

    if re.search(
        r"(action:|to do:|todo:|next steps?:|actions?:|follow.?up|assigned to)",
        lower,
    ) or re.search(r"(action|todo|tasks?)", lower_name):
        return "action-item"

    return "raw-note"


def ollama_classify(content: str, tags_config: dict) -> str | None:
    """Attempt classification using local ollama. Returns None on failure."""
    try:
        result = subprocess.run(
            ["which", "ollama"], capture_output=True, text=True, timeout=5
        )
        if result.returncode != 0:
            return None
    except Exception:
        return None

    artefact_types = []
    try:
        artefact_types = tags_config.get("taxonomy", {}).get("artefact_type", {}).get("values", VALID_TYPES)
    except Exception:
        artefact_types = VALID_TYPES

    prompt = f"""You are a delivery management assistant. Classify the following note into exactly one of these types:
{json.dumps(artefact_types, indent=2)}

Respond with ONLY a JSON object like: {{"type": "meeting-note", "confidence": 0.9, "reasoning": "..."}}

Note content:
---
{content[:2000]}
---"""

    try:
        result = subprocess.run(
            ["ollama", "run", "mistral", prompt],
            capture_output=True,
            text=True,
            timeout=30,
        )
        if result.returncode != 0:
            return None

        output = result.stdout.strip()
        # Extract JSON from response
        json_match = re.search(r'\{[^{}]+\}', output, re.DOTALL)
        if not json_match:
            return None

        data = json.loads(json_match.group())
        classified_type = data.get("type", "").strip()
        if classified_type in VALID_TYPES:
            return classified_type
        return None
    except Exception:
        return None


def process_file(filepath: Path, engagement_dir: Path) -> bool:
    """Process a single inbox file: classify, add frontmatter, move."""
    content = filepath.read_text(encoding="utf-8", errors="replace")

    # Skip files that already have frontmatter
    if content.startswith("---"):
        print(f"  SKIP (has frontmatter): {filepath.name}")
        return True

    tags_config = load_tags_config()
    today = datetime.now().strftime("%Y-%m-%d")
    now = datetime.now().strftime("%Y-%m-%dT%H:%M:%S")

    # Try AI classification first, fall back to rules
    file_type = ollama_classify(content, tags_config)
    classifier_used = "ollama"
    if file_type is None:
        file_type = rule_based_classify(content, filepath.name)
        classifier_used = "rule-based"

    dest_subdir = DEST_MAP.get(file_type, "inbox")
    dest_dir = engagement_dir / dest_subdir
    dest_dir.mkdir(parents=True, exist_ok=True)

    base_name = slugify(filepath.stem)
    title = " ".join(w.capitalize() for w in base_name.split("-"))
    out_filename = f"{today}-{base_name}.md"
    out_path = dest_dir / out_filename

    # Guard against overwriting
    if out_path.exists():
        ts = datetime.now().strftime("%H%M%S")
        out_path = dest_dir / f"{today}-{base_name}-{ts}.md"

    frontmatter = f"""---
title: "{title}"
type: {file_type}
date: "{today}"
classified_at: "{now}"
classified_by: inbox-pipeline-python
classifier: {classifier_used}
tags:
  - {file_type}
  - status:draft
status: draft
source_file: "{filepath.name}"
---

"""

    out_path.write_text(frontmatter + content, encoding="utf-8")
    filepath.unlink()

    rel_out = str(out_path.relative_to(engagement_dir))
    print(f"  [{file_type}] ({classifier_used}) {filepath.name} → {rel_out}")
    return True


def main() -> None:
    if len(sys.argv) < 2:
        print("Usage: inbox-classifier.py <engagement-slug-or-path>", file=sys.stderr)
        sys.exit(1)

    input_path = sys.argv[1]
    engagement_dir: Path | None = None

    if Path(input_path).is_dir():
        engagement_dir = Path(input_path).resolve()
    elif (REPO_ROOT / "engagements" / input_path).is_dir():
        engagement_dir = REPO_ROOT / "engagements" / input_path
    else:
        print(f"ERROR: Cannot find engagement directory: {input_path}", file=sys.stderr)
        sys.exit(1)

    inbox_dir = engagement_dir / "inbox"
    if not inbox_dir.is_dir():
        print(f"No inbox directory at: {inbox_dir}")
        sys.exit(0)

    print(f"Processing inbox: {inbox_dir}")
    print()

    files = list(inbox_dir.glob("*.txt")) + list(inbox_dir.glob("*.md"))
    if not files:
        print("No files to process in inbox.")
        return

    processed = 0
    failed = 0
    for f in files:
        try:
            if process_file(f, engagement_dir):
                processed += 1
        except Exception as exc:
            print(f"  ERROR processing {f.name}: {exc}", file=sys.stderr)
            failed += 1

    print()
    print(f"Done. Processed: {processed}, Failed: {failed}")


if __name__ == "__main__":
    main()
