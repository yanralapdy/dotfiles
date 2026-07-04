# Feedback Files

Structured communication artifacts between agents when something needs fixing. Two flavors — pick by role, not by taste.

## Two flavors

| Flavor        | Filename                          | One file per         | Created by     | Best fit for              |
|---------------|-----------------------------------|----------------------|----------------|---------------------------|
| Task-scoped   | `feedback-<TASK-ID>.md`           | plan task            | Tester         | Per-task PASS/FAIL loop   |
| Issue-scoped  | `feedback-<role>-<NN>.md`         | distinct concern     | Reviewer, scanners, deployer-fails | Cross-cutting or specialist review |

**Task-scoped example:** `feedback-T-03.md` — tester rejects task T-03, builder fixes, tester re-tests, file evolves in place.

**Issue-scoped example:** `feedback-security-02.md` — the second finding from the security scanner across the whole feature; unrelated to any single task.

Both variants live in the same directory as the agent prompts: `~/brain-dump/coms-prompts/<project>/<feature>/`.

## Choosing the flavor

- **Task-scoped** when the concern maps 1:1 to a plan task. The task is the unit of work; the feedback tracks it.
- **Issue-scoped** when the concern spans modules, doesn't map to a single task, or comes from a whole-system pass.
- **Never mix.** One task cannot have two files. One issue cannot span two files.

## Task-scoped template

Full lifecycle: `open` (tester) → `resolved` (builder) → `closed` (tester). Re-open on regression.

```markdown
# Feedback: T-XX — [Task Description]

**Status**: open
**Created**: YYYY-MM-DD HH:MM
**Last updated**: YYYY-MM-DD HH:MM
**Iteration**: 1 of 3

## Issue

[What failed — expected vs actual. Be specific.]

### Steps to reproduce
1. [Step]
2. [Step]

### Expected
[From plan/requirements]

### Actual
[Observed behavior]

### Evidence
- Screenshot: [path or omit]
- Console error: [text or omit]
- Test output: [snippet or omit]

### Environment
- URL / entry point:
- Browser / runtime:
- Task: T-XX

## Fix

*(Builder fills after applying)*

**Date**: YYYY-MM-DD HH:MM
**Status**: resolved

### Changes made
- **File**: `path/to/file`
  - [What changed and why — specific: "added `pr-10` to Input className", not "fixed overlap"]

### Builder verification
- [x] Build command passes
- [x] [Manual check]

## Verification

*(Tester fills after re-test)*

**Date**: YYYY-MM-DD HH:MM

- [ ] Issue resolved
- [ ] No regressions
- [ ] Related test cases still pass

**Notes**: [Re-test observations]

**Final status**: closed / re-opened
```

**Re-opening a task-scoped file**: append a new `## Issue` section (dated), bump `Iteration`, set Status back to `open`. Never overwrite prior `## Issue` blocks — history matters.

## Issue-scoped template

One file per distinct concern. Severity is mandatory. No re-open — either the fix works or a fresh issue file is opened.

```markdown
# Feedback: <ROLE>-<NN> — [Issue Title]

**Status**: open
**Created**: YYYY-MM-DD HH:MM
**Last updated**: YYYY-MM-DD HH:MM
**Iteration**: 1 of 3
**Severity**: Critical | High | Medium | Low
**Review area**: <e.g., Architecture / Security / Performance / Deploy>
**Modules affected**: <comma-separated>

## Issue

[Specific problem, quoting or referencing code.]

### Current state
[The problematic code or design.]

### Why it matters
[Concrete risk. For security: attack scenario. For perf: measured or estimated impact. For architecture: coupling cost.]

### Recommendation
[Specific fix. Include code sketch if it clarifies.]

## Fix

*(Builder fills after applying)*

**Date**: YYYY-MM-DD HH:MM
**Status**: resolved

### Changes made
- **File**: `path/to/file`
  - [Specific change]

### Builder verification
- [x] Build passes
- [x] [Manual sanity check tied to the issue]

## Verification

*(Reviewer / scanner fills after re-check)*

**Date**: YYYY-MM-DD HH:MM

- [ ] Issue resolved
- [ ] No new issues introduced
- [ ] Related area still clean

**Notes**: [Re-review observations]

**Final status**: closed / needs further work
```

## Severity guide (issue-scoped only)

| Level    | Meaning                                                    | Examples                                                | Must fix? |
|----------|-----------------------------------------------------------|---------------------------------------------------------|-----------|
| Critical | Blocks shipping. Data loss, crash, security breach.        | SQL injection, orphan subprocesses, corrupted data      | Yes, immediate |
| High     | Major gap or risk.                                         | Auth token leaked to logs, missing nil-guard causing silent failure | Yes |
| Medium   | Design smell that will hurt later.                         | Tight coupling, missing extension point, N+1 in a warm path | Yes for v1 |
| Low      | Nitpick or future improvement.                             | Variable naming, minor DRY, comment gaps                | Optional; note it |

Every issue-scoped file must include one severity. Task-scoped files inherit "must fix before task closes" and don't need severity.

## Lifecycle diagram

```
Task-scoped:
   open ─(builder fix)─▶ resolved ─(tester ok)─▶ closed
     ▲                                              │
     └────────── re-opened (regression) ────────────┘

Issue-scoped:
   open ─(builder fix)─▶ resolved ─(reviewer ok)─▶ closed
     │
     └──── after 3 iterations ────▶ escalation
```

Both variants cap at **3 iterations** before mandatory human escalation (see [PROTOCOL.md](PROTOCOL.md#escalation-to-human)).

## Guidelines shared across flavors

**For the reporter (tester / reviewer / scanner):**

- Specificity wins. "Eye icon hidden behind text for passwords >20 chars" beats "toggle broken."
- Evidence beats opinion. Screenshot, error log, or measured number.
- Append on re-test failure. Never overwrite.
- Skip out-of-scope items — check the plan's parking lot / out-of-scope section first.

**For the fixer (builder):**

- Read the whole file — later iterations append; don't miss context.
- Name every file changed in `## Fix`. The reporter uses this list to know what to regression-test.
- Verify yourself before marking `resolved`. Build command + a manual sanity check.
- Update `Status` and `Last updated` promptly. Stale `open` files break the state machine.

## What NOT to do

- **Don't version filenames.** `feedback-T-03-v2.md` breaks the state machine. Use the existing file.
- **Don't bundle unrelated issues.** One concern per issue-scoped file. Two security findings = two files.
- **Don't skip severity** on issue-scoped files. Missing severity = the fix priority is undefined.
- **Don't file feedback for out-of-scope work.** Flag it via a `message` to the human instead.
