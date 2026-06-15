---
name: diagnose
description: Disciplined diagnosis loop for hard bugs. Reproduce → minimise → hypothesise → instrument → fix → regression-test. Use when user says "diagnose", "debug this", reports a bug, or describes something broken/failing.
---

# Diagnose

A discipline for hard bugs. Skip phases only when explicitly justified.

## Phase 1 — Build a Feedback Loop

**This is the skill.** If you have a fast, deterministic pass/fail signal, you will find the cause. If you don't, no amount of staring at code will save you.

Try in order:
1. Failing test at whatever seam reaches the bug
2. Curl/HTTP script against a running dev server
3. CLI invocation with fixture input, diffing output
4. Headless browser script (Playwright/Puppeteer)
5. Replay a captured trace/payload through the code path
6. Throwaway harness — minimal subset exercising the bug
7. Property/fuzz loop for intermittent bugs
8. Bisection harness (`git bisect run`)

Iterate on the loop: make it faster, sharper, more deterministic.

**Do not proceed to Phase 2 without a loop.**

## Phase 2 — Reproduce

Run the loop. Confirm:
- [ ] Failure matches what the user described (not a different nearby failure)
- [ ] Reproducible across multiple runs
- [ ] Exact symptom captured (error message, wrong output, timing)

## Phase 3 — Hypothesise

Generate **3–5 ranked hypotheses** before testing any.

Each must be falsifiable: "If X is the cause, then Y will make the bug disappear / Z will make it worse."

Show the list to the user — they often have domain knowledge that re-ranks instantly.

## Phase 4 — Instrument

Each probe maps to a specific prediction from Phase 3.

**Change one variable at a time.**

Preference: debugger/REPL > targeted logs > never "log everything and grep".

Tag debug logs with unique prefix (e.g. `[DEBUG-a4f2]`) for easy cleanup.

## Phase 5 — Fix + Regression Test

1. Turn minimised repro into a failing test
2. Watch it fail
3. Apply the fix
4. Watch it pass
5. Re-run Phase 1 loop against original scenario

## Phase 6 — Cleanup

- [ ] Original repro no longer reproduces
- [ ] Regression test passes
- [ ] All debug instrumentation removed
- [ ] Correct hypothesis stated in commit message
- [ ] Ask: what would have prevented this bug?
