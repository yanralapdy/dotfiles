# Status Reporting

How to communicate progress in chat during a plan-branch-executor session.

Same golden rule as plan-executor: **the human should always know where we are,
what just happened, and what's coming next — without having to ask.**

This file extends the base status-reporting conventions with new message types for
the branch and MR review workflow.

---

## Message types and when to use each

### 1. Plan loaded (once, at orientation)
```
**Plan loaded**: `{project-name} / {feature-name}`
{N} tasks across {M} phases. Goal: {one sentence goal state}.
Running pre-flight and git setup next.
```

### 2. Pre-flight summary (once, before git setup)
Either:
- `Pre-flight clear — setting up plan branch.`
- Or the grouped list format from `preflight.md`.

### 3. Git setup complete (once, after plan branch is created)
```
**Git setup complete**
Plan branch: `plan/{feature-name}` (branched from `{base-branch}`)
All task MRs will target this branch. Starting T-01 now.
```

### 4. Task branch created (once per task, at Step 4a)
```
▶ T-{XX}: {task title} — branch `task/T-{XX}-{slug}` created. Starting proposal pass.
```

### 5. Proposal MR ready (after Step 4c — the key human pause point)
```
📋 T-{XX} proposal ready for review

Branch: task/T-{XX}-{slug}
Draft MR: [PROPOSAL] T-{XX}: {task title} → plan/{feature-name}
URL: {MR URL if available}

The diff shows exactly where code will change, with explanations.
Comment on the MR for anything you want moved, removed, or reconsidered.

Reply here when you've finished reviewing.
```

### 6. Proposal revised (after incorporating 🔴 review comments)
```
📋 T-{XX} proposal revised — {N} comment(s) addressed

{Numbered list of what changed per each 🔴 comment}

MR updated: {URL}
Reply here when you've finished reviewing the revision.
```

### 7. Proposal approved (when moving from review to implementation)
```
✅ T-{XX} proposal approved — no remaining change requests.
Starting implementation now.
```

### 8. Implementation MR ready (after Step 4f — the second human pause point)
```
🔧 T-{XX} implementation complete — MR ready for review

Branch: task/T-{XX}-{slug}
MR: T-{XX}: {task title} → plan/{feature-name} (ready, not draft)
URL: {MR URL if available}

Done when (verified):
- [x] {criterion} ✅ {how it was confirmed}
- [x] {criterion} ✅ {how it was confirmed}

Review the implementation diff. When you're satisfied, merge and reply here.
```

### 9. Implementation revised (after incorporating 🔴 code review comments)
```
🔧 T-{XX} implementation revised — {N} comment(s) addressed

{Numbered list of what changed per each 🔴 comment}

MR updated: {URL}
Reply when merged.
```

### 10. Task complete (after merge is confirmed and plan branch is synced)
```
✅ T-{XX} merged and synced

plan/{feature-name} is up to date.
Proposal rounds: {N} | Implementation rounds: {N}
Moving to T-{XX+1}: {next task title}.
```

### 11. Phase checkpoint (after every 3–4 tasks for large plans)
```
## ✅ Phase {N} complete — {phase name}

Tasks merged:
- T-{XX}: {one-line outcome}
- T-{XX}: {one-line outcome}

Next: Phase {N+1} — {phase name} ({task list})
{One sentence on what Phase N+1 accomplishes.}

→ Ready to continue?
```

### 12. Blocker
See `blocker-protocol.md` for the exact format.

### 13. Completion summary (once, at the end — Step 6)
```
## 🎉 Plan complete — `{feature-name}`

**What was done**: {2–3 sentences}

**Definition of done**:
- [x] {criterion} ✅
- [x] {criterion} ✅
- [ ] {criterion} — SKIPPED ({reason})

**Plan branch**: `plan/{feature-name}` — contains all {N} completed tasks.
Ready to be merged into `{base-branch}` via a final PR/MR when your team is ready.

**Review stats**:
- T-01: {N} proposal rounds, {N} implementation rounds
- T-02: {N} proposal rounds, {N} implementation rounds

**Assumptions used** (please verify):
- {list of any assumptions proceeded on}

**Deferred / parking lot**: {list or "none"}
```

---

## Tone calibration

Same rules as plan-executor:

**Be factual, not performative.** `✅ T-03 merged and synced` not `Great news! Task 3 is done! 🎊`

**Be specific, not vague.** `Idempotency check added to middleware.ts:18, verified with Redis CLI`
not `the Redis step went well`.

**Be brief.** Each message should be readable in 10 seconds.

**The two pause points are sacred.** Always include the reply instruction at the end
of message types 5 and 8 — the human must explicitly return to chat before execution
continues. Never proceed past a pause point without a response.

---

## What NOT to say

- ❌ "Simply do X" — banished
- ❌ "Obviously, Y is the case" — banished
- ❌ "I'll just quickly..." — banished
- ❌ Starting implementation before the user replies to a proposal MR
- ❌ Marking an MR as ready without waiting for the user to confirm the proposal
- ❌ Asking for confirmation on things the plan already decided
- ❌ Reporting two task completions in a single message

---

## Progress tracker (for plans with 6+ tasks)

Include this tracker in every phase checkpoint and task-complete message:

```
## Progress

Phase 1 — Refactor    ✅ T-01 ✅ T-02 ✅ T-03
Phase 2 — Signature   🔄 T-04 ✅ | T-05 ⏳ | T-06 ⏳
Phase 3 — Rollout     ⏳
```

Keep it updated at every checkpoint. The human should be able to glance at the
latest message and know exactly where the plan stands.
