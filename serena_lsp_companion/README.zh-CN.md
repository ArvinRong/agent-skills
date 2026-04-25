# serena_lsp_companion

[English](./README.md) | [简体中文](./README.zh-CN.md)

`serena_lsp_companion` 是一个把 Serena 当作 LSP 风格能力使用的 AI Agent skill。

它不是通用搜索 skill。它会告诉 agent 什么时候应该用 Serena 做符号概览、定义查找、引用分析、安全重命名、安全删除，以及什么时候应该改用 `rg`、`grep`、`Get-Content`、`cat`、日志、测试或普通编辑工具。

这里不提供 Claude Code 分发版本，因为目标工作流里 Claude Code 已经有 LSP 方向的插件支持。

## 目录结构

- `core/serena-lsp-companion/`
  - 共享 skill 源码
- `adapters/`
  - Codex 和 GitHub Copilot 元数据
- `dist/`
  - 可直接复制安装的分发目录
- `build_dist.py`
  - 重新生成 `dist/`

## 安装

### Codex

复制：

```text
dist/codex/.agents/skills/serena-lsp-companion/
```

到 Codex skills 目录，例如：

- 仓库级：`.agents/skills/serena-lsp-companion`
- 用户级：`~/.agents/skills/serena-lsp-companion`
- 用户级：`~/.codex/skills/serena-lsp-companion`

### GitHub Copilot

复制：

```text
dist/copilot/.github/skills/serena-lsp-companion/
```

到：

- 项目级：`.github/skills/serena-lsp-companion`
- 用户级：`~/.copilot/skills/serena-lsp-companion`

## 重新生成 dist

修改 `core/` 或 `adapters/` 后运行：

```bat
.\build_dist.cmd
```

或显式用一次性的 PowerShell 执行策略运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\build_dist.ps1
```

或：

```bash
./build_dist.sh
```
