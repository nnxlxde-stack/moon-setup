# Shared bootstrap for irm | iex entry scripts (install / update / uninstall).
$script:MoonSetupBootstrapFiles = @(
    "lib/common.ps1",
    "lib/bootstrap.ps1",
    "scripts/install-moon.ps1",
    "scripts/install-vscode.ps1",
    "scripts/update-moon.ps1",
    "scripts/update-vscode.ps1",
    "scripts/uninstall-moon.ps1",
    "scripts/uninstall-vscode.ps1",
    "scripts/verify.ps1"
)

function Resolve-MoonSetupRoot {
    $fromLib = Split-Path $PSScriptRoot -Parent
    if ((Test-Path $fromLib) -and (Test-Path (Join-Path $fromLib "install-all.ps1"))) {
        return $fromLib
    }

    $bootstrap = Join-Path $env:TEMP "moon-setup"
    Write-Host "==> Bootstrapping moon-setup -> $bootstrap" -ForegroundColor Cyan

    $base = "https://raw.githubusercontent.com/nnxlxde-stack/moon-setup/main"
    foreach ($rel in $script:MoonSetupBootstrapFiles) {
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

function Initialize-MoonSetupRoot {
    param([string]$CallerScriptRoot = "")

    if ($CallerScriptRoot) {
        return $CallerScriptRoot
    }

    return Resolve-MoonSetupRoot
}