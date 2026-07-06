function Get-MoonSetupStatus {
    $status = [ordered]@{
        MoonInstalled = $false
        MoonVersion = ""
        MoonPath = $script:MoonExePath
        StdlibPath = $script:MoonStdlibDir
        Editors = @()
    }

    if (Test-Path $script:MoonExePath) {
        $status.MoonInstalled = $true
        $savedPath = $env:Path
        $env:Path = "$script:MoonBinDir;$script:MoonRuntimeDir;$savedPath"
        $saved = $ErrorActionPreference
        $ErrorActionPreference = "Continue"
        try {
            $ver = & $script:MoonExePath version 2>&1 | Select-Object -First 1
            $status.MoonVersion = "$ver".Trim()
        } finally {
            $ErrorActionPreference = $saved
            $env:Path = $savedPath
        }
    }

    foreach ($editor in Find-EditorInstallations) {
        $ext = Get-MoonExtensionInfo $editor.Command
        $status.Editors += [pscustomobject]@{
            Id = $editor.Id
            Label = $editor.Label
            Running = Test-EditorRunning $editor.Id
            ExtensionVersion = if ($ext) { $ext.Version } else { $null }
        }
    }

    return [pscustomobject]$status
}

function Show-MoonStatusPanel {
    param($Status)

    Write-Host "----------------------------------------" -ForegroundColor DarkGray
    Write-Host " Status" -ForegroundColor Cyan

    if ($Status.MoonInstalled) {
        Write-Host ('  moon      installed  {0}' -f $Status.MoonPath) -ForegroundColor Green
        if ($Status.MoonVersion) {
            Write-Host ('             {0}' -f $Status.MoonVersion) -ForegroundColor DarkGray
        }
    } else {
        Write-Host "  moon      not installed" -ForegroundColor Yellow
    }

    if ($Status.Editors.Count -eq 0) {
        Write-Host "  editors   none detected" -ForegroundColor Yellow
    } else {
        foreach ($editor in $Status.Editors) {
            $run = if ($editor.Running) { "running" } else { "stopped" }
            $ext = if ($editor.ExtensionVersion) { "ext $($editor.ExtensionVersion)" } else { "no extension" }
            $color = if ($editor.Running) { "Yellow" } else { "Green" }
            Write-Host ('  {0,-16} {1,-8} {2}' -f $editor.Label, $run, $ext) -ForegroundColor $color
        }
    }
    Write-Host "----------------------------------------" -ForegroundColor DarkGray
}

function Read-MoonMenuChoice {
    param(
        [int]$Min = 1,
        [int]$Max = 8,
        [int]$Default = 0
    )

    $prompt = if ($Default -gt 0) {
        "Select [$Min-$Max] (default $Default)"
    } else {
        "Select [$Min-$Max]"
    }

    $choice = Read-Host $prompt
    if ([string]::IsNullOrWhiteSpace($choice) -and $Default -gt 0) { return $Default }
    if ($choice -notmatch '^\d+$') { return -1 }
    $num = [int]$choice
    if ($num -lt $Min -or $num -gt $Max) { return -1 }
    return $num
}

function Show-MoonManageMenu {
    Write-Host ""
    Write-Host "  [1] Install all (moon + extension)" -ForegroundColor White
    Write-Host "  [2] Update all" -ForegroundColor White
    Write-Host "  [3] Uninstall all" -ForegroundColor White
    Write-Host "  [4] Install moon toolchain only" -ForegroundColor White
    Write-Host "  [5] Install / update extension" -ForegroundColor White
    Write-Host "  [6] Uninstall extension" -ForegroundColor White
    Write-Host "  [7] Verify installation" -ForegroundColor White
    Write-Host "  [8] Exit" -ForegroundColor White
    Write-Host ""
}