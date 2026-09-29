# Created By: Karim-(KaReem Elhlag)-Abdelhady
# init-temp.ps1 — isolated scratch-directory initialization & hygiene guard (PowerShell twin of init-temp.sh).
#
# Contract (SKILL.md section 4):
#   * One scratch directory per session: temp/ at the project root.
#   * ALL intermediate artifacts live there (gate logs, curl dumps, probes, one-off scripts).
#   * temp/ is git-ignored by contract and safe to wipe at any time.
#   * Local-only files (project.config.json, field-lessons.md) stay git-ignored too.
#
# Usage:
#   scripts/init-temp.ps1              # initialize + hygiene check
#   scripts/init-temp.ps1 -CheckOnly   # hygiene check without creating anything
#   scripts/init-temp.ps1 -Wipe        # empty temp/ (durable records must already exist)

param(
    [switch]$CheckOnly,
    [switch]$Wipe
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

$TempDir   = Join-Path $Root 'temp'
$Gitignore = Join-Path $Root '.gitignore'

$RequiredIgnores = @('temp/', 'project.config.json', 'field-lessons.md')
$Marker = '# kmg-agent-skill: isolated local files (scratch, config, field lessons)'

function Ensure-Gitignore {
    if (-not (Test-Path $Gitignore)) {
        if ($CheckOnly) { Write-Host 'FAIL: .gitignore missing (cannot honour the isolation contract).' -ForegroundColor Red; exit 1 }
        Set-Content -Path $Gitignore -Value $Marker -Encoding UTF8
    }
    $content = Get-Content $Gitignore -Raw
    $missing = $RequiredIgnores | Where-Object { $content -notmatch [regex]::Escape($_) }
    if ($missing.Count -gt 0) {
        if ($CheckOnly) {
            Write-Host ("FAIL: not git-ignored: {0}" -f ($missing -join ', ')) -ForegroundColor Red
            exit 1
        }
        Add-Content -Path $Gitignore -Value $missing -Encoding UTF8
        Write-Host ("OK: added to .gitignore: {0}" -f ($missing -join ', '))
    }
}

# --- 1. Create or wipe the scratch directory ---------------------------------
if ($Wipe) {
    if (Test-Path $TempDir) {
        Get-ChildItem $TempDir -Force | Remove-Item -Recurse -Force
        Write-Host 'OK: temp/ wiped (durable records are the only source of truth).'
    } else {
        Write-Host 'OK: no temp/ to wipe.'
    }
    Ensure-Gitignore
    exit 0
}

if (-not $CheckOnly) {
    New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
    Write-Host "OK: temp/ ready at $TempDir"
}
Ensure-Gitignore

# --- 2. Hygiene: no stray scratch artifacts in the project tree --------------
$StrayPatterns = @('gate*.txt','nexus*.txt','probe*.txt','scratch*.txt','output*.txt','curl-dump*','*-dump.json','tmp-*','.scratch*')
$SkipDirs = @('temp','node_modules','.git','bin','obj','.venv','dist','build')

$stray = @()
foreach ($pattern in $StrayPatterns) {
    $stray += Get-ChildItem -Path $Root -Filter $pattern -File -Recurse -Force -ErrorAction SilentlyContinue |
        Where-Object { $p = $_.FullName; -not ($SkipDirs | Where-Object { $p -match [regex]::Escape("\$_\") }) }
}

if ($stray.Count -gt 0) {
    foreach ($f in $stray) { Write-Host "STRAY: $($f.FullName)  (move into temp/ or delete)" -ForegroundColor Yellow }
    Write-Host 'HYGIENE: FAIL - stray scratch artifacts outside temp/.' -ForegroundColor Red
    exit 1
}

Write-Host 'HYGIENE: PASS - tree clean, temp/ isolated, local files git-ignored.' -ForegroundColor Green
exit 0
