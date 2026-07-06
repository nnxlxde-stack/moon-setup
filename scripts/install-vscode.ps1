param(
    [string]$VsixPath = "",
    [ValidateSet("", "code", "code-insiders", "cursor")]
    [string]$Editor = "",
    [switch]$NonInteractive
)
. "$PSScriptRoot\..\lib\common.ps1"

$selected = Select-EditorCli -Prefer $Editor -NonInteractive:$NonInteractive
if (-not $selected) {
    Write-Host "No VS Code / Cursor CLI found — skipping extension install." -ForegroundColor Yellow
    Write-Host "Install one of: VS Code, VS Code Insiders, or Cursor (with CLI in PATH)." -ForegroundColor Yellow
    Write-Host "Then run: irm .../install-all.ps1 | iex   or   .\scripts\install-vscode.ps1 -Editor code-insiders" -ForegroundColor Yellow
    return
}

if ($VsixPath -eq "") {
    Write-Step "Downloading latest moon-vscode release"
    $release = Invoke-RestMethod -Uri $script:MoonVscodeReleaseApi -Headers $script:GhHeaders
    $asset = $release.assets | Where-Object { $_.name -like "vscode-moon-*.vsix" } | Select-Object -First 1
    if (-not $asset) { throw "No .vsix asset in latest release" }
    $VsixPath = Join-Path $env:TEMP $asset.name
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $VsixPath -Headers $script:GhHeaders
}

Write-Step "Installing $VsixPath into $($selected.Label)"
& $selected.Command --install-extension $VsixPath --force
if ($LASTEXITCODE -ne 0) { throw "Extension install failed (exit $LASTEXITCODE)" }
Write-Host "Moon extension installed in $($selected.Label)." -ForegroundColor Green