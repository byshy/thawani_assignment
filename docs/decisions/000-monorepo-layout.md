# ADR 000 — Apps + SDK monorepo

## Context

The assignment ships one Flutter app, but shared mobile code (networking, storage, models, UI) should stay reusable if another Thawani app is added later.

## Decision

Use a monorepo with:

- `apps/` — runnable Flutter applications (`explorer` for this assignment)
- `sdk/` — path-dependent packages shared (or shareable) across apps

## Consequences

**Positive**

- Clear composition boundary; Explorer stays a thin app shell.
- Shared packages scale across multiple apps.
- Adding a second app later is a dependency exercise, not a rewrite.

**Negative / trade-offs**

- Slightly more scaffolding than a single `lib/` tree.
- Path dependencies and analyze must be run per package (or via a small script later).

**Rejected alternatives**

- Single app only — simpler, but shared code would live only inside Explorer.
- Melos/pub workspaces from day one — optional later; path deps are enough for this package count.
