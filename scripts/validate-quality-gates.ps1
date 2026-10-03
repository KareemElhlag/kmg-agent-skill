# Created By: Karim-(KaReem Elhlag)-Abdelhady
[CmdletBinding()]
param([string]$Root = (Split-Path -Parent $PSScriptRoot))
$ErrorActionPreference = 'Stop'
$required = @('SKILL.md','PLAYBOOK.md','QUALITY_GATES.md','PERFORMANCE.md','NETWORK_AND_JOBS.md','README.md','SUMMARY.md')
$missing = @($required | Where-Object { -not (Test-Path (Join-Path $Root $_)) })
if ($missing.Count -gt 0) { Write-Error ("Missing required files: " + ($missing -join ', ')); exit 1 }
$localForbidden = @('project.config.json','field-lessons.md') | Where-Object { Test-Path (Join-Path $Root $_) }
if ($localForbidden.Count -gt 0) { Write-Error ("Local-only files must not be committed: " + ($localForbidden -join ', ')); exit 1 }
$files = Get-ChildItem -Path $Root -File -Recurse | Where-Object { $_.FullName -notmatch '\\temp\\|\\.git\\' }
$content = $files | Get-Content -Raw
$secretPatterns = @('AKIA[0-9A-Z]{16}','-----BEGIN (RSA|OPENSSH|EC) PRIVATE KEY-----','password\s*[:=]\s*[^<\s]+','connectionstrings?\s*[:=]')
foreach ($pattern in $secretPatterns) { if ($content -match $pattern) { Write-Error "Potential secret pattern detected: $pattern"; exit 1 } }
if ((Get-Content (Join-Path $Root 'SKILL.md') -Raw) -notmatch 'version: 2\.0\.0') { Write-Error 'SKILL.md is not version 2.0.0'; exit 1 }
Write-Output 'QUALITY_GATES_VALIDATION=PASS'
Write-Output "REQUIRED_FILES=$($required.Count)"
Write-Output "SECRET_PATTERNS_CHECKED=$($secretPatterns.Count)"
exit 0
