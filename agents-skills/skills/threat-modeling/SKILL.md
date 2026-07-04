---
name: threat-modeling
description: Structural threat analysis for security-sensitive designs. STRIDE per-element on a data-flow diagram, attack trees for scary paths, LINDDUN when privacy matters. Use when reviewing new architecture, adding authentication or payments or PII flows, before shipping a security-sensitive change, or when user says "threat model", "STRIDE", "attack tree", or "what could go wrong".
---

# Threat Modeling

Systematic "what could go wrong" analysis on a system's design before it ships. Grounded in OWASP's Threat Modeling Manifesto and Adam Shostack's four questions.

## The four questions

Every threat model answers these in order. Skip a step → the model is incomplete.

1. **What are we building?** — Data flow diagram (DFD) with trust boundaries.
2. **What can go wrong?** — Apply a framework (STRIDE, LINDDUN, or attack tree) element by element.
3. **What are we going to do about it?** — Mitigation per threat (accept, transfer, mitigate, avoid).
4. **Did we do a good job?** — Review coverage; re-run when the design changes.

## Choose the framework

| Framework | Strength | Use when |
|-----------|----------|----------|
| **STRIDE** | Breadth. Enumerates six threat categories per element. | Default. Any security-relevant design change. |
| **Attack trees** | Depth. Decomposes one attacker goal into AND/OR sub-steps. | You already identified a scary threat and need to explore how it could actually be executed. |
| **LINDDUN** | Privacy focus. Seven privacy threat categories. | Systems handling PII, health, financial, or biometric data. |
| **PASTA** | Business-risk framing (7 stages). | Executive-facing risk assessment; heavy for engineering-only work. |

Rule: **STRIDE first for breadth, then attack-tree the scary ones**. Add LINDDUN if PII crosses a trust boundary.

## STRIDE — the six categories

Applied per DFD element. Not every element hits every category — pick applicable ones.

| Letter | Category | Violates | Typical mitigation |
|--------|----------|----------|-------------------|
| **S** | Spoofing | Authentication | Strong auth (MFA, mTLS, signed tokens) |
| **T** | Tampering | Integrity | Signatures, checksums, WORM storage, input validation |
| **R** | Repudiation | Non-repudiation | Audit logs (signed, append-only), transaction receipts |
| **I** | Information disclosure | Confidentiality | Encryption at rest/in transit, authz, minimize data |
| **D** | Denial of service | Availability | Rate limits, quotas, redundancy, circuit breakers |
| **E** | Elevation of privilege | Authorization | Least privilege, sandboxing, capability tokens |

**Coverage by element type:**

| Element type       | Applies      |
|--------------------|--------------|
| External entity    | S, R         |
| Process            | S, T, R, I, D, E |
| Data flow          | T, I, D      |
| Data store         | T, R, I, D   |

## Workflow

1. **Diagram** — Draw a DFD in text or a tool. Nodes: external entities, processes, data stores. Edges: data flows. Draw trust boundaries around zones with the same privilege level.
2. **Walk each element** — For every process/store/flow, list applicable STRIDE categories. For each, ask "how might this be violated here?" Write one threat per line.
3. **Rank** — Assign severity (Critical/High/Medium/Low) using likelihood × impact. Skip DREAD scoring theatre; a two-axis judgment is enough.
4. **Deep-dive scary ones** — Build an attack tree for each Critical/High threat. Root = attacker goal; children = AND/OR sub-steps; leaves = concrete actions.
5. **Mitigate** — For each threat: accept, transfer, mitigate, or avoid. Write the specific control (not "add security" — "sign requests with HMAC-SHA256, verify at gateway").
6. **File** — Save under `docs/threat-models/<component>-<YYYYMM>.md`. Include DFD, threat list, mitigations, residual risk.

## Attack tree template

```
Goal: <attacker's objective — "steal user session tokens">
├── AND: <both children required>
│   ├── Obtain valid session ID  (OR)
│   │   ├── Read from browser storage (XSS)
│   │   ├── Intercept over unencrypted transport
│   │   └── Guess (predictable IDs)
│   └── Replay against server
│       └── Server accepts token without binding to IP/device
```

Leaves are the interception points where a control lands.

## LINDDUN — privacy lens

Seven categories: **L**inkability, **I**dentifiability, **N**on-repudiation, **D**etectability, **D**isclosure of information, **U**nawareness, **N**on-compliance.

Trigger LINDDUN when: PII crosses a boundary, analytics/telemetry ships user actions, third-party integrations receive user data, or the system falls under GDPR/CCPA/HIPAA.

## Threat entry template

```markdown
### T-<NN>: <one-line summary>

- **STRIDE category**: <letter>
- **Element**: <DFD node/edge affected>
- **Severity**: Critical | High | Medium | Low
- **Threat**: <how the violation happens>
- **Precondition**: <what an attacker needs first>
- **Impact**: <what they gain / user loses>
- **Mitigation**: <specific control — command, header, config>
- **Residual risk**: <what remains after mitigation>
- **Owner**: <person or team>
```

## Common failure modes

- **Abstract threats** — "SQL injection is possible" — say where and against which query.
- **No trust boundary drawn** — every DFD needs at least one. If there's only one trust zone, why threat model at all?
- **Mitigation is a category, not a control** — "encryption" is not a mitigation; "AES-256-GCM with keys from KMS, rotated 90d" is.
- **One-and-done** — threat model becomes stale within a sprint. Re-run when architecture changes.
- **STRIDE without DFD** — the DFD is what makes STRIDE actionable. Skipping it collapses the exercise into brainstorming.

## When to skip

- Read-only static site with no auth.
- Internal tool on isolated network with no external inputs.
- Change that only refactors internals without altering trust boundaries or data flows.

Everywhere else: threat model.

## Tools

- **OWASP pytm** — Python-based, threats-as-code; auto-generates DFDs and reports. Best for CI-integrated modeling.
- **OWASP Threat Dragon** — Web UI, visual DFDs; good for collaborative sessions with non-engineers.
- **Text-only** — Markdown + Mermaid DFDs works fine for small teams and lives with the code.
