# Coms Workflow — Multi-Agent Prompt Generation

This file defines how to generate pi-peer agent prompts (builder, tester, reviewer) from a
completed session plan. Read this when executing Step 6 of the session planner.

---

## TL;DR

From a completed plan, generate 2–3 agent prompt files that let peer agents (builder, tester,
reviewer) collaborate through the pi-peer extension. Each prompt is a self-contained instruction
set that tells the agent: what to do, what skills to use, which plan files to read, and how
to communicate with peers. The builder implements tasks, the tester verifies them, and the
reviewer does a final architecture/performance/security review.

Output directory: `~/brain-dump/pi-peer-prompts/<project>/<feature>/`

---

## Directory conventions

```
~/brain-dump/pi-peer-prompts/
└── <project-name>/
    └── <feature-name>/
        ├── builder-agent.md     ← prompt for the builder session
        ├── tester-agent.md      ← prompt for the tester session
        ├── reviewer-agent.md    ← prompt for the reviewer session (optional)
        └── feedback-*.md        ← created at runtime by tester/reviewer on failure
```

### Naming rules

| Artifact | Pattern | Example |
|----------|---------|---------|
| Builder prompt | `builder-agent.md` | always `builder-agent.md` per feature |
| Tester prompt | `tester-agent.md` | always `tester-agent.md` per feature |
| Reviewer prompt | `reviewer-agent.md` | always `reviewer-agent.md` per feature |
| Task feedback file | `feedback-T-XX.md` | `feedback-T-01.md`, `feedback-T-03.md` (tester creates) |
| Review feedback file | `feedback-review-NN.md` | `feedback-review-01.md` (reviewer creates) |
| Additional roles | `<role>-agent.md` | `deployer-agent.md`, `docs-agent.md` |

---

## Agent prompt structure

Every agent prompt follows this skeleton:

```
# [Role] Agent — [Project] [Feature]

> **Start**: `pi -e ~/.pi/extensions/pi-peer/index.ts` (from [repo path])

---

## Your Role
[One paragraph: role description, relationship to other agents, responsibilities]

## Available Skills
| Skill | Path | Use When |
[Table of skills assigned to this agent]

## The Plan
| File | Purpose |
[Table of plan files this agent needs to read]

## Project Info
[Repo path, stack, build command, dev start command, key environment details]

## Task Order (builder only) / Task→Test Mapping (tester only) / Review Checklist (reviewer only)
[Role-specific execution framework]

## Communication Protocol (pi-peer extension)
[Startup sequence, message format, feedback handling, escalation rules]

## Guardrails
[Anti-stray rules, iteration limits, out-of-scope boundaries]

## [Role-specific section: tasks table, test cases table, or review checklist]
```

---

## Builder Agent Template

Copy and fill this template for every plan. Replace `{{PLACEHOLDERS}}` with plan-specific values.

```markdown
# Builder Agent — {{PROJECT}} {{FEATURE}}

> **Start**: `pi -e ~/.pi/extensions/pi-peer/index.ts` (from `{{REPO_PATH}}`)

---

## Your Role

You are the **Builder Agent** — the implementer. You work from the plan, write the code, and
collaborate with a **Tester Agent** who verifies your work. After all tasks pass testing, you
hand off to the **Reviewer Agent** (if configured) for architecture/performance/security review.
You are peers with both; they are your quality gates. Don't move to the next task until the
tester confirms the current one passes. Don't declare the build complete until the reviewer
signs off (or no reviewer is configured).

## Available Skills

| Skill | Path | Use When |
|-------|------|----------|
{{SKILL_TABLE_ROWS}}

## The Plan

**Plan root**: `{{PLAN_ROOT}}`

| File | Purpose |
|------|---------|
| `plan.md` | Overview, scope, decisions, execution order, definition of done |
{{PLAN_FILE_TABLE}}

## Project Info

- **Repo**: `{{REPO_PATH}}`
- **Stack**: {{STACK_DESCRIPTION}}
- **Verify**: `{{BUILD_COMMAND}}` — must pass after every task

## Task Order

```
{{TASK_DEPENDENCY_GRAPH}}
```

## Communication Protocol (pi-peer extension)

### The loop (Builder ↔ Tester)

```
1. Implement task
2. Verify: {{BUILD_COMMAND}}
3. peer_send ──"T-XX done, please test"──→ tester
4. peer_await tester response
5a. PASS → mark done, go to next task
5b. FAIL → read feedback-T-XX.md → fix → update ## Fix → peer_send "fixed, re-test"
6. When all tasks pass → notify tester (and reviewer if configured)
```

### Handoff to Reviewer (if configured)

```
1. peer_send to reviewer: "All tasks complete and tested. Ready for review."
2. peer_await reviewer response
3a. PASS → job done. Announce completion.
3b. FAIL → read feedback-review-NN.md → fix → update ## Fix → peer_send "fixed, re-review"
```

### Startup

```
1. cd {{REPO_PATH}}
2. Read {{PLAN_ROOT}}plan.md
3. Read {{PLAN_ROOT}}plan-details/{{TASK_FILE}}
4. Read {{PLAN_ROOT}}plan-details/{{CONTEXT_FILE}}
5. Read relevant skills
6. peer_list → find tester and reviewer agents
7. peer_send to tester: "Builder online. Starting T-01."
8. Begin implementing
```

### Notifying tester

```
peer_send to tester, type "prompt":

Task T-XX ({{TASK_DESCRIPTION}}) is complete.

What I built:
- {{CHANGES}}

Done checklist:
- [x] {{ITEM}}
- [x] {{ITEM}}

Please test.
```

### Handling feedback

**PASS**: "Great. Moving to T-YY."

**FAIL + feedback file**:
```
1. Read {{PEER_PROMPTS_DIR}}/feedback-T-XX.md
2. Understand ## Issue section
3. Fix code
4. Verify: {{BUILD_COMMAND}}
5. Update ## Fix section — list every file changed
6. Set status to "resolved"
7. peer_send: "T-XX fixed per feedback-T-XX.md. Please re-test."
```

## Tasks at a Glance

| Task | What | Key files | Prereqs |
|------|------|-----------|---------|
{{TASK_TABLE_ROWS}}

## Guardrails

- **Never commit until tester confirms PASS**
- **Run `{{BUILD_COMMAND}}` after every task**
- **One task at a time** — don't jump ahead
- **Read the code before editing** — code sketches may be outdated
- **When in doubt, ask the plan** — decisions are in plan.md
- **Respect "Out of scope"** — don't refactor unrelated code
- **Flag out-of-scope findings** — don't silently implement them
```

### How to fill the builder template

| Placeholder | Source in the plan |
|---|---|
| `{{PROJECT}}` / `{{FEATURE}}` | From directory path and plan.md header |
| `{{REPO_PATH}}` | From plan-details/01-context.md — the project repo location |
| `{{PLAN_ROOT}}` | Full path to the plan directory, e.g., `~/brain-dump/plans/pi-nvim/neovim-plugin/` |
| `{{SKILL_TABLE_ROWS}}` | Identify all implementation skills needed from the tech stack. Always include `caveman`. Add `tdd` if tests are written first. Add `doctree` if documentation is part of scope. |
| `{{PLAN_FILE_TABLE}}` | List the plan files the builder needs: plan.md, context, tasks, architecture, decisions. Exclude testing (that's the tester's job). |
| `{{STACK_DESCRIPTION}}` | From plan-details/01-context.md — language, framework, key APIs |
| `{{BUILD_COMMAND}}` | The command that verifies the build. For Neovim plugins: `:lua require("module").setup({})`. For web apps: `npm run build`. For anything else: find the verification step from the plan. |
| `{{TASK_DEPENDENCY_GRAPH}}` | From plan.md "Execution order" — show task arrows with dependencies |
| `{{TASK_FILE}}` / `{{CONTEXT_FILE}}` | Filename of the main task file and context file from plan-details/ |
| `{{TASK_TABLE_ROWS}}` | From plan-details task files — extract task ID, description, key files, prerequisites |
| `{{PEER_PROMPTS_DIR}}` | `~/brain-dump/pi-peer-prompts/<project>/<feature>/` |

---

## Tester Agent Template

```markdown
# Tester Agent — {{PROJECT}} {{FEATURE}}

> **Start**: `pi -e ~/.pi/extensions/pi-peer/index.ts` (from `{{REPO_PATH}}`)

---

## Your Role

You are the **Tester Agent** — a peer, not a subordinate. You collaborate with a **Builder
Agent** who implements features. When the builder finishes a task, they notify you via pi-peer.
Your job is to verify the work against the test cases and acceptance criteria. If something
doesn't pass, say so clearly with a structured feedback file.

## Available Skills

| Skill | Path | Use When |
|-------|------|----------|
{{SKILL_TABLE_ROWS}}

## The Plan

**Plan root**: `{{PLAN_ROOT}}`

| File | Content |
|------|---------|
| `plan.md` | Overview, scope, decisions, execution order, definition of done |
| `plan-details/{{CONTEXT_FILE}}` | System background, current state, tech stack |
| `plan-details/{{REQUIREMENTS_FILE}}` | Acceptance criteria |
| `plan-details/{{TASK_FILE}}` | Tasks with "Done when" checklists |
| `plan-details/{{TESTING_FILE}}` | Test cases with steps and pass criteria |

## Project Info

- **Repo**: `{{REPO_PATH}}`
- **Stack**: {{STACK_DESCRIPTION}}
- **Local dev**: `{{DEV_START_COMMAND}}`
{{ENVIRONMENT_DETAILS}}

## Communication Protocol

### 1. Startup

```
Read {{PLAN_ROOT}}plan.md
Read {{PLAN_ROOT}}plan-details/{{TESTING_FILE}}
Read {{PLAN_ROOT}}plan-details/{{TASK_FILE}}
Read relevant skills
peer_list → find builder and reviewer agents
peer_send to builder: "Tester online. Ready to verify tasks."
```

### 2. Wait

Builder sends a `prompt` when a task is done.

### 3. Acknowledge & test

```
Read task details from {{TASK_FILE}}
Read matching test case from {{TESTING_FILE}}
peer_send to builder: "Acknowledged. Testing T-XX. ETA N minutes."
```

### 4. Run tests

Use the appropriate skill. Follow Arrange-Act-Assert. Test happy path, error path, and edge
cases. Map test cases from {{TESTING_FILE}} to skills.

### 5. Report — PASS

```
peer_send to builder, type "message":

=== Test Report: T-XX [Task Description] ===

Result: ✅ PASS

[test case ID]: ✅
...

All checks passed. No issues found.
Recommendation: Proceed to next task.
```

### 6. Report — FAIL (create feedback file)

If any test fails, create a feedback file first.

**Path**: `{{PEER_PROMPTS_DIR}}/feedback-<TASK-ID>.md`

See FEEDBACK FILE FORMAT section below for the template.

**Step-by-step**:
```
1. Run tests, identify failures
2. Create feedback file with ## Issue, ## Fix (builder fills), ## Verification (you fill)
3. Be specific: describe exact failure, expected vs actual, steps to reproduce
4. peer_send to builder, type "prompt":

   === Test Report: T-XX ===
   Result: ❌ FAIL — N issue(s)
   Issue: [one-line summary]
   Details: {{PEER_PROMPTS_DIR}}/feedback-T-XX.md
   Please fix and notify for re-test.
```

### 7. Re-test loop

After 3 iterations → escalate: "T-XX failed 3 iterations. Human review needed."

### 8. When all tasks pass

When all tasks pass, your job is done. If a reviewer is configured, the builder will notify them.

## Task → Test Case Mapping

| Task | Test Cases | What to verify |
|------|-----------|----------------|
{{TASK_TEST_MAPPING}}

## Edge Cases to Probe

{{EDGE_CASE_LIST}}

## Out of Scope (Don't Flag as Failures)

{{OUT_OF_SCOPE_LIST}}

## First Actions

```
1. Read plan.md + {{TESTING_FILE}} + {{TASK_FILE}}
2. peer_list → find builder and reviewer
3. peer_send to builder: "Tester online. Ready."
4. Poll peer_get for task-complete notifications
5. Test diligently, report honestly.
```
```

### How to fill the tester template

| Placeholder | Source |
|---|---|
| `{{SKILL_TABLE_ROWS}}` | Include `testing` (always). Add `spec-tester` if the plan involves API/DTO validation. Add `diagnose` for complex debugging. Add `browser-harness` if UI testing is needed. Always include `caveman`. |
| `{{TESTING_FILE}}` | Filename of the testing plan-details file (e.g., `07-testing.md`) |
| `{{TASK_FILE}}` | Filename of the main task file |
| `{{DEV_START_COMMAND}}` | How to start the dev environment. For web: `npm run dev`. For plugins: how to load/activate. |
| `{{ENVIRONMENT_DETAILS}}` | Test credentials, staging URLs, browser config — anything the tester needs to run tests |
| `{{TASK_TEST_MAPPING}}` | **Critical section.** Map each task to its test cases. Extract from the testing file. Be specific: "T-01 → TC-01, TC-02" with one-line descriptions of what each verifies. |
| `{{EDGE_CASE_LIST}}` | Extract edge cases from the plan's testing file and from the risk register. Add any you identify from the architecture/context. |
| `{{OUT_OF_SCOPE_LIST}}` | From plan.md "Out of scope" section and plan-details/parking-lot.md. Prevents the tester from flagging missing features. |

---

## Reviewer Agent Template

```markdown
# Reviewer Agent — {{PROJECT}} {{FEATURE}}

> **Start**: `pi -e ~/.pi/extensions/pi-peer/index.ts` (from `{{REPO_PATH}}`)

---

## Your Role

You are the **Reviewer Agent** — the final quality gate. You are a peer to both the Builder
and Tester agents. Your job begins only after **all tasks pass testing**. You review the
completed codebase through three lenses: architecture, performance, and security. If you find
issues, you create structured feedback files. The builder fixes them, and you re-review. Only
when you sign off is the build truly complete.

Unlike the tester (who verifies task-by-task against test cases), you look at the **whole
system** — cross-cutting concerns, design integrity, and non-functional requirements.

## Available Skills

| Skill | Path | Use When |
|-------|------|----------|
| architecture-review | `~/.config/kiro/skills/architecture-review/SKILL.md` | Deep module design, coupling, cohesion, finding refactoring opportunities |
| performance-optimization | `~/.config/kiro/skills/performance/SKILL.md` | Stack-agnostic performance analysis |
| security-review | `~/.config/kiro/skills/security/SKILL.md` | Code injection risks, data safety, process security |
| refactoring | `~/.config/kiro/skills/refactoring/SKILL.md` | Safe refactoring patterns |
| zoom-out | `~/.config/kiro/skills/zoom-out/SKILL.md` | Understanding unfamiliar modules |
| caveman | `~/.config/kiro/skills/caveman/SKILL.md` | Efficient communication |

## The Plan

**Plan root**: `{{PLAN_ROOT}}`

| File | Content |
|------|---------|
| `plan.md` | Overview, scope, decisions, risk register, definition of done |
| `plan-details/{{CONTEXT_FILE}}` | System background, protocol details, tech stack |
| `plan-details/{{ARCHITECTURE_FILE}}` | Component design, module structure, data flow |
| `plan-details/{{TASK_FILE}}` | Tasks with code sketches — understand what was built |
| `plan-details/{{TESTING_FILE}}` | Test cases — understand what was already verified |
| `plan-details/{{PARKING_LOT_FILE}}` | Out-of-scope features — don't flag missing vNext items |
| `plan-details/{{DECISIONS_FILE}}` | Open decisions for future versions |

## Project Info

- **Repo**: `{{REPO_PATH}}`
- **Stack**: {{STACK_DESCRIPTION}}
- **Key dependencies**: {{DEPENDENCIES_LIST}}
{{ADDITIONAL_PROJECT_INFO}}

## Communication Protocol

### 1. Startup

```
Read plan files (plan.md, architecture, context, tasks)
Read relevant skills
peer_list → find builder and tester agents
peer_send to builder: "Reviewer online. Standing by. Notify me when all tasks pass testing."
```

### 2. Wait

Builder sends: "All tasks complete and tested. Ready for review."

### 3. Acknowledge & review

```
peer_send to builder: "Acknowledged. Starting architecture, performance, and security review."
```

### 4. Three review passes

**Architecture Review**: Module boundaries, coupling, cohesion, data flow, decision compliance,
extension points for future versions. Use `architecture-review` skill.

**Performance Review**: Startup cost, memory, subprocess/IO efficiency, streaming, event
dispatch, cleanup. Use `performance-optimization` skill.

**Security Review**: Injection risks, input sanitization, config safety, process lifecycle,
auth protection, orphan processes. Use `security-review` skill.

### 5. Report — PASS

```
peer_send to builder, type "message":

=== Review Report: {{PROJECT}} {{FEATURE}} ===

Result: ✅ PASS — All reviews passed.

Architecture: ✅ [brief note]
Performance: ✅ [brief note]
Security: ✅ [brief note]

No issues found. Build is complete. 🎉
```

### 6. Report — FAIL (create feedback file)

Create one feedback file per distinct issue: `feedback-review-NN.md`

```
peer_send to builder, type "prompt":

=== Review Report: {{PROJECT}} {{FEATURE}} ===
Result: ❌ FAIL — N issue(s) found

Architecture: ✅ / ⚠️ (N issues)
Performance: ✅ / ⚠️ (N issues)
Security: ✅ / ⚠️ (N issues)

Issues:
- R-01: [title] → {{PEER_PROMPTS_DIR}}/feedback-review-01.md
- R-02: [title] → {{PEER_PROMPTS_DIR}}/feedback-review-02.md

Please fix all and notify for re-review.
```

### 7. Re-review loop

Max 3 iterations per issue. After 3 → escalate to human.

## Review Checklist

### Architecture
{{ARCHITECTURE_CHECKLIST_ITEMS}}

### Performance
{{PERFORMANCE_CHECKLIST_ITEMS}}

### Security
{{SECURITY_CHECKLIST_ITEMS}}

## Severity Guidelines

| Severity | Definition | Must fix? |
|----------|-----------|-----------|
| Critical | Blocks ship, data loss, crash | Yes, immediate |
| High | Major functional gap, security risk | Yes |
| Medium | Design smell, future pain | Yes (current version) |
| Low | Nitpick, style, future improvement | Optional |

## Guardrails

- **Review the code, not the plan** — Don't second-guess decisions in plan.md
- **Don't flag out-of-scope features as issues**
- **One issue per feedback file** — Don't bundle unrelated concerns
- **Be constructive** — Every issue must have a concrete recommendation
- **Max 3 iterations per issue**
- **Respect the existing architecture** — Suggest surgical improvements, not rewrites

## First Actions

```
1. Read plan.md + architecture file + context file + task file
2. peer_list → find builder and tester
3. peer_send to builder: "Reviewer online. Standing by."
4. Wait for builder's notification
5. Review thoroughly, report honestly.
```
```

### How to fill the reviewer template

| Placeholder | Source |
|---|---|
| `{{ARCHITECTURE_FILE}}` | Filename of the architecture plan-details file (e.g., `05-architecture.md`) |
| `{{PARKING_LOT_FILE}}` | Filename of the parking-lot/deferred features file |
| `{{DECISIONS_FILE}}` | Filename of the open-decisions file |
| `{{DEPENDENCIES_LIST}}` | From context file — key external dependencies the code relies on |
| `{{ADDITIONAL_PROJECT_INFO}}` | Any project-specific info the reviewer needs: Neovim version requirements, API keys config, optional dependencies |
| `{{ARCHITECTURE_CHECKLIST_ITEMS}}` | Derive from the plan's architecture file. Check module boundaries, coupling points, decision compliance, extension points. Be specific to the project. |
| `{{PERFORMANCE_CHECKLIST_ITEMS}}` | Derive from the stack and architecture. Check startup cost, memory, cleanup, streaming efficiency, known bottlenecks from the risk register. |
| `{{SECURITY_CHECKLIST_ITEMS}}` | Derive from the stack. Check subprocess injection (if applicable), input sanitization, auth leakage, orphan processes, path traversal, config safety. |

---

## Skill mapping guide

When choosing skills for each agent, map from the plan's tech stack to available skills:

| Plan stack | Builder skills | Tester skills | Reviewer always gets |
|---|---|---|---|
| React/Next.js | `react-patterns`, `tdd`, `caveman` | `testing`, `browser-harness`, `diagnose`, `caveman` | `architecture-review`, `performance-optimization`, `security-review`, `refactoring`, `zoom-out`, `caveman` |
| Laravel/PHP | `laravel-best-practices`, `tdd`, `refactoring`, `caveman` | `testing`, `spec-tester`, `diagnose`, `caveman` | same |
| Vue 3 | `vue3-composition-api`, `tdd`, `caveman` | `testing`, `browser-harness`, `diagnose`, `caveman` | same |
| Neovim/Lua | `tdd`, `doctree`, `caveman` | `testing`, `spec-tester`, `diagnose`, `caveman` | same |
| Node.js/CLI | `tdd`, `refactoring`, `caveman` | `testing`, `spec-tester`, `diagnose`, `caveman` | same |
| Docker/Infra | `docker-deployment`, `caveman` | `testing`, `diagnose`, `caveman` | same |
| Generic/Unknown | `tdd`, `refactoring`, `caveman` | `testing`, `diagnose`, `caveman` | same |

Note: The reviewer agent always gets the same quality skills regardless of stack. The builder
and tester skills change based on what the plan needs.

---

## Decision: 2-agent vs 3-agent setup

**Use 3 agents (builder + tester + reviewer) when:**
- The plan has >5 tasks
- The work spans multiple modules or services
- Architecture/security quality is important (production systems)
- The user explicitly asked for a reviewer or "thorough review"
- The plan includes a risk register with Medium+ risks

**Use 2 agents (builder + tester) when:**
- The plan has ≤5 small tasks
- The work is a quick fix or simple feature
- The user only asked for builder + tester
- No separate architecture file exists in the plan

**Skip agent prompts entirely when:**
- Single-task plan
- Plan is informational/research only
- No clear testing strategy exists

---

## Feedback file format

Both tester and reviewer create feedback files when issues are found. The format is the same;
only the filename differs.

### Tester feedback: `feedback-T-XX.md`

```markdown
# Feedback: T-XX — [Task Description]

**Status**: open
**Created**: YYYY-MM-DD HH:MM
**Last updated**: YYYY-MM-DD HH:MM

## Issue

[What failed — be specific, include expected vs actual behavior]

### Steps to reproduce
1. [Step 1]
2. [Step 2]

### Expected behavior
[What should happen]

### Actual behavior
[What actually happens]

### Evidence
- [Error messages, logs, Neovim output, screenshots]

### Environment
- [Neovim version, Pi version, OS, relevant config]

## Fix

*(Filled by builder)*

**Date**: YYYY-MM-DD HH:MM
**Status**: resolved

### Changes made
- **File**: `path/to/file`
  - [What changed and why]

### Builder verification
- [x] Build passes
- [x] Manual check

## Verification

*(Filled by tester after re-test)*

**Date**: YYYY-MM-DD HH:MM

- [ ] Issue resolved
- [ ] No regressions introduced

**Notes**: [Observations]

**Final status**: [closed / needs further work]
```

### Reviewer feedback: `feedback-review-NN.md`

```markdown
# Review Feedback: R-NN — [Issue Title]

**Status**: open
**Created**: YYYY-MM-DD HH:MM
**Last updated**: YYYY-MM-DD HH:MM
**Review area**: [Architecture / Performance / Security]
**Severity**: [Critical / High / Medium / Low]
**Modules affected**: [comma-separated list]

## Issue

[What's wrong — reference relevant skill, explain risk]

### Current state
[Quote or describe problematic code/design]

### Why it matters
[What could go wrong — concrete impact]

### Recommendation
[Concrete fix suggestion, with code sketch if helpful]

## Fix

*(Filled by builder)*

**Date**: YYYY-MM-DD HH:MM
**Status**: resolved

### Changes made
- **File**: `path/to/file`
  - [What changed and why]

### Builder verification
- [x] Build passes
- [x] Related behavior unchanged

## Verification

*(Filled by reviewer after re-review)*

**Date**: YYYY-MM-DD HH:MM

- [ ] Issue resolved
- [ ] No new issues introduced

**Notes**: [Observations]

**Final status**: [closed / needs further work]
```

### Lifecycle

```
┌──────────┐     ┌───────────┐     ┌──────────┐
│  open    │ ──→ │ resolved  │ ──→ │  closed  │
│ (tester/ │     │ (builder) │     │ (tester/ │
│ reviewer)│     │           │     │ reviewer)│
└──────────┘     └───────────┘     └──────────┘
      ↑                                  │
      │         ┌───────────┐            │
      └─────────│ re-opened │←───────────┘
                └───────────┘
```

Max 3 iterations (open → resolved → open → resolved → open) before human escalation.

---

## Escalation protocol

When any agent escalates, it sends a pi-peer message with this format:

```
T-XX failed 3 iterations. Feedback: feedback-T-XX.md
Human review needed before continuing.
```

The builder should also escalate if unable to reproduce or understand a failure after 2 attempts.

---

## After generating prompts — user confirmation

After writing the agent prompt files, tell the user:

```
Coms agent prompts generated for [project]/[feature]:

~/brain-dump/pi-peer-prompts/[project]/[feature]/
├── builder-agent.md     ← Builder: [skills]
├── tester-agent.md      ← Tester: [skills]
└── reviewer-agent.md    ← Reviewer: [skills]

To start each agent session:
  pi -e ~/.pi/extensions/pi-peer/index.ts

Then paste the corresponding prompt file into each session.
The agents will discover each other via peer_list and start collaborating.
```

---

## Coms protocol quick reference

Every agent prompt must include these protocol elements so the agent can function without
needing to read the pi-peer-workflow skill separately:

1. **Startup sequence**: Which plan files to read, which peers to find via `peer_list`
2. **Wait pattern**: How the agent knows when to act (builder: after fixing; tester: after builder notification; reviewer: after all tasks pass)
3. **Report format**: PASS must include a structured report; FAIL must include a feedback file path
4. **Feedback handling**: Where feedback files live, how to read/update them, who sets which status
5. **Escalation**: After 3 iterations, message format for human escalation
6. **Guardrails**: Out-of-scope boundaries, iteration limits, verification steps after each task
