<!-- Created By: Karim-(KaReem Elhlag)-Abdelhady -->

# Template — Task Run Record

> One file per execution of the ordered workflow. Path convention: `docs/test-runs/YYYY-MM-DD-<change-id>.md`.
> Append, never rewrite — the history is the value. Raw probe output stays in `temp/`; record commands + numbers.

# Run record — YYYY-MM-DD — <change-id>

**Change:** <one sentence>
**Class (P1):** HOTFIX / PATCH / FEATURE / MAJOR — trigger: <permission code / feature key / schema / none>
**Blast radius:** <modules · controllers · permissions · feature keys · DbContexts · frontend surfaces>
**Runtime sync (P2.5):** <containers read; start-time vs change-time; restart/rebuild action or "none needed — mechanism named">
**Previous record:** <path, or "first record for this change id">

## Stage table

| # | Stage | Ran? | Result | Passed / Failed / Skipped / Gated | Evidence path | Δ vs previous record |
|---|---|---|---|---|---|---|
| S0 | Preflight & classification | | | | | |
| S1 | Static contracts (build/types) | | | | | |
| S2 | Backend unit | | | | | |
| S3 | Frontend unit | | | | | |
| S4 | Assembly/reflection smoke | | | | | |
| S5 | Migration smoke (fresh DB) | | | | | |
| S6 | Integration / persistence | | | | | |
| S7 | RBAC / API probe | | | | | |
| S8 | Tenant isolation | | | | | |
| S9 | UI policy audits | | | | | |
| S10 | E2E scenario | | | | | |
| S11 | Load (after correctness) | | | | | |
| S12 | Full regression | | | | | |
| S13 | Registration & release gate | | | | | |

## Live readback (mandatory when a served payload changed)

| Endpoint | Command | Before | After | Decisive fields |
|---|---|---|---|---|
| | | | | |

## Not run, and why

| Stage | Status (BLOCKED/GATED/N/A) | Missing prerequisite / reason |
|---|---|---|
| | | |

## Findings raised by this run

| Finding | Kind (defect/gap/decision) | Stage that should have caught it | Where recorded |
|---|---|---|---|
| | | | |

## Denominators (never blended)

- Surfaces touched: n — certified: n
- Workflows fully certified: n / n
- Executed suites pass rate: n / n
- Load-check pass rate: n / n (or `N/A — no hot-path change`)

## Write-shape log (P6)

| File | Lines | Non-ASCII count | Diff stat | Clean? |
|---|---|---|---|---|
| | | | | |
