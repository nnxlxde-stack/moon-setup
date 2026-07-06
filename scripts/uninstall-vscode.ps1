param(
    [ValidateSet("", "code", "code-insiders", "cursor")]
    [string]$Editor = "",
    [switch]$All,
    [switch]$NonInteractive
)
. "$PSScriptRoot\..\lib\common.ps1"

$editors = Find-EditorInstallations
if ($editors.Count -eq 0) {
    Write-Host "No VS Code / Cursor CLI found - nothing to uninstall." -ForegroundColor Yellow
    return
}

if ($All) {
    $targets = $editors
} elseif ($Editor) {
    $targets = $editors | Where-Object { $_.Id -eq $Editor }
    if (-not $targets) {
        Write-Host "Editor '$Editor' not found." -ForegroundColor Yellow
        return
    }
} else {
    $selected = Select-EditorCli -NonInteractive:$NonInteractive
    if (-not $selected) { return }
    $targets = @($selected)
}

foreach ($editor in $targets) {
    $ext = Test-MoonExtensionInstalled $editor.Command
    if (-not $ext) {
        Write-Host "$($editor.Label): Moon extension not installed." -ForegroundColor Yellow
        continue
    }
    Write-Step "Uninstalling Moon extension from $($editor.Label)"
    & $editor.Command --uninstall-extension $script:MoonExtensionId
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Extension uninstall failed in $($editor.Label) (exit $LASTEXITCODE)" -ForegroundColor Red
    } else {
        Write-Host ('Moon extension removed from {0}.' -f $editor.Label) -ForegroundColor Green
    }
}