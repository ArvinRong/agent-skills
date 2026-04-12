# Repository Agent Guidance

This repository uses project-local skill docs to organize domain knowledge for AI collaboration.

When a task touches implementation, debugging, testing, architecture, deployment, rendering, SSH, vault, commands, or other repository-specific workflows:

- prefer checking `docs/skills/INDEX.md` first when it exists
- then read only the most relevant 1-2 docs from `docs/skills/` or `skills/`
- treat project-local docs as the source of truth
- avoid bulk-loading unrelated project skill docs

When a project-local skill doc materially helps a task, prefer updating `docs/skills/SKILL_USAGE.json` or `skills/SKILL_USAGE.json` through the bundled `update_skill_usage.py` script instead of editing tracking files by hand.
