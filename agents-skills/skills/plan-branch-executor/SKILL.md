---
name: plan-branch-executor
description: >
  Executes a session-planner plan using a structured git branch + merge request review
  workflow. Use this skill whenever a user says "execute the plan with review",
  "execute the plan with branches", "execute the plan with PR workflow",
  "execute the plan with MR workflow", "branch-based execution", "PR-based execution",
  "MR-based execution", "execute with draft PR", "execute with draft MR",
  "I want to review before implementation", "execute one task at a time with review",
  or any phrasing that combines plan execution with a git review loop. Also triggers
  when the user points to a plan.md and mentions wanting to review proposals before code
  is written. This skill is distinct from plan-executor: it does NOT write any
  implementation code without a human-approved proposal first. Every task goes through
  a two-phase loop — propose (TODO comments + draft MR) → implement (real code + ready MR)
  — with the human reviewing between each phase.
---

# Plan Branch Executor

Executes a session-planner plan one task at a time using a git branch and merge request
review workflow. No implementation code is written until the human has reviewed and
approved a proposal of what will be changed.

**The core principle**: Show your plan before you execute it. Every task starts with a
proposal — `// TODO:` comments that describe intent without changing behavior — reviewed
by the human via a draft MR. Only after approval does the agent write real code.

**What makes this different from `plan-executor`**: Instead of executing tasks directly,
each task goes through two phases: a proposal review loop and an implementation review
loop. The human is in control at every gate.

---

## Reference files — read on demand

| File | When to read |
|---|---|
| `references/loading-strategy.md` | Step 1 — before reading any plan files |
| `references/preflight.md` | Step 2 — before any git or execution work begins |
| `references/git-setup.md` | Step 3 — when setting up the plan branch |
| `references/proposal-protocol.md` | Step 4a — when doing the TODO annotation pass |
| `references/review-protocol.md` | Step 4c and 4f — when checking MR comments |
| `references/implementation-protocol.md` | Step 4e — when writing real code |
| `references/status-reporting.md` | Any time you send a progress update to the user |
| `references/blocker-protocol.md` | When execution hits an assumption, decision, or failure |

---

## Step 0 — Locate the plan

**Read `references/loading-strategy.md` now**, before touching any files.

Then find the plan root:

1. **User gave a path** → use it directly. Verify `plan.md` exists at that path.
2. **User mentioned project + feature** → look for `/{project-name}/{feature-name}/plan.md`
3. **Resuming a previous session** → ask which plan: "Which plan should I pick up?
   Give me the path or the project/feature name."
4. **No context at all** → ask once: "What's the path to the plan you'd like me to run?
   (e.g., `/payments-api/stripe-refactor/plan.md`)"

Confirm the plan exists before proceeding. If the path doesn't resolve, say so and stop.

---

## Step 1 — Orient: read plan.md only

Load `plan.md` and build a working model. Do NOT load any `plan-details/` files yet.

Extract and hold in working memory:
- **Project + feature name** (for branch naming and file path lookups)
- **Session type** (review / grill-me / casual / mixed)
- **Goal state** — what done looks like
- **Scope** — in and out of scope
- **Constraints** — non-negotiables
- **Key decisions** — already made; do not re-litigate
- **Execution order** — the sequence of tasks
- **File index** — the list of `plan-details/` files and their purpose
- **Definition of done** — the checklist to run at the end

After loading, announce your orientation to the user using the status format from
`references/status-reporting.md`. Keep it short — one paragraph. Example:

> **Plan loaded**: `payments-api / stripe-webhook-refactor`
> 5 tasks across 2 phases. Goal: replace the legacy webhook handler with idempotent
> processing and proper signature verification. Running pre-flight and git setup next.

---

## Step 2 — Pre-flight: surface everything uncertain before touching any branch

**Read `references/preflight.md` now.**

Scan every `plan-details/` file listed in the execution order and collect:
- Every `⚠️ ASSUMPTION:` block
- Every `❓ OPEN:` block
- Every `[TBD: ...]` placeholder
- Every `Decision D-XX` marked as 🔴 Blocking in `open-decisions.md` (if it exists)

Also collect git-specific unknowns (see `references/preflight.md` for the full list):
- Target repository and remote name
- Base branch for the plan branch (usually `main` or `develop`)
- MR platform (GitHub / GitLab / Bitbucket / other)
- Naming conventions if specified in the plan

Present all findings before doing anything. Wait for resolution of all hard blockers.

---

## Step 3 — Git setup: create the plan branch

**Read `references/git-setup.md` now.**

Once pre-flight is clear, create the plan branch. This branch is the shared target for
all task MRs in this plan. It is created once and lives for the entire plan.

```
git checkout <base-branch>
git pull origin <base-branch>
git checkout -b plan/<feature-name>
git push -u origin plan/<feature-name>
```

Where `<feature-name>` is derived from the plan's directory name (e.g., `stripe-webhook-refactor`).

Announce the setup:

> **Git setup complete**
> Plan branch: `plan/stripe-webhook-refactor` (branched from `main`)
> All task branches will merge into this plan branch, not directly into `main`.
> Starting Task T-01 now.

---

## Step 4 — Task loop: one task at a time

Load one task detail file at a time (see `references/loading-strategy.md`). For each task,
run all four sub-steps below in order. Do not skip any sub-step.

---

### 4a — Create the task branch

From the plan branch, create a task-scoped branch:

```
git checkout plan/<feature-name>
git pull origin plan/<feature-name>
git checkout -b task/<task-id>-<short-description>
```

Where `<task-id>` is the task identifier from the plan (e.g., `T-01`) and
`<short-description>` is 3–5 kebab-case words from the task title (e.g., `add-idempotency-keys`).

Full example: `task/T-01-add-idempotency-keys`

Brief the user:

> `▶ T-01: Add idempotency keys — starting proposal pass on branch task/T-01-add-idempotency-keys`

---

### 4b — Proposal pass: annotate with TODO comments

**Read `references/proposal-protocol.md` now.**

Go through every file that this task will touch. For each location where code will be
added, changed, or deleted:

- **Add**: Insert a `// TODO [T-01]: Add <function/block name> — <explanation of what and why>`
  comment at the exact line where the new code will go.
- **Change**: Insert a `// TODO [T-01]: Change <what> — <explanation of what the change is and why>`
  comment directly above the code that will be modified. Do not modify the existing code yet.
- **Delete**: Insert a `// TODO [T-01]: Remove <what> — <explanation of why it is being removed>`
  comment directly above the code that will be deleted. Do not delete it yet.

For new files that will be created, create the file with only TODO comments describing
its structure and purpose — no functional code.

Every TODO comment must explain the **why**, not just the **what**.
See `references/proposal-protocol.md` for detailed format and examples.

---

### 4c — Push and create draft MR

Commit and push the TODO-only changes:

```
git add .
git commit -m "proposal(T-01): annotate changes for <task title>"
git push -u origin task/T-01-add-idempotency-keys
```

Create a **draft** pull request / merge request:
- **From**: `task/T-01-add-idempotency-keys`
- **Into**: `plan/<feature-name>` (NOT into `main` or `develop`)
- **Title**: `[PROPOSAL] T-01: <task title>`
- **Body**: The task's summary from the plan, plus a clear note: "This MR contains
  only TODO annotation comments. No functional code has been changed. Please review
  the proposed change locations and approach before approving implementation."

Report to the user using the status format from `references/status-reporting.md`:

```
📋 T-01 proposal ready for review

Branch: task/T-01-add-idempotency-keys
Draft MR: [PROPOSAL] T-01: Add idempotency keys → plan/stripe-webhook-refactor
URL: <MR URL if available>

Review the diff — it shows exactly where and what will change, with explanations.
Comment directly on the MR for anything you want moved, removed, or explained differently.

Reply here when you've finished reviewing.
```

**Stop here.** Wait for the user to say they have finished reviewing. Do not proceed
to the next sub-step until the user explicitly returns to this chat session.

---

### 4d — Process the proposal review

When the user says they have finished reviewing, **read `references/review-protocol.md` now.**

Check the MR for comments. Classify each comment as:

- 🔴 **Change needed** — the user wants something different (location, approach, scope)
- 🟡 **Question** — the user is asking for clarification (answer in the MR, no change needed)
- ✅ **Positive** — approval, acknowledgment, or "looks good" feedback

**If there are 🔴 change-needed comments:**

1. Make the requested adjustments to the TODO comments (and only the TODO comments —
   still no implementation code).
2. Push the updates:
   ```
   git add .
   git commit -m "proposal(T-01): revise per review — <summary of changes>"
   git push
   ```
3. Report the revisions to the user and ask them to re-review:

   ```
   📋 T-01 proposal revised

   Changes made per your review:
   - Moved the idempotency key TODO from `handler.ts:42` to `middleware.ts:18`
   - Removed the TODO for caching layer (you noted it's out of scope)

   Updated MR: <URL>
   Reply here when you've finished reviewing the revision.
   ```

   Return to Step 4c (wait for user). This loop repeats until all 🔴 comments are resolved.

**If there are no 🔴 comments (only 🟡 or ✅, or no comments at all):**

Announce approval and move directly to implementation:

```
✅ T-01 proposal approved — moving to implementation
```

Proceed to Step 4e.

---

### 4e — Implementation pass: write the real code

**Read `references/implementation-protocol.md` now.**

Working on the same task branch (`task/T-01-add-idempotency-keys`):

1. Remove each `// TODO [T-01]:` comment.
2. Replace it with the actual implementation described in that comment.
3. For new files, replace the TODO structure with real code.
4. For deletions, remove the lines marked for removal (and their TODO comment).

Follow the task steps from the plan detail file precisely — the TODO comments were
your blueprint. The implementation should match exactly what the TODO comments described.
If you need to deviate from what the TODOs said, flag it as a blocker (see
`references/blocker-protocol.md`) before deviating.

After writing all code, verify the task's "Done when" criteria one by one, explicitly.
Do not skip this. A task is not done until every criterion is confirmed, not just attempted.

---

### 4f — Push and update MR to ready

Commit and push the implementation:

```
git add .
git commit -m "feat(T-01): implement idempotency keys"
git push
```

Update the MR:
- Change the title from `[PROPOSAL] T-01: ...` to `T-01: <task title>`
- Change status from **Draft** to **Ready for Review** (or equivalent on your platform)
- Update the body: "Implementation complete. All TODO comments have been replaced with
  working code. See the proposal MR comments for the reviewed intent behind each change."

Report to the user:

```
🔧 T-01 implementation complete — MR ready for review

Branch: task/T-01-add-idempotency-keys
MR: T-01: Add idempotency keys → plan/stripe-webhook-refactor (ready, not draft)
URL: <MR URL if available>

Done when (verified):
- [x] createUser with duplicate event_id returns 200 ✅ tested
- [x] Redis key created with 24h TTL ✅ confirmed via Redis CLI

Review the implementation diff. When you're satisfied, merge the MR and reply here.
```

**Stop here.** Wait for the user to confirm the MR has been merged (or to leave
implementation review comments).

---

### 4g — Process the implementation review

When the user returns:

**If the user left implementation comments (🔴 change-needed):**

1. Make the requested code changes on the same task branch.
2. Push the fixes.
3. Report back and ask the user to re-review:

   ```
   🔧 T-01 implementation revised

   Changes per your review:
   - Extracted idempotency logic into `IdempotencyService` (moved from inline)
   - Added error boundary for Redis connection failures

   MR updated. Reply when merged.
   ```

   This loop repeats until the user merges.

**If the user says the MR is merged:**

Proceed to Step 4h.

---

### 4h — Post-merge: sync and advance

After the task MR is merged into the plan branch:

```
git checkout plan/<feature-name>
git pull origin plan/<feature-name>
```

Report the completion and announce the next task:

```
✅ T-01 merged and synced

plan/stripe-webhook-refactor is up to date.
Moving to T-02: Add webhook signature verification.
```

Loop back to Step 4a with the next task.

---

## Step 5 — Run the definition of done

After all tasks are merged into the plan branch, load the definition of done from
`plan.md` and work through every checkbox explicitly:

```
## Definition of done

- [x] Webhook signature verification added — confirmed, tested in T-02
- [x] Idempotency key stored in Redis — confirmed, integration test passed
- [ ] ⚠️ Post-deploy monitoring alert — SKIPPED (out of scope, flagged in pre-flight)
- [x] All tests pass in CI — confirmed green on plan branch
```

If any item is unresolved, flag it and ask the user how to handle it before
declaring the plan complete.

---

## Step 6 — Close out

Write a brief completion summary (format from `references/status-reporting.md`) covering:
- What was accomplished
- Any tasks skipped and why
- Any proposal revisions made (so the user knows where the plan evolved)
- Any assumptions that were used
- The plan branch status: "Plan branch `plan/stripe-webhook-refactor` contains all
  completed tasks and is ready to be merged into `main` (or reviewed before merging)."

Optionally annotate `plan.md` with a completion note at the top:

```markdown
> ✅ **Executed** (branch workflow): [date] — All tasks complete. Skipped: [list].
> Plan branch: `plan/stripe-webhook-refactor`. Ready to merge into `main`.
```

---

## Efficiency rules — always active

1. **Load lazily** — One detail file at a time. Do not load ahead.

2. **Decisions stay decided** — The plan's "Key decisions" section is final. Do not
   re-open or suggest alternatives to decisions already made.

3. **Assumptions stay visible** — Any assumption you proceed on must be stated in your
   next user-facing message. Never silently assume.

4. **Proposals are a contract** — What the TODO comments describe is what the
   implementation must do. If the implementation needs to diverge from the proposal,
   flag it as a blocker before diverging — do not silently change the approach.

5. **Never implement before approval** — The proposal phase gate is mandatory. Under no
   circumstances write functional code before the user has reviewed the TODO-comment draft
   MR and returned to confirm (or until all 🔴 comments are resolved).

6. **One task at a time** — Do not start Task T-02's proposal pass until T-01 is fully
   merged. Task branches must be sequential to avoid cross-task merge conflicts.

7. **Never skip "done when"** — Every task has exit criteria. Check every one, explicitly,
   after the implementation pass. A task is not done until its criteria are verified.

8. **Respect out-of-scope** — If the user asks to do something the plan marks as out of
   scope, pause: "The plan scopes this out — want me to add it, or keep it deferred?"
   Do not silently expand scope.

9. **MR targets are fixed** — Task branches always merge into the plan branch, never
   directly into `main`. The plan branch merges into `main` only after all tasks complete
   and the user decides to land it.
