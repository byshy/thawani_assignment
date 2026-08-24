# ADR 003 — Persistence: Hive via `local_storage`


## Context

The brief requires local cache and favourites persistence; Thawani’s role description mentions Hive or SQLite. I need something fast to integrate and easy to fake in tests.

## Decision

I use **Hive** behind `sdk/local_storage`. Repositories define **what** is stored; `local_storage` defines **how** boxes are opened and read/written.

Store at minimum:

- List/search cache entries + `fetchedAt`
- Character detail snapshots + `fetchedAt`
- Favourites collection

## Consequences

**Positive**

- Aligns with Thawani’s stated local-storage familiarity.
- Good fit for keyed object cache without SQL migrations for this scope.
- Single abstraction allows swapping to SQLite later without rewriting UI.

**Negative / trade-offs**

- Hive adapters / JSON encoding must stay tidy.
- Not a relational query engine — fine for this data shape.

**Rejected alternatives**

- **SQLite / drift** — stronger for complex queries; heavier for this assignment.
- **shared_preferences only** — weak for list caches and structured favourites.
- Writing Hive calls from widgets — violates layered architecture.
