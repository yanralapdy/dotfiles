# Plan Detail File Templates

Templates for every standard `plan-details/` file type. Copy the relevant template,
then fill in the actual content from the session. Remove any sections that don't apply.
Never leave a section empty — if it's not applicable, remove the heading too.

---

## Table of contents

1. [01-context.md](#01-contextmd)
2. [02-requirements.md](#02-requirementsmd)
3. [03-findings.md](#03-findingsmd) (review sessions)
4. [XX-tasks.md](#xx-tasksmd)
5. [XX-phase-N.md](#xx-phase-nmd)
6. [XX-architecture.md](#xx-architecturemd)
7. [XX-session-log.md](#xx-session-logmd) (grill-me sessions)
8. [XX-gap-remediation.md](#xx-gap-remediationmd) (grill-me sessions)
9. [XX-open-decisions.md](#xx-open-decisionsmd)
10. [XX-spikes.md](#xx-spikesmd)
11. [XX-testing.md](#xx-testingmd)
12. [XX-rollout.md](#xx-rolloutmd)
13. [XX-parking-lot.md](#xx-parking-lotmd)

---

## 01-context.md

```markdown
# Context

> **TL;DR**: [2–3 sentences: what system/feature this is, its current state,
> and why this session happened.]

## System overview
[Describe the system being discussed: what it does, who uses it, where it lives
in the broader architecture. Include tech stack, key dependencies, deployment model.]

## Current state
[Describe exactly how things work RIGHT NOW, before any planned changes.
Be specific — name the files, services, and data flows involved.
This is the baseline the agent starts from.]

## Why this matters
[Why did this session happen? What problem prompted it?
What breaks or degrades if nothing is done?]

## Relevant links
- Repo: [URL or path]
- Design doc / RFC: [URL or path]
- Related tickets: [IDs]
- Runbook: [URL or path]
- Monitoring dashboard: [URL or path]
```

---

## 02-requirements.md

```markdown
# Requirements

> **TL;DR**: [2–3 sentences: what the system must do when the plan is complete,
> stated as observable outcomes.]

## Functional requirements
[What must the system do? State as outcomes, not implementations.
Use "must", "should", "may" to indicate priority.]

- **MUST**: [Non-negotiable requirement]
- **MUST**: [Non-negotiable requirement]
- **SHOULD**: [Strong preference but not a blocker]
- **MAY**: [Nice to have]

## Non-functional requirements
[Performance, reliability, security, compatibility, accessibility constraints.]

| Requirement | Target | How to measure |
|---|---|---|
| Response time | < 200ms p95 | Datadog APM |
| Availability | 99.9% uptime | PagerDuty |
| [Other] | [Target] | [Measurement] |

## Acceptance criteria
[Concrete, binary conditions that define "done". Each one must be checkable by the agent.]

- [ ] [Specific, verifiable condition]
- [ ] [Specific, verifiable condition]
- [ ] [Specific, verifiable condition]

## Out of scope
[List anything that might seem related but is explicitly NOT part of this plan.
This prevents scope creep and saves the agent from doing unnecessary work.]

- [Out-of-scope item and why]
- [Out-of-scope item and why]
```

---

## 03-findings.md

*(Review sessions only)*

```markdown
# Findings

> **TL;DR**: [N] findings from the review: [X] critical, [Y] high, [Z] medium, [W] low.
> Critical and high items are planned for immediate resolution. Medium items partially addressed.

## Findings catalog

### CRIT-01: [Short title]
**Severity**: Critical
**Location**: `path/to/file.ts:line-range`
**Description**: [What is wrong, concretely. Not "bad code" — what specifically
is incorrect, missing, or dangerous.]
**Impact**: [What happens if this isn't fixed. Data loss? Security breach? Wrong behavior?]
**Fix**: [How to fix it — see the corresponding task in `03-critical-fixes.md`]

---

### HIGH-01: [Short title]
[same format]

---

### MED-01: [Short title]
[same format]

---

### LOW-01: [Short title]
[same format — these may be batched: "LOW-01 through LOW-07: Style inconsistencies
in src/components/ — no ticket needed, fix during next pass"]

## Patterns

[If multiple findings point to the same systemic issue, document it here.]

### Pattern: Missing error boundaries in React components
**Findings affected**: MED-03, MED-05, MED-08, MED-11
**Root cause**: No `ErrorBoundary` component exists; errors propagate and crash the app.
**Resolution**: Create a shared `ErrorBoundary`, wrap all async data-loading components.
See `05-refactors.md` Task R-01.

## Deferred findings

[Items raised in the review but explicitly deferred.]

| ID | Title | Reason deferred | Target |
|---|---|---|---|
| MED-12 | Add API response caching | Needs perf profiling first | Q4 |
| LOW-04 | Rename `doTheThing` to something meaningful | Low risk | Next cleanup PR |
```

---

## XX-tasks.md

```markdown
# Tasks

> **TL;DR**: [N] tasks covering [main areas]. Execute in the order listed;
> tasks [X] and [Y] can be parallelized. Prerequisites listed per task.

## Execution order

```
Task 1 → Task 2 → Task 3 (parallel: Task 4, Task 5) → Task 6
```

[Or use a simple dependency table if there are many tasks:]

| Task | Depends on | Can parallelize with |
|---|---|---|
| T-01 | — | — |
| T-02 | T-01 | T-03 |
| T-03 | T-01 | T-02 |

---

### Task T-01: [Short title]

**Priority**: [Critical / High / Medium / Low]
**Effort**: [S (< 1hr) / M (1–4hr) / L (> 4hr)]
**Preconditions**: [What must be true / set up before this task can start]

**Background**: [Why this task exists. What prompted it. What it unblocks.]

**Steps**:
1. [Concrete action with named files/functions/commands]
2. [Concrete action]
3. [Concrete action]

**Code sketch** (if helpful):
```[language]
// Example or pseudocode showing the shape of the change
```

**Done when**:
- [ ] [Specific, verifiable outcome]
- [ ] [Tests pass / command output / observable behavior]

> ⚠️ ASSUMPTION: [Any assumption made that the agent should validate]

---

### Task T-02: [Short title]
[same format]
```

---

## XX-phase-N.md

*(For plans split into sequential phases)*

```markdown
# Phase N: [Phase name]

> **TL;DR**: [What this phase accomplishes and why it's a separate phase from the others.]

## Phase goal
[The single outcome this phase delivers. Expressed as a checkable state.]

## Entry criteria
[What must be true before this phase begins. Usually: the previous phase is complete
and verified. List any additional setup or approval needed.]

- [ ] Phase [N-1] acceptance criteria all green
- [ ] [Other entry condition]

## Tasks

[Use the same task format from XX-tasks.md]

### Task P[N]-01: [Short title]
[...]

## Exit criteria
[What must be true before moving to the next phase. Usually mirrors the phase goal.]

- [ ] [Specific, verifiable condition]
- [ ] [Specific, verifiable condition]

## Rollback plan
[If this phase produces artifacts that affect production or state,
describe how to undo the phase's work.]
```

---

## XX-architecture.md

```markdown
# Architecture

> **TL;DR**: [The core design approach and the most important trade-off it makes.]

## Design approach
[The high-level approach: what pattern, what structure, what data flow.]

## Component diagram
[ASCII or Mermaid diagram showing the key components and how they connect.
Even a rough diagram beats a paragraph of prose for spatial relationships.]

```
[Client] → [API Gateway] → [Auth Service] → [User Service] → [PostgreSQL]
                        ↘ [Product Service] → [Redis Cache] → [Product DB]
```

## Key design decisions

### Decision 1: [Title]
**Context**: [Why this decision needed to be made]
**Options considered**: [The alternatives]
**Choice**: [What was decided]
**Rationale**: [Why this option over the others]
**Trade-offs**: [What we're giving up]

### Decision 2: [Title]
[same format]

## Data model
[If the plan involves data changes, describe the model here.
Include schema sketches, field types, indexes, constraints.]

## API contracts
[If the plan involves API changes, list the endpoints, request/response shapes,
and any versioning strategy.]

## Security considerations
[Authentication, authorization, input validation, secrets management,
anything with a security surface area.]

## Scalability notes
[Any known bottlenecks, sharding strategy, horizontal scaling approach.]
```

---

## XX-session-log.md

*(Grill-me sessions only)*

```markdown
# Session log

> **TL;DR**: [N] questions asked. [X] answered confidently, [Y] partial,
> [Z] gaps identified, [W] open decisions.

## How to read this log

| Icon | Meaning |
|---|---|
| ✅ | Answered confidently — no action needed |
| ⚠️ | Partial answer — see gap remediation |
| ❌ | Gap / misconception — see gap remediation |
| 🔶 | Open decision — see open decisions file |

---

## Q-01: [Question text]

**Answered by**: [Person / agent]
**Answer**: [Summarized answer]
**Outcome**: ✅ Confident
**Notes**: [Any useful context from the exchange]

---

## Q-02: [Question text]

**Answered by**: [Person / agent]
**Answer**: [Summarized answer]
**Outcome**: ❌ Gap — [brief description of the gap]
**Agreed position**: [What was concluded or deferred]
**→ Task**: G-03 in `03-gap-remediation.md`

---

## Q-03: [Question text]

**Answered by**: [Person / agent]
**Answer**: [Summarized answer]
**Outcome**: 🔶 Open decision
**Arguments for A**: [...]
**Arguments for B**: [...]
**→ Decision**: D-01 in `04-open-decisions.md`
```

---

## XX-gap-remediation.md

*(Grill-me sessions only)*

```markdown
# Gap remediation

> **TL;DR**: [N] gaps identified during the session. This file contains tasks
> to close each gap. Execute in priority order.

---

### Task G-01: [Short title]

**Gap source**: Q-[N] — [one line: what the question was]
**Gap type**: [Knowledge / Implementation / Documentation / Process]
**Priority**: [Critical / High / Medium]

**What's missing**:
[Describe the gap concretely. What should be true that isn't?]

**What to do**:
1. [Step]
2. [Step]

**Done when**:
- [ ] [Verifiable outcome]
```

---

## XX-open-decisions.md

```markdown
# Open decisions

> **TL;DR**: [N] decisions need to be made before/during execution.
> [X] are blocking (execution can't start without them), [Y] are non-blocking.

---

### Decision D-01: [Title]

**Status**: 🔴 Blocking — must decide before Task [T-N]
**Context**: [Why this decision exists. What the tension is.]
**Options**:

**Option A: [Name]**
- How it works: [...]
- Pros: [...]
- Cons: [...]
- Best when: [...]

**Option B: [Name]**
- How it works: [...]
- Pros: [...]
- Cons: [...]
- Best when: [...]

**Recommendation**: [If the session produced a leaning, state it. Otherwise "No consensus."]
**Decision owner**: [Who should make the call]
**Decide by**: [Date or milestone]

---

### Decision D-02: [Title]

**Status**: 🟡 Non-blocking — can proceed with [Option A] as default, revisit later
[same format]
```

---

## XX-spikes.md

```markdown
# Spikes (research tasks)

> **TL;DR**: [N] research tasks to resolve uncertainty before or during implementation.
> [X] are blocking (results needed before implementation begins).

Spikes are time-boxed investigations. They produce a conclusion document, not production code.

---

### Spike S-01: [Title]

**Question to answer**: [The specific question this spike answers]
**Blocking**: [Yes / No] — [which tasks depend on the answer]
**Time box**: [Max hours to spend before making a decision with available info]

**What to investigate**:
1. [Specific thing to test or research]
2. [Specific thing to test or research]

**Output expected**:
[What the spike must produce — a benchmark result, a proof-of-concept, a
documented finding — so "we spent 3 hours and didn't conclude anything" isn't acceptable]

**Possible outcomes and implications**:
- If [outcome A]: proceed with [approach X] (see Task T-N)
- If [outcome B]: fall back to [approach Y], revisit requirements
```

---

## XX-testing.md

```markdown
# Testing

> **TL;DR**: [What this testing plan covers and the main risk it guards against.]

## Test strategy

[Choose the appropriate level(s) and explain why:]
- **Unit tests**: [What to test at unit level and why]
- **Integration tests**: [What to test at integration level]
- **End-to-end tests**: [What user journeys to cover]
- **Manual verification**: [What requires human eyes and why]
- **Load/performance tests**: [If applicable]

## Test cases

### Unit: [Component or function name]

```[language]
// Test: [what it verifies]
describe('[unit]', () => {
  it('[should do X when Y]', () => {
    // setup
    // act
    // assert
  });
});
```

**What to cover**:
- Happy path: [...]
- Edge case: [...]
- Error case: [...]

### Integration: [Scenario name]
[Describe the integration test scenario: what services/components interact,
what input triggers it, what outcome to assert.]

### Manual checklist
Steps a human should verify in staging before shipping:
- [ ] [Step: action → expected result]
- [ ] [Step: action → expected result]

## Regression risks
[What existing behavior might break? How to detect it?]

## Test environment setup
[Any setup the agent needs before running tests: seeds, environment variables,
mock server configuration, test database reset.]
```

---

## XX-rollout.md

```markdown
# Rollout

> **TL;DR**: [What this rollout does, its risk level, and the main precaution taken.]

## Pre-deploy checklist
- [ ] All task acceptance criteria are green
- [ ] All tests pass in CI
- [ ] [Environment variable / secret] added to production config
- [ ] [Feature flag] created and defaulted to [off/on]
- [ ] Rollback plan reviewed by [role]
- [ ] [Other precondition]

## Deploy steps

1. **[Step name]**: [Concrete command or action]
   ```bash
   [command if applicable]
   ```
2. **[Step name]**: [...]

## Post-deploy verification
Within [timeframe] of deploy, verify:
- [ ] [Observable: log message / metric / user-facing behavior]
- [ ] [Observable]
- [ ] Error rate in Datadog < [threshold]

## Rollback procedure
If anything is wrong, rollback by:
1. [Concrete rollback step]
2. [Concrete rollback step]

**Rollback takes**: [estimated time]
**Rollback removes**: [what functionality is lost during rollback]
**Safe to rollback until**: [e.g., "24 hours after deploy, before migration step 3 runs"]

## Feature flag strategy
[If using a flag:]
- Flag name: `[flag-name]`
- Initial state: OFF
- Gradual rollout: [1% → 10% → 50% → 100% over N days]
- Kill switch: [how to disable immediately if something goes wrong]
```

---

## XX-parking-lot.md

```markdown
# Parking lot

Ideas from the session that are worth revisiting but are out of scope for this plan.
Captured so they aren't lost.

---

## [Idea title]

**Raised during**: [casual session / grill-me question / aside in review]
**Description**: [What the idea is]
**Why out of scope now**: [Time / dependency / priority]
**Why worth keeping**: [The value it would deliver]
**Rough effort**: [S / M / L / unknown]
**Suggested next step**: [Add to backlog / schedule a spike / revisit in Q[N]]
```
