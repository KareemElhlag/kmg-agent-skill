<!-- Created By: Karim-(KaReem Elhlag)-Abdelhady -->

# Network, Service Communication, and Jobs v2

## HTTP and external providers

- Every outbound call has cancellation, finite connect/request timeouts, bounded retries, and a correlation id.
- Retry only transient failures and only when the operation is idempotent or has an idempotency key.
- Secrets come from the approved secret store and never enter logs, templates, or evidence.
- Validate tenant, authorization, endpoint allow-list, and contract before sending data externally.

## SignalR and messaging

- Realtime clients expose connecting, connected, reconnecting, failed, and stopped states.
- Handshake, keep-alive, proxy, and sticky-session assumptions are verified independently.
- Durable API state remains the source of truth after reconnect.
- Events are versioned and include tenant, aggregate, event id, and correlation id.
- Outbox publication is transactional; consumers are idempotent.

## Jobs

- Jobs have bounded retries, backoff, cancellation, visibility timeout, dead-letter behavior, and replay evidence.
- A failed job is observable and recoverable; swallowed exceptions are rejected.
- Cross-service workflows define compensation for each partially completed step.

## Diagnosis order

1. Database/schema and migration state.
2. Backend contract, authorization, logs, and dependency health.
3. Network transport, timeout, proxy, and messaging state.
4. Frontend request, payload, state machine, and retry/readback.

The conclusion names the failing axis and its proof. “Unexpected error” is never a root cause.
