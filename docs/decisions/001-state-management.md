# ADR 001 — State management: Provider


## Context

The brief allows Riverpod, Bloc/Cubit, or Provider, and asks for a short justification in the README. Thawani’s role description calls out **Provider**. The assignment’s state surface is modest: list pagination/search, detail, favourites, connectivity banner.

## Decision

Use **Provider** (and `ChangeNotifier` / dedicated notifiers) for presentation **state**.

**Dependency injection** is separate: **get_it** via `sdk/needle`, registered in `apps/explorer/lib/di/`. See [008-dependency-injection.md](008-dependency-injection.md).

## Consequences

**Positive**

- Aligns with Thawani’s stated stack without fighting the brief.
- Easy to narrate in interview: “tap → Provider → use case → repository → UI rebuild”.
- Sufficient for debounce, pagination guards, and favourites sync via a shared favourites notifier.

**Negative / trade-offs**

- Less structured than Bloc for event/state sealed unions — I compensate with clear notifier APIs and typed UI states (loading/data/empty/error).
- Not Riverpod’s compile-safe DI — get_it handles construction; Provider handles UI state.

**Rejected alternatives**

- **Bloc/Cubit** — strong for Clean Architecture demos; weaker signal vs Thawani’s Provider preference for this submission.
- **Riverpod** — strong technically; less aligned with Thawani’s explicit Provider callout.
