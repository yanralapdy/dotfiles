---
name: refactoring
description: Safe refactoring patterns for any codebase. Use when improving existing code without changing behavior.
---

# Refactoring

## Rules
- Tests must exist before refactoring — if they don't, write them first
- One refactoring at a time — don't mix refactoring with feature changes
- Run tests after each step, not just at the end
- Commit working state before starting

## Universal Patterns

### Fat handler → service/use-case
Move business logic out of request handlers (controllers, route handlers, resolvers) into dedicated service modules.

### Repeated logic → shared abstraction
Extract duplicated code into a function, module, or utility only when used 3+ times.

### Nested conditionals → early return
```
// Before: deeply nested
if (a) { if (b) { if (c) { doThing() } } }

// After: guard clauses
if (!a) return
if (!b) return
if (!c) return
doThing()
```

### Inline logic → named function
If a block of code needs a comment to explain what it does, extract it into a well-named function instead.

### Prop/parameter drilling → shared state or context
If data passes through 3+ layers untouched, consider a shared state mechanism appropriate to the stack.

### Large file → smaller modules
Split when a file exceeds ~300 lines or has multiple distinct responsibilities.

## What NOT to Refactor
- Working code with no tests (too risky without coverage)
- Code about to be deleted
- Code you don't fully understand yet
- Code that's "ugly but correct" during a time crunch

## Process
1. Identify the smell (duplication, long method, feature envy, etc.)
2. Ensure test coverage exists for the affected code
3. Apply one transformation
4. Run tests
5. Commit
6. Repeat
