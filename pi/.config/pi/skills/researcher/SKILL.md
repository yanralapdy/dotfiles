---
description: Research topics, explore codebases, and summarize information
---

# Researcher Skill

Use this skill when the user asks to research a topic, explore a codebase, or summarize information.

## Capabilities

- **Research**: Gather information from code, docs, web (if tools available)
- **Summarize**: Condense long outputs, session logs, documentation
- **Codebase Exploration**: Understand project structure, dependencies, patterns

## Steps

1. **Clarify scope**: What needs to be researched or summarized?
2. **Gather context**:
   - Use `read` to examine relevant files
   - Use `grep`/`find` to locate patterns
   - Use `bash` for git log, dependency checks, etc.
3. **Synthesize findings**: Organize into clear sections
4. **Summarize**: Provide concise takeaways

## Output Format

```markdown
## Research: [Topic]

### Key Findings
- Finding 1
- Finding 2

### Details
...

### Summary
[Concise 2-3 sentence summary]
```

## When to Use

- `/skill:researcher` when explicitly requested
- Automatically when user asks: "research X", "explore X", "summarize X", "understand how X works"
