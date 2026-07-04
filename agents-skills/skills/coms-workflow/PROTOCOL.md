# Coms Protocol

Wire-level conventions every agent in the team follows. Message types, startup handshake, lifecycle triggers, and escalation. Not role-specific — every role in [ROLES.md](ROLES.md) obeys this.

## Message types

The coms extension exposes two message kinds. Use each intentionally.

| Kind      | Semantics                                              | Use for                                        |
|-----------|--------------------------------------------------------|------------------------------------------------|
| `prompt`  | Wakes the receiver — enters their conversation as user turn | Handoffs, task-done, PASS/FAIL, escalation     |
| `message` | Notification only — appears without prompting the receiver | Status updates, "heads up" pings, non-blocking info |

Rule: **any transition that changes what the receiver should do next is a `prompt`**. Everything else is a `message`.

## Session startup — the handshake

Every agent runs this on session start, before any project work:

```
1. cd <REPO_PATH>
2. Read the plan artifacts assigned to this role (see role prompt)
3. Read the skills listed in the role prompt
4. coms_list  → learn which peers are online
5. coms_send message "<ROLE> online. <role-specific readiness line>" to each expected peer
6. Enter the role's main loop (see role prompt for whether to poll or wait for prompt)
```

**Readiness lines by role:**

| Role                | First message                                                             |
|---------------------|---------------------------------------------------------------------------|
| Builder             | "Builder online. Starting T-01."                                          |
| Tester              | "Tester online. Ready to verify."                                         |
| Reviewer            | "Reviewer online. Standing by. Notify me when tester signals all-pass."   |
| Security-scanner    | "Security online. Standing by for review handoff."                        |
| Performance-analyzer| "Perf online. Standing by for review handoff."                            |
| Planner             | "Planner online. Producing plan.md now."                                  |
| Researcher          | "Researcher online. Waiting for `research` requests."                     |
| Consultant (`<domain>`) | "`<domain>`-consultant online. Waiting for `consult` requests."       |
| Documenter          | "Documenter online. Waiting for reviewer PASS."                           |
| Deployer            | "Deployer online. Waiting for documenter PASS."                           |

## Task lifecycle — the six standard triggers

Every task moves through six trigger messages between builder and tester. Reviewer's messages follow the same shape but at the whole-plan grain.

| # | Trigger                                     | Sender  | Receiver | Kind    | Body                                                             |
|---|---------------------------------------------|---------|----------|---------|------------------------------------------------------------------|
| 1 | task-start                                  | Builder | Tester   | message | "Starting T-XX (`<desc>`). ETA `<N>`m."                          |
| 2 | task-done                                   | Builder | Tester   | prompt  | "T-XX done. Files: `<list>`. Done-when: `[x]`... Please test."   |
| 3 | test-ack                                    | Tester  | Builder  | message | "Ack. Testing T-XX. ETA `<N>`m."                                 |
| 4 | test-pass                                   | Tester  | Builder  | prompt  | "T-XX PASS. Proceed."                                            |
| 4'| test-fail                                   | Tester  | Builder  | prompt  | "T-XX FAIL. See `feedback-T-XX.md`. Fix and re-notify."          |
| 5 | fix-done                                    | Builder | Tester   | prompt  | "T-XX fixed per feedback-T-XX.md `## Fix`. Please re-test."      |
| 6 | escalation                                  | Tester  | Builder + human | prompt  | "T-XX failed 3 iterations. Human review needed."         |

Between stages (e.g., all-tasks-done → reviewer), the protocol adds two more triggers:

| # | Trigger                                     | Sender | Receiver | Kind   | Body                                                                                             |
|---|---------------------------------------------|--------|----------|--------|--------------------------------------------------------------------------------------------------|
| 7 | stage-handoff                               | Tester | Reviewer | prompt | "All tasks PASS. Handing off to reviewer. Ready for architecture/perf/security review."          |
| 8 | stage-return                                | Reviewer | Builder | prompt | "Review complete. `<N>` issue(s). See feedback-review-\*.md. Fix and re-notify for re-review."   |

## Handoff message shape

A handoff crosses a topology stage boundary. It must include:

```
=== <SENDER> → <RECEIVER> handoff ===
Stage complete: <what just finished>
Ready for: <what the receiver should do next>
Artifacts:
  - <file 1>
  - <file 2>
Feedback thus far: <link to feedback files, or "none">
Next expected reply: <PASS/FAIL, ETA>
```

Every arrow in a [TOPOLOGIES.md](TOPOLOGIES.md) diagram must have a matching handoff message. If a topology arrow has no defined message, the topology is under-specified — fix the topology first.

## Consult / research requests

For on-demand roles (consultant, researcher):

```
coms_send prompt to <specialist>:

=== consult: <one-line question> ===
Context:
  - File: <path>
  - Current approach: <2-line sketch>
  - Constraint: <e.g., must not add dependency>
Question: <exact question>
Deadline: <how urgent — "before continuing T-XX" or "before EOD">
```

Specialist replies **prompt** to caller with:

```
=== reply: <same one-line question> ===
Recommendation: <the answer>
Rationale: <why>
Alternatives considered: <if relevant>
Caveats: <edge cases, tradeoffs>
Reusable note: <path to consult-NN.md if worth saving, else "none">
```

## Escalation to human

Trigger any of:

- Same issue fails 3 iterations
- Agent cannot reproduce a reported bug after 2 attempts
- Two agents disagree on a recommendation and neither will yield
- Plan appears wrong (agent flags "the plan says X but the code needs Y")
- Consultant is unreachable when needed

Format:

```
coms_send prompt to <human_agent_name> (and cc the other peer):

=== ESCALATION ===
Reason: <one of the triggers above>
Context: <link to feedback file or plan section>
What I tried: <bullet list of attempts>
What I need: <specific decision — "should I proceed anyway?" or "is the plan correct?">
Blocked: <what I stop doing until answered>
```

After escalating, the agent stops on that thread and waits. It may continue **unblocked** work on other tasks.

## Idle behaviour

Agents that wait (reviewer, documenter, deployer, consultant, researcher) should:

- Long-poll `coms_get`, don't tight-loop.
- Emit a `message` (not `prompt`) heartbeat only if asked. Don't spam status.
- Read their skill docs and plan artifacts once at startup; don't re-read on every poll.
- Exit the role loop when their `stage-done` output is emitted (deployer/documenter). Planner exits after producing the plan.

## What NOT to do

- **Do not** wake a peer with `prompt` for informational updates. Use `message`. Prompt is a wake signal.
- **Do not** invent trigger phrases. If your topology needs a new one, add it to the trigger table above first.
- **Do not** send a fresh feedback file when re-testing. Update the existing file in place; the file IS the state machine.
- **Do not** cc every peer on every message. Address the intended recipient; leave others idle.
- **Do not** collapse the handshake by "just implementing." Startup handshake makes coordination legible.
