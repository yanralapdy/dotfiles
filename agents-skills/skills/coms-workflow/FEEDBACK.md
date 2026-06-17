# Feedback File Format

Structured communication channel between tester and builder when a task fails. One file per task, updated in-place by both agents.

## Location

```
~/brain-dump/coms-prompts/<project>/<feature>/feedback-<TASK-ID>.md
```

Examples:
- `~/brain-dump/coms-prompts/satis/feedback-june-2026/feedback-T-01.md`
- `~/brain-dump/coms-prompts/prosper/api-v2/feedback-T-03.md`

## Naming rules

- **Prefix**: `feedback-` — groups feedback files together in directory listings
- **Task ID**: `T-XX` — matches the plan's task identifier
- **One file per task**: Don't version (`feedback-T-01-v2.md`). Append to the same file
- **Created by**: Tester (on first failure)
- **Updated by**: Both agents as the loop progresses

## Template

```markdown
# Feedback: T-XX — [Task Description]

**Status**: open
**Created**: YYYY-MM-DD HH:MM
**Last updated**: YYYY-MM-DD HH:MM

## Issue

[Describe what failed — be specific, include expected vs actual behavior]

### Steps to reproduce

1. [Step 1]
2. [Step 2]
3. [Step 3]

### Expected behavior

[What should happen according to the plan/requirements]

### Actual behavior

[What actually happens]

### Evidence

- Screenshot: [path or description]
- Console error: [if applicable]
- Network response: [if applicable]

### Environment

- URL: [e.g., http://localhost:3000/login]
- Browser: [e.g., Chrome via browser-harness]
- Task: T-XX

## Fix

*(Filled by builder after applying the fix)*

**Date**: YYYY-MM-DD HH:MM
**Status**: resolved

### Changes made

- **File**: `path/to/file.tsx`
  - [What changed and why]
- **File**: `path/to/another/file.ts`
  - [What changed and why]

### Builder verification

- [x] `[build command]` passes
- [x] [Manual check 1]
- [x] [Manual check 2]

## Verification

*(Filled by tester after re-testing)*

**Date**: YYYY-MM-DD HH:MM

- [ ] Issue resolved
- [ ] No regressions introduced
- [ ] Related test cases still pass

**Notes**: [Any observations during re-test]

**Final status**: [resolved / needs further work]
```

## Lifecycle

```
┌──────────┐     ┌───────────┐     ┌──────────┐
│  open    │ ──→ │ resolved  │ ──→ │  closed  │
│ (tester) │     │ (builder) │     │ (tester) │
└──────────┘     └───────────┘     └──────────┘
      ↑                                  │
      │         ┌───────────┐            │
      └─────────│ re-opened │←───────────┘ (if re-test fails or
                │ (tester)  │              regression found)
                └───────────┘
```

| State | Set by | Meaning | Next action |
|-------|--------|---------|-------------|
| `open` | Tester | Issue reported, with steps to reproduce | Builder reads and fixes |
| `resolved` | Builder | Fix applied, `## Fix` filled | Tester re-tests |
| `closed` | Tester | Re-test passed, `## Verification` confirmed | Loop complete |
| `open` (again) | Tester | Re-test failed or regression found | Builder reads appended updates and re-fixes |

## Guidelines

### For the tester

- **Be specific**: "Eye icon hidden behind password text on 20+ char passwords" — not "toggle broken"
- **Include reproduction steps**: Builder must be able to trigger the bug
- **Capture evidence**: Screenshots, console errors, network responses
- **Append, don't replace**: If re-test finds issues, append to `## Issue` — don't overwrite history
- **Don't create for out-of-scope items**: Check the plan's "Out of scope" section first

### For the builder

- **Read the whole file before fixing**: `## Issue` may have been appended after multiple re-tests
- **Be specific in `## Fix`**: "Added `pr-10` to Input className" — not "fixed the overlap"
- **List every file changed**: Tester uses this to know what to regression-test
- **Verify yourself before marking resolved**: Run build command + manual sanity check
- **Update status promptly**: Don't leave files in `open` state after fixing

## Escalation

After **3 iterations** (open → resolved → open → resolved → open):

```
Tester sends coms_send:
"T-XX failed 3 iterations. Feedback: feedback-T-XX.md
Human review needed before continuing."
```

Builder should also escalate if unable to reproduce/understand after 2 attempts.
