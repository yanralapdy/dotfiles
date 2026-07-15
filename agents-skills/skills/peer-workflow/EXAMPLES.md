# Worked Examples

Five real team shapes with concrete role choices, wiring, and expected message flow. Use as reference when generating prompts for a new feature.

Each example lists: roles, why this shape, directory layout, message flow, and what to copy.

---

## 1. Pair — builder + tester

The default. Sequential pipeline with maker-checker loop. Two agents, one feature.

**When to use:** typical feature work, well-defined tasks, single-domain change.

**Roles:**

| Role    | Slice                                     |
|---------|-------------------------------------------|
| Builder | TEMPLATES.md → Builder slice              |
| Tester  | TEMPLATES.md → Tester slice               |

**Directory:**

```
~/brain-dump/peer-prompts/<project>/<feature>/
├── builder-agent.md
├── tester-agent.md
└── feedback-T-<XX>.md      # created by tester on failure, one per task
```

**Message flow (T-01 happy path):**

```
Builder            Tester
   │                 │
   ├─ handshake ────▶│   peer_send type:"message" — "Builder online. Starting T-01."
   │◀── handshake ───┤   peer_send type:"message" — "Tester online. Ready to verify."
   │                 │
   │  [implements]   │
   │  {{BUILD_CMD}}  │
   │                 │
   ├─ task-done ────▶│   peer_send type:"prompt", expectReply:true — "T-01 done. Files:... Please test."
   │◀── test-ack ────┤   peer_send type:"message" — "Ack. Testing T-01. ETA 5m."
   │                 │  [runs tests]
   │◀── test-pass ───┤   peer_send type:"prompt" — "T-01 PASS. Proceed."
   │                 │
   │  [moves to T-02]│
```

**Message flow (T-02 failure + fix):**

```
Builder            Tester
   ├─ task-done ────▶│   peer_send type:"prompt", expectReply:true
   │◀── test-ack ────┤   peer_send type:"message"
   │                 │  [runs; TC-02b fails]
   │                 │  [creates feedback-T-02.md, Status=open]
   │◀── test-fail ───┤   peer_send type:"prompt" — "T-02 FAIL. See feedback-T-02.md."
   │  [reads issue]  │
   │  [fixes]        │
   │  [updates Fix]  │
   ├─ fix-done ─────▶│   peer_send type:"prompt", expectReply:true — "T-02 fixed per feedback-T-02.md."
   │◀── test-pass ───┤   peer_send type:"prompt" — [re-tests, closes file]
```

**To generate:**

```
1. Pick topology: sequential pipeline (TOPOLOGIES.md §1).
2. Pick roles: builder + tester (ROLES.md).
3. Assemble prompts: base template + Builder slice / Tester slice (TEMPLATES.md).
4. Fill placeholders from the plan directory.
5. Install pi-peer once: `pi install https://github.com/yanralapdy/pi-peer.git`
6. Save to feature directory. Start both sessions.
```

---

## 2. Trio — builder + tester + reviewer

The pi-nvim shape. Sequential pipeline with a whole-system review stage. Three agents, one feature.

**When to use:** v1 shipping, security-relevant code, code the team will maintain long-term, or the tester is per-task but you also want architecture/perf/security lenses.

**Roles:**

| Role     | Slice                                                        |
|----------|--------------------------------------------------------------|
| Builder  | TEMPLATES.md → Builder slice + reviewer awareness            |
| Tester   | TEMPLATES.md → Tester slice + stage-handoff to reviewer      |
| Reviewer | TEMPLATES.md → Reviewer slice (3 lenses)                     |

**Directory:**

```
~/brain-dump/peer-prompts/<project>/<feature>/
├── builder-agent.md
├── tester-agent.md
├── reviewer-agent.md
├── feedback-T-<XX>.md         # task-scoped, tester → builder
└── feedback-review-<NN>.md    # issue-scoped, reviewer → builder
```

**Message flow (happy path, all-clear):**

```
Builder     Tester      Reviewer
   │           │           │
   ├─ tri handshake (type:"message") ────────▶│   all three announce
   │           │           │
   │──T-01 done (type:"prompt")─▶│         │
   │◀── PASS (type:"prompt")────│         │
   │           │           │
   │──T-02 done─▶│         │
   │◀── PASS ────│         │
   │          ...          │
   │──T-05 done─▶│         │
   │◀── PASS ────│         │
   │           │           │
   │           ├─ stage-handoff (type:"prompt", expectReply:true) ─▶│
   │◀────────────ack (type:"message")────────┤   "Ack. Reviewing. ETA 15m."
   │           │           │  [architecture + perf + security passes]
   │◀────────────PASS (type:"prompt")──────┤   "Review PASS. All lenses clean."
   │           │           │
   │  [build complete]
```

**Message flow (review finds 2 issues):**

```
Builder                   Reviewer
   │◀── stage-return (type:"prompt") ────────┤   "Review FAIL. 2 issues.
   │                          │   - R-01: feedback-review-01.md (Security, High)
   │                          │   - R-02: feedback-review-02.md (Perf, Medium)"
   │  [reads both files]      │
   │  [fixes each]            │
   │  [updates ## Fix in each]│
   ├─ fix-done (type:"prompt", expectReply:true) ──────────────▶│   "Both fixed."
   │◀── PASS (type:"prompt") ─────────────────┤   [re-reviews only affected modules]
```

**To generate:**

```
1. Pick topology: sequential pipeline (TOPOLOGIES.md §1).
2. Add third stage: reviewer between tester and "done".
3. Assemble builder, tester, reviewer prompts.
4. Ensure:
   - Builder's Main Loop step 6 sends stage-handoff to reviewer after tester all-pass.
   - Tester's Main Loop step 7 sends stage-handoff to reviewer when every task closed.
   - Reviewer starts at step 1: ends turn, woken by the tester's injected stage-handoff prompt.
5. Save all three prompts. Start three sessions.
```

**Real precedent:** `~/brain-dump/peer-prompts/pi-nvim/neovim-plugin/` — the working example that seeded this skill.

---

## 3. Parallel review — builder + tester + { security-scanner ∥ perf-analyzer ∥ reviewer }

Concurrent fan-out at the review stage. Five agents. One producer, three parallel reviewers.

**When to use:** shipping to production, cross-cutting refactor, security-critical code, code touching three or more subsystems.

**Roles:**

| Role                | Slice                                             |
|---------------------|---------------------------------------------------|
| Builder             | Builder slice, aggregation logic in Main Loop     |
| Tester              | Tester slice, hands off to ALL THREE reviewers    |
| Security-scanner    | Security-scanner slice                            |
| Performance-analyzer| Perf slice                                        |
| Reviewer (arch)     | Reviewer slice, architecture lens only            |

**Directory:**

```
~/brain-dump/peer-prompts/<project>/<feature>/
├── builder-agent.md
├── tester-agent.md
├── security-agent.md
├── perf-agent.md
├── reviewer-agent.md
├── feedback-T-<XX>.md
├── feedback-security-<NN>.md
├── feedback-perf-<NN>.md
└── feedback-review-<NN>.md
```

**Message flow (review stage):**

```
              Tester (all tasks PASS)
                     │
                     ├─ stage-handoff ─▶ security-scanner
                     ├─ stage-handoff ─▶ perf-analyzer
                     └─ stage-handoff ─▶ reviewer

              (each runs in parallel, produces own feedback files)

              security-scanner ──▶ builder  (PASS or FAIL + files)
              perf-analyzer   ──▶ builder  (PASS or FAIL + files)
              reviewer        ──▶ builder  (PASS or FAIL + files)

              builder aggregates:
                - All three PASS → announce complete
                - Any FAIL → fix each issue-scoped file → send fix-done to
                  each affected reviewer for re-review
                - Conflicting recommendations (e.g., perf wants cache,
                  security says no) → escalate to human
```

**To generate:**

```
1. Pick topology: pipeline + concurrent fan-out at review stage (TOPOLOGIES.md §2 + composition).
2. Roles: builder, tester, security-scanner, perf-analyzer, reviewer.
3. Tester's stage-handoff step must fire THREE messages (one per reviewer).
4. Builder's Main Loop must aggregate all three PASS reports before completion.
5. Escalation: on conflicting reviewer recommendations, builder escalates — do not have reviewers debate each other.
```

---

## 4. Planner-led — planner → builder + tester + reviewer

Planner runs first, produces the plan, exits. Then the trio begins.

**When to use:** greenfield feature, ambiguous requirements, cross-team scope, refactor that needs decision documentation.

**Roles:**

| Role     | Slice                                                    | Session duration |
|----------|----------------------------------------------------------|------------------|
| Planner  | Planner slice                                            | Short — runs then exits |
| Builder  | Builder slice                                            | Long — full feature    |
| Tester   | Tester slice                                             | Long — full feature    |
| Reviewer | Reviewer slice                                           | Idle → wakes at end     |

**Directory:**

```
~/brain-dump/plans/<project>/<feature>/         # planner's output
├── plan.md
└── plan-details/
    ├── 01-context.md
    ├── 02-requirements.md
    ├── 03-tasks.md
    ├── 05-testing.md
    └── 08-parking-lot.md

~/brain-dump/peer-prompts/<project>/<feature>/  # execution artifacts
├── planner-agent.md                            # optional; can be run inline
├── builder-agent.md
├── tester-agent.md
├── reviewer-agent.md
├── feedback-T-<XX>.md
└── feedback-review-<NN>.md
```

**Message flow (planner phase):**

```
Planner
   │
   │ [reads requirements source]
   │ [drafts plan.md + plan-details/*]
   │
   ├─ plan-ready ─▶ builder  (prompt)
   ├─ plan-ready ─▶ tester   (prompt)
   ├─ plan-ready ─▶ reviewer (prompt)
   │
   │ [exits — frees the peer slot]
```

**Message flow (execution phase):** identical to the trio example.

**To generate:**

```
1. Start with a planner session; give it the requirements source and target plan directory.
2. Planner produces plan.md + plan-details/* under ~/brain-dump/plans/<project>/<feature>/.
3. Planner emits plan-ready prompt to each execution role, then exits.
4. Generate builder/tester/reviewer prompts from the just-created plan.
5. Start three execution sessions.
```

**Pro tip:** If planning is short (~30 min), do it inline in your main session and skip the planner peer. Reserve a peer slot for planner only when planning is long enough to justify a dedicated session.

---

## 5. Consultant-on-call — builder + tester + db-consultant

Pair with an ambient specialist. Consultant sits idle; builder calls on demand.

**When to use:** builder is competent generally but occasionally hits domain questions (DB indexing, framework internals, security review of a single decision). Cheaper than a full reviewer.

**Roles:**

| Role          | Slice                                | Wakes when?                     |
|---------------|--------------------------------------|--------------------------------|
| Builder       | Builder slice + consult calls        | Always active                  |
| Tester        | Tester slice                         | Always active                  |
| DB-consultant | Consultant slice, domain="database"  | Only on `consult` prompt       |

**Directory:**

```
~/brain-dump/peer-prompts/<project>/<feature>/
├── builder-agent.md
├── tester-agent.md
├── db-consultant-agent.md
├── feedback-T-<XX>.md
└── consult-<NN>.md          # optional; created by consultant for reusable answers
```

**Message flow (a consult round):**

```
Builder                    DB-consultant
   │                            │
   │ [hits DB question mid T-04]│
   ├── consult ──────────────▶  │   peer_send type:"prompt", expectReply:true
   │                            │   content: "consult: how to index this hot query?
   │                            │           File: db/queries.rb:42
   │                            │           Current approach: SELECT * ... ORDER BY created_at
   │                            │           Constraint: no schema change
   │                            │           Question: fastest index for 10M rows?"
   │                            │
   │                            │ [thinks]
   │                            │
   │◀── reply ───────────────── │   peer_send type:"response"
   │                            │   content: "reply: how to index this hot query?
   │                            │           Recommendation: composite index (status, created_at DESC)
   │                            │           Rationale: ...
   │                            │           Alternatives considered: ...
   │                            │           Caveats: ...
   │                            │           Reusable note: consult-01.md"
   │ [applies advice]           │
   │ [continues T-04]           │
```

**To generate:**

```
1. Pick topology: sequential pair + on-demand consultant (TOPOLOGIES.md §4).
2. Roles: builder, tester, one or more consultants (one per domain).
3. In builder's prompt, list the consultants with their domains and remind builder to summon them for domain questions.
4. Consultant sessions consume little context — cheap to run.
5. If a consultant is called on every task, promote it to a reviewer or specialist-scanner role.
```

---

## Choosing between examples

| Signal                                                | Use example       |
|-------------------------------------------------------|-------------------|
| Small, well-scoped change, tests exist                | 1 — Pair          |
| Ship-quality, shared code, long-lived module          | 2 — Trio          |
| Production ship, security-critical, cross-subsystem   | 3 — Parallel review |
| Greenfield or ambiguous, needs plan first             | 4 — Planner-led   |
| Builder needs occasional domain input                 | 5 — Consultant    |

Composition: example 4 can wrap examples 1, 2, or 3 (planner runs first, then the execution shape). Example 5 can overlay on any of 1–4 (consultants coexist with any topology).
