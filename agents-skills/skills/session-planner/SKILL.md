---
name: session-planner
description: >
  Converts a session (review, grill-me, or casual) into an agent-executable plan. Use when a
  conversation, review, interview, or brainstorm needs structured action steps another agent can
  execute without re-reading the transcript. Triggers: "create a plan from this session", "turn
  this review into a plan", "plan from grill-me", "plan this out", "I need a plan", "write an
  implementation plan", or when user says "plan this" or "plan it out". Also generates multi-agent
  pi-peer prompts (builder, tester, reviewer) from completed plans. Triggers: "create agent prompts
  for this plan", "set up pi-peer for this plan", "generate builder/tester prompts", "set up
  multi-agent for this plan", or when user wants a plan executed by multiple agents via pi-peer.
---

# Session Planner

Converts any session — review, grill-me, or casual — into a thorough, agent-ready execution
plan with clean directory structure and deep implementation detail.

The output must be so complete that a fresh agent, reading only the plan files, can execute the
work without asking follow-up questions. Every ambiguity should be resolved in the plan. Every
decision should be documented with its rationale.

Optionally, generates pi-peer agent prompts so the plan can be executed by a team of peer agents
(builder → tester → reviewer) communicating through the pi-peer extension. See Step 6.

Write every plan as if you are explaining the work to a junior developer who is competent but
brand new to this codebase. Assume they understand code — but do not assume they know this
project's conventions, history, or unwritten rules. Define any project-specific terms the first
time they appear. Always explain the *why* behind a step, not just the *what*. If something
feels obvious, write it anyway — misunderstood "obvious" steps are the most common reason
plans fail in execution. Never use phrases like "as usual", "simply", or "of course".

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

If the user expects multi-agent execution, also read `references/pi-peer-workflow.md`.

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

**Multi-agent signals** (for Step 6)
- Did the user mention wanting agents, automation, or delegation?
- Did they reference pi-peer, builder, tester, or reviewer roles?
- Is the plan large enough (>5 tasks, multiple skill domains) to benefit from agent splitting?

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

**If generating pi-peer agent prompts (Step 6), also check:**
- [ ] Does each task map to test cases the tester can independently run?
- [ ] Are task dependencies clear enough to serialize for the builder?
- [ ] Does the plan include enough stack/architecture detail for the reviewer?
- [ ] Are "out of scope" items clearly marked so agents don't stray?

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

## Step 6 — Optionally generate pi-peer agent prompts

If the user intends the plan to be executed by multiple agents (or if you detect that the
plan's size and skill domains warrant it), generate pi-peer agent prompts that let a builder,
tester, and reviewer agent collaborate through the pi-peer extension.

**Read `references/pi-peer-workflow.md`** before generating prompts. It contains the full
template, communication protocol, and directory conventions.

### When to generate agent prompts

Generate prompts when:
- The user explicitly asks ("set up pi-peer agents", "multi-agent this plan", "create builder/tester prompts")
- The plan has 5+ tasks spanning multiple skill domains
- The user mentioned agents, delegation, or automation during the session
- The plan's testing strategy benefits from independent verification

Skip prompts when:
- The plan is a single-task fix
- The plan is purely informational (documentation, research notes)
- There's no clear testing strategy (cannot build a tester prompt)

### Agent role assignment

Map the plan's content to agent roles dynamically based on what skills are needed:

| Role | Purpose | Skills to assign | Derived from |
|------|---------|-----------------|--------------|
| **Builder** | Implements tasks from the plan | Implementation skills (e.g., react-patterns, laravel-best-practices, vue3-composition-api, tdd, refactoring, doctree) + caveman | The plan's tech stack and task files |
| **Tester** | Verifies each task against test cases | Testing skills (e.g., testing, spec-tester, diagnose, browser-harness) + caveman | The plan's testing file |
| **Reviewer** | Reviews complete work for architecture, performance, security | Quality skills (e.g., architecture-review, performance-optimization, security-review, zoom-out) + caveman | The plan's architecture and risk register |

Always include `caveman` for all three — it saves tokens in pi-peer communication.

If the user specifies custom skill assignments, use those instead.

### Directory for pi-peer prompts

```
~/brain-dump/pi-peer-prompts/
└── <project-name>/
    └── <feature-name>/
        ├── builder-agent.md
        ├── tester-agent.md
        ├── reviewer-agent.md
        └── feedback-*.md   ← created at runtime by tester/reviewer
```

### Generating the prompts

For each agent prompt, fill in the template from `references/pi-peer-workflow.md`:

1. **Map plan files to agent knowledge**: Each agent needs specific plan files:
   - Builder: `plan.md`, context, tasks, architecture, decisions — everything needed to implement
   - Tester: `plan.md`, requirements, tasks (for "Done when" checklists), testing, context
   - Reviewer: `plan.md`, architecture, context, risk register, tasks (for what was built), open decisions

2. **Map tasks to test cases**: Create explicit task→test-case mappings for the tester

3. **Determine skills**: Pick from the available skills list based on the plan's stack:
   - Builder: implementation skills matching the tech stack
   - Tester: `testing` + stack-appropriate verification skills
   - Reviewer: `architecture-review` + `performance-optimization` + `security-review`

4. **Fill in project info**: Repo path, build command, stack description, config details

5. **Wire the communication protocol**: Each agent prompt must contain the full pi-peer protocol
   so the agent knows how to start up, notify peers, handle feedback, and escalate.

6. **Add guardrails**: Anti-stray rules — out of scope features, iteration limits, escalation path.

### Agent workflow

```
Builder implements T-01 → verifies → peer_send "T-01 done" → Tester tests
  → PASS: builder moves to T-02
  → FAIL: tester creates feedback-T-01.md → builder fixes → re-test
[Repeat for all tasks]
  → All tasks pass → Builder notifies Reviewer
    → Reviewer does architecture/performance/security review
    → PASS: build complete 🎉
    → FAIL: reviewer creates feedback-review-NN.md → builder fixes → re-review
```

Max 3 iterations per issue before human escalation.

### After generating prompts

Confirm to the user:
- Where the agent prompts are saved (`~/brain-dump/pi-peer-prompts/<project>/<feature>/`)
- How many agents were configured (2 or 3)
- The startup command for each agent session: `pi -e ~/.pi/extensions/pi-peer/index.ts`
- Which plan files each agent should read on startup

---

## Writing style

Plans are written for an agent, not for a human manager. That means:
- Be direct and precise, not diplomatic
- Name the things — actual file paths, function names, config keys
- Use imperative voice for tasks ("Create the migration", not "A migration should be created")
- Prefer concrete over abstract ("debounce at 300ms" over "add debouncing")
- Short sentences. No filler.
- Organize with headers and numbered lists; this is navigation material

**Write as if teaching a junior developer.** This is the single most important writing
principle in this skill. Concretely, that means:

- **Define terms on first use.** If you reference `the event bus`, add a one-liner: "the
  event bus (our internal pub/sub system in `src/events/`) ". Never assume the reader
  knows what a project-specific term means.
- **Explain the why, not just the what.** Don't write "Add an index on `user_id`." Write
  "Add an index on `user_id` — without it, this query will do a full table scan and will
  time out at production row counts."
- **Spell out the full command or path.** Not "run the migration script" — write
  `npm run migrate -- --env staging` and explain what it does.
- **State what correct output looks like.** After each step, tell the reader what they
  should see if it worked: "You should see `✅ Migration applied: 0023_add_user_index`
  in the terminal. If you see an error about a missing table, see the Troubleshooting
  section."
- **Never use "simply", "just", "obviously", or "as usual".** These words skip over the
  exact thing a junior developer needs to understand. Remove them on sight.
- **When in doubt, over-explain.** A senior developer can skim past detail. A junior
  developer cannot invent detail that isn't there.

---

## Reference files in this skill

| File | When to read |
|---|---|
| `references/review-session.md` | Session was a code/design review |
| `references/grill-me-session.md` | Session was a Q&A / challenge format |
| `references/casual-session.md` | Session was a brainstorm or informal discussion |
| `references/directory-structure.md` | Always — defines output layout conventions |
| `references/plan-detail-templates.md` | When writing individual plan-details files |
| `references/pi-peer-workflow.md` | When generating multi-agent pi-peer prompts (Step 6) |
