# Agent Skills

This document helps kiro-cli agents understand how to work with this repository's skills and conventions.

## Available Skills

This repository contains skills adapted from Matt Pocock's skills repo for kiro-cli. Skills are organized by category:

### Engineering
* **diagnose** — Disciplined diagnosis loop for hard bugs and performance regressions
* **grill-with-docs** — Grilling session that updates CONTEXT.md and ADRs inline
* **triage** — Triage issues through a state machine of triage roles
* **improve-codebase-architecture** — Find deepening opportunities in a codebase
* **setup-skills** — Scaffold per-repo config for engineering skills
* **tdd** — Test-driven development with red-green-refactor loop
* **to-issues** — Break plans into independently-grabbable issues
* **to-prd** — Turn conversation context into a PRD
* **zoom-out** — Give broader context on unfamiliar code
* **prototype** — Build throwaway prototypes for design questions

### Productivity
* **caveman** — Ultra-compressed communication mode
* **grill-me** — Relentless interview about plans/designs
* **handoff** — Compact conversation into handoff document
* **write-a-skill** — Create new skills with proper structure

### Misc
* **git-guardrails** — Block dangerous git commands
* **migrate-to-shoehorn** — Migrate test files from `as` to @total-typescript/shoehorn
* **scaffold-exercises** — Create exercise directory structures
* **setup-pre-commit** — Set up Husky pre-commit hooks

## How Skills Work

Skills are discovered by kiro-cli through the `skill://` URI scheme. When an agent loads this repository as a resource, it can access skill descriptions and trigger them based on user requests.

### Skill Structure
Each skill is a directory containing:
- `SKILL.md` — Main instructions with YAML frontmatter
- Optional reference files (REFERENCE.md, EXAMPLES.md)
- Optional scripts directory for deterministic operations

### YAML Frontmatter
Skills use YAML frontmatter for metadata:
```yaml
--- name: skill-name description: Brief description. Use when [specific triggers]. ---
```

The description is critical — it's what agents see when deciding which skill to load.

## Using Skills

### For Users
1. Install skills using the installer: `./scripts/install.sh install <skill-name>`
2. Skills are symlinked to `~/.kiro/skills/`
3. kiro-cli agents automatically discover installed skills

### For Agents
1. Read the skill description to understand when to trigger it
2. Follow the skill's instructions precisely
3. Update documentation (CONTEXT.md, ADRs) as specified in the skill
4. Use the project's domain language from CONTEXT.md

## Repository Conventions

### Domain Documentation
- `CONTEXT.md` — Project glossary and domain language
- `docs/adr/` — Architecture decision records
- `CONTEXT-MAP.md` — For multi-context repos (monorepos)

### Issue Tracking
Skills that interact with issues need to know:
- Issue tracker type (GitHub, GitLab, local markdown)
- Triage label vocabulary
- Domain doc layout

Run the `setup-skills` skill to configure these for a repository.

## Best Practices

1. **Always grill first** — Use `grill-me` or `grill-with-docs` before starting work
2. **Update CONTEXT.md** — Capture domain language as you work
3. **Write ADRs sparingly** — Only for hard-to-reverse, surprising decisions
4. **Use vertical slices** — Break work into complete end-to-end slices
5. **Test first** — Use `tdd` for features and bug fixes

## Installation

Skills can be installed individually or by category:
```bash
./scripts/install.sh list
./scripts/install.sh install tdd
./scripts/install.sh install --category engineering
./scripts/install.sh install --all
```

## Credits

These skills are adapted from Matt Pocock's [skills repository](https://github.com/mattpocock/skills) for use with kiro-cli. Original work by Matt Pocock, adapted for kiro-cli conventions.