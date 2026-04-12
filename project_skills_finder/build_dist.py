#!/usr/bin/env python3
"""Build ready-to-copy dist layouts for each supported agent."""

from __future__ import annotations

import shutil
from pathlib import Path


ROOT = Path(__file__).resolve().parent
CORE_SKILL = ROOT / "core" / "project-skill-finder"
CORE_SKILL_FILE = CORE_SKILL / "SKILL.md"
DIST = ROOT / "dist"


def reset_dir(path: Path) -> None:
    if path.exists():
        shutil.rmtree(path)
    path.mkdir(parents=True, exist_ok=True)


def copy_tree(src: Path, dest: Path) -> None:
    shutil.copytree(src, dest, dirs_exist_ok=True)


def copy_core_runtime(dest: Path) -> None:
    for item in CORE_SKILL.iterdir():
        if item.name == "templates":
            continue
        target = dest / item.name
        if item.is_dir():
            shutil.copytree(item, target, dirs_exist_ok=True)
        else:
            shutil.copy2(item, target)


def write_adapted_skill(skill_dir: Path, adapter_frontmatter: Path) -> None:
    if not adapter_frontmatter.exists():
        return

    extra = adapter_frontmatter.read_text(encoding="utf-8").strip()
    if not extra:
        return

    core_content = CORE_SKILL_FILE.read_text(encoding="utf-8")
    normalized = core_content.replace("\r\n", "\n")
    marker = "\n---\n"
    if not normalized.startswith("---\n") or marker not in normalized[4:]:
        raise ValueError(f"Core SKILL.md is missing a valid frontmatter block: {CORE_SKILL_FILE}")

    frontmatter_end = normalized.index(marker, 4)
    frontmatter = normalized[4:frontmatter_end].rstrip("\n")
    body = normalized[frontmatter_end + len(marker):]
    merged = f"---\n{frontmatter}\n{extra}\n---\n{body}"
    (skill_dir / "SKILL.md").write_text(merged, encoding="utf-8")


def build_codex() -> None:
    skill_dir = DIST / "codex" / ".agents" / "skills" / "project-skill-finder"
    reset_dir(skill_dir)
    copy_core_runtime(skill_dir)
    adapter = ROOT / "adapters" / "codex" / "agents" / "openai.yaml"
    target = skill_dir / "agents" / "openai.yaml"
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(adapter, target)


def build_claude() -> None:
    skill_dir = DIST / "claude" / ".claude" / "skills" / "project-skill-finder"
    reset_dir(skill_dir)
    copy_core_runtime(skill_dir)
    adapter_frontmatter = ROOT / "adapters" / "claude" / "frontmatter.append.yaml"
    write_adapted_skill(skill_dir, adapter_frontmatter)


def build_copilot() -> None:
    skill_dir = DIST / "copilot" / ".github" / "skills" / "project-skill-finder"
    reset_dir(skill_dir)
    copy_core_runtime(skill_dir)
    adapter_frontmatter = ROOT / "adapters" / "copilot" / "frontmatter.append.yaml"
    write_adapted_skill(skill_dir, adapter_frontmatter)
    adapter = ROOT / "adapters" / "copilot" / "copilot-instructions.md"
    target = DIST / "copilot" / ".github" / "copilot-instructions.md"
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(adapter, target)


def main() -> None:
    DIST.mkdir(parents=True, exist_ok=True)
    build_codex()
    build_claude()
    build_copilot()
    print(f"Built dist packages under {DIST}")


if __name__ == "__main__":
    main()
