<!-- Created By: Karim-(KaReem Elhlag)-Abdelhady -->

# Performance Measurement v2

Performance claims require a baseline, a changed run, the same fixture shape, and a delta. Never blend UI, API,
database, job, and load denominators.

| Surface | Required measurements |
|---|---|
| HTTP/API | P50, P95, P99 latency, status/error rate, timeout rate, payload size |
| Database | query count, slowest query, duration, rows read, plan/index evidence when relevant |
| Frontend | route load, mutation duration, retry count, visible loading/error/empty state |
| SignalR | connect, handshake, reconnect, keep-alive timeout, dropped-message evidence |
| Messaging | publish/consume latency, retries, dead letters, duplicate handling |
| Jobs | duration, success/failure, retries, backlog age, idempotency result |

## Default budgets

- No new unbounded query or unbounded message payload.
- Investigate an API hot-path P95 regression above **10%**; reject above **20%** without an approved exception.
- Investigate query-count regression above **20%** and reject N+1 patterns.
- Error and timeout rate must not increase in the focused workflow.
- A job must expose bounded retries, cancellation, and terminal failure handling.

When a real SLO exists, it overrides these defaults. Raw traces and payloads stay in ignored `temp/`; durable records
contain commands, numbers, deltas, and evidence paths only.
