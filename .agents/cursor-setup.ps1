# Setup script for Windows - creates junctions for Cursor auto-discovery
# Cursor requires flat skill folders under .cursor/skills/, so we create
# per-skill junctions from the nested .agents/skills/ structure.
# Run from workspace root (where .agents/ lives)
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = Split-Path -Parent $scriptDir
Set-Location $rootDir

$cursorDir = Join-Path $rootDir ".cursor"
$agentsSourceDir = Join-Path $rootDir ".agents"

# Agents: single junction
$agentsLink = Join-Path $cursorDir "agents"
$agentsTarget = Join-Path $agentsSourceDir "agents"

if (Test-Path $agentsLink) {
    $item = Get-Item $agentsLink -Force
    if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
        cmd /c rmdir `"$agentsLink`" 2>$null
    } else {
        Remove-Item $agentsLink -Force -Recurse -ErrorAction SilentlyContinue
    }
}
New-Item -ItemType Directory -Force -Path $cursorDir | Out-Null
cmd /c mklink /J `"$agentsLink`" `"$agentsTarget`"
Write-Host "  Linked: agents -> $agentsTarget"

# Skills: flat per-skill junctions in .cursor/skills/
$skillsDir = Join-Path $cursorDir "skills"
$skillsSourceDir = Join-Path $agentsSourceDir "skills"

if (Test-Path $skillsDir) {
    Get-ChildItem $skillsDir -Directory | ForEach-Object {
        if ($_.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
            cmd /c rmdir `"$($_.FullName)`"
        } else {
            Remove-Item $_.FullName -Force -Recurse
        }
    }
} else {
    New-Item -ItemType Directory -Force -Path $skillsDir | Out-Null
}

Get-ChildItem $skillsSourceDir -Directory -Recurse |
    Where-Object { Test-Path (Join-Path $_.FullName "SKILL.md") } |
    ForEach-Object {
        $linkPath = Join-Path $skillsDir $_.Name
        $targetPath = $_.FullName
        cmd /c mklink /J `"$linkPath`" `"$targetPath`"
        Write-Host "  Linked: $($_.Name) -> $targetPath"
    }

Write-Host "Setup complete. Cursor will now discover skills and agents from .agents/"
