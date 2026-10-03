[CmdletBinding()]
param(
    [string]$Root = (Get-Location).Path,
    [string]$EvidencePath = "",
    [switch]$SkipTests
)

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
$secret = Get-ChildItem $rootPath -Recurse -File -Force -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch '\\(bin|obj|node_modules|\.git|temp)\\' -and $_.Name -match '(^|\.)(env|pem|key|pfx|secret)$' } |
    Select-Object -First 1
Add-Check "sensitive-file guard" ($null -eq $secret) "no obvious secret file in tracked surface"

if ($EvidencePath) {
    $evidence = Join-Path $rootPath $EvidencePath
    Add-Check "evidence bundle" (Test-Path $evidence) "requested evidence path"
}
if (-not $SkipTests) {
    $testProjects = @(Get-ChildItem $rootPath -Recurse -Filter '*Tests.csproj' -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch '\\(bin|obj|node_modules|\.git)\\' })
    Add-Check "test inventory" ($testProjects.Count -gt 0) "found $($testProjects.Count) test project(s)"
}

$checks | Set-Content -Encoding utf8 $report
$blocked = @($checks | Where-Object { $_ -like '[BLOCK]*' })
$decision = if ($blocked.Count -gt 0) { "BLOCKED" } else { "REVIEW_REQUIRED" }
Add-Content -Encoding utf8 $report "Decision: $decision"
Write-Output "Senior Monitor: $decision"
Write-Output "Evidence: $report"
if ($blocked.Count -gt 0) { exit 2 }
