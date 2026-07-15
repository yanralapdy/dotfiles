# Blocker Protocol

What to do when execution can't proceed — cleanly, without data loss, and with the
human fully informed.

**The rule: a clear pause is always better than a silent workaround.**

Adapted from `plan-executor/references/blocker-protocol.md` with additions for
git and MR-specific blockers.

---

## What counts as a blocker

### Plan blockers (same as plan-executor)
| Blocker type | Examples |
|---|---|
| **Missing file** | A file the plan references doesn't exist on disk |
| **Failed command** | A command returned an error or unexpected output |
| **Unsatisfied precondition** | A task's precondition isn't met |
| **Unresolved TBD** | A `[TBD]` that should've been resolved in pre-flight |
| **Unresolved decision** | An `❓ OPEN` that blocks this specific task |
| **Contradicting state** | Current system state doesn't match what the plan assumes |
| **Scope expansion** | User asks to do something the plan marks as out of scope |
| **Missing credential/secret** | An env var or credential needed by a task |

### Git and MR blockers (new in this skill)
| Blocker type | Examples |
|---|---|
| **Branch already exists** | `feature/<feature>` or `task/T-XX-...` already exists remotely |
| **Push rejected** | Remote rejects the push (protected branch, fork required, no access) |
| **Dirty working tree** | Uncommitted changes exist before a branch switch |
| **Plan branch behind** | Plan branch is behind `main` in a way that causes conflicts |
| **MR creation fails** | CLI or API error when creating the draft MR |
| **MR not found** | Can't locate the MR to update it (wrong number, wrong platform) |
| **Implementation scope wider than proposal** | Code change requires touching a file not in the approved TODO set |
| **Proposal-to-implementation mismatch** | The approved TODO described approach X but implementation reveals approach Y is needed |

---

## Blocker severity

### 🔴 Hard blocker — execution must stop

```
🛑 Hard blocker — T-02 proposal cannot proceed

**What happened**: `git push -u origin task/T-02-add-signature-verification` was
rejected. The remote reports: "remote: error: GH006: Protected branch update not allowed."

**Impact**: Cannot push the proposal branch. Cannot create the draft MR.
T-02 and all subsequent tasks are blocked until this is resolved.

**Options**:
[A] Push to a fork and open a cross-fork PR (standard for protected repos)
[B] Request push access to the origin repo
[C] Use a different base remote (specify which)

→ What would you prefer?
```

### 🟡 Soft blocker — current step affected, others can continue

```
⚠️ Soft blocker — T-03 implementation scope wider than proposed

**What happened**: Implementing the signature verifier requires changes to
`src/types/webhook.ts` — this file was not included in the approved proposal TODOs.

**Impact**: T-03 implementation is paused at this step. The change is small (adding
one type definition) but wasn't reviewed in the proposal.

**Options**:
[A] Add the type definition now as a minor unreviewed addition (low risk — it's a type)
[B] Add a quick TODO comment to `src/types/webhook.ts`, push it as a proposal amendment,
    and ask for a quick approval before continuing implementation
[C] Inline the type in the implementation file to avoid touching `src/types/`

→ My recommendation: [A] — a type definition is not logic and changes nothing functional.
```

### ⚪ Advisory — noting a deviation, not stopping

```
ℹ️ Advisory — T-01 commit message format differs from plan

The plan's conventions section specifies `feat/<scope>:` format but the existing
git log uses `[FEAT] <scope>:` format. I'll match the existing log format for consistency.
This has no functional impact.
```

---

## How to present a blocker

Always include:
1. **What happened** — specific error, missing thing, or conflict (not a vague summary)
2. **Impact** — which tasks or steps are blocked and what the downstream effect is
3. **Options** — 2–3 concrete paths forward
4. **Your recommendation** — optional but helpful

Blockers are not failures — they're checkpoints. Frame them that way.

---

## After the human resolves a blocker

1. Acknowledge: "Got it — going with [A]."
2. Update working memory with the resolution.
3. Note it for the final summary.
4. Resume from the blocked step (not from the beginning of the task).

---

## When the user ignores a hard blocker

If the user says "just skip it and move on":

1. Accept the direction.
2. Mark the task as `⏭️ Skipped at user direction`.
3. Note which downstream tasks may be affected.
4. Add it to the final summary.
5. Continue with the next non-dependent task.

Do not argue. Do not re-raise the blocker. Flag it once, accept direction, document it.

---

## Scope expansion blockers

When the user asks for something the plan marks as out of scope:

```
🔶 Scope check — this wasn't in the plan

You've asked me to [action]. The plan explicitly marks this as out of scope:
> "Out of scope: adding rate limiting (deferred to Q4)"

**Options**:
[A] Add it now (I'll add a proposal pass for it and treat it as a new task)
[B] Add it to the parking lot for a future session
[C] Keep it strictly out of scope and continue

→ What would you prefer?
```

If [A]: create a new task entry, run the full proposal → review → implementation loop
for it before continuing to the next planned task.

---

## Rollback blockers (implementation failed after pushing)

If an implementation commit is pushed but the task later fails (CI failure, test failure,
implementation error discovered):

```
🛑 T-03 implementation failed after push

**What failed**: CI pipeline failed on `task/T-03-migrate-legacy-handler`.
Error: `TypeError: Cannot read property 'id' of undefined` in `src/webhooks/handler.ts:82`

**Changes already on the remote branch**:
- `src/webhooks/handler.ts` — modified (lines 78–95)
- `src/webhooks/signature.ts` — new file created

**Options**:
[A] Fix the error, push an additional commit to the task branch, and update the MR
[B] Revert the task branch to the last good commit and restart implementation
[C] Investigate and diagnose first before deciding

→ My recommendation: [A] — the fix is likely small.
```

Never force-push a task branch without explicitly confirming it with the user, as it
rewrites history that may already be under review.
