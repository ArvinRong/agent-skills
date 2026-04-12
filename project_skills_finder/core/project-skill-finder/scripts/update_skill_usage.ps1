param(
    [Alias("repo-root")]
    [string]$RepoRoot = ".",
    [Alias("skills-dir")]
    [string]$SkillsDir,
    [Alias("skill-id")]
    [Parameter(Mandatory = $true)]
    [string]$SkillId,
    [Parameter(Mandatory = $true)]
    [string]$File,
    [ValidateSet("used", "helpful", "not-useful")]
    [string]$Result = "used",
    [string[]]$Reason = @(),
    [string]$Notes,
    [Alias("no-report")]
    [switch]$NoReport
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

function Ensure-NoteProperty {
    param(
        [object]$InputObject,
        [string]$Name,
        $Value
    )

    if (-not ($InputObject.PSObject.Properties.Name -contains $Name)) {
        Add-Member -InputObject $InputObject -MemberType NoteProperty -Name $Name -Value $Value
    }
}

$resolvedSkillsDir = if ($SkillsDir) {
    (Resolve-Path -LiteralPath $SkillsDir).Path
} else {
    Resolve-SkillsDir -RepoRootPath $RepoRoot
}

$usagePath = Join-Path $resolvedSkillsDir "SKILL_USAGE.json"

if (-not (Test-Path -LiteralPath $usagePath -PathType Leaf)) {
    throw "Usage file not found: $usagePath"
}

$usageData = Get-Content -LiteralPath $usagePath -Raw | ConvertFrom-Json
Ensure-NoteProperty -InputObject $usageData -Name "skills" -Value @()
Ensure-NoteProperty -InputObject $usageData -Name "recommended_reason_labels" -Value @()

$entry = @($usageData.skills) | Where-Object { $_.skill_id -eq $SkillId } | Select-Object -First 1
if (-not $entry) {
    $entry = [pscustomobject]@{
        skill_id = $SkillId
        file = $File
        used_count = 0
        helpful_count = 0
        not_useful_count = 0
        not_useful_reasons = @()
        last_used_at = $null
        notes = ""
    }
    $usageData.skills = @($usageData.skills) + $entry
}

Ensure-NoteProperty -InputObject $entry -Name "file" -Value $File
Ensure-NoteProperty -InputObject $entry -Name "not_useful_reasons" -Value @()

if (-not $entry.file) {
    $entry.file = $File
}

$entry.used_count = [int]$entry.used_count + 1
switch ($Result) {
    "helpful" {
        $entry.helpful_count = [int]$entry.helpful_count + 1
    }
    "not-useful" {
        $entry.not_useful_count = [int]$entry.not_useful_count + 1
        $existingReasons = @($entry.not_useful_reasons)
        foreach ($reasonLabel in $Reason) {
            if ($existingReasons -notcontains $reasonLabel) {
                $existingReasons += $reasonLabel
            }
        }
        $entry.not_useful_reasons = $existingReasons
    }
}

$entry.last_used_at = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
if ($PSBoundParameters.ContainsKey("Notes")) {
    $entry.notes = $Notes
}

$usageData | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $usagePath -Encoding UTF8
Write-Host "Updated $usagePath"

if (-not $NoReport) {
    $syncScript = Join-Path $PSScriptRoot "sync_skill_usage_report.ps1"
    & $syncScript -skills-dir $resolvedSkillsDir
}
