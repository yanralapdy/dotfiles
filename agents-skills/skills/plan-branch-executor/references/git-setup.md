# Git Setup

How to initialize and maintain the branch structure for a plan-branch-executor session.

---

## Branch hierarchy

Every plan-branch-executor session uses a two-level branch hierarchy:

```
main (or develop)
  └── plan/<feature-name>          ← one per plan, lives for the entire session
        ├── task/T-01-<slug>       ← one per task, merged into plan branch when done
        ├── task/T-02-<slug>       ← created fresh only after T-01 is merged
        └── task/T-03-<slug>       ← and so on
```

**Why this hierarchy?**
- The plan branch accumulates completed task work so each new task branch starts with
  a clean, up-to-date base that includes prior tasks.
- Task branches merge into the plan branch (not `main`) keeping `main` untouched until
  the human explicitly decides to land the whole plan.
- The plan branch itself is a single reviewable unit — the entire feature — that can
  be merged into `main` or deleted if the plan is abandoned.

---

## Naming conventions

### Plan branch
```
plan/<feature-name>
```
- `<feature-name>` comes from the plan directory name, in kebab-case.
- Example: if the plan is at `/payments-api/stripe-webhook-refactor/plan.md`,
  the branch name is `plan/stripe-webhook-refactor`.
- If the plan directory name is ambiguous or generic (e.g., `refactor/`), use the
  project name prefix: `plan/payments-api-refactor`.

### Task branch
```
task/<task-id>-<short-slug>
```
- `<task-id>` is the task identifier from the plan (e.g., `T-01`, `T-02`).
- `<short-slug>` is 3–5 kebab-case words from the task title.
- Keep the slug short: describe what the task does, not why.
- Examples:
  - `task/T-01-add-idempotency-keys`
  - `task/T-02-add-signature-verification`
  - `task/T-03-migrate-legacy-handler`

---

## Setting up the plan branch (Step 3)

Run this sequence exactly. Do not skip the pull — the base branch may have received
commits since pre-flight began.

```bash
# 1. Switch to the base branch (from pre-flight: usually main or develop)
git checkout <base-branch>

# 2. Pull latest — ensures the plan branch starts from the current tip
git pull origin <base-branch>

# 3. Create and switch to the plan branch
git checkout -b plan/<feature-name>

# 4. Push to remote and set upstream
git push -u origin plan/<feature-name>
```

If any step fails, invoke `blocker-protocol.md` — do not attempt workarounds.

**Expected outcome**: `plan/<feature-name>` exists on both local and remote.
The branch tip matches `<base-branch>` at the time of setup.

---

## Creating a task branch (Step 4a)

Run this sequence at the start of every task:

```bash
# 1. Switch to the plan branch
git checkout plan/<feature-name>

# 2. Pull latest — picks up any previous task merges
git pull origin plan/<feature-name>

# 3. Create and switch to the task branch
git checkout -b task/<task-id>-<short-slug>

# 4. Push to remote and set upstream
git push -u origin task/<task-id>-<short-slug>
```

**Why pull before branching?** If T-01 was just merged into the plan branch, T-02's
branch must start from that updated tip. Skipping the pull means T-02's branch diverges
from the plan branch immediately, causing unnecessary merge conflicts.

---

## Creating the draft MR

After the proposal pass (Step 4c), create a draft MR with these exact settings:

| Field | Value |
|---|---|
| **Source branch** | `task/<task-id>-<short-slug>` |
| **Target branch** | `plan/<feature-name>` |
| **Title** | `[PROPOSAL] <task-id>: <task title>` |
| **Status** | Draft / Work in Progress |
| **Description** | See proposal-protocol.md for the body template |

**Platform-specific instructions:**

*GitHub*: Use `gh pr create --draft --base plan/<feature-name> --head task/T-01-... --title "[PROPOSAL] T-01: ..."` or create via the GitHub UI. Check the "Create as draft" option.

*GitLab*: Use `glab mr create --draft --target-branch plan/<feature-name> --source-branch task/T-01-...` or prefix the title with `Draft:` in the UI.

*Bitbucket*: Create via the UI; mark the PR as "work in progress" if the platform supports it.

If the platform isn't known, ask the user once: "What platform is this repo on?
(GitHub / GitLab / Bitbucket / other) — I'll create the MR correctly for your platform."

---

## Updating the MR after implementation (Step 4f)

After the implementation pass:

1. Update the MR title: remove `[PROPOSAL]` prefix → `T-01: <task title>`
2. Change status from Draft/WIP to **Ready for Review** (mark as ready)
3. Update the MR description to indicate implementation is complete

*GitHub*: Use the "Ready for review" button on the PR page, or:
`gh pr ready <PR-number>`

*GitLab*: Remove the `Draft:` prefix from the title, or click "Mark as ready"

---

## Handling a dirty working tree

If `git status` shows uncommitted changes before a branch switch:

1. Stop and check: are these from a previous step that wasn't committed?
2. If yes: commit or stash before switching branches.
3. If the origin is unclear: invoke `blocker-protocol.md`.

Never use `git checkout -f` or `git reset --hard` without flagging it to the user first.
These commands discard work and cannot be undone easily.

---

## If the base branch changes mid-plan

If `main` (or `develop`) receives significant commits while the plan is in progress,
the plan branch may need to be rebased or merged. Do not do this automatically.

Flag it to the user:

```
⚠️ The base branch has received commits since we started.

The plan branch (plan/stripe-webhook-refactor) may be behind main.
Options:
[A] Merge main → plan branch now (safer, preserves history)
[B] Rebase plan branch onto main (cleaner history, more risk)
[C] Continue without syncing (acceptable if the changes don't overlap)

→ What would you prefer?
```

---

## Branch cleanup at the end

After the plan is complete (Step 6), the task branches are no longer needed.
The plan branch itself should be merged into `main` by the human (the agent does not do this).

Optionally suggest cleanup:

```
The following task branches can be deleted after the plan branch lands in main:
- task/T-01-add-idempotency-keys
- task/T-02-add-signature-verification
- task/T-03-migrate-legacy-handler

The plan branch (plan/stripe-webhook-refactor) should be merged into main via a PR/MR
reviewed by your team, then deleted.
```
