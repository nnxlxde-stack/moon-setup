# Moon ecosystem uninstaller (Windows)
# Usage: irm https://raw.githubusercontent.com/nnxlxde-stack/moon-setup/main/uninstall-all.ps1 | iex
param(
    [switch]$SkipVscode,
    [switch]$Force,
    [ValidateSet("", "code", "code-insiders", "cursor")]
    [string]$Editor = "",
    [switch]$AllEditors,
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

if (-not $Force -and -not $NonInteractive) {
    Write-Host "This will remove Moon toolchain from %APPDATA%\Moon" -ForegroundColor Yellow
    if (-not $SkipVscode) {
        Write-Host "and uninstall the Moon VS Code extension." -ForegroundColor Yellow
    }
    $confirm = Read-Host "Continue? [y/N]"
    if ($confirm -notmatch '^[yY]') {
        Write-Host "Cancelled." -ForegroundColor Yellow
        return
    }
}

if (-not $SkipVscode) {
    $uninstallArgs = @{ NonInteractive = $true }
    if ($Editor) { $uninstallArgs.Editor = $Editor }
    if ($AllEditors) { $uninstallArgs.All = $true }
    & (Join-Path $Root "scripts\uninstall-vscode.ps1") @uninstallArgs
}
& (Join-Path $Root "scripts\uninstall-moon.ps1")
& (Join-Path $Root "scripts\verify.ps1")
Write-Host "`nMoon uninstalled." -ForegroundColor Green