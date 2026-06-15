---
name: git-workflow
description: Git branching, commit, and PR conventions. Use when working with version control.
---

# Git Workflow

## Branch Naming
```
feature/short-description     # new features
fix/short-description         # bug fixes
chore/short-description       # maintenance, deps, config
refactor/short-description    # code improvements
```

## Commit Messages (Conventional Commits)
```
<type>(<scope>): <short description>

[optional body]
```

Types: `feat`, `fix`, `chore`, `refactor`, `test`, `docs`, `perf`

Examples:
```
feat(auth): add email verification on registration
fix(orders): prevent duplicate order on double-click
refactor(users): extract service from handler
test(api): add missing auth boundary tests
```

Rules:
- Subject line ≤ 72 characters
- Use imperative mood: "add" not "added"
- Reference issue numbers in body if applicable

## Workflow
```bash
# Start a feature
git checkout main && git pull
git checkout -b feature/my-feature

# Work in small, logical commits
git add <specific-files>
git commit -m "feat(scope): description"

# Push and open PR
git push -u origin feature/my-feature
```

## PR Rules
- Title follows commit message format
- Description includes: what changed, how to test, screenshots if UI
- All tests must pass before merge
- No direct pushes to `main`
- Squash merge to keep main history clean

## What NOT to Commit
- Environment files (`.env`, `.env.local`)
- Dependency directories (`node_modules/`, `vendor/`, `venv/`, `target/`)
- IDE config (`.idea/`, `.vscode/`) — use `.gitignore`
- Build output (`dist/`, `build/`, `out/`, `public/build/`)
- Secrets or credentials of any kind
- OS files (`.DS_Store`, `Thumbs.db`)
