# Project Skills Index

This is the main entry for project-local skill docs.

Use this file to help an agent or collaborator choose which project skill docs to read first.

## Routing Index

```yaml
skills:
  - id: example-module
    file: EXAMPLE_MODULE_SKILL.md
    title: Example Module Skill
    purpose: Navigate the example module's entrypoints, tests, and common failure modes.
    when_to_use:
      - implementing changes in the example module
      - debugging example module behavior or tests
      - reviewing boundaries around the example module
    keywords:
      - example
      - module
      - tests
    priority: medium
```

Use this YAML block as the router-friendly summary. Keep it short, stable, and focused on deciding which docs to read next.

## Human Index

| Skill ID | Skill | Purpose | When to use | Keywords |
|---|---|---|---|---|
| `example-module` | [EXAMPLE_MODULE_SKILL](./EXAMPLE_MODULE_SKILL.md) | Navigate the example module's entrypoints, tests, and common failure modes | Implementing changes, debugging tests, or reviewing boundaries in the example module | `example`, `module`, `tests` |

## Notes

- Keep this file short
- Keep the YAML block and table aligned
- Prefer routing over duplication
- Point to the minimum set of useful project docs
- Do not list control docs such as `SKILL_USAGE.json` or `SKILL_USAGE.md` here
