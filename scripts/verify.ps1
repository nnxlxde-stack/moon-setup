. "$PSScriptRoot\..\lib\common.ps1"

Write-Step "Verifying Moon installation"

$moon = $script:MoonExePath
if (Test-Path $moon) {
    $savedPath = $env:Path
    $env:Path = "$script:MoonBinDir;$script:MoonRuntimeDir;$savedPath"
    & $moon version
    if ($env:MOON_STDLIB -or (Test-Path $script:MoonStdlibDir)) {
        $stdlib = if ($env:MOON_STDLIB) { $env:MOON_STDLIB } else { $script:MoonStdlibDir }
        Write-Host "MOON_STDLIB: $stdlib" -ForegroundColor Green
    }
} elseif (Get-Command moon -ErrorAction SilentlyContinue) {
    moon version
} else {
    Write-Host "moon CLI not found. Run install-moon.ps1 first." -ForegroundColor Yellow
}

$editors = Find-EditorInstallations
if ($editors.Count -eq 0) {
    Write-Host "No VS Code / Cursor CLI found." -ForegroundColor Yellow
} else {
    foreach ($editor in $editors) {
        $ext = Test-MoonExtensionInstalled $editor.Command
        if ($ext) {
            Write-Host "$($editor.Label): Moon extension installed ($ext)" -ForegroundColor Green
        } else {
            Write-Host "$($editor.Label): Moon extension not installed." -ForegroundColor Yellow
        }
    }
}