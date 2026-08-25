# ADR 004 — Networking package (Dio)

## Context

I need REST access to Rick and Morty, connectivity awareness, and typed mapping of transport failures. Thawani’s role description emphasises REST integration.

## Decision

I implement `sdk/networking` with **Dio** as the HTTP client (`ApiClient`), plus a connectivity checker used by repositories for offline decisions.

Reachability uses **`internet_connection_checker_plus`** (real internet access), not `connectivity_plus` (which only reports interface attachment).

`ApiClient` requires a `baseUrl` from the app (flavors / DI). Shared `requireJsonMap` / `requireJsonList` helpers live here so remote data sources do not reimplement Dio payload casting.

Character-specific endpoints live in `thawani` remote data sources that **use** networking — not inside the networking package itself.

## Consequences

**Positive**

- Interceptors, cancel tokens (search/episode cancel), and testable adapters are straightforward.
- Typed remote failures / status handling stay in one place.
- Cancel tokens support brief requirements around disposed screens and bonus episode cancellation.
- Offline decisions reflect actual reachability, not just Wi‑Fi/cellular up.
- Base URL stays environment-owned in the app.

**Negative / trade-offs**

- Dio is an extra dependency vs `package:http` — justified by cancellation and testing adapters.
- Reachability probes hit remote endpoints (library default) — acceptable for this assignment.

**Rejected alternatives**

- Raw `http` only — workable but weaker cancel/interceptor story for this brief.
- `connectivity_plus` alone — does not verify real internet access.
- Hardcoding the API base URL in `networking` — couples infra to one product host; flavors own config.
- GraphQL — not used; API is REST.
- Code-generated API clients — not used; hand-written DTOs and mappers.
