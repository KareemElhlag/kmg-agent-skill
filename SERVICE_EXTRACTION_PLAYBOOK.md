# Service Extraction Playbook

Reusable procedure for moving a bounded capability from a crowded service into a clean microservice without creating
dual ownership, data loss, or an untestable cutover. This playbook was validated while extracting hosted Ecommerce
from Trade.

## Stage 0: Classify and freeze the boundary

Record the request, blast radius, current owner, target owner, consumers, permissions, database tables, routes,
events, jobs, and runtime dependencies. Mark the change `MAJOR` when it crosses service or database ownership.
Do not move code before the ownership table is approved.

## Stage 1: Inventory the source

Search first and read bounded windows. Produce a map of:

- Domain entities and invariants.
- Application commands, queries, DTOs, and permissions.
- Infrastructure persistence, migrations, outbox, jobs, and external adapters.
- API routes and frontend callers.
- Compose, gateway, secrets, health, and observability wiring.

Inline schema creation/healing in controllers is migration debt; move it to migrations before write cutover.

## Stage 2: Create a service shell

Create Domain, Application, Infrastructure, API, Contracts, and Tests projects. Register the service in the solution,
compose, gateway, health checks, logging, authentication, tenant middleware, and OpenAPI. The shell must build before
any source behavior is moved.

## Stage 3: Publish contracts and compatibility adapter

Create versioned contracts independent from source domain classes. Add a typed gateway/adapter with bounded timeout,
correlation propagation, authorization propagation, tenant validation, and explicit failure behavior. Keep existing
source routes and writes unchanged.

## Stage 4: Build an owned read model

Create target-owned tables with no cross-service foreign keys. Store immutable snapshots where historical meaning must
not change. Add unique tenant-scoped keys, indexes, migration scripts, and an import checkpoint. Never use
`EnsureCreated` or controller SQL for production schema management.

## Stage 5: Import and shadow-compare

Import in idempotent batches. Persist a checkpoint and source version/timestamp. Retry only transient failures.
Compare old and new reads by tenant, record mismatches, and stop on invariant violations. Do not cut over while the
comparison has unresolved critical mismatches.

## Stage 6: Move writes by bounded workflow

Move one workflow at a time, each with its own command contract, authorization, transaction boundary, outbox event,
idempotency key, and rollback. For ERP flows, move order/payment/shipment writes only after inventory reservation and
financial ownership contracts are proven.

## Stage 7: Cut over with a tenant flag

Switch gateway/frontend traffic per tenant. Keep source compatibility routes for rollback. Verify runtime artifact
timestamps, traces, error rate, latency, and readback after each canary. Never claim visibility from a source build alone.

## Stage 8: Decommission only after evidence

Prove zero source traffic, drained messages, completed retention/export, and an approved rollback window. Then remove
compatibility code and old tables in a separate change. Destructive cleanup is never part of the first cutover.

## Required evidence and stop conditions

- Build/test results tied to the current tree.
- Tenant isolation, authorization, concurrency, idempotency, and rollback tests.
- Import counts, checkpoint, mismatch counts, and unresolved residue.
- Runtime/container readback and dependency health.
- Senior Monitor decision: `CERTIFIED` or `CERTIFIED_WITH_RESIDUE`.

Stop immediately on an unknown owner, missing tenant scope, dual write source, unverified money/inventory invariant,
missing rollback, or unavailable runtime evidence. Record the blocker; do not invent a default.
