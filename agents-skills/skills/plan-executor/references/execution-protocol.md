# Execution Protocol

How to run tasks from a plan file — precisely, verifiably, and with the human informed
at every meaningful step.

---

## The task execution loop

For each task in the current detail file:

```
1. READ the task fully before doing anything
2. BRIEF the user (one sentence: "Doing X now")
3. DO the work, step by step as written
4. VERIFY the "Done when" criteria, one by one
5. REPORT the outcome
6. ADVANCE to the next task
```

Never skip step 1 — reading a task fully before starting prevents mid-task surprises.
Never skip step 4 — unverified exit criteria are the most common source of regressions.

---

## Step 1: Read the task fully

Before starting any task, read:
- The task title and priority
- The preconditions (what must already be true)
- All steps
- The "Done when" criteria
- Any `⚠️ ASSUMPTION` blocks within the task
- Any code sketches (they often clarify what "step 3" means)

If a precondition isn't met (e.g., Task T-03 requires T-02 to be complete and it isn't),
stop and invoke `blocker-protocol.md` before doing anything.

---

## Step 2: Brief the user

One line, before starting:

> `▶ T-03: Creating the idempotency key table in Redis...`

For longer tasks (effort M or L), add what the user will see when it's done:

> `▶ T-04 (est. ~30 min): Setting up the webhook signature verifier.`
> `When this is done, POST /webhook with a bad signature will return 401 instead of 200.`

This primes the user to evaluate the output without reading the whole task themselves.

---

## Step 3: Execute steps as written

The plan was written as junior-developer–level instructions. Follow them literally.
Do not skip steps, combine steps, or take shortcuts.

**When a step specifies an exact command**, run it exactly:
```bash
npm run migrate -- --env staging --dry-run
```
Not a paraphrase, not a variation. If you believe the command is wrong, flag it as
a blocker — don't silently substitute.

**When a step specifies a file path**, use that exact path. If the file doesn't exist
at that path, that's a blocker — not a reason to guess.

**When a step includes a code sketch**, treat it as the intended shape of the solution.
The sketch shows the approach; you may fill in details the sketch left abstract, but
do not change the approach without flagging it.

**When a step says "see X file"**, read that section before continuing. These cross-
references are usually there because the plan author knew you'd need the context.

---

## Step 4: Verify "Done when" criteria

Every task has "Done when" criteria. These are not suggestions — they are the exit gate.

Verify each criterion explicitly:

```
Done when:
- [x] `createUser` called with `email="notanemail"` returns 400 ✅ confirmed (tested)
- [x] `age=-1` returns 400 with `{ error: "Invalid age" }` ✅ confirmed (tested)
- [ ] Unit tests added for both paths ❌ — tests written but one is failing (see blocker)
```

If a criterion involves observable behavior (a command output, an HTTP response, a log
message), produce the evidence. Don't just say "done" — show it.

If a criterion can't be verified (e.g., needs staging access you don't have), mark it
as unverified and invoke `blocker-protocol.md`.

---

## Step 5: Report the outcome

After a task completes successfully, report briefly using this format:

```
✅ T-03 done — idempotency key table created in Redis.
   Key format: `webhook:idempotency:{event_id}` with 24h TTL.
   Verified: duplicate POST /webhook with same event_id returns 200 (idempotent, not 500).
```

Keep it short. The human doesn't need a narrative — they need to know it worked
and how to verify it themselves if they want to.

---

## Step 6: Advance to the next task

After reporting:
- If this is the last task in a phase → go to the **phase boundary checkpoint** (below)
- Otherwise → loop back to Step 1 with the next task

**Do not report two task completions in a single message.** One task per message.
This gives the human a natural pause point to intervene, ask questions, or redirect.

---

## Phase boundary checkpoints

At the end of each phase (or every 3–4 tasks for large phases), pause:

```
## ✅ Phase 1 complete — Webhook handler refactor

Done:
- T-01: Removed legacy handler (`webhooks/legacy.ts` deleted)
- T-02: Created `webhooks/handler.ts` with idempotency logic
- T-03: Redis key table created and verified

Next: Phase 2 — Signature verification (tasks T-04, T-05)
This will add HMAC-SHA256 verification to all incoming webhook events.

→ Ready to continue? (reply "go" or tell me if you need to review anything first)
```

**Wait for explicit confirmation before loading the next phase file.**
This is not optional — the checkpoint is the human's last chance to catch anything
before the next phase of changes lands.

---

## Handling task dependencies mid-execution

Some tasks depend on results produced by earlier tasks (e.g., a database ID, a generated
file path, an API key). The plan may leave these as `[TBD]` placeholders with a note
like "use the value from T-02".

When you encounter this:
1. Retrieve the actual value from what T-02 produced
2. Substitute it into the current task's steps
3. State the substitution: "Using Redis URL from T-02: `redis://staging:6379`"

Never leave a `[TBD]` unresolved when the value is available. If the value genuinely
isn't available yet, that's a blocker.

---

## Parallel tasks

If the execution order or the phase file explicitly marks tasks as parallelizable
(e.g., "T-04 and T-05 can run concurrently"), you may execute them together and
report both in a single message. Do not declare tasks parallelizable on your own
— only follow the plan's explicit guidance.

---

## When a step produces unexpected output

If a command or action produces output that doesn't match what the plan's
"State what correct output looks like" section says you should see:

1. Show the unexpected output
2. Compare it to the expected output from the plan
3. Invoke `blocker-protocol.md` — do not try to diagnose and fix on your own without
   telling the user

The only exception: if the output is a cosmetic difference (e.g., different log
timestamp format, extra whitespace), and all functional criteria are still met, proceed
and note it: "Output differed cosmetically from plan — functional criteria all met."
