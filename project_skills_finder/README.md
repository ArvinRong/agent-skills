# project_skills_finder

[English](./README.md) | [简体中文](./README.zh-CN.md)

`project_skills_finder` is a starter pattern for building an evolvable AI skills layer inside real software projects.

It separates three concerns:

1. A thin global router skill discovers project-local skill docs
2. The project keeps its own knowledge in versioned `docs/skills/` or `skills/`
3. Usage tracking feeds back into the docs over time

## Repository layout

This subproject is organized for both maintainers and end users:

- `core/project-skill-finder/`
  - shared skill source used across agents
- `adapters/`
  - agent-specific metadata or companion files
- `dist/`
  - ready-to-copy install layouts for each agent
- `build_dist.py`
  - regenerates `dist/` from `core/` plus `adapters/`

End users should copy from `dist/`. Maintainers should edit `core/` and `adapters/`, then rebuild `dist/`.

## Agent-specific config choices

- Codex:
  - keeps the shared `SKILL.md`
  - adds `agents/openai.yaml`
  - explicitly enables implicit invocation in adapter metadata
- Claude Code:
  - uses an adapter `SKILL.md`
  - hides the router from the slash menu with `user-invocable: false`
- GitHub Copilot:
  - uses an adapter `SKILL.md`
  - adds `license: MIT`
  - ships an optional `.github/copilot-instructions.md`

By default, Claude Code and Copilot do not pre-approve broad shell access for this router skill. Since it can trigger on many repository tasks, enabling `allowed-tools` too broadly would be riskier than it is helpful in the default distribution.

## Install for each agent

### Codex

Copy:

```text
dist/codex/.agents/skills/project-skill-finder/
```

into your Codex skills location, for example:

- repo-level: `.agents/skills/project-skill-finder`
- user-level: `~/.agents/skills/project-skill-finder`

### Claude Code

Copy:

```text
dist/claude/.claude/skills/project-skill-finder/
```

into:

- project-level: `.claude/skills/project-skill-finder`
- personal-level: `~/.claude/skills/project-skill-finder`

### GitHub Copilot

Copy:

```text
dist/copilot/.github/skills/project-skill-finder/
```

into your repository at:

- `.github/skills/project-skill-finder`

If you also want the optional repository-wide hint file, copy:

```text
dist/copilot/.github/copilot-instructions.md
```

into `.github/copilot-instructions.md`.

## How it works

```mermaid
flowchart LR
    A["Router Skill<br/>project-skill-finder"] --> B["Project Skills Index<br/>docs/skills/INDEX.md"]
    B --> C["Relevant Skill Docs<br/>docs/skills/*.md"]
    C --> D["Actual Project Work"]
    C --> E["Structured Usage Data<br/>SKILL_USAGE.json"]
    E --> C
```

The global skill does not carry project knowledge itself. It only helps the agent discover project-local docs, load the minimum relevant ones, and keep a lightweight usefulness signal over time.

## Core skill contents

The shared core skill contains:

- `SKILL.md`
  - host-neutral routing instructions
- `templates/docs/skills/`
  - starter files for project-local skills
- `scripts/update_skill_usage.ps1`
  - PowerShell updater for Windows or PowerShell-first environments
- `scripts/update_skill_usage.sh`
  - shell updater for macOS, Linux, or WSL
- `scripts/update_skill_usage.py`
  - optional fallback implementation for Python-based environments
- `scripts/sync_skill_usage_report.*`
  - dedicated tools that regenerate `SKILL_USAGE.md` from `SKILL_USAGE.json`

## Project-local files

In a project, the skill expects something like:

```text
docs/
  skills/
    INDEX.md
    SKILL_USAGE.json
    SKILL_USAGE.md
    rendering.md
    ssh-runtime.md
```

The project-local docs remain the source of truth. The global router only helps an agent discover and use them.

## Usage tracking

`SKILL_USAGE.json` is the structured source of truth.

`SKILL_USAGE.md` is the human-readable report regenerated from the JSON data.

The default tracking fields are:

- `skill_id`
- `file`
- `used_count`
- `helpful_count`
- `not_useful_count`
- `not_useful_reasons`
- `last_used_at`
- `notes`

Recommended `not_useful_reasons` labels:

- `description_unclear`
- `wrong_trigger`
- `outdated_content`
- `missing_key_files`
- `too_shallow`
- `too_broad`
- `poor_examples`

## Rebuild dist

After editing `core/` or `adapters/`, rebuild the installable outputs:

```bash
./project_skills_finder/build_dist.sh
```

On Windows, you can also run:

```powershell
.\project_skills_finder\build_dist.ps1
```

## Extend to another agent

To support another tool:

1. Reuse `core/project-skill-finder/`
2. Add a new adapter under `adapters/<tool>/`
3. Teach `build_dist.py` how to emit the install layout into `dist/<tool>/`

This keeps the shared skill logic in one place while letting each agent keep its own install path and host-specific metadata.
