# ADR 004 — Networking package (Dio)

## Context

I need REST access to Rick and Morty, connectivity awareness, and typed mapping of transport failures. Thawani’s role description emphasises REST integration.

## Decision

I implement `sdk/networking` with **Dio** as the HTTP client, plus a connectivity abstraction used by repositories for offline decisions.

Character-specific endpoints live in `thawani` remote data sources that **use** networking — not inside the networking package itself.

## Consequences

**Positive**

- Interceptors, cancel tokens (search/episode cancel), and testable adapters are straightforward.
- Typed remote failures / status handling stay in one place.
- Cancel tokens support brief requirements around disposed screens and bonus episode cancellation.

**Negative / trade-offs**

- Dio is an extra dependency vs `package:http` — justified by cancellation and testing adapters.

**Rejected alternatives**

- Raw `http` only — workable but weaker cancel/interceptor story for this brief.
- GraphQL — not used; API is REST.
- Code-generated API clients — not used; hand-written DTOs and mappers.
