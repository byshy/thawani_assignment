# sdk/

Shared Flutter/Dart packages consumed by apps.

| Package | Role |
|---------|------|
| `thawani/` | Product/domain (repositories, data sources) — **scaffolded** |
| `thawani_models/` | Entities, DTOs, mappers — **scaffolded** |
| `thawani_ui/` | Design system & shared widgets — **scaffolded** |
| `networking/` | HTTP, connectivity, remote failures — **scaffolded** |
| `local_storage/` | Local persistence (Hive) — **scaffolded** |
| `needle/` | get_it re-export for DI — **scaffolded** |

All SDK packages exist. The assignment app is [`apps/explorer`](../apps/explorer/README.md). Dependency rules: [../docs/monorepo.md](../docs/monorepo.md).
