# Assignment scope

Mapping of the official brief (`Flutter Assignment.pdf`) to what we will build and where it lives.

## Success criteria (from brief)

Finishing **mandatory** scope is a complete submission. Bonuses are optional and cannot lower the score.

### Do not cut

- Paginated list with infinite scroll  
- Search (debounced)  
- Detail screen  
- Favourites persistence  
- Error handling + offline behaviour  

### Cut last if out of time (in this order)

1. Tests (keep at least the two repository paths + one interaction / debounce-or-pagination test)  
2. Offline banner “how long ago” detail (keep serving cached data)  
3. Pull to refresh  
4. Filter / sort niceties  

---

## Feature → package map

| Requirement | Primary home | Notes |
|-------------|--------------|-------|
| Paginated character list | `thawani` repo + `explorer` list UI | Infinite scroll; end-of-list loader |
| Search by name | `explorer` Provider debounce → repo | 300–500 ms; cancel stale |
| Search `404` → empty | `thawani` remote/repository | Map to empty results, not error UI |
| Pull to refresh | `explorer` list | Resets to page 1 |
| List row (2+ fields + favourite) | `thawani_ui` row + `explorer` | Name + status (or species) |
| Detail screen | `explorer` + repo | Richer fields; works offline from cache |
| Favourites screen | `explorer` + local favourites | Empty state; sync with list/detail |
| Offline cache + banner | repo + `thawani_ui` banner | See [offline-and-caching.md](offline-and-caching.md) |
| Typed errors | `networking` / `thawani` | User-facing messages in UI |
| DTO ≠ model | `thawani_models` | Explicit bidirectional mappers (`toEntity` / `toDto`) |
| Tests | `thawani` + `explorer` | See [testing-strategy.md](testing-strategy.md) |
| `flutter analyze` clean | all packages | No `// ignore:` to silence |

## Screens

### 1. List

Distinct non-overlapping UI for:

1. Initial loading  
2. Loaded with results  
3. Loaded with zero results for current search (message **names the query**)  
4. Error with retry  

Plus: infinite scroll loader, search field, pull-to-refresh, favourite toggle per row.

### 2. Detail

- Richer character view (image, status, species, gender, origin, location, episode count, etc.).  
- Favourite toggle consistent with list.  
- Opens from cache when offline.

### 3. Favourites

- Tab or dedicated route.  
- Fully offline.  
- Empty state.  
- Unfavourite updates list/detail.

### 4. Offline

- Cache fetched list (and detail payloads as needed).  
- Serve cache when network unavailable.  
- Non-blocking banner: offline + age of data.  
- Recover on connectivity / retry.

## API (Rick and Morty)

| Purpose | Endpoint |
|---------|----------|
| Paginated list | `GET /api/character?page=N` |
| Search | `GET /api/character?name=QUERY` |
| Single | `GET /api/character/ID` |

Response shape: `info` (`count`, `pages`, `next`, `prev`) + `results`.

Base URL: `https://rickandmortyapi.com`

## Optional bonus

Pick **at most one** if mandatory scope is solid:

| Option | Plan |
|--------|------|
| Filter chips / sort | Only if time remains after mandatory + tests |
| Light/dark + persisted theme | Good fit with `thawani_ui` + `local_storage` |
| Episodes fan-out (hard) | Prefer **Path 2** design doc — already drafted as [episode-fanout.md](episode-fanout.md). Path 1 only if mandatory is rock solid |

## Evaluation weights (for prioritisation)

| Area | Weight | Focus |
|------|--------|-----------|
| Mandatory features work | 20% | Ship list/search/detail/favourites/offline |
| Architecture & SoC | 20% | Clean layers + use cases + repo boundary + sdk package split |
| State management & async | 15% | Provider + debounce/pagination guards |
| Errors & offline | 15% | Typed failures + cache-first when offline |
| Tests that catch bugs | 15% | Repo success/fail + debounce + pagination + widget interaction |
| Code quality | 10% | Readable, analyze-clean |
| Commits & docs | 5% | Incremental commits; this docs set |

Visual polish is **not** scored. Clarity of layering beats decoration.

## Implementation order (when coding starts)

1. Scaffold monorepo packages + Explorer app + flavors (dev / prod)  
2. Models + DTOs + mappers (hand-written; no code gen / GraphQL)  
3. Networking + remote data source  
4. Local storage + cache/favourites sources  
5. Repositories in `thawani`, then use cases in `explorer`  
6. Providers + list/detail/favourites UI  
7. Offline banner + connectivity  
8. Tests + analyze  
9. README run instructions (per flavor), platforms, time, AI note  
10. Optional: theme **or** episode design already done / partial Path 1  

## Out of scope for this assignment

- Real Thawani payment APIs, auth, NFC, push, deep links (job-relevant; not in brief).  
- GraphQL or API/model code generation.  
- Analytics / Crashlytics.  
- Second shipped app binary (structure only).  
- Publishing to stores.
