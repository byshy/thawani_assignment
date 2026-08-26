# ADR 006 — Episodes bonus: Path 2 first, Path 1 after mandatory


## Context

The hard bonus (episode fan-out) is optional and time-intensive. Path 2 (design doc) is scored the same as a partial Path 1 and is recommended when time is limited.

## Decision

1. Keep [../episode-fanout.md](../episode-fanout.md) as the Path 2 submission artifact.  
2. Only implement Path 1 after mandatory features, offline, analyze, and tests are solid.  
3. Do not attempt filter/sort **and** episodes; the brief says pick at most one bonus.

Path 1 is implemented: batched episode list on character detail, in-memory cache, debug overlay. Persisted theme was not chosen.

## Consequences

**Positive**

- Protects mandatory score (most weighting sits outside bonuses) by sequencing Path 1 after that work.  
- Demonstrates systems thinking in both the design doc and running code (batching, single-flight, partial failure, cancel).

**Negative / trade-offs**

- No persisted light/dark theme.

**Rejected alternatives**

- Jumping into Path 1 early — risks incomplete mandatory scope.
- Skipping the design doc entirely — leaves Path 2 answers unwritten.
- Implementing theme instead — weaker demonstration of the hard bonus.
