---
name: tdd
description: Test-driven development with red-green-refactor loop. Use when user wants TDD, says "red-green-refactor", wants test-first development, or asks to build a feature with tests.
---

# Test-Driven Development

## Philosophy

Tests verify behavior through public interfaces, not implementation details. A good test survives internal refactors because it doesn't care about structure.

**Good tests**: exercise real code paths through public APIs. Read like specifications.
**Bad tests**: mock internal collaborators, test private methods, break when you refactor but behavior hasn't changed.

## Anti-Pattern: Horizontal Slices

**DO NOT write all tests first, then all implementation.**

This produces crap tests — tests written in bulk test imagined behavior, not actual behavior.

```
WRONG (horizontal):
  RED: test1, test2, test3, test4, test5
  GREEN: impl1, impl2, impl3, impl4, impl5

RIGHT (vertical):
  RED→GREEN: test1→impl1
  RED→GREEN: test2→impl2
  RED→GREEN: test3→impl3
```

## Workflow

### 1. Plan
Before writing any code:
- Confirm with user what interface changes are needed
- Confirm which behaviors to test (you can't test everything — prioritize)
- List behaviors to test (not implementation steps)
- Get user approval on the plan

### 2. Tracer Bullet
Write ONE test that confirms ONE thing:
```
RED:   Write test for first behavior → test fails
GREEN: Write minimal code to pass → test passes
```

### 3. Incremental Loop
For each remaining behavior:
```
RED:   Write next test → fails
GREEN: Minimal code to pass → passes
```

Rules:
- One test at a time
- Only enough code to pass current test
- Don't anticipate future tests

### 4. Refactor
After all tests pass:
- Extract duplication
- Simplify interfaces
- Run tests after each refactor step
- **Never refactor while RED** — get to GREEN first

## Checklist Per Cycle
- [ ] Test describes behavior, not implementation
- [ ] Test uses public interface only
- [ ] Test would survive internal refactor
- [ ] Code is minimal for this test
- [ ] No speculative features added
