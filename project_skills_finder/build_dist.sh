#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
CORE="$ROOT/core/project-skill-finder"
DIST="$ROOT/dist"
CORE_SKILL="$CORE/SKILL.md"

reset_dir() {
  rm -rf "$1"
  mkdir -p "$1"
}

copy_core_skill() {
  reset_dir "$1"
  for item in "$CORE"/*; do
    base=$(basename "$item")
    if [ "$base" = "templates" ]; then
      continue
    fi
    cp -R "$item" "$1"/
  done
}

write_adapted_skill() {
  skill_dir="$1"
  adapter_frontmatter="$2"

  if [ ! -f "$adapter_frontmatter" ] || [ ! -s "$adapter_frontmatter" ]; then
    return
  fi

  awk -v extra_file="$adapter_frontmatter" '
    BEGIN {
      while ((getline line < extra_file) > 0) {
        extras[++extra_count] = line
      }
      close(extra_file)
    }
    NR == 1 && $0 == "---" {
      in_frontmatter = 1
      print
      next
    }
    in_frontmatter && $0 == "---" {
      for (i = 1; i <= extra_count; i++) {
        print extras[i]
      }
      print
      in_frontmatter = 0
      next
    }
    { print }
  ' "$CORE_SKILL" > "$skill_dir/SKILL.md"
}

copy_core_skill "$DIST/codex/.agents/skills/project-skill-finder"
copy_core_skill "$DIST/claude/.claude/skills/project-skill-finder"
copy_core_skill "$DIST/copilot/.github/skills/project-skill-finder"

mkdir -p "$DIST/codex/.agents/skills/project-skill-finder/agents"
cp "$ROOT/adapters/codex/agents/openai.yaml" "$DIST/codex/.agents/skills/project-skill-finder/agents/openai.yaml"
write_adapted_skill "$DIST/claude/.claude/skills/project-skill-finder" "$ROOT/adapters/claude/frontmatter.append.yaml"
write_adapted_skill "$DIST/copilot/.github/skills/project-skill-finder" "$ROOT/adapters/copilot/frontmatter.append.yaml"

mkdir -p "$DIST/copilot/.github"
cp "$ROOT/adapters/copilot/copilot-instructions.md" "$DIST/copilot/.github/copilot-instructions.md"

echo "Built dist packages under $DIST"
