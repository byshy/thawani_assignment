# Planned packages (stubs)

These READMEs describe packages **before** they are scaffolded. When each package is created, move/adapt this content into that package’s own `README.md`.

Scaffolded: [`sdk/needle`](../../sdk/needle/README.md), [`sdk/thawani_models`](../../sdk/thawani_models/README.md), [`sdk/networking`](../../sdk/networking/README.md), [`sdk/local_storage`](../../sdk/local_storage/README.md), [`sdk/thawani_ui`](../../sdk/thawani_ui/README.md).

## `apps/explorer`

Flutter application implementing the Rick and Morty Explorer assignment. Composition root: Provider wiring, use cases navigation (list / detail / favourites), flavors, and screen UI. Depends on `thawani`, `thawani_ui`, and `thawani_models`.

## `sdk/thawani`

Product/domain package. Character (and optional episode) repositories, remote/local data sources, orchestration of cache vs network. Depends on `thawani_models`, `networking`, `local_storage`. Use cases live in the app, not here.
