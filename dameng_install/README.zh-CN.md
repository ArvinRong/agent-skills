# dameng_install

[English](./README.md) | [简体中文](./README.zh-CN.md)

Linux 单机达梦 DM8 安装 skill，覆盖安装介质与服务器检查、磁盘挂载和目录建议、配置选项说明、逐项确认、交互安装、断线续装、版本差异、运行参数验收和部署交付。

维护入口为 [core/dameng-install/SKILL.md](./core/dameng-install/SKILL.md)。生产环境事实和真实凭据不属于这个skill；每次安装均从实际目标采集。

## 分发目录

| Agent | 可复制的完整skill目录 |
| --- | --- |
| Codex | `dist/codex/.agents/skills/dameng-install/` |
| Claude Code | `dist/claude/.claude/skills/dameng-install/` |
| GitHub Copilot | `dist/copilot/.github/skills/dameng-install/` |

复制对应的完整目录到宿主的skill目录。Codex用户级可使用 `~/.codex/skills/dameng-install`，项目级可使用 `.agents/skills/dameng-install`；其他宿主使用相应的项目skill位置。仅创建此仓库不会自动安装到当前Codex。

调用示例：

```text
使用 $dameng-install 检查目标麒麟服务器。ISO在我指定的远端路径，先分析资源和磁盘挂载，给出目录建议，逐项解释并确认配置，然后交互安装。
```

也可只请求检查、配置对比或续装。skill会保留该范围，不把检查请求自动变成安装。

## 维护与生成分发副本

修改 `core/dameng-install/`，Codex UI元数据修改 `adapters/codex/agents/openai.yaml`。在本目录执行以下PowerShell，更新三个分发副本：

```powershell
$packageRoot = (Get-Location).Path
$corePath = Join-Path $packageRoot 'core/dameng-install'
$layouts = @{
    codex = 'dist/codex/.agents/skills/dameng-install'
    claude = 'dist/claude/.claude/skills/dameng-install'
    copilot = 'dist/copilot/.github/skills/dameng-install'
}
foreach ($layout in $layouts.Values) {
    $destination = Join-Path $packageRoot $layout
    New-Item -ItemType Directory -Path $destination -Force | Out-Null
    foreach ($item in Get-ChildItem -LiteralPath $corePath -Force) {
        Copy-Item -LiteralPath $item.FullName -Destination $destination -Recurse -Force
    }
}
$agentsPath = Join-Path $packageRoot 'dist/codex/.agents/skills/dameng-install/agents'
New-Item -ItemType Directory -Path $agentsPath -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $packageRoot 'adapters/codex/agents/openai.yaml') -Destination $agentsPath -Force
```

该同步只复制/更新文件，不删除文件；若core删除或重命名资源，应同步检查并移除分发副本里的旧文件。验收SQL是已认证会话中的只读查询，仍需根据安装版本的视图列适配，不能在创建skill时自动连接生产数据库验证。
