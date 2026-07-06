# Moon setup manager (interactive TUI)
# Usage: irm https://raw.githubusercontent.com/nnxlxde-stack/moon-setup/main/moon-manage.ps1 | iex
param(
    [ValidateSet("", "code", "code-insiders", "cursor")]
    [string]$Editor = ""
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
. (Join-Path $Root "lib\common.ps1")
. (Join-Path $Root "lib\tui.ps1")

function Invoke-MoonManageAction {
    param([int]$Choice)

    switch ($Choice) {
        1 {
            & (Join-Path $Root "scripts\install-moon.ps1")
            & (Join-Path $Root "scripts\install-vscode.ps1") -Editor $Editor
        }
        2 {
            & (Join-Path $Root "scripts\update-moon.ps1")
            & (Join-Path $Root "scripts\update-vscode.ps1") -Editor $Editor
        }
        3 {
            $confirm = Read-Host "Uninstall moon and extension? [y/N]"
            if ($confirm -notmatch '^[yY]') {
                Write-Host "Cancelled." -ForegroundColor Yellow
                return
            }
            & (Join-Path $Root "scripts\uninstall-vscode.ps1") -Editor $Editor -NonInteractive
            & (Join-Path $Root "scripts\uninstall-moon.ps1")
        }
        4 {
            & (Join-Path $Root "scripts\install-moon.ps1")
        }
        5 {
            & (Join-Path $Root "scripts\install-vscode.ps1") -Editor $Editor
        }
        6 {
            & (Join-Path $Root "scripts\uninstall-vscode.ps1") -Editor $Editor
        }
        7 {
            & (Join-Path $Root "scripts\verify.ps1")
        }
        8 { return "exit" }
        default {
            Write-Host "Invalid choice." -ForegroundColor Yellow
        }
    }
    return $null
}

Clear-Host
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Moon Setup Manager" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

while ($true) {
    $status = Get-MoonSetupStatus
    Show-MoonStatusPanel $status
    Show-MoonManageMenu

    $choice = Read-MoonMenuChoice -Min 1 -Max 8 -Default 0
    if ($choice -eq 8) { break }
    if ($choice -lt 1) {
        Write-Host "Invalid choice. Enter 1-8." -ForegroundColor Yellow
        continue
    }

    Write-Host ""
    $result = Invoke-MoonManageAction -Choice $choice
    if ($result -eq "exit") { break }

    if ($choice -in 1, 2, 4, 5, 6, 7) {
        Write-Host ""
        & (Join-Path $Root "scripts\verify.ps1")
    }

    Write-Host ""
    $again = Read-Host "Press Enter to return to menu (Q to quit)"
    if ($again -match '^[qQ]') { break }
    Clear-Host
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Moon Setup Manager" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Docs: https://nnxlxde-stack.github.io/moon-lang/" -ForegroundColor Green