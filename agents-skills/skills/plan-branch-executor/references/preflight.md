# Pre-flight Protocol

Surface and resolve every assumption, open decision, placeholder, and git prerequisite
**before any branch is created or code is touched**. A blocker discovered mid-task
wastes far more time than a pre-flight that takes two minutes.

---

## Two categories of pre-flight items

### Category A — Plan content flags
Scan every `plan-details/` file for these markers:

| Marker | Source | Meaning |
|---|---|---|
| `⚠️ ASSUMPTION:` | Any file | Something assumed true — needs human confirmation |
| `❓ OPEN:` | Any file | An unresolved question — must be answered before that task runs |
| `[TBD: ...]` | Any file | A placeholder — must be filled in before that task runs |
| `🔴 Blocking` | `open-decisions.md` | A decision that blocks a specific task |
| `🟡 Non-blocking` | `open-decisions.md` | A decision with a default; can proceed but should be confirmed |

Also check `plan.md` itself — the "Open questions / flagged assumptions" section at
the bottom often contains plan-level flags that affect everything.

### Category B — Git prerequisites
These must be confirmed before the plan branch is created:

| Item | Why it matters |
|---|---|
| **Repository path** | Where to run git commands; must be the correct repo |
| **Base branch** | What to branch the plan branch from (usually `main` or `develop`) |
| **Remote name** | Usually `origin`; could differ in monorepos or fork setups |
| **MR platform** | GitHub / GitLab / Bitbucket — affects MR creation commands |
| **Draft MR support** | Some platforms don't support draft MRs; need a workaround |
| **Branch naming constraints** | Some teams/CIs have branch naming rules (e.g., must start with `feat/`) |
| **Protected branch rules** | Can the agent push directly, or is a fork required? |

If the plan already specifies any of these (e.g., "branch from `develop`"), confirm
from the plan and record them — no need to ask the user again.

If not specified, surface them in the pre-flight.

---

## Severity classification

### 🔴 Hard blockers — cannot start until resolved
- A `🔴 Blocking` decision that gates a task in Phase 1
- A `[TBD]` in a task the execution order hits immediately
- Unknown base branch (can't create plan branch without it)
- Unknown repository path (can't run any git commands without it)
- Protected branch rules that prevent the agent from pushing

### 🟡 Soft blockers — can proceed with a stated default
- A `⚠️ ASSUMPTION` where the assumption is reasonable but unconfirmed
- A `🟡 Non-blocking` decision with a default option in the plan
- Unknown MR platform (can ask later, just before first MR creation)
- Unknown branch naming constraints (can apply a standard and note it)

### ⚪ Informational — no user input needed
- Assumptions confirmed cross-referenced elsewhere in the plan
- Out-of-scope items flagged as deferred
- Parking-lot ideas

---

## How to present the pre-flight

Group by severity. Lead with hard blockers. Be direct.

```
## Pre-flight check — 5 items found

### 🔴 Must resolve before starting

**1. Base branch unknown**
   What branch should I create `plan/stripe-webhook-refactor` from?
   → [A] `main`   [B] `develop`   [C] Something else (specify)

**2. Decision D-01: Redis vs in-memory store (blocks Task T-03)**
   The plan documents both options but didn't conclude.
   → [A] Redis (needs REDIS_URL env var)   [B] In-memory Map (simpler, resets on deploy)

---

### 🟡 I'll proceed with a default unless you say otherwise

**3. ⚠️ ASSUMPTION — T-02: unit tests should be added in the same task**
   → Proceeding with: yes, tests in T-02. Reply "tests separate" if you want a dedicated task.

**4. MR platform not specified**
   → Assuming GitHub. Reply "GitLab" or "Bitbucket" if different.

**5. ⚠️ ASSUMPTION — Remote name is `origin`**
   → Proceeding with `origin`. Reply if your remote has a different name.

---
Reply with your answers and I'll create the plan branch.
```

---

## Handling responses

When the user responds:

1. Map each answer to its flag and record the resolution in working memory.
2. If the user answers only some items, acknowledge what's resolved and ask again
   about the remaining hard blockers. Do not let a hard blocker slide.
3. If the user says "use your best judgment on all of these":
   - Proceed on hard blockers with the most conservative option
   - State each choice explicitly in the git setup announcement
   - Flag them again in the final summary

---

## When the plan has no flags and git details are already known

```
## Pre-flight check — all clear ✅
No plan assumptions or open decisions found.
Git: branching from `main`, remote `origin`, platform GitHub.
Creating plan branch now.
```

Then proceed directly to Step 3 without waiting.

---

## Pre-flight for resumed sessions

If resuming a partial execution:
- Run pre-flight only on *remaining* tasks.
- Re-check git state: does the plan branch still exist? Is it up to date?
- Announce the resume point:

```
Resuming plan/stripe-webhook-refactor from T-03.
T-01 and T-02 are already merged into the plan branch.
Pulling latest plan branch before creating task/T-03 branch.
```
