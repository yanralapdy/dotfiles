# Loading Strategy

How to read plan files efficiently — without flooding context or loading things you won't use.

Identical to the `plan-executor` loading strategy. Reproduced here so this skill is
self-contained and doesn't depend on the other skill's files.

---

## The three-pass model

### Pass 1: Orientation (plan.md only)
**Goal**: Build a working model of the whole plan without loading any details.
**What to read**: `plan.md` — the full file.
**What to extract**: Goal state, scope, constraints, execution order, file index,
definition of done, key decisions.
**What NOT to do**: Do not open any `plan-details/` file yet.

### Pass 2: Pre-flight scan (all detail files, shallow)
**Goal**: Find every assumption, open decision, TBD, and blocker across the entire plan.
**What to read**: Every `plan-details/` file listed in the execution order — but only
enough to find flag markers (`⚠️ ASSUMPTION`, `❓ OPEN`, `[TBD`, `🔴 Blocking`).
**What NOT to do**: Do not execute any tasks during this pass. Do not deeply parse
task steps or "done when" criteria.

### Pass 3: Execution (one file at a time, deep)
**Goal**: Execute the proposal and implementation passes for one task.
**What to read**: The single detail file for the current task.
**What NOT to do**: Do not load the next task file until the current task is fully
merged and the plan branch is synced.

---

## File loading order

Always follow the execution order specified in `plan.md`. Never reorder it.
If the execution order is missing, derive it from file numbering:
`01-context.md` → `02-requirements.md` → `03-...` → `NN-testing.md` → `NN-rollout.md`

Always load `NN-testing.md` before `NN-rollout.md`. Never rollout without testing.

---

## Context management during deep reads

When reading a large `plan-details/` file (> 200 lines):

1. Read the **TL;DR** at the top first.
2. Read the **execution order / dependency table** — note task sequence.
3. Read the current task fully before starting the proposal pass for that task.
4. After the task is merged, treat its content as resolved — you don't need it again
   unless a later task references something from it.

---

## When a referenced file is missing

If a file listed in the execution order doesn't exist on disk:

1. Note it as a blocker (see `blocker-protocol.md`)
2. Check whether `plan.md` lists it as optional
3. If required: pause, tell the user, ask how to proceed
4. If clearly optional (e.g., `parking-lot.md`): skip and note in final summary

---

## When the plan has no `plan-details/` directory

Some minimal plans put everything in `plan.md`:

1. Read the full `plan.md`
2. Skip Pass 2 (no files to scan)
3. Execute tasks directly from `plan.md`, one at a time
4. The definition-of-done section at the bottom of `plan.md` is your exit check

---

## Handling `.plan-meta.json`

If a `.plan-meta.json` file exists at the plan root, read it during Pass 1:

```json
{
  "execution_order": ["plan-details/03-...", "plan-details/04-..."],
  "blockers": ["Waiting on PR #902 to merge before Task T-04"]
}
```

If `execution_order` is present, use it — it takes priority over the order in `plan.md`.

---

## Resuming a partial execution

If picking up a plan mid-way:

1. Ask: "How far did we get? Which tasks are already merged?"
2. Or scan `plan.md` for tasks marked `[x]` or `✅ Complete`.
3. Check the git state: does the plan branch exist? Is it ahead of the last merged task?
4. Adjust: start from the first incomplete task.
5. Still run pre-flight on remaining tasks — don't skip it.
6. Announce the resume point:
   > Resuming from T-03. T-01 and T-02 are merged into `feature/stripe-webhook-refactor`.
   > Pulling plan branch and creating `task/T-03-...` now.
