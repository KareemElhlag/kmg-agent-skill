<!-- Created By: Karim-(KaReem Elhlag)-Abdelhady -->

# Template — Business Rules & Commercial Logic

> Copy per feature/pack/change. Fill only what applies.
> Privacy rule: document *rules and invariants*, never real customer data, real prices of a specific tenant
> contract, or credential material.

## 1. Capability definition

| Field | Value |
|---|---|
| Capability name (en/ar) | |
| Feature key | |
| Module | |
| Sold as (plan tier / pack / add-on) | |
| Catalogue category | |
| Price source (single named constant / stored per-plan row) | |

## 2. Paid-Pack Triple (mandatory for anything purchasable — PLAYBOOK §4)

| Component | Owner (file/service) | Test that pins it | Status |
|---|---|---|---|
| Grant writer (who sets the entitlement on purchase completion) | | | |
| Renewal biller (dedicated renewal line + price source; excluded from generic pack billing) | | | |
| Pinning tests (grant mapping test + no-double-bill test) | | | |

> Any of the three blank ⇒ the pack is **not on sale**. Record it `GATED` with the missing component named.

## 3. Entitlement predicates in play

| Predicate | Semantic | Call sites here |
|---|---|---|
| Grant side ("may this be newly sold/granted?") | Block-aware | |
| Resolution side ("what does this tenant have?") | Block-blind | |

- Call sites that cannot tell renewal from first-time grant resolved to: *(resolution side / justification)*

## 4. Fail-closed rules this feature obeys

- Unresolved market/currency/rate/tenant → *(refused / explicit-unknown — where)*
- Sales block visibility (grant vs resolution) verified:
- Navigation decision for an entitled-but-unpermitted role: *(visible-locked / hidden — and why)*

## 5. Business invariants asserted by tests

| Invariant | Test (source, not implementation) | Result |
|---|---|---|
| | | |

## 6. Open commercial gaps

| Gap | Kind (defect/gap/decision) | Next action |
|---|---|---|
| | | |
