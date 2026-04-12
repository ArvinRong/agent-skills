Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$core = Join-Path $root "core\project-skill-finder"
$dist = Join-Path $root "dist"

function Reset-Directory {
    param([string]$Path)

    if (Test-Path -LiteralPath $Path) {
        Remove-Item -LiteralPath $Path -Recurse -Force
    }
    New-Item -ItemType Directory -Force -Path $Path | Out-Null
}

function Copy-CoreSkill {
    param([string]$SkillDir)

    Reset-Directory -Path $SkillDir
    foreach ($item in Get-ChildItem -Force -Path $core) {
        if ($item.Name -eq "templates") {
            continue
        }
        Copy-Item -LiteralPath $item.FullName -Destination $SkillDir -Recurse -Force
    }
}

$codexSkill = Join-Path $dist "codex\.agents\skills\project-skill-finder"
$claudeSkill = Join-Path $dist "claude\.claude\skills\project-skill-finder"
$copilotSkill = Join-Path $dist "copilot\.github\skills\project-skill-finder"

Copy-CoreSkill -SkillDir $codexSkill
Copy-CoreSkill -SkillDir $claudeSkill
Copy-CoreSkill -SkillDir $copilotSkill

$codexAgentsDir = Join-Path $codexSkill "agents"
New-Item -ItemType Directory -Force -Path $codexAgentsDir | Out-Null
Copy-Item -LiteralPath (Join-Path $root "adapters\codex\agents\openai.yaml") -Destination (Join-Path $codexAgentsDir "openai.yaml") -Force

Copy-Item -LiteralPath (Join-Path $root "adapters\claude\SKILL.md") -Destination (Join-Path $claudeSkill "SKILL.md") -Force
Copy-Item -LiteralPath (Join-Path $root "adapters\copilot\SKILL.md") -Destination (Join-Path $copilotSkill "SKILL.md") -Force

$copilotRoot = Join-Path $dist "copilot\.github"
New-Item -ItemType Directory -Force -Path $copilotRoot | Out-Null
Copy-Item -LiteralPath (Join-Path $root "adapters\copilot\copilot-instructions.md") -Destination (Join-Path $copilotRoot "copilot-instructions.md") -Force

Write-Host "Built dist packages under $dist"
