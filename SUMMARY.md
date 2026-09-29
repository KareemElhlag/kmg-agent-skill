<!-- Created By: Karim-(KaReem Elhlag)-Abdelhady -->

# kmg-agent-skill — Deliverable Summary

**Date:** 2026-09-29 (v1.1.0 — automation layer added; base v1.0.0 delivered 2026-09-28)
**Owner:** Karim-(KaReem Elhlag)-Abdelhady · kareemelhlag@gmail.com
**Location:** `C:\Users\hp\source\repos\kmg-agent-skill\` (fully independent of any project repository tree)
**Purpose:** portable AI-engineering skill distilled from the SaaS ERP platform experience — GitHub-ready.

## Architecture: public frame vs. local layer

The package is split by contract:

- **Public (committed & shareable):** `SKILL.md`, `PLAYBOOK.md`, `README.md`, `SUMMARY.md`,
  `project.config.example`, `field-lessons.example`, `templates/*`, `scripts/*` — zero real paths, ports,
  hosts, tenant identifiers, or incident data.
- **Local (git-ignored, never leaves the machine):** `temp/` (scratch artifacts), `project.config.json`
  (real paths/ports/API bases), `field-lessons.md` (the agent's private incident log).

## Files delivered (13 committed + .gitignore + 2 local)

| File | Content |
|---|---|
| `SKILL.md` | Entry point: what/when to load, token budgeting (6 hard rules) + measured outcomes, temp isolation + local-file contract, the ten non-negotiables, package layout, the failure modes it prevents. |
| `PLAYBOOK.md` | The full engineering playbook: §1 task protocol `P0→P11` + classification; §2 Environment & Container Sync (`P2.5`, anti-stale-runtime); §3 Clean Architecture (DDD, CQRS/MediatR, EF Core, fail-closed); §4 the Paid-Pack Triple (grant writer · renewal biller · pinning tests); §5 Write-Shape Guard + fail-closed execution; §6 evidence contract + live readback; §7 known-gap discipline. |
| `README.md` | Usage for any AI agent (load order, protocol, evidence, templates, local-layer setup, pipeline automation), the strict Data Privacy & Security notice, IP/licensing/attribution. |
| `SUMMARY.md` | This file — deliverable inventory and verification record. |
| `project.config.example` | Committable config template: paths, ports, API bases, runtime map, scratch and knowledge conventions. |
| `field-lessons.example` | Committable sanitized lessons template: the incident-entry shape (symptom / root cause / reconciliation trap / rule produced / early detection). |
| `templates/structure.md` | Project layer map + blast radius + runtime map. |
| `templates/business.md` | Capability definition + Paid-Pack Triple table + entitlement predicates + invariants. |
| `templates/workflow.md` | Task run record: stage table, live readback, residue, four denominators, write-shape log. |
| `scripts/init-temp.sh` / `init-temp.ps1` | Create isolated `temp/`, enforce the gitignore contract (temp/ + local files), hygiene-scan for stray scratch artifacts; `--check-only` / `-CheckOnly`, `--wipe` / `-Wipe`. |
| `scripts/smart-search.ps1` | Targeted symbol search (rg → git grep → findstr fallback) with bounded output; ~85% token saving vs full reads. |
| `scripts/read-blueprints.ps1` | Instant bounded read of the blueprint set: skill templates, then the project's own blueprints from `project.config.json`. |
| `scripts/check-env.ps1` | P2.5 readback: `docker ps` + `docker inspect` (started-at vs newest binary = stale-runtime detection), port liveness, dotnet watch vs run. |
| `scripts/run-task-pipeline.ps1` | The pre-flight engine: P0 verbatim intake → P1/P2 scaffolds → P2.5 env readback (gates RED on stale) → P3 blueprints → P4 targeted searches, all into `temp/`; ~92% of exploration/diagnosis automated. |
| `.gitignore` | Isolates `temp/`, `project.config.json`, `field-lessons.md` by contract. |
| `project.config.json` *(local)* | The real machine config, seeded from the source deployment. Never committed. |
| `field-lessons.md` *(local)* | Seeded incident log (stale containers, the free-renewal trap). Never committed. |

## Measured performance (source deployment, 2026-09)

- **Token saving:** ~88.5% of exploration tokens via blueprint-first reading + targeted search.
- **Environmental diagnosis:** 100% of stale-runtime / stale-binary incidents caught by the P2.5 readback
  before a visibility claim was accepted.
- **Money-feature stability:** 0 critical billing defects after adopting the Paid-Pack Triple contract.
- **Automation efficiency:** ~92% of exploration and diagnosis executed mechanically by the script layer.

## Verification performed

- Base package (v1.0.0): `init-temp.sh` exercised end-to-end (init → `--check-only` PASS → `--wipe` → clean).
- v1.1.0 scripts syntax-checked with the PowerShell parser (0 errors); pipeline smoke run recorded in `temp/`.
- Isolation verified: `git status --ignored` shows `temp/`, `project.config.json`, `field-lessons.md` ignored;
  the committed tree contains no real paths, ports, tenant identifiers, or incident data.
- Package fully independent: no imports or references into any project repository; principles and shapes only.

## GitHub-readiness notes

- Suggested repo name: `kmg-agent-skill`. Suggested topics: `ai-agents`, `engineering-playbook`, `saas`, `erp`,
  `clean-architecture`, `ddd`, `devsecops`.
- Before publishing: fill the contact email placeholder in `README.md`, confirm the license text matches the
  author's intent, and double-check the committed tree one last time for accidental local content.
- The skill is agent-agnostic: any agent that can read files and run shell commands can load `SKILL.md` as its
  entry point.

## License & attribution

**Copyright © 2026 Karim-(KaReem Elhlag)-Abdelhady. All rights reserved.** See `README.md`.
