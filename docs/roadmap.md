# Implementation roadmap

Ordered implementation plan. Package behaviour lives in each package’s `README.md` and in `docs/`.

## Phase 0 — Docs (done)

- [x] Root README  
- [x] Architecture, monorepo, scope, offline, testing  
- [x] ADRs  
- [x] Episode fan-out Path 2  

## Phase 1 — Scaffold

1. Create Flutter packages under `sdk/` — done (all six packages).  
2. Create `apps/explorer` Flutter app with path dependencies — done.  
3. Wire flavors: Development, Production (single `main.dart`, Android product flavors, iOS schemes) — done.  
4. Add `apps/explorer/lib/di/` — `injection_container.dart` + split injectors (`get_it` via `needle`) — done (use-case / provider injectors stay empty until Phase 3).  
5. Shared analysis options if useful; ensure `flutter analyze` is runnable per package — done (`flutter_lints` per package).  
6. Initial incremental git commits (scaffold ≠ one giant dump).

## Phase 2 — Data foundation

1. DTOs + entities + mappers in `thawani_models` — done (hand-written; no code gen / GraphQL).  
2. Dio client + failures + connectivity in `networking` — done.  
3. Hive facade in `local_storage` — done.  
4. Remote + local data sources + repositories in `thawani` — done.  

## Phase 3 — Presentation

1. App shell with tabs/routes: List | Favourites (+ Detail push) — done.  
2. Use cases in `apps/explorer` on top of repositories — done.  
3. List Provider → use cases: pagination, debounce, pull-to-refresh, UI states — done.  
4. Detail screen + shared favourites notifier (via use cases) — done.  
5. Favourites screen + empty state — done.  
6. Offline banner wired to cache metadata — done.  

## Phase 4 — Quality

1. Repository tests (success + failure) — done.  
2. Debounce and pagination tests — done.  
3. Widget interaction test — done.  
4. `flutter analyze` clean — SDK via CI; Explorer locally (CI follow-up).  
5. Fill README: run steps per flavor, Flutter version, platforms, time, AI tools, assumptions, limitations — done.  

## Phase 5 — Optional

1. Keep episode Path 2 doc as bonus.  
2. If time: persisted light/dark theme **or** Path 1 episodes — not both.  
3. 2–3 minute screen recording including airplane-mode offline scenario.  

## Interview prep checklist

- [ ] Trace: list row tap → Provider → use case → repository → detail data  
- [ ] Trace: network error → typed failure → user message  
- [ ] Explain search 404 → empty  
- [ ] Explain debounce + stale response ignore  
- [ ] Explain offline cache + banner `fetchedAt`  
- [ ] Explain flavors (dev / prod)  
- [ ] Walk episode answers in `episode-fanout.md`  
- [ ] Be ready for a small live change  
