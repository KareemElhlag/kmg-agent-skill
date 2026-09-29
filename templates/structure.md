<!-- Created By: Karim-(KaReem Elhlag)-Abdelhady -->

# Template — Project Structure & Blast Radius

> Copy per task into the project's run-record directory. Fill only what applies; strike nothing silently.
> Privacy rule: identify layers by *role and path pattern*, never by tenant data or secrets.

## 1. Layer map (as read, not as believed)

| Layer | Root path | What it holds here | Boundary violations found |
|---|---|---|---|
| Domain | | Entities, invariants, factories | |
| Application | | Commands/Queries, handlers, behaviors | |
| Infrastructure | | DbContexts, migrations, providers | |
| API | | Controllers, middleware | |
| Frontend | | Pages/components, guard hooks | |
| Shared kernel | | Cross-cutting abstractions | |

## 2. Change blast radius (P2 output)

| Field | Value |
|---|---|
| Change class (P1) | HOTFIX / PATCH / FEATURE / MAJOR + trigger |
| Files under change | |
| Controllers/endpoints touched | |
| Permission codes touched | |
| Feature keys touched | |
| DbContexts / migrations | |
| Frontend surfaces | |
| Catalogue/pricing/billing payloads changed? | yes/no — if yes, live readback required (§6.2) |

## 3. Runtime map (P2.5 output)

| Container/service | Start time vs change time | Command mechanism (watch/run/baked) | Mounts | Sync action needed |
|---|---|---|---|---|
| | | | | |

## 4. Dependency notes

- Metadata chain resolved first? (permission → feature → entitlement → UI)
- Seeders/catalogs affected:
- Contract/wire types affected:
