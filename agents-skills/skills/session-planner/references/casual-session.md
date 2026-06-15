# Casual Session — Planning Guide

A casual session — brainstorm, exploratory chat, "let's think about this" discussion —
is the least structured input. The plan's job is to impose structure without losing
the insight that made the conversation valuable.

---

## What to extract from a casual session

### Ideas and proposals
Casual sessions generate more ideas than can or should be acted on. Classify each:

| Classification | Meaning |
|---|---|
| **Core idea** | The thing the session was fundamentally about |
| **Concrete proposal** | A specific, actionable thing to build or change |
| **Exploration** | Something interesting to investigate before committing |
| **Tangent** | Interesting but off-scope; park it |
| **Constraint surfaced** | A limitation or requirement that emerged |

For each concrete proposal, capture:
- What exactly is being proposed
- The problem it solves (the "why")
- Any rough design or approach mentioned
- Concerns or counter-arguments raised
- Whether there was agreement to proceed

### Decisions vs. directions
Casual sessions often produce "directional" agreement rather than firm decisions.
Be precise in the plan:

- **Decision**: "We agreed to use Postgres, not MySQL" → document as decided
- **Direction**: "We're leaning toward a microservices approach" → document as direction
  + flag that it needs a firmer decision before implementation begins
- **Exploration needed**: "We're not sure if the latency will be acceptable" → document
  as a spike/research task

### The core hypothesis
Most good brainstorms orbit a hypothesis. Extract it:
> "If we [change X], we expect [outcome Y] because [reason Z]."

The plan should validate this hypothesis — or at least structure the work so the
hypothesis is tested early before committing to the full build.

---

## Plan structure for a casual session

### The translation challenge
Casual sessions are inherently ambiguous. The plan must resolve ambiguity, not preserve it.
Anywhere the conversation was vague, the plan makes a concrete interpretation and flags it
as an assumption. The agent can then validate or override.

Mark assumptions explicitly:
```markdown
> ⚠️ ASSUMPTION: The session mentioned "cache the results" without specifying scope.
> This plan assumes Redis with a 5-minute TTL on the `/search` endpoint.
> Validate with the team before implementing.
```

### `plan.md` additions for casual sessions
Add a **Core Hypothesis** section near the top:

```markdown
## Core hypothesis
> If we refactor the onboarding flow to use a wizard pattern (replacing the current
> single long form), we expect a 20%+ reduction in drop-off at step 3, because users
> are overwhelmed by seeing all fields at once.
>
> **Validation**: A/B test in staging. Proceed to production only if drop-off improves.
```

### Recommended `plan-details/` structure for casual sessions

```
plan-details/
  01-context.md            ← current state and why the session happened
  02-hypothesis.md         ← the core idea and how it will be validated
  03-requirements.md       ← what needs to be built (derived from the discussion)
  04-design.md             ← approach, architecture, key design decisions
  05-tasks.md              ← concrete implementation steps
  06-spikes.md             ← research/exploration tasks (if any ambiguity to resolve first)
  07-testing.md            ← how to validate success
  08-parking-lot.md        ← good ideas from the session that are out of scope for now
```

Omit `06-spikes.md` if there's nothing uncertain enough to warrant investigation.
Always include `08-parking-lot.md` — casual sessions generate side ideas that should
be captured, not lost.

---

## Parking lot format (`08-parking-lot.md`)

```markdown
# Parking lot

Ideas from the session that are worth revisiting but are out of scope for this plan.

---

## Idea: Global search across all entities

**Raised by**: Discussion about improving discoverability
**Why out of scope**: Requires Elasticsearch integration; too large for this sprint.
**Why it's worth keeping**: Several users have complained about not being able to find
old orders. High-leverage UX improvement.
**Suggested next step**: Add to Q3 roadmap discussion.

---

## Idea: Dark mode

**Raised by**: Mentioned in passing
**Why out of scope**: Design system doesn't support theming yet.
**Why it's worth keeping**: Low effort once theming is in place.
**Suggested next step**: Add to design system backlog.
```

---

## Casual session–specific open questions

- Was there a clear decision to proceed, or is the plan contingent on approval?
- Who needs to be consulted or sign off before work begins?
- What's the appetite for risk — is this a prototype, an experiment, or production work?
- Are there dependencies on other teams or systems?
- What's the rough timeline or priority relative to other work?
