# serena_lsp_companion

[English](./README.md) | [简体中文](./README.zh-CN.md)

`serena_lsp_companion` packages a narrow AI-agent skill for using Serena as an LSP-style companion during software development.

It is intentionally not a general search skill. It tells agents when to use Serena for symbol overview, definition lookup, references, safe rename, and safe delete, and when to use `rg`, `grep`, `Get-Content`, `cat`, logs, tests, or normal editing tools instead.

Claude Code is not packaged here because Claude Code already has LSP-oriented plugin support in the target workflow.

## Layout

- `core/serena-lsp-companion/`
  - shared skill source
- `adapters/`
  - Codex and GitHub Copilot metadata
- `dist/`
  - ready-to-copy install layouts
- `build_dist.py`
  - regenerates `dist/`

## Install

### Codex

Copy:

```text
dist/codex/.agents/skills/serena-lsp-companion/
```

into a Codex skills location, for example:

- repo-level: `.agents/skills/serena-lsp-companion`
- user-level: `~/.agents/skills/serena-lsp-companion`
- user-level: `~/.codex/skills/serena-lsp-companion`

### GitHub Copilot

Copy:

```text
dist/copilot/.github/skills/serena-lsp-companion/
```

into:

- project-level: `.github/skills/serena-lsp-companion`
- user-level: `~/.copilot/skills/serena-lsp-companion`

## Rebuild dist

After editing `core/` or `adapters/`, rebuild:

```bat
.\build_dist.cmd
```

or run PowerShell with an explicit one-off execution policy:

```powershell
powershell -ExecutionPolicy Bypass -File .\build_dist.ps1
```

or:

```bash
./build_dist.sh
```
