Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not $env:PROJECT_SKILLS_FINDER_BUILD_INLINE) {
    if (-not $PSCommandPath) {
        throw "Could not determine the current build_dist.ps1 path."
    }

    $env:PROJECT_SKILLS_FINDER_BUILD_INLINE = "1"
    $env:PROJECT_SKILLS_FINDER_ROOT = Split-Path -Parent $PSCommandPath
    $scriptText = Get-Content -LiteralPath $PSCommandPath -Raw
    $encoded = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($scriptText))
    & powershell -ExecutionPolicy Bypass -EncodedCommand $encoded
    exit $LASTEXITCODE
}

$root = if ($env:PROJECT_SKILLS_FINDER_ROOT) { $env:PROJECT_SKILLS_FINDER_ROOT } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$core = Join-Path $root "core\project-skill-finder"
$dist = Join-Path $root "dist"
$coreSkillFile = Join-Path $core "SKILL.md"

function Ensure-Directory {
    param([string]$Path)

    if (Test-Path -LiteralPath $Path) {
        return
    }

    $pending = [System.Collections.Generic.List[string]]::new()
    $current = $Path
    while ($current -and -not (Test-Path -LiteralPath $current)) {
        $pending.Add($current)
        $current = Split-Path -Path $current -Parent
    }

    for ($index = $pending.Count - 1; $index -ge 0; $index--) {
        [System.IO.Directory]::CreateDirectory($pending[$index]) | Out-Null
    }
}

function Reset-Directory {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        Ensure-Directory -Path $Path
        return
    }

    foreach ($file in Get-ChildItem -LiteralPath $Path -Force -Recurse -File) {
        Remove-Item -LiteralPath $file.FullName -Force
    }

    $directories = Get-ChildItem -LiteralPath $Path -Force -Recurse -Directory | Sort-Object FullName -Descending
    foreach ($directory in $directories) {
        if (Test-Path -LiteralPath $directory.FullName) {
            [System.IO.Directory]::Delete($directory.FullName, $false)
        }
    }
}

function Copy-CoreSkill {
    param([string]$SkillDir)

    Ensure-Directory -Path $SkillDir
    foreach ($item in Get-ChildItem -Force -Path $core) {
        if ($item.Name -eq "templates") {
            continue
        }
        $destination = Join-Path $SkillDir $item.Name
        if ($item.PSIsContainer) {
            Ensure-Directory -Path $destination
            foreach ($child in Get-ChildItem -Force -LiteralPath $item.FullName) {
                Copy-Item -LiteralPath $child.FullName -Destination $destination -Recurse -Force
            }
        } else {
            Copy-Item -LiteralPath $item.FullName -Destination $destination -Force
        }
    }
}

function Write-AdaptedSkill {
    param(
        [string]$SkillDir,
        [string]$AdapterFrontmatterPath
    )

    if (-not (Test-Path -LiteralPath $coreSkillFile -PathType Leaf)) {
        throw "Core SKILL.md not found: $coreSkillFile"
    }

    if (-not $AdapterFrontmatterPath -or -not (Test-Path -LiteralPath $AdapterFrontmatterPath -PathType Leaf)) {
        return
    }

    $coreContent = Get-Content -LiteralPath $coreSkillFile -Raw
    $adapterContent = (Get-Content -LiteralPath $AdapterFrontmatterPath -Raw).Trim()

    if (-not $adapterContent) {
        return
    }

    $newline = if ($coreContent.Contains("`r`n")) { "`r`n" } else { "`n" }
    $match = [regex]::Match(
        $coreContent,
        "^(?:---\r?\n)(?<front>.*?)(?:\r?\n---\r?\n)(?<body>.*)$",
        [System.Text.RegularExpressions.RegexOptions]::Singleline
    )

    if (-not $match.Success) {
        throw "Core SKILL.md is missing a valid frontmatter block: $coreSkillFile"
    }

    $frontmatter = $match.Groups["front"].Value.TrimEnd()
    $body = $match.Groups["body"].Value
    $merged = @(
        "---"
        $frontmatter
        $adapterContent
        "---"
        $body
    ) -join $newline

    [System.IO.File]::WriteAllText((Join-Path $SkillDir "SKILL.md"), $merged, [System.Text.UTF8Encoding]::new($false))
}

function Convert-ToWslPath {
    param([string]$WindowsPath)

    if ($WindowsPath -match '^([A-Za-z]):\\(.*)$') {
        $drive = $matches[1].ToLowerInvariant()
        $rest = $matches[2] -replace '\\', '/'
        return "/mnt/$drive/$rest"
    }

    throw "Could not convert Windows path to WSL path: $WindowsPath"
}

function Build-DistNative {
    $codexSkill = Join-Path $dist "codex\.agents\skills\project-skill-finder"
    $claudeSkill = Join-Path $dist "claude\.claude\skills\project-skill-finder"
    $copilotSkill = Join-Path $dist "copilot\.github\skills\project-skill-finder"

    Copy-CoreSkill -SkillDir $codexSkill
    Copy-CoreSkill -SkillDir $claudeSkill
    Copy-CoreSkill -SkillDir $copilotSkill

    $codexAgentsDir = Join-Path $codexSkill "agents"
    Ensure-Directory -Path $codexAgentsDir
    Copy-Item -LiteralPath (Join-Path $root "adapters\codex\agents\openai.yaml") -Destination (Join-Path $codexAgentsDir "openai.yaml") -Force

    Write-AdaptedSkill -SkillDir $claudeSkill -AdapterFrontmatterPath (Join-Path $root "adapters\claude\frontmatter.append.yaml")
    Write-AdaptedSkill -SkillDir $copilotSkill -AdapterFrontmatterPath (Join-Path $root "adapters\copilot\frontmatter.append.yaml")

    $copilotRoot = Join-Path $dist "copilot\.github"
    Ensure-Directory -Path $copilotRoot
    Copy-Item -LiteralPath (Join-Path $root "adapters\copilot\copilot-instructions.md") -Destination (Join-Path $copilotRoot "copilot-instructions.md") -Force
}

try {
    Build-DistNative
    Write-Host "Built dist packages under $dist"
} catch {
    $wsl = Get-Command "wsl.exe" -ErrorAction SilentlyContinue
    if ($wsl -and -not $env:PROJECT_SKILLS_FINDER_WSL_FALLBACK_ATTEMPTED) {
        $env:PROJECT_SKILLS_FINDER_WSL_FALLBACK_ATTEMPTED = "1"
        Write-Warning "Native PowerShell build failed. Falling back to WSL build_dist.sh."
        $wslRoot = Convert-ToWslPath -WindowsPath $root
        & $wsl.Source sh -lc "cd '$wslRoot' && sh ./build_dist.sh"
        if ($LASTEXITCODE -ne 0) {
            throw "WSL fallback build failed with exit code $LASTEXITCODE"
        }
        Write-Host "Built dist packages under $dist (via WSL fallback)"
    } else {
        throw
    }
}
