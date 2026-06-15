# Kiro Skills

Skills for Real Engineers — adapted from Matt Pocock's skills repo for kiro-cli.

Developing real applications is hard. These skills are designed to be small, easy to adapt, and composable. They work with any model. They're based on decades of engineering experience. Hack around with them. Make them your own. Enjoy.

## Quickstart

1. Clone this repo (or use it from your dotfiles):
   ```bash
   # If using from dotfiles:
   cd ~/.dotfiles/kiro-skills
   
   # Or clone standalone:
   git clone https://github.com/yourusername/kiro-skills.git
   cd kiro-skills
   ```

2. Install skills:
   ```bash
   ./scripts/install.sh list          # See all available skills
   ./scripts/install.sh install tdd   # Install specific skill
   ./scripts/install.sh install --all # Install everything
   ```

3. Skills will be symlinked to `~/.kiro/skills/` where kiro-cli can discover them.

## Why These Skills Exist

I built these skills as a way to fix common failure modes I see with AI coding agents.

### #1: The Agent Didn't Do What I Want

**The Problem**. The most common failure mode in software development is misalignment. You think the dev knows what you want. Then you see what they've built - and you realize it didn't understand you at all.

This is just the same in the AI age. There is a communication gap between you and the agent. The fix for this is a **grilling session** - getting the agent to ask you detailed questions about what you're building.

**The Fix** is to use:
* `grill-me` - for non-code uses
* `grill-with-docs` - same as `grill-me`, but adds more goodies (see below)

These are my most popular skills. They help you align with the agent before you get started, and think deeply about the change you're making. Use them *every* time you want to make a change.

### #2: The Agent Is Way Too Verbose

**The Problem**: At the start of a project, devs and the people they're building the software for (the domain experts) are usually speaking different languages.

I felt the same tension with my agents. Agents are usually dropped into a project and asked to figure out the jargon as they go. So they use 20 words where 1 will do.

**The Fix** for this is a shared language. It's a document that helps agents decode the jargon used in the project.

Example

Here's an example `CONTEXT.md`, from my `course-video-manager` repo. Which one is easier to read?
* **BEFORE**: "There's a problem when a lesson inside a section of a course is made 'real' (i.e. given a spot in the file system)"
* **AFTER**: "There's a problem with the materialization cascade"

This concision pays off session after session.

This is built into `grill-with-docs`. It's a grilling session, but that helps you build a shared language with the AI, and document hard-to-explain decisions in ADR's.

It's hard to explain how powerful this is. It might be the single coolest technique in this repo. Try it, and see.

Tip

A shared language has many other benefits than reducing verbosity:
* **Variables, functions and files are named consistently**, using the shared language
* As a result, the **codebase is easier to navigate** for the agent
* The agent also **spends fewer tokens on thinking**, because it has access to a more concise language

### #3: The Code Doesn't Work

**The Problem**: Let's say that you and the agent are aligned on what to build. What happens when the agent *still* produces crap?

It's time to look at your feedback loops. Without feedback on how the code it produces actually runs, the agent will be flying blind.

**The Fix**: You need the usual tranche of feedback loops: static types, browser access, and automated tests.

For automated tests, a red-green-refactor loop is critical. This is where the agent writes a failing test first, then fixes the test. This helps give the agent a consistent level of feedback that results in far better code.

I've built a **`tdd` skill** you can slot into any project. It encourages red-green-refactor and gives the agent plenty of guidance on what makes good and bad tests.

For debugging, I've also built a **`diagnose`** skill that wraps best debugging practices into a simple loop.

### #4: We Built A Ball Of Mud

**The Problem**: Most apps built with agents are complex and hard to change. Because agents can radically speed up coding, they also accelerate software entropy. Codebases get more complex at an unprecedented rate.

**The Fix** for this is a radical new approach to AI-powered development: caring about the design of the code.

This is built in to every layer of these skills:
* `to-prd` quizzes you about which modules you're touching before creating a PRD
* `zoom-out` tells the agent to explain code in the context of the whole system

And crucially, `improve-codebase-architecture` helps you rescue a codebase that has become a ball of mud. I recommend running it on your codebase once every few days.

### Summary

Software engineering fundamentals matter more than ever. These skills are my best effort at condensing these fundamentals into repeatable practices, to help you ship the best apps of your career. Enjoy.

## Reference

### Engineering

Skills I use daily for code work.
* **diagnose** — Disciplined diagnosis loop for hard bugs and performance regressions: reproduce → minimise → hypothesise → instrument → fix → regression-test.
* **grill-with-docs** — Grilling session that challenges your plan against the existing domain model, sharpens terminology, and updates `CONTEXT.md` and ADRs inline.
* **triage** — Triage issues through a state machine of triage roles.
* **improve-codebase-architecture** — Find deepening opportunities in a codebase, informed by the domain language in `CONTEXT.md` and the decisions in `docs/adr/`.
* **setup-skills** — Scaffold the per-repo config (issue tracker, triage label vocabulary, domain doc layout) that the other engineering skills consume. Run once per repo before using `to-issues`, `to-prd`, `triage`, `diagnose`, `tdd`, `improve-codebase-architecture`, or `zoom-out`.
* **tdd** — Test-driven development with a red-green-refactor loop. Builds features or fixes bugs one vertical slice at a time.
* **to-issues** — Break any plan, spec, or PRD into independently-grabbable GitHub issues using vertical slices.
* **to-prd** — Turn the current conversation context into a PRD and submit it as a GitHub issue. No interview — just synthesizes what you've already discussed.
* **zoom-out** — Tell the agent to zoom out and give broader context or a higher-level perspective on an unfamiliar section of code.
* **prototype** — Build a throwaway prototype to answer a design question — either a runnable terminal app for state/business-logic questions, or several radically different UI variations toggleable from one route.

### Productivity

General workflow tools, not code-specific.
* **caveman** — Ultra-compressed communication mode. Cuts token usage ~75% by dropping filler while keeping full technical accuracy.
* **grill-me** — Get relentlessly interviewed about a plan or design until every branch of the decision tree is resolved.
* **handoff** — Compact the current conversation into a handoff document so another agent can continue the work.
* **write-a-skill** — Create new skills with proper structure, progressive disclosure, and bundled resources.

### Misc

Tools I keep around but rarely use.
* **git-guardrails** — Set up kiro-cli hooks to block dangerous git commands (push, reset --hard, clean, etc.) before they execute.
* **migrate-to-shoehorn** — Migrate test files from `as` type assertions to @total-typescript/shoehorn.
* **scaffold-exercises** — Create exercise directory structures with sections, problems, solutions, and explainers.
* **setup-pre-commit** — Set up Husky pre-commit hooks with lint-staged, Prettier, type checking, and tests.

## About

Skills for Real Engineers. Adapted from Matt Pocock's skills repo for kiro-cli.

### Resources

* [Original Matt Pocock skills repo](https://github.com/mattpocock/skills)
* [Kiro CLI documentation](https://kiro.dev/docs/cli/)

### License

MIT license