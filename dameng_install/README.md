# dameng_install

[English](./README.md) | [简体中文](./README.zh-CN.md)

A reusable skill for interactive installation and initialization of a standalone DM8 database on Linux, including Kylin and openEuler.

The workflow checks the installation media, server resources and mounted storage, explains configuration choices and their effects, confirms the user's choices, installs interactively, verifies runtime settings and produces a deployment handover when requested. It also covers interrupted installations and version-specific parameter constraints.

The shared source is [core/dameng-install/SKILL.md](./core/dameng-install/SKILL.md). Instructions are in Chinese. Environment addresses, real credentials and license files are deliberately excluded.

| Agent | Ready-to-copy skill directory |
| --- | --- |
| Codex | `dist/codex/.agents/skills/dameng-install/` |
| Claude Code | `dist/claude/.claude/skills/dameng-install/` |
| GitHub Copilot | `dist/copilot/.github/skills/dameng-install/` |

Copy the complete directory to your agent's skill location. For Codex, examples are `~/.codex/skills/dameng-install` for personal use or `.agents/skills/dameng-install` for project use. Creating the package does not automatically install it into the running agent.

Edit `core/dameng-install/` and the Codex metadata under `adapters/`. The [Chinese packaging guide](./README.zh-CN.md) contains the PowerShell commands for regenerating the distribution copies. No build dependency is required.
