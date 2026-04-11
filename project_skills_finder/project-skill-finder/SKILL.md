---
name: project-skill-finder
description: Discover and route into project-local skill docs when working in a software repository on implementation, debugging, testing, architecture, command, runtime, deployment, SSH, vault, plugin, rendering, or similar development tasks. Use only for project work, not general chat. Prefer project-local docs in docs/skills/ or skills/ before doing deeper repository work.
---

# Project Skill Finder

Use this skill only for project development tasks.

## Workflow

1. Look for project-local skill docs in this order:
   - `docs/skills/INDEX.md`
   - `docs/skills/*.md`
   - `skills/INDEX.md`
   - `skills/*.md`
2. If an `INDEX.md` exists, read it first.
3. Then read only the most relevant 1-2 project skill docs for the task.
4. Do not bulk-load all project skill docs.
5. If no `INDEX.md` exists, enumerate `.md` files in that directory and choose the most relevant 1-2.
6. If no project skill docs exist, continue normally without error.

## Project-Local Rules

- Treat project-local docs as the source of truth.
- If `docs/skills/SKILL_ANALYZATION_DATA.md` exists and project skill docs were actually read and used, update it.
- Count `used_count` only when a project skill doc was clearly read and referenced.
- Count `helpful_count` only when that project skill materially helped the task.
- Count `not_useful_count` when the project skill doc was read and referenced but did not materially help.
- Keep `not_useful_reasons` short and stable when possible. Prefer labels such as `description_unclear`, `wrong_trigger`, `outdated_content`, `missing_key_files`, `too_shallow`, `too_broad`, or `poor_examples`.
- Update `last_used_at` using `yyyy-MM-dd HH:mm:ss` and refresh `notes` when useful.
- Mentioning a project skill by name without reading it does not count as usage.
- In multi-agent tasks, prefer having the main agent perform the shared data update.`r`n- If a task used a project skill doc and also changed code, tests, entrypoints, or behavior in that same problem area, review whether the skill doc should be refreshed before closing the task.`r`n- If the doc is clearly outdated, update it; if the need is plausible but uncertain, explicitly prompt whether the project skill doc should be updated.

## Context Budget

- Read the index first when present.
- Load the minimum relevant project docs.
- Avoid unrelated project skill docs unless the task expands.

## Skill Growth

If the task reveals a repeated problem area, a missing onboarding path, or a module cluster that would benefit from its own project skill doc, explicitly suggest adding one.

