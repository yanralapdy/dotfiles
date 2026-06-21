# Blocker Protocol

What to do when execution can't proceed — cleanly, without data loss, and with the
human fully informed.

The rule: **a clear pause is always better than a silent workaround.**

---

## What counts as a blocker

| Blocker type | Examples |
|---|---|
| **Missing file** | A file the plan references doesn't exist on disk |
| **Failed command** | A command returned an error or unexpected output |
| **Unsatisfied precondition** | A task's precondition isn't met (dependency not done) |
| **Unresolved TBD** | A `[TBD]` placeholder that should've been resolved in pre-flight |
| **Unresolved decision** | An `❓ OPEN` that blocks this specific task |
| **Contradicting state** | The current system state doesn't match what the plan assumes |
| **Scope expansion request** | The user asks to do something the plan marks as out of scope |
| **Explicit error** | Any error output where the plan expected success |
| **Missing credential/secret** | An environment variable or credential needed by a task |

---

## Blocker severity

### 🔴 Hard blocker — execution must stop
Use when: the current task cannot complete, and the next tasks depend on it.

```
🛑 Hard blocker — T-04 cannot proceed

**What happened**: The plan references `src/webhooks/signature.ts` but the file
doesn't exist. Task T-04 Step 2 requires editing this file.

**Impact**: T-04, T-05, and the testing phase all depend on this file existing.

**Options**:
[A] Create `signature.ts` now with the skeleton from the plan's code sketch
[B] Locate the file (it may have been renamed — check `src/webhooks/`)
[C] Skip T-04 and explain why in the final summary

→ What would you like me to do?
```

### 🟡 Soft blocker — current task affected, but others can continue
Use when: one task can't complete but it doesn't block the rest of the execution order.

```
⚠️ Soft blocker — T-03 exit criterion unverifiable

**What happened**: T-03 requires verifying against the staging database, but
I don't have the staging DB connection string.

**Impact**: T-03 is functionally complete but unverified. T-04 and T-05 don't
depend on T-03's verification — they can proceed.

**Proposed path**: Mark T-03 as ⚠️ Unverified, continue to T-04, and add
"verify T-03 against staging" to the follow-up checklist.

→ OK to proceed this way?
```

### ⚪ Advisory — noting a deviation, not stopping
Use when: something differs from the plan but execution can safely continue.

```
ℹ️ Advisory — T-02 output differs cosmetically from plan

Expected log: `✅ Migration applied: 0023_add_webhook_table`
Actual log:   `[INFO] 2025-09-15T10:42:00Z migration:0023 applied`

The message format differs (newer logging library), but the migration applied
successfully. All functional "done when" criteria are met. Continuing to T-03.
```

---

## How to present a blocker

Always include:
1. **What happened** — the specific error, missing thing, or conflict (not a vague summary)
2. **Impact** — which tasks are blocked and what the downstream effect is
3. **Options** — 2–3 concrete paths forward (don't leave the human with nothing to choose from)
4. **Your recommendation** — optional, but helpful: "I'd suggest [A] because..."

Blockers are not failures — they're checkpoints. Frame them that way.

---

## After the human resolves a blocker

1. Acknowledge the resolution explicitly: "Got it — going with [A]."
2. Update your working model with the resolution
3. Note it in the running execution log (you'll include it in the final summary)
4. Resume execution from the blocked task (not from the beginning of the phase)

---

## When the user ignores a hard blocker

If the user says "just skip it and move on" for a 🔴 hard blocker:

1. Accept the direction — it's their plan
2. Mark the task as `⏭️ Skipped at user direction`
3. Note which downstream tasks may be affected by the skip
4. Add it to the final summary's "items requiring follow-up" list
5. Continue with the next non-dependent task

Do not argue. Do not re-raise the blocker. Flag it once, accept the direction, document it.

---

## When a blocker cascade occurs

If resolving one blocker reveals another (e.g., finding the missing file shows it has
syntax errors), present the new blocker using the same format. Do not try to chain-resolve
multiple blockers in a single message — surface them one at a time.

---

## Scope expansion blockers

When the user asks to do something the plan marks as out of scope:

```
🔶 Scope check — this wasn't in the plan

You've asked me to [action]. The plan explicitly marks this as out of scope:
> "Out of scope: adding rate limiting (deferred to Q4)"

**Options**:
[A] Add it now (I'll need to estimate effort and adjust the plan)
[B] Add it to the parking lot for a future session
[C] Keep it strictly out of scope and continue

→ What would you prefer?
```

If the user says "add it now", get a brief spec from them and treat it as a new task
appended to the current phase. Do not absorb it silently.

---

## Rollback blockers

If a task fails after making changes that need to be undone:

1. **Stop immediately** — do not continue to the next step
2. Check `plan.md` or `NN-rollout.md` for a rollback procedure
3. If a rollback procedure exists, present it and ask for confirmation before running it
4. If no rollback procedure exists, list what was changed and ask the user how to revert

```
🛑 Task T-05 failed after partial changes were made

**Changes applied before failure**:
- Migration 0024 was applied ✅
- `WEBHOOK_SECRET` env var was set in staging ✅
- `webhooks/handler.ts` line 47 was modified ✅

**Failed at**: Deploying to staging — exit code 1, "build failed"

**Rollback options** (from `07-rollout.md`):
> Roll back migration: `npm run migrate:rollback -- --env staging`
> Revert code: `git checkout HEAD webhooks/handler.ts`

→ Should I run the rollback procedure, or would you like to investigate first?
```
