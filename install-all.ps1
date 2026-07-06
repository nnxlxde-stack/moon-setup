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

if (-not (Get-Command Import-MoonSetupBootstrap -ErrorAction SilentlyContinue)) {
    if ($PSScriptRoot) {
        . (Join-Path $PSScriptRoot "lib\bootstrap.ps1")
    } else {
        $staging = Join-Path $env:TEMP "moon-setup"
        $bootstrapPath = Join-Path $staging "lib\bootstrap.ps1"
        if (-not (Test-Path $bootstrapPath)) {
            New-Item -ItemType Directory -Force -Path (Join-Path $staging "lib") | Out-Null
            Invoke-WebRequest -Uri "https://raw.githubusercontent.com/nnxlxde-stack/moon-setup/main/lib/bootstrap.ps1" `
                -OutFile $bootstrapPath -UseBasicParsing -Headers @{ "User-Agent" = "moon-setup" }
        }
        . $bootstrapPath
    }
}

$Root = Import-MoonSetupBootstrap -CallerScriptRoot $PSScriptRoot

& (Join-Path $Root "scripts\install-moon.ps1") -Tag $Tag
if (-not $SkipVscode) {
    & (Join-Path $Root "scripts\install-vscode.ps1") -Editor $Editor -NonInteractive:$NonInteractive
}
& (Join-Path $Root "scripts\verify.ps1")

Write-Host ""
if (-not $SkipVscode) {
    Write-Host "Tip: use moon-manage.ps1 for install/update/uninstall with a menu." -ForegroundColor DarkGray
    Write-Host "  irm https://raw.githubusercontent.com/nnxlxde-stack/moon-setup/main/moon-manage.ps1 | iex" -ForegroundColor DarkGray
}
Write-Host "Done. Docs: https://nnxlxde-stack.github.io/moon-lang/" -ForegroundColor Green