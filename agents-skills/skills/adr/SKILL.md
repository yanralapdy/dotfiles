---
name: adr
description: Capture architecturally significant decisions in versioned Markdown records — the why behind the system, not just the what. Nygard, MADR, and Y-Statement templates. Use when making a non-trivial architectural or technology choice, after grill-me / grill-with-docs sessions, when reversing a prior decision, or when user mentions ADR, decision record, MADR, or "why did we choose X".
---

# ADR — Architecture Decision Records

Lightweight Markdown files that preserve **why** a decision was made, alongside the code. Grounded in Michael Nygard's 2011 "Documenting Architecture Decisions" and the adr.github.io canon.

## What counts as architecturally significant

Not every decision needs an ADR. A decision is ADR-worthy if it meets any two:

- Changes structure or major interfaces
- Non-trivial to reverse (cost > a day of work)
- Constrains future decisions
- Involves cost, security, compliance, or vendor lock-in
- The team argued for more than 30 minutes

If reversing it costs an afternoon and nobody argued — skip the ADR.

## Directory and naming

```
docs/adr/
├── 0001-record-architecture-decisions.md         # meta: the ADR about doing ADRs
├── 0002-use-postgres-for-primary-store.md
├── 0003-adopt-oidc-for-github-actions.md
├── 0004-move-to-trunk-based-development.md
└── ...
```

**Naming rules:**

- Four-digit sequential number (0001+), zero-padded — sorts chronologically
- Kebab-case title, short, verb-first ("use", "adopt", "deprecate", "reverse")
- One ADR per file, one decision per ADR
- Never renumber; deprecate and supersede instead

## Pick a template

Three canonical formats — pick one per project and stick to it.

| Template     | Fields                                          | Best for                                     |
|--------------|-------------------------------------------------|----------------------------------------------|
| **Nygard**   | Title, Status, Context, Decision, Consequences  | Default. Small teams. Fast.                  |
| **MADR**     | Adds: options considered, pros/cons per option, decision drivers | Teams comparing 3+ options; needs traceability |
| **Y-Statement** | Single sentence: "In context of X, we chose Y over Z because W"| Very small decisions; index of tiny choices |

If unsure: **use MADR**. It's the modern default for good reason — it forces you to write down the alternatives.

## Nygard template

```markdown
# ADR NNNN: <Short imperative title>

## Status

Proposed | Accepted | Deprecated | Superseded by [ADR-NNNN](NNNN-...md)

## Context

The forces at play. What problem are we solving? What constraints exist? What has changed that requires a decision? Include facts, not opinions. 2-6 short paragraphs.

## Decision

The change we are making. State it in present tense: "We will use PostgreSQL for the primary transactional store."

## Consequences

The results of this decision — good, bad, and neutral. What becomes easier? What becomes harder? What new risks appear? What follow-up work is triggered?
```

## MADR template (recommended default)

```markdown
# ADR NNNN: <Short imperative title>

- Status: proposed | accepted | rejected | deprecated | superseded by [NNNN](NNNN-...md)
- Deciders: <names or roles>
- Date: YYYY-MM-DD
- Tags: <optional, comma-separated>

## Context and Problem Statement

<2-6 sentences. What forces us to choose? Frame as a question.>

## Decision Drivers

- <driver 1 — e.g., "must support 10k concurrent connections">
- <driver 2 — e.g., "team already runs Postgres">
- <driver 3>

## Considered Options

- Option A: <name>
- Option B: <name>
- Option C: <name>

## Decision Outcome

Chosen option: **<name>**, because <justification linking to drivers>.

### Positive Consequences

- <what gets better>
- <what capability opens up>

### Negative Consequences

- <what gets worse>
- <what we now have to maintain>

## Pros and Cons of the Options

### Option A: <name>
- ✅ <pro>
- ❌ <con>

### Option B: <name>
- ✅ <pro>
- ❌ <con>

## Links

- [Related ADR](NNNN-...md)
- <External docs, RFCs, benchmarks>
```

## Y-Statement — the one-liner

For decisions too small for a full ADR but still worth capturing:

```markdown
In the context of <use case>,
facing <concern>,
we decided for <option>
and against <alternative>
to achieve <quality attribute>,
accepting <downside>.
```

One paragraph. Batch a dozen into `docs/adr/0001-minor-decisions.md` if you don't want per-file overhead.

## Lifecycle — the status machine

```
proposed  ──accept──▶  accepted  ──replaced──▶  superseded by NNNN
                                ──unused──▶     deprecated
                                ──reverse──▶    reversed by NNNN
   │
   └──reject──▶  rejected  (keep the file — the "no" is documented)
```

**Rules:**
- Never delete an ADR. If a decision is reversed, mark it `superseded by NNNN` and write a new ADR explaining the reversal.
- Rejected proposals stay in the log — the "no" is often more valuable than another "yes".
- Update the status inline; don't rewrite the body when reversing. Write ADR NNNN+1 instead.

## The index — one page, always current

```
docs/adr/README.md
```

Contents:

```markdown
# ADR Index

| # | Title | Status | Date |
|---|-------|--------|------|
| 0001 | [Record architecture decisions](0001-...) | Accepted | 2026-01-15 |
| 0002 | [Use Postgres for primary store](0002-...) | Accepted | 2026-01-16 |
| 0003 | [Adopt OIDC for CI](0003-...) | Accepted | 2026-02-01 |
| 0004 | [Move to trunk-based development](0004-...) | Superseded by 0011 | 2026-03-12 |
```

Auto-generate this from filenames + front-matter if the team grows past ~20 ADRs.

## Workflow

```
1. Someone proposes a decision — verbally, in PR review, or after grill-me.
2. Create docs/adr/NNNN-<title>.md with Status: proposed.
3. Circulate for review — PR, meeting, async doc comments.
4. Update to Status: accepted (or rejected — either way, merge the file).
5. If reversing later: new ADR NNNN+1; original marked superseded.
6. Reference the ADR from code comments where it applies:
   // See ADR 0002 — Postgres primary store
```

## Common failure modes

- **The ADR that documents "what"** — code already shows what. ADRs document why. If you can delete every "why" and the ADR still reads fine, it's not doing its job.
- **The ADR nobody reads** — link ADRs from PRs, code comments, and the README. Bury them and they die.
- **The ADR written months after the decision** — memory is not archival. Write it when you decide, even if roughly.
- **The ADR that hedges** — "we might consider option X in the future" — decide or don't. If you can't decide, keep it Proposed and ship the option that's marked "least regret" until you can.
- **Sprawl** — 300 ADRs, none current. Deprecate ruthlessly. Every ADR review round, mark 5 as deprecated if the decision no longer applies.

## When to skip

- Bug fixes (unless they revealed a design flaw)
- Renames and refactors that don't change interfaces
- Tooling swaps that leave the codebase's contract unchanged
- Style choices (linting, formatting) — link to a style doc instead

## Integration with other skills

- **grill-me / grill-with-docs** — a grilling session almost always ends with 1-3 ADRs. Write them during the session.
- **to-prd** — the PRD frames the problem; the ADRs record the design choices that flow from it.
- **coms-workflow (documenter / planner)** — planner produces ADRs at planning time; documenter refreshes the index and links from the README when a change ships.
- **threat-modeling** — the threat model output is not an ADR, but security decisions taken because of it are.
