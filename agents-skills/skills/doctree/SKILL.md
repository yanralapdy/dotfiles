---
name: doctree
description: Set up and manage hierarchical documentation trees for projects. Use when initializing project docs, creating child DOC.md files, maintaining documentation hierarchy, or when user mentions DOCTREE or AGENTS.md structure.
---

# DOCTREE

Hierarchical documentation using AGENTS.md at root and DOC.md files for child scopes.

## Core Contract

- Root `AGENTS.md` is the project-wide binding contract
- `DOC.md` files are child scopes, linked tree-style to parent
- Work must stay understandable from nearest DOC.md + root AGENTS.md
- Closer docs control local details; no child may weaken DOCTREE

## Initialize DOCTREE

When setting up a project:

1. Create root `AGENTS.md` with:
   - Purpose (one sentence)
   - Stack
   - Commands
   - Conventions
   - `## Child DOCTREE Index` table

2. Scan for folders needing their own scope (≥3 source files, distinct rules)

3. Create `DOC.md` in those folders

## DOC.md Structure

```md
# [Name]

## Purpose
[What this folder does]

## Local Contracts
- [Specific rules for this scope]

## Work Guidance
- [How work should be done here]
```

## Update After Changes

When editing files:

1. **Read Before**: Follow root AGENTS.md → child DOC.md chain to target
2. **Update After**: If change affects contracts/rules, update nearest DOC.md or root

## Style

- Concise, current, operational
- No diary entries or stale notes
- Delete outdated text, don't explain history
