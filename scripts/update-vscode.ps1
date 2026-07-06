param(
    [string]$VsixPath = "",
    [ValidateSet("", "code", "code-insiders", "cursor")]
    [string]$Editor = "",
    [switch]$NonInteractive,
    [switch]$Strict
)
. "$PSScriptRoot\..\lib\common.ps1"

$result = Install-MoonVscodeExtension -VsixPath $VsixPath -Editor $Editor `
    -NonInteractive:$NonInteractive -Force -Strict:$Strict

if (-not $result.Success -and -not $result.Skipped -and $Strict) {
    exit 1
}