# Testing strategy

Tests should **fail if the behaviour under them breaks**. The brief’s bar: imagine breaking the code — would the test catch it?

## Mandatory coverage (brief)

1. **Repository unit test** with a mocked HTTP client  
   - Success path  
   - At least one failure path  
2. **Debounce and pagination** logic tests  
3. **One widget test** exercising a real interaction  

## Planned tests

### `sdk/thawani` — `CharacterRepository`

| Case | Assert |
|------|--------|
| Success | Mock client returns page JSON → models mapped; cache write invoked |
| Failure without cache | Mock throws / 500 → typed `Failure`; no crash |
| Failure with cache | Remote fails, local has data → returns cached models + cache meta |
| Search 404 | Treated as empty results, not failure |
| Offline read | Connectivity false → serves local without calling remote |

Use a fake/mock HTTP client (e.g. Dio `Adapter` / `http` MockClient) — never hit the live API in tests.

### Debounce and pagination

Both are covered (brief requires at least one).

**Debounce:** given rapid query changes, only the last query after 300–500 ms triggers a fetch; responses for older queries are ignored.

**Pagination:** while a page request is in flight, a second trigger does not start a duplicate; when `next` is null, no further requests.

### Widget interaction (`apps/explorer`)

Example that catches bugs:

- Tap favourite on a list row → icon/state updates **and** favourites repository/notifier reflects the change  
  or  
- Enter search text → after debounce, empty/error/results UI updates for that query  

Avoid tests that only `expect(find.byType(ListView), findsOneWidget)` with no behaviour.

## What we will not do

- Golden/screenshot tests (not scored; polish).  
- Full integration tests against the real API (flaky; against brief spirit for unit isolation).  
- 100% coverage chasing — prefer few sharp tests.

## Tooling

- `flutter_test`  
- Mocking: register fakes on `GetIt sl` in test setup; hand-rolled fakes preferred for clarity; `mocktail` acceptable if readable  
- Run per package: `flutter test` in `sdk/thawani` and `apps/explorer`  
- CI runs `flutter analyze --fatal-warnings` and `flutter test` for changed SDK packages and for Explorer when `apps/explorer/` or `.github/` changes  
- `flutter analyze` with zero warnings across packages — no `// ignore:` silencers  

## Definition of done for tests

- Breaking mapper success → repository success test fails  
- Breaking failure mapping → failure test fails  
- Removing debounce delay / ignore-stale → debounce test fails  
- Duplicate page fetch or fetch past last page → pagination test fails  
- Favourite tap no longer persists → widget test fails  

### Bonus — episode fan-out (`sdk/thawani` + `apps/explorer`)

Fake remote, not the live API. Cover: object vs list parse, chunk count (51 ids → 3 calls), single-flight, partial failure + retry, cancel.  
