Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

if (-not $env:SERENA_LSP_COMPANION_BUILD_INLINE) {
    if (-not $PSCommandPath) {
        throw "Could not determine the current build_dist.ps1 path."
    }

    $env:SERENA_LSP_COMPANION_BUILD_INLINE = "1"
    $env:SERENA_LSP_COMPANION_ROOT = Split-Path -Parent $PSCommandPath
    $scriptText = Get-Content -LiteralPath $PSCommandPath -Raw
    $encoded = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($scriptText))
    & powershell -ExecutionPolicy Bypass -EncodedCommand $encoded
    exit $LASTEXITCODE
}

if (-not $env:SERENA_LSP_COMPANION_ROOT -and -not $PSCommandPath) {
    throw "Could not determine the current build_dist.ps1 path."
}

$root = if ($env:SERENA_LSP_COMPANION_ROOT) { $env:SERENA_LSP_COMPANION_ROOT } else { Split-Path -Parent $PSCommandPath }
$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
    $python = Get-Command py -ErrorAction SilentlyContinue
}
if (-not $python) {
    throw "Python was not found on PATH."
}

& $python.Source (Join-Path $root "build_dist.py")
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

$dist = Join-Path $root "dist"
if (Test-Path -LiteralPath $dist) {
    Get-ChildItem -LiteralPath $dist -Recurse -File -Force | Unblock-File
}
