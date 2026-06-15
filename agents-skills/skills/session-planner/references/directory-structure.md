# Directory Structure — Canonical Output Layout

This file defines how session plans are organized on disk. Every plan produced by this
skill must follow this layout. Consistency matters — it lets agents (and humans) navigate
plans without reading any documentation.

---

## Canonical structure

```
/{project-name}/{feature-or-topic-name}/
  plan.md                          ← Entry point. Executive summary + index.
  plan-details/
    01-context.md                  ← Background, current state, why this matters
    02-requirements.md             ← What needs to be true when done (may be omitted for reviews)
    03-[phase-or-area].md          ← Main work files (numbered, descriptive names)
    ...                            ← As many as needed
    NN-testing.md                  ← Validation and testing strategy
    NN-rollout.md                  ← Deployment/release steps (if applicable)
    NN-parking-lot.md              ← Out-of-scope ideas (casual sessions)
```

Numbers are zero-padded to two digits (`01`, `02`, ..., `10`, `11`). This ensures correct
sort order in any file browser or `ls` output.

---

## Naming rules

### Project name
- Derived from: repo name, product name, service name, or what the user calls their system
- Format: `kebab-case`, lowercase
- Be specific: `payments-api` not `backend`; `mobile-app` not `app`
- If unknown: ask once, or use `unknown-project` and flag it

```
✅ payments-api
✅ design-system
✅ data-pipeline
❌ project          (too generic)
❌ MyApp            (wrong case)
❌ backend_service  (underscores — use hyphens)
```

### Feature / topic name
- Derived from: the feature, ticket topic, PR title, or discussion subject
- Format: `kebab-case`, lowercase, descriptive (3–5 words is ideal)
- Should answer "what was this session about?"

```
✅ stripe-webhook-refactor
✅ onboarding-flow-redesign
✅ redis-cache-migration
✅ auth-security-review
✅ q3-roadmap-brainstorm
❌ fix               (too vague)
❌ new-feature       (too vague)
❌ session           (meaningless)
❌ stripe_webhook_refactor  (underscores — use hyphens)
```

### Plan detail file names
- Prefix with two-digit number matching their logical sequence
- Suffix should be descriptive of what the file covers
- Separate prefix from name with a hyphen

```
✅ 01-context.md
✅ 03-auth-service-tasks.md
✅ 07-database-migration.md
❌ context.md            (no number prefix)
❌ 3-context.md          (not zero-padded)
❌ 01_context.md         (underscore)
```

---

## Reserved file slots

These names have a fixed meaning and position:

| Filename | Purpose | Always present? |
|---|---|---|
| `plan.md` | Root entry point, executive overview | ✅ Always |
| `01-context.md` | Background and current state | ✅ Always |
| `NN-testing.md` | Validation strategy | ✅ Always |
| `NN-rollout.md` | Deployment/release instructions | If touching production |
| `NN-parking-lot.md` | Deferred ideas | Casual sessions |

"NN" means: use the next available number in the sequence.

---

## Examples of complete plan directory structures

### Small feature (casual session)
```
/ecommerce-platform/cart-abandonment-emails/
  plan.md
  plan-details/
    01-context.md
    02-requirements.md
    03-email-design.md
    04-trigger-logic.md
    05-testing.md
    06-rollout.md
    07-parking-lot.md
```

### Code review (review session)
```
/payments-api/checkout-security-review/
  plan.md
  plan-details/
    01-context.md
    02-findings.md
    03-critical-fixes.md
    04-high-fixes.md
    05-medium-fixes.md
    06-testing.md
```

### Complex feature with phases (casual + grill-me)
```
/data-platform/real-time-pipeline-v2/
  plan.md
  plan-details/
    01-context.md
    02-requirements.md
    03-architecture.md
    04-phase-1-ingestion.md
    05-phase-2-processing.md
    06-phase-3-sink.md
    07-spikes.md
    08-testing.md
    09-rollout.md
    10-parking-lot.md
```

### Quick grill-me session (focused)
```
/auth-service/jwt-implementation-review/
  plan.md
  plan-details/
    01-context.md
    02-session-log.md
    03-gap-remediation.md
    04-open-decisions.md
    05-validation.md
```

---

## When to split vs. merge task files

**Split into separate files when:**
- A phase or area has > 10 distinct tasks
- Different team members will own different areas
- Tasks in one area must be fully complete before the next area starts
- A file would exceed ~200 lines

**Merge into one file when:**
- Fewer than 10 total tasks across areas
- All tasks are roughly the same type (e.g., all fix tasks from a small review)
- There's no clear ownership boundary between areas

---

## Relative links in plan files

Always use relative paths when linking between plan files:

```markdown
See [gap remediation tasks](plan-details/03-gap-remediation.md) for implementation detail.
```

Never use absolute paths — plans may be checked into different repos or moved.

---

## `.plan-meta.json` (optional)

For agent-to-agent handoffs where the receiving agent needs to parse the plan
programmatically, create a lightweight metadata file at the plan root:

```json
{
  "plan_version": "1.0",
  "session_type": "review",
  "session_date": "2025-09-15",
  "project": "payments-api",
  "feature": "checkout-security-review",
  "status": "ready-for-execution",
  "entry_point": "plan.md",
  "execution_order": [
    "plan-details/03-critical-fixes.md",
    "plan-details/04-high-fixes.md",
    "plan-details/05-medium-fixes.md",
    "plan-details/06-testing.md"
  ],
  "blockers": [],
  "assumptions": [
    "Reviewer confirmed: fix branch off main, not staging"
  ]
}
```

Include `.plan-meta.json` when the plan will be consumed by an automated agent pipeline.
Skip it for human-facing plans.
