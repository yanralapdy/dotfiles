# Team Topologies

Four ways to wire a peer team over pi-peer. Grounded in the canonical multi-agent patterns (sequential, concurrent, maker-checker, handoff) adapted for a peer-to-peer socket bus with no central orchestrator.

> **Transport scope.** pi-peer uses Unix-domain sockets on POSIX and named pipes on Windows. All peers must be on the **same machine**. There is no cross-machine transport and no durable message queue — a message sent to an offline peer is lost.

## Decision matrix

| Topology                | Roles typical                                    | When it wins                                       | Watch out for                              |
|-------------------------|--------------------------------------------------|----------------------------------------------------|--------------------------------------------|
| Sequential pipeline     | builder → tester → reviewer → (deployer)         | Deterministic stages, each blocks the next         | One slow stage stalls the whole chain      |
| Concurrent fan-out      | builder → { security-scanner ∥ perf ∥ reviewer } | Multiple independent lenses on the same output     | Aggregating contradictory feedback         |
| Maker-checker loop      | builder ↔ tester                                 | Tight iterative refinement of one artifact         | Infinite loops — 3-iteration cap mandatory |
| On-demand consultant    | builder + { consultant, researcher }             | Occasional specialist input, no gate               | Builder forgets consultant exists          |

If a workflow needs more than one topology (e.g., pipeline with a parallel review stage), compose them. Composition rules at the bottom.

## 1. Sequential pipeline

Stages run in fixed order. Each stage blocks the next until it emits PASS. This is the shape of most delivery workflows.

```
┌─────────┐  T-XX done   ┌────────┐  all pass    ┌──────────┐  approved   ┌──────────┐
│ Builder │─────────────▶│ Tester │─────────────▶│ Reviewer │────────────▶│ Deployer │
└─────────┘              └────────┘              └──────────┘             └──────────┘
     ▲   FAIL ── feedback-T-XX.md      ▲    FAIL ── feedback-review-NN.md    │
     └─────────────────────────────────┘                                     │
     ▲                                                                       │
     └───────────────── deploy failed ─── high-severity feedback ────────────┘
```

**Rules:**
- Every arrow forward is a `peer_send` with a distinct trigger phrase (see [PROTOCOL.md](PROTOCOL.md)).
- Feedback flows backwards only to the immediately previous stage; each stage owns its own feedback style.
- A stage may fan out one message to **inform** later stages without waking them (e.g., builder pings reviewer "T-01 through T-05 done, tester now verifying" — reviewer stays idle until tester's final PASS).

**When to use:** requirements are stable and stages are well-defined. Default choice for feature delivery.

**When to avoid:** stages are ambiguous, or feedback needs to route past the previous stage (e.g., reviewer wants planner to update the plan). In those cases, break into two pipelines separated by a human checkpoint.

## 2. Concurrent fan-out

One producer emits an artifact; multiple specialist reviewers examine it in parallel and each produce their own issue-scoped feedback. Builder integrates all findings before continuing.

```
                                ┌──────────────────┐
                          ┌────▶│ Security-scanner │──feedback-security-NN.md──┐
                          │     └──────────────────┘                            │
┌─────────┐  ready to     │     ┌──────────────────┐                            │
│ Builder │──review──────┼────▶│ Perf-analyzer    │──feedback-perf-NN.md──────┼──▶ Builder aggregates
└─────────┘               │     └──────────────────┘                            │
                          │     ┌──────────────────┐                            │
                          └────▶│ Reviewer (arch)  │──feedback-review-NN.md────┘
                                └──────────────────┘
```

**Rules:**
- Builder emits a single "ready for review" `prompt` addressed to all reviewers via multiple `peer_send` calls.
- Each reviewer produces its own issue-scoped file prefix (`feedback-<role>-<NN>.md`). Never share a prefix.
- Builder waits until all reviewers have emitted their final report (PASS or FAIL). Missing reports block the aggregate.
- On conflicting recommendations (e.g., perf wants caching, security wants no caching), builder escalates to human — not to another agent.

**When to use:** shipping to production, security-sensitive changes, cross-cutting refactors, code that touches three or more subsystems.

**When to avoid:** small changes where a single reviewer covers the ground. Fan-out costs 3x the review time.

## 3. Maker-checker loop

Two peers iterate on a single artifact until the checker approves. The task-scoped feedback file is the whole state machine. This is the tightest form of pipeline — the classic build ↔ test cycle.

```
        ┌──────────────────────────────┐
        │                              │
        ▼                              │
┌─────────┐  T-XX done      ┌────────┐ │
│ Builder │────────────────▶│ Tester │─┘  fix + resubmit
└─────────┘◀────FAIL────────└────────┘
                                │
                                └─── PASS after ≤3 iterations ───▶ done
                                └─── FAIL after 3 iterations ────▶ escalate to human
```

**Rules:**
- One `feedback-<TASK-ID>.md` per task. Same file for every iteration. Append to `## Issue`, never fork the filename.
- Status transitions: `open` (tester) → `resolved` (builder) → `closed` (tester) OR `open` again (regression).
- Hard cap of 3 iterations. On the 4th open, tester emits an escalation message; builder stops fixing.
- Builder must not proceed to T-YY until T-XX is `closed`.

**When to use:** every task in a delivery pipeline. This is the default builder-tester relationship.

**When to avoid:** it's not really avoidable — this loop is what makes the pair work. Just enforce the cap.

## 4. On-demand consultant

One lead agent works alone. Specialists sit idle until the lead sends an explicit `consult` message. The specialist replies with advice; the lead decides what to do. Specialists never block the lead.

```
┌─────────┐         (idle unless summoned)
│ Builder │◀────consult "how do I index this query?"─────┐
└─────────┘                                              │
     │  advice: "use partial index on (status, created_at)"
     │                                                   │
     ▼                                              ┌──────────────────┐
   builds on                                        │ DB-consultant    │
   the advice                                       │ (idle otherwise) │
                                                    └──────────────────┘
```

**Rules:**
- Consultant advises; it never modifies code or files (except an optional `consult-<NN>.md` note if the answer is reusable).
- Lead frames each `consult` message with concrete question + minimal context (file paths, current approach, constraint). Send as `type: "prompt"` with `expectReply: true`.
- Consultant replies with `type: "response"`. If a back-and-forth is needed, the lead sends another `consult`.
- Multiple consultants can coexist; each covers a distinct domain (`db-consultant`, `security-consultant`, `ux-consultant`).

**When to use:** builder is competent generally but hits domain-specific questions occasionally. Cheaper than a full-time reviewer.

**When to avoid:** the specialist's input is needed on every task. That's a reviewer, not a consultant — promote it.

## Composition — mixing topologies

Real teams combine topologies. Two recipes cover the common cases:

### Pipeline with parallel review

Use a sequential pipeline for stages but replace the reviewer stage with a concurrent fan-out:

```
Builder → Tester ──all-pass──▶ { Security-scanner ∥ Perf-analyzer ∥ Reviewer } ──all-pass──▶ Deployer
```

The parallel-review stage is one logical stage in the pipeline. Builder aggregates all three reviewers' PASS reports before signaling deployer.

### Pipeline with on-demand consultants

Overlay consultants on any pipeline. They wake only on explicit `consult` messages:

```
Builder ◀──consult──▶ DB-consultant     (available at any stage)
   │
   ▼
Tester → Reviewer → Deployer
```

Any pipeline agent can call any consultant; consultants respond to whichever agent summoned them.

### What you cannot compose

- **Two pipelines writing to the same feature directory.** Race conditions on files. Split by feature instead.
- **A reviewer in a maker-checker with the builder.** Reviewers work at whole-system granularity, not per-task. Use a tester for per-task and a reviewer downstream.
- **A consultant that produces feedback files.** Consultants advise; blocking work is a reviewer or specialist-scanner role.
