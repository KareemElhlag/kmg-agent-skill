# Senior Monitor Certification Rubric

## Evidence bundle

- Original request and accepted scope.
- Classification, architecture map, and changed-file list.
- Focused and contract test results tied to the current tree.
- Runtime/container readback where visibility matters.
- Security, tenant, money/inventory, network, and job checks when relevant.
- Rollback path and migration safety.

## Gates

| Area | Pass condition |
|---|---|
| Scope | Every changed path maps to an accepted requirement. |
| Architecture | One clear owner and source of truth; no accidental coupling. |
| Correctness | Critical invariants have executable tests or an explicit blocker. |
| Security | Authorization, tenant boundaries, secrets, and validation fail closed. |
| Reliability | Timeouts, retries, idempotency, and jobs are defined. |
| Performance | Baseline and delta exist, or the gap is documented. |
| Runtime | The serving artifact is proven to contain the change. |
| UX | Loading, empty, error, permission, RTL, mobile, and destructive states are covered when relevant. |
| Operations | Correlation, metrics, rollback, and residue ownership are present. |

## Decisions

- `CERTIFIED`: applicable gates pass with no material residue.
- `CERTIFIED_WITH_RESIDUE`: safe to proceed with an owned, dated follow-up.
- `REWORK_REQUIRED`: plan or implementation needs correction.
- `BLOCKED`: required evidence or environment is unavailable.
