# Loading Strategy

How to read plan files efficiently — without flooding context or loading things you won't use.

---

## The three-pass model

Plan files are read in three distinct passes, each with a different purpose.

### Pass 1: Orientation (plan.md only)
**Goal**: Build a working model of the whole plan without loading any details.
**What to read**: `plan.md` — the full file.
**What to extract**: Goal state, scope, constraints, execution order, file index,
definition of done, key decisions.
**What NOT to do**: Do not open any `plan-details/` file yet.
**Cost**: One file, always small.

### Pass 2: Pre-flight scan (all detail files, shallow)
**Goal**: Find every assumption, open decision, TBD, and blocker across the entire plan.
**What to read**: Every `plan-details/` file listed in the execution order — but only
enough to find the flag markers (`⚠️ ASSUMPTION`, `❓ OPEN`, `[TBD`, `🔴 Blocking`).
**Technique**: Read each file sequentially. Extract flagged blocks. Stop after the
last flag in each file — don't process task content yet.
**What NOT to do**: Do not execute any tasks during this pass. Do not deeply parse
task steps, code sketches, or "done when" criteria.
**Cost**: All files, but shallow. Fast.

### Pass 3: Execution (one file at a time, deep)
**Goal**: Execute the tasks in one phase/file.
**What to read**: The single detail file for the current phase.
**Technique**: Read the entire file. Follow every step. Check every exit criterion.
Discard context when the phase is complete; load the next file fresh.
**What NOT to do**: Do not load the next file until the current phase is complete
and the user has confirmed at the checkpoint.

---

## File loading order

Always follow the execution order specified in `plan.md`. Never reorder it.
The author sequenced files to respect dependencies — skipping or reordering
phases causes dependency violations.

If the execution order is missing from `plan.md`, derive it from file numbering:
`01-context.md` → `02-requirements.md` → `03-...` → ... → `NN-testing.md` → `NN-rollout.md`

Always load `NN-testing.md` before `NN-rollout.md`. Never rollout without testing.

---

## Context management during deep reads

When reading a large `plan-details/` file (> 200 lines), use this structure:

1. Read the **TL;DR** at the top — if present, this tells you what the file covers
2. Read the **execution order / dependency table** — if present, note task sequence
3. Read tasks one at a time in order — don't skip ahead
4. After completing a task, treat its steps as "resolved context" — you don't need
   to re-read them unless verifying exit criteria

---

## When a referenced file is missing

If a file listed in the execution order doesn't exist on disk:

1. Note it as a blocker (see `blocker-protocol.md`)
2. Check whether `plan.md` lists it as optional
3. If it's required: pause, tell the user, ask how to proceed
4. If it's clearly optional (e.g., `parking-lot.md` when no ideas were deferred):
   skip it silently and note the skip in the final summary

---

## When the plan has no `plan-details/` directory

Some minimal plans put everything in `plan.md`. If there are no detail files:

1. Read the full `plan.md`
2. Skip Pass 2 (no files to scan)
3. Execute tasks directly from `plan.md` using the same task-by-task protocol
4. The definition-of-done section at the bottom of `plan.md` is your exit check

---

## Handling `.plan-meta.json`

If a `.plan-meta.json` file exists at the plan root, read it during Pass 1 alongside
`plan.md`. It may override the execution order or list additional blockers:

```json
{
  "execution_order": ["plan-details/03-...", "plan-details/04-..."],
  "blockers": ["Waiting on PR #902 to merge before Task T-04"]
}
```

If `execution_order` is present in `.plan-meta.json`, use it — it takes priority over
the order in `plan.md`.

---

## Resuming a partial execution

If the user is picking up a plan mid-way through:

1. Ask: "How far did we get? Which tasks or phases are already complete?"
2. Or, if the plan has been annotated (e.g., tasks marked `[x]` or phases marked
   `✅ Complete`), scan for those markers during Pass 1.
3. Adjust the execution order: start from the first incomplete task.
4. Still run pre-flight on the *remaining* tasks — don't skip it for uncompleted phases.
5. Announce the resume point clearly:
   > Resuming from Phase 2, Task T-04. Phases 1 and 2 (T-01–T-03) are already complete.
