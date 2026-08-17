---
name: titan-deep-research
description: Produce a cited research report on a topic from open-web evidence gathered through Titan, written to a file with every claim attached to its source. Use when the user asks to research a topic, wants a report or briefing on a market, technology, regulation, or industry question, asks "what's the state of X", or needs a synthesis no single search can answer. Not for a quick lookup, a product recommendation, or a company brief — use titan-lead-research for one company and titan-market-landscape for who is in a category.
license: MIT
metadata:
  author: titannet-dao
  homepage: https://webscraping.titannet.io
  source: https://github.com/titannet-dao/webscraping-skills
---

# Titan deep research

Produces `research-<topic>.md`: a report that answers a question from sources the reader
can check, not from what the model already believed.

Use this when a single search is not enough — when the answer is contested, spread across
sources, moving, or needs primary documents. If one search and one fetch would answer it,
do that instead.

## Before you start

Infer the topic and the angle from what the user said. If the topic is clear, start.

Ask only where an answer would change the report:

- the topic, if it is genuinely ambiguous
- which market or region, when the answer differs by geography
- a constraint that reframes the work — a date range, a jurisdiction, a named source they
  trust

Pick everything else yourself and name it in one line.

## Collect

Read [titan-tools.md](https://github.com/titannet-dao/webscraping-skills/blob/main/references/titan-tools.md) first for the caps and defaults.

**Decompose before searching.** Turn the question into distinct angles, and query each one
in its own words rather than re-running one phrasing:

- definitions and current state
- numbers — market size, adoption, pricing, performance
- primary sources — regulations, filings, standards, official documentation
- who disagrees, and what the strongest counter-argument is
- what changed recently

**Search.** `titan_search` per angle. Results are metadata only — title, URL, snippet —
so treat them as a shortlist, not evidence.

- `freshness=month` or `week` when recency is the point. Note that Baidu, Yandex and
  Naver drop `freshness` entirely.
- `include_domains` to go straight at a regulator, a standards body, or a specific
  publication.
- `file_types: ["pdf"]` for filings, standards, and research — often the only place the
  real numbers are. Dropped on Yahoo, Yandex and Naver.
- When the topic is regional, run the same angle through the market's own provider as
  well. See [regional-search.md](https://github.com/titannet-dao/webscraping-skills/blob/main/references/regional-search.md).

**Read.** `titan_fetch` the shortlisted URLs, batched — up to 100 per call, so one call
usually covers a whole angle. Set `only_main_content=true` and raise
`max_chars_per_url` above the 12,000 default for long PDFs and filings, or you will
silently read a fraction of the document and cite it as if you read all of it.

**Follow the trail.** Sources cite sources. When a page's number comes from somewhere
else, fetch that instead and cite the original. `include_links=true` on the first fetch
makes this cheap.

**Keep going until the picture stops changing.** Stop when new sources repeat what you
have, the disagreements are mapped, and the numbers are corroborated — not at a page
count. If the evidence stays thin, that is a finding: report it.

## Parallel work

Independent angles are independent runs. If sub-agents are available, give each one an
angle, the queries, and a fixed return shape: claim, source URL, source quality, how
confident. One writer then synthesises — parallel agents gather evidence, they do not
each write a section.

## Analyse

- **Corroborate.** A number in one source is a claim. In three independent sources it is
  a finding. Say which one you have.
- **Rank sources.** A regulator's filing outranks a vendor's blog outranks a listicle
  reprinting the vendor's blog. When sources conflict, say who says what rather than
  averaging them.
- **Date everything.** A 2019 market figure presented undated reads as current.
- **Separate what you found from what you infer.** Both belong in the report; conflating
  them is what makes research untrustworthy.

## Deliverable

Write `research-<topic>.md`:

```markdown
# <Topic>

## Summary
What the evidence says, and how firmly. Written to be read alone.

## Key findings
Numbered. Each one carries its source link, and says whether it is corroborated or
single-sourced.

## Analysis
The themes, the numbers, and what they mean together.

## Disagreement and counter-evidence
Who argues the other side, on what grounds, and how strong it is.

## Open questions
What is still unknown, and what would settle it.

## Sources
Every URL, with a one-line note on what it contributed and how much to trust it.

## Coverage gaps
What could not be reached — paywalls, login walls, search refinements the provider
dropped (check `warnings`) — and what that leaves uncertain.

## Rerun inputs
workflow: titan-deep-research
topic: <topic>
providers: <providers used>
region: <country or global>
output: research-<topic>.md
```

Report roughly what the run consumed and point at
<https://webscraping.titannet.io/usage>.

Write the report in the user's language. Source titles and quotes stay in their original
language, with the URL intact.

## Quality bar

- Every factual claim has a URL. No exceptions, including ones you were confident about
  before the research started.
- Synthesise. A list of page summaries is not a report.
- Prefer the primary document over anything describing it.
- Name what you could not reach. A gap disclosed is useful; a gap hidden makes the whole
  report unreliable.
