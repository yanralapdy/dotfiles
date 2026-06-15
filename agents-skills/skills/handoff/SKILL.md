---
name: handoff
description: Compact the current conversation into a handoff document so another agent or session can continue the work. Use when context window is getting full, switching sessions, or handing off to another person.
---

Write a handoff document summarizing the current conversation so a fresh session can continue the work.

## Save location

Save to `~/Downloads/work/handoffs/<project>/<YYYY-MM-DD>-<slug>.md`. Create the folder if it does not exist.

- `<project>`: infer from the git repo or working directory. Match an existing client folder when one fits (for example `primaclouds`, `prosper`). Ask if it is ambiguous.
- `<slug>`: kebab-case, 3 to 5 words naming the main topic.
- Never overwrite an existing handoff. Write a new dated file. If one already exists for today on the same topic, append `-2`, `-3`, and so on.

A central location is deliberate: handoffs survive a repo wipe or re-clone, group by client, and can span several repos.

## Include
1. **Goal** — what we're trying to accomplish
2. **Decisions made** — key choices and their reasoning
3. **Current state** — what's done, what's in progress
4. **Next steps** — prioritized list of remaining work
5. **Gotchas** — anything the next session needs to watch out for

Do not duplicate content already in other artifacts (specs, PRDs, commits, vault notes). Reference them by path instead.

Keep it concise — this is a briefing, not a transcript.
