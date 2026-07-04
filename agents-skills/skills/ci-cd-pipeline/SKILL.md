---
name: ci-cd-pipeline
description: Continuous integration and delivery pipeline patterns — canonical stages, deploy gates, GitHub Actions and GitLab CI wiring, OIDC to cloud, rollback strategy, DORA metrics. Use when setting up or reviewing a CI/CD pipeline, adding deploy gates, wiring cloud auth, or when user mentions CI, CD, pipeline, GitHub Actions, GitLab CI, deploy gate, or approval flow.
---

# CI/CD Pipeline

Automated path from commit to production with quality gates at every step. Grounded in canonical DevOps practice (DORA) and GitHub Actions / GitLab CI's native primitives.

## Eight canonical stages

Every pipeline has these stages, in this order. Skip a stage → shift the risk downstream.

```
1. Source        → git event triggers pipeline
2. Build         → compile, package, produce artifact
3. Test          → unit + integration + lint + type-check
4. Staging deploy→ push artifact to staging environment
5. Integration   → smoke + e2e against staging
6. Approval gate → manual or automated go/no-go
7. Prod deploy   → push artifact to production
8. Verify        → health checks + observability confirmation
                 → on failure: rollback
```

Rule: **each stage's output is the input to the next; each stage produces a pass/fail signal**. No stage completes without a verdict.

## Trigger patterns

Match the trigger to the branch strategy.

| Strategy         | Trigger        | Runs                       |
|------------------|----------------|----------------------------|
| Trunk-based      | Push to `main` | Full pipeline through prod deploy |
| PR-then-merge    | `pull_request` | Build + test + staging deploy (no prod) |
| Release branches | Tag `v*.*.*`   | Full pipeline, prod-only paths |
| Nightly          | `schedule: cron`| Long-running tests, dependency audits |

Default recommendation: **trunk-based with PR gates**. Feature branches are short-lived (< 24h); PR must pass CI to merge; main triggers the deploy pipeline.

## GitHub Actions primitives

Learn these six; they cover ~90% of production pipelines.

| Primitive             | Purpose                                                        |
|-----------------------|----------------------------------------------------------------|
| **Environments**      | Named deploy target (staging/prod). Attaches approval, secrets, protection rules. |
| **Reusable workflows**| `workflow_call` — share pipeline steps across repos/services. |
| **Composite actions** | Bundle multiple steps into one reusable unit (local or published). |
| **OIDC**              | Short-lived cloud credentials via `permissions: id-token: write` — no static secrets. |
| **Matrix**            | Fan-out one job across versions/OSes/configs.                  |
| **Concurrency**       | Cancel superseded runs; serialize deploys per environment.     |

## Deploy gates — three patterns

| Pattern              | Mechanism                                                | Use when                                       |
|----------------------|----------------------------------------------------------|------------------------------------------------|
| **Manual approval**  | GitHub Environments → required reviewers                 | Production, or first-time to a new environment |
| **Time-delayed**     | Environment wait timer (5-30 min) between stages         | Give observability a window to alert           |
| **Automated policy** | Custom deployment protection rule / branch check         | Enforce policy (e.g., no deploys on Friday)    |

Combine: staging deploys automatically → wait 5 min → check error budget → require 1 reviewer approval → prod deploy.

## OIDC — no static cloud secrets

Never commit AWS access keys, GCP service-account JSON, or Azure client secrets. Use OIDC to exchange the workflow's identity token for short-lived cloud credentials.

```yaml
permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789:role/deploy-role
          aws-region: us-east-1
      - run: aws s3 sync ./build s3://my-bucket/
```

Trust policy on the cloud side restricts the role to specific `sub` claims (repo, branch, environment). No secret ever leaves GitHub.

Same pattern in GitLab CI via `id_tokens` block.

## Rollback strategy

Every prod deploy has a rollback path. Choose one and document it in the pipeline:

| Strategy         | How                                                              | Rollback time |
|------------------|------------------------------------------------------------------|---------------|
| Blue/green       | Two environments; switch load balancer / DNS                     | Seconds       |
| Canary           | Route N% of traffic to new version; ramp up if healthy           | Seconds (drop canary) |
| Rolling          | Replace instances gradually; watch health per batch              | Minutes       |
| Recreate         | Stop all → start all with new version                            | Minutes; downtime |
| Feature flag     | Deploy dark; toggle on. Rollback = toggle off.                   | Instant       |

**Rule:** if you can't roll back in under 5 minutes, treat every deploy as high-risk. Blue/green + feature flags together give < 1 minute rollback.

## Reusable workflow — a real example

```yaml
# .github/workflows/_deploy.yml (reusable)
on:
  workflow_call:
    inputs:
      environment: { type: string, required: true }
      image_tag:   { type: string, required: true }
    secrets:
      aws_role:    { required: true }

jobs:
  deploy:
    environment: ${{ inputs.environment }}   # attaches approvals + protection
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    concurrency:
      group: deploy-${{ inputs.environment }}
      cancel-in-progress: false
    steps:
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.aws_role }}
          aws-region: us-east-1
      - name: Deploy
        run: ./scripts/deploy.sh ${{ inputs.environment }} ${{ inputs.image_tag }}
      - name: Health check
        run: ./scripts/health-check.sh ${{ inputs.environment }}
```

Callers:

```yaml
# .github/workflows/prod.yml
jobs:
  staging:
    uses: ./.github/workflows/_deploy.yml
    with:  { environment: staging, image_tag: ${{ github.sha }} }
    secrets: { aws_role: ${{ secrets.STAGING_ROLE }} }
  prod:
    needs: staging
    uses: ./.github/workflows/_deploy.yml
    with:  { environment: production, image_tag: ${{ github.sha }} }
    secrets: { aws_role: ${{ secrets.PROD_ROLE }} }
```

## DORA metrics — what to measure

Elite performers hit all four (2024 State of DevOps):

| Metric                     | Elite target        | What it means                                    |
|----------------------------|---------------------|--------------------------------------------------|
| Deployment frequency       | On-demand (multiple/day) | How fast can we ship                       |
| Lead time for changes      | < 1 hour (commit→prod)   | How fast can we respond                    |
| Change failure rate        | 0-15%                    | How reliable is the process                |
| Time to restore service    | < 1 hour                 | How resilient are we                       |

Instrument these in the pipeline itself — record deploy timestamps to a metrics store; correlate with incidents.

## Security controls at the pipeline

Every serious pipeline enforces:

- **Signed commits** — GPG or Sigstore; block unsigned merges on protected branches
- **Dependency scan** — dependency-audit skill; fail on Critical CVEs
- **Secret scan** — gitleaks / trufflehog in pre-commit and CI
- **SBOM** — generate per build; store as artifact
- **Image sign** — Sigstore cosign for container images; verify at deploy
- **SAST** — CodeQL / Semgrep on every PR
- **Least privilege** — pipeline OIDC role can deploy only, not read customer data

## Common failure modes

- **Shared prod credentials in CI** — one leak compromises everything. Use OIDC.
- **No staging** — deploys land in prod with no rehearsal. Always test the deploy itself in staging.
- **Tests skipped when green pipeline needed fast** — the moment you skip tests, you're not doing CI.
- **Rollback plan documented in Confluence, not codified** — nobody reads it at 2am. Codify rollback as a pipeline job.
- **Long pipelines that people bypass** — a 45-minute pipeline creates pressure to skip. Split into fast-lane (< 5 min for common changes) and full-lane.
- **No concurrency control on deploys** — two deploys race, artifacts overwrite, prod is confused. Serialize per environment.

## When to skip stages

- **Test stage** — never skip. If tests are slow, run a fast subset on PRs and full suite on main.
- **Staging** — skip only for docs-only changes (paths filter). Anything touching runtime = staging first.
- **Approval gate** — automate away only when confidence is high (small change class, strong test coverage, feature flag on).
- **Health check** — never skip. The pipeline doesn't succeed until the deployed thing responds correctly.

## Pipeline anti-patterns

- **The pipeline that runs everything on every change** — 40-minute runs kill velocity. Path filters and job dependencies fix this.
- **The pipeline as god-mode admin** — a compromised action = compromised infra. Scope credentials per job.
- **The "just push to main and see" pipeline** — no PR checks, no staging, no gate. Not CI/CD; that's YOLO.
- **The pipeline with no observability of itself** — you don't know which stages are slow. Instrument step durations.
