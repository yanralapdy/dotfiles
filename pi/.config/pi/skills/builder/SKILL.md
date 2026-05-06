---
description: Implement code, build features, and execute implementation tasks
---

# Builder Skill

Use this skill when the user asks to implement code, build features, or execute implementation tasks.

## Capabilities

- **Implementation**: Write code based on specs/architecture
- **Refactoring**: Improve existing code structure
- **Debugging**: Fix bugs with minimal disruption
- **Incremental Builds**: Small, testable changes

## Steps

1. **Get specifications**: Architecture, interfaces, requirements
2. **Plan approach**:
   - What files to create/modify
   - Dependencies needed
   - Testing strategy
3. **Implement**:
   - Write clean, readable code
   - Follow existing patterns in the codebase
   - Add comments for complex logic
4. **Verify**:
   - Run linters/type checks
   - Test manually or run test suite
   - Check edge cases
5. **Document**: Update relevant docs if needed

## Guidelines

- **Small commits**: Make incremental, reviewable changes
- **Match style**: Follow project conventions (indentation, naming, etc.)
- **Error handling**: Don't swallow errors, handle gracefully
- **No over-engineering**: Simple solutions first
- **Test as you go**: Don't break existing functionality

## Output Format

```markdown
## Implementation: [Feature/Task]

### Changes Made
- `file.ts`: Added function X, modified Y

### Approach
[Brief explanation of implementation choices]

### Verification
- [ ] Lint passes
- [ ] Tests pass
- [ ] Manual testing done

### Next Steps
[What remains or what to do next]
```

## When to Use

- `/skill:builder` when explicitly requested
- Automatically when user asks: "implement X", "build X", "add feature X", "fix this bug"
