# ADR 006 — Episodes bonus: Path 2 first


## Context

The hard bonus (episode fan-out) is optional and time-intensive. Path 2 (design doc) is scored the same as Path 1 and is recommended when time is limited.

## Decision

1. Keep [../episode-fanout.md](../episode-fanout.md) as the Path 2 submission artifact.  
2. Only implement Path 1 after mandatory features, offline, analyze, and tests are solid.  
3. Do not attempt filter/sort **and** episodes; the brief says pick at most one bonus — if I implement a bonus in code, I prefer persisted light/dark theme as the lighter option, keeping episodes as the design-scored hard bonus.

## Consequences

**Positive**

- Protects mandatory score (most weighting sits outside bonuses).
- Still demonstrates systems thinking (batching, single-flight, partial failure, cancel).

**Negative / trade-offs**

- No running episode UI unless Path 1 is later scheduled.

**Rejected alternatives**

- Jumping into Path 1 early — risks incomplete mandatory scope.
- Skipping the design doc entirely — leaves free Path 2 points on the table.
