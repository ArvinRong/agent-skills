param(
    [Alias("repo-root")]
    [string]$RepoRoot = ".",
    [Alias("skills-dir")]
    [string]$SkillsDir
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-SkillsDir {
    param([string]$RepoRootPath)

    $root = (Resolve-Path -LiteralPath $RepoRootPath).Path
    $candidates = @(
        (Join-Path $root "docs\skills"),
        (Join-Path $root "skills")
    )

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate -PathType Container) {
            return $candidate
        }
    }

    throw "Could not find docs/skills or skills under repository root: $root"
}

$resolvedSkillsDir = if ($SkillsDir) {
    (Resolve-Path -LiteralPath $SkillsDir).Path
} else {
    Resolve-SkillsDir -RepoRootPath $RepoRoot
}

$usagePath = Join-Path $resolvedSkillsDir "SKILL_USAGE.json"
$reportPath = Join-Path $resolvedSkillsDir "SKILL_USAGE.md"

if (-not (Test-Path -LiteralPath $usagePath -PathType Leaf)) {
    throw "Usage file not found: $usagePath"
}

$usageData = Get-Content -LiteralPath $usagePath -Raw | ConvertFrom-Json
$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add("# Skill Usage")
$lines.Add("")
$lines.Add("This Markdown file is an optional human-readable report derived from ``SKILL_USAGE.json``.")
$lines.Add("")
$lines.Add("Prefer ``SKILL_USAGE.json`` as the structured source of truth for updates and automation. Regenerate this file after updating the JSON data.")
$lines.Add("")
$lines.Add("| Skill ID | File | used_count | helpful_count | not_useful_count | not_useful_reasons | last_used_at | notes |")
$lines.Add("|---|---|---:|---:|---:|---|---|---|")

foreach ($entry in @($usageData.skills)) {
    $reasons = if (@($entry.not_useful_reasons).Count -gt 0) { @($entry.not_useful_reasons) -join "," } else { "-" }
    $lastUsedAt = if ($entry.last_used_at) { $entry.last_used_at } else { "-" }
    $notesText = if ($entry.notes) { ($entry.notes -replace "`r?`n", " ") } else { "-" }
    $lines.Add("| ``$($entry.skill_id)`` | ``$($entry.file)`` | $($entry.used_count) | $($entry.helpful_count) | $($entry.not_useful_count) | $reasons | $lastUsedAt | $notesText |")
}

$lines.Add("")
$lines.Add("## Recommended reason labels")
$lines.Add("")
foreach ($label in @($usageData.recommended_reason_labels)) {
    $lines.Add("- ``$label``")
}

[System.IO.File]::WriteAllLines($reportPath, $lines, [System.Text.UTF8Encoding]::new($false))
Write-Host "Refreshed $reportPath"
