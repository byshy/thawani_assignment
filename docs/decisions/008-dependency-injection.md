# ADR 008 — Dependency injection with get_it

## Context

Repositories, data sources, use cases, and Providers need to be wired without constructing dependencies inside widgets. Provider handles **state**; something else must handle **construction and lookup**.

## Decision

Use **get_it** for dependency injection, exposed through a thin `sdk/needle` package that re-exports `get_it` (same pattern as the existing Thawani mobile codebase).

- `sdk/needle` re-exports get_it and exposes `final GetIt sl = GetIt.instance`.
- `apps/explorer/lib/di/` owns registration:
  - `injection_container.dart` — `initSL()`
  - Split injectors: external (HTTP, storage), datasource, repository, use case, provider
- `lib/main.dart` calls `await initSL()` before `runApp`. Flavor is resolved from `--dart-define=flavor=` (preferred) or `--flavor`.
- Use cases resolve repositories via `sl<CharacterRepository>()`.
- Providers resolve use cases via `sl<GetCharactersPageUseCase>()` (or receive them in the constructor at registration time).
- SDK packages define types and implementations; they do not register themselves — the app composition root does.

## Consequences

**Positive**

- Same DI ergonomics as production Thawani mobile work.
- Easy to swap fakes in tests by registering mocks on `sl` before tests run.
- Clear boot order: storage → networking → data sources → repositories → use cases → providers.

**Negative / trade-offs**

- Service locator pattern — acceptable here; kept at the app boundary, not inside widgets’ `build` methods.
- One extra SDK package (`needle`) for a single re-export — keeps import style consistent across packages.

**Rejected alternatives**

- Constructor injection only through Provider — awkward for deep graphs and test setup at this scale.
- Riverpod as DI — not aligned with Provider + get_it stack for this submission.
- Registering inside `sdk/thawani` — hides the composition root; app should own wiring.
