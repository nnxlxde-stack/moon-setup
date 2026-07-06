# Moon ecosystem updater (Windows)
# Usage: irm https://raw.githubusercontent.com/nnxlxde-stack/moon-setup/main/update-all.ps1 | iex
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

& (Join-Path $Root "scripts\update-moon.ps1") -Tag $Tag
if (-not $SkipVscode) {
    & (Join-Path $Root "scripts\update-vscode.ps1") -Editor $Editor -NonInteractive:$NonInteractive
}
& (Join-Path $Root "scripts\verify.ps1")
Write-Host "`nDone. Docs: https://nnxlxde-stack.github.io/moon-lang/" -ForegroundColor Green