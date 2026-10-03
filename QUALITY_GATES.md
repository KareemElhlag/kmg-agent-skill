<!-- Created By: Karim-(KaReem Elhlag)-Abdelhady -->

# Quality Gates v2

This document defines acceptance gates for a change. It is an engineering contract, not a promise of defect-free
software. Thresholds are defaults; a stricter project policy wins. Any exception is recorded with evidence, owner,
expiry stage, and risk.

## Feature creation workflow

1. Preserve the request verbatim and classify it.
2. Map domain, application, infrastructure, API, UI, database, permissions, events, jobs, and runtime.
3. Run a pre-change baseline before editing.
4. Choose one owner for each state and document contracts and invariants.
5. Implement in dependency order and keep rules out of controllers and UI.
6. Run the first failing verification stage until it is repaired.
7. Verify the served endpoint or workflow with the same tenant and authorization context.
8. Record findings, measurements, decision, and unrun prerequisites.

## Mandatory acceptance gates

| Gate | Reject when | Minimum evidence |
|---|---|---|
| Contract | DTO, event, or persistence shape is ambiguous or mismatched | Typed contract test or named blocker |
| Architecture | Business rules live only in UI/controller or boundaries are bypassed | Layer map and focused test |
| Tenant/security | A query, command, file, or event can cross tenant scope | Authorized positive and negative test |
| Integrity | Money, stock, entitlement, or transition can duplicate or disappear | Invariant and idempotency evidence |
| Error handling | Failure has no actionable recovery path | Error-state and retry/readback test |
| Maintainability | New duplicate owner, primitive, or unexplained exception appears | Reuse search and review decision |
| Performance | No baseline/delta exists for a touched hot path | Performance record |
| Runtime | Source is green but served revision is stale or unverified | Runtime readback |

## Complexity and maintenance defaults

- Cyclomatic complexity: **≤10 preferred**, **11–15 review required**, **>15 reject unless decomposed or excepted**.
- Nesting depth **≤3**, parameters **≤5**, and one business responsibility per function.
- A file above **500 lines** or a function above **80 lines** requires a split review.
- No new `any`, silent catch, unbounded query, or network call without timeout and cancellation.
- New static warnings are rejected; existing warnings remain residue with count and owner.

## Decision vocabulary

`ACCEPTED` means required gates pass. `ACCEPTED WITH FOLLOW-UP` means no required gate is open and quality residue has
an owner and expiry. `REJECTED` means a required gate fails. `BLOCKED` means a named external prerequisite prevented a
gate from running and never counts as pass.
