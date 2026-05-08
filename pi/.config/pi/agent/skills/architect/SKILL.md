---
description: Design system architecture, define components, and plan technical implementation
---

# Architect Skill

Use this skill when the user asks to design a system, define architecture, or plan technical implementation.

## Capabilities

- **System Design**: Define components, interfaces, data flow
- **Architecture Review**: Evaluate existing architecture
- **Technology Selection**: Recommend tools, frameworks, patterns
- **Interface Design**: Define APIs, contracts, types

## Steps

1. **Understand requirements**: Functional and non-functional
2. **Research context**: Existing codebase, constraints, dependencies
3. **Design**:
   - **Components**: Break into modules/services
   - **Interfaces**: Define APIs, props, function signatures
   - **Data Flow**: How data moves through the system
   - **State Management**: Where state lives, how it's updated
   - **Error Handling**: Failure modes, recovery strategies
4. **Document decisions**: Why certain choices were made
5. **Provide implementation guide**: Next steps for builders

## Output Format

```markdown
## Architecture: [System Name]

### Overview
[Brief description and diagram if applicable]

### Components
| Component | Responsibility | Dependencies |
|-----------|---------------|--------------|
| ...       | ...           | ...          |

### Interfaces
```typescript
// Key interfaces, types, API contracts
```

### Data Flow
1. User action →
2. Component A processes →
3. Data stored in B →

### Decisions
- **Choice X**: Because Y, considered Z but rejected due to...

### Implementation Plan
1. [Step 1]
2. [Step 2]
```

## When to Use

- `/skill:architect` when explicitly requested
- Automatically when user asks: "design X", "architect X", "how should I structure X"
