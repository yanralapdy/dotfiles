# Codebase Memory — Setup Guide

## Step 1: Check if Binary is Installed

```bash
which codebase-memory-mcp
```

If this returns a path, skip to Step 2. Otherwise, install:

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/main/install.sh | bash
```

### macOS (Homebrew)

```bash
brew install DeusData/tap/codebase-memory-mcp
```

### Windows (PowerShell)

```powershell
Invoke-WebRequest -Uri https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/main/install.ps1 -OutFile install.ps1
.\install.ps1
```

After install, verify:

```bash
which codebase-memory-mcp
# Expected: ~/.local/bin/codebase-memory-mcp (or similar)
```

If not found, add to PATH:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

---

## Step 2: Configure MCP Server for Your Agent

The `install.sh` script auto-detects agents. If it missed yours, configure manually:

### Kiro

Config file: `~/.kiro/settings/mcp.json`

Add `codebase-memory-mcp` to the `mcpServers` object:

```json
{
  "mcpServers": {
    "codebase-memory-mcp": {
      "command": "codebase-memory-mcp",
      "args": []
    }
  }
}
```

If the file already has other servers, merge into the existing `mcpServers` object — do not overwrite.

**Full path variant** (if binary not on PATH):

```json
{
  "mcpServers": {
    "codebase-memory-mcp": {
      "command": "/Users/USERNAME/.local/bin/codebase-memory-mcp",
      "args": []
    }
  }
}
```

### Pi (Ampcode)

Pi uses `packages` in `~/.config/pi/agent/settings.json`:

```json
{
  "packages": [
    "git:github.com/DeusData/codebase-memory-mcp"
  ]
}
```

Add to the existing `packages` array — do not overwrite other entries.

**Alternative**: Pi also supports MCP via the `mcpServers` key in settings:

```json
{
  "mcpServers": {
    "codebase-memory-mcp": {
      "command": "codebase-memory-mcp",
      "args": []
    }
  }
}
```

---

## Step 3: Restart Agent

After configuring, restart the agent session for MCP tools to become available.

Verify by asking the agent: "list MCP tools" — you should see tools like `index_repository`, `search_graph`, `trace_path`, etc.

---

## Step 4: Enable Auto-Index (Optional)

```bash
codebase-memory-mcp config set auto_index true
```

This auto-indexes new projects on first MCP connection.

---

## Step 5: Custom File Extensions (Optional)

For projects using non-standard extensions (e.g., Laravel `.blade.php`):

Create `.codebase-memory.json` at project root:

```json
{
  "extra_extensions": {
    ".blade.php": "php",
    ".mjs": "javascript",
    ".vue": "vue"
  }
}
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `command not found` after install | Add `export PATH="$HOME/.local/bin:$PATH"` to `~/.zshrc` or `~/.bashrc` |
| macOS Gatekeeper blocks binary | Run `xattr -d com.apple.quarantine ~/.local/bin/codebase-memory-mcp` |
| MCP tools not showing in agent | Check JSON syntax in config file; restart agent |
| Agent can't find binary | Use absolute path in `command` field |
| Install script fails | Download manually from https://github.com/DeusData/codebase-memory-mcp/releases/latest |

---

## Updating

```bash
codebase-memory-mcp update
```

## Uninstalling

```bash
codebase-memory-mcp uninstall
```

Removes all agent configs. Binary and databases remain at `~/.local/bin/` and `~/.cache/codebase-memory-mcp/`.
