# Role Catalog

Ten role archetypes. Compose them into teams. Each role is a distinct Pi session with its own prompt (`<role>-agent.md`) and its own contract with the plan.

## How to read this catalog

For each role:

- **Responsibility** — the one thing this role owns
- **Consumes** — plan artifacts and messages it reads
- **Produces** — code, feedback files, and messages it emits
- **Skills** — which dotfile skills to include in the prompt
- **Feedback style** — task-scoped or issue-scoped (see [FEEDBACK.md](FEEDBACK.md))
- **When to add** — the signal that this role is worth its own session
- **Peers** — who it typically talks to via coms

## Core roles

### Builder

- **Responsibility**: Implement tasks from the plan, one at a time. Verify each locally before handoff.
- **Consumes**: `plan.md`, `03-tasks.md`, `01-context.md`; PASS/FAIL messages; feedback files addressed to this task.
- **Produces**: code commits, `## Fix` sections in feedback files, task-done messages.
- **Skills**: language/framework skill (`react-patterns`, `laravel-best-practices`, `vue3-composition-api`…), `refactoring`, `git-workflow`, `tdd` when tests are required first.
- **Feedback style**: consumer, not producer. Updates `## Fix` in task-scoped and issue-scoped files.
- **When to add**: always. Every team needs at least one builder.
- **Peers**: tester (required), reviewer (if trio), consultant (if on-demand).

### Tester

- **Responsibility**: Verify each finished task against the plan's test cases. Approve or reject with structured evidence.
- **Consumes**: `05-testing.md` (or equivalent test-case doc), `03-tasks.md`, `02-requirements.md`; builder's task-done messages.
- **Produces**: task-scoped feedback (`feedback-<TASK-ID>.md`), PASS/FAIL reports.
- **Skills**: `testing`, `spec-tester`, `browser` (for web), `diagnose` (for hard failures), stack-specific test skills.
- **Feedback style**: task-scoped. One file per task, updated in place across iterations.
- **When to add**: any team where "does it work?" needs an independent voice. Default to always.
- **Peers**: builder (required), reviewer (hands off when all tasks pass).

### Reviewer

- **Responsibility**: Whole-system review after all tasks pass testing. Architecture, performance, security — cross-cutting concerns.
- **Consumes**: `05-architecture.md`, `01-context.md`, `04-open-decisions.md`, the committed code, tester's PASS reports.
- **Produces**: issue-scoped feedback (`feedback-review-<NN>.md`), one file per distinct concern with severity level.
- **Skills**: `architecture-review`, `performance-optimization`, `security-review`, `refactoring`, `zoom-out`.
- **Feedback style**: issue-scoped. Sequential NN per concern, severity-tagged (Critical/High/Medium/Low).
- **When to add**: v1 shipping, security-sensitive changes, refactor of shared infrastructure, code the team will maintain for years.
- **Peers**: builder (main), tester (waits for tester's all-pass signal).

## Planning roles

### Planner

- **Responsibility**: Convert requirements into a task-decomposed plan before any code is written.
- **Consumes**: user intent, existing codebase context, product docs.
- **Produces**: `plan.md`, `plan-details/03-tasks.md`, `plan-details/05-testing.md`. Then hands off and typically exits.
- **Skills**: `session-planner`, `to-prd`, `to-issues`, `grill-me`, `grill-with-docs`, `architecture-review`, `adr`.
- **Feedback style**: none during execution; planner's output IS the artifact everyone else consumes.
- **When to add**: ambiguous requirements, greenfield features, cross-team work. Skip if plan already exists.
- **Peers**: hands off to builder + tester + reviewer via a single "plan ready" message, then goes idle or exits.

### Researcher

- **Responsibility**: Answer specific factual questions the builder can't resolve alone (library docs, API contracts, prior-art).
- **Consumes**: builder's `research-request` messages, external docs, existing code.
- **Produces**: `research-<NN>.md` (short summaries with citations) placed in the feature directory.
- **Skills**: `web-research`, `zoom-out`, `notion-vault`, `obsidian-vault`, `knowledge-manager`, `pdf-reader`, `markitdown`, `browser` (for live pages).
- **Feedback style**: not applicable. Produces research notes, not fix requests.
- **When to add**: unfamiliar third-party library, spec that requires archaeology, prior migration in this codebase, math or algorithm lookup.
- **Peers**: builder (on-demand). Sometimes planner during discovery.

## Specialist review roles

### Security-scanner

- **Responsibility**: Focused security pass — injection, secrets, authz, input validation, supply chain.
- **Consumes**: committed code, `01-context.md`, `security-review` skill.
- **Produces**: issue-scoped feedback (`feedback-security-<NN>.md`), severity mandatory.
- **Skills**: `security-review`, `threat-modeling`, `dependency-audit`, `zoom-out`.
- **Feedback style**: issue-scoped. Sequential NN. Every finding must include exploitation scenario.
- **When to add**: authentication code, payment flows, PII handling, public APIs, admin panels, cryptographic code.
- **Peers**: parallel to reviewer or replaces the security lens of a general reviewer.

### Performance-analyzer

- **Responsibility**: Focused performance pass — startup cost, memory, N+1s, unnecessary work, allocation patterns.
- **Consumes**: committed code, profiling data if available, `performance-optimization` skill.
- **Produces**: issue-scoped feedback (`feedback-perf-<NN>.md`), with measured or estimated impact.
- **Skills**: `performance-optimization`, `observability`, `database-design` (for DB-heavy work), `zoom-out`.
- **Feedback style**: issue-scoped. Every finding must include impact estimate (ms, MB, or Big-O).
- **When to add**: hot paths, high-throughput endpoints, batch jobs, mobile apps, embedded targets.
- **Peers**: parallel to reviewer/security in concurrent fan-out topologies.

## Delivery roles

### Documenter

- **Responsibility**: Update user-facing and internal docs after review passes.
- **Consumes**: final code, reviewer PASS report, existing docs (`docs/`, `README.md`, `CHANGELOG.md`).
- **Produces**: doc commits — README updates, changelog entries, ADRs, migration notes.
- **Skills**: `doctree`, `adr`, `stop-slop`, `notion-vault`, `obsidian-vault`.
- **Feedback style**: consumer of others' PASS reports; produces no feedback of its own.
- **When to add**: user-facing releases, breaking API changes, new subsystems that the next agent will need to understand.
- **Peers**: reviewer (waits for PASS), deployer (hands off when docs merged).

### Deployer

- **Responsibility**: Ship the change to staging/production. Verify deploy health.
- **Consumes**: reviewer PASS, documenter PASS, `docker-deployment` skill, deploy configs.
- **Produces**: deploy runs, health check evidence, rollback notes if needed.
- **Skills**: `ci-cd-pipeline`, `docker-deployment`, `observability`, `git-workflow`, `use_aws` or platform equivalent.
- **Feedback style**: emits deploy-failed messages that route back to builder as high-severity issue-scoped feedback.
- **When to add**: teams that own the deploy pipeline, not code-only teams. Skip if deploy is out-of-band.
- **Peers**: waits for documenter (or reviewer if no documenter). Final stage in most pipelines.

## Ambient roles

### Consultant

- **Responsibility**: Answer targeted questions on demand. Never modifies code.
- **Consumes**: builder's `consult` messages with concrete question + context.
- **Produces**: advice replies via coms. Optionally a `consult-<NN>.md` note if the answer is long or reusable.
- **Skills**: domain-specific (`database-design`, `laravel-best-practices`, `react-patterns`, `security-review`, whatever expertise is needed).
- **Feedback style**: not applicable. Consultant advises, never blocks.
- **When to add**: builder needs a specialist voice occasionally but not on every task. Cheaper than a full reviewer.
- **Peers**: exactly one caller (usually builder). Multiple consultants can coexist for different domains.

## Custom roles

Coining a new role: mint it from the base template ([TEMPLATES.md](TEMPLATES.md#base-template)) and answer these seven questions in its prompt:

1. **What does this role own** that no existing role covers?
2. **What does it consume** from the plan and from other agents?
3. **What does it produce** — code, feedback files, notes, deploys?
4. **Which skills** does it load at startup?
5. **What feedback style** — task-scoped, issue-scoped, or none?
6. **When does it start** — always, on-demand, after another role's PASS?
7. **Who are its peers** and what handoff message wakes it up?

If a proposed role can't answer all seven cleanly, fold it into an existing role instead.

## Composition rules

- **Two builders → forbidden.** Split the work across features instead. Two builders on the same code will race.
- **Multiple reviewers → concurrent fan-out.** Use specialist reviewers (`security-scanner`, `performance-analyzer`) in parallel rather than duplicating the generalist reviewer.
- **One tester per builder.** If tests take longer than build, add test cases per task rather than a second tester.
- **Consultants are cheap; add them freely.** They don't block; they only respond to explicit `consult` messages.
- **Planner exits after handoff.** Don't keep a planner idle for the whole run — regenerate its output as a file, then close the session.
