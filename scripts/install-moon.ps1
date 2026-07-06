param(
    [string]$Tag = "",
    [switch]$SkipRuntime,
    [switch]$SkipStdlib
)
. "$PSScriptRoot\..\lib\common.ps1"

Write-Step "Moon standalone install -> $script:MoonInstallRoot"

if (-not $SkipRuntime) {
    Install-MoonRuntime -Tag $Tag
}
Install-MoonBinary -Tag $Tag
if (-not $SkipStdlib) {
    $stdlibTag = if ($Tag) { $Tag } else { "v0.3.0" }
    Install-MoonStdlib -Tag $stdlibTag
}
Install-MoonUserPath

Write-Host ""
Write-Host "Moon installed:" -ForegroundColor Green
Write-Host ("  moon.exe  -> {0}" -f $script:MoonExePath)
Write-Host ("  runtime   -> {0}" -f $script:MoonRuntimeDir)
Write-Host ("  stdlib    -> {0}" -f $script:MoonStdlibDir)
Write-Host ""
Write-Host "Restart terminal or VS Code to pick up PATH changes." -ForegroundColor Yellow