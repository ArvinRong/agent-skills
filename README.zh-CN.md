# agent-skills

[English](./README.md) | [简体中文](./README.zh-CN.md)

一个面向真实开发工作流的 AI Agent Skills、starter kit 和可复用模式集合。

`agent-skills` 关注的是那些真正能落在项目里、能随着代码演进、也能在反复使用中持续优化的方法，而不只是孤立的演示。

## 子项目

### `project_skills_finder`

一个用于构建“可演进项目 Skills 层”的起始模式。

它结合了：

- 一个供维护者复用的共享 core skill
- 面向 Codex、Claude Code、GitHub Copilot 的可直接复制 `dist/` 安装包
- 项目内版本化的 `docs/skills/` 知识入口
- 基于 `SKILL_USAGE.json` 的结构化效果反馈
- 基于 `SKILL_USAGE.md` 的 Markdown 报表

详情见 [project_skills_finder/README.zh-CN.md](./project_skills_finder/README.zh-CN.md)。

## License

MIT
