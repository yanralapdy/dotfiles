---
name: session-planner
description: >
  Converts a session (review, grill-me, or casual discussion) into a thorough, agent-executable
  plan. Use this skill whenever a conversation, code review, interview, brainstorm, or informal
  chat needs to produce a structured action plan that another agent or person can execute without
  needing to re-read the session transcript. Triggers include: "create a plan from this session",
  "turn this review into a plan", "write up an execution plan", "make a plan from our discussion",
  "document what we talked about as tasks", "plan from grill-me", "plan from brainstorm", "plan
  this out", "I need a plan", "convert this to actionable steps", "write an implementation plan",
  or any situation where a discussion or review needs to be turned into structured, executable
  instructions for an agent. Always use this skill when the user has had a substantial conversation
  and wants to capture its output as a plan — even if they just say "plan this" or "plan it out".
---

# Session Planner

Converts any session — review, grill-me, or casual — into a thorough, agent-ready execution
plan with clean directory structure and deep implementation detail.

The output must be so complete that a fresh agent, reading only the plan files, can execute the
work without asking follow-up questions. Every ambiguity should be resolved in the plan. Every
decision should be documented with its rationale.

---

## Step 0 — Read the right reference files first

Before doing anything, determine the session type and read the corresponding reference:

| Session type | When to use | Reference file |
|---|---|---|
| **review** | Code review, architecture review, PR review, design review | `references/review-session.md` |
| **grill-me** | Q&A, challenge session, knowledge-testing, interview-style | `references/grill-me-session.md` |
| **casual** | Brainstorm, informal feature discussion, vibe session, exploratory chat | `references/casual-session.md` |

Also read `references/directory-structure.md` — it defines the canonical output layout.

If the session is mixed (e.g., started casual, turned into a grill-me), read both files and blend.

---

## Step 1 — Extract session context

Mine the conversation for every piece of relevant context. Do NOT ask the user to repeat things
they already said — find it. Build an internal model of:

**Project context**
- Project name, repo, language/framework, architecture pattern
- Current state (greenfield? existing system? mid-migration?)
- Team size and deployment environment if mentioned

**The session's core output**
- What problem was identified or discussed?
- What decisions were made (implicit or explicit)?
- What was deferred, deprioritized, or explicitly out of scope?
- What open questions remain?
- What constraints were mentioned (time, performance, backwards-compat, etc.)?

**Emotional and priority signals**
- What did the person seem most energized or worried about?
- Were there any "definitely must do" vs "would be nice" signals?

If critical context is missing (no project name, no clear scope), ask ONE targeted question before
proceeding. Don't hold up the whole plan for minor details — use `[TBD: description]` placeholders.

---

## Step 2 — Determine directory path

Use the convention from `references/directory-structure.md`:

```
/{project-name}/{feature-or-topic-name}/
  plan.md                    ← executive summary + index
  plan-details/
    01-context.md
    02-requirements.md
    03-tasks.md              ← or split by phase/area
    ...
    NN-testing.md
    NN-rollout.md
```

Derive names from the conversation:
- **project-name**: from repo name, product name, or what the person calls their system
- **feature-name**: from the feature, ticket, or topic discussed (use kebab-case, be descriptive)

Examples of good paths:
- `/payments-api/stripe-webhook-refactor/`
- `/mobile-app/onboarding-redesign/`
- `/infra/redis-cache-migration/`
- `/design-system/button-accessibility-audit/`

If ambiguous, lean toward more-specific-is-better.

---

## Step 3 — Write the plan files

Write each file fully. No stubs, no "fill this in later". A plan file should read like thorough
documentation written by someone who deeply understood the work.

### `plan.md` — The executive overview

This is the entry point. A fresh agent reads this first. It must contain:

1. **One-paragraph summary** — What happened in the session and what the plan accomplishes
2. **Session type and date** — Review / Grill-me / Casual + ISO date
3. **Current state** — Where things stand *right now*, before any work begins
4. **Goal state** — What "done" looks like
5. **Scope** — What is and is NOT included (explicit out-of-scope prevents wasted work)
6. **Constraints** — Non-negotiables (performance budgets, API compatibility, deadlines, etc.)
7. **Key decisions** — Decisions made during the session and why
8. **Risk register** — Known risks, their likelihood, and mitigation approach
9. **File index** — Links to each `plan-details/` file with one-line descriptions
10. **Execution order** — Recommended sequence (which tasks block others)
11. **Definition of done** — Checklist for "the work is complete"

### `plan-details/` files — The working documents

Each file covers one coherent area of work. Write them in depth.

Read `references/plan-detail-templates.md` for canonical templates for each file type
(context, requirements, task files, testing, rollout, etc.).

General rules for every detail file:
- Open with a **TL;DR** (2-3 sentences: what this file covers and why it matters)
- Use concrete language — name the files, functions, endpoints, components
- Include code sketches where it removes ambiguity (pseudo-code is fine)
- Make explicit what the agent must verify before starting
- Make explicit what the agent must validate when done
- Flag anything uncertain with `> ⚠️ ASSUMPTION: [text]` so the agent can check

---

## Step 4 — Quality check before writing files

Before creating any file, do a silent self-review:

- [ ] Can an agent execute this plan without re-reading the session?
- [ ] Are all major decisions documented with rationale?
- [ ] Are all open questions either answered or clearly flagged?
- [ ] Are the tasks sequenced correctly (dependencies respected)?
- [ ] Is the testing strategy specific enough to be runnable?
- [ ] Is there a rollout/deployment step if the work touches production?
- [ ] Are edge cases and failure modes addressed?

If any box is unchecked, fill the gap before writing.

---

## Step 5 — Output the files

Write all files to disk. Always write `plan.md` first, then the `plan-details/` files in order.

After writing, confirm to the user:
- Where the files are saved
- A one-paragraph summary of the plan
- Any flagged assumptions or open questions that need human input

Do NOT write a lengthy recap in chat — the files are the record. Just confirm creation and flag
anything that needs attention.

---

## Writing style

Plans are written for an agent, not for a human manager. That means:
- Be direct and precise, not diplomatic
- Name the things — actual file paths, function names, config keys
- Use imperative voice for tasks ("Create the migration", not "A migration should be created")
- Prefer concrete over abstract ("debounce at 300ms" over "add debouncing")
- Short sentences. No filler.
- Organize with headers and numbered lists; this is navigation material

---

## Reference files in this skill

| File | When to read |
|---|---|
| `references/review-session.md` | Session was a code/design review |
| `references/grill-me-session.md` | Session was a Q&A / challenge format |
| `references/casual-session.md` | Session was a brainstorm or informal discussion |
| `references/directory-structure.md` | Always — defines output layout conventions |
| `references/plan-detail-templates.md` | When writing individual plan-details files |
