# ADR 007 — Flutter flavors (Development, Production)

## Context

Thawani’s role description expects experience with multiple application environments and Flutter flavors. The assignment itself uses one public API and forbids committing secrets. Two flavors are enough to demonstrate the pattern for this take-home.

## Decision

Explorer ships with two flavors:

| Flavor | Typical use |
|--------|-------------|
| Development | Day-to-day local runs |
| Production | Release-shaped build |

Each flavor has its own config (app display name suffix, application id / bundle id where applicable, environment label). A single `lib/main.dart` resolves the flavor from `--dart-define=flavor=` (preferred) or `--flavor`. For this assignment both flavors may share the same Rick and Morty base URL; the flavor machinery is still in place.

No API keys, tokens, or other secrets are committed. Config that must differ later can use non-secret values or local untracked files.

## Consequences

**Positive**

- Shows multi-environment wiring without UAT overhead for this assignment.
- README can document how to run each flavor.

**Negative / trade-offs**

- Extra Android product flavors and iOS schemes to maintain vs a single-flavor app.
- UAT is omitted here; a third flavor can be added later if needed.

**Rejected alternatives**

- Single flavor only — simpler, but does not show environment wiring.
- Dev + UAT + Prod — more than needed for this assignment.
- Committing secrets per flavor — disallowed by the brief.
