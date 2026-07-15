# Implementation Protocol

How to convert approved TODO proposal comments into real, working code.

This phase runs only after the proposal MR has been reviewed and all 🔴 comments
are resolved. The TODO comments are the specification — the implementation must
match what they describe.

---

## The implementation contract

The proposal review created an agreement with the human about what will be changed,
where, and why. This protocol holds the implementation to that agreement.

**The rule**: Every TODO comment describes a specific change. The implementation must
deliver that change exactly as described. If delivering the change would require
something not described in the TODO, flag it before writing that code.

Deviating from the TODOs without flagging is a trust violation — the human approved
a plan, and now they would get something different. Use `blocker-protocol.md` whenever
the implementation reveals a need to deviate.

---

## Pass order

Work file by file in the same order the TODO comments were added during the proposal pass.
This keeps changes coherent and makes the implementation commit diff easy to follow.

For each file:
1. Open the file.
2. Find the first `// TODO [T-XX]:` comment.
3. Read it fully — understand what it describes before writing any code.
4. Write the implementation code that fulfills the TODO description.
5. Remove the `// TODO [T-XX]:` comment line (the implementation replaces it, not accompanies it).
6. Move to the next TODO in the same file.
7. After all TODOs in a file are resolved, move to the next file.

---

## Translating TODO types into code

### Add
```js
// TODO [T-01]: Add idempotency check before processEvent() — queries Redis for event.id.
// Return 200 immediately if found. Store key with 24h TTL before continuing.
```
→ Write the idempotency check code at that line. Remove the TODO comment.

### Change
```js
// TODO [T-03]: Change this response from 500 to 409 — duplicate events are not server errors.
res.status(500).json({ error: 'Internal server error' });
```
→ Modify the line(s) below the TODO to implement the change. Remove the TODO comment.

Result:
```js
res.status(409).json({ error: 'Duplicate event', eventId: event.id });
```

### Remove
```js
// TODO [T-02]: Remove this call — replaced by WebhookHandler.process() in T-03.
processWebhook(event);
```
→ Delete both the TODO comment line and the `processWebhook(event)` line.

### New file
For a new file created during the proposal pass with structural TODO comments:
→ Write the full implementation of each structural TODO in order. Remove each TODO
as you implement it. The file should contain zero TODO comments when done.

---

## Implementation quality rules

**Follow the plan steps precisely.** The plan detail file contains step-by-step
instructions for how to implement the task. The TODO comments are the *what* and *where*
— the plan steps are the *how*. Read the task steps in full before writing any code.

**Match the surrounding code style.** If the file uses 2-space indentation, use 2 spaces.
If it uses TypeScript strict mode types, add types. If it uses a specific error handling
pattern, follow it. The implementation should look like it belongs in the file.

**Keep changes minimal.** Implement exactly what the TODO describes, no more. If you
notice a related issue nearby (a bug, an opportunity for improvement), do not fix it
silently — note it as an advisory (see `blocker-protocol.md` — ⚪ Advisory type) and
move on. Scope creep in implementation is hard to review and easy to miss.

**Write tests if the plan specifies them.** If the task's plan detail file includes
a testing section, implement those tests as part of this pass. They are part of the
task's "Done when" criteria.

---

## Verifying "Done when" criteria

After all TODO comments in all files have been replaced with code, verify the task's
exit criteria one by one. Read the criteria from the plan detail file.

For each criterion:
- Run the command / test / verification that confirms it.
- Report the actual result, not just "done".
- If a criterion cannot be verified (e.g., needs staging access), mark it as
  `⚠️ unverified` and invoke `blocker-protocol.md`.

**Explicit is required.** Do not mark a criterion as satisfied unless you can show
evidence. "I implemented it" is not evidence. A passing test, a command output, or
a log entry is evidence.

Example verification report:
```
Done when (T-01):
- [x] Duplicate event returns 200 ✅ tested: POST /webhook with same event_id twice
       → first call: 200 + processed; second call: 200 + skipped (Redis key found)
- [x] Redis key created with 24h TTL ✅ confirmed:
       `redis-cli TTL webhook:idempotency:evt_123` → 86399 (≈24h)
- [x] Unit tests pass ✅ `npm test -- --grep idempotency` → 4 passed, 0 failed
```

---

## No TODO comments in the final commit

Before committing the implementation, verify that no `// TODO [T-XX]:` comments remain
in the changed files:

```bash
git diff feature/<feature-name> -- '*.ts' '*.js' | grep "TODO \[T-"
```

This must return empty. If any TODO comments remain, they are either:
- A TODO you forgot to implement → implement it now.
- A scoped-out TODO that should be removed without implementation → remove the comment.

Do not leave TODO comments in the implementation commit. They confuse the code review
because the reviewer won't know which TODOs are implemented vs. pending.

---

## Handling implementation surprises

Sometimes implementation reveals that the approved proposal was incomplete — a file
the TODOs didn't mention needs to change, or the approach doesn't work as described.

**Do not silently expand the scope.** Use `blocker-protocol.md` to surface it:

```
⚠️ Implementation blocker — T-01 scope wider than proposed

The approved proposal didn't include `src/types/webhook.ts`, but implementing
the idempotency check requires adding an `IdempotencyResult` type there.

Options:
[A] Add the type to src/types/webhook.ts as part of T-01 (small, low-risk addition)
[B] Create a proposal-amendment commit covering this addition and ask for a quick re-check
[C] Create the type inline in handler.ts instead (avoids touching types/ but less clean)

→ My recommendation: [A] — it's a type definition, not logic, and adds to what was approved.
What would you prefer?
```

---

## Commit message format

Use conventional commits for the implementation commit:

```
feat(T-01): add idempotency key check for webhook processing

- Queries Redis for event.id before processing
- Returns 200 early if key found (duplicate suppression)
- Stores key with 24h TTL after processing
- Addresses plan task T-01 (stripe-webhook-refactor)
```

For bug fixes discovered during implementation: `fix(T-01): ...`
For refactors: `refactor(T-01): ...`
For tests only: `test(T-01): ...`

Always include the task ID in the scope — it keeps the git log traceable to the plan.
