# Thawani Flutter Assignment — Explorer

Thawani Flutter take-home: the **Explorer** app — a Rick and Morty character browser with search, pagination, favourites, and offline-first behaviour.

This repo is a **multi-package monorepo**: runnable apps live under `apps/`, shared libraries under `sdk/`. Networking, storage, models, and UI live in the SDK; product apps stay thin shells that compose those packages. Another app can depend on `sdk/` instead of copying layers.

> **Status:** Mandatory scope is implemented (list, search, detail, favourites, offline). Bonus episode fan-out Path 1 is implemented on character detail (Path 2 design remains in docs). Optional extra not shipped: persisted theme.

---

## Screen recording

Walkthrough of Explorer — list, search, detail, favourites, and airplane-mode offline:

**[Watch on YouTube](https://youtube.com/shorts/mMX2ulmdADI)** (unlisted)

---

## Repository layout

```text
thawani_assignment/
├── apps/
│   └── explorer/          # Assignment Flutter app
├── sdk/
│   ├── thawani/           # Domain / product package (repos, features)
│   ├── thawani_models/    # Shared models, DTOs, mappers
│   ├── thawani_ui/        # Shared design system & reusable widgets
│   ├── networking/        # HTTP, connectivity, typed remote failures
│   ├── local_storage/     # Local persistence abstraction (Hive)
│   └── needle/            # get_it re-export for DI
├── docs/                  # Architecture, ADRs, scope, strategies
└── README.md              # You are here
```

See [docs/monorepo.md](docs/monorepo.md) for package responsibilities and dependency rules.

---

## Documentation index

| Document | Purpose |
|----------|---------|
| [docs/architecture.md](docs/architecture.md) | Clean Architecture layers, boundaries, data flow |
| [docs/monorepo.md](docs/monorepo.md) | Apps vs SDK, package map, dependency graph |
| [docs/assignment-scope.md](docs/assignment-scope.md) | Brief requirements mapped to planned work |
| [docs/offline-and-caching.md](docs/offline-and-caching.md) | Cache, favourites, offline banner strategy |
| [docs/testing-strategy.md](docs/testing-strategy.md) | Unit / widget tests planned against the brief |
| [docs/episode-fanout.md](docs/episode-fanout.md) | Bonus: episode batching design (Path 2) + Path 1 notes |
| [docs/roadmap.md](docs/roadmap.md) | Phased implementation order |
| [docs/decisions/](docs/decisions/) | Architecture Decision Records (ADRs) |

---

## How to run

```bash
cd apps/explorer
flutter pub get

flutter run --flavor dev
flutter run --flavor prod
```

Both flavors use the public Rick and Morty API. They differ by app name, Android application id / iOS bundle id, launcher icon, splash colour, and the in-app environment label.

```bash
# From apps/explorer
flutter analyze --fatal-warnings
flutter test
```

SDK packages: `cd sdk/<package> && flutter analyze --fatal-warnings && flutter test`.

- **Flutter version:** 3.41.6 (stable), Dart 3.11.4 — same pin as GitHub Actions.
- **Platforms tested:** Android (`dev` and `prod` flavor builds). iOS schemes are wired; Android was the device-side check. Unit and widget tests run on the Flutter test harness.

---

## Architecture snapshot

- **Presentation** lives in `apps/explorer` (screens, Provider, navigation, flavors).
- **Use cases** live in `apps/explorer` (between Providers and repositories).
- **Domain contracts** (entities, repository interfaces, failures) live primarily in `sdk/thawani` + `sdk/thawani_models`.
- **Data** (API client, DTO ↔ model mapping, Hive cache / favourites) implements those contracts inside `sdk/thawani` and infrastructure packages.
- Widgets never call HTTP or storage directly. UI → use case → repository (via Provider), not Dio/Hive.
- **Flavors:** Development, Production.

Full detail: [docs/architecture.md](docs/architecture.md).

---

## State management & DI

- **Provider** — UI state ([docs/decisions/001-state-management.md](docs/decisions/001-state-management.md))
- **get_it** via **needle** — dependency injection ([docs/decisions/008-dependency-injection.md](docs/decisions/008-dependency-injection.md))

---

## Assumptions

1. Search with no matches (API `404`) is treated as an empty result set for that query, not a hard failure — user sees a named empty state.
2. Favourites are keyed by character `id` and store enough fields to render list/detail offline without a network round-trip.
3. “Cached and when it was fetched” on the offline banner uses the timestamp of the last successful list/detail write for the data currently shown.
4. Infinite scroll triggers when remaining scroll extent is under **400 px**, not only at the exact end.
5. One product app (`explorer`) is enough for the submission; the monorepo exists to demonstrate multi-app readiness, not to ship a second app.

---

## Known limitations

- No persisted light/dark theme (brief: pick at most one bonus; this repo implemented episode fan-out).
- Visual polish is not scored; clarity of layering is.
- Episode cache is in-memory only (does not survive process restart).

---

## Time spent

Work spanned **24–26 August 2026** (docs, SDK packages, Explorer features, flavors, and tests).

---

## AI tools used

| Tool | Used for |
|------|----------|
| Cursor | Help drafting docs and coding assistance under my direction |

I only submit code I can explain line-by-line in interview.

---

## Assignment brief

Official brief: Rick and Morty Explorer (list, search, detail, favourites, offline). Mapping of that brief to this repo: [docs/assignment-scope.md](docs/assignment-scope.md).
