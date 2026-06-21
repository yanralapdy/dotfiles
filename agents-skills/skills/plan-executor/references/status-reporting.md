# Status Reporting

How to communicate plan execution progress in chat — clearly, concisely, and without
burying the human in noise.

The golden rule: **the human should always know where we are, what just happened,
and what's coming next — without having to ask.**

---

## Message types and when to use each

### 1. Plan loaded (once, at orientation)
After reading `plan.md`. Sets the human's expectations for the whole session.

```
**Plan loaded**: `{project-name} / {feature-name}`
Session type: {Review / Grill-me / Casual}
{N} tasks across {M} phases. Goal: {one sentence goal state from plan.md}.
Running pre-flight check now to surface any blockers before we start.
```

### 2. Pre-flight summary (once, before execution)
See `preflight.md` for the exact format. Either:
- "Pre-flight clear — starting execution" (no issues), or
- Grouped list of items needing resolution

### 3. Task start (before each task)
```
▶ {Task ID}: {Task title}...
```
For M/L effort tasks, add what done looks like.

### 4. Task complete (after each task)
```
✅ {Task ID} done — {one-line summary of what was produced/changed}.
   Verified: {how the "done when" criteria were confirmed}.
```

### 5. Phase checkpoint (at end of each phase)
```
## ✅ Phase {N} complete — {phase name}

Done:
- {Task}: {one-line outcome}
- {Task}: {one-line outcome}

Next: Phase {N+1} — {phase name} ({task list}).
{One sentence on what phase N+1 accomplishes.}

→ Ready to continue?
```

### 6. Blocker (when execution hits a wall)
See `blocker-protocol.md` for the exact format.

### 7. Completion summary (once, at the end)
```
## 🎉 Plan complete — `{feature-name}`

**What was done**: {2–3 sentences summarizing the work}

**Definition of done**:
- [x] {criterion} ✅
- [x] {criterion} ✅
- [ ] {criterion} — SKIPPED ({reason})

**Assumptions used** (please verify):
- T-02: Branched from `main` (unconfirmed, you said "proceed")
- T-05: Used `npm run deploy:prod` (unconfirmed)

**Deferred / parking lot**: {list from parking-lot.md, or "none"}

**Follow-up session would start at**: {first uncompleted item, if any}
```

---

## Tone calibration

**Be factual, not performative.** Don't say "Great news, Task 3 is complete! 🎊"
Say "✅ T-03 done — Redis table created."

**Be specific, not vague.** Don't say "the database step went well".
Say "Migration 0023 applied successfully. Confirmed: `users` table has `idx_user_id` index."

**Be brief, not terse.** Each message should be readable in 10 seconds. If it's longer,
it's probably doing too much — split it or cut it.

**Never say "I'm working on it" and then produce nothing.** If a task takes effort,
show incremental output — a partial result is better than a long silence.

---

## Reporting errors and deviations

When something doesn't go as planned, be direct:

```
⚠️ T-04: Unexpected output from migration command.

Expected (from plan): `✅ Migration applied: 0023_add_webhook_table`
Got: `ERROR: relation "webhooks" already exists`

This likely means migration 0023 was already applied. I'm pausing here — please
confirm whether to:
[A] Skip this migration and continue
[B] Roll back and re-apply
[C] Investigate before deciding
```

Never hide an error. Never minimize it. Never attempt a fix without telling the user first.

---

## What NOT to say

- ❌ "Simply do X" — banished from this skill
- ❌ "Obviously, Y is the case" — banished
- ❌ "As usual, we'll need to..." — banished
- ❌ "I'll just quickly..." — banished
- ❌ Long paragraphs explaining what you're about to do instead of doing it
- ❌ Repeating the same information across multiple messages
- ❌ Asking for confirmation on things the plan already decided

---

## Progress tracking in long sessions

For plans with 10+ tasks, maintain a running tracker in your last checkpoint message:

```
## Progress tracker

Phase 1 — Refactor   ✅ Complete (T-01 T-02 T-03)
Phase 2 — Signature  🔄 In progress (T-04 ✅ | T-05 ⏳ | T-06 ⏳)
Phase 3 — Rollout    ⏳ Not started
```

Update this tracker at every checkpoint. The human should be able to glance at the
latest checkpoint and know exactly where execution stands.
