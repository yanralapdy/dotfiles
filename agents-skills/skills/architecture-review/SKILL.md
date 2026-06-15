---
name: architecture-review
description: Find architectural friction and propose deepening opportunities — refactors that turn shallow modules into deep ones. Use when user wants to improve architecture, find refactoring opportunities, or make a codebase more maintainable.
---

# Architecture Review

Surface architectural friction and propose **deepening opportunities** — refactors that turn shallow modules into deep ones.

## Key Concepts

- **Deep module** — lots of functionality behind a simple interface (high leverage)
- **Shallow module** — interface nearly as complex as the implementation (low leverage)
- **Deletion test** — imagine deleting the module. If complexity vanishes, it was a pass-through. If complexity reappears across N callers, it was earning its keep.

## Process

### 1. Explore

Read the project's steering doc and any existing architecture docs first. Then explore organically and note friction:

- Where does understanding one concept require bouncing between many small modules?
- Where are modules shallow — interface nearly as complex as implementation?
- Where have pure functions been extracted just for testability, but real bugs hide in how they're called?
- Where do tightly-coupled modules leak across their boundaries?
- Which parts are untested or hard to test through their current interface?

Apply the deletion test to anything you suspect is shallow.

### 2. Present Candidates

Present a numbered list. For each:
- **Files** — which files/modules are involved
- **Problem** — why the current architecture causes friction
- **Solution** — plain English description of what would change
- **Benefits** — in terms of testability, maintainability, and reduced coupling

Do NOT propose interfaces yet. Ask: "Which of these would you like to explore?"

### 3. Grilling Loop

Once the user picks a candidate, drop into a grilling conversation:
- Walk the design tree: constraints, dependencies, shape of the deepened module
- What sits behind the boundary? What tests survive?
- If a decision is hard to reverse and surprising without context, offer an ADR

## When NOT to Suggest

- Working code with no tests (refactoring without coverage is reckless)
- Code about to be deleted
- Contradicts a documented decision without strong justification
