---
name: setup-skills
description: Sets up an `## Agent skills` block in AGENTS.md and `docs/agents/` so the engineering skills know this repo's issue tracker (GitHub or local markdown), triage label vocabulary, and domain doc layout. Run before first use of `to-issues`, `to-prd`, `triage`, `diagnose`, `tdd`, or `zoom-out` — or if those skills appear to be missing context about the issue tracker, triage labels, or domain docs.
---

# Setup Skills

Scaffold the per-repo configuration that the engineering skills assume:
- **Issue tracker** — where issues live (GitHub by default; local markdown is also supported)
- **Triage labels** — the strings used for the five canonical triage roles
- **Domain docs** — where `CONTEXT.md` and ADRs live, and the consumer rules for reading them

This is a prompt-driven skill, not a deterministic script. Explore, present what you found, confirm with the user, then write.

## Process

### 1. Explore
Look at the current repo to understand its starting state. Read whatever exists; don't assume:
- `git remote -v` and `.git/config` — is this a GitHub repo? Which one?
- `AGENTS.md` at the repo root — does it exist? Is there already an `## Agent skills` section?
- `CONTEXT.md` and `CONTEXT-MAP.md` at the repo root
- `docs/adr/` and any `src/*/docs/adr/` directories
- `docs/agents/` — does this skill's prior output already exist?
- `.scratch/` — sign that a local-markdown issue tracker convention is already in use

### 2. Present findings and ask
Summarise what's present and what's missing. Then walk the user through the three decisions **one at a time** — present a section, get the user's answer, then move to the next.

**Section A — Issue tracker.**
> Explainer: The "issue tracker" is where issues live for this repo. Skills like `to-issues`, `triage`, and `to-prd` read from and write to it — they need to know whether to call `gh issue create`, write a markdown file under `.scratch/`, or follow some other workflow you describe.

Options:
- **GitHub** — issues live in the repo's GitHub Issues (uses the `gh` CLI)
- **GitLab** — issues live in the repo's GitLab Issues (uses the `glab` CLI)
- **Local markdown** — issues live as files under `.scratch/` in this repo
- **Other** (Jira, Linear, etc.) — ask the user to describe the workflow in one paragraph

**Section B — Triage label vocabulary.**
> Explainer: When the `triage` skill processes an incoming issue, it moves it through a state machine. It needs to apply labels that match strings you've actually configured.

The five canonical roles:
- `needs-triage` — maintainer needs to evaluate
- `needs-info` — waiting on reporter
- `ready-for-agent` — fully specified, AFK-ready
- `ready-for-human` — needs human implementation
- `wontfix` — will not be actioned

Default: each role's string equals its name. Ask the user if they want to override any.

**Section C — Domain docs.**
> Explainer: Some skills read a `CONTEXT.md` file to learn the project's domain language, and `docs/adr/` for past architectural decisions.

Confirm the layout:
- **Single-context** — one `CONTEXT.md` + `docs/adr/` at the repo root. Most repos are this.
- **Multi-context** — `CONTEXT-MAP.md` at the root pointing to per-context `CONTEXT.md` files (typically a monorepo).

### 3. Confirm and edit
Show the user a draft of:
- The `## Agent skills` block to add to `AGENTS.md`
- The contents of `docs/agents/issue-tracker.md`, `docs/agents/triage-labels.md`, `docs/agents/domain.md`

Let them edit before writing.

### 4. Write
If `AGENTS.md` exists, edit it. If not, ask the user whether to create it.

If an `## Agent skills` block already exists, update its contents in-place rather than appending a duplicate.

The block:
```markdown
## Agent skills

### Issue tracker
[one-line summary of where issues are tracked]. See `docs/agents/issue-tracker.md`.

### Triage labels
[one-line summary of the label vocabulary]. See `docs/agents/triage-labels.md`.

### Domain docs
[one-line summary of layout — "single-context" or "multi-context"]. See `docs/agents/domain.md`.
```

Then write the three docs files under `docs/agents/`.

### 5. Done
Tell the user the setup is complete and which engineering skills will now read from these files. Mention they can edit `docs/agents/*.md` directly later — re-running this skill is only necessary if they want to switch issue trackers or restart from scratch.
