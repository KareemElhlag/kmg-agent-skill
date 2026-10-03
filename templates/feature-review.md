<!-- Created By: Karim-(KaReem Elhlag)-Abdelhady -->

# Feature Review: <change-id>

**Date:** YYYY-MM-DD  
**Classification:** PATCH / FEATURE / MAJOR  
**Owner:** <name>  
**Decision:** ACCEPTED / ACCEPTED WITH FOLLOW-UP / REJECTED / BLOCKED

## Workflow contract

| Contract | Evidence |
|---|---|
| Entry and permission | route, permission, entitlement |
| Read | query, tenant scope, loading/empty/error/retry |
| Write | command, validation, authorization, conflict handling |
| Persistence | migration/schema and readback |
| Integration | event/API/job contract and idempotency |
| UX | RTL, keyboard, mobile, pending/success/error |

## Findings

| Severity | Type | Finding | Evidence | Owner/expiry |
|---|---|---|---|---|
| Required / Quality / Advisory | defect / gap / decision / residue | | | |

## Measurements

| Surface | Baseline | Changed | Delta | Budget | Status |
|---|---:|---:|---:|---:|---|
| API P95 | | | | | |
| Query count | | | | | |
| Errors/timeouts | | | | | |
| Job duration/retries | | | | | |

## Tests and evidence

| Stage | Command | Result | Evidence path |
|---|---|---|---|
| Static/build | | PASS/FAIL/BLOCKED | |
| Unit | | PASS/FAIL/BLOCKED | |
| Contract/integration | | PASS/FAIL/BLOCKED | |
| Authorization/tenant | | PASS/FAIL/BLOCKED | |
| UI/E2E | | PASS/FAIL/BLOCKED | |
| Runtime readback | | PASS/FAIL/BLOCKED | |

## Residue

List what did not run, why, and the next action. A skipped or blocked stage never counts as passed.
