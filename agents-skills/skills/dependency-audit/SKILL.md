---
name: dependency-audit
description: Software Bill of Materials, CVE scanning, license and typosquatting checks, and supply-chain hygiene for third-party dependencies. Use when reviewing dependencies before shipping, auditing an existing project, adding a new library, or when user says "SBOM", "supply chain", "check dependencies", "CVE audit", or "vulnerability scan".
---

# Dependency Audit

Third-party code is the biggest surface for supply-chain risk. This skill defines what to check, which tools to use, and how to decide when a finding is real.

## What you check — five lenses

Every audit walks all five. Skipping one leaves a gap.

| Lens                       | Question                                         | Primary tool                |
|----------------------------|--------------------------------------------------|-----------------------------|
| **Vulnerabilities**        | Any published CVE for a version we use?          | Trivy, OSV-Scanner, Snyk    |
| **License compliance**     | Is the license compatible with our use?          | Trivy, ScanCode              |
| **Typosquatting / lookalikes** | Package name subtly different from a popular one? | Manual review + npm/pip audit |
| **Maintenance signal**     | Alive? Last commit, open issue count, single-maintainer risk. | GitHub check (stars, commits, contributors) |
| **Transitive dependencies**| What does this pull in transitively?             | Lockfile inspection + SBOM  |

## Generate an SBOM

Every audit starts with an inventory. Pick a format and generate.

| Format     | Strength                                         | Use when                          |
|------------|--------------------------------------------------|-----------------------------------|
| **CycloneDX** | Developer-friendly, superior vulnerability correlation | Default. Best for security scanning workflows. |
| **SPDX**   | ISO 5962:2021, verbose, strong license metadata | Legal / license-compliance heavy contexts. |

**Generate with Trivy (unified scanner):**

```bash
# From a source directory
trivy fs --format cyclonedx --output sbom.cdx.json .

# From a container image
trivy image --format cyclonedx --output sbom.cdx.json <image>

# From a lockfile only (fastest)
trivy fs --scanners vuln --format json .
```

**Generate with Syft (SBOM-focused; pair with Grype for scanning):**

```bash
syft . -o cyclonedx-json > sbom.cdx.json
grype sbom:sbom.cdx.json
```

## Scan for CVEs

Once you have an SBOM, or scan the source directly:

```bash
# Trivy — unified: vuln + license + secrets + IaC
trivy fs --scanners vuln,license,secret .

# OSV-Scanner — Google, uses OSV.dev database
osv-scanner --lockfile package-lock.json
osv-scanner scan source .

# Language-native (fast, but narrower than Trivy/OSV)
npm audit --audit-level=high
pip-audit
composer audit
cargo audit
go list -json -deps ./... | nancy sleuth
```

**Rule:** run one comprehensive scanner (Trivy or OSV) plus the language-native one. They catch different things — CVE feeds overlap but not perfectly.

## Interpret severity

Every finding has a CVSS score (0.0-10.0). Don't fix by score alone.

| CVSS       | Nominal severity | Real action                                                     |
|------------|-----------------|-----------------------------------------------------------------|
| 9.0 – 10.0 | Critical        | Fix immediately. Block release. |
| 7.0 – 8.9  | High            | Fix this sprint. Document if deferred. |
| 4.0 – 6.9  | Medium          | Fix if reachable in your code. Ignore if unreachable (but document). |
| 0.1 – 3.9  | Low             | Note it. Fix opportunistically. |

**Reachability matters more than severity.** A Critical in a code path you never call is often lower risk than a Medium in your hot path. When rejecting a Critical as unreachable, document the reasoning.

## Typosquatting checks

Manual, but fast. When adding any new dependency:

```
1. Search the package name on the registry (npm/pypi/rubygems/packagist).
2. Note top 3 packages with visually similar names.
3. If the top hit is not our target: pause. Verify author, repo URL, star count, install count.
4. Check the repo URL in package metadata actually points to a real project.
```

**Red flags:**
- Zero-day-old package with production-sounding name
- No repo URL, or repo is empty/private
- Description copied from a legitimate package
- Author has one package, published today
- Install count dramatically lower than the "real" package

## Maintenance signal

Before adopting or upgrading, check:

```
1. Last commit date  — > 12 months without commits is a smell
2. Open issue count vs stars — > 5% is high friction
3. Contributor count — 1 = bus factor 1
4. Release cadence — regular patch releases = healthy
5. Response time on recent issues — sample 5 recent, see if maintainers responded
```

Alive projects with 1000 stars beat dead projects with 30000 stars. Star count is a lagging indicator.

## License check

Common categories and use:

| License           | Copyleft | Commercial-friendly | Notes |
|-------------------|----------|---------------------|-------|
| MIT / BSD / Apache 2.0 | No  | Yes                 | Safe default |
| MPL 2.0           | Weak     | Yes                 | File-level copyleft |
| LGPL              | Weak     | Yes with dynamic link | Static linking triggers copyleft |
| GPL / AGPL        | Strong   | Careful             | Distribution / network use may require open-sourcing your code |
| SSPL / BUSL       | —        | Restricted          | Not OSI-approved; check company policy |
| Unclear / "custom"| —        | Danger              | Escalate to legal |

Reject any dependency without an explicit license. "No license" is not permissive — it's restrictive.

## Report format

For each finding, produce one issue-scoped entry (see coms-workflow FEEDBACK.md):

```markdown
### D-<NN>: <package>@<version> — <one-line issue>

- **Severity**: Critical | High | Medium | Low
- **Type**: CVE | License | Typosquatting | Maintenance | Transitive
- **CVE / CWE**: <if applicable>
- **CVSS**: <score>
- **Reachable in our code**: yes / no / unknown (with reasoning)
- **Fixed in**: <version> (if a fix exists)
- **Recommendation**: upgrade / replace / accept-risk / remove
- **Rationale**: <why this recommendation>
- **Evidence**: <lockfile line, scanner output snippet>
```

## When to skip

- Read-only static site with no runtime dependencies (still audit build-time deps).
- Prototype directory clearly marked non-production.
- Locked-down environments where the dependency set is externally curated.

Everywhere else: audit before ship and on a regular cadence (monthly at minimum).

## Common failure modes

- **Ignoring lockfile drift** — `package.json` says `^1.0.0` but `package-lock.json` has 1.6.3 with a CVE. Scan the lockfile, not just the manifest.
- **Scanning only the top level** — transitive deps carry most CVEs. Ensure the scanner walks the full graph.
- **Fix without regression test** — bumping a version can break call sites. Run the test suite post-upgrade.
- **False-positive fatigue** — if 90% of findings are unreachable, tune the scanner or add a suppressions file with reasoning per suppression.
- **"Vendored" copies of libraries** — a copy of a lib pasted into your repo isn't in the lockfile; scanners miss it. Grep for vendored copies quarterly.

## Tools quick reference

| Tool          | Type                    | Best for                                      |
|---------------|-------------------------|-----------------------------------------------|
| Trivy         | Unified scanner         | Default. SBOM + vuln + license + secrets + IaC. |
| Syft          | SBOM generator          | Pair with Grype for pure OSS SBOM workflow.   |
| OSV-Scanner   | Vulnerability scanner   | Second scanner; uses Google's OSV.dev feed.   |
| Grype         | Vulnerability scanner   | Native pair with Syft.                        |
| Dependabot    | Auto-PR upgrades        | Continuous; enable on all GitHub repos.       |
| Renovate      | Auto-PR upgrades        | More configurable alternative to Dependabot.  |
| Snyk          | Commercial              | Rich UI, reachability analysis, private feeds. |
