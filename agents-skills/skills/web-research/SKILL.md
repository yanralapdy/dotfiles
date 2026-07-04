---
name: web-research
description: Disciplined web research with source triage, citation, and confidence scoring. Use when researching an unfamiliar library, API contract, migration path, prior art, best-practice comparison, or when user asks "look this up", "research", "find docs for", or requests any topic outside the parametric knowledge cutoff.
---

# Web Research

Answer specific factual questions from the web without hallucinating. Every claim traces to a source or is explicitly marked as unverified.

## The three-pass method

Every research task runs three passes. Skip one → answer degrades.

1. **Cast wide** — 1-3 web searches with different phrasings. Skim results, note domain diversity. Do not click yet.
2. **Cite deep** — Open 2-5 primary sources (project docs, GitHub READMEs, canonical specs, first-hand author posts). Extract concrete claims with URLs.
3. **Reconcile** — When sources disagree, name the disagreement in the answer. Never silently pick one.

## Source triage

Rank by trust:

| Tier | Sources                                                                 | Trust    |
|------|-------------------------------------------------------------------------|----------|
| 1    | Official project docs, official specs (RFCs, W3C), canonical GitHub repo | High     |
| 2    | Author personal posts, well-known engineering blogs (Cloudflare, Netflix, Stripe, Google Cloud, AWS blogs), academic papers | High     |
| 3    | High-star GitHub examples, established Q&A (Stack Overflow accepted answers with dates) | Medium   |
| 4    | Framework tutorial blogs, dev.to posts, Medium articles                 | Medium-low, check date |
| 5    | AI-generated content farms, undated listicles, "top 10" sites            | Low. Skip unless corroborated by higher tier. |

**Red flags:** no author, no date, no code samples, generic advice, repeated LLM cadence ("delve into", "in today's fast-paced world"), broken examples.

## GitHub repo research

For any library or tool the answer depends on:

```
1. Check stars, last commit date, open issue count — is it alive?
2. Read README top-to-bottom — installation, quickstart, limitations
3. Skim CHANGELOG / releases — recent breaking changes?
4. Check open issues for the exact question — often already answered
5. Search repo for the file/function mentioned in your question
6. Note license — affects usage in commercial code
```

Stars alone don't equal quality. A 3-month-old repo with 15k stars is often a rewrite of an established alternative and may be under-tested.

## Citation format

Every non-trivial claim in the answer includes an inline reference:

```markdown
Trivy handles CycloneDX and SPDX SBOMs and includes vuln, license, secrets, and IaC scans in one CLI [1].
Syft focuses purely on SBOM generation and is often paired with Grype for scanning [2].

[1] https://trivy.dev/docs/latest/guide/target/sbom/
[2] https://github.com/anchore/syft
```

Numbered inline; sources at the bottom. One line per source. Include the URL fragment or section anchor if the claim is on a long page.

## Confidence scoring

Every answer ends with an explicit confidence line:

- **High** — Two or more Tier 1/2 sources agree; direct quote available; recent (< 12 months).
- **Medium** — One Tier 1/2 source, or multiple Tier 3; some inference required; may be dated.
- **Low** — Only Tier 3-4 sources; sources contradict; my sources are older than the question warrants.

Low confidence is not failure. It's honest. Better than fake precision.

## Workflow

```
1. Restate the question in one sentence. If it can't be one sentence, split into multiple research tasks.
2. Draft 2-3 search queries with different keyword sets and phrasing:
   - Query A: precise technical terms
   - Query B: what a beginner would type
   - Query C: "vs" or "compared to" a known alternative (surfaces comparison articles)
3. Run searches. Note the top 3-5 unique domains per query.
4. Open the highest-tier sources first. Read, don't skim, the sections that answer the question.
5. Extract claims into notes: {claim, URL, quote or paraphrase, date of source}.
6. If sources disagree: name the disagreement, cite both, recommend the higher-tier one but flag the conflict.
7. Draft the answer:
   - Short summary (3-8 lines)
   - Detail with inline citations
   - Alternatives considered (if relevant)
   - Caveats / edge cases
   - Confidence line
   - Sources list
8. Self-check: does every non-obvious claim have a citation?
```

## Query design

- **Precise beats catchy** — search "React 19 useOptimistic hook" not "how do I make my React fast"
- **Add year for time-sensitive topics** — "kubernetes ingress vs gateway 2026"
- **Use "vs" to surface comparisons** — "trivy vs snyk"
- **Add `site:github.com` when you want repos, not blogs**
- **Add `site:docs.<project>.com` for official documentation**
- **Add `-medium.com -dev.to` when you want to exclude low-signal blogs**

## Fetch discipline

When opening a page:

- **selective mode** with `search_terms` — pulls only relevant sections; use when you know the specific claim you're chasing.
- **full mode** — use when the page is short (< 5000 chars) or when structure matters (a spec, a changelog).
- **truncated mode** — last resort; loses context.

Never quote from a page you haven't opened. "According to X..." with no URL = fabrication risk.

## What NOT to do

- **Don't** rely on parametric knowledge for time-sensitive facts (versions, API shapes, current best practice). Verify.
- **Don't** cite a URL you didn't open. Domain in a search result ≠ source read.
- **Don't** stitch together unrelated blog posts to fabricate consensus. If they don't cite each other, they may all be wrong together.
- **Don't** answer around the question. If you can't verify, say "I couldn't confirm from the sources I checked" and list what you searched.
- **Don't** trust a single AI-authored article — it may be summarizing another AI article summarizing a real source. Chase to the real source.

## Output template

```markdown
## <Question>

**Answer**: <3-8 line summary>

### Detail

<paragraph with inline [1], [2] citations>

### Alternatives considered
- <alt A> — <why not>
- <alt B> — <why not>

### Caveats
- <edge case or limitation>

**Confidence**: High | Medium | Low
**Date of sources**: <most recent source's date>

### Sources
[1] <URL> — <title, date>
[2] <URL> — <title, date>
```
