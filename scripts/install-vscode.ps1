param(
    [string]$VsixPath = ""
)
. "$PSScriptRoot\..\lib\common.ps1"

if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
    throw "VS Code CLI 'code' not found. Install VS Code and enable 'code' in PATH."
}

if ($VsixPath -eq "") {
    Write-Step "Downloading latest moon-vscode release"
    $release = Invoke-RestMethod -Uri $MoonVscodeReleaseApi -Headers @{ "User-Agent" = "moon-setup" }
    $asset = $release.assets | Where-Object { $_.name -like "vscode-moon-*.vsix" } | Select-Object -First 1
    if (-not $asset) { throw "No .vsix asset in latest release" }
    $VsixPath = Join-Path $env:TEMP $asset.name
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $VsixPath
}

Write-Step "Installing $VsixPath"
code --install-extension $VsixPath --force
Write-Host "Moon VS Code extension installed." -ForegroundColor Green