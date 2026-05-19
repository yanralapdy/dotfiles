---
name: prototype
description: Build a throwaway prototype to answer a design question. Use when user wants to prototype, sanity-check a data model, mock up a UI, explore design options, or says "prototype this".
---

# Prototype

A prototype is **throwaway code that answers a question**. The question decides the shape.

## Pick a Branch

Ask the user (or infer from context):

- **"Does this logic/state model feel right?"** → Build a tiny interactive script that pushes the state machine through hard-to-reason-about cases.
- **"What should this look like?"** → Generate several radically different UI variations, switchable via a param or toggle.

## Rules

1. **Throwaway and clearly marked.** Name it so anyone can see it's not production. Place it near the code it's prototyping.
2. **One command to run.** Use whatever the project's task runner supports.
3. **No persistence by default.** State lives in memory.
4. **Skip the polish.** No tests, no error handling beyond what makes it runnable, no abstractions.
5. **Surface the state.** After every action, print/render the full relevant state so the user sees what changed.
6. **Delete or absorb when done.** Don't leave it rotting in the repo.

## When Done

The answer is the only thing worth keeping. Capture it:
- What question was asked
- What the prototype revealed
- The decision made as a result

Then delete the prototype code.
