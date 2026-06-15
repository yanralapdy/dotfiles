# Review Session — Planning Guide

A review session produces a plan by turning identified issues, suggestions, and decisions
from a code/design/architecture review into actionable, sequenced work.

---

## What to extract from a review session

### Issues and findings
Categorize everything surfaced:

| Category | Examples |
|---|---|
| **Critical** | Security holes, data loss risks, correctness bugs, broken contracts |
| **High** | Performance problems, architectural violations, missing error handling |
| **Medium** | Code quality, test coverage gaps, missing documentation |
| **Low** | Style inconsistencies, naming, minor refactors |

For each finding, capture:
- **Location** — file path, function name, line range if mentioned
- **What's wrong** — the specific problem, not a vague label
- **Why it matters** — impact if left unfixed
- **Suggested fix** — how to address it (even if approximate)
- **Effort estimate** — S/M/L or hours if mentioned

### Patterns and systemic issues
Sometimes multiple findings point to the same root cause. Group these:
- "Five functions missing input validation" → add a shared validation layer
- "Error handling inconsistent across three modules" → create an error-handling standard

Document patterns separately from individual findings — they often produce higher-leverage tasks.

### Approved vs tentative items
Some review comments are clear directives ("this must be fixed before merge"), others are
suggestions ("might be worth considering"). Flag this clearly in the plan so the agent knows
what's required vs optional.

---

## Plan structure for a review session

### `plan.md` additions for reviews
Add a **Findings Summary** section:
```markdown
## Findings summary
| Severity | Count | Resolved in plan |
|---|---|---|
| Critical | 2 | ✅ Tasks 3, 7 |
| High | 5 | ✅ Tasks 1, 2, 4, 5, 6 |
| Medium | 8 | ✅ Tasks 8–11, ⏳ Deferred: 12–15 |
| Low | 12 | ⏳ Separate cleanup PR |
```

### Recommended `plan-details/` structure for reviews

```
plan-details/
  01-context.md          ← what was reviewed, its role in the system
  02-findings.md         ← full findings catalog with severity and location
  03-critical-fixes.md   ← critical + high severity tasks, step-by-step
  04-medium-fixes.md     ← medium severity tasks
  05-refactors.md        ← systemic improvements, patterns, cleanup
  06-testing.md          ← how to verify each fix is correct
  07-rollout.md          ← if changes affect production behavior
```

For small reviews (< 10 findings), merge 03–05 into a single `03-tasks.md`.

---

## Task format for review findings

Each task in a findings file should follow this pattern:

```markdown
### Task R-03: Fix missing input validation in `createUser`

**Severity**: High
**Location**: `src/users/createUser.ts:47-89`
**Finding**: The function accepts `email` without format validation and `age` without
bounds checking. Invalid inputs propagate to the database layer, causing obscure constraint
errors rather than clear 400 responses.

**Fix**:
1. Import `validateEmail` from `src/utils/validators.ts`
2. Add at function entry: `if (!validateEmail(email)) throw new ValidationError(...)`
3. Add: `if (age < 0 || age > 150) throw new ValidationError(...)`
4. Add unit tests for both validation paths (see `06-testing.md`)

**Verify done when**: `createUser` called with `email="notanemail"` returns 400 with
`{ error: "Invalid email format" }`. `age=-1` returns 400 with `{ error: "Invalid age" }`.
```

---

## Review-specific open questions to resolve

Before finalizing the plan, check whether these were addressed in the session:
- Is there a target merge date or deadline?
- Are any fixes blocked on another PR/dependency?
- Does anything require a migration or data backfill?
- Were any findings explicitly deferred to a future sprint?
- Is there a test environment to verify against?
