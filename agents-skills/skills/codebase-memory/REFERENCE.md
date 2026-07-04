# Codebase Memory — Reference

## MCP Tools

### Indexing Tools

#### `index_repository`

Index a repository into the knowledge graph.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `repo_path` | string | yes | **Absolute** path to repository root |

Returns node/edge counts, indexing time. Auto-sync keeps graph fresh after initial index.

#### `list_projects`

List all indexed projects with node/edge counts. No parameters.

#### `delete_project`

Remove a project and all its graph data.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `project` | string | yes | Project name (from `list_projects`) |

#### `index_status`

Check indexing status of a project.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `project` | string | yes | Project name |

---

### Query Tools

#### `search_graph`

Structured search by label, name pattern, file pattern, degree filters.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name_pattern` | string | no | Regex pattern for symbol name |
| `label` | string | no | Node label filter (see Graph Model) |
| `file_pattern` | string | no | Filter by file path |
| `min_degree` | int | no | Minimum connections |
| `max_degree` | int | no | Maximum connections |
| `project` | string | no | Scope to specific project |
| `limit` | int | no | Max results (default varies) |
| `offset` | int | no | Pagination offset |

#### `trace_path`

BFS traversal — who calls a function and what it calls.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `function_name` | string | yes | Exact function name |
| `direction` | string | no | `inbound`, `outbound`, or `both` (default: `both`) |
| `depth` | int | no | Traversal depth 1-5 (default: 3) |
| `project` | string | no | Scope to project |

**Tip**: If `trace_path` returns 0 results, use `search_graph(name_pattern=".*PartialName.*")` to find the exact name first.

#### `query_graph`

Execute Cypher-like graph queries (read-only).

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `query` | string | yes | Cypher query string |
| `project` | string | no | Scope to project |

#### `get_graph_schema`

Node/edge counts, relationship patterns, property definitions per label. **Run this first** on any new project.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `project` | string | no | Scope to project |

#### `get_code_snippet`

Read source code for a function by qualified name.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `qualified_name` | string | yes | Format: `project.path_parts.SymbolName` |

Use `search_graph` to discover qualified names first.

#### `get_architecture`

Codebase overview: languages, packages, routes, hotspots, clusters, ADRs.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `project` | string | no | Scope to project |

#### `search_code`

Grep-like text search within indexed project files only.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `query` | string | yes | Search text/regex |
| `file_pattern` | string | no | Glob filter (e.g. `*.py`) |
| `project` | string | no | Scope to project |

#### `detect_changes`

Map git diff to affected symbols + blast radius with risk classification.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `repo_path` | string | no | Path (uses current project if omitted) |
| `project` | string | no | Scope to project |

#### `manage_adr`

CRUD for Architecture Decision Records.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `action` | string | yes | `list`, `get`, `create`, `update` |
| `id` | string | conditional | Required for `get`/`update` |
| `title` | string | conditional | Required for `create` |
| `content` | string | conditional | ADR body |
| `project` | string | no | Scope to project |

#### `semantic_query`

Vector search across the entire graph using bundled embeddings.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `query` | string | yes | Natural language query |
| `project` | string | no | Scope to project |
| `limit` | int | no | Max results |

#### `ingest_traces`

Ingest runtime traces to validate HTTP_CALLS edges.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `traces` | array | yes | Runtime trace data |
| `project` | string | no | Scope to project |

---

## Graph Data Model

### Node Labels

| Label | Represents |
|-------|-----------|
| `Project` | Root node for indexed repository |
| `Package` | Language package/module namespace |
| `Folder` | Directory in file tree |
| `File` | Source file |
| `Module` | Language module (Python, JS, etc.) |
| `Class` | Class definition |
| `Function` | Top-level function |
| `Method` | Class method |
| `Interface` | Interface/protocol/trait |
| `Enum` | Enumeration type |
| `Type` | Type alias / typedef |
| `Route` | HTTP/REST endpoint |
| `Resource` | K8s resource / IaC entity |

### Edge Types

| Edge | Meaning |
|------|---------|
| `CONTAINS_PACKAGE` | Project → Package |
| `CONTAINS_FOLDER` | Folder → Subfolder |
| `CONTAINS_FILE` | Folder → File |
| `DEFINES` | File → Function/Class/Type |
| `DEFINES_METHOD` | Class → Method |
| `IMPORTS` | File → File (or Module → Module) |
| `CALLS` | Function → Function |
| `HTTP_CALLS` | Function → Route (cross-service) |
| `ASYNC_CALLS` | Async cross-service calls |
| `IMPLEMENTS` | Class → Interface |
| `INHERITS` | Class → Parent class |
| `HANDLES` | Function → Route |
| `USAGE` | Symbol → Symbol reference |
| `TESTS` | Test function → tested function |
| `USES_TYPE` | Function → Type |
| `EMITS` | Function → Channel |
| `LISTENS_ON` | Function → Channel |
| `DATA_FLOWS` | Arg-to-param mapping |
| `SIMILAR_TO` | MinHash near-clone detection |

---

## Cypher Reference

### Supported Clauses

`MATCH`, `OPTIONAL MATCH`, `WHERE`, `WITH`, `RETURN`, `ORDER BY`, `SKIP`, `LIMIT`, `DISTINCT`, `UNWIND`, `UNION`, `CASE`

### WHERE Operators

`=`, `<>`, `<`, `<=`, `>`, `>=`, `AND`, `OR`, `XOR`, `NOT`, `IN`, `CONTAINS`, `STARTS WITH`, `ENDS WITH`, `IS NULL`, `IS NOT NULL`, `=~` (regex), label test `n:Label`, `EXISTS { pattern }`

### Aggregates

`count`, `sum`, `avg`, `min`, `max`, `collect` (all support `DISTINCT`)

### Functions

`labels`, `type`, `id`, `keys`, `properties`, `toLower`, `toUpper`, `toString`, `toInteger`, `toFloat`, `toBoolean`, `size`, `length`, `trim`, `ltrim`, `rtrim`, `reverse`, `coalesce`, `substring`, `replace`, `left`, `right`

### Patterns

```cypher
-- Labelled node
(n:Function)

-- Label alternation
(n:Function|Method)

-- Relationship with type
(a)-[:CALLS]->(b)

-- Variable-length path (depth 1 to 3)
(a)-[:CALLS*1..3]->(b)

-- Inline property map
(f:Function {name: "main"})
```

### NOT Supported

Write clauses (`CREATE`, `MERGE`, `SET`, `DELETE`), `CALL`, list/map literals, comprehensions, path functions, parameters. Unsupported syntax returns a clear error.

---

## Cypher Cookbook

### Hotspots (most-called functions)

```cypher
MATCH (f:Function)<-[:CALLS]-(caller)
RETURN f.name, f.file, count(caller) AS fan_in
ORDER BY fan_in DESC LIMIT 10
```

### Dead code (no callers, excluding entry points)

```cypher
MATCH (f:Function)
WHERE NOT EXISTS { (f)<-[:CALLS]-() }
  AND NOT f.name IN ['main', '__init__', 'setUp', 'tearDown']
RETURN f.name, f.file
LIMIT 20
```

### Interface implementations

```cypher
MATCH (c:Class)-[:IMPLEMENTS]->(i:Interface)
WHERE i.name = 'Repository'
RETURN c.name, c.file
```

### Call chain between two functions

```cypher
MATCH path = (a:Function)-[:CALLS*1..4]->(b:Function)
WHERE a.name = 'handleRequest' AND b.name = 'saveToDb'
RETURN [n IN nodes(path) | n.name]
```

### HTTP routes and their handlers

```cypher
MATCH (f:Function)-[:HANDLES]->(r:Route)
RETURN r.name AS route, f.name AS handler, f.file
ORDER BY r.name
```

### Cross-service calls

```cypher
MATCH (f:Function)-[:HTTP_CALLS]->(r:Route)
RETURN f.name AS caller, f.file, r.name AS target_route
```

### Test coverage by symbol

```cypher
MATCH (t:Function)-[:TESTS]->(f:Function)
RETURN f.name, collect(t.name) AS tests
ORDER BY size(collect(t.name)) DESC LIMIT 10
```

### Find all methods of a class

```cypher
MATCH (c:Class)-[:DEFINES_METHOD]->(m:Method)
WHERE c.name = 'UserService'
RETURN m.name
```

### Inheritance tree

```cypher
MATCH (c:Class)-[:INHERITS*1..3]->(parent:Class)
WHERE c.name = 'AdminController'
RETURN c.name, [p IN nodes(path) | p.name] AS hierarchy
```

### Files with most definitions (God files)

```cypher
MATCH (file:File)-[:DEFINES]->(sym)
RETURN file.name, count(sym) AS symbols
ORDER BY symbols DESC LIMIT 10
```

### Unused imports

```cypher
MATCH (a:File)-[:IMPORTS]->(b:File)
WHERE NOT EXISTS { (a)-[:CALLS]->(:Function)<-[:DEFINES]-(b) }
RETURN a.name AS importer, b.name AS imported
LIMIT 20
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `trace_path` returns 0 results | Use `search_graph` to find exact name first |
| Wrong project results | Add `project="name"` parameter; check `list_projects` |
| `index_repository` fails | Must use **absolute** path |
| Binary not found | `export PATH="$HOME/.local/bin:$PATH"` |
| Stale graph data | `delete_project` then re-index, or trust auto-sync |

---

## Environment Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `CBM_CACHE_DIR` | `~/.cache/codebase-memory-mcp` | Database storage location |
| `CBM_LOG_LEVEL` | `info` | `debug`/`info`/`warn`/`error`/`none` |
| `CBM_WORKERS` | auto-detected | Parallel indexing worker count |
| `CBM_DIAGNOSTICS` | `false` | Enable periodic diagnostic output |
