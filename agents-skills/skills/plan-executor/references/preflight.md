# Pre-flight Protocol

Surface and resolve every assumption, open decision, and placeholder in the plan
**before any execution begins**. A blocker discovered mid-task wastes far more time
than a pre-flight that takes two minutes.

---

## What to look for

Scan every `plan-details/` file for these exact markers:

| Marker | Source | Meaning |
|---|---|---|
| `⚠️ ASSUMPTION:` | Any file | Something assumed true — needs human confirmation |
| `❓ OPEN:` | Any file | An unresolved question — must be answered before that task runs |
| `[TBD: ...]` | Any file | A placeholder — must be filled in before that task runs |
| `🔴 Blocking` | `open-decisions.md` | A decision that blocks a specific task |
| `🟡 Non-blocking` | `open-decisions.md` | A decision with a default; can proceed but should be confirmed |
| `> ⚠️ ASSUMPTION` | Any task block | Assumption nested in a specific task |

Also check `plan.md` itself — the "Open questions / flagged assumptions" section at
the bottom often contains plan-level flags that affect everything.

---

## Severity classification

Classify each finding before presenting it to the user:

### 🔴 Hard blockers — execution cannot start until resolved
- A `🔴 Blocking` decision that gates a task in Phase 1
- A `[TBD]` in a task the execution order hits immediately
- A missing dependency or environment variable that all tasks need
- An `❓ OPEN` on the production credentials, target branch, or database

### 🟡 Soft blockers — can proceed with a stated default, but should surface
- A `⚠️ ASSUMPTION` where the assumption is reasonable but unconfirmed
- A `🟡 Non-blocking` decision where the plan provides a default option
- A `[TBD]` in a task that's later in the execution order (can resolve before we get there)

### ⚪ Informational — no user input needed, just note it
- Assumptions that are confirmed by something else in the plan (cross-referenced)
- Out-of-scope items flagged as deferred (not blocking)
- `parking-lot.md` ideas (they won't affect execution)

---

## How to present the pre-flight

Group by severity. Lead with hard blockers. Be direct — don't bury items in prose.

```
## Pre-flight check — 4 items found

### 🔴 Must resolve before starting

**1. Decision D-01: Redis vs in-memory store (blocks Task T-03)**
   The plan documents both options but didn't conclude.
   → Which should I use?
   [A] Redis (persistent, survives restarts, needs `REDIS_URL` env var)
   [B] In-memory Map (simpler, resets on deploy — acceptable for staging-only)

**2. [TBD] Staging URL — needed in Task T-04 testing step**
   → What is the staging environment URL?

---

### 🟡 I'll proceed with a default unless you say otherwise

**3. ⚠️ ASSUMPTION in T-02: branch cut from `main`, not `staging`**
   → Proceeding with `main`. Reply "use staging" if I should branch from there instead.

**4. ⚠️ ASSUMPTION in T-05: deployment uses `npm run deploy:prod`**
   → Proceeding with this command. Let me know if your deploy command differs.

---
Reply with your answers and I'll start execution.
```

---

## Handling responses

When the user responds:

1. Map each answer to its flag and record the resolution:
   - `D-01 → Redis (REDIS_URL=redis://staging:6379)`
   - `Staging URL → https://staging.payments.company.com`
   - `T-02 branch → confirmed main`
   - `T-05 deploy → confirmed`

2. Update your working model with each resolution. You'll reference them during execution.

3. If the user answers only some items, acknowledge what's resolved and ask again
   specifically about the remaining hard blockers. Do not let a hard blocker slide.

4. If the user says "just use your best judgment on all of these":
   - Proceed on hard blockers with the most conservative / least destructive option
   - State each choice explicitly in your first execution update
   - Flag them again in the final summary

---

## Pre-flight for resumed sessions

If resuming a partial execution, run pre-flight only on the *remaining* tasks.
Don't re-surface assumptions from phases already confirmed as complete.

But do re-check: if a previous session left any item as "TBD — will confirm later",
that item must be resolved now before the phase that needs it.

---

## When the plan has no flags at all

Some plans are complete and have no assumptions or open decisions. In that case:

```
## Pre-flight check — all clear ✅
No assumptions, open decisions, or placeholders found.
Ready to start execution. Going in.
```

Then proceed directly to Step 3 without waiting for user input.
