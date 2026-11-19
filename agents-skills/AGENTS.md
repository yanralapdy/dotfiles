# Agent Skills & Agents

This document describes the available skills and agents across kiro and pi, how they're organized, and how they interact.

## Architecture Overview

### Agents vs Skills

- **Agents** are persona definitions with a model, system prompt, and assigned skills. They represent a working mode (architect, builder, reviewer, etc.) that coordinates sub-agents and skills.
- **Skills** are on-demand capability packages that get loaded into context when relevant. They provide instructions, workflows, and reference material for specific tasks.

In pi:
- Agents are switched via `/mode <agent>` command (mode-switcher extension)
- Skills are discovered automatically from skill directories and loaded by the agent on demand
- The workflow-orchestrator extension provides multi-agent pipeline coordination

In kiro:
- Agents are JSON definitions in `~/.config/kiro/agents/` with their own prompt, model, tools, and skill resources
- Skills are discovered via `skill://` URIs referenced in agent configs

## Agents

All agents are defined in `~/.dotfiles/pi/.config/pi/agent/agents/` (pi) and `~/.dotfiles/kiro/.config/kiro/agents/` (kiro).

| Agent | Model | Role | Skills |
|-------|-------|------|--------|
| **orchestrator** | claude-sonnet-4.6 | Coordinates dev pipeline: architect → builder → reviewer | handoff, caveman |
| **architect** | claude-opus-4.8 | Analyzes requirements, produces specs before code | architecture-review, postgres, prototype, grill-me |
| **builder** | claude-sonnet-4.6 | Implements code from specs, runs tests | tdd, refactoring, git-workflow |
| **code-reviewer** | claude-sonnet-4.6 | Reviews code for bugs, security, performance, style | security, performance, testing, debugging |
| **documenter** | glm-5 | Updates docs, README, changelogs after review | stop-slop |
| **researcher** | deepseek-3.2 | Explores codebases, summarizes findings | (none) |
| **test-runner** | deepseek-3.2 | Runs test/lint suites, reports results | (none) |
| **security-scanner** | claude-sonnet-4.6 | Scans for vulnerabilities (injection, secrets, authz) | security |
| **doc-fetcher** | glm-5 | Fetches external library/API documentation | (none) |

### Pi Mode Switching

Use `/mode <name>` to switch between agent personas:

| Command | Mode | Description |
|---------|------|-------------|
| `/mode architect` | Architect | Design systems, produce specs |
| `/mode builder` | Builder | Implement code from specs |
| `/mode code-reviewer` | Code Reviewer | Review code quality |
| `/mode researcher` | Researcher | Explore and summarize |
| `/mode orchestrator` | Orchestrator | Coordinate multi-agent pipeline |
| `/mode documenter` | Documenter | Update docs and changelogs |

### Pi Workflow Commands

After running `/workflow-orchestrator` to activate:

| Command | Description |
|---------|-------------|
| `/plan <task>` | Create a step-by-step plan with agent assignments |
| `/workflow list` | List active workflows |
| `/workflow run <name>` | Run a named workflow |

## Skills

Skills are organized by category. All skills live in one canonical location (`~/.dotfiles/agents-skills/skills/`) and are exposed to both kiro and pi through symlinks.

### Planning & Multi-Agent
* **session-planner** — Turn a session into an agent-executable plan
* **plan-executor** — Execute a session-planner plan task by task
* **plan-branch-executor** — Execute a plan with branch + MR review per task
* **peer-workflow** — Design peer agent teams for pi-peer
* **peer-runner** — Bootstrap a peer-workflow role session
* **handoff** — Compact conversation into handoff document

### Thinking & Research
* **grill-me** — Relentless interview about plans/designs
* **grill-with-docs** — Grilling session that updates CONTEXT.md and ADRs inline
* **research** — Research a question against primary sources into a Markdown file
* **web-research** — Web research with source triage and citations
* **codebase-memory** — Index codebases into a knowledge graph

### Development
* **git-workflow** — Git branching, commit, and PR conventions
* **git-guardrails** — Block dangerous git commands
* **mr-discord-notify** — Announce a merge request in Discord, mentioning the reviewer and naming the project
* **taste-skill** — Frontend design direction (symlink to leonxlnx/taste-skill)

### Knowledge & Writing
* **knowledge-manager** — Read, search, create, and sync Notion and Obsidian notes
* **stop-slop** — Remove AI writing patterns from prose
* **pdf-reader** — Read and comprehend PDF files (hybrid text + vision)
* **teach** / **teach-full** — Structured lessons in a workspace

### Tools
* **browser-harness** — Direct browser control via CDP for automation/scraping
* **webwright** — Playwright web tasks with screenshots (symlink)
* **write-a-skill** — Create new skills with proper structure
* **matt-pocock/** — implement, research, to-spec, to-tickets, wayfinder, setup-matt-pocock-skills

## File Locations

### Skills
| Location | Purpose |
|----------|---------|
| `~/.dotfiles/agents-skills/skills/` | **Canonical source** for all skills |
| `~/.config/kiro/skills/` | Symlink → `~/.dotfiles/agents-skills/skills/` |
| `~/.kiro/skills/` | Symlink → `~/.dotfiles/agents-skills/skills/` |
| `~/.dotfiles/kiro/.config/kiro/skills/` | Symlink → `~/.dotfiles/agents-skills/skills/` |
| `~/.dotfiles/kiro/.kiro/skills/` | Symlink → `~/.dotfiles/agents-skills/skills/` |
| `~/.dotfiles/pi/.config/pi/agent/skills/` | Symlink → `~/.dotfiles/agents-skills/skills/` |
| `~/.pi/agent/skills/` | Symlink → `~/.dotfiles/agents-skills/skills/` |

### Agents
| Location | Purpose |
|----------|---------|
| `~/.dotfiles/pi/.config/pi/agent/agents/` | Pi agent definitions (JSON) |
| `~/.pi/agent/agents/` | Symlinks → `~/.dotfiles/pi/.config/pi/agent/agents/` |
| `~/.dotfiles/kiro/.config/kiro/agents/` | Kiro agent definitions (JSON) |
| `~/.dotfiles/kiro/.kiro/agents/` | Symlinks → `~/.config/kiro/agents/` |

### Extensions
| Location | Purpose |
|----------|---------|
| `~/.dotfiles/pi/.config/pi/agent/extensions/` | Pi extensions (mode-switcher, workflow-orchestrator, plan-mode, etc.) |

## Consolidation Status

All skills are now unified under a single canonical directory and exposed to both kiro and pi via symlinks:

- ✅ Canonical source: `~/.dotfiles/agents-skills/skills/`
- ✅ Kiro runtime: `~/.config/kiro/skills/` → symlink to canonical
- ✅ Kiro runtime: `~/.kiro/skills/` → symlink to canonical
- ✅ Kiro dotfiles: `~/.dotfiles/kiro/.config/kiro/skills/` → symlink to canonical
- ✅ Kiro dotfiles: `~/.dotfiles/kiro/.kiro/skills/` → symlink to canonical
- ✅ Pi dotfiles: `~/.dotfiles/pi/.config/pi/agent/skills/` → symlink to canonical
- ✅ Pi runtime: `~/.pi/agent/skills/` → symlink to canonical
- ✅ Old `kiro-skills/` directory renamed to `agents-skills/`
- ✅ Duplicate skill directories removed (backups in `~/.dotfiles/.backups/`)
- ✅ Pi-original persona skills (architect, builder, code-reviewer, researcher) converted to agent definitions
- ✅ spec-tester kept as skill (it's domain-specific, not a persona)
- ✅ Unique skills merged both ways (knowledge-manager, write-a-skill, pdf-reader, stop-slop, notion-vault)

### Adding or modifying skills

1. Edit files in `~/.dotfiles/agents-skills/skills/<skill-name>/`
2. Changes are immediately visible to both kiro and pi through the symlink chain
3. Do **not** create pi-specific or kiro-specific copies — if a skill needs environment-aware behavior, branch inside the skill itself

## Best Practices

1. **Use the right agent** — `/mode architect` for design, `/mode builder` for implementation, `/mode code-reviewer` for review
2. **Always grill first** — Use `grill-me` or `grill-with-docs` before starting work
3. **Update CONTEXT.md** — Capture domain language as you work
4. **Write ADRs sparingly** — Only for hard-to-reverse, surprising decisions
5. **Use vertical slices** — Break work into complete end-to-end slices
6. **Test first** — Use `tdd` for features and bug fixes
7. **Hand off properly** — Use `handoff` skill when context is full or switching sessions