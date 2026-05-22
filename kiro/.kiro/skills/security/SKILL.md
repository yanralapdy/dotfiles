---
name: security-review
description: Security checklist and patterns for any application. Use when reviewing or writing security-sensitive code.
---

# Security Review

## Authentication & Authorization
- All non-public endpoints require authentication
- Authorization checked at the resource level, not just route level
- Use the framework's built-in auth mechanisms (policies, guards, middleware)
- Never roll custom crypto or session management

## Input Validation
- Validate all input at the boundary (API handlers, form processors)
- Use allowlists over denylists
- Validate file uploads: mime type, size, extension
- Never trust client-side validation alone

## Injection Prevention
- **SQL**: Use parameterized queries / ORM — never string-interpolate user input into queries
- **Command**: Use array-based command execution, never shell string interpolation
- **XSS**: Escape output by default; never render raw user HTML without sanitization
- **Path traversal**: Validate and sanitize file paths; reject `../` sequences

## Secrets Management
- Never commit secrets to version control
- Never log sensitive data (passwords, tokens, PII)
- Use environment variables or secret managers for credentials
- Rotate secrets that may have been exposed

## Data Protection
- Hash passwords with bcrypt/argon2 — never store plaintext
- Encrypt sensitive data at rest when required
- Use HTTPS for all external communication
- Minimize data exposure in API responses (don't return full objects when a subset suffices)

## Frontend Security
- Never use raw HTML injection (innerHTML, v-html, dangerouslySetInnerHTML) with user content
- Store auth tokens in httpOnly cookies or memory — not localStorage
- Never expose API keys or secrets in client-side code
- Implement CSRF protection for state-changing requests

## Security Review Checklist
- [ ] All endpoints require appropriate auth
- [ ] Authorization checked at resource level
- [ ] All inputs validated with allowlists
- [ ] No injection vulnerabilities (SQL, command, XSS, path)
- [ ] No secrets in code or logs
- [ ] File uploads validated for type and size
- [ ] No raw HTML rendering with untrusted content
- [ ] Error messages don't leak internal details to users
