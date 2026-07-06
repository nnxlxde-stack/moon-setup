# Moon ecosystem installer (Windows)
# Usage: irm https://raw.githubusercontent.com/nnxlxde-stack/moon-setup/main/install-all.ps1 | iex
param([switch]$SkipVscode)

$Root = $PSScriptRoot
& "$Root\scripts\install-moon.ps1"
if (-not $SkipVscode) {
    & "$Root\scripts\install-vscode.ps1"
}
& "$Root\scripts\verify.ps1"
Write-Host "`nDone. Docs: https://github.com/nnxlxde-stack/moon-lang/blob/main/docs/index.html" -ForegroundColor Green