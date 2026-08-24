# Episode fan-out design (bonus Path 2)

Optional hard bonus from the brief. **Path 2** (design-only) is scored the same as a partial Path 1. This note answers the interview questions and records how we would implement the feature without melting the network.

> Status: design complete for scoring Path 2. Path 1 implementation is optional and only after mandatory scope is solid.

## Feature

On the character detail screen, show episodes the character appears in — **name**, **air date**, **episode code** — grouped by season.

Character payload gives URLs only:

```json
"episode": [
  "https://rickandmortyapi.com/api/episode/1",
  "https://rickandmortyapi.com/api/episode/2"
]
```

Main characters can exceed 50 episodes. Naïve per-URL fetching is the N+1 fan-out we must avoid.

## API facts (investigation answers)

Verified with live `curl` against `https://rickandmortyapi.com` (2026-08-24).

### Single id vs multiple ids

- `GET /api/episode/1` → a **single** episode **object** (HTTP 200).  
- `GET /api/episode/1,2,3` → a top-level **array** of episode objects (HTTP 200) — **not** wrapped in `info`/`results`.  
- `GET /api/episode?page=1` (paginated list) → `{ info, results }` — a third shape; do not reuse that parser for by-id fetches.

Parsers must accept **both** by-id shapes:

```dart
// Pseudocode
EpisodeOrList parse(dynamic json) {
  if (json is List) return json.map(EpisodeDto.fromJson);
  if (json is Map) return [EpisodeDto.fromJson(json)];
  throw ParseFailure(...);
}
```

### Practical URL length / id batch size

- Rick Sanchez (`/api/character/1`) has **51** episode URLs (ids 1–51).  
- `GET /api/episode/1,...,51` succeeds in **one** call (HTTP 200, array of 51). URL length is only ~183 characters.  
- Today the catalog has **51** episodes total, so the entire set fits comfortably in one multi-id URL.  
- Mixed valid + invalid (`/api/episode/1,99999,2`) → HTTP **200** with only valid episodes `[1, 2]` (bad ids dropped silently).  
- Duplicate ids (`/api/episode/1,1,2`) → API dedupes; returns two episodes.  
- Invalid **single** id (`/api/episode/99999`) → HTTP **404** `{ "error": "Episode not found" }`.

So URL length is **not** the binding constraint for this API today. Chunking is still deliberate:

**Choice:** chunk size **20**.  
For 51 uncached episodes → `ceil(51/20) = 3` HTTP requests (or fewer if some ids are already cached).

**Why not one request for Rick?** One call works on this API *today*. Chunking at 20 keeps payloads modest, makes partial failure / “retry missing” meaningful (network/timeout failures, not bad-id failures — those are silently skipped in multi-id calls), and keeps concurrency controllable if episode counts grow. Easy to justify and debug in the overlay.

I am not chasing the maximum possible batch.

---

## Design

### Components

| Piece | Responsibility |
|-------|----------------|
| `EpisodeRemoteDataSource` | `fetchByIds(List<int> ids)` — one HTTP call; parse object-or-list |
| `EpisodeCache` | In-memory map `id → Episode`; optional Hive later |
| `EpisodeRepository` | Dedupe ids, split cache hits/misses, chunk misses, single-flight, concurrency cap |
| Detail Provider | Requests episodes for character; cancels on dispose; exposes partial + retry |

### Algorithm (open character with N episode URLs)

1. Parse ids from URLs.  
2. Partition into **cached** vs **missing**.  
3. Chunk **missing** into batches of 20.  
4. Run chunks with **max concurrency = 2** (or 3) — never one socket per chunk simultaneously if many chunks.  
5. **Single-flight:** coalesce concurrent asks for the same id/chunk key so one network call serves all waiters.  
6. Merge successes into cache and into UI state as chunks complete.  
7. On chunk failure: keep successful episodes; mark failed id set; offer **Retry missing**.  
8. On dispose / navigate back: cancel in-flight work (CancelToken); do not update Provider after dispose.

### Debug overlay

Small overlay on detail: `episode HTTP calls this screen: K`.  
Reviewers can open a heavy character and see batching (e.g. 3, not 51).

### Fake for tests

`FakeEpisodeRemote` implements the same interface; tests never touch production API. Cover: object vs list parse, chunking count, single-flight, partial failure + retry, cancel.

---

## Interview Q&A (ready answers)

### A character appears in 51 episodes. How many HTTP requests, and why?

**Up to 3** under our design, if none are cached: chunk size 20 → 20 + 20 + 11.  
(Verified: the API *can* return all 51 in one multi-id call; we still chunk for payload size, retry granularity, and concurrency.)  
If some ids are already in cache, fewer. Debug overlay should match.

### Single id vs several — parser?

Single → JSON **object**; multi → JSON **array** (not `{info, results}`). Parser normalises to `List<Episode>`.

### Second character shares 40 episodes with the first. How many requests now?

Only for **ids not already in memory cache**. If 40 are warm and 11 are new → **one** request (11 ≤ 20). Ideally **zero** if the second character’s set is a subset of the cache.

### Two widgets ask for episode 12 at the same instant. How many network calls?

**Exactly one.** Single-flight map: first caller starts the request; second awaits the same `Future`.

### One chunk fails, others succeed. What does the user see?

Successful episodes render (grouped by season). Failed subset shows an inline error + **Retry** for missing ids only. User does not lose arrived data.  
Note: a bad id *inside* a multi-id call is usually **not** a chunk failure — the API returns 200 with valid ids only. Chunk failures we design for are network / timeout / 5xx.

### User taps back while five chunks are in flight?

Cancel tokens fire; repository ignores late results for that session; Provider disposed so no `notifyListeners` on dead state. In-flight work should not continue “for nothing” beyond cancellation — Dio cancel aborts the calls.

### How to test without the real API?

Inject `EpisodeRemoteDataSource` fake: scripted responses per id list, forced failures per chunk, delayed futures to assert single-flight and cancel.

### In-memory cache — what if it must survive restart?

Persist `id → Episode` (and maybe `cachedAt`) in Hive via `local_storage`. Hydrate memory cache on startup or on first miss. Same repository API; only the cache adapter changes. Watch storage growth — optional max entries / LRU for production.

---

## Concurrency and courtesy

- Cap concurrent chunk requests (2–3).  
- No aggressive rate limit on this API, but runaway loops are a finding — guards on pagination/single-flight apply here too.  
- Prefer Path 2 documentation over a half-broken Path 1.

## Implementation sketch (if Path 1 later)

```text
sdk/thawani/
  data/episodes/episode_remote_data_source.dart
  data/episodes/episode_repository.dart
  data/episodes/episode_memory_cache.dart
apps/explorer/
  features/detail/episode_section.dart
  features/detail/episode_debug_overlay.dart
```

## Deliberate non-goals

- Prefetching all episodes app-wide.  
- GraphQL.  
- Unbounded parallel chunk fan-out.
