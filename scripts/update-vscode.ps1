param(
    [string]$VsixPath = "",
    [ValidateSet("", "code", "code-insiders", "cursor")]
    [string]$Editor = "",
    [switch]$NonInteractive
)
. "$PSScriptRoot\..\lib\common.ps1"

$selected = Select-EditorCli -Prefer $Editor -NonInteractive:$NonInteractive
if (-not $selected) {
    Write-Host "No VS Code / Cursor CLI found - skipping extension update." -ForegroundColor Yellow
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

Write-Step "Updating extension in $($selected.Label)"
& $selected.Command --install-extension $VsixPath --force
if ($LASTEXITCODE -ne 0) { throw "Extension update failed (exit $LASTEXITCODE)" }
Write-Host ('Moon extension updated in {0}.' -f $selected.Label) -ForegroundColor Green