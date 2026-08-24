# ADR 005 — Repository and use cases

## Context

The brief mandates a repository between the UI and data sources (network + cache). Clean Architecture for this project also uses **use cases** so presentation does not call repositories directly.

## Decision

- Expose two repository interfaces from `sdk/thawani`:
  - `CharacterRepository` — list/search/detail and cache-aware character reads
  - `FavouritesRepository` — persist and observe favourites
- Repository implementations live in `sdk/thawani` (remote + local sources and mapping for characters; local storage only for favourites).
- Use case classes live in `apps/explorer` (per feature), e.g. get page, get detail, toggle favourite, list favourites.
- Providers depend on use cases (resolved via `sl<T>()` or injected at registration), not on repositories or data sources.
- Search `404` → empty page result is handled in the repository/remote layer so UI and use cases can treat it as an empty result.

## Consequences

**Positive**

- Matches the brief’s “UI should not know where data came from”.
- Clear interview trace: tap → Provider → use case → repository → source.
- Repositories stay reusable across apps; each app owns its use-case orchestration.
- Favourites stay fully offline-testable without mocking the character network path.

**Negative / trade-offs**

- More types than a single combined repository.
- Providers still own presentation policy (debounce, pagination guards) — that stays out of use cases and out of widgets’ `build` methods.

**Rejected alternatives**

- Widgets calling data sources — disallowed by brief.
- Providers calling repositories directly — skips the use-case layer used in this architecture.
- Use cases inside `sdk/thawani` — couples app-specific orchestration into the shared SDK.
- One combined repository for characters and favourites — weaker separation of network/cache vs pure local favourites.
