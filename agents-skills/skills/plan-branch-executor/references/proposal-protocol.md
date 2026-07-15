# Proposal Protocol

How to annotate code with `// TODO` proposal comments — the format, the placement,
and the content — so the human can review intent before any implementation code is written.

**The core rule**: during the proposal pass, the only changes allowed to existing code
are adding `// TODO [T-XX]:` comments. No logic is removed, no behavior is changed,
no new functional code is added. The diff should be entirely comment lines.

---

## Why TODO comments, not a design doc

A TODO-comment proposal lives inside the actual files that will change. The reviewer
sees the exact locations, the exact surrounding context, and the exact intent in one
diff. This is more precise than a separate design doc and more reviewable than a wall
of prose — the MR diff becomes the specification.

---

## TODO comment format

```
// TODO [T-XX]: <verb> <what> — <why>
```

- `[T-XX]` is the task identifier from the plan. Always include it so comments are
  traceable back to the task and easy to search-and-remove after approval.
- `<verb>` is one of: `Add`, `Change`, `Remove`, `Move`, `Extract`, `Replace`
- `<what>` is a short description of the thing being acted on (function name, block, field)
- `<why>` explains the reason — the business logic, the bug being fixed, the constraint
  being satisfied. This is the part most likely to surface disagreements during review.

**Good examples:**
```js
// TODO [T-01]: Add idempotency check before processing — prevents duplicate charges
// if the same webhook event is delivered more than once by Stripe's retry policy.

// TODO [T-02]: Remove legacy `processWebhook()` call — replaced by the new
// `WebhookHandler.process()` below; the legacy version doesn't verify signatures.

// TODO [T-03]: Change error response from 500 to 409 — a duplicate event is not
// a server error; returning 500 causes Stripe to retry indefinitely.
```

**Bad examples (do not use):**
```js
// TODO: Add check               ← no task ID, no why, too vague
// TODO [T-01]: refactor this    ← no what, no why
// TODO: see plan                ← useless, says nothing
```

---

## Placement rules

### Adding new code
Place the TODO comment at the exact line where the new code will be inserted.
The comment should be on its own line — not inline with existing code.

```js
function handleWebhook(event) {
  // TODO [T-01]: Add idempotency check here — query Redis for event.id before
  // processing. Return 200 immediately if found (already processed). If not found,
  // store the key with a 24h TTL before continuing.
  return processEvent(event);
}
```

### Changing existing code
Place the TODO comment directly above the line(s) being changed. Leave the existing
code exactly as-is below the comment.

```js
// TODO [T-03]: Change this error response from 500 to 409 — duplicate events
// are not server errors; see plan decision D-02 for rationale.
res.status(500).json({ error: 'Internal server error' });
```

### Removing existing code
Place the TODO comment directly above the line(s) being removed. Leave the code
exactly as-is below the comment.

```js
// TODO [T-02]: Remove this call — replaced by WebhookHandler.process() in T-03.
// Safe to remove after T-03 is merged; nothing else calls processWebhook() directly.
processWebhook(event);
```

### Multi-line blocks
For a block of changes (e.g., an entire function being rewritten), place one TODO
comment before the block. Do not annotate every line.

```js
// TODO [T-04]: Replace this entire function with a class-based WebhookHandler.
// The new implementation adds signature verification, idempotency, and structured
// logging. The function signature stays the same so callers don't need to change.
function handleWebhook(req, res) {
  // ... existing code untouched ...
}
```

---

## New files

For a new file that will be created, create the file during the proposal pass
containing only the file-level TODO and structural TODOs — no implementation code.

```ts
// TODO [T-04]: Create this file — the WebhookHandler class that replaces the
// inline webhook processing in routes/webhooks.ts. See plan T-04 for full spec.

// TODO [T-04]: Export class WebhookHandler with constructor(config: WebhookConfig)
// — accepts signingSecret and redisClient so both can be injected in tests.

// TODO [T-04]: Add method process(event: WebhookEvent): Promise<ProcessResult>
// — main entry point. Runs: verifySignature → checkIdempotency → dispatch → storeKey.

// TODO [T-04]: Add private method verifySignature(payload, sig): boolean
// — uses crypto.createHmac('sha256', signingSecret). Throws WebhookSignatureError
// if verification fails (caller should return 401).
```

---

## Files not touched

Do not create or modify files that the task will not touch. Only open the files
that the plan detail file explicitly names as change targets.

If you realize during the proposal pass that a file not mentioned in the plan also
needs to change, note it with a `⚠️ ASSUMPTION` comment and flag it to the user:

```js
// ⚠️ ASSUMPTION [T-04]: This change may also require updating tests/webhooks.test.ts
// — the test currently imports the old function directly. Will flag this for review.
```

---

## MR description template

Use this template for the draft MR body:

```markdown
## Proposal — [T-XX]: <task title>

**This MR contains only TODO annotation comments. No functional code has been changed.**
**Do not approve for implementation until you have reviewed the proposed change locations.**

### What this task will do
<one paragraph from the plan's task description>

### Files that will change
- `src/webhooks/handler.ts` — add idempotency check, remove legacy call
- `src/webhooks/signature.ts` — new file: signature verification
- `src/routes/webhooks.ts` — update import from inline handler to WebhookHandler class

### Key decisions reflected here
- Using Redis for idempotency keys (Decision D-01)
- 409 response for duplicates (Decision D-02)

### Review guidance
Look at each TODO comment and ask:
- Is this the right place for this change?
- Does the explanation make sense?
- Is there anything you want moved, removed, or reconsidered?

Leave comments on specific lines in the diff. Reply in the chat session when done reviewing.
```

---

## What the reviewer should comment on

Encourage the reviewer to focus on:
- **Location**: Is the change going in the right file / function / line?
- **Approach**: Does the described implementation match the intent?
- **Scope**: Is anything being added that shouldn't be (scope creep), or missing?
- **Naming**: Will the new functions / variables / files use the right names?

The reviewer should NOT comment on:
- Code style (there is no code yet)
- Implementation details that weren't described in the TODO (those come in the impl review)

---

## After approval: removing TODO comments

Once the proposal is approved (no 🔴 comments), the implementation pass starts by
removing each `// TODO [T-XX]:` comment and replacing it with actual code. Never
leave TODO comments in the final implementation commit.

A good way to verify no TODO comments remain after implementation:

```bash
git diff feature/<feature-name> -- '*.ts' '*.js' | grep "TODO \[T-0"
```

This should return empty before the MR is marked ready.
