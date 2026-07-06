$ErrorActionPreference = "Stop"

$script:MoonSetupRoot = Split-Path $PSScriptRoot -Parent
$script:MoonLangRepo = "https://github.com/nnxlxde-stack/moon-lang.git"
$script:MoonVscodeRepo = "https://github.com/nnxlxde-stack/moon-vscode.git"
$script:MoonVscodeReleaseApi = "https://api.github.com/repos/nnxlxde-stack/moon-vscode/releases/latest"
$script:DefaultInstallDir = Join-Path $env:USERPROFILE "moon"

function Write-Step([string]$Message) {
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Ensure-Git {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        throw "git is required. Install Git for Windows first."
    }
}

function Ensure-Swift {
    if (-not (Get-Command swift -ErrorAction SilentlyContinue)) {
        throw "Swift 6.3+ is required. Install from https://www.swift.org/install/"
    }
}