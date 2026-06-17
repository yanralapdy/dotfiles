---
name: coms-workflow
description: Set up peer-to-peer agent workflows (builder+tester) using the coms extension. Use when creating multi-agent collaboration prompts, setting up build→test→feedback→fix loops, organizing coms-prompts directories, or when user mentions coms agents, builder/tester pairs, agent feedback loops, or peer-agent communication.
---

# Coms Workflow

Set up peer-level agent pairs that collaborate through the coms extension — no delegation, no hierarchy. The builder implements tasks from a plan; the tester verifies each task and creates structured feedback files when things fail. Both agents communicate via `coms_send` / `coms_await`.

## Quick start

```
1. Ensure the coms extension is available (~/.pi/extensions/coms/)
2. Identify the plan the agents will work from
3. Create the directory structure (see Conventions below)
4. Generate builder and tester prompts from templates
5. Start two Pi sessions, each loading one prompt + coms extension
```

## Directory conventions

All coms-related artifacts live under `~/brain-dump/coms-prompts/`:

```
~/brain-dump/coms-prompts/
├── <project>/
│   └── <feature-or-plan>/
│       ├── builder-agent.md    # prompt for the builder session
│       ├── tester-agent.md     # prompt for the tester session
│       └── feedback-T-XX.md    # created by tester on failure, updated by both
└── _shared/                    # optional: reusable role templates
```

### Naming rules

| Artifact | Pattern | Example |
|----------|---------|---------|
| Builder prompt | `builder-agent.md` | always `builder-agent.md` per feature |
| Tester prompt | `tester-agent.md` | always `tester-agent.md` per feature |
| Feedback file | `feedback-<TASK-ID>.md` | `feedback-T-01.md`, `feedback-T-03.md` |
| Additional roles | `<role>-agent.md` | `reviewer-agent.md`, `deployer-agent.md` |

**Why `feedback-` prefix**: Groups all feedback files together in directory listings. One file per task — updated in-place by both agents (no version sprawl).

## Workflow

### Create prompts for a plan

```
1. Read the plan (plan.md, task list, test cases)
2. Identify what skills each role needs:
   - Builder: react-patterns (or stack-equivalent), refactoring, git-workflow
   - Tester: browser-harness, testing, spec-tester (adapt to project stack)
3. Generate builder prompt from [TEMPLATES.md](TEMPLATES.md):
   - Fill in plan paths, project info, skill list, task mapping
   - Wire the coms communication protocol
4. Generate tester prompt from [TEMPLATES.md](TEMPLATES.md):
   - Map each task to its test cases
   - Include feedback file creation workflow
   - Set the re-test loop (max 3 iterations before human escalation)
5. Save both prompts to the feature directory
```

### The build→test→feedback loop

```
Builder implements task → build (verify) → coms_send "T-XX done"
  → Tester reads task spec → runs tests
    → PASS: coms_send "PASS" → builder marks done, moves to next
    → FAIL: tester creates feedback-T-XX.md → coms_send "FAIL + link"
      → Builder reads feedback → fixes code → updates ## Fix section
      → Builder coms_send "fixed, re-test"
      → Tester re-tests → updates ## Verification
        → PASS: feedback closed, loop ends
        → FAIL again: append to same file, repeat. After 3 iterations → escalate to human
```

### Feedback file lifecycle

| State | Set by | Meaning |
|-------|--------|---------|
| `open` | Tester | Issue reported, awaiting fix |
| `resolved` | Builder | Fix applied, ready for re-test |
| `closed` | Tester | Re-test passed, loop complete |

Full format: see [FEEDBACK.md](FEEDBACK.md)

## Adding new roles

Extend beyond builder+tester by following the same conventions:

1. Create `<role>-agent.md` in the feature directory
2. Use the same coms protocol (announce → wait → act → report)
3. Map the role's responsibilities to existing plan artifacts (tasks, test cases, requirements)
4. If the role is reusable, save a base template to `_shared/<role>-base.md`

## Guardrails

- **Peer, not subordinate**: Agents use `coms_send` directly — no manager routing messages
- **One feedback file per task**: Don't create `feedback-T-01-v2.md`. Append to the same file
- **Max 3 re-test iterations**: After 3 failures, escalate to human. Don't loop indefinitely
- **Plan is the source of truth**: Both agents reference the same plan directory. If the plan changes, regenerate prompts
- **Coms extension must be loaded**: Each agent session needs `pi -e ~/.pi/extensions/coms/index.ts`
