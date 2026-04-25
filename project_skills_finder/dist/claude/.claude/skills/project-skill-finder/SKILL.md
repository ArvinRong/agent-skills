---
name: project-skill-finder
description: Discover and route into project-local skill docs when working in a software repository on implementation, debugging, testing, architecture, command, runtime, deployment,plugin, rendering, or similar development tasks. Use only for project work, not general chat. Prefer project-local docs in docs/skills/ or skills/ before doing deeper repository work.
user-invocable: false
---

# Project Skill Finder

This skill should only be used for tasks related to project development, including debugging, design, and implementation.

## When This Skill Must Fire

  Invoke this skill **before** the first codebase exploration action (e.g., searching, reading, or scanning source files using tools such as Glob or Grep)** when:
  - The task involves writing, changing, or reviewing project code or tests
  - The user asks "how does X work", "what should I add", or "help me implement Y"
  - Any task that would otherwise start with codebase exploration

Do NOT:
  - Start reading source files to understand the domain without checking skill docs first

## Workflow


1. If an `skills/INDEX.md` or `docs/skills/INDEX.md` exists, read it first.
2. Then read only the most relevant 1-2 project skill docs from `docs/skills` or `skills` folder for the task.
3. Prefer docs that expose stable YAML frontmatter such as `id`, `description`, and `when_to_use`.
4. Do not bulk-load all project skill docs.
5. If no `INDEX.md` exists, enumerate candidate `.md` files in that directory, exclude control docs, and choose the most relevant 1-2.
6. If no project skill docs exist, continue normally without error.
7. If there are no helpful relevant skill docs, then continue with the task as usual.

## Project-Local Rules

- Treat project-local docs as the source of truth.
- Project-local skill docs should ideally carry stable YAML frontmatter such as `id`, `title`, `description`, and `when_to_use`.
- If project skill docs were actually read and used, update the usage tracking file in the same skill directory.
- If a bundled usage script is available, prefer running it instead of editing tracking files by hand.
- On Windows or PowerShell-first environments, prefer `scripts/update_skill_usage.ps1`.
- On macOS, Linux, or WSL, prefer `scripts/update_skill_usage.sh`.
- `scripts/update_skill_usage.py` remains available as an optional fallback.
- After writing `SKILL_USAGE.json`, the updater should refresh `SKILL_USAGE.md` automatically.
- Prefer `SKILL_USAGE.json` as the structured source of truth for usage tracking.
- `SKILL_USAGE.md` is the human-readable report derived from the JSON data.
- Count `used_count` only when a project skill doc was clearly read and referenced.
- Count `helpful_count` only when that project skill materially helped the task.
- Count `not_useful_count` when the project skill doc was read and referenced but did not materially help.
- Use the stable skill `id` when available; otherwise fall back to the filename.
- Keep `not_useful_reasons` short and stable when possible. Prefer labels such as `description_unclear`, `wrong_trigger`, `outdated_content`, `missing_key_files`, `too_shallow`, `too_broad`, or `poor_examples`.
- Update `last_used_at` using `yyyy-MM-dd HH:mm:ss` and refresh `notes` when useful.
- Mentioning a project skill by name without reading it does not count as usage.
- In multi-agent tasks, prefer having the main agent perform the shared data update.
- If a task used a project skill doc and also changed code, tests, entrypoints, or behavior in that same problem area, review whether the skill doc should be refreshed before closing the task.
- If the doc is clearly outdated, update it; if the need is plausible but uncertain, explicitly prompt whether the project skill doc should be updated.
- Do not pre-approve broad shell access for this skill by default. This router can auto-trigger, so shell execution should still follow the host's normal approval flow unless a team intentionally narrows and enables it.

## Context Budget

- Read the index first when present.
- Load the minimum relevant project docs.
- Avoid unrelated project skill docs unless the task expands.

## Skill Growth

If the task reveals a repeated problem area, a missing onboarding path, or a module cluster that would benefit from its own project skill doc, explicitly suggest adding one or splitting an overloaded one.
