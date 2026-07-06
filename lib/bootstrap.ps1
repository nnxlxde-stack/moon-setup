# Shared bootstrap for irm | iex entry scripts (install / update / uninstall).
$script:MoonSetupBootstrapVersion = "3"
$script:MoonSetupBootstrapFiles = @(
    "lib/common.ps1",
    "lib/bootstrap.ps1",
    "lib/tui.ps1",
    "scripts/install-moon.ps1",
    "scripts/install-vscode.ps1",
    "scripts/update-moon.ps1",
    "scripts/update-vscode.ps1",
    "scripts/uninstall-moon.ps1",
    "scripts/uninstall-vscode.ps1",
    "scripts/verify.ps1"
)

function Import-MoonSetupBootstrap {
    param([string]$CallerScriptRoot = "")
    return Initialize-MoonSetupRoot -CallerScriptRoot $CallerScriptRoot
}

function Resolve-MoonSetupRoot {
    $fromLib = Split-Path $PSScriptRoot -Parent
    if ((Test-Path $fromLib) -and (Test-Path (Join-Path $fromLib "install-all.ps1"))) {
        return $fromLib
    }

    $bootstrap = Join-Path $env:TEMP "moon-setup"
    $versionFile = Join-Path $bootstrap ".bootstrap-version"
    $needsRefresh = $true

    if (Test-Path $versionFile) {
        $cached = (Get-Content $versionFile -Raw).Trim()
        if ($cached -eq $script:MoonSetupBootstrapVersion) {
            $marker = Join-Path $bootstrap "scripts\install-vscode.ps1"
            $needsRefresh = -not (Test-Path $marker)
        }
    }

    if ($needsRefresh) {
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
        Set-Content -Path $versionFile -Value $script:MoonSetupBootstrapVersion -NoNewline
    }

    return $bootstrap
}

function Initialize-MoonSetupRoot {
    param([string]$CallerScriptRoot = "")

    if ($CallerScriptRoot -and (Test-Path (Join-Path $CallerScriptRoot "install-all.ps1"))) {
        return $CallerScriptRoot
    }

    return Resolve-MoonSetupRoot
}

function Connect-MoonSetup {
    param([string]$CallerScriptRoot = "")

    $localBootstrap = $null
    if ($CallerScriptRoot) {
        $candidate = Join-Path $CallerScriptRoot "lib\bootstrap.ps1"
        if (Test-Path $candidate) { $localBootstrap = $candidate }
    }

    if ($localBootstrap) {
        . $localBootstrap
    } else {
        $staging = Join-Path $env:TEMP "moon-setup"
        $remoteBootstrap = Join-Path $staging "lib\bootstrap.ps1"
        New-Item -ItemType Directory -Force -Path (Split-Path $remoteBootstrap) | Out-Null
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/nnxlxde-stack/moon-setup/main/lib/bootstrap.ps1" `
            -OutFile $remoteBootstrap -UseBasicParsing -Headers @{ "User-Agent" = "moon-setup" }
        . $remoteBootstrap
    }

    if (-not (Get-Command Import-MoonSetupBootstrap -ErrorAction SilentlyContinue)) {
        throw "moon-setup bootstrap failed to load"
    }

    return Import-MoonSetupBootstrap -CallerScriptRoot $CallerScriptRoot
}