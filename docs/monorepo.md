# Monorepo structure

## Why apps + sdk

```text
apps/     → product binaries (what users install)
sdk/      → shared libraries (what multiple apps reuse)
```

This assignment ships one app (`explorer`). The `apps/` + `sdk/` layout keeps networking, storage, models, and UI reusable so a second Flutter app can depend on the same packages instead of copying Explorer’s code.

## Target tree

```text
thawani_assignment/
├── apps/
│   └── explorer/                 # Rick & Morty Explorer (assignment)
├── sdk/
│   ├── thawani/                  # Product/domain package
│   ├── thawani_models/           # Models, DTOs, mappers
│   ├── thawani_ui/               # Design system & shared widgets
│   ├── networking/               # HTTP + connectivity + remote failures
│   ├── local_storage/            # Persistence facade (Hive)
│   └── needle/                   # get_it re-export for DI
├── docs/
└── README.md
```

Leaf SDK packages exist (`needle`, `thawani_models`, `networking`, `local_storage`). Still planned: `thawani_ui`, `thawani`, and `apps/explorer`.

## Package responsibilities

### `apps/explorer`

| Owns | Does not own |
|------|----------------|
| `main.dart`, MaterialApp, routes/tabs | Dio configuration details |
| Feature screens, Providers, use cases | JSON DTO definitions |
| App-level DI (`get_it` via `needle`) / Provider wiring / flavors | Hive box schemas (lives in storage / thawani data) |
| Platform projects (Android / iOS) | Shared button/theme primitives (prefer `thawani_ui`) |

The app is the **composition root**: `initSL()` registers dependencies, hosts navigation, owns use cases, renders screens.

**DI layout** (`apps/explorer/lib/di/`):

```text
di/
  injection_container.dart   # initSL(); sl lives in needle
  external_injector.dart     # ApiClient(baseUrl from app), ConnectivityChecker, LocalStorage.init
  datasource_injector.dart   # remote + local data sources
  repository_injector.dart   # CharacterRepository, FavouritesRepository
  use_case_injector.dart     # feature use cases
  provider_injector.dart     # ChangeNotifiers / Providers (if registered in sl)
```

### `sdk/thawani`

Brand / product domain package — for this assignment it hosts Explorer domain behaviour that would otherwise be copy-pasted into every app:

- Repository interfaces and implementations for characters (and episodes if bonus is implemented).
- Remote/local data sources specific to this product API usage.
- Feature-level helpers that are not generic infrastructure.

Use cases stay in `apps/explorer`, not in this package.

In a multi-app Thawani setup, this package would grow with wallets, transfers, bill pay, and similar features. Explorer is the first consumer that proves the slot.

### `sdk/thawani_models`

- Domain entities used by UI and domain (`Character`, pagination `PageInfo`, cache metadata).
- API DTOs (`CharacterDto`, response wrappers) with `fromJson` / `toJson` (for cache) and **explicit** `toEntity()` mappers.
- Shared enums / value types (status, gender).
- Episode types deferred until Path 1 bonus work (see [episode-fanout.md](episode-fanout.md)).

**Rule:** widgets import models, never raw response maps.

### `sdk/thawani_ui`

- Theme tokens (colors, typography, spacing) suitable for a clean, readable assignment UI — not visual polish for its own sake.
- Reusable widgets: list row shell, empty state, error state with retry, offline banner, favourite icon button, loading indicators.
- Debounce helper may live here or in `thawani` utilities; prefer one place and document it.

Keeps Explorer screens thin and gives a future Thawani app the same empty/error/offline language.

### `sdk/networking`

- Dio-based `ApiClient` — `baseUrl` is required and supplied by the app (flavors / DI), not hardcoded in this package.
- Real internet reachability via `ConnectivityChecker` (`internet_connection_checker_plus`), not Wi‑Fi/cellular attachment alone.
- Mapping of `DioException` → typed remote failures (`NetworkFailure`, `ServerFailure`, `ParseFailure`, `CancelledFailure`).
- Small JSON helpers (`requireJsonMap` / `requireJsonList`).

No feature-specific character endpoints here — those stay in `thawani`.

### `sdk/local_storage`

- Hive CE–backed `LocalStorage` facade: `init()` / `initPath()`, map put/get/delete/clear helpers.
- Callers own box names and value shapes (list/detail cache, favourites live in `thawani`).
- `StorageFailure` for unexpected value types.
- No cache policy — repositories decide what to store and when.

```dart
import 'package:local_storage/local_storage.dart';

await storage.putMap('favourites', '1', json);
final cached = await storage.getMap('favourites', '1');
```

### `sdk/needle`

Thin wrapper around **get_it**. Re-exports `GetIt` and exposes `sl` (`GetIt.instance`) so app and SDK packages share one import:

```dart
import 'package:needle/needle.dart';

final foo = sl<Foo>();
```

No registration logic lives here — `initSL()` stays in `apps/explorer/lib/di/`.

## Dependency rules

Allowed direction: **apps → sdk**, and **higher-level sdk → lower-level sdk**. Never the reverse.

```text
apps/explorer
    ├── thawani
    ├── thawani_ui
    ├── thawani_models
    ├── needle
    ├── networking          (only if wiring needs types; prefer via thawani)
    └── local_storage       (same)

thawani
    ├── thawani_models
    ├── networking
    ├── local_storage
    └── needle              (optional; for sl in tests or shared helpers)

needle              → get_it only

thawani_ui
    └── thawani_models      (optional; only if widgets need entity types)

networking          → (Flutter/Dart + Dio + internet_connection_checker_plus)
local_storage       → (Flutter/Dart + hive_ce / hive_ce_flutter)
thawani_models      → (Dart; prefer pure Dart)
```

**Hard rules:**

1. `networking` and `local_storage` must not depend on `thawani` or `explorer`.
2. `thawani_models` must not depend on UI or networking.
3. Feature screens must not import Dio or Hive packages directly.

## Path dependencies

Apps and packages will use path dependencies, e.g.:

```yaml
# apps/explorer/pubspec.yaml (illustrative)
dependencies:
  thawani:
    path: ../../sdk/thawani
  thawani_ui:
    path: ../../sdk/thawani_ui
  thawani_models:
    path: ../../sdk/thawani_models
```

Melos (or similar) is optional for this assignment size; path deps are enough. A workspace tool can be added later if package count grows.

## What a second app would look like

```text
apps/
  explorer/          # assignment
  wallet/            # hypothetical Thawani app — depends on same sdk/*
```

`wallet` would reuse `networking`, `local_storage`, `thawani_models`, `thawani_ui`, and product APIs from `thawani`. Only wallet-specific screens and Providers would be new.

## Naming

| Name | Rationale |
|------|-----------|
| `explorer` | Matches the brief’s product name (“Explorer”) |
| `thawani` | Thawani product/domain package |
| `thawani_models` / `thawani_ui` | Clear Thawani ownership; avoid generic pub.dev name clashes |
| `networking` / `local_storage` / `needle` | Infrastructure; reusable and boring on purpose |

## Related ADRs

- [000-monorepo-layout.md](decisions/000-monorepo-layout.md)
- [002-package-boundaries.md](decisions/002-package-boundaries.md)
- [003-persistence.md](decisions/003-persistence.md)
- [008-dependency-injection.md](decisions/008-dependency-injection.md)
