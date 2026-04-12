#!/usr/bin/env python3
"""Render SKILL_USAGE.md from SKILL_USAGE.json."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo-root", default=".", help="Repository root to inspect.")
    parser.add_argument("--skills-dir", help="Explicit skills directory to update.")
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


def render_report(data: dict[str, Any], report_path: Path) -> None:
    lines = [
        "# Skill Usage",
        "",
        "This Markdown file is an optional human-readable report derived from `SKILL_USAGE.json`.",
        "",
        "Prefer `SKILL_USAGE.json` as the structured source of truth for updates and automation. Regenerate this file after updating the JSON data.",
        "",
        "| Skill ID | File | used_count | helpful_count | not_useful_count | not_useful_reasons | last_used_at | notes |",
        "|---|---|---:|---:|---:|---|---|---|",
    ]

    for entry in data.get("skills", []):
        reasons = entry.get("not_useful_reasons") or []
        lines.append(
            "| `{skill_id}` | `{file}` | {used_count} | {helpful_count} | {not_useful_count} | {reasons} | {last_used_at} | {notes} |".format(
                skill_id=entry.get("skill_id", "-"),
                file=entry.get("file", "-"),
                used_count=entry.get("used_count", 0),
                helpful_count=entry.get("helpful_count", 0),
                not_useful_count=entry.get("not_useful_count", 0),
                reasons=",".join(reasons) if reasons else "-",
                last_used_at=entry.get("last_used_at") or "-",
                notes=(entry.get("notes") or "-").replace("\n", " "),
            )
        )

    reason_labels = data.get("recommended_reason_labels", [])
    lines.extend(["", "## Recommended reason labels", ""])
    lines.extend(f"- `{label}`" for label in reason_labels)
    report_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> None:
    args = parse_args()
    repo_root = Path(args.repo_root).resolve()
    skills_dir = Path(args.skills_dir).resolve() if args.skills_dir else detect_skills_dir(repo_root)
    usage_path = skills_dir / "SKILL_USAGE.json"
    report_path = skills_dir / "SKILL_USAGE.md"

    data = load_usage(usage_path)
    render_report(data, report_path)
    print(f"Refreshed {report_path}")


if __name__ == "__main__":
    main()
