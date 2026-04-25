---
name: serena-lsp-companion
description: "Use automatically on repository development tasks when the agent needs LSP-style code intelligence: symbol overview, definition lookup, reference analysis, safe rename, safe delete, or deciding whether to use rg/grep/file reads versus Serena symbol tools. Trigger for coding, refactoring, bug fixing, code review, call-site checks, API/interface changes, renaming symbols, deleting dead code, and large-file navigation. Do not use for general chat, pure log analysis, config-only edits, CSS/UI copy-only edits, or non-code work."
license: MIT
---

# Serena LSP Companion

Use Serena as a narrow LSP-style companion. Do not treat it as a general search engine, memory system, or replacement for tests, logs, and normal edits.

## Hard Tool Allowlist

Serena may appear as a named MCP namespace, a grouped tool collection, or a flat list of individual tools depending on the host. Identify Serena tools by their MCP server/namespace when visible, or by these function names when only a flat tool list is shown.

When this skill is active, only these Serena MCP tools are allowed:

- `activate_project`
- `get_current_config`
- `get_symbols_overview`
- `find_symbol`
- `find_referencing_symbols`
- `rename_symbol`
- `safe_delete_symbol`
- `search_for_pattern`

Treat all other tools from the Serena MCP server as unavailable, even if the host exposes them. This skill is an instruction-level guardrail, not a technical sandbox; strict enforcement requires configuring Serena/MCP to expose only the allowlisted tools or routing Serena through a wrapper.

Do not call memory tools, onboarding tools, or Serena symbol-body editing tools such as `replace_symbol_body`, `insert_before_symbol`, and `insert_after_symbol`. If a task appears to need a blocked Serena tool, use the host agent's normal tools instead. Do not temporarily expand this allowlist.

## Default Workflow

1. Use `rg` first for broad repo discovery unless the exact file and symbol are already known.
2. Use Serena after there is a concrete code file, symbol name, or symbol candidate.
3. Use `get_symbols_overview` before reading a large code file.
4. Use `find_symbol` for exact definitions and symbol bodies.
5. Use `find_referencing_symbols` before changing shared symbols or public interfaces.
6. Use `rename_symbol` only when the language service identifies the target cleanly.
7. Use `safe_delete_symbol` only after `rg` suggests the symbol is probably dead.
8. Read exact local file context before editing, then validate with tests, builds, type checks, or logs.

## Tool Boundaries

Use `rg` as the default text search tool for files, keywords, old concept residue, JSON/YAML/CSS/config/tests/snapshots/prompts/fixtures/logs/traces, cross-language scans, and cleanup verification.

Use `grep` only as a fallback when `rg` is unavailable, or for small Unix-style pipelines.

Use `Get-Content` in PowerShell and `cat` in Unix-like shells when the file path is known and exact text is needed.

Use Serena `search_for_pattern` only when the result will feed into `find_symbol`, `find_referencing_symbols`, `rename_symbol`, or `safe_delete_symbol`. Do not use it as a blanket replacement for `rg`.

## Serena LSP Rules

Use `get_symbols_overview` for file structure, especially before splitting large files or deciding module boundaries.

Use `find_symbol` for definitions and symbol bodies. Prefer narrow `relative_path` values. In CommonJS or dynamic module files, watch for duplicate matches such as a function definition plus a `module.exports` property.

Use `find_referencing_symbols` for code references. It is not a full-text search and may miss dynamic string-based usage.

Use `rename_symbol` for language-service-backed rename. Use `safe_delete_symbol` for dead-code cleanup. After either operation, run `rg` for residue and run relevant validation.

## Editing Policy

Allowed Serena write operations are only `rename_symbol` and `safe_delete_symbol`.

Use the host agent's normal editing tools for local line edits, new helpers, function body replacement, import updates, JSON, YAML, CSS, Markdown, prompts, tests, fixtures, snapshots, and generated artifacts.

## Copilot And Codebase Search

Treat Copilot or other agent codebase tools as semantic recall and context-building systems. They are useful for finding likely relevant code.

Treat Serena as the LSP companion for precise definition, reference, rename, safe-delete, and file-symbol-overview operations. Use the host agent's codebase tools or `rg` to discover candidates; use Serena to confirm symbol boundaries and references; use normal reads/edits for exact patches; use tests and logs to verify behavior.

## When Not To Use Serena

Do not force Serena into tasks dominated by logs, traces, build output, JSON/config editing, CSS/UI copy, prompt text, data files, fixtures, OOXML/docx internals, snapshots, binary-derived artifacts, or small isolated edits where the file and line are already obvious.
