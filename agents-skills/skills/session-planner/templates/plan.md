# Plan: [Feature / Topic name]

**Project**: [project-name]
**Session type**: [Review / Grill-me / Casual / Mixed]
**Session date**: [YYYY-MM-DD]
**Plan created**: [YYYY-MM-DD]
**Status**: Ready for execution

---

## Summary

[One paragraph: what happened in the session and what this plan accomplishes.
Written for someone who wasn't in the session — enough context to understand
what the work is and why it matters, without needing to read the full details.]

---

## Current state

[Where things stand RIGHT NOW, before any work begins. Be specific.
Name the files, services, and behaviors. This is what the executing agent inherits.]

---

## Goal state

[What "done" looks like. Describe the system as it will behave AFTER the plan
is executed. Observable, concrete. Not "improved code quality" — what specifically
will be true that isn't true now.]

---

## Scope

### In scope
- [What is included]
- [What is included]

### Out of scope
- [What is explicitly excluded and why]
- [What is explicitly excluded and why]

---

## Constraints

[Non-negotiables the executing agent must respect:]

| Constraint | Details |
|---|---|
| [Performance] | [e.g., p95 latency must stay under 200ms] |
| [Compatibility] | [e.g., must maintain backwards compatibility with API v2] |
| [Deadline] | [e.g., must be merged before 2025-10-01] |
| [Dependencies] | [e.g., blocked on PR #847 merging first] |

---

## Key decisions

[Decisions made during the session. Document what was decided and why,
so the agent doesn't re-litigate them.]

| Decision | What was decided | Rationale |
|---|---|---|
| [Topic] | [Choice made] | [Why this option] |
| [Topic] | [Choice made] | [Why this option] |

---

## Risk register

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| [Risk description] | Low/Med/High | Low/Med/High | [How to mitigate] |
| [Risk description] | Low/Med/High | Low/Med/High | [How to mitigate] |

---

## Execution order

[The recommended sequence for executing the plan-details files.
Note which steps can be parallelized and which are strictly sequential.]

```
01-context.md          (read first — orientation)
↓
02-requirements.md     (understand the goal)
↓
03-[main tasks]        (implement — sequential)
↓
04-[more tasks]        (implement — can parallelize with 05)
05-[other tasks]       ↗
↓
06-testing.md          (validate all changes)
↓
07-rollout.md          (deploy — only after testing passes)
```

---

## File index

| File | Description |
|---|---|
| [plan-details/01-context.md](plan-details/01-context.md) | Background, current state, system overview |
| [plan-details/02-requirements.md](plan-details/02-requirements.md) | What must be true when done |
| [plan-details/03-tasks.md](plan-details/03-tasks.md) | Implementation tasks |
| [plan-details/04-testing.md](plan-details/04-testing.md) | Test strategy and test cases |
| [plan-details/05-rollout.md](plan-details/05-rollout.md) | Deployment and release steps |

---

## Definition of done

The plan is complete when ALL of the following are true:

- [ ] [Specific, checkable condition]
- [ ] [Specific, checkable condition]
- [ ] [Specific, checkable condition]
- [ ] All tests pass in CI
- [ ] Post-deploy verification checklist complete (see rollout file)
- [ ] No P0/P1 errors in Datadog for 30 minutes after deploy

---

## Open questions / flagged assumptions

[Items that need human input before or during execution:]

> ⚠️ **ASSUMPTION**: [What was assumed and what to validate]

> ❓ **OPEN**: [Question that needs an answer — who should answer it]
