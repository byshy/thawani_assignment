# ADR 002 — SDK package boundaries

## Context

A Thawani-shaped monorepo needs reusable building blocks without exploding into dozens of packages for a take-home.

## Decision

Six SDK packages:

| Package | Role |
|---------|------|
| `thawani` | Product/domain: repositories, data sources, feature logic |
| `thawani_models` | Entities, DTOs, mappers |
| `thawani_ui` | Theme + shared widgets (empty/error/offline/favourite) |
| `networking` | HTTP client, connectivity, remote failure mapping |
| `local_storage` | Persistence facade (Hive) |
| `needle` | get_it re-export for dependency injection |

Dependency direction: app → `thawani` / `thawani_ui` → models & infra; infra packages do not depend on product packages.

The split separates models, UI, Thawani domain, and infrastructure.

## Consequences

**Positive**

- Clear ownership for models, UI, domain, and infra.
- Forces DTO/model separation and UI isolation from Dio/Hive.
- A second Thawani app can depend on the same set.

**Negative / trade-offs**

- More packages than a minimal single-app layout.
- Temptation to put too much in `thawani_ui` — keep it presentational only.

**Rejected alternatives**

- One mega `sdk/core` package — weaker boundaries, harder ownership.
- Feature packages per screen — overkill for three screens.
- Putting all domain code in the app — shared SDK packages would not exist.
