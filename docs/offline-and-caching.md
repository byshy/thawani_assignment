# Offline and caching strategy

Offline behaviour is a **core** requirement, not a bonus.

## Goals

1. When the network is unavailable, show **cached** character data instead of a hard error (when cache exists).  
2. Show a **visible, non-blocking** indicator that data is cached, including how long ago it was fetched.  
3. Favourites work with **no network**.  
4. Detail opens from cache when offline.  
5. Recover automatically or via retry when connectivity returns.

## Data stores

| Store | Contents | Survives restart |
|-------|----------|------------------|
| List/search cache | Pages (or flattened results) keyed by query + page, plus `fetchedAt` | Yes (Hive) |
| Character detail cache | Full character by `id`, plus `fetchedAt` | Yes |
| Favourites | Favourited characters (enough fields to render list/detail rows) | Yes |
| In-memory episode cache | Only if bonus Path 1 is implemented | No by default (see episode doc) |

Default persistence: **Hive** via `sdk/local_storage` (see [decisions/003-persistence.md](decisions/003-persistence.md)).

## Repository policy

```text
readCharacters(query, page):
  if online:
    try remote
      on success → write cache → return NetworkResult(data, fromCache: false)
      on failure → if cache hit → return CacheResult(data, fetchedAt)
                   else → Failure
  if offline:
    if cache hit → return CacheResult(data, fetchedAt)
    else → Failure (no data to show)  // distinct from "empty search"
```

### Search empty vs error vs offline-miss

| Situation | UI |
|-----------|-----|
| Online, API `404` for search | Empty state naming the query |
| Online, 5xx / parse error, no cache | Error + retry |
| Offline, cache hit | Data + offline banner |
| Offline, no cache | Error-style empty with “unavailable offline” + retry (retry no-ops or waits for network) |

## Offline banner

Non-blocking banner above the list (and optionally detail):

- Example copy: `Offline — showing data from 12 minutes ago`  
- `fetchedAt` comes from the cache metadata for the **data currently displayed**  
- Hide banner when serving fresh network data  
- Banner must not block scrolling or favourite toggles  

If we must cut under time pressure: keep serving cache; drop the relative-time detail (brief allows this cut).

## Favourites

- Toggle writes only to local favourites store.  
- Same source of truth for list, detail, and favourites screen (Provider listens to favourites changes).  
- Favourites screen never requires network.  
- Optionally, favouriting also ensures the character snapshot is in detail cache (so detail remains rich offline).

## Connectivity

- `networking` exposes a connectivity stream/checker (`ConnectivityChecker`) based on real internet reachability.  
- List Provider may auto-refresh page 1 when transitioning offline → online (optional but nice).  
- Manual pull-to-refresh and error retry remain primary recovery paths.

## Cache invalidation

For this assignment, keep it simple:

- Successful network reads **overwrite** cache for that key.  
- No TTL eviction required by the brief.  
- Stale data is acceptable while offline; honesty via the banner matters more than freshness algorithms.

## Privacy / security note

Public Rick and Morty data only — no PII. For a real Thawani app, I would plug encrypted secure storage for tokens/PII into the same `local_storage` boundary; that is out of scope for this assignment.

## Related

- [architecture.md](architecture.md)  
- [episode-fanout.md](episode-fanout.md) (episode cache behaviour if bonus)  
- [decisions/003-persistence.md](decisions/003-persistence.md)
