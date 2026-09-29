# Created By: Karim-(KaReem Elhlag)-Abdelhady
# run-task-pipeline.ps1 - the automation engine: one command, P0->P11 pre-flight executed for you.
#
# What it automates (~92% of exploration/diagnosis work):
#   P0  - verbatim intake: writes the task statement to temp/task-intake.txt (no paraphrase).
#   P1  - classification scaffold: emits the class table skeleton into the run record.
#   P2  - blast radius scaffold: emits the touched-layers table skeleton.
#   P2.5- runs check-env.ps1 (stale-runtime readback) and records the verdict.
#   P3  - runs read-blueprints.ps1 (structure + business + workflow heads) into temp/.
#   P4  - runs smart-search.ps1 on the symbols you name, into temp/search-results.txt.
#   P5+ - gates are human/agent judgment; this script pre-flights, it does not decide.
#
# Everything it produces lands in temp/ - you summarize into the durable record yourself.
#
# Usage:
#   scripts/run-task-pipeline.ps1 -Task "Add renewal proration to the pack biller"
#   scripts/run-task-pipeline.ps1 -Task "..." -Symbols "GrantIntegrationEntitlements,PaidFlagKey"
#   scripts/run-task-pipeline.ps1 -Task "..." -SkipEnv       # skip the docker check

param(
    [Parameter(Mandatory = $true)][string]$Task,
    [string[]]$Symbols,
    [string]$Config = 'project.config.json',
    [switch]$SkipEnv
)

$ErrorActionPreference = 'Continue'
# The PROJECT root is where the caller invokes this script from; skill files resolve via $Root.
$ProjectRoot = (Get-Location).Path
$Root = Split-Path -Parent $PSScriptRoot
$Temp = Join-Path $Root 'temp'
New-Item -ItemType Directory -Path $Temp -Force | Out-Null

$stamp  = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
$header = "KMG TASK PIPELINE - $stamp"
Write-Host "=== $header ===" -ForegroundColor Cyan

# ---- P0: verbatim intake ---------------------------------------------------------
$intake = Join-Path $Temp 'task-intake.txt'
@"
P0 VERBATIM INTAKE - $stamp
TASK (verbatim, not paraphrased):
$Task
"@ | Set-Content -Path $intake -Encoding UTF8
Write-Host "P0  intake written -> temp/task-intake.txt"

# ---- P1/P2: scaffolds --------------------------------------------------------------
$scaffold = Join-Path $Temp 'task-scaffold.md'
@"
# Task scaffold - $stamp

## P1 classification (fill exactly one class + trigger)
| Class | Chosen | Trigger (verbatim reason) |
|---|---|---|
| CHORE / DOCS / FIX / FEATURE |  |  |

Rule: a change touching permissions, feature keys, or schema is FEATURE minimum regardless of diff size.

## P2 blast radius (fill before writing code)
| Layer | Touched? | Files | Notes |
|---|---|---|---|
| Domain |  |  |  |
| Application |  |  |  |
| Infrastructure |  |  |  |
| API |  |  |  |
| Frontend |  |  |  |
| Money surfaces |  |  | if yes -> the Paid-Pack Triple is mandatory |
"@ | Set-Content -Path $scaffold -Encoding UTF8
Write-Host "P1/P2 scaffold written -> temp/task-scaffold.md"

# ---- P2.5: environment readback -----------------------------------------------------
if (-not [System.IO.Path]::IsPathRooted($Config)) { $Config = Join-Path $ProjectRoot $Config }
$envLog = Join-Path $Temp 'env-check.log'
if ($SkipEnv) {
    "P2.5 SKIPPED by explicit flag" | Set-Content -Path $envLog -Encoding UTF8
    Write-Host 'P2.5 skipped (-SkipEnv).' -ForegroundColor Yellow
} else {
    Write-Host 'P2.5 environment readback...'
    if (Test-Path "$Root/scripts/check-env.ps1") {
        & "$Root/scripts/check-env.ps1" -Config $Config 2>&1 | Tee-Object -FilePath $envLog
        if ($LASTEXITCODE -eq 1) {
            Write-Host 'P2.5 GATE: RED - fix the runtime before writing code (rerun from this stage).' -ForegroundColor Red
            exit 1
        }
    } else {
        'check-env.ps1 not found' | Set-Content -Path $envLog -Encoding UTF8
        Write-Host 'P2.5 check-env.ps1 missing - run it once it exists.' -ForegroundColor Yellow
    }
}

# ---- P3: blueprint read --------------------------------------------------------------
Write-Host 'P3 blueprint read...'
& "$Root/scripts/read-blueprints.ps1" -Config $Config | Out-File (Join-Path $Temp 'blueprints-read.txt') -Encoding UTF8
Write-Host "P3 blueprints read -> temp/blueprints-read.txt"

# ---- P4: targeted searches ------------------------------------------------------------
if ($Symbols) {
    $searchLog = Join-Path $Temp 'search-results.txt'
    "KMG smart-search - $stamp" | Set-Content -Path $searchLog -Encoding UTF8
    foreach ($sym in $Symbols) {
        "=== symbol: $sym ===" | Add-Content -Path $searchLog -Encoding UTF8
        & "$Root/scripts/smart-search.ps1" -Pattern $sym -MaxResults 10 2>&1 | Add-Content -Path $searchLog -Encoding UTF8
    }
    Write-Host "P4 searches -> temp/search-results.txt"
} else {
    Write-Host 'P4 no -Symbols given - targeted search skipped (do it manually before P5).'
}

# ---- verdict ----------------------------------------------------------------------------
Write-Host ''
Write-Host 'PIPELINE: pre-flight complete. Gates P5+ (writes, tests, evidence, registration)' -ForegroundColor Green
Write-Host 'remain agent-judgment: this engine pre-flights, it does not decide.' -ForegroundColor Green
exit 0
