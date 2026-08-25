# ADR 003 — Persistence: Hive via `local_storage`

## Context

The brief requires local cache and favourites persistence; Thawani’s role description mentions Hive or SQLite. I need something fast to integrate and easy to fake in tests.

## Decision

I use **Hive CE** (`hive_ce` / `hive_ce_flutter`) behind `sdk/local_storage`. Repositories define **what** is stored; `local_storage` defines **how** boxes are opened and maps are read/written.

`LocalStorage` exposes keyed map helpers (`putMap` / `getMap` / `getAllMaps` / `delete` / `clear`). Box names and JSON shapes stay in `thawani` (list/search cache + `fetchedAt`, detail snapshots, favourites).

App boot calls `LocalStorage.init()` (Flutter documents dir). Tests use `initPath(...)`.

## Consequences

**Positive**

- Aligns with Thawani’s stated local-storage familiarity (Hive API).
- Good fit for keyed object cache without SQL migrations for this scope.
- Single abstraction allows swapping to SQLite later without rewriting UI.
- Hive CE is the maintained Hive lineage for current Flutter/Dart.

**Negative / trade-offs**

- Maps must stay tidy (callers store DTO/`toJson` maps, not ad-hoc types).
- Not a relational query engine — fine for this data shape.

**Rejected alternatives**

- **SQLite / drift** — stronger for complex queries; heavier for this assignment.
- **shared_preferences only** — weak for list caches and structured favourites.
- Writing Hive calls from widgets — violates layered architecture.
- Original unmaintained `hive` package — prefer Hive CE for ongoing support.
