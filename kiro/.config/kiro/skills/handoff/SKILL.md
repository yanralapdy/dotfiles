---
name: handoff
description: Compact the current conversation into a handoff document so another agent or session can continue the work. Use when context window is getting full, switching sessions, or handing off to another person.
---

Write a handoff document summarizing the current conversation so a fresh session can continue the work.

Save it to `.kiro/context/handoff.md`.

Include:
1. **Goal** — what we're trying to accomplish
2. **Decisions made** — key choices and their reasoning
3. **Current state** — what's done, what's in progress
4. **Next steps** — prioritized list of remaining work
5. **Gotchas** — anything the next session needs to watch out for

Do not duplicate content already in other artifacts (specs, PRDs, commits). Reference them by path instead.

Keep it concise — this is a briefing, not a transcript.
