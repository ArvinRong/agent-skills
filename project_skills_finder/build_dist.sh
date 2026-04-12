#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
CORE="$ROOT/core/project-skill-finder"
DIST="$ROOT/dist"

reset_dir() {
  rm -rf "$1"
  mkdir -p "$1"
}

copy_core_skill() {
  reset_dir "$1"
  cp -R "$CORE"/. "$1"/
}

copy_core_skill "$DIST/codex/.agents/skills/project-skill-finder"
copy_core_skill "$DIST/claude/.claude/skills/project-skill-finder"
copy_core_skill "$DIST/copilot/.github/skills/project-skill-finder"

mkdir -p "$DIST/codex/.agents/skills/project-skill-finder/agents"
cp "$ROOT/adapters/codex/agents/openai.yaml" "$DIST/codex/.agents/skills/project-skill-finder/agents/openai.yaml"
cp "$ROOT/adapters/claude/SKILL.md" "$DIST/claude/.claude/skills/project-skill-finder/SKILL.md"
cp "$ROOT/adapters/copilot/SKILL.md" "$DIST/copilot/.github/skills/project-skill-finder/SKILL.md"

mkdir -p "$DIST/copilot/.github"
cp "$ROOT/adapters/copilot/copilot-instructions.md" "$DIST/copilot/.github/copilot-instructions.md"

echo "Built dist packages under $DIST"
