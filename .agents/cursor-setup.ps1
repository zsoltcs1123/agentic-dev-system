# Setup script for Windows - creates junctions for Cursor auto-discovery
# Run from workspace root (where .agents/ lives)
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = Split-Path -Parent $scriptDir
Set-Location $rootDir

if (-not (Test-Path ".cursor")) {
    New-Item -ItemType Directory -Path ".cursor" | Out-Null
}

if (Test-Path ".cursor\skills") {
    Remove-Item ".cursor\skills" -Force -Recurse
}
if (Test-Path ".cursor\agents") {
    Remove-Item ".cursor\agents" -Force -Recurse
}

cmd /c mklink /J ".cursor\skills" ".agents\skills"
cmd /c mklink /J ".cursor\agents" ".agents\agents"

Write-Host "Setup complete. Cursor will now discover skills and agents from .agents/"
