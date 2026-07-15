---
name: peer-runner
description: >-
  Bootstrap and execute a generated peer-workflow role session. Load this skill when starting a Pi session as any peer-workflow role (builder, tester, reviewer, planner, security-scanner, performance-analyzer, documenter, deployer, consultant, researcher). It locates the matching <role>-agent.md prompt file, reads all referenced artifacts and skills in the correct order, runs the startup handshake, and enters the role's main loop. Triggers on: PI_PEER_ROLE is set at session start, user says "start as <role>", "load my role", "run as builder/tester/reviewer", "begin the peer workflow", or provides a feature directory path.
---

# Peer Runner

Boots a Pi session into a peer-workflow role. Three phases: **locate** the role file, **read** it and its dependencies, **run** the startup handshake.

---

## Phase 1 — Determine role and locate the prompt file

### Step 1 — Identify your role

Your role is in `PI_PEER_ROLE`. Confirm it:

```bash
echo $PI_PEER_ROLE
```

If the env var is empty and no role has been set, ask the user once: "What role should I run as? (builder / tester / reviewer / …)". Then call `peer_set_role({ role: "<answer>" })`.

The target file is always: `<role>-agent.md` where `<role>` is the value above.

### Step 2 — Find the file (priority chain, stop at first hit)

**Priority 1 — env vars**

If `PI_PEER_PROJECT` and `PI_PEER_FEATURE` are both set:

```bash
ls ~/brain-dump/peer-prompts/$PI_PEER_PROJECT/$PI_PEER_FEATURE/${PI_PEER_ROLE}-agent.md
```

If the file exists → use it. Skip to Phase 2.

If only one of the two vars is set, skip to Priority 2 (partial vars are not reliable).

**Priority 2 — current working directory**

Search the cwd and one level of subdirectories:

```bash
find . -maxdepth 2 -name "${PI_PEER_ROLE}-agent.md" 2>/dev/null | head -1
```

If found → use it. Skip to Phase 2.

**Priority 3 — ask the user**

Neither env vars nor cwd produced the file. Ask once:

> "I'm starting as **`<role>`** but can't find `<role>-agent.md`.
> Please do one of:
> 1. Paste the full file path
> 2. Set `PI_PEER_PROJECT=<project> PI_PEER_FEATURE=<feature>` and restart
> 3. Run from the directory that contains `<role>-agent.md`"

Accept a path or pasted content. If a path is given, verify it exists before continuing.

---

## Phase 2 — Read in order

Read the located `<role>-agent.md` first, then pull in its dependencies. Follow this exact sequence — do not skip sections, do not reorder.

```
1. Read the full <role>-agent.md
   Internalize: role description, peers table, project info (repo path, build command),
   feedback style, startup handshake steps, main loop, and shared guardrails.

2. Read each skill file in ## Available Skills (use the Path column)
   Read them in table order. If a path does not exist on disk, note it
   ("skill <name> not found at <path> — continuing without it") and move on.
   Do not halt.

3. Read plan artifacts from ## The Plan (Plan root path is given there)
   Read in this order: plan.md → 01-context.md → 02-requirements.md →
   03-tasks.md → 05-testing.md → any other listed files.
   If a file is missing, note it and continue.

4. Do NOT read feedback files now.
   feedback-T-XX.md and feedback-<role>-NN.md are read on demand
   when a FAIL message arrives in the main loop.
```

After reading, verify internally that you know:
- What your role owns and does NOT own
- Who your peers are and what role names to use in `to:`
- Your feedback style (task-scoped or issue-scoped)
- The exact trigger phrases for your main loop (task-done, test-pass, stage-handoff, etc.)
- The build/verify command from ## Project Info

If any of these is unclear, re-read the relevant section of the role file before proceeding.

---

## Phase 3 — Run the startup handshake

First classify your role from **## Main Loop** step 1 in the role file:

- **Waiter** — step 1 begins with "End your turn. You are woken by …" (tester, reviewer, security-scanner, performance-analyzer, documenter, deployer, consultant, researcher). Waiters do nothing until a peer wakes them.
- **Initiator** — step 1 is an action, e.g. "Implement current task" (builder) or "Read requirements …" (planner). Initiators produce the first handoff and must start working, not wait.

Then run these steps in order:

```
1. cd <REPO_PATH>  (from ## Project Info > Repo in the role file)

2. peer_list
   See which peers are online and confirm their roles show correctly
   (role-bearing peers list first). Note which peers named in ## Peers are present.
   Do NOT block startup on absent peers here — readiness messages don't wake anyone,
   so blocking would deadlock. Presence only gates handoffs (see step 5).

3. peer_send type:"message" to each present expected peer (address by role):
   "<READINESS_LINE from the role file's startup handshake section>"

   Use type:"message" for readiness lines — they are informational and must NOT
   wake peers. Never use type:"prompt" during the handshake.

4. Check /peer status to confirm your own identity, role, and inbox are clean.

5. Branch on your role class:
   • Waiter → End your turn. You are woken automatically by an injected prompt or
     response when a peer hands off to you. Do not poll. Do not send anything else.
   • Initiator → Proceed directly into ## Main Loop step 1 and start working.
     Before each handoff prompt, confirm the target peer is present with peer_list
     (a prompt to an absent peer is lost — no durable queue). If the target is
     missing, peer_send type:"message" to it is pointless; instead end your turn and
     retry when woken, or tell the human the target role never came online.
```

---

## Entering the main loop

Follow the **## Main Loop** in your role file exactly. A **waiter** is idle until woken; an **initiator** begins at step 1 immediately.

Carry these reminders into every iteration:

| Rule | Detail |
|------|--------|
| Always specify `type:` | Every `peer_send` must have `"message"`, `"prompt"`, or `"response"` |
| `expectReply: true` is UI-only | It shows a waiting indicator in the widget; it never blocks |
| Read inbox with `peer_get(clear: true)` | Only for passive `type:"message"` entries; `prompt`/`response` inject automatically |
| Build before signaling | Run `{{BUILD_COMMAND}}` (from ## Project Info) before every task-done or fix-done trigger |
| 3-iteration cap | After 3 failed attempts on the same feedback file, escalate to human — do not re-open a 4th time |
| Never touch another role's section | In a feedback file: builder owns `## Fix`, tester/reviewer own `## Issue` and `## Verification` |
| Address peers by role | `to: "tester"` not `to: "agent-fd4ff"` — use role names from ## Peers |

---

## Failure modes

| Problem | What to do |
|---------|-----------|
| Role file not found after all three lookup steps | Stop. Show the three options from Priority 3 to the user. |
| Skill file path does not resolve | Log: "skill `<name>` not found at `<path>` — skipping." Continue. |
| Plan artifact missing | Log: "plan file `<path>` not found — continuing with available context." Notify peers in your readiness message that some plan files are absent. |
| Required peer absent at startup | Waiter: end turn, wait to be woken. Initiator: start work anyway; only block right before a handoff prompt to the missing peer (retry `peer_list`, or tell the human that role never came online). |
| Woken by an unrecognised message | Call `peer_get(clear: true)` to check passive inbox. If still unclear, `peer_send type:"message"` to the sender asking for clarification. Do not guess the trigger. |
| `peer_set_role` rejected (duplicate role) | Call `peer_list`. If the other session holding the role is stale, it will expire on its own (heartbeat every 5 s). Do not force. Wait and retry. |
| Role file found but unparseable or blank | Show the path and first 10 lines to the user and ask how to proceed. |
