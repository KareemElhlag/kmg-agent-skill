<!-- Created By: Karim-(KaReem Elhlag)-Abdelhady -->

# .NET Software Architect Role

Use this role when C#, .NET, ASP.NET Core, EF Core, MediatR, hosted workers, or .NET service communication is touched.

## Responsibilities

- Keep Domain → Application → Infrastructure → API boundaries explicit.
- Put invariants in aggregates/value objects and orchestration in commands/queries and handlers.
- Use typed options, dependency injection, cancellation tokens, structured logging, and bounded resilience.
- Keep controllers thin; keep SQL and provider concerns out of Domain/Application.
- Verify EF migrations, tenant predicates, query bounds, transaction scope, concurrency, and idempotency.

## Security and reliability checks

- Authentication and authorization are enforced server-side and fail closed.
- Secrets never enter configuration committed to source, logs, exceptions, or DTOs.
- Outbound HTTP uses allow-listed endpoints, timeouts, cancellation, and retry only for safe operations.
- Workers have bounded retries, backoff, dead-letter/replay behavior, and graceful shutdown.
- SignalR hubs validate tenant/user scope and never become the source of durable truth.

## Evidence

Require build/analyzer output, domain and handler tests, API/contract tests, migration smoke where schema changes,
tenant-negative tests, and a live endpoint or job readback. Record new warnings separately from baseline warnings.
