# Created By: Karim-(KaReem Elhlag)-Abdelhady
# smart-search.ps1 - targeted symbol/content search (SKILL.md section 3: search first, read second).
#
# Budget rationale: a bounded search with line numbers + a narrow read around the hit
# replaces most full-file reads (~85% token saving vs sweeping the tree).
#
# Usage:
#   scripts/smart-search.ps1 -Pattern "GrantIntegrationEntitlements"
#   scripts/smart-search.ps1 -Pattern "PaidFlagKey" -Path services -Glob "*.cs" -Context 2

param(
    [Parameter(Mandatory = $true)][string]$Pattern,
    [string]$Path = '.',
    [string]$Glob,
    [int]$MaxResults = 15,
    [int]$Context = 0,
    [switch]$IgnoreCase
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot

# ---- tool selection: ripgrep > git grep > findstr ----------------------------
$rg = Get-Command rg -ErrorAction SilentlyContinue

if ($rg) {
    $args = @($Pattern, $Path, '--line-number', '--max-count', $MaxResults)
    if ($Glob)      { $args += @('--glob', $Glob) }
    if ($IgnoreCase){ $args += '-i' }
    if ($Context -gt 0) { $args += @('-C', $Context) }
    & rg @args
}
elseif (Get-Command git -ErrorAction SilentlyContinue) {
    $args = @('grep', '-n')
    if ($IgnoreCase) { $args += '-i' }
    if ($Context -gt 0) { $args += @('-C', $Context) }
    $args += @('--max-count', $MaxResults, $Pattern, '--', $Path)
    if ($Glob) { $args += @('*', $Glob) | Select-Object -Unique }  # git grep globs differ; best effort
    & git @args
}
else {
    $findstrArgs = @('/N', '/P')
    if ($IgnoreCase) { $findstrArgs += '/I' }
    if ($Context -gt 0) { $findstrArgs += @('/C', $Context) }  # literal context lines; approximate
    if (-not $Glob) { $Glob = '*' }
    $findstrArgs += $Pattern
    & findstr.exe $findstrArgs (Get-ChildItem -Recurse -File -Filter $Glob -Path $Path).FullName
}

Write-Host ''
Write-Host "[budget] $MaxResults hit(s) shown. Read a bounded window around the decisive hit" -ForegroundColor DarkGray
Write-Host '[budget] (offset/limit), never the whole file. One pass per file.' -ForegroundColor DarkGray
