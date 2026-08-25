# sdk/

Shared Flutter/Dart packages consumed by apps.

| Package | Role |
|---------|------|
| `thawani/` | Product/domain (repositories, data sources) |
| `thawani_models/` | Entities, DTOs, mappers |
| `thawani_ui/` | Design system & shared widgets |
| `networking/` | HTTP, connectivity, remote failures |
| `local_storage/` | Local persistence (Hive) |
| `needle/` | get_it re-export for DI — **scaffolded** |

`needle` exists. Remaining packages are still planned. Dependency rules: [../docs/monorepo.md](../docs/monorepo.md).
