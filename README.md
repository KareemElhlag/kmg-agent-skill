<!-- Created By: Karim-(KaReem Elhlag)-Abdelhady -->

# kmg-agent-skill v2.1.0

Current release: **2.2.0**

**Author / Developer / Owner:** Karim-(KaReem Elhlag)-Abdelhady
**Contact Email:** kareemelhlag@gmail.com

**A portable engineering skill for AI agents** building and operating complex multi-tenant SaaS ERP systems.
It encodes a production-proven task lifecycle (`P0 → P11`), clean architecture discipline, container/runtime
synchronization, financial entitlement integrity, and fail-closed evidence rules — every rule anchored to a real
defect class, not to generic best practice.

---

## What's inside

| File | Purpose |
|---|---|
| `SKILL.md` | The skill entry point: when to load it, token budgeting rules, temp isolation policy, the ten non-negotiables. |
| `PLAYBOOK.md` | The full engineering playbook: task protocol, environment sync, clean architecture (DDD/CQRS/MediatR/EF Core), the Paid-Pack Triple, write-shape guard, evidence & live readback. |
| `QUALITY_GATES.md` | Feature/review gates, complexity limits, maintainability rules, and accept/reject vocabulary. |
| `PERFORMANCE.md` | Baselines, deltas, API/database/UI/job metrics, and default performance budgets. |
| `NETWORK_AND_JOBS.md` | HTTP, SignalR, messaging, retry, idempotency, outbox, and job rules. |
| `roles/*.md` | General, .NET, and Frontend architect/designer/security review roles with routing rules. |
| `templates/structure.md` | Template for documenting a project's layer/membership structure and blast-radius mapping. |
| `templates/business.md` | Template for documenting business rules, commercial packs, entitlements, and money invariants. |
| `templates/workflow.md` | Template for task run records: stages, results, deltas, denominators, residue. |
| `project.config.example` | Committable template for your local `project.config.json` (paths, ports, API bases, runtime map) — the local file itself is git-ignored. |
| `field-lessons.example` | Committable template for your local `field-lessons.md` (the agent's living incident log) — the local file itself is git-ignored. |
| `scripts/init-temp.sh` / `init-temp.ps1` | Initialize the isolated `temp/` scratch directory, enforce its gitignore contract, and hygiene-scan for stray artifacts. |
| `scripts/smart-search.ps1` | Targeted symbol search with bounded output — search first, read second (~85% token saving). |
| `scripts/read-blueprints.ps1` | Instant, bounded read of the blueprint set (structure → business → workflow, then project blueprints). |
| `scripts/check-env.ps1` | P2.5 container/runtime sync readback: stale-container detection, port checks, dotnet watch vs run. |
| `scripts/run-task-pipeline.ps1` | The pre-flight engine: automates P0 intake → P1/P2 scaffolds → P2.5 env readback → P3 blueprints → P4 searches in one command (~92% of exploration automated). |
| `scripts/validate-quality-gates.ps1` | Checks required v2 files, local-only file isolation, version, and public-tree secret patterns. |
| `SENIOR_MONITOR.md` | Mandatory post-work certification rubric and fail-closed decision model. |
| `scripts/senior-monitor.ps1` | Deterministic post-work hygiene/evidence gate; raw output stays in `temp/`. |

---

## How an AI agent uses this skill

### 1. Load order

1. Read `SKILL.md` first — it decides whether the rest of the skill is worth its token cost for the task at hand.
2. For any repository-changing task, load `PLAYBOOK.md` §1 (the `P0 → P11` protocol) and follow it from `P0`.
3. Load only the sections the task touches: §2 for containerized runtimes, §3 for architecture changes,
   §4 for money/entitlement work, §5 before any file write, §6 before any "done" claim.

### 2. Follow the protocol, not the mood

The protocol (`P0 → P11`) is one workflow for every task; only the class delta varies. Start at `P0` (verbatim
intake), classify at `P1`, map the blast radius at `P2`, **read the running environment at `P2.5`**, and do not
write code before `P3` (read the tree). A red gate at any stage stops the run until fixed.

### 3. Produce evidence, not assertions

Every claim gets a durable artifact: a gate file with exit codes, a run record with stage rows and deltas, a
registry row per claim, and — for anything that changes what an endpoint serves — a **live readback** of the
running service. `SKIPPED`/`BLOCKED`/`GATED` never count as passed.

### 4. Use the templates

Copy a template per task and fill only what applies; delete nothing silently. The templates encode the exact
tables the playbook's evidence contract expects, so a filled template *is* a compliant record.

### 5. Set up the local layer (once per machine)

```bash
cp project.config.example project.config.json   # then fill paths/ports/API bases
cp field-lessons.example  field-lessons.md      # your private incident log
scripts/init-temp.sh                            # or scripts/init-temp.ps1
```

`project.config.json` and `field-lessons.md` are **git-ignored by contract and never leave your machine**;
only their `*.example` templates are committed. Keep real paths, ports, tenant references, and incident
details out of every committable file.

### 6. Automate the pre-flight

```powershell
scripts/run-task-pipeline.ps1 -Task "<verbatim task statement>" -Symbols "SymbolOne,SymbolTwo"
```

One command runs P0 verbatim intake, emits the P1 classification and P2 blast-radius scaffolds, executes the
P2.5 environment readback (`check-env.ps1`), reads the blueprints (P3), and runs the targeted searches (P4) —
all into `temp/`. You summarize the results into the durable record; the engine pre-flights, it does not decide.

---

## Data Privacy & Security — strict notice

> **READ BEFORE APPLYING THIS SKILL TO ANY REPOSITORY.**

This skill was distilled from the engineering experience of real production systems. **It contains no source code,
no tenant data, no credentials, no secrets, and no proprietary identifiers** — and it must stay that way.

**Absolute prohibitions for any agent (or human) applying this skill:**

1. **Never read, collect, index, or export** secrets, API keys, connection strings, passwords, tokens, or any
   credential material — from environment files, configuration, databases, logs, or memory dumps.
2. **Never expose or export tenant data, customer data, or personal data** — names, identifiers, financial records,
   invoices, or any row-level business data — into skill files, templates, examples, logs, commits, or reports.
3. **Never copy proprietary source code, schema dumps, or internal documentation** out of the working repository
   into this skill or any artifact derived from it. The skill encodes *principles and shapes*, never *instances*.
4. **Never commit raw probe output** (API responses, database dumps, container inspections). Readbacks are recorded
   as the command plus the decisive numbers only; raw output belongs in the git-ignored `temp/` and is discarded.
5. **Redact before recording.** Any identifier that must appear in a record (a tenant name in a finding, a database
   name in a gate log) is reduced to the minimum needed to audit the claim — and never leaves the local repository.
6. **Least knowledge.** An agent should read the smallest scope that answers the task. Broad sweeps of sensitive
   trees are a privacy defect even when nothing is exported.

Violations of this section are severity-one defects — regardless of whether the data was ever published.

---

## License & Intellectual Property

**Copyright © 2026 Karim-(KaReem Elhlag)-Abdelhady. All rights reserved.**

- **Author / Developer / Owner:** Karim-(KaReem Elhlag)-Abdelhady
- **Contact Email:** kareemelhlag@gmail.com
- The skill's structure, playbook text, templates, and scripts are the intellectual property of the author.
- **Permitted use:** as an installed engineering skill for AI agents and human engineers inside your own
  development workflow; local modification for personal/team use.
- **Not permitted:** redistribution, resale, sublicensing, or republishing the skill (or derivatives) without the
  author's prior written consent.
- The skill ships **as-is**, with no warranty of any kind; applying it does not replace human code review or the
  owning team's own release gates.

## Versioning

Semantic versioning (`MAJOR.MINOR.PATCH`). Rules are added only when anchored to a new defect class with evidence;
corrections are appended with dates, never silently rewritten.
