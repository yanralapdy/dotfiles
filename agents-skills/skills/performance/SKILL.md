---
name: performance-optimization
description: Stack-agnostic performance optimization principles. Use when diagnosing or fixing performance issues.
---

# Performance Optimization

## Golden Rule
Measure before optimizing. Profile first — don't optimize code that isn't slow.

## Common Anti-Patterns (Any Stack)

### N+1 queries
Fetching related data inside a loop instead of batching. Fix: eager-load, join, or batch-fetch.

### Unbounded queries
Fetching all rows without pagination. Fix: always paginate or limit results.

### Missing indexes
Slow queries on columns used in WHERE, ORDER BY, JOIN. Fix: add appropriate indexes.

### Blocking I/O in hot paths
Synchronous file/network calls in request handlers. Fix: async/queue/background jobs.

### Unnecessary computation in loops
Recalculating values that don't change per iteration. Fix: hoist invariants out of loops.

## Backend Performance
- Cache expensive computations with appropriate TTL and invalidation strategy
- Queue slow operations (emails, reports, image processing) — anything >200ms that doesn't need to block the response
- Use connection pooling for databases
- Profile queries: look for sequential scans on large tables, missing indexes
- Paginate all list endpoints (prefer cursor/keyset over offset for large datasets)

## Database Performance
- Index every foreign key and frequently-filtered column
- Use EXPLAIN/EXPLAIN ANALYZE to verify index usage
- Prefer keyset pagination over OFFSET for large tables
- Batch inserts/updates instead of row-by-row
- Use appropriate data types (don't store numbers as strings)

## Frontend Performance
- Lazy-load routes and heavy components
- Tree-shake imports (named imports from ES modules)
- Virtualize long lists (>100 items)
- Debounce user input that triggers expensive operations (300ms)
- Minimize bundle size: analyze with build tool's analyzer

## Caching Strategy
- Cache at the right layer: HTTP cache > application cache > query cache
- Always define invalidation strategy before adding cache
- Use cache tags or keys that allow granular invalidation
- Set appropriate TTLs — stale data is a bug
