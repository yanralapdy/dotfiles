---
name: skill-review
description: Review, audit, and improve existing agent skills for predictability and quality. Use when evaluating skills, finding issues in skill design, or improving skill effectiveness.
---

# Skill Review

Review skills to make them predictable — the agent taking the same *process* every run.

## Review Process

1. **Load the skill** - read SKILL.md and any linked files
2. **Run the checks** below
3. **Report findings** - list issues with severity (critical/warning/info)
4. **Offer fixes** - suggest specific edits, not vague advice

## Checks

### Structure

- [ ] SKILL.md under 100 lines (sprawl = hard to maintain)
- [ ] Reference pushed to separate file when >100 lines
- [ ] Single source of truth (no duplication across files)
- [ ] Co-located (concept's definition, rules, caveats under one heading)

### Description

- [ ] Front-loads leading word (first word = main trigger)
- [ ] One trigger per branch (no synonyms renaming same thing)
- [ ] No identity already in body (cut what SKILL.md already says)

### Steps

- [ ] Each step has completion criterion (checkable, not vague)
- [ ] Criterion is exhaustive ("every X accounted for" not "produce list")
- [ ] No premature completion risk (post-completion steps hidden if needed)

### Language

- [ ] Leading words used (compressed pretrained concepts)
- [ ] No-op test passed (every sentence changes behavior)
- [ ] No restatements (same idea in multiple places)

### Branches

- [ ] Each branch needs different material (not all paths use everything)
- [ ] Inline what every branch needs
- [ ] Push behind pointer what only some branches reach

## Failure Modes

| Symptom | Diagnosis | Fix |
|---------|-----------|-----|
| Agent rushes steps | Premature completion | Sharpen criterion, hide later steps |
| Same meaning in 2+ places | Duplication | Merge to single source |
| Skill keeps growing, never shrinking | Sediment | Prune aggressively |
| Too long even when all live | Sprawl | Split by branch or sequence |
| Line doesn't change behavior | No-op | Delete it |

## Leading Words

Compact concepts from pretraining that anchor behavior.

| Instead of... | Use... |
|---------------|--------|
| fast, deterministic, low-overhead | tight |
| a loop you believe in | red |
| thorough, careful, complete | relentless |
| make a plan first | trace |
| small incremental changes | tracer bullets |

Hunt restated ideas. Collapse to one word.

## No-Op Test

Remove each sentence. Does behavior change?
- No → delete
- Yes → keep

Be aggressive. Most prose fails.

## Output Format

```
## Skill Review: [skill-name]

### Critical
- [issue]: [why it matters] → [fix]

### Warning
- [issue]: [why it matters] → [fix]

### Info
- [suggestion]: [improvement]

### Summary
[X] critical, [Y] warning, [Z] info
```
