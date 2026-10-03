---
name: kmg-agent-skill
description: Advanced portable engineering standard for AI agents building and operating complex multi-tenant SaaS ERP systems — task lifecycle protocol, clean architecture, container/runtime synchronization, financial entitlement integrity, and fail-closed execution discipline.
version: 2.1.0
author: Karim-(KaReem Elhlag)-Abdelhady
license: Proprietary — all rights reserved. See README.md.
---

<!-- Created By: Karim-(KaReem Elhlag)-Abdelhady -->

# KMG Agent Skill — Portable SaaS/ERP Engineering Standard

## 1. What this skill is

This skill encodes a **production-proven engineering standard** for building, changing, certifying, and operating
complex SaaS ERP platforms — multi-tenant systems with billing, entitlements, financial ledgers, role-based and
attribute-based access control, background provisioning, and long-lived containerized runtimes.

It is **process, not product**: every rule in this skill is anchored to a *defect class that was actually met in
production*, and each rule exists because a plausible alternative produced a silent, reconciling, hard-to-diagnose
failure. Nothing here is generic best-practice copy; where a behavior is not enforced, it is labeled as a gap —
never stated as a rule.

**The single organizing principle:** *a claim is accepted only against the artifact that can falsify it.*
"Done", "green", "visible", "committed" are all claims about a tree, a test run, or a running service — and every
one of them can be read back mechanically. This skill turns that readback into a protocol.

## 2. When to load this skill

Load it when the task touches any of the following:

- **Task lifecycle management** — a change that must be classified, blast-radius-mapped, staged, gated, and registered.
- **Layered architecture** — Domain → Application → Infrastructure → API → Frontend boundaries.
- **Multi-tenant data isolation** — tenant-scoped queries, entitlement snapshots, feature keys.
- **Money surfaces** — packs, pricing, billing, renewals, discounts, proration.
- **Containerized runtimes** — Docker/compose dev stacks where a verified code change can still be invisible
  because the serving container predates it.
- **Feature go-to-market** — a capability that must become *purchasable* without financial leakage.

Do not load it for isolated content edits, one-shot scripts, or tasks with no repository footprint — the protocol
costs tokens and is only justified when a claim about the system must survive audit.

## 3. Token budgeting (mandatory)

Tokens are the scarcest resource in an agent session. The following are hard rules, not advice:

1. **Structural reading over full scans.** Never sweep a repository end-to-end when a structure file can answer
   the question. Read the smallest file that can falsify the claim at hand; prefer a 40-line window around a
   searched symbol over a 2,000-line file read.
2. **Search first, read second.** Locate the decision point with a targeted symbol search, then read a narrow
   window around it. A search hit with line numbers plus a bounded read replaces most full-file reads.
3. **One pass per file.** Re-reading a file because its first read was unfocused is a budget defect. Decide the
   question *before* opening the file.
4. **Bounded verification over exhaustive suites.** Run the narrowest test filter that can detect the change
   first; only widen on red. A red narrow run is cheaper than a green wide one that proves nothing new.
5. **Compressed evidence in records.** Run records capture the command, the number, and the delta — never the
   full transcript. A record that pastes logs is a record nobody re-reads.
6. **Context isolation for scratch work.** All intermediate artifacts (gate logs, curl dumps, probe outputs,
   scratch notes) live in an isolated `temp/` directory — see §4 — and are summarized into the durable record
   rather than pasted into it.

**Measured budget outcomes** (source deployment, 2026-09): structural reading plus targeted search saved
~88.5% of exploration tokens; the P2.5 runtime readback diagnosed stale-runtime incidents with 100% accuracy
(every stale container flagged before a visibility claim was accepted); after adopting the Paid-Pack Triple
(PLAYBOOK §4), shipped money features carried 0 critical billing defects; the script pre-flight
(`scripts/run-task-pipeline.ps1`) automates ~92% of exploration and diagnosis work.

## 4. Temporary-file isolation policy (mandatory)

Every session creates exactly **one** scratch directory: `temp/` at the skill root (or the working root when the
skill is deployed into a project). The rules:

- **All** intermediate artifacts go there: gate logs (`*.txt`), probe outputs, JSON dumps, one-off scripts,
  curl readbacks, diff snapshots.
- The project tree itself is **never** polluted: no `nexus-*.txt`, no `output-final2.txt`, no scratch files at
  repository root or next to source files. A stray artifact outside `temp/` is a cleanup defect to fix in the
  same session.
- `temp/` is **git-ignored by contract** (see `scripts/init-temp.sh`) and may be wiped at any time without risk:
  anything worth keeping was already summarized into the durable record (`docs/test-runs/…` or the project's
  equivalent).
- **Readback hygiene:** a live readback (curl, SQL probe, container inspect) is *recorded* in the durable record
  as the command + the decisive numbers, and its raw output stays in `temp/`. Never commit raw probe output.
- Initialize it once per session: run `scripts/init-temp.sh` (or `scripts/init-temp.ps1`) before the first
  artifact exists.
- **Local-only files never leave the machine:** `project.config.json` (your paths, ports, API bases) and
  `field-lessons.md` (the agent's incident log — e.g. the stale-container lesson, the free-renewal trap) are
  git-ignored by contract; only their sanitized `*.example` templates are ever committed.

## 5. The engineering core (what the playbook encodes)

The full lifecycle lives in `PLAYBOOK.md`. Its pillars, in dependency order:

| Pillar | Section | Essence |
|---|---|---|
| Task protocol `P0 → P11` | PLAYBOOK §1 | One workflow for every task; the class delta is the only variable. |
| Environment sync `P2.5` | PLAYBOOK §2 | A green suite is not a restart; read the container state before claiming visibility. |
| Clean architecture & DDD | PLAYBOOK §3 | Layer order, boundaries, CQRS/MediatR, EF Core owned types, fail-closed domain factories. |
| Money integrity | PLAYBOOK §4 | The Paid-Pack Triple: grant writer · renewal biller · pinning tests. |
| Write-shape & fail-closed execution | PLAYBOOK §5 | Every write verified by shape; every unresolved fact refused or explicit-unknown. |
| Live readback & registration | PLAYBOOK §6 | Evidence contract: commands, numbers, deltas — no blended denominators. |

## 6. Quality gates and measured acceptance

Version 2 adds explicit acceptance gates for feature creation, review, performance, networking, service-to-service
communication, and background jobs. Load the smallest relevant reference before changing code:

- `QUALITY_GATES.md` for severity, complexity, maintainability, test, and release thresholds.
- `PERFORMANCE.md` for baseline/delta measurements and latency, query, job, and error budgets.
- `NETWORK_AND_JOBS.md` for HTTP, SignalR, messaging, retries, idempotency, and job evidence.
- `templates/feature-review.md` for a review record that ends in an accept/reject decision.
- `scripts/validate-quality-gates.ps1` for deterministic hygiene and gate-shape validation.

The workflow is fail-closed: intake → architecture map → baseline → implementation → focused checks → contract and
runtime verification → performance delta → review decision → evidence registration. A missing measurement is
`BLOCKED`, not a pass. A warning is tracked with an owner and due stage; warnings are never silently discarded.

## 6.1 Role routing

Every task uses exactly one primary role and may consult the other roles when the blast radius crosses layers. All three
roles are software architects/designers and security-aware reviewers; their specialization changes the evidence they
require, not the quality bar:

- `roles/general-software-architect.md`: use for language-agnostic design, service boundaries, data contracts,
  threat modeling, maintainability, and cross-cutting reviews.
- `roles/dotnet-architect.md`: use when the change includes C#, .NET, ASP.NET Core, EF Core, MediatR, workers, or
  .NET service-to-service communication.
- `roles/frontend-architect.md`: use when the change includes React, TypeScript, Vite, Tailwind, browser state,
  accessibility, UI security, or frontend-to-API contracts.

Route by the files and runtime actually touched, not by the feature title. If both backend and frontend are changed,
select the dominant risk as primary and explicitly run the other role's contract checklist. The general role remains the
tie-breaker for architecture and security decisions. Never apply a role's framework preference against the repository's
existing architecture without recording the trade-off.

## 7. The non-negotiables (read this even if you read nothing else)

1. **Classify before you touch.** Every change gets exactly one class with its trigger written down; a change
   touching permissions, feature keys, or schema is FEATURE minimum regardless of diff size.
2. **Read the state before writing.** HEAD, working tree, touched lines — read, not recalled.
3. **Read the runtime before claiming visibility.** Container start time vs change time. `dotnet watch` is not
   `dotnet run`; a bind mount is not a rebuild.
4. **A red gate stops the run.** Fix and re-run *from that stage*. Never "keep re-running until green".
5. **No invented values.** An unresolved currency, rate, tenant id, or market is refused or explicit-unknown —
   never a plausible default.
6. **Writes are verified by shape**, not by eye: line count, non-ASCII count, diff stat.
7. **Money features ship with their triple**, or they do not ship.
8. **One commit per class, named paths, no push** without explicit instruction.
9. **Register every claim** with a row and a run record; `SKIPPED`/`BLOCKED`/`GATED` never count as passed.
10. **Disclose the residue.** What did not run, with the missing prerequisite named — every time.

## 8. Package layout

```
kmg-agent-skill/
├── SKILL.md                 ← this file (entry point — load first)
├── PLAYBOOK.md              ← the full engineering playbook (P0→P11, architecture, money, gates)
├── README.md                ← usage, data-privacy & security policy, licensing & attribution
├── SUMMARY.md               ← deliverable inventory & verification record
├── roles/                   ← scoped architecture, design, and security review roles
├── project.config.example   ← committable config template — copy to project.config.json (local only)
├── field-lessons.example    ← committable lessons template — copy to field-lessons.md (local only)
├── templates/
│   ├── structure.md         ← project-structure documentation template
│   ├── business.md          ← business-rules & commercial-logic documentation template
│   └── workflow.md          ← task/workflow run-record template
└── scripts/
    ├── init-temp.sh         ← temp/ initialization & hygiene guard (bash)
    ├── init-temp.ps1        ← temp/ initialization & hygiene guard (PowerShell)
    ├── smart-search.ps1     ← targeted symbol search (search first, read second)
    ├── read-blueprints.ps1  ← instant, bounded read of the blueprint set
    ├── check-env.ps1        ← P2.5 container/runtime sync readback (the stale-runtime killer)
    └── run-task-pipeline.ps1← the pre-flight engine: P0→P4 automated in one command
```

`temp/`, `project.config.json`, and `field-lessons.md` exist only on your machine — `.gitignore` enforces it,
and `init-temp.*` verifies it.

## 9. Failure modes this skill exists to prevent

Each was met in production; each produced a wrong answer that *reconciled*:

- **The false green** — "done" with no artifact behind it.
- **The stale runtime** — verified code, invisible feature: the serving container ran pre-change binaries for hours.
- **The invented value** — a defaulted currency/rate/tenant-id where nothing resolved.
- **The corrupted write** — a round-trip that mangled encoding or doubled a file, committed unread.
- **The free renewal** — a paid pack whose entitlement flag was never written by the fulfilment path.
- **The double bill** — a pack billed by both a dedicated renewal line and the generic pack line.
- **The stale record** — a registry row asserting a state the code has left.

## 10. Versioning

Semantic versioning. Rules are added only when anchored to a new defect class with its evidence; existing rules
are corrected by appending a dated correction, never by silent rewrite — the history is the value.
