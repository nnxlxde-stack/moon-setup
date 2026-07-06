param(
    [string]$Tag = ""
)
. "$PSScriptRoot\..\lib\common.ps1"

Write-Step "Updating Moon toolchain -> $script:MoonInstallRoot"
Update-MoonToolchain -Tag $Tag

Write-Host "`nMoon updated:" -ForegroundColor Green
Write-Host "  moon.exe  -> $script:MoonExePath"
Write-Host "  runtime   -> $script:MoonRuntimeDir"
Write-Host "  stdlib    -> $script:MoonStdlibDir"
Write-Host "Restart terminal or VS Code to pick up PATH changes." -ForegroundColor Yellow