# Implementation roadmap

Ordered plan for when coding begins. Documentation in this folder is the source of truth until code exists.

## Phase 0 — Docs (done)

- [x] Root README  
- [x] Architecture, monorepo, scope, offline, testing  
- [x] ADRs  
- [x] Episode fan-out Path 2  

## Phase 1 — Scaffold

1. Create Flutter packages under `sdk/` (`thawani_models`, `networking`, `local_storage`, `thawani_ui`, `thawani`, `needle`).  
2. Create `apps/explorer` Flutter app with path dependencies.  
3. Wire flavors: Development, Production (entrypoints, Android product flavors, iOS schemes).  
4. Add `apps/explorer/lib/di/` — `injection_container.dart` + split injectors (`get_it` via `needle`).  
5. Shared analysis options if useful; ensure `flutter analyze` is runnable per package.  
6. Initial incremental git commits (scaffold ≠ one giant dump).

## Phase 2 — Data foundation

1. DTOs + entities + mappers in `thawani_models` (hand-written; no code gen / GraphQL).  
2. Dio client + failures + connectivity in `networking`.  
3. Hive facade in `local_storage`.  
4. Remote + local data sources + repositories in `thawani`.  

## Phase 3 — Presentation

1. App shell with tabs/routes: List | Favourites (+ Detail push).  
2. Use cases in `apps/explorer` on top of repositories.  
3. List Provider → use cases: pagination, debounce, pull-to-refresh, UI states.  
4. Detail screen + shared favourites notifier (via use cases).  
5. Favourites screen + empty state.  
6. Offline banner wired to cache metadata.  

## Phase 4 — Quality

1. Repository tests (success + failure).  
2. Debounce and pagination tests.  
3. Widget interaction test.  
4. `flutter analyze` clean.  
5. Fill README: run steps per flavor, Flutter version, platforms, time, AI tools, assumptions, limitations.  

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
