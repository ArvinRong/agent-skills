#!/usr/bin/env python3
"""Update SKILL_USAGE.json and optionally refresh SKILL_USAGE.md."""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from typing import Any


TIMESTAMP_FORMAT = "%Y-%m-%d %H:%M:%S"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo-root", default=".", help="Repository root to inspect.")
    parser.add_argument("--skills-dir", help="Explicit skills directory to update.")
    parser.add_argument("--skill-id", required=True, help="Stable skill identifier.")
    parser.add_argument("--file", required=True, help="Skill markdown filename.")
    parser.add_argument(
        "--result",
        choices=("used", "helpful", "not-useful"),
        default="used",
        help="How this invocation should be counted.",
    )
    parser.add_argument(
        "--reason",
        action="append",
        default=[],
        help="Reason label for a not-useful result. Repeat to add more than one.",
    )
    parser.add_argument("--notes", help="Replacement notes text for this skill entry.")
    parser.add_argument(
        "--no-report",
        action="store_true",
        help="Do not regenerate SKILL_USAGE.md after updating the JSON data.",
    )
    return parser.parse_args()


def detect_skills_dir(repo_root: Path) -> Path:
    candidates = [repo_root / "docs" / "skills", repo_root / "skills"]
    for candidate in candidates:
        if candidate.is_dir():
            return candidate
    raise FileNotFoundError("Could not find docs/skills or skills under the repository root.")


def load_usage(path: Path) -> dict[str, Any]:
    if not path.exists():
        raise FileNotFoundError(f"Usage file not found: {path}")
    return json.loads(path.read_text(encoding="utf-8"))


def save_usage(path: Path, data: dict[str, Any]) -> None:
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def upsert_entry(data: dict[str, Any], skill_id: str, file_name: str) -> dict[str, Any]:
    skills = data.setdefault("skills", [])
    for entry in skills:
        if entry.get("skill_id") == skill_id:
            if not entry.get("file"):
                entry["file"] = file_name
            return entry

    entry = {
        "skill_id": skill_id,
        "file": file_name,
        "used_count": 0,
        "helpful_count": 0,
        "not_useful_count": 0,
        "not_useful_reasons": [],
        "last_used_at": None,
        "notes": "",
    }
    skills.append(entry)
    return entry


def merge_reasons(entry: dict[str, Any], reasons: list[str]) -> None:
    existing = list(entry.get("not_useful_reasons", []))
    for reason in reasons:
        if reason not in existing:
            existing.append(reason)
    entry["not_useful_reasons"] = existing


def sync_report(skills_dir: Path) -> None:
    script_path = Path(__file__).with_name("sync_skill_usage_report.py")
    subprocess.run(
        [sys.executable, str(script_path), "--skills-dir", str(skills_dir)],
        check=True,
    )


def main() -> None:
    args = parse_args()
    repo_root = Path(args.repo_root).resolve()
    skills_dir = Path(args.skills_dir).resolve() if args.skills_dir else detect_skills_dir(repo_root)
    usage_path = skills_dir / "SKILL_USAGE.json"

    data = load_usage(usage_path)
    entry = upsert_entry(data, args.skill_id, args.file)

    entry["used_count"] = int(entry.get("used_count", 0)) + 1
    if args.result == "helpful":
        entry["helpful_count"] = int(entry.get("helpful_count", 0)) + 1
    elif args.result == "not-useful":
        entry["not_useful_count"] = int(entry.get("not_useful_count", 0)) + 1
        merge_reasons(entry, args.reason)

    entry["last_used_at"] = datetime.now().strftime(TIMESTAMP_FORMAT)
    if args.notes is not None:
        entry["notes"] = args.notes

    save_usage(usage_path, data)
    print(f"Updated {usage_path}")

    if not args.no_report:
        sync_report(skills_dir)


if __name__ == "__main__":
    main()
