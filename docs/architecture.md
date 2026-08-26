# Architecture

This project uses **Clean Architecture**: data, domain, and presentation are kept apart, with a repository between the UI and data sources, DTOs separate from UI models, typed errors, and use cases between presentation and repositories.

The repo is also split into `apps/` and `sdk/` packages so shared networking, storage, models, and UI can be reused by more than one app. The Explorer app uses flavors for Development and Production.

## Goals

1. Widgets never talk to HTTP clients or storage directly.
2. Presentation talks to use cases; use cases talk to repositories (network + cache). The UI does not know where data came from.
3. API **DTOs** stay separate from **UI/domain models**, with explicit mappers.
4. Failures are **typed**; raw `Exception.toString()` never reaches the user.
5. Package boundaries make a second app cheap to add without forking networking, models, or UI.
6. App environments are selectable via flavors (Development / Production) without committing secrets.

## Layer overview

```text
┌─────────────────────────────────────────────────────────────┐
│  Presentation  —  apps/explorer                             │
│  Screens · widgets · Provider · use cases · navigation      │
│  flavors                                                    │
└───────────────────────────┬─────────────────────────────────┘
                            │ use cases call repositories
┌───────────────────────────▼─────────────────────────────────┐
│  Domain contracts  —  sdk/thawani + thawani_models          │
│  Entities · repository interfaces · typed failures          │
└───────────────────────────┬─────────────────────────────────┘
                            │ implemented by
┌───────────────────────────▼─────────────────────────────────┐
│  Data  —  sdk/thawani (impl) + networking + local_storage   │
│  Remote data source · local data source · DTO mappers       │
│  Repository implementations (cache + network orchestration) │
└─────────────────────────────────────────────────────────────┘
```

### Presentation (`apps/explorer`)

- Feature folders for list, detail, favourites (and shell / tabs).
- **Use cases** for application operations (get character page, get character detail, toggle favourite, list favourites).
- **Provider** for feature state (list pagination, search debounce, detail, favourites).
- **get_it** (via `needle`) for dependency injection — use cases, repositories, and data sources are registered in `apps/explorer/lib/di/` and resolved with `sl<T>()`.
- Providers call use cases, not repositories or data sources.
- Composes widgets from `thawani_ui` where shared; keeps screen-specific UI local.
- Knows **nothing** about Dio, Hive, or JSON parsing.
- **Flavors:** Development and Production (`--flavor`, env-specific config such as base URL labels, app name suffix, bundle id). One `lib/main.dart`; flavor is resolved at runtime. No secrets in the repo.

### Domain contracts (`sdk/thawani` + `thawani_models`)

- Stable types the UI can depend on: `Character`, `Episode`, pagination info, favourites, failure types.
- Repository interfaces: `CharacterRepository`, `FavouritesRepository`, and `EpisodeRepository` (kept separate).
- No Flutter UI imports in pure domain types where practical; Flutter is allowed in the `thawani` package only where feature helpers need it.

### Data (implementations)

- **Remote:** Rick and Morty REST via `networking` (`ApiClient` with app-supplied `baseUrl`, typed failures, real reachability checks). Hand-written DTOs — no GraphQL, no API code generation.
- **Local:** list/detail cache + favourites via `local_storage` (Hive CE facade).
- **Mappers:** bidirectional DTO ↔ entity in `thawani_models` (`toEntity` / `toDto`); repositories consume them.
- **Repository:** chooses network vs cache, writes cache on success, exposes a single API to use cases.

## Request flow (list)

```text
User scrolls / searches
        │
        ▼
ListProvider (debounce, page guard, cancel stale)
        │
        ▼
sl<GetCharactersPageUseCase>()  — or injected at Provider construction
        │
        ▼
GetCharactersPageUseCase(query, page)
        │
        ▼
CharacterRepository.getPage(query, page)
        │
        ├──► online?  RemoteDataSource ──► DTO ──► mapper ──► models
        │                 │
        │                 └── write cache (+ fetchedAt)
        │
        └──► offline / failure with cache?
                    LocalDataSource ──► models + CacheMeta(offline, fetchedAt)
        │
        ▼
UI states: loading | data | empty(query) | error(retry)
         + optional offline banner
```

## Detail & favourites

- **Detail:** use case → repository returns cached character when offline; favourite toggle goes through the same favourites path both list and detail observe.
- **Favourites:** fully local; removing an item notifies listeners so the list star state updates without a special cross-screen hack.

## Flavors

| Flavor | Purpose |
|--------|---------|
| `dev` / Development | Local development; distinct app id / name suffix |
| `prod` / Production | Release-shaped build |

All flavors can point at the same public Rick and Morty API for this assignment; the important part is the **environment wiring** (one `main.dart`, Android product flavors, iOS schemes, config object). No API keys or secrets are committed.

See [decisions/007-flavors.md](decisions/007-flavors.md).

## Dependency injection

Registration lives in `apps/explorer/lib/di/`. Boot order:

```text
initSL()
  → local_storage (LocalStorage.init)
  → networking (ApiClient + ConnectivityChecker)
  → data sources
  → repositories
  → use cases
  → runApp (Provider tree)
```

Use cases resolve repositories with `sl<CharacterRepository>()`. Providers resolve use cases with `sl<…UseCase>()`. Widgets do not call `sl` directly — they go through Provider.

See [decisions/008-dependency-injection.md](decisions/008-dependency-injection.md).

## Async correctness (brief requirements)

| Concern | Planned approach |
|---------|------------------|
| Debounced search (300–500 ms) | Timer in Provider/controller; reset on each keystroke; ignore responses whose query ≠ current query |
| No duplicate page fetches | In-flight flag / page lock; ignore scroll triggers while loading |
| Last page | Use API `info.next == null` (or `page >= pages`) |
| Dispose | Dispose TextEditingController, timers, connectivity subscription in Provider `dispose` |
| Context after await | Prefer listening via Provider; avoid `setState` after async; check `mounted` only where StatefulWidget is unavoidable |

## Error model

Map transport and parse failures into domain failures, for example:

- `NetworkFailure` — no connectivity / timeout / socket
- `ServerFailure` — unexpected HTTP (except search `404` → empty)
- `ParseFailure` — malformed JSON
- `CancelledFailure` — disposed / stale request
- `NoCachedDataFailure` — offline with no usable cache (`thawani`)
- `StorageFailure` — local read/write type issues (`local_storage`)

Presentation maps failures to user copy + retry. Never show stack traces.

## What is deliberately **not** included

- A separate pure-Dart “domain-only” package with zero Flutter — domain lives in `thawani` / `thawani_models` without that extra package split.
- GraphQL clients.
- API / model code generation — REST + hand-written DTOs and mappers.
- Analytics / Crashlytics in this assignment.

## How this maps to Thawani expectations

| Concern | How this addresses it |
|---------|------------------------|
| Clean Architecture / SoC | Layers + use cases + repository boundary |
| Testable, maintainable code | Fakes registered on `sl`; Providers stay free of Dio/Hive |
| Reusable mobile SDK | `sdk/` packages shared across future apps |
| Multiple environments | Flutter flavors: Development, Production |
| Secure, clear error handling | No secrets in repo; typed errors; offline without leaking internals |
| Interview walkthrough | Clear path: tap → Provider → use case → repository → source → UI |

## Related docs

- [monorepo.md](monorepo.md) — package ownership
- [offline-and-caching.md](offline-and-caching.md) — cache policy
- [testing-strategy.md](testing-strategy.md)
- [decisions/](decisions/) — ADRs
