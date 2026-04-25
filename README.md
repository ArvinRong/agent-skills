# agent-skills

[English](./README.md) | [简体中文](./README.zh-CN.md)

A collection of practical AI agent skills for real-world development workflows.

`agent-skills` is a collection of practical AI agent skills, starter kits, and reusable patterns for real-world development workflows. It focuses on ideas that can actually live inside projects, evolve with code, and improve through repeated use.

## Subprojects

### `project_skills_finder`

A starter pattern for building an evolvable AI skills layer for software projects.

It combines:

- a shared core skill for maintainers
- ready-to-copy `dist/` packages for Codex, Claude Code, and GitHub Copilot
- project-local `docs/skills/` knowledge
- structured usage tracking with `SKILL_USAGE.json`
- a generated Markdown report with `SKILL_USAGE.md`

See [project_skills_finder/README.md](./project_skills_finder/README.md) for details.

### `serena_lsp_companion`

A narrow skill for using Serena as an LSP-style companion during repository development.

It focuses on symbol overview, definition lookup, references, safe rename, and safe delete, while keeping text search, logs, tests, and normal edits with the host agent's regular tools.

See [serena_lsp_companion/README.md](./serena_lsp_companion/README.md) for details.

## License

MIT
