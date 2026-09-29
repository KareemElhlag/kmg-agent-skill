# Created By: Karim-(KaReem Elhlag)-Abdelhady
# check-env.ps1 - container/runtime synchronization check (PLAYBOOK section 2, protocol P2.5).
#
# Purpose: kill the "stale runtime" defect class - a verified code change that stays invisible
# because the serving container predates it. Read the runtime; never assume it.
#
# Checks:
#   1. Docker availability and running containers (started-at vs. newest relevant binary).
#   2. Dev ports from project.config.json actually listening.
#   3. dotnet watch vs dotnet run detection (a bind mount is not a rebuild).
#
# Exit codes: 0 = env in sync, 1 = stale/misaligned runtime found, 2 = docker missing/unreadable.
#
# Usage:
#   scripts/check-env.ps1                      # full check against project.config.json
#   scripts/check-env.ps1 -Services api,web    # restrict to specific compose services

param(
    [string]$Config = 'project.config.json',
    [string[]]$Services,
    [int]$StaleMinutes = 0
)

$ErrorActionPreference = 'Continue'
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

$failures = @()
$warnings = @()

function Fail([string]$m) { $script:failures += $m; Write-Host "FAIL: $m" -ForegroundColor Red }
function Warn([string]$m) { $script:warnings += $m; Write-Host "WARN: $m" -ForegroundColor Yellow }
function Ok([string]$m)   { Write-Host "OK: $m" -ForegroundColor Green }

# ---- 0. Load local config -----------------------------------------------------
$cfg = $null
if (Test-Path $Config) {
    try { $cfg = Get-Content $Config -Raw | ConvertFrom-Json } catch { Warn "could not parse $Config : $($_.Exception.Message)" }
} else {
    Warn "$Config not found - copy project.config.example to project.config.json and fill it."
}

# ---- 1. Docker: available? containers fresh? -----------------------------------
$docker = Get-Command docker -ErrorAction SilentlyContinue
if (-not $docker) {
    Write-Host 'SKIP: docker not on PATH - container sync cannot be verified here.'
    exit 0
}

$psOut = & docker ps --format '{{.Names}}|{{.Image}}|{{.Status}}|{{.RunningFor}}' 2>$null
if ($LASTEXITCODE -ne 0) { Write-Host 'FAIL: docker present but not readable (daemon down or permissions).' -ForegroundColor Red; exit 2 }

if (-not $psOut) {
    Write-Host 'OK: docker reachable; no containers running (nothing to go stale).'
} else {
    Write-Host '--- running containers ---'
    $psOut | ForEach-Object {
        $parts = $_ -split '\|'
        if ($Services -and ($parts[0] -notin $Services -and $parts[1] -notmatch ($Services -join '|'))) { return }
        Write-Host ("  {0,-32} {1,-40} {2}" -f $parts[0], $parts[1], $parts[2])

        # started-at readback per P2.5
        $insp = & docker inspect $parts[0] --format '{{.State.StartedAt}}' 2>$null
        if ($LASTEXITCODE -eq 0) {
            $startedAt = [datetime]$insp
            $ageMin = [int]((New-TimeSpan $startedAt (Get-Date)).TotalMinutes)

            # newest binary under the repo (bin/obj debug outputs), if any
            $newestBin = Get-ChildItem -Path $Root -Recurse -Include '*.dll' -File -ErrorAction SilentlyContinue |
                Where-Object { $_.FullName -match '\\bin\\' } |
                Sort-Object LastWriteTime -Descending | Select-Object -First 1
            if ($newestBin -and $newestBin.LastWriteTime -gt $startedAt) {
                $staleMin = [int]((New-TimeSpan $startedAt $newestBin.LastWriteTime).TotalMinutes)
                if ($staleMin -ge $StaleMinutes) {
                    Fail ("stale runtime: container '{0}' started {1} but binaries changed {2} later ({3} min after start) - restart before claiming visibility." -f $parts[0], $startedAt.ToString('yyyy-MM-dd HH:mm'), $newestBin.Name, $staleMin)
                }
            }
        }
    }
}

# ---- 2. Ports from config actually listening ------------------------------------
if ($cfg -and $cfg.ports) {
    Write-Host '--- ports ---'
    foreach ($prop in $cfg.ports.PSObject.Properties) {
        $port = $prop.Value
        if ($port -isnot [int]) { continue }
        $listening = Test-NetConnection -ComputerName 127.0.0.1 -Port $port -InformationLevel Quiet -WarningAction SilentlyContinue
        if ($listening) { Ok ("port {0} ({1}) is listening" -f $port, $prop.Name) }
        else            { Warn ("port {0} ({1}) is NOT listening - is the runtime up?" -f $port, $prop.Name) }
    }
}

# ---- 3. dotnet watch vs dotnet run detection ------------------------------------
if ($cfg -and $cfg.runtime -and $cfg.runtime.containerized) {
    Write-Host '--- runtime mode ---'
    $procs = Get-Process -Name 'dotnet' -ErrorAction SilentlyContinue
    if ($procs) {
        foreach ($p in $procs) {
            $cmd = (Get-CimInstance Win32_Process -Filter "ProcessId=$($p.Id)" -ErrorAction SilentlyContinue).CommandLine
            if ($cmd -match 'watch') { Ok ("dotnet watch (pid $($p.Id)) - file changes propagate; rebuild-on-save is active.") }
            elseif ($cmd -match 'run') { Warn ("dotnet run (pid $($p.Id)) - changes need an explicit restart/rebuild (P2.5).") }
        }
    } else {
        Write-Host '  (no host dotnet processes; runtime presumably fully containerized)'
    }
    if ($failures.Count -eq 0) { Ok 'container/runtime sync read - no staleness detected.' }
}

# ---- verdict ----------------------------------------------------------------------
Write-Host ''
if ($failures.Count -gt 0) {
    Write-Host ("CHECK-ENV: FAIL - {0} stale/misaligned item(s). Fix before proceeding (P2.5)." -f $failures.Count) -ForegroundColor Red
    exit 1
}
if ($warnings.Count -gt 0) {
    Write-Host ("CHECK-ENV: PASS WITH WARNINGS - {0} item(s) to look at." -f $warnings.Count) -ForegroundColor Yellow
    exit 0
}
Write-Host 'CHECK-ENV: PASS - environment in sync.' -ForegroundColor Green
exit 0
