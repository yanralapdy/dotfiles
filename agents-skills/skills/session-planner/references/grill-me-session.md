# Grill-Me Session — Planning Guide

A grill-me session is adversarial by design — someone is being challenged on their work,
knowledge, or design choices. The plan captures what the grilling revealed: gaps to fill,
positions to defend or revise, and knowledge areas to strengthen.

---

## What to extract from a grill-me session

### Questions and responses — classify each

| Outcome | Meaning | Action |
|---|---|---|
| **Answered confidently** | Person knows this cold | No task needed (document as confirmed) |
| **Answered partially** | Some knowledge, some gaps | Task: deepen understanding, validate answer |
| **Stumbled / uncertain** | Gap identified | Task: learn, research, or decide |
| **Wrong / corrected** | Misconception | Task: fix the implementation or update the understanding |
| **Couldn't answer** | Blind spot | Task: research and document |
| **Deflected / deferred** | Conscious choice to not address | Flag for later, document why |

For each question, record:
- The question asked
- The answer given (summarized)
- The classification above
- Any follow-up challenge or pushback from the griller
- The final agreed-upon position (if resolution was reached)

### Themes and patterns
Group related questions into themes:
- Security considerations
- Scalability assumptions
- Error handling strategy
- Dependency choices
- Testing coverage
- Operational readiness

Themes that had multiple stumbles are high-priority plan areas.

### Unresolved debates
Sometimes a grill-me session doesn't produce a clear winner — two approaches are debated
without resolution. Document these as explicit decision points in the plan with the
arguments for each side laid out, so the agent (or team) can make a final call.

---

## Plan structure for a grill-me session

### `plan.md` additions for grill-me
Add a **Knowledge & Gap Summary** section:

```markdown
## Session summary
- **Questions asked**: 23
- **Confidently answered**: 14
- **Partial / uncertain**: 6
- **Gaps identified**: 3
- **Key decisions still open**: 2
```

### Recommended `plan-details/` structure for grill-me

```
plan-details/
  01-context.md           ← what was being grilled (feature, system, design)
  02-session-log.md       ← Q&A log with outcomes (see format below)
  03-gap-remediation.md   ← tasks to close knowledge/implementation gaps
  04-open-decisions.md    ← unresolved debates with arguments and decision process
  05-validation.md        ← how to prove the work is actually correct after gaps are closed
  06-knowledge-docs.md    ← documentation tasks (if the session revealed undocumented areas)
```

---

## Session log format (`02-session-log.md`)

```markdown
## Q-07: How does the service handle a database timeout during checkout?

**Asked by**: Reviewer
**Answer given**: Described a retry loop with 3 attempts, then 500 to client.
**Outcome**: ⚠️ Partial — retry logic exists but no dead-letter queue for failed orders.
**Agreed position**: Current retry is acceptable for now. Add DLQ in Q3 (see Task G-04).

---

## Q-12: Why was Redis chosen over Memcached?

**Asked by**: Reviewer
**Answer given**: Couldn't articulate specific reasons beyond "it's what we knew".
**Outcome**: ❌ Gap — decision was undocumented and not performance-tested.
**Agreed position**: Run a benchmark (see Task G-07). Document decision in ADR-012.
```

---

## Gap remediation task format (`03-gap-remediation.md`)

```markdown
### Task G-04: Implement dead-letter queue for failed checkout orders

**Gap identified**: Q-07 — Failed orders after 3 retries are silently dropped.
**Impact**: Revenue loss; no way to manually recover failed transactions.
**Priority**: High

**What to do**:
1. Create `failed_orders` queue in SQS (see infra/sqs.tf)
2. In `checkoutService.processOrder`, after final retry failure, publish to DLQ
3. Add CloudWatch alert for DLQ depth > 0
4. Create runbook: `docs/runbooks/failed-checkout-recovery.md`

**Done when**: Integration test simulates DB timeout, confirms message lands in DLQ,
alert fires in staging environment.
```

---

## Grill-me specific open questions

- Was the grilling against a spec/RFC/design doc? Link to it.
- Are there follow-up sessions planned?
- Were any items escalated to a wider team decision?
- What's the deadline for closing the identified gaps?
