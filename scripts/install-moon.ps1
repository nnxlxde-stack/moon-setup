param(
    [string]$InstallDir = (Join-Path $env:USERPROFILE "moon"),
    [switch]$Update
)
. "$PSScriptRoot\..\lib\common.ps1"
Ensure-Git
Ensure-Swift

$LangDir = Join-Path $InstallDir "moon-lang"
Write-Step "Moon toolchain -> $LangDir"

if (Test-Path $LangDir) {
    if ($Update) {
        Push-Location $LangDir
        git pull
        Pop-Location
    }
} else {
    New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
    git clone $MoonLangRepo $LangDir
}

Push-Location $LangDir
swift build
$MoonExe = Join-Path $LangDir ".build\debug\moon.exe"
if (-not (Test-Path $MoonExe)) { throw "moon build failed" }
& $MoonExe version
Pop-Location

Write-Host "Add to PATH: $MoonExe" -ForegroundColor Green