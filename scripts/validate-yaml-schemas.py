#!/usr/bin/env python3
"""validate-yaml-schemas.py — Validate ADMS YAML config files against JSON Schemas."""

import sys
from pathlib import Path

try:
    import yaml
    from jsonschema import validate, ValidationError, SchemaError
except ImportError as e:
    print(f"ERROR: Missing dependency: {e}\nInstall with: pip install pyyaml jsonschema")
    sys.exit(1)

REPO_ROOT = Path(__file__).parent.parent.resolve()

PHASES_SCHEMA = {"type": "object", "required": ["macro_phases", "default_sub_phases"]}
ACTIVITIES_SCHEMA = {"type": "object", "required": ["activities"], "properties": {"activities": {"type": "array", "minItems": 1}}}
DELIVERABLES_SCHEMA = {"type": "object", "required": ["deliverables"], "properties": {"deliverables": {"type": "array", "minItems": 1}}}
TAGS_SCHEMA = {"type": "object", "required": ["taxonomy"]}
ROLES_SCHEMA = {"type": "object", "required": ["roles"], "properties": {"roles": {"type": "array", "minItems": 1}}}
METHODOLOGY_SCHEMA = {"type": "object", "required": ["methodology"]}
CATALOGUE_SCHEMA = {"type": "object", "required": ["engagements"], "properties": {"engagements": {"type": "array"}}}
ENGAGEMENT_SCHEMA = {
    "type": "object",
    "required": ["id", "name", "slug", "client", "status", "current_phase"],
    "properties": {
        "status": {"type": "string", "enum": ["active", "on-hold", "completed", "cancelled"]},
        "current_phase": {"type": "string", "enum": ["discover-envision", "design-implement", "run-evolve"]},
    },
}

STATIC_VALIDATIONS = [
    ("delivery/_config/phases.yaml", PHASES_SCHEMA),
    ("delivery/_config/activities.yaml", ACTIVITIES_SCHEMA),
    ("delivery/_config/deliverables.yaml", DELIVERABLES_SCHEMA),
    ("delivery/_config/tags.yaml", TAGS_SCHEMA),
    ("delivery/_config/roles.yaml", ROLES_SCHEMA),
    ("delivery/_config/methodology.yaml", METHODOLOGY_SCHEMA),
    ("engagements/_catalogue.yaml", CATALOGUE_SCHEMA),
]

def validate_file(rel_path, schema):
    filepath = REPO_ROOT / rel_path
    if not filepath.exists():
        return [f"  [SKIP] {rel_path}"]
    try:
        data = yaml.safe_load(filepath.read_text())
    except yaml.YAMLError as e:
        return [f"  [ERROR] YAML parse error in {rel_path}: {e}"]
    if data is None:
        return [f"  [WARN] Empty file: {rel_path}"]
    try:
        validate(instance=data, schema=schema)
        return []
    except (ValidationError, SchemaError) as e:
        return [f"  [ERROR] {rel_path}: {e.message}"]

def main():
    print("Validating YAML config files...\n")
    all_errors, validated, skipped = [], 0, 0
    for rel_path, schema in STATIC_VALIDATIONS:
        errors = validate_file(rel_path, schema)
        if any("[SKIP]" in e for e in errors):
            print(f"  [SKIP] {rel_path}"); skipped += 1
        elif errors:
            all_errors.extend(errors)
            for e in errors: print(e)
        else:
            print(f"  [OK]   {rel_path}"); validated += 1
    engagements_dir = REPO_ROOT / "engagements"
    if engagements_dir.is_dir():
        for eng_yaml in sorted(engagements_dir.glob("*/engagement.yaml")):
            rel_path = str(eng_yaml.relative_to(REPO_ROOT))
            errors = validate_file(rel_path, ENGAGEMENT_SCHEMA)
            if errors:
                all_errors.extend(errors)
                for e in errors: print(e)
            else:
                print(f"  [OK]   {rel_path}"); validated += 1
    print(f"\nValidated: {validated}, Skipped: {skipped}, Errors: {len(all_errors)}")
    if all_errors:
        print(f"\nFAILED: {len(all_errors)} error(s)."); sys.exit(1)
    print("All YAML files passed schema validation.")

if __name__ == "__main__":
    main()
