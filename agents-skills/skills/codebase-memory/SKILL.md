---
name: codebase-memory
description: Index codebases into a persistent knowledge graph and query structure, call chains, architecture, and impact via codebase-memory-mcp. Use when user says "index this project", "what calls X", "show architecture", "trace", "dead code", "impact of changes", or needs structural code intelligence beyond grep.
---

# Codebase Memory

Structural code intelligence via knowledge graph. Index once, query in sub-milliseconds.

## Prerequisites

Before any indexing or querying, verify the MCP server is installed and configured:

```bash
which codebase-memory-mcp
```

**If not found** — install and configure. See [SETUP.md](SETUP.md) for full instructions, or quick path:

```bash
# Install binary
curl -fsSL https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/main/install.sh | bash

# Verify
which codebase-memory-mcp
```

**If installed but MCP tools unavailable** — the server isn't configured for this agent. Add to config:

- **Kiro**: Add to `~/.kiro/settings/mcp.json` → `mcpServers.codebase-memory-mcp`
- **Pi**: Add `"git:github.com/DeusData/codebase-memory-mcp"` to `packages` in `~/.config/pi/agent/settings.json`

Then restart the agent session. See [SETUP.md](SETUP.md) for exact JSON snippets.

## Quick Start

**Index current project:**
```
index_repository(repo_path="/absolute/path/to/project")
```

**Find a function:**
```
search_graph(name_pattern=".*ProcessOrder.*", label="Function")
```

**Trace callers:**
```
trace_path(function_name="ProcessOrder", direction="inbound")
```

## Workflows

### First-time project indexing

1. Run `index_repository` with the absolute repo path
2. Run `get_graph_schema` to understand available labels and edges
3. Run `get_architecture` for high-level overview

### Structural exploration

| Goal | Tool | Example |
|------|------|---------|
| Find symbols by name | `search_graph` | `name_pattern=".*Handler.*", label="Function"` |
| Who calls function X | `trace_path` | `function_name="X", direction="inbound"` |
| What does X call | `trace_path` | `function_name="X", direction="outbound"` |
| Full call chain | `trace_path` | `function_name="X", direction="both", depth=3` |
| Read source code | `get_code_snippet` | `qualified_name="project.path.FunctionName"` |
| Grep indexed files | `search_code` | `query="TODO", file_pattern="*.py"` |

### Impact analysis

1. `detect_changes` — maps uncommitted git diff to affected symbols with risk classification
2. `trace_path` on high-risk symbols — understand blast radius
3. `query_graph` with Cypher — custom traversals for edge cases

### Architecture overview

`get_architecture` returns: languages, packages, entry points, HTTP routes, hotspots (high fan-in/fan-out), boundaries, layers, and clusters.

### Dead code detection

```
query_graph(query="MATCH (f:Function) WHERE NOT EXISTS { (f)<-[:CALLS]-() } AND f.name <> 'main' RETURN f.name, f.file LIMIT 20")
```

### Multi-project

Use `list_projects` to see all indexed repos. Add `project="name"` to any query tool to scope results.

## Cypher Queries

`query_graph` accepts a read-only openCypher subset. Common patterns:

```cypher
-- Functions with most callers (hotspots)
MATCH (f:Function)<-[:CALLS]-(caller) RETURN f.name, count(caller) AS fans ORDER BY fans DESC LIMIT 10

-- Classes implementing an interface
MATCH (c:Class)-[:IMPLEMENTS]->(i:Interface) WHERE i.name = 'Repository' RETURN c.name, c.file

-- Cross-file imports
MATCH (a:File)-[:IMPORTS]->(b:File) WHERE a.name CONTAINS 'controller' RETURN a.name, b.name
```

See [REFERENCE.md](REFERENCE.md) for full Cypher syntax and more examples.

## Configuration

```bash
codebase-memory-mcp config set auto_index true
```

For custom file extensions, add `.codebase-memory.json` at project root:
```json
{"extra_extensions": {".blade.php": "php", ".mjs": "javascript"}}
```

## Tips

- Always use **absolute paths** with `index_repository`
- Run `search_graph` first to discover exact qualified names before `trace_path` or `get_code_snippet`
- Add `project="name"` when multiple repos are indexed
- Use `get_graph_schema` to see available node labels and edge types before writing Cypher
- Indexes persist across sessions at `~/.cache/codebase-memory-mcp/`
