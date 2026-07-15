---
name: peer-workflow
description: Design and generate peer-to-peer agent teams (pair, trio, or arbitrary N-agent topologies) that collaborate via the pi-peer extension. Use when creating multi-agent collaboration prompts, wiring build→test→review pipelines, adding a reviewer or planner or researcher to an existing pair, running parallel review passes, setting up on-demand consultants, or when the user mentions peer agents, pi-peer, builder/tester/reviewer, feedback loops, or multi-agent workflows.
---

# Peer Workflow

Design peer-to-peer agent teams that coordinate via the pi-peer extension — no orchestrator, no hierarchy. Each agent runs in its own Pi session with a first-class **role** (`builder`, `tester`, `reviewer`, …) seeded from `PI_PEER_ROLE` at startup. Communication is **event-driven**: `peer_send` delivers `prompt`/`response` messages that auto-inject into the receiver's session and wake it — no polling, no blocking await. Teams range from a **pair** (builder+tester) to a **trio** (add reviewer) to arbitrary N-agent topologies (planner, researcher, deployer, consultants).

## Quick start

```
1. Pick a topology     → see [TOPOLOGIES.md](TOPOLOGIES.md)   (sequential / concurrent / maker-checker / consultant)
2. Pick the roles      → see [ROLES.md](ROLES.md)             (which archetypes fill each slot)
3. Generate prompts    → see [TEMPLATES.md](TEMPLATES.md)     (one per role, filled from the plan)
4. Wire the protocol   → see [PROTOCOL.md](PROTOCOL.md)       (startup, handoff, escalation)
5. Feedback format     → see [FEEDBACK.md](FEEDBACK.md)       (task-scoped vs issue-scoped)
6. Full walkthroughs   → see [EXAMPLES.md](EXAMPLES.md)       (5 worked topologies)
```

## Decision tree — which topology?

```
Does the plan already list ordered stages (build → test → review → deploy)?
  YES → Sequential pipeline. Each stage blocks the next until PASS.
  NO  ↓

Do you need multiple independent perspectives on the same output (security + perf + arch)?
  YES → Concurrent fan-out. One producer, N reviewers in parallel, aggregate results.
  NO  ↓

Is this an iterative maker/checker where the same two peers loop until convergence?
  YES → Maker-checker loop. Special-case pair with strict iteration cap.
  NO  ↓

Does one lead agent occasionally need a specialist (DB expert, security advisor)?
  YES → On-demand consultant. Lead agent works alone, calls consultant when stuck.
```

If unsure: start with a **sequential pipeline** — it composes with the other three later.

## Directory conventions

All artifacts live under `~/brain-dump/peer-prompts/<project>/<feature>/`:

```
<project>/<feature>/
├── <role>-agent.md                # one prompt per agent (builder-agent.md, tester-agent.md, reviewer-agent.md, …)
├── feedback-<TASK-ID>.md          # task-scoped feedback (one per task, updated in-place)
└── feedback-<role>-<NN>.md        # issue-scoped feedback (one per distinct concern, sequential NN)
```

Naming rules and lifecycle: [FEEDBACK.md](FEEDBACK.md).

## Generation workflow

For any team the agent generates:

```
1. Read the plan (plan.md + plan-details/*). Identify tasks, test cases, decisions, out-of-scope.
2. Choose topology (decision tree above).
3. Choose roles (ROLES.md). Confirm each role has a home in the plan.
4. For each role: copy the base template + role slice from TEMPLATES.md; fill placeholders from plan.
5. Wire peer handoffs per PROTOCOL.md — every stage transition needs an explicit trigger message.
6. Set feedback file convention per role (task-scoped or issue-scoped — see FEEDBACK.md).
7. Save each prompt as <role>-agent.md in the feature directory.
```

## Guardrails

- **Peer, not subordinate.** Every agent uses `peer_send` directly. No agent routes messages for another.
- **One prompt per role, per feature.** Never version prompts (`builder-agent-v2.md`). Regenerate in place if the plan changes.
- **Feedback discipline.** One task-feedback file per task; one issue-feedback file per issue. Append, never fork.
- **Max 3 iterations per issue.** After 3 failed fix attempts on the same issue, escalate to human. No infinite loops.
- **Plan is the source of truth.** All agents reference the same plan directory. If the plan changes, regenerate prompts.
- **Install pi-peer before starting sessions.** Run `pi install https://github.com/yanralapdy/pi-peer.git` once per machine. For local dev or opt-in only: start each session with `PI_PEER_ROLE=<role> pi -e ~/sites/js/node/pi-peer` instead. Address peers by role: `peer_send(to: "tester", …)`.
- **Deeper the team, stricter the handoffs.** A trio (build→test→review) needs explicit "tester passes to reviewer" messages defined in PROTOCOL.md, not inferred.
- **Local machine only.** pi-peer uses Unix-domain sockets (POSIX) or named pipes (Windows). No cross-machine transport; no durable queue — messages sent to offline peers are lost.
