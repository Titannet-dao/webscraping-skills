---
name: titan-competitive-intel
description: Track what competitors charge, ship, and claim, through Titan, and write it to a file built to be re-run and diffed. Use when the user asks for a competitor analysis or competitive analysis, wants to compare pricing, plans, or features against rivals, wants to monitor a competitor's changelog, releases, or positioning, asks "what changed since last time", or wants a recurring competitor watch. For who else exists in a category, use titan-market-landscape first.
license: MIT
metadata:
  author: titannet-dao
  homepage: https://webscraping.titannet.io
  source: https://github.com/titannet-dao/webscraping-skills
---

# Titan competitive intel

Produces `competitors-<category>.md`: a side-by-side of pricing, packaging, features, and
positioning, plus a changelog of what moved since the last run.

Written so the second run is more valuable than the first. Every fact carries the URL it
came from and the date it was read, so a re-run diffs cleanly instead of being rewritten
from scratch.

## Before you start

Infer the competitors and the axes from what the user said, and from their own site if you
have it.

Ask only:

- who the competitors are, if not given and not inferable — otherwise propose a list from
  search and let them correct it
- what they care about comparing, if the request is vague: price, features, positioning,
  release velocity
- whether a previous run exists to diff against — check the working directory for a prior
  `competitors-*.md` before asking

## Collect

Read [titan-tools.md](https://github.com/titannet-dao/webscraping-skills/blob/main/references/titan-tools.md) first for the caps.

**Find the pages, per competitor.** `titan_crawl` with `mode=map` on each competitor's
domain, then pick out what matters — pricing, plans, features, product pages, changelog,
release notes, docs, about, customers. `include_patterns` narrows a large site fast.
Crawl is one origin at a time and **asynchronous by default**, so each competitor is its
own run collected with `titan_get_run`.

For a small competitor set, `titan_search` with `include_domains: ["competitor.com"]` and
terms like pricing or changelog is quicker than a full map.

**Read them live.** `titan_fetch` with **`freshness=live_only`**. This is the whole point
of the workflow: a cached price is not a price, and a monitoring report built on cache
reports last month's state as today's.

- Batch across competitors — up to 100 URLs per call, so one call usually covers the
  whole set.
- `only_main_content=true` for feature and marketing copy.
- `only_main_content=false` for pricing pages. Plan comparison tables and footnotes
  frequently live outside the main content block, and the footnotes are where the real
  limits are.
- Raise `max_chars_per_url` past 12,000 for long changelogs and feature matrices.

**Record what you read, when.** Every extracted fact gets its source URL and the date it
was fetched. This is what makes the next run a diff.

### Pricing pages resist reading

Expect this and handle it rather than reporting a number you are unsure of:

- Prices set by client-side JavaScript may be absent from the markup. Titan does not
  render JS. If a plan's price is missing, record it as *not readable from the page* — not
  as free, and not as an estimate.
- Prices differ by visitor country. When that matters, fetch through
  `titan_run_template` with `proxy_locations` — see
  [regional-search.md](https://github.com/titannet-dao/webscraping-skills/blob/main/references/regional-search.md) — and label each price with
  the location it was read from.
- Toggles (monthly/annual, currency, seat count) usually mean one state is in the markup
  and the other is not. Say which one you captured.
- "Contact us" is a finding, not a gap. It says something about who they sell to.

## Parallel work

One competitor per sub-agent, if available. Give each the domain, the page types to find,
and a fixed return shape: plans with prices and limits, features present or absent,
positioning claims, recent releases, every fact with URL and fetch date.

Merge centrally. Comparison only works if one writer normalises the vocabulary — two
vendors calling different things "unlimited" is a finding you can only see side by side.

## Analyse

- **Normalise before comparing.** Per-seat against per-usage against flat-rate needs a
  stated basis, or the table is misleading. Say what you normalised to.
- **Compare limits, not just prices.** The cheaper plan with a lower cap is not cheaper.
- **Quote positioning.** How a competitor describes itself is evidence; your paraphrase is
  not.
- **Diff against the prior run** when one exists: price changes, plans added or removed,
  features shipped, positioning rewritten, pages that disappeared. The changelog is
  usually the most-read section.

## Deliverable

Write `competitors-<category>.md`:

```markdown
# Competitive intel: <category>
Run date. Competitors covered. Normalisation basis for pricing.

## What changed
Since the last run: price moves, new plans, shipped features, repositioning.
First run: say so.

## Pricing
Table: competitor, plan, price, billing basis, key limits, source URL, date read,
location read from if it varied.

## Features
Matrix: capability by competitor. Present / absent / partial, with the URL that
shows it. Mark "not stated" separately from "absent" — they are different claims.

## Positioning
Per competitor: who they say they serve, in their own words, quoted with the URL.

## Release velocity
What each has shipped recently, from changelogs and release notes.

## Read this carefully
Prices that could not be read from the markup, JS-rendered content skipped,
regional variation not checked, pages behind a login.

## Rerun inputs
workflow: titan-competitive-intel
competitors: <domains>
axes: <pricing, features, positioning, releases>
freshness: live_only
output: competitors-<category>.md
```

Report roughly what the run consumed and point at
<https://webscraping.titannet.io/usage>.

Suggest a re-run cadence that matches what moves — pricing quarterly, changelogs monthly.

## Quality bar

- `freshness=live_only` for anything time-sensitive. Not negotiable in this workflow.
- Every cell in every table has a URL and a date.
- "Not stated on their site" and "they do not have it" are different findings. Never
  collapse them.
- No inferred prices. Missing is missing.
- Read `warnings` on every call.
