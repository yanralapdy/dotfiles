# Peer Protocol

Wire-level conventions every agent in the team follows. Message types, startup handshake, lifecycle triggers, and escalation. Not role-specific — every role in [ROLES.md](ROLES.md) obeys this.

## Message types

The pi-peer extension exposes two message kinds. Use each intentionally.

| Kind      | Semantics                                              | Use for                                        |
|-----------|--------------------------------------------------------|------------------------------------------------|
| `prompt`  | Auto-injects into the receiver's session as a user turn and wakes it | Handoffs, task-done, PASS/FAIL, escalation     |
| `response`| Auto-injects as a follow-up user turn once the receiver is idle (never interrupts a streaming turn) | Replies to a `prompt`, completing a handoff    |
| `message` | Notification only — lands in the inbox, does NOT wake the receiver | Status updates, "heads up" pings, non-blocking info |

Rule: **any transition that changes what the receiver should do next is a `prompt`** (replied to with `response`). Everything else is a `message`.

Delivery is event-driven and best-effort, session-lifetime only. There is **no `peer_await`** — agents end their turn and are woken automatically when a `prompt`/`response` arrives. Passive `message` entries stay in the inbox and are read with `peer_get`. If the receiver is offline when a message is sent, the message is lost (no durable queue).

## Tools

### `peer_list`

List active peers in the current project. Role-bearing peers appear first, then role-less peers. Output includes role, short ID (`agent-<hex>`), model, status, context usage, and last-seen time.

### `peer_send`

Send a message to another peer. **Resolve target by role first** — that is the preferred addressing form.

```
peer_send(
  to: "tester",                              # role (preferred) | sessionName | agent-<hex>
  content: "T-01 done. Files: [...]. Please test.",
  type: "prompt",                            # "message" | "prompt" | "response"
  expectReply: true                          # optional; UI-only status flag — never blocks
)
```

**Address resolution order:** role → sessionName → exact `agent-<hex>` ID → displayName. First match wins. If two agents claim the same role, the most-recently-seen wins and the sender is warned.

`expectReply: true` shows a waiting-for-reply indicator in the live widget. It has no effect on delivery and never causes the sender to block.

### `peer_set_role`

Set, change, or clear this session's role at runtime.

```
peer_set_role({ role: "builder" })   # claim a role
peer_set_role({ role: "none" })      # clear role (also accepts: "empty", "null", "unset", "clear")
```

When a role is set, pi-peer also calls `pi.setSessionName(role)` so the session selector shows the role name. Role remains the authoritative addressing key; session name is just a display label. **Duplicate live roles are rejected**: if `PI_PEER_ROLE=builder` is already held by an active peer, the new session starts role-less and shows a warning.

### `peer_get`

Read passive inbox messages (`type: "message"`). Prompts and responses are delivered directly into the conversation as injected user messages and are never polled here.

```
peer_get(clear: true)    # read and clear the inbox in one call
peer_get()               # read without clearing
```

There is intentionally **no `peer_await`**. End the turn; the next `prompt`/`response` wakes the agent automatically.

## Slash commands

The extension registers `/peer` sub-commands for human inspection — agents don't need to call these, but they are useful during debugging:

| Command         | What it shows                                       |
|-----------------|-----------------------------------------------------|
| `/peer list`    | All active peers in the project                     |
| `/peer status`  | This session's identity, role, waiting state, inbox count |
| `/peer inbox`   | Passive inbox messages                              |
| `/peer clear`   | Clear passive inbox                                 |
| `/peer whoami`  | This session's identity and role                    |

## Session startup — the handshake

Every agent runs this on session start, before any project work. The role is seeded deterministically from `PI_PEER_ROLE` by the extension; `peer_set_role` can change or clear it at runtime.

```
1. cd <REPO_PATH>
2. Read the plan artifacts assigned to this role (see role prompt)
3. Read the skills listed in the role prompt
4. peer_list  → confirm peers are online and see their roles (role-bearing peers list first)
5. peer_send type: "message", to each expected peer (address by role, e.g. to: "tester"):
   "<ROLE> online. <role-specific readiness line>"
6. End your turn. You will be woken automatically by an injected prompt/response when a peer hands off to you.
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

| # | Trigger                                     | Sender  | Receiver | Type    | Body                                                             |
|---|---------------------------------------------|---------|----------|---------|------------------------------------------------------------------|
| 1 | task-start                                  | Builder | Tester   | message | "Starting T-XX (`<desc>`). ETA `<N>`m."                          |
| 2 | task-done                                   | Builder | Tester   | prompt  | "T-XX done. Files: `<list>`. Done-when: `[x]`... Please test."   |
| 3 | test-ack                                    | Tester  | Builder  | message | "Ack. Testing T-XX. ETA `<N>`m."                                 |
| 4 | test-pass                                   | Tester  | Builder  | prompt  | "T-XX PASS. Proceed."                                            |
| 4'| test-fail                                   | Tester  | Builder  | prompt  | "T-XX FAIL. See `feedback-T-XX.md`. Fix and re-notify."          |
| 5 | fix-done                                    | Builder | Tester   | prompt  | "T-XX fixed per feedback-T-XX.md `## Fix`. Please re-test."      |
| 6 | escalation                                  | Tester  | Builder + human | prompt  | "T-XX failed 3 iterations. Human review needed."         |

Between stages (e.g., all-tasks-done → reviewer), the protocol adds two more triggers:

| # | Trigger                                     | Sender | Receiver | Type   | Body                                                                                             |
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
peer_send(
  to: "<specialist-role>",
  type: "prompt",
  expectReply: true,
  content: """
    === consult: <one-line question> ===
    Context:
      - File: <path>
      - Current approach: <2-line sketch>
      - Constraint: <e.g., must not add dependency>
    Question: <exact question>
    Deadline: <how urgent — "before continuing T-XX" or "before EOD">
  """
)
```

Specialist replies with `type: "response"` to caller:

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
peer_send(
  to: "<human_agent_name>",   # cc the other peer with a separate message
  type: "prompt",
  content: """
    === ESCALATION ===
    Reason: <one of the triggers above>
    Context: <link to feedback file or plan section>
    What I tried: <bullet list of attempts>
    What I need: <specific decision — "should I proceed anyway?" or "is the plan correct?">
    Blocked: <what I stop doing until answered>
  """
)
```

After escalating, the agent stops on that thread and waits. It may continue **unblocked** work on other tasks.

## Idle behaviour

Agents that wait (reviewer, documenter, deployer, consultant, researcher) are woken automatically — they do nothing until a `prompt` or `response` arrives. Concretely:

- Do **not** poll `peer_get` waiting for a handoff. End your turn; the next `prompt`/`response` injects as a new user turn.
- `peer_get` is only for reading passive `message` entries (status pings, readiness) that did not wake you.
- Emit a `message` (not `prompt`) heartbeat only if asked. Don't spam status.
- Read your skill docs and plan artifacts once at startup; don't re-read on every wake.
- Exit the role loop when your `stage-done` output is emitted (deployer/documenter). Planner exits after producing the plan.

## What NOT to do

- **Do not** poll or block waiting for a handoff. There is no `peer_await`. End the turn; the receiver is woken by the next injected `prompt`/`response`.
- **Do not** wake a peer with `prompt` for informational updates. Use `message`. Prompt is a wake signal.
- **Do not** invent trigger phrases. If your topology needs a new one, add it to the trigger table above first.
- **Do not** send a fresh feedback file when re-testing. Update the existing file in place; the file IS the state machine.
- **Do not** cc every peer on every message. Address the intended recipient; leave others idle.
- **Do not** collapse the handshake by "just implementing." Startup handshake makes coordination legible.
- **Do not** omit `type:` from `peer_send`. Always specify `"message"`, `"prompt"`, or `"response"` explicitly.
- **Do not** use `peer_set_role` to claim a role already held by a live peer — the call will be rejected. Check `peer_list` first.
