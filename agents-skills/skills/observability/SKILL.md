---
name: observability
description: Instrument services so behavior can be understood from outside. Four golden signals, RED and USE methods, SLIs/SLOs/SLAs, the three pillars (metrics, logs, traces), and how to define alerts that don't cry wolf. Use when defining service metrics, wiring dashboards, setting SLOs, reviewing monitoring for a new service, or when user mentions observability, SLI, SLO, RED method, golden signals, OpenTelemetry.
---

# Observability

Instrument systems so their internal state is legible through external outputs. Grounded in Google SRE practice (Beyer et al.) and Grafana / Splunk canonical guidance.

## The three pillars

Every observability stack has three signal types. They answer different questions.

| Pillar     | Question                                        | Storage                           | Cost  |
|------------|-------------------------------------------------|-----------------------------------|-------|
| **Metrics**| "How is the system trending?"                   | Time-series DB (Prometheus, VictoriaMetrics, Cloud) | Low   |
| **Logs**   | "What happened at this timestamp?"              | Log store (Loki, ELK, cloud)      | Med-High |
| **Traces** | "Why was this request slow across services?"    | Trace store (Tempo, Jaeger, cloud)| High  |

Rule: **metrics for alerting, traces for debugging, logs for evidence**. Alerting on logs is fragile; deep-diving with metrics is impossible.

## The four golden signals (Google SRE)

Every service exposes four metrics. If you can only monitor four things, monitor these.

| Signal        | Definition                                     | Alert trigger                              |
|---------------|------------------------------------------------|--------------------------------------------|
| **Latency**   | Time to serve a request (p50, p95, p99)        | p99 > SLO threshold sustained > 5 min      |
| **Traffic**   | Requests per second (or business unit — tx/sec, msgs/sec) | Sudden drop of > 30% vs baseline    |
| **Errors**    | Fraction of requests failing (5xx, business errors) | Error ratio > SLO threshold                |
| **Saturation**| How "full" the service is (CPU, memory, queue depth, connection pool) | > 80% of capacity sustained          |

Track separately for user-facing traffic vs internal/batch. Aggregate deceives.

## RED method — for request-driven services

Rate, Errors, Duration. Per service, per endpoint.

- **Rate** — requests per second
- **Errors** — failing requests per second
- **Duration** — distribution of successful request time

RED dashboards are the operator's first look. Best for microservices, HTTP APIs, RPC services.

## USE method — for resources

Utilization, Saturation, Errors. Per resource (CPU, disk, network, memory, connection pool).

- **Utilization** — % of time the resource was busy
- **Saturation** — how much extra work is queued (run queue length, IO wait, dropped packets)
- **Errors** — error events count

USE dashboards diagnose "why is the service slow" when RED shows Duration up.

**Combine:** RED for what users see, USE for what caused it. Same incident, two lenses.

## SLI / SLO / SLA — the reliability contract

| Term    | Definition                                                       | Example                                    |
|---------|------------------------------------------------------------------|--------------------------------------------|
| **SLI** | Service Level *Indicator* — a specific measurement.              | 99th-percentile HTTP latency of GET /users |
| **SLO** | Service Level *Objective* — an internal target for the SLI.      | p99 latency < 200ms, over 30-day rolling window |
| **SLA** | Service Level *Agreement* — external contract with consequences. | If uptime < 99.9% monthly, refund X%       |

**Rule:** always set SLOs stricter than SLAs. Alert when the SLO is at risk, well before the SLA breaches.

**Error budget:** the inverse of the SLO. If SLO is 99.9% over 30 days, budget is 43.2 minutes of downtime per month. Burn budget faster than expected → freeze non-critical changes.

## Defining an SLO — six steps

```
1. Pick the SLI — user-facing, measurable, from real traffic (not synthetic).
2. Aggregate — per endpoint, per user segment, or global. Global hides tail pain.
3. Choose the statistic — usually p95 or p99. Never a mean.
4. Pick the target — start with the current p99 * 1.1 (10% headroom).
5. Choose the window — 28 or 30 days rolling. Longer windows smooth incidents; shorter surface them.
6. Wire alerts against burn rate, not raw SLI.
```

## Burn-rate alerting

Alerting on "SLO breached" is too late. Alert on **error budget burn rate** — the rate at which you're consuming the month's budget.

| Burn rate  | Meaning                                          | Alert speed          |
|------------|--------------------------------------------------|----------------------|
| 14.4×      | Burning a month's budget in 2 hours              | Immediate page       |
| 6×         | Burning a month's budget in 5 hours              | Page                 |
| 3×         | Burning a month's budget in 10 hours             | Ticket               |
| 1×         | On track — normal                                | No alert             |
| < 1×       | Under budget                                     | No alert; celebrate  |

Multi-window multi-burn-rate alerts (Google SRE Workbook): fast burn triggers on 5-min + 1-hour windows; slow burn on 30-min + 6-hour windows. Reduces false pages.

## Instrumentation — OpenTelemetry standard

OTel is the vendor-neutral standard for metrics, logs, traces. Use it.

```
Application  ──emits──▶  OTel SDK  ──exports──▶  OTel Collector  ──routes──▶  Backend(s)
                                                                              │
                                                                              ├─ Prometheus (metrics)
                                                                              ├─ Loki / ELK (logs)
                                                                              └─ Tempo / Jaeger (traces)
```

Why OTel over vendor SDKs: swap backends without re-instrumenting; correlate signals via shared trace ID; portable across languages.

## What to instrument first — the minimum

For any new service, day-one instrumentation:

- Four golden signals as Prometheus counters/histograms
- Structured JSON logs with `trace_id`, `service`, `env`, `version`
- OTel tracing for cross-service calls
- Health endpoint (`/healthz`) — liveness (am I up) + readiness (can I serve traffic)
- Version endpoint (`/version`) — SHA + build time; makes rollback verification instant

## Dashboards — three tiers

| Tier           | Audience                | Content                                                    |
|----------------|-------------------------|------------------------------------------------------------|
| **Overview**   | Anyone (on-call, PM)    | Traffic, latency, error rate, SLO status. One page. |
| **Service**    | Service owners          | RED + USE + dependencies + key business metrics.           |
| **Debug**      | Engineers deep-diving   | Per-endpoint, per-region, per-version. Ad hoc slicing.     |

Don't build all three at once. Start with Overview; add Service when you have oncall; add Debug when you're debugging your third incident on this service.

## Logs — structured, not prose

**Bad** (unparseable, unqueryable):

```
2026-07-01 14:32:11 ERROR user 4823 failed to log in
```

**Good** (queryable, correlated):

```json
{"ts":"2026-07-01T14:32:11Z","level":"error","event":"login_failed","user_id":"4823","reason":"invalid_password","trace_id":"abc123","service":"auth","version":"v1.4.2"}
```

Rule: **log events, not sentences**. Every log line has `level`, `event`, `trace_id`, `service`, `version` plus event-specific fields.

## Traces — sample smart

Full traces are expensive. Two strategies:

- **Head sampling** — decide at trace start (e.g., 1% of traffic). Cheap, uniform, but misses rare events.
- **Tail sampling** — decide after trace ends (e.g., keep all errors, keep slow requests, keep 1% of successful). Expensive to collect; retains signal.

Default: tail sampling for production, head sampling (10%+) for staging.

## Alert hygiene

Every alert must:

- **Be actionable** — a human can do something specific to fix it. "CPU high" is not actionable; "auth-service CPU > 85% for 10min, likely scale event" is.
- **Point to a runbook** — link in alert body to `docs/runbooks/<alert-name>.md`.
- **Have a documented false-positive rate** — track weekly. > 20% = broken alert.
- **Be tied to a symptom, not a cause** — page on "users can't log in", not on "Redis connection count is high". Causes change; symptoms stay stable.

Anti-pattern: alerts that fire on every "unusual" pattern. Model-based anomaly detection sounds smart until it pages on Christmas Day.

## Common failure modes

- **Averaging over p99** — averages hide tail latency; monitor percentiles.
- **Alerting on infrastructure, not user impact** — nobody paged because a disk was 60% full. Users paged because checkouts failed.
- **No SLO** — without a target, everything is "somewhat slow" and nothing is fixed.
- **Log-based alerts** — grep pipelines break; timestamps drift; use metrics.
- **Dashboards that only look good** — pretty but not read during incidents. Test dashboards during game days.

## When to instrument more

Signals to add instrumentation:

- Incident took > 30 min to diagnose because we couldn't tell what happened → add trace / log fields
- Ops asked "is this normal?" and couldn't answer → add baseline metric
- Alert paged but nobody knew what to do → add runbook, refine alert
- A user complained about slowness we didn't detect → add user-facing SLI

If none of these trigger, resist adding more. Instrumentation has cost — signal noise, storage, complexity.
