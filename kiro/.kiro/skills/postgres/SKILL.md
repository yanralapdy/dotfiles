---
name: database-design
description: Database schema design, indexing, and query optimization patterns. Use when designing schemas or optimizing queries.
---

# Database Design & Optimization

## Schema Design Principles
- Use appropriate data types (don't store numbers as strings, use timestamps with timezone)
- Use bigint/bigserial for primary keys on tables that may grow large
- Use UUIDs for public-facing IDs to prevent enumeration attacks
- Use decimal/numeric for money — never float
- Define foreign key constraints for referential integrity
- Add NOT NULL constraints where appropriate — nullable should be intentional

## Naming Conventions
- Tables: `snake_case`, plural (`users`, `order_items`)
- Columns: `snake_case`
- Foreign keys: `{table_singular}_id` (`user_id`, `order_id`)
- Indexes: `idx_{table}_{columns}` (`idx_orders_user_id`)

## Indexing Strategy

### Always Index
- Every foreign key column
- Columns in frequent WHERE clauses
- Columns in ORDER BY on paginated queries
- Columns used in JOIN conditions

### Index Types (PostgreSQL/MySQL)
- **B-tree** (default): equality and range queries
- **Partial/filtered index**: queries that always filter on a condition
- **Composite index**: multi-column WHERE (put most selective column first)
- **GIN**: JSONB fields, full-text search, array columns

## Query Optimization
- Use EXPLAIN ANALYZE to verify index usage
- Look for sequential scans on large tables → needs index
- Prefer keyset/cursor pagination over OFFSET for large datasets
- Use window functions instead of correlated subqueries
- Batch inserts/updates instead of row-by-row operations
- Avoid SELECT * — select only needed columns

## Pagination
```sql
-- Offset (simple but slow at high pages)
SELECT * FROM orders ORDER BY id LIMIT 20 OFFSET 1000;

-- Keyset (fast at any depth, preferred for large tables)
SELECT * FROM orders WHERE id > :last_id ORDER BY id LIMIT 20;
```

## Migration Best Practices
- Migrations should be reversible (include rollback/down)
- One logical change per migration
- Never modify a migration that has been deployed — create a new one
- Add indexes in the same migration as the table or in a separate migration for existing tables
- Test migrations against a copy of production data when possible
