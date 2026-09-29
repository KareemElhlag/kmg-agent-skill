<!-- Created By: Karim-(KaReem Elhlag)-Abdelhady -->

# KMG Engineering Playbook

**Status:** living document — an audit trail of how complex systems are engineered, not a static spec.
**Scope:** governs every change — a one-line fix, a feature, the fallout of a review, or a documentation edit.
**Hard rule:** every mandatory rule must be anchored to a real defect class with real evidence. Where a practice is
not yet enforced, it is labeled **Known Gap** or **Recommendation** — never stated as a rule.

---

## §1 — The Task Execution Protocol (`P0 → P11`)

One protocol for every task. The only thing that varies per task is the class delta (§1.1). A per-task instruction
that contradicts this protocol is corrected **in the protocol first**, then in the task.

| # | Step | What must exist when it ends | The command, or the rule | Forbidden |
|---|---|---|---|---|
| `P0` | Intake, verbatim | The task in the requester's own words, unedited | Copy the request; do not paraphrase into scope | Paraphrasing before `P2` — scope drifts with the paraphrase |
| `P1` | Classify | One class (§1.1) and its hard trigger, written down | See §1.1 | Arguing the class *down* because the diff is small |
| `P2` | Blast radius | The files, controllers, permission codes, feature keys, DbContexts, and surfaces the change touches | Search the dependency; read the catalog; read the contract docs | Listing from memory; stopping at the first file the requester named |
| `P2.5` | **Environment & container sync** | The state of the **running** environment read: what is up, since when, built from what | `docker ps`; `docker inspect <service>` (CMD, mounts, image age). Restart/rebuild when catalogue, billing, or backend binaries the change touches are **newer than the container's start** | Declaring a feature visible because the tree is correct; treating a hot-reload-labelled container as a live one |
| `P3` | Read the state before writing | HEAD, working tree, touched lines — **read from the tree** | `git log --oneline -3`; `git status --porcelain`; a bounded read of the touched lines | Believing a claim (yours, a report's) about what the tree contains |
| `P4` | Baseline gate | The pre-change measurement, in a gate file under `temp/` | A `RUN <time>` header, the files under change, one `*_EXIT=` line per command | "It was green before", from memory |
| `P5` | Implement | The change, in layer order (§3) | Metadata → entity → handler → controller → UI | Frontend first, permission/feature metadata discovered later |
| `P6` | Write-shape check | Three numbers for every file written (§5) | Line count · non-ASCII count · diff stat | Reviewing a write by eye |
| `P7` | Run the stages | The class's stages in order, each with its artifact | A red stage stops the run; fix and re-run **from that stage** | Re-running from the top after a fix; recording `GATED`/`BLOCKED` as a pass |
| `P8` | Read the gate + live readback | Every exit code read per command; for served-payload changes, the **live endpoint readback** recorded | Read the gate file line by line; curl/readback the running service | Committing while an exit line does not exist yet; trusting a suite over the served response |
| `P9` | Commit | One commit per class, named paths only | `git add <explicit paths>`; the message states the class | `git add -A`; a push without explicit instruction |
| `P10` | Register | A row per claim, a run record per run, a §8-style log row for FEATURE/MAJOR | The evidence registry + `docs/test-runs/YYYY-MM-DD-<id>.md` | Registering a `GATED` as a pass; one blended percentage instead of separate denominators |
| `P11` | Close & disclose | What ran, what did not (prerequisite named), residue as residue | The run record's "Not run, and why" block | "Done" with no denominator; a residue described as already fixed |

### 1.1 Change classification

- **HOTFIX** — urgent production incident. Narrow, surgical, expedited review. Never bypasses security-critical gates.
- **PATCH** — small bounded fix with no contract, permission, feature-key, or schema change.
- **FEATURE** — new capability, endpoint, permission change, feature-key change, or schema change.
- **MAJOR** — new module/service, auth-layer change, or multi-tenancy strategy change.

**Hard trigger (do not argue):** any change touching a permission code, a feature key, or the DB schema is
**FEATURE minimum**, even when it looks small — small-looking entitlement gaps are the expensive ones.

### 1.2 Ordered execution (`S0 → S13`)

Most-diagnostic-per-second first: **static → unit → wiring → schema → persistence → authorization → UI → load →
whole tree**. Two laws make the order non-negotiable:

1. A stage may sit below another only if the stage above *cannot* observe what it detects.
2. **A red stage stops the run.** Fix it and re-run from that stage — never from the top, never "until green".
   A downstream green over an upstream red is not evidence.

Reference stage ladder (adapt per project): `S0` preflight/classify → `S1` static contracts (types, build) →
`S2` backend units → `S3` frontend units → `S4` assembly/reflection smoke → `S5` migration smoke (fresh DB) →
`S6` integration/persistence → `S7` RBAC/API probe per role → `S8` tenant isolation → `S9` UI policy audits →
`S10` E2E scenario → `S11` load (SLO, after correctness) → `S12` full regression → `S13` registration & release gate.

### 1.3 Flakes and stale expectations

A flake is a **finding**, not a retry. A test that failed then passed names the test, the run, the numbers, and one
of exactly two resolutions: *fix the cause*, or *raise the floor with a stated measurement*. Deleting a flaky test,
adding retries, or widening a timeout silently are prohibited — each converts a defect into silence. A deliberately
widened expectation is extended with a dated provenance comment, never loosened.

---

## §2 — Environment & Container Synchronization (`P2.5`, the anti-stale-runtime protocol)

**The lesson:** a fully verified source change — build green, suites green — remained invisible in the running
environment because the serving container had started **15 hours before the change**. The container was a
hot-reload-overlay SDK container whose command was `dotnet run` over a read-only bind mount of the source tree.
`dotnet watch` restarts on file change; **`dotnet run` rebuilds only at process start.** The bind mount delivered
new sources; nothing recompiled them. The endpoint faithfully served yesterday's catalogue for hours.

**The rules:**

1. **Read the runtime before claiming visibility.** `docker ps` (what is up, since when) and
   `docker inspect <service>` (CMD, entrypoint, mounts, working dir, image) for every container the change reaches.
2. **Container start time vs change time.** If the binaries/files the change touches are newer than the container's
   start, the change is *not served* until the container restarts or rebuilds.
3. **Match the restart to the mechanism.** `dotnet watch`/hot-reload reacts to edits; `dotnet run` needs a process
   restart; a baked image needs a rebuild. Declaring a restart "unnecessary" requires naming the mechanism that
   makes it unnecessary.
4. **Prefer the project's supported restart path** (e.g. a stack-up script that keeps build caches) over ad-hoc
   commands, and get explicit approval before restarting shared environments.
5. **Close against the served response.** After restart, poll the health probe, then perform the live readback
   (§6.2). The before/after readback pair is the delta that proves the runtime caught up.
6. **The frontend container counts too.** A static or built web container predating a payload change is the same
   defect on the client half.

---

## §3 — Clean Architecture & Domain-Driven Design

### 3.1 The mandatory layer order

```
Domain Entity → Application (Command/Query + Handler) → Infrastructure (Repository/DbContext) → API Controller → Frontend
```

| Layer | Holds | Forbidden |
|---|---|---|
| **Domain** | Entities with private setters, rich invariant methods, static factories returning `Result` | EF attributes, HTTP, DI, raw SQL |
| **Application** | Command/Query records + handlers; business orchestration; pipeline behaviors | DbContext-specific SQL, UI logic |
| **Infrastructure** | DbContexts, migrations, raw SQL (reporting readers), external providers | Business decisions |
| **API** | Thin controllers: route, send, `Ok(result)` / `BadRequest(result)` | Business logic, SQL, direct DbContext queries |
| **Frontend** | Components + permission/entitlement guard hooks | `any` types; rules enforced *only* client-side |

### 3.2 CQRS + MediatR patterns

- **Command/Query records** as immutable request types; handlers return `Result<T>` — **`Result<T>` over exceptions**
  for all business-validation outcomes. Exceptions remain appropriate for infrastructure/catastrophic failures and
  missing critical configuration (fail-loud at startup).
- **Pipeline behaviors** compose cross-cutting concerns in a fixed order: validation → permission → resilience/retry
  → transaction. The order is configured once and is the runtime contract.
- **Listing-query pattern (mandatory shape):** bounded take (`Math.Clamp`/`Math.Min`), `AsNoTracking()`,
  tenant-scoped predicate, deterministic ordering, hard cap, hand-written projection (`Select(x => new Dto(...))`) —
  no lazy `Include` sprawl. Lazy loading is disabled repo-wide; eager explicit includes are the mechanism.
- **Every journal-producing operation is a persisted document**: stable non-empty `DocumentId` + human-readable
  `DocumentNumber`; mutation routes address that identity (`/{id}/finalize`, `/{id}/post`); integration contracts
  carry `DocumentId`, `DocumentNumber`, and a per-attempt `CorrelationId`; finalization freezes the journal snapshot;
  a retry republishes that exact snapshot with a new correlation id — **financial values are never recalculated
  after approval**. Accrual and payment are separate documents and separate journals.
- **Idempotency belongs to the ledger, not the message.** "Already done?" is answered from the durable store (e.g.
  *does a credit note already reference the original invoice?*), never from a remembered message key — a crash
  between posting and reporting would otherwise desynchronize the two.

### 3.3 EF Core patterns

- **Owned money types are required:** an owned navigation backing a financial amount must be `.IsRequired()` —
  an all-default owned instance is treated as missing and silently writes NULL to the opposite column.
- **Client-assigned keys are declared `ValueGeneratedNever()`.** Under the convention default, EF's graph discovery
  reads a pre-set key as "pre-exists", marks the entity `Modified`, and issues an UPDATE against a row never inserted.
- **Column nullability is a table-level change:** tightening a column requires enumerating and dropping *every*
  referencing index at once (including ones created by raw SQL scripts, not the EF model), deleting orphans first,
  never scaffolding a `defaultValue` on a tightened column, and rehearsing on a clone before applying.
- **Migrations are code:** verified against a fresh database by a smoke test (`EnsureDeleted → MigrateAsync` →
  zero pending). No manual DDL on live databases. Generated SQL baselines executed at runtime by earlier migrations
  must stay **column-frozen** — naming a later column there breaks every from-scratch build.
- **Raw SQL lives in Infrastructure** (reporting readers), never in controllers.

### 3.4 Multi-tenancy & authorization

- Every query tenant-scoped; every cross-tenant read a deliberate, audited, aggregate-level act routed through the
  control plane — never a request parameter that becomes another tenant.
- **Permission ≠ entitlement.** RBAC (role → action) and ABAC (plan → feature key) are two independent, disjoint
  layers; adding one without the other fails silently. The refusal states are distinct (401 vs 403 vs 404) on purpose.
- **Fail-closed grant model:** new things start refused; an empty permission profile is removed, not defaulted;
  a feature key missing from the plan's entitlements is off, even if the permission exists.
- **A declared requirement must be satisfiable by its producer.** Before any rule can reject, trace the producing
  document end-to-end: can it supply the dimension on *every* path? When it cannot, make the source supply it.
- **Fail-closed on unresolved facts:** an unresolved value is refused or rendered as explicit-unknown — never a
  plausible default. An exchange rate is never defaulted to 1; a market is a (country, currency) *pair* or no
  request is issued; no market ⇒ no catalogue, not a catalogue in somebody else's money.

---

## §4 — The Paid-Pack Triple (financial entitlement integrity)

**The lesson (met twice in one product):** a paid integration pack shipped priced and entitled, but the fulfilment
path never wrote its account entitlement flag — a fulfilled purchase would have charged once at checkout and then
**renewed free forever**, invisibly, because every suite stayed green. Separately, the generic renewal pack line did
not exclude a pack that *also* had its own dedicated renewal line — a **double bill** waiting for the first buyer.

**The rule: a paid pack or add-on ships only with its triple. Any of the three missing = not on sale.**

| Component | Question it answers | Where it lives | Failure if missing |
|---|---|---|---|
| **Grant writer** | Who *writes* the entitlement when a purchase completes? | The fulfilment path (webhook completion) must set the account's entitlement flag / grant for **every** integration service — the grant list is one place, one entry per service | Checkout collects; renewals read the flag as false; **the service renews free** |
| **Renewal biller** | Who *bills* it on every cycle? | A dedicated renewal line priced from the stored per-plan price row, **plus** the pack excluded from any generic pack-billing line | **Double billing** (dedicated line + generic line) or **zero billing** (no line at all) |
| **Pinning tests** | What proves both survive unrelated edits? | A unit test asserting the grant mapping from the emitting side (pack → flag), and an integration test asserting the renewal output contains **no** generic pack line for the pack | The next pack repeats the defect; the regression ships unseen |

**Supporting invariants:**

- One named price constant per commercial agreement + a pricing test; duplicated numbers drift silently.
- The stored per-plan price row is authoritative; the catalogue constant is the default only.
- Disjoint feature keys across independently-priced services — overlap lets one purchase unlock the other.
- Withholding a feature from sale must never withdraw it from tenants already holding it: **grant side**
  (may it be newly sold?) and **resolution side** (what does this tenant have?) are two predicates, and every call
  site belongs to exactly one. A call site that cannot tell renewal from a first-time grant takes the resolution side.
- A purchase is priced on terms *effective now*; a hypothetical quote may price the past — the two are different
  routes and must not share a guard.
- Catalogue visibility is the flip side of the sellability gate: a pack withheld from sale until its surface exists
  is a **charging-for-nothing gate**; lifting the gate is the same commit that ships the surface, with its own test
  asserting the pack now appears in the purchasable catalogue payload.
- The client never maps pack keys to entitlement flags by hand; the flag travels **on the payload** (one fewer
  per-product table to forget to extend), and a contract test asserts every declared flag exists on the wire type.

---

## §5 — Write-Shape Guard & Fail-Closed Execution

### 5.1 The write-shape check (`P6`)

Every file write ends with three numbers, and the numbers are the check:

| Number | What it catches |
|---|---|
| **Line count** | an inflated or collapsed file |
| **Non-ASCII count** | a mangled encoding |
| **Diff stat** | a change larger than the change |

Forbidden write patterns (each produced one recorded corruption): reading-and-rewriting a file in one pipeline
(doubles encoding on non-ASCII); round-tripping a file through a line-array join/split (inflates line counts);
a mechanical rename performed with a case-insensitive replace (also rewrites argument positions). If a diff stat
shows 10× the intended change, **stop and rewrite cleanly** — a bloated or mangled file is reverted and rewritten
in full with the intended content, never hand-patched in place.

### 5.2 Fail-closed execution

- Anything new (permission, feature, module, pack) starts **refused** by default; auto-grant is the defect.
- A gate that throws on an unknown key is a gate with a hole — a resolver must distinguish *unrecognised* from
  *unpurchasable*, because the two need different answers.
- Navigation follows the same discipline: an entitled surface stays **visible** and is refused on click (or locked
  with a truthful state); hiding an entitled surface trains operators to believe the module does not exist. A scope
  fact (ownership, jurisdiction) resolves to *hidden*, not to a fake paywall — an unbuyable upgrade row is a lie.
- An untrusted/unresolved environment reading (a failed fetch, a missing flag) keeps the surface **closed**, never open.
- **Every defect fixed by a gate, not by attention:** after fixing, ask *which stage should have failed, and why
  didn't it?* — then answer with a new assertion at the lowest stage that can express it.

---

## §6 — Evidence, Registration & Live Readback

### 6.1 The evidence contract

Every claim gets a row recording: the surface, the **acceptance rule** (an observable condition — "page opened" is
not enough), the test type, the **source** (the test code, not the implementation), the exact command, the result
with numerator/denominator, a durable evidence path, and the next action. Status vocabulary:
`PASS · FAIL · SKIPPED · BLOCKED · GATED` — non-PASS states **never** count as passed and move no denominator.

The run record (`docs/test-runs/YYYY-MM-DD-<change-id>.md`) adds the longitudinal half: one table row per stage
(ran? result? counts? evidence path? **delta vs previous record**), a "Not run, and why" block, and four
**never-blended** denominators (surfaces touched vs certified · workflows fully certified · executed-suite pass
rate · load-check pass rate). Records are **appended, never rewritten** — the history is the value.

### 6.2 Live readback (mandatory for served payloads)

A change that alters what an endpoint serves — catalogue, pricing, billing, entitlements — is closed against a
**live readback**: the running service's own response, captured with the exact command and its decisive numbers.

- Readback **before and after** when the runtime mattered (the §2 protocol) — the before/after pair is the delta.
- The readback lives in `temp/` raw; the durable record carries the command + the numbers that decided the claim.
- A browser-level confirmation is a *separate, weaker* claim from the API readback: a UI test on a surface the API
  refuses still passes, because it renders the refusal. Authorization is proven from the API; the UI proves the
  control that reaches it.
- A flake-ridden or fixture-blocked stage is recorded `BLOCKED`/`GATED` with the missing prerequisite **named** —
  never quietly skipped, never counted.

### 6.3 Reviews are workflows too

A review (code, module, screen) runs its own loop and *ends* in the change workflow: **R1** read-only inventory →
**R2** classify every finding as `defect` / `gap` / `decision` → **R3** a defect enters `P0` as its own change →
**R4** re-run the smallest superset that localizes it, then add the guard that should have caught it →
**R5** register, then re-measure **keeping both numbers** (a fix without a before-number cannot show its size).
A review that produces no registered row produces nothing durable.

---

## §7 — Known-Gap Discipline

Honesty is part of the protocol. Every unenforced behavior is recorded as a **Known Gap** with its evidence path and
a next action: the failing SLO, the raw SQL in the wrong layer, the secret-scan that is documented but not CI-gated,
the surface unproven at its required tiers. A gap imported into a mandatory baseline is a lie; a baseline that hides
its gaps is worse. Re-baseline measurements per feature rather than quoting old numbers as current truth.
