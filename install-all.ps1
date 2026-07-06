# Moon ecosystem installer (Windows)
# Usage: irm https://raw.githubusercontent.com/nnxlxde-stack/moon-setup/main/install-all.ps1 | iex
param(
    [switch]$SkipVscode,
    [string]$Tag = ""
)

$ErrorActionPreference = "Stop"

function Resolve-MoonSetupRoot {
    if ($PSScriptRoot) { return $PSScriptRoot }

    # irm | iex runs in memory — $PSScriptRoot is empty; download scripts to temp.
    $bootstrap = Join-Path $env:TEMP "moon-setup"
    Write-Host "==> Bootstrapping moon-setup -> $bootstrap" -ForegroundColor Cyan

    $base = "https://raw.githubusercontent.com/nnxlxde-stack/moon-setup/main"
    $files = @(
        "lib/common.ps1",
        "scripts/install-moon.ps1",
        "scripts/install-vscode.ps1",
        "scripts/verify.ps1"
    )

    foreach ($rel in $files) {
        $dest = Join-Path $bootstrap $rel
        $dir = Split-Path $dest -Parent
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Force -Path $dir | Out-Null
        }
        Invoke-WebRequest -Uri "$base/$rel" -OutFile $dest -UseBasicParsing `
            -Headers @{ "User-Agent" = "moon-setup" }
    }

    return $bootstrap
}

$Root = Resolve-MoonSetupRoot
& (Join-Path $Root "scripts\install-moon.ps1") -Tag $Tag
if (-not $SkipVscode) {
    & (Join-Path $Root "scripts\install-vscode.ps1")
}
& (Join-Path $Root "scripts\verify.ps1")
Write-Host "`nDone. Docs: https://nnxlxde-stack.github.io/moon-lang/" -ForegroundColor Green