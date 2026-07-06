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