# Review Protocol

How to check MR/PR comments after a review, classify them, and decide what happens next.
Used at two gates: after the proposal review (Step 4d) and after the implementation
review (Step 4g).

---

## The two review gates

| Gate | After step | MR type | What's being reviewed |
|---|---|---|---|
| **Proposal review** | 4c (draft MR created) | Draft | TODO comment placement, intent, approach |
| **Implementation review** | 4f (ready MR created) | Ready | Actual code: correctness, style, edge cases |

The classification and decision logic is the same at both gates. The difference is what
the reviewer is looking at and what the agent does in response.

---

## How to check for comments

The agent cannot browse the MR platform directly unless tools are available.
Use this approach:

1. Ask the user to paste comments into the chat, **or**
2. If a GitHub / GitLab MCP tool is connected, use it to fetch open comments on the MR, **or**
3. If neither is available, ask the user to summarize any change requests.

When asking the user, be specific:

```
Are there any change requests on the MR? If so, paste them here (or summarize them)
and I'll address each one before we move forward.
If there are no 🔴 change requests — only positive comments or no comments at all
— just say "looks good" and I'll proceed.
```

Do not proceed to the next step until the user explicitly responds with either
"looks good" / "no comments" or pastes specific feedback.

---

## Comment classification

For each comment received, classify it into one of three categories:

### 🔴 Change needed
The reviewer wants something different. This blocks progression to the next phase.

Signs: "move this to...", "don't do this here", "use X instead of Y", "remove this",
"I'd rather see...", "this doesn't look right", "change the approach to..."

**What to do**: Address all 🔴 comments before proceeding. Do not partially address
them and move on. All 🔴 comments in a round must be resolved before the next push.

### 🟡 Question / clarification
The reviewer is asking why something is done a certain way. This does NOT block
progression if the agent can answer it in the MR (or in chat).

Signs: "why is this here?", "what does this do?", "is this intentional?", "explain..."

**What to do**: Answer the question — in the MR thread as a reply, or in the chat
message reporting back to the user. No code change needed unless the answer reveals
a 🔴 issue.

### ✅ Positive
Approval, acknowledgment, or agreement. Does not require action.

Signs: "looks good", "LGTM", "makes sense", "+1", ":thumbsup:", "approved"

---

## Handling a round of mixed comments

If a review round contains a mix of 🔴, 🟡, and ✅:

1. List all comments with their classification, numbered.
2. Address all 🔴 items. Answer all 🟡 items. Acknowledge ✅ items.
3. Push the revisions.
4. Report back with a clear summary of what was addressed.

Example report format:

```
📋 T-01 proposal revised — 3 comments addressed

1. 🔴 Moved idempotency check from handler.ts:42 to middleware.ts:18
   (you asked it to be extracted into middleware)

2. 🟡 "Why 24h TTL?" — answered in the MR thread:
   Stripe guarantees delivery within 72h. 24h is conservative but leaves room for
   a second attempt. Noted in the TODO comment.

3. ✅ "Smart to handle this in middleware" — acknowledged, no action needed.

Updated MR: <URL>
Reply here when you've finished reviewing the revision.
```

---

## When the same comment recurs across rounds

If the reviewer raises the same concern again after a revision (i.e., the previous
change didn't satisfy them), treat it as a 🔴 blocker and ask for clarification:

```
🛑 Clarification needed — T-01 proposal

You've raised the same concern again: "move idempotency logic to middleware."
My previous revision moved the TODO to middleware.ts:18 — it seems this still
isn't what you had in mind.

Could you clarify:
[A] Which file / function / line you'd prefer?
[B] Or describe the approach you're looking for and I'll re-annotate?
```

Do not keep guessing. Ask directly.

---

## When the user says "just proceed" without reviewing

If the user says "skip the review" or "just implement it":

```
📋 T-01 proposal review skipped at your direction.
Moving directly to implementation. The TODO comments from the proposal pass
will be the blueprint for the code.
```

Document the skip in the final summary. Do not re-raise it.

---

## After all 🔴 comments are resolved

Once a review round has no remaining 🔴 comments:

**For proposal review** → announce and proceed to implementation (Step 4e):
```
✅ T-01 proposal approved — no remaining change requests.
Moving to implementation now.
```

**For implementation review** → announce and wait for merge:
```
✅ T-01 implementation review clear — no remaining change requests.
MR is ready to merge. Reply here when it's merged.
```

---

## Tracking review rounds

Keep a simple counter in your working memory for each task:

```
T-01 proposal: round 1 → 🔴 x2, round 2 → ✅ cleared → implementation
T-01 implementation: round 1 → 🔴 x1, round 2 → ✅ cleared → merged
```

Include this in the task completion report so the user has a record of how many
review rounds each task required.
