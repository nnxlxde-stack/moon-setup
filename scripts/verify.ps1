. "$PSScriptRoot\..\lib\common.ps1"
$InstallDir = Join-Path $env:USERPROFILE "moon"
$MoonExe = Join-Path $InstallDir "moon-lang\.build\debug\moon.exe"

Write-Step "Verifying Moon installation"
if (Test-Path $MoonExe) {
    & $MoonExe version
} elseif (Get-Command moon -ErrorAction SilentlyContinue) {
    moon version
} else {
    Write-Host "moon CLI not found. Run install-moon.ps1 first." -ForegroundColor Yellow
}

if (Get-Command code -ErrorAction SilentlyContinue) {
    $ext = code --list-extensions 2>$null | Select-String "moon-lang.vscode-moon|vscode-moon"
    if ($ext) { Write-Host "VS Code extension: $ext" -ForegroundColor Green }
    else { Write-Host "Moon VS Code extension not installed." -ForegroundColor Yellow }
}