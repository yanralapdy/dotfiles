---
name: plan-executor
description: >
  Reads and executes plan files produced by the session-planner skill. Use this skill
  whenever a user says "execute the plan", "run the plan", "start working on the plan",
  "follow the plan", "implement the plan", "let's work through the plan", "pick up where
  we left off on the plan", "continue the plan", or points to a plan.md file or a
  plan-details/ directory. Also triggers when a user shares a file path ending in plan.md
  or mentions a project + feature combo that likely has a plan on disk. This skill handles
  ALL phases of plan-driven execution: loading, pre-flight resolution, task-by-task
  implementation, checkpoint confirmation, blocker escalation, and final sign-off.
  Always use this skill instead of ad-hoc file reading when a session-planner plan exists.
---

# Plan Executor

Reads plan files produced by `session-planner` and drives execution in a structured,
efficient, human-in-the-loop way — without dumping everything into context at once,
without skipping assumption checks, and without leaving the human confused about where
things stand.

**The core principle**: Work like a thoughtful senior developer handing tasks to a junior
one — give full context for the current task, confirm before advancing to the next, and
never silently push past a blocker.

---

## Reference files — read on demand

| File | When to read |
|---|---|
| `references/loading-strategy.md` | Step 1 — before reading any plan files |
| `references/preflight.md` | Step 2 — before executing any tasks |
| `references/execution-protocol.md` | Step 3 — when starting each task or phase |
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
- **Project + feature name** (for all file path lookups)
- **Session type** (review / grill-me / casual / mixed)
- **Goal state** — what done looks like
- **Scope** — in and out of scope
- **Constraints** — non-negotiables
- **Key decisions** — already made; do not re-litigate
- **Execution order** — which files to read and in what sequence
- **File index** — the list of `plan-details/` files and their purpose
- **Definition of done** — the checklist to run at the end

After loading, announce your orientation to the user using the status format from
`references/status-reporting.md`. Keep it short — one paragraph. Example:

> **Plan loaded**: `payments-api / stripe-webhook-refactor`
> 5 tasks across 2 phases. Goal: replace the legacy webhook handler with idempotent
> processing and proper signature verification. I'll start with a pre-flight check to
> surface any assumptions before we begin.

---

## Step 2 — Pre-flight: surface everything uncertain before touching code

Read `references/preflight.md` now.

Scan every `plan-details/` file listed in the execution order and collect:
- Every `⚠️ ASSUMPTION:` block
- Every `❓ OPEN:` block
- Every `[TBD: ...]` placeholder
- Every `Decision D-XX` marked as 🔴 Blocking in `open-decisions.md` (if it exists)

Do this scan quickly — read each file enough to extract the flags, don't deeply process
the task content yet.

Then present all findings to the user **before starting any work**:

```
## Pre-flight check

Found 3 items that need resolution before I start:

**⚠️ ASSUMPTION — Task T-02**
> Branch should be cut from `main`, not `staging`.
→ Can you confirm? (or I'll proceed with `main`)

**❓ OPEN — Decision D-01 (BLOCKING)**
> Redis vs in-memory cache for idempotency keys. Needed before Task T-03.
→ Which should I use?

**[TBD] — 04-testing.md**
> Staging environment URL not specified.
→ What's the staging URL? (or I can skip the staging verification step)
```

Wait for the user's responses. Update your working model with their answers.
Record resolutions as inline notes — you'll reference them during execution.

Do not proceed to Step 3 until all blocking items are resolved. Non-blocking items
can be documented as "proceeding with assumption X" and flagged in the final summary.

---

## Step 3 — Execute: one phase at a time

Read `references/execution-protocol.md` now.

Work through the execution order from `plan.md`. For each phase or task file:

### 3a. Load the file
Load only the current detail file into working context. Do not load ahead.

### 3b. Brief the user
Before doing any work, give a one-paragraph brief of what this phase covers and
what the user will see when it's done. This primes them to evaluate the output.

### 3c. Execute task by task
Follow the task steps precisely as written. The plan was written as instructions to a
junior developer — read them that way. If a step says "Add an index on `user_id` —
without it, this query will do a full table scan", follow the reasoning, not just the action.

For each task:
- Do the work
- Report the outcome (what was done, what the result was)
- Check the task's **"Done when"** criteria — explicitly confirm each one is satisfied
- If a criterion can't be satisfied, invoke `references/blocker-protocol.md`

### 3d. Phase boundary checkpoint
At the end of each phase (or after every 3–4 tasks for large phases), pause and
check in with the user using the checkpoint format from `references/status-reporting.md`.

**Never advance to the next phase without explicit confirmation** from the user.
The checkpoint message must:
- State what was completed in this phase
- State what comes next
- Ask for the go-ahead: "Ready to move to Phase 2 (database migration)?"

### 3e. Handle blockers immediately
If anything blocks execution mid-task (a file isn't where the plan says it is,
a command fails, a decision is needed), invoke `references/blocker-protocol.md`
immediately. Do not attempt workarounds without telling the user.

---

## Step 4 — Run the definition of done

After all phases complete, load the definition of done from `plan.md` and work through
every checkbox explicitly:

```
## Definition of done

- [x] Webhook signature verification added — confirmed, tested in Step 3c
- [x] Idempotency key stored in Redis — confirmed, integration test passed
- [ ] ⚠️ Post-deploy monitoring alert — SKIPPED (out of scope, flagged in pre-flight)
- [x] All tests pass in CI — confirmed green
```

If any item is unresolved, flag it clearly and ask the user how to handle it before
declaring the plan complete.

---

## Step 5 — Close out

Write a brief completion summary to the user (format: `references/status-reporting.md`)
covering:
- What was accomplished
- Any items skipped and why
- Any assumptions that were used (so the user can validate them)
- Any parking-lot items that surfaced (from `NN-parking-lot.md` if it exists)
- What a follow-up session would need to pick up

Optionally annotate `plan.md` with a completion note at the top:

```markdown
> ✅ **Executed**: [date] — All tasks complete. Skipped: [list]. See execution summary below.
```

---

## Efficiency rules — always active

These apply throughout the entire execution, at every step:

1. **Load lazily** — One detail file at a time. Discard it (stop referencing it) when
   the phase is complete and the next file is loaded.

2. **Decisions stay decided** — The plan's "Key decisions" section is final. Do not
   re-open, re-debate, or suggest alternatives to decisions already made. If something
   feels wrong, flag it as a blocker and ask — don't silently deviate.

3. **Assumptions stay visible** — Any assumption you proceed on must be stated in your
   next user-facing message. Never silently assume.

4. **One task at a time in chat** — Do not report five task completions in one message.
   Report task N, then wait for the next message before reporting task N+1. This keeps
   the human in the loop and able to intervene.

5. **Never skip "done when"** — Every task has exit criteria. Check every one, explicitly.
   A task is not done until its criteria are verified, not just attempted.

6. **Respect out-of-scope** — If the user asks to do something the plan explicitly marks
   as out of scope, pause and flag it: "The plan scopes this out — want me to add it,
   or keep it deferred?" Do not silently expand scope.
