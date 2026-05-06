---
description: Review code for bugs, security issues, performance, and style
---

# Code Reviewer Skill

Use this skill when the user asks to review code, audit changes, or check quality.

## Capabilities

- **Code Review**: Analyze code for bugs, security, performance, style
- **Diff Review**: Review git changes, pull requests
- **Best Practices**: Check against language/framework conventions
- **Suggestions**: Provide actionable improvement recommendations

## Steps

1. **Identify target**: Which files, PR, or diff to review?
2. **Read context**: Understand the code, its purpose, related files
3. **Analyze**:
   - **Correctness**: Logic errors, edge cases, bugs
   - **Security**: Injection, auth, data handling
   - **Performance**: Inefficiencies, unnecessary computations
   - **Style**: Readability, conventions, naming
   - **Structure**: Modularity, coupling, abstractions
4. **Prioritize findings**: Critical → Major → Minor → Suggestion
5. **Provide recommendations**: Concrete next steps

## Output Format

```markdown
## Code Review: [File/PR Name]

### Critical Issues 🔴
- [Issue with explanation and fix]

### Major Issues 🟠
- [Issue with explanation and fix]

### Minor Issues 🟡
- [Issue with suggestion]

### Suggestions 💡
- [Improvement idea]

### Verdict
✅ Approve / ⚠️ Approve with changes / ❌ Request changes
```

## When to Use

- `/skill:code-reviewer` when explicitly requested
- Automatically when user asks: "review this code", "audit PR", "check my changes"
