# Moon ecosystem installer (Windows)
# Usage: irm https://raw.githubusercontent.com/nnxlxde-stack/moon-setup/main/install-all.ps1 | iex
param(
    [switch]$SkipVscode,
    [string]$Tag = "",
    [ValidateSet("", "code", "code-insiders", "cursor")]
    [string]$Editor = "",
    [switch]$NonInteractive
)

$ErrorActionPreference = "Stop"

$stagingBootstrap = Join-Path $env:TEMP "moon-setup\lib\bootstrap.ps1"
if ($PSScriptRoot -and (Test-Path (Join-Path $PSScriptRoot "lib\bootstrap.ps1"))) {
    . (Join-Path $PSScriptRoot "lib\bootstrap.ps1")
    $Root = Import-MoonSetupBootstrap -CallerScriptRoot $PSScriptRoot
} else {
    New-Item -ItemType Directory -Force -Path (Split-Path $stagingBootstrap) | Out-Null
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/nnxlxde-stack/moon-setup/main/lib/bootstrap.ps1" `
        -OutFile $stagingBootstrap -UseBasicParsing -Headers @{ "User-Agent" = "moon-setup" }
    . $stagingBootstrap
    $Root = Import-MoonSetupBootstrap -CallerScriptRoot ""
}

& (Join-Path $Root "scripts\install-moon.ps1") -Tag $Tag
if (-not $SkipVscode) {
    & (Join-Path $Root "scripts\install-vscode.ps1") -Editor $Editor -NonInteractive:$NonInteractive
}
& (Join-Path $Root "scripts\verify.ps1")

Write-Host ""
Write-Host "Tip: interactive manager:" -ForegroundColor DarkGray
Write-Host "  irm https://raw.githubusercontent.com/nnxlxde-stack/moon-setup/main/moon-manage.ps1 | iex" -ForegroundColor DarkGray
Write-Host "Done. Docs: https://nnxlxde-stack.github.io/moon-lang/" -ForegroundColor Green