# Planned packages (stubs)

These READMEs describe packages **before** they are scaffolded. When each package is created, move/adapt this content into that package’s own `README.md`.

## `apps/explorer`

Flutter application implementing the Rick and Morty Explorer assignment. Composition root: Provider wiring, use cases navigation (list / detail / favourites), flavors, and screen UI. Depends on `thawani`, `thawani_ui`, and `thawani_models`.

## `sdk/thawani`

Product/domain package. Character (and optional episode) repositories, remote/local data sources, orchestration of cache vs network. Depends on `thawani_models`, `networking`, `local_storage`. Use cases live in the app, not here.

## `sdk/thawani_models`

Shared entities, API DTOs, and explicit mappers. No HTTP or Hive. Consumed by domain and UI.

## `sdk/thawani_ui`

Design tokens and reusable widgets: list row chrome, empty/error states, offline banner, favourite control, loading indicators. Presentation-only.

## `sdk/needle`

Re-exports **get_it**. Shared import for `GetIt` / `sl` across app and SDK packages. Registration stays in `apps/explorer/lib/di/`.

## `sdk/networking`

Dio-based HTTP wrapper, connectivity, typed remote failures. Feature-agnostic.

## `sdk/local_storage`

Hive-backed persistence facade. Feature-agnostic read/write; repositories own cache policy.
