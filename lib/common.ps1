$ErrorActionPreference = "Stop"

$script:MoonSetupRoot = Split-Path $PSScriptRoot -Parent
$script:MoonLangRepo = "https://github.com/nnxlxde-stack/moon-lang.git"
$script:MoonLangReleaseApi = "https://api.github.com/repos/nnxlxde-stack/moon-lang/releases/latest"
$script:MoonVscodeRepo = "https://github.com/nnxlxde-stack/moon-vscode.git"
$script:MoonVscodeReleaseApi = "https://api.github.com/repos/nnxlxde-stack/moon-vscode/releases/latest"
$script:MoonInstallRoot = Join-Path $env:APPDATA "Moon"
$script:MoonBinDir = Join-Path $script:MoonInstallRoot "bin"
$script:MoonRuntimeDir = Join-Path $script:MoonInstallRoot "runtime\bin"
$script:MoonStdlibDir = Join-Path $script:MoonInstallRoot "stdlib"
$script:MoonExePath = Join-Path $script:MoonBinDir "moon.exe"
$script:GhHeaders = @{ "User-Agent" = "moon-setup" }
$script:MoonExtensionId = "moon-lang.vscode-moon"

function Write-Step([string]$Message) {
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Get-GitHubReleaseAsset([string]$ApiUrl, [string]$Pattern) {
    $release = Invoke-RestMethod -Uri $ApiUrl -Headers $script:GhHeaders
    $asset = $release.assets | Where-Object { $_.name -like $Pattern } | Select-Object -First 1
    if (-not $asset) { throw "No asset matching '$Pattern' in release $($release.tag_name)" }
    return $asset
}

function Expand-ZipArchive([string]$ZipPath, [string]$Destination) {
    if (Get-Command Expand-Archive -ErrorAction SilentlyContinue) {
        Expand-Archive -Path $ZipPath -DestinationPath $Destination -Force
        return
    }
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($ZipPath, $Destination)
}

function Ensure-Directory([string]$Path) {
    New-Item -ItemType Directory -Force -Path $Path | Out-Null
}

function Remove-UserPathEntry([string]$Dir) {
    if (-not $Dir) { return }
    $normalized = $Dir
    if (Test-Path $Dir) {
        $normalized = (Resolve-Path $Dir).Path
    }
    $current = [Environment]::GetEnvironmentVariable("Path", "User")
    if (-not $current) { return }
    $parts = $current -split ';' | Where-Object {
        $_ -and $_.Trim() -ne "" -and $_.Trim() -ne $normalized
    }
    $updated = ($parts -join ';').TrimEnd(';')
    [Environment]::SetEnvironmentVariable("Path", $updated, "User")
}

function Add-UserPathEntry([string]$Dir) {
    if (-not (Test-Path $Dir)) { return }
    $normalized = (Resolve-Path $Dir).Path
    $current = [Environment]::GetEnvironmentVariable("Path", "User")
    $parts = @()
    if ($current) { $parts = $current -split ';' | Where-Object { $_ -and $_.Trim() -ne "" } }
    if ($parts -notcontains $normalized) {
        $parts = @($normalized) + $parts
        $updated = ($parts -join ';').TrimEnd(';')
        [Environment]::SetEnvironmentVariable("Path", $updated, "User")
    }
    if ($env:Path -notlike "*$normalized*") {
        $env:Path = "$normalized;$env:Path"
    }
}

function Install-MoonUserPath {
    Add-UserPathEntry $script:MoonBinDir
    Add-UserPathEntry $script:MoonRuntimeDir
    Write-Host "User PATH updated: $script:MoonBinDir; $script:MoonRuntimeDir" -ForegroundColor Green
}

function Install-MoonRuntime([string]$Tag = "") {
    Write-Step "Installing Swift runtime -> $script:MoonRuntimeDir"
    Ensure-Directory $script:MoonRuntimeDir

    $api = if ($Tag) {
        "https://api.github.com/repos/nnxlxde-stack/moon-lang/releases/tags/$Tag"
    } else {
        $script:MoonLangReleaseApi
    }

    $asset = Get-GitHubReleaseAsset $api "moon-runtime-*-windows-x86_64.zip"
    $zipPath = Join-Path $env:TEMP $asset.name
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zipPath -Headers $script:GhHeaders

    $staging = Join-Path $env:TEMP "moon-runtime-staging"
    if (Test-Path $staging) { Remove-Item $staging -Recurse -Force }
    Ensure-Directory $staging
    Expand-ZipArchive $zipPath $staging

    Get-ChildItem $staging -Recurse -Filter "*.dll" | ForEach-Object {
        Copy-Item $_.FullName (Join-Path $script:MoonRuntimeDir $_.Name) -Force
    }
    Write-Host "Runtime DLLs: $((Get-ChildItem $script:MoonRuntimeDir -Filter '*.dll').Count)" -ForegroundColor Green
}

function Install-MoonBinary([string]$Tag = "") {
    Write-Step "Installing moon CLI -> $script:MoonBinDir"
    Ensure-Directory $script:MoonBinDir

    $api = if ($Tag) {
        "https://api.github.com/repos/nnxlxde-stack/moon-lang/releases/tags/$Tag"
    } else {
        $script:MoonLangReleaseApi
    }

    $asset = Get-GitHubReleaseAsset $api "moon-*-windows-x86_64.exe"
    $exePath = Join-Path $env:TEMP $asset.name
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $exePath -Headers $script:GhHeaders
    Copy-Item $exePath $script:MoonExePath -Force
    & $script:MoonExePath version
}

function Install-MoonStdlib([string]$Tag = "v0.3.0") {
    Write-Step "Installing stdlib -> $script:MoonStdlibDir"
    if (Test-Path $script:MoonStdlibDir) { Remove-Item $script:MoonStdlibDir -Recurse -Force }
    Ensure-Directory $script:MoonStdlibDir

    $api = "https://api.github.com/repos/nnxlxde-stack/moon-lang/releases/tags/$Tag"
    try {
        $asset = Get-GitHubReleaseAsset $api "moon-stdlib-*.zip"
        $zipPath = Join-Path $env:TEMP $asset.name
        Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zipPath -Headers $script:GhHeaders
        $staging = Join-Path $env:TEMP "moon-stdlib-staging"
        if (Test-Path $staging) { Remove-Item $staging -Recurse -Force }
        Ensure-Directory $staging
        Expand-ZipArchive $zipPath $staging
        $stdlibSrc = Join-Path $staging "stdlib"
        if (Test-Path $stdlibSrc) {
            Copy-Item $stdlibSrc $script:MoonInstallRoot -Recurse -Force
        } elseif (Test-Path (Join-Path $staging "Core")) {
            Ensure-Directory $script:MoonStdlibDir
            Copy-Item (Join-Path $staging "Core") (Join-Path $script:MoonStdlibDir "Core") -Recurse -Force
        } else {
            throw "stdlib folder missing in archive"
        }
    } catch {
        Write-Host "stdlib zip not found, cloning sparse from git..." -ForegroundColor Yellow
        $cloneDir = Join-Path $env:TEMP "moon-lang-stdlib"
        if (Test-Path $cloneDir) { Remove-Item $cloneDir -Recurse -Force }
        git clone --depth 1 --filter=blob:none --sparse $script:MoonLangRepo $cloneDir
        Push-Location $cloneDir
        git sparse-checkout set stdlib
        Pop-Location
        Copy-Item (Join-Path $cloneDir "stdlib") $script:MoonStdlibDir -Recurse -Force
    }

    [Environment]::SetEnvironmentVariable("MOON_STDLIB", $script:MoonStdlibDir, "User")
    $env:MOON_STDLIB = $script:MoonStdlibDir
    Write-Host "MOON_STDLIB=$script:MoonStdlibDir" -ForegroundColor Green
}

function Find-EditorInstallations {
    $defs = @(
        @{
            Id = "code-insiders"
            Label = "VS Code Insiders"
            Names = @("code-insiders")
            Paths = @(
                (Join-Path $env:LOCALAPPDATA "Programs\Microsoft VS Code Insiders\bin\code-insiders.cmd")
            )
        },
        @{
            Id = "cursor"
            Label = "Cursor"
            Names = @("cursor")
            Paths = @(
                (Join-Path $env:LOCALAPPDATA "Programs\cursor\resources\app\bin\cursor.cmd")
                (Join-Path $env:LOCALAPPDATA "Programs\Cursor\resources\app\bin\cursor.cmd")
            )
        },
        @{
            Id = "code"
            Label = "VS Code"
            Names = @("code")
            Paths = @(
                (Join-Path $env:LOCALAPPDATA "Programs\Microsoft VS Code\bin\code.cmd")
            )
        }
    )

    $found = @()
    foreach ($def in $defs) {
        $command = $null
        foreach ($name in $def.Names) {
            $resolved = Get-Command $name -ErrorAction SilentlyContinue
            if ($resolved) {
                $command = $resolved.Source
                break
            }
        }
        if (-not $command) {
            foreach ($candidate in $def.Paths) {
                if (Test-Path $candidate) {
                    $command = $candidate
                    break
                }
            }
        }
        if ($command) {
            $found += [pscustomobject]@{
                Id = $def.Id
                Label = $def.Label
                Command = $command
            }
        }
    }
    return $found
}

function Select-EditorCli {
    param(
        [string]$Prefer = "",
        [switch]$NonInteractive
    )

    $editors = Find-EditorInstallations
    if ($editors.Count -eq 0) { return $null }

    if ($Prefer) {
        $preferred = $editors | Where-Object { $_.Id -eq $Prefer } | Select-Object -First 1
        if ($preferred) { return $preferred }
        Write-Host "Editor '$Prefer' not found; showing available editors." -ForegroundColor Yellow
    }

    if ($editors.Count -eq 1) {
        Write-Host "Using editor: $($editors[0].Label)" -ForegroundColor Green
        return $editors[0]
    }

    if ($NonInteractive) {
        Write-Host "Using editor: $($editors[0].Label) (non-interactive)" -ForegroundColor Green
        return $editors[0]
    }

    Write-Host ""
    Write-Host "Multiple editors found:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $editors.Count; $i++) {
        Write-Host "  [$($i + 1)] $($editors[$i].Label)"
    }
    $default = 1
    $choice = Read-Host "Select editor [1-$($editors.Count)] (default $default)"
    if ([string]::IsNullOrWhiteSpace($choice)) { $choice = "$default" }
    if ($choice -notmatch '^\d+$') { $choice = "$default" }
    $index = [int]$choice - 1
    if ($index -lt 0 -or $index -ge $editors.Count) { $index = 0 }
    return $editors[$index]
}

function Invoke-EditorCli {
    param(
        [string]$EditorCommand,
        [string[]]$Arguments
    )
    $saved = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & $EditorCommand @Arguments 2>&1 | ForEach-Object { "$_" }
        return @{
            ExitCode = $LASTEXITCODE
            Output = $output
        }
    } finally {
        $ErrorActionPreference = $saved
    }
}

function Get-EditorProcessName([string]$EditorId) {
    switch ($EditorId) {
        "code" { return "Code" }
        "code-insiders" { return "Code - Insiders" }
        "cursor" { return "Cursor" }
    }
    return $null
}

function Test-EditorRunning([string]$EditorId) {
    $name = Get-EditorProcessName $EditorId
    if (-not $name) { return $false }
    return [bool](Get-Process -Name $name -ErrorAction SilentlyContinue)
}

function Test-MoonExtensionInstalled([string]$EditorCommand) {
    $result = Invoke-EditorCli $EditorCommand @("--list-extensions")
    return $result.Output | Where-Object { $_ -match "moon-lang\.vscode-moon|vscode-moon" } | Select-Object -First 1
}

function Get-MoonExtensionInfo([string]$EditorCommand) {
    $result = Invoke-EditorCli $EditorCommand @("--list-extensions", "--show-versions")
    $line = $result.Output | Where-Object { $_ -match "^moon-lang\.vscode-moon@" } | Select-Object -First 1
    if (-not $line) { return $null }
    if ($line -match "^(.+)@(.+)$") {
        return [pscustomobject]@{ Id = $Matches[1]; Version = $Matches[2] }
    }
    return $null
}

function Get-MoonVsixVersion([string]$Path) {
    $name = Split-Path $Path -Leaf
    if ($name -match "vscode-moon-([\d.]+)\.vsix") { return $Matches[1] }
    return $null
}

function Get-MoonVsixPackage {
    param([string]$VsixPath = "")

    if ($VsixPath -and (Test-Path $VsixPath)) {
        return [pscustomobject]@{
            Path = $VsixPath
            Version = Get-MoonVsixVersion $VsixPath
        }
    }

    Write-Step "Downloading latest moon-vscode release"
    $release = Invoke-RestMethod -Uri $script:MoonVscodeReleaseApi -Headers $script:GhHeaders
    $asset = $release.assets | Where-Object { $_.name -like "vscode-moon-*.vsix" } | Select-Object -First 1
    if (-not $asset) { throw "No .vsix asset in latest release" }
    $path = Join-Path $env:TEMP $asset.name
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $path -Headers $script:GhHeaders
    return [pscustomobject]@{
        Path = $path
        Version = Get-MoonVsixVersion $asset.name
        ReleaseTag = $release.tag_name
    }
}

function Wait-EditorClosed {
    param(
        [string]$EditorId,
        [string]$Label,
        [switch]$NonInteractive
    )

    if (-not (Test-EditorRunning $EditorId)) { return $true }

    Write-Host ""
    Write-Host "$Label is running. Close it completely before installing the extension." -ForegroundColor Yellow
    if ($NonInteractive) {
        Write-Host "Skipping extension install while editor is open." -ForegroundColor Yellow
        return $false
    }

    while (Test-EditorRunning $EditorId) {
        $choice = Read-Host "Close $Label, then press Enter to retry (S to skip)"
        if ($choice -match '^[sS]') { return $false }
    }
    Start-Sleep -Seconds 1
    return $true
}

function Write-ExtensionManualInstallHint {
    param(
        [string]$Label,
        [string]$EditorCommand,
        [string]$VsixPath
    )
    Write-Host ("Close {0} completely, then run:" -f $Label) -ForegroundColor Yellow
    Write-Host ('  {0} --install-extension "{1}"' -f $EditorCommand, $VsixPath) -ForegroundColor White
}

function Install-MoonVscodeExtension {
    param(
        [string]$VsixPath = "",
        [string]$Editor = "",
        [switch]$NonInteractive,
        [switch]$Force,
        [switch]$Strict
    )

    $selected = Select-EditorCli -Prefer $Editor -NonInteractive:$NonInteractive
    if (-not $selected) {
        Write-Host "No VS Code / Cursor CLI found - skipping extension install." -ForegroundColor Yellow
        Write-Host "Install VS Code, VS Code Insiders, or Cursor with CLI in PATH." -ForegroundColor Yellow
        return [pscustomobject]@{ Success = $false; Skipped = $true; Message = "No editor CLI" }
    }

    $package = Get-MoonVsixPackage -VsixPath $VsixPath
    $installed = Get-MoonExtensionInfo $selected.Command

    if ($installed -and $package.Version -and $installed.Version -eq $package.Version -and -not $Force) {
        Write-Host ('Moon extension {0} already installed in {1}.' -f $installed.Version, $selected.Label) -ForegroundColor Green
        return [pscustomobject]@{ Success = $true; Skipped = $true; Message = "Already installed" }
    }

    if (Test-EditorRunning $selected.Id) {
        $ready = Wait-EditorClosed -EditorId $selected.Id -Label $selected.Label -NonInteractive:$NonInteractive
        if (-not $ready) {
            Write-ExtensionManualInstallHint $selected.Label $selected.Command $package.Path
            return [pscustomobject]@{
                Success = $false
                Skipped = $true
                NeedsRestart = $true
                VsixPath = $package.Path
                Editor = $selected
                Message = "Editor running"
            }
        }
    }

    $verb = if ($installed) { "Updating" } else { "Installing" }
    Write-Step ('{0} {1} into {2}' -f $verb, (Split-Path $package.Path -Leaf), $selected.Label)
    $result = Invoke-EditorCli $selected.Command @("--install-extension", $package.Path, "--force")

    if ($result.ExitCode -eq 0) {
        Write-Host ('Moon extension installed in {0}.' -f $selected.Label) -ForegroundColor Green
        return [pscustomobject]@{ Success = $true; Skipped = $false; Message = "Installed" }
    }

    $output = ($result.Output -join "`n")
    $needsRestart = $output -match "restart|EPERM|operation not permitted|rename failed"

    Write-Host "Extension install failed." -ForegroundColor Red
    if ($needsRestart) {
        Write-ExtensionManualInstallHint $selected.Label $selected.Command $package.Path
    } elseif ($output) {
        Write-Host $output -ForegroundColor DarkGray
    }

    $resultObj = [pscustomobject]@{
        Success = $false
        Skipped = $false
        NeedsRestart = $needsRestart
        VsixPath = $package.Path
        Editor = $selected
        Message = "Install failed"
        ExitCode = $result.ExitCode
    }

    if ($Strict) { throw "Extension install failed (exit $($result.ExitCode))" }
    return $resultObj
}

function Uninstall-MoonUserPath {
    Remove-UserPathEntry $script:MoonBinDir
    Remove-UserPathEntry $script:MoonRuntimeDir
    $stdlib = [Environment]::GetEnvironmentVariable("MOON_STDLIB", "User")
    if ($stdlib -and $stdlib -like "*\Moon\stdlib*") {
        [Environment]::SetEnvironmentVariable("MOON_STDLIB", $null, "User")
    }
    Write-Host "Removed Moon entries from user PATH and MOON_STDLIB." -ForegroundColor Green
}

function Uninstall-MoonFiles {
    if (Test-Path $script:MoonInstallRoot) {
        Remove-Item $script:MoonInstallRoot -Recurse -Force
        Write-Host "Removed $script:MoonInstallRoot" -ForegroundColor Green
    } else {
        Write-Host "Moon install directory not found: $script:MoonInstallRoot" -ForegroundColor Yellow
    }
}

function Update-MoonToolchain([string]$Tag = "") {
    Install-MoonRuntime -Tag $Tag
    Install-MoonBinary -Tag $Tag
    $stdlibTag = if ($Tag) { $Tag } else { "v0.3.0" }
    Install-MoonStdlib -Tag $stdlibTag
    Install-MoonUserPath
}