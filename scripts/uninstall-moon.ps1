. "$PSScriptRoot\..\lib\common.ps1"

Write-Step "Uninstalling Moon toolchain"
Uninstall-MoonUserPath
Uninstall-MoonFiles
Write-Host "Restart terminal or VS Code to apply PATH changes." -ForegroundColor Yellow