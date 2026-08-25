# Thawani Flutter Assignment — Explorer

Thawani Flutter take-home: the **Explorer** app — a Rick and Morty character browser with search, pagination, favourites, and offline-first behaviour.

This repo is a **multi-package monorepo**: runnable apps live under `apps/`, shared libraries under `sdk/`. Networking, storage, models, and UI live in the SDK; product apps stay thin shells that compose those packages. Another app can depend on `sdk/` instead of copying layers.

> **Status:** Leaf SDK packages exist (`needle`, `thawani_models`, `networking`, `local_storage`). Remaining: `thawani_ui`, `thawani`, and Explorer.

---

## Repository layout

```text
thawani_assignment/
├── apps/
│   └── explorer/          # Assignment Flutter app (to be created)
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
| [docs/episode-fanout.md](docs/episode-fanout.md) | Optional bonus: episode batching design (Path 2) |
| [docs/roadmap.md](docs/roadmap.md) | Phased implementation order (when coding starts) |
| [docs/decisions/](docs/decisions/) | Architecture Decision Records (ADRs) |

---

## How to run

*To be filled once the Flutter project is scaffolded.*

Expected (draft):

```bash
# From apps/explorer after packages exist
flutter pub get
flutter run --flavor dev -t lib/main_dev.dart
# also: prod entrypoint
```

- **Flutter version:** TBD at scaffold time (pinned in docs and CI notes).
- **Platforms tested:** TBD (Android and/or iOS — one is sufficient per brief).

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

*Updated as ambiguities are resolved during implementation. Initial set:*

1. Search with no matches (API `404`) is treated as an empty result set for that query, not a hard failure — user sees a named empty state.
2. Favourites are keyed by character `id` and store enough fields to render list/detail offline without a network round-trip.
3. “Cached and when it was fetched” on the offline banner uses the timestamp of the last successful list/detail write for the data currently shown.
4. Infinite scroll triggers when the user approaches the bottom (threshold TBD, ~200–400 px), not only at exact end.
5. One product app (`explorer`) is enough for the submission; the monorepo exists to demonstrate multi-app readiness, not to ship a second app.

---

## Known limitations / unfinished

*To be updated honestly before submission.*

- Implementation started: `needle`, `thawani_models`, `networking`, and `local_storage`. Remaining: `thawani_ui`, `thawani`, and Explorer.
- Bonus episodes feature: design documented in [docs/episode-fanout.md](docs/episode-fanout.md); implementation optional.

---

## Time spent

*To be filled before submission.*

---

## AI tools used

| Tool | Used for |
|------|----------|
| Cursor (Composer) | Help drafting docs and (later) coding assistance under my direction |

I only submit code I can explain line-by-line in interview.

---

## Assignment brief

See `Flutter Assignment.pdf` in the repo root for the official brief (Rick and Morty Explorer: list, search, detail, favourites, offline).
