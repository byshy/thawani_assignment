# sdk/

Shared Flutter/Dart packages consumed by apps.

| Package | Role |
|---------|------|
| `thawani/` | Product/domain (repositories, data sources) |
| `thawani_models/` | Entities, DTOs, mappers — **scaffolded** |
| `thawani_ui/` | Design system & shared widgets |
| `networking/` | HTTP, connectivity, remote failures — **scaffolded** |
| `local_storage/` | Local persistence (Hive) — **scaffolded** |
| `needle/` | get_it re-export for DI — **scaffolded** |

Leaf SDK packages exist. Remaining: `thawani_ui` and `thawani`. Dependency rules: [../docs/monorepo.md](../docs/monorepo.md).
