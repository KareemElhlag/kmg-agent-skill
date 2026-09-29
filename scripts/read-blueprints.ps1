# Created By: Karim-(KaReem Elhlag)-Abdelhady
# read-blueprints.ps1 - instant, bounded read of the project's blueprint set.
#
# Budget rationale: one command answers "what is this project and what rules govern it"
# (~90% saving vs reading files across the tree to reconstruct context).
#
# Order: skill templates (structure -> business -> workflow), then the project's own
# blueprint documents listed in project.config.json (paths.docs.blueprints).
#
# Usage:
#   scripts/read-blueprints.ps1                 # heads (120 lines each)
#   scripts/read-blueprints.ps1 -Lines 40       # tighter budget
#   scripts/read-blueprints.ps1 -Full           # whole blueprint set (use sparingly)

param(
    [int]$Lines = 120,
    [switch]$Full,
    [string]$Config = 'project.config.json'
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

function Show-File {
    param([string]$File, [string]$Title)
    if (-not (Test-Path $File)) { Write-Host "MISSING: $File" -ForegroundColor Yellow; return }
    Write-Host ''
    Write-Host ("===== {0}  ({1}) =====" -f $Title, $File) -ForegroundColor Cyan
    if ($Full) { Get-Content $File }
    else       { Get-Content $File -TotalCount $Lines; Write-Host "... [truncated at $Lines lines; -Full for the rest]" -ForegroundColor DarkGray }
}

# ---- 1. The skill's own blueprints ------------------------------------------
Show-File 'templates/structure.md' 'STRUCTURE  (layers, blast radius)'
Show-File 'templates/business.md'  'BUSINESS   (rules, money invariants, Paid-Pack Triple)'
Show-File 'templates/workflow.md'  'WORKFLOW   (task protocol, run record)'

# ---- 2. The project's own blueprints, if configured --------------------------
if (Test-Path $Config) {
    try {
        $cfg = Get-Content $Config -Raw | ConvertFrom-Json
        $bpDir = $cfg.paths.docs.blueprints
        if ($bpDir -and (Test-Path $bpDir)) {
            $files = Get-ChildItem $bpDir -File -Include *.md -Recurse -ErrorAction SilentlyContinue
            if (-not $files) { $files = Get-ChildItem $bpDir -Filter *.md -File -ErrorAction SilentlyContinue }
            foreach ($f in $files) { Show-File $f.FullName "PROJECT BLUEPRINT  ($($f.BaseName))" }
        } else {
            Write-Host ''
            Write-Host "[config] no blueprints directory found at '$bpDir' - skipping project blueprints." -ForegroundColor DarkGray
        }
    } catch {
        Write-Host "[config] could not parse $Config : $($_.Exception.Message)" -ForegroundColor Yellow
    }
} else {
    Write-Host ''
    Write-Host "[config] $Config not found - copy project.config.example and fill your paths to include project blueprints." -ForegroundColor DarkGray
}
