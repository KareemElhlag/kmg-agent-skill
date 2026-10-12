[CmdletBinding()]
param(
    [string]$Root = (Get-Location).Path,
    [string]$EvidencePath = "",
    [switch]$SkipTests
)

<#
.SYNOPSIS
Mechanical pre-checks for the Senior Monitor stage (SKILL.md / SENIOR_MONITOR.md).

.IMPORTANT (read this before trusting the decision line)
This script can only ever prove a NEGATIVE: that none of its own mechanical probes found a blocker.
It cannot evaluate the substantive gates in SENIOR_MONITOR.md#Gates (architecture ownership,
correctness of business logic, whether security/tenant checks are actually right, whether the UX
states are actually correct) - those require the agent's own judgment against the real diff and the
real runtime evidence gathered during the task. A clean mechanical run is therefore reported as
MECHANICAL_CHECKS_PASSED, not CERTIFIED: it is a necessary precondition for CERTIFIED /
CERTIFIED_WITH_RESIDUE, never sufficient by itself. The agent renders the actual SENIOR_MONITOR.md
decision (CERTIFIED / CERTIFIED_WITH_RESIDUE / REWORK_REQUIRED / BLOCKED) by combining this script's
result with its own gate-by-gate review, and states that decision explicitly in the closing report -
this script's own stdout is not the final word and must never be quoted as if it were.

(Fixed 2026-10-12: a prior version of this script could only ever emit BLOCKED or REVIEW_REQUIRED -
REVIEW_REQUIRED on every single run regardless of how clean the work was, contradicting the four-way
decision set this document itself defines. That made the "mandatory certification" stage report the
same inconclusive result every time, which several review cycles this project ran noted as a real
skill defect. This version is honest about what a script can and cannot certify instead.)
#>

$ErrorActionPreference = "Stop"
$rootPath = (Resolve-Path $Root).Path
$temp = Join-Path $rootPath "temp"
New-Item -ItemType Directory -Force -Path $temp | Out-Null
$report = Join-Path $temp "senior-monitor-report.txt"
$checks = [System.Collections.Generic.List[string]]::new()

function Add-Check([string]$Name, [bool]$Passed, [string]$Detail) {
    $state = if ($Passed) { "PASS" } else { "BLOCK" }
    $checks.Add("[$state] $Name - $Detail")
}

Add-Check "git repository" (Test-Path (Join-Path $rootPath ".git")) "repository root resolved"
Add-Check "scratch isolation" (Test-Path $temp) "temporary evidence path exists"

# --- Sensitive-file guard: filename/extension heuristic (cheap, kept as a first pass) ---
$secretFile = Get-ChildItem $rootPath -Recurse -File -Force -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch '\\(bin|obj|node_modules|\.git|temp)\\' -and $_.Name -match '(^|\.)(env|pem|key|pfx|secret)$' } |
    Select-Object -First 1
Add-Check "sensitive-file guard (filename)" ($null -eq $secretFile) "no obviously-named secret file in tracked surface"

# --- Sensitive-content guard: this is the check a filename-only pass cannot do. ---
# A filename pass alone gave a false sense of safety at least once in this project's real history:
# a live reCAPTCHA secret sat inside a perfectly normally-named appsettings.json for three months,
# tracked in git, and no filename-based check ever flagged it. This pass greps tracked file CONTENT
# for a short list of high-confidence secret shapes. It is still only a heuristic (not a replacement
# for a real secret-scanning tool in CI), but it would have caught that exact incident.
$secretContentPatterns = @(
    # Cloud/provider key shapes with a recognizable prefix
    'AKIA[0-9A-Z]{16}',                                   # AWS access key id
    'AIza[0-9A-Za-z_\-]{35}',                              # Google API key
    'sk_live_[0-9a-zA-Z]{16,}',                             # Stripe live secret key
    'xox[baprs]-[0-9A-Za-z-]{10,}',                         # Slack token
    'ghp_[0-9A-Za-z]{36}',                                  # GitHub personal access token
    '-----BEGIN (RSA|EC|OPENSSH|PRIVATE) KEY-----',        # private key material
    # A JSON/property assignment that looks like a real (non-empty, non-placeholder) secret value -
    # this is the shape that actually caught the reCAPTCHA incident: a named "SecretKey"/"ApiKey"/
    # "Password" field with a long opaque value, not "", not a ${...}/%...% placeholder.
    # No \s allowed in the value: a real secret is one opaque token, never natural-language text -
    # this excludes i18n label strings like "apiKey": "مفتاح API مخصص للمستأجر" (a UI label
    # describing an API key field, not a key), which an earlier version of this pattern flagged.
    '"(?i:(SecretKey|ApiKey|ApiSecret|ClientSecret|AccessToken|PrivateKey))"\s*:\s*"(?!\s*$|\$\{|%)[^"\s]{12,}"'
)
$contentScanRoots = @('services', 'nexusecore-web', 'scripts') | ForEach-Object { Join-Path $rootPath $_ } | Where-Object { Test-Path $_ }
$secretContentHits = [System.Collections.Generic.List[string]]::new()
if ($contentScanRoots.Count -gt 0) {
    $candidateFiles = Get-ChildItem $contentScanRoots -Recurse -File -Force -ErrorAction SilentlyContinue |
        Where-Object {
            $_.FullName -notmatch '\\(bin|obj|node_modules|\.git|temp|dist|build)\\' -and
            $_.Extension -in @('.json', '.config', '.yml', '.yaml', '.env', '.cs', '.ts', '.tsx', '.ps1', '.sh') -and
            $_.Length -lt 2MB
        }
    foreach ($file in $candidateFiles) {
        $text = $null
        try { $text = Get-Content $file.FullName -Raw -ErrorAction Stop } catch { continue }
        if ([string]::IsNullOrEmpty($text)) { continue }
        foreach ($pattern in $secretContentPatterns) {
            if ($text -match $pattern) {
                $secretContentHits.Add("$($file.FullName) :: matched /$pattern/")
                break
            }
        }
        if ($secretContentHits.Count -ge 20) { break }  # cap: this is a guard, not a full audit
    }
}
Add-Check "sensitive-content guard" ($secretContentHits.Count -eq 0) $(
    if ($secretContentHits.Count -eq 0) { "no high-confidence secret pattern found in scanned source" }
    else { "possible secret content in $($secretContentHits.Count) file(s) - see report for paths; verify and remove/rotate before certifying" }
)
if ($secretContentHits.Count -gt 0) {
    Add-Content -Encoding utf8 $report ($secretContentHits -join [Environment]::NewLine)
}

if ($EvidencePath) {
    $evidence = Join-Path $rootPath $EvidencePath
    Add-Check "evidence bundle" (Test-Path $evidence) "requested evidence path"
}
if (-not $SkipTests) {
    $testProjects = @(Get-ChildItem $rootPath -Recurse -Filter '*Tests.csproj' -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch '\\(bin|obj|node_modules|\.git)\\' })
    Add-Check "test inventory" ($testProjects.Count -gt 0) "found $($testProjects.Count) test project(s)"
}

$checks | Add-Content -Encoding utf8 $report
# NOTE: -like treats [BLOCK] as a character class (any one of B/L/O/C/K), not the literal string
# "[BLOCK]" - every string here starts with a literal '[' character, which that pattern can never
# match, so a wildcard -like check against '[BLOCK]*' silently never fires. Use a literal prefix
# check instead.
$blocked = @($checks | Where-Object { $_.StartsWith('[BLOCK]') })
$mechanicalResult = if ($blocked.Count -gt 0) { "BLOCKED" } else { "MECHANICAL_CHECKS_PASSED" }
Add-Content -Encoding utf8 $report "Mechanical result: $mechanicalResult"
Add-Content -Encoding utf8 $report "This is NOT the Senior Monitor decision. Render CERTIFIED / CERTIFIED_WITH_RESIDUE / REWORK_REQUIRED / BLOCKED yourself against SENIOR_MONITOR.md#Gates and state it in the closing report."

Write-Output "Senior Monitor mechanical pre-check: $mechanicalResult"
Write-Output "Evidence: $report"
Write-Output "Reminder: this script never certifies anything by itself - see the script's own header comment and SENIOR_MONITOR.md."
if ($blocked.Count -gt 0) { exit 2 }
