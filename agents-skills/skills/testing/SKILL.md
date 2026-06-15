---
name: testing
description: Stack-agnostic testing strategies and principles. Use when writing or reviewing tests.
---

# Testing

## Principles
- Test behavior, not implementation details
- Each test should have one clear reason to fail
- Tests must be deterministic — no flaky tests
- Fast tests run first; slow integration tests run separately

## Test Pyramid
1. **Unit tests** — isolated logic, no I/O, fast
2. **Integration tests** — modules working together, real dependencies
3. **E2E tests** — full user flows, slowest, fewest

## What to Test
- Happy path (valid input → expected output)
- Validation/error cases (invalid input → appropriate error)
- Auth boundaries (unauthenticated, unauthorized)
- Edge cases specific to business rules
- Regression tests for every bug fix

## Test Structure (Arrange-Act-Assert)
```
1. Arrange: set up preconditions and inputs
2. Act: execute the behavior under test
3. Assert: verify the expected outcome
```

## Rules
- One test file per module/component, co-located or in a parallel test directory
- Mock external dependencies (network, filesystem, time), not internal modules
- Use factories/fixtures for test data — never hardcode IDs or rely on DB state
- Clean up side effects — each test starts from a known state
- No snapshot tests for logic — use explicit assertions
- Name tests descriptively: what scenario → what expected outcome

## Stack Detection
Detect the project's test framework from config files and use it:
- JS/TS: Jest, Vitest, Mocha (check package.json scripts and devDependencies)
- Python: pytest, unittest (check pyproject.toml, setup.cfg)
- Go: built-in `go test`
- Rust: built-in `cargo test`
- PHP: Pest, PHPUnit (check composer.json)
- Ruby: RSpec, Minitest (check Gemfile)
- Java/Kotlin: JUnit, TestNG (check build.gradle, pom.xml)
