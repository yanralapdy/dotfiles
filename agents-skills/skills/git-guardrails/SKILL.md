---
name: git-guardrails
description: Set up kiro-cli hooks to block dangerous git commands (push, reset --hard, clean, branch -D, etc.) before they execute. Use when user wants to prevent destructive git operations, add git safety hooks, or block git push/reset in kiro-cli.
---

# Setup Git Guardrails

Sets up a preToolUse hook that intercepts and blocks dangerous git commands before kiro-cli executes them.

## What Gets Blocked

- `git push` (all variants including `--force`)
- `git reset --hard`
- `git clean -f` / `git clean -fd`
- `git branch -D`
- `git checkout .` / `git restore .`

When blocked, the agent sees a message telling it that it does not have authority to access these commands.

## Steps

### 1. Ask scope
Ask the user: install for **this project only** (`.kiro/agents/` local config) or **all projects** (`~/.kiro/agents/` global config)?

### 2. Create hook script
Create a script that checks for dangerous git commands. Save it to:
- **Project**: `.kiro/hooks/block-dangerous-git.sh`
- **Global**: `~/.kiro/hooks/block-dangerous-git.sh`

Make it executable with `chmod +x`.

### 3. Hook script template

```bash
#!/bin/bash
# block-dangerous-git.sh — blocks dangerous git commands

set -e
command="$(cat)"

dangerous_patterns=(
    "^git push"
    "^git reset --hard"
    "^git clean -f"
    "^git clean -fd"
    "^git branch -D"
    "^git checkout \."
    "^git restore \."
)

for pattern in "${dangerous_patterns[@]}"; do
    if echo "$command" | grep -qE "$pattern"; then
        echo "BLOCKED: Dangerous git command detected: $command" >&2
        echo "This command requires explicit approval from a human." >&2
        exit 2
    fi
done

echo "$command"
```

### 4. Add hook to agent configuration

Add to the appropriate agent configuration file:

**Project** (`.kiro/agents/<agent-name>.json`):
```json
{
  "hooks": {
    "preToolUse": [
      {
        "matcher": "execute_bash",
        "command": "\"$PWD\"/.kiro/hooks/block-dangerous-git.sh"
      }
    ]
  }
}
```

**Global** (`~/.kiro/agents/<agent-name>.json`):
```json
{
  "hooks": {
    "preToolUse": [
      {
        "matcher": "execute_bash",
        "command": "~/.kiro/hooks/block-dangerous-git.sh"
      }
    ]
  }
}
```

If the agent config already exists, merge the hook into existing `hooks.preToolUse` array — don't overwrite other settings.

### 5. Ask about customization
Ask if user wants to add or remove any patterns from the blocked list. Edit the script accordingly.

### 6. Verify
Run a quick test:
```bash
echo 'git push origin main' | .kiro/hooks/block-dangerous-git.sh
```
Should exit with non-zero code and print a BLOCKED message to stderr.
