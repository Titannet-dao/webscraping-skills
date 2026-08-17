---
name: titan-workflows
description: Pick and run the right Titan web-data workflow, and produce it as a finished file. Use when the user wants a deliverable built from web data through Titan — a research report, SEO audit, competitor tracker, investor or funding brief, pre-meeting company brief, market landscape, or audience research — or when they ask what Titan can do for them, or describe a web-research job with no obvious skill attached. Also use when a workflow needs data from a specific country or from Baidu, Yandex, Naver, or another regional search engine.
license: MIT
metadata:
  author: titannet-dao
  homepage: https://webscraping.titannet.io
  source: https://github.com/titannet-dao/webscraping-skills
---

# Titan workflows

Titan reads the open web — search it, fetch pages, crawl a site — on Titan Network's own
residential infrastructure. This skill turns that into a finished deliverable rather than
a pile of scraped pages.

If the user wants a single page fetched or one search run, just call the tool. This skill
is for the jobs that end in a document.

## Pick the workflow

- **[titan-deep-research](../titan-deep-research/SKILL.md)** — a cited report on a topic
  that no single search answers. Market, technical, policy, regulatory.
- **[titan-seo-audit](../titan-seo-audit/SKILL.md)** — a site's structure, on-page SEO,
  and how it compares to whoever outranks it.
- **[titan-competitive-intel](../titan-competitive-intel/SKILL.md)** — what competitors
  charge, ship, and claim. Built to be re-run on a schedule and diffed.
- **[titan-investor-research](../titan-investor-research/SKILL.md)** — funding rounds,
  which funds are actively deploying, portfolios, and the shared-investor graph between
  companies.
- **[titan-lead-research](../titan-lead-research/SKILL.md)** — a brief on one company or
  person before a meeting or an outreach message.
- **[titan-market-landscape](../titan-market-landscape/SKILL.md)** — who is in a
  category, how it is segmented, and how it differs by region. The workflow that uses
  Titan's regional search engines hardest.
- **[titan-audience-research](../titan-audience-research/SKILL.md)** — what people
  publicly say about a category or brand, from communities and review sites.

Several of these compose. A market entry question is usually
`titan-market-landscape` for the shape, then `titan-competitive-intel` on the players
that matter. Run them in that order rather than merging them into one sprawling pass.

If none fits, use the process below and tell the user at the end that this could become a
new skill.

## Before you start

Infer the workflow, the subject, and the output format from what the user already said
and from any URLs or files they gave you. If that is enough, start.

Otherwise ask at most 1–3 questions, and only ones that change the work:

- what to analyse — the topic, company, site, or category
- which market or country, when the answer would differ by region
- the deliverable, if a document is not obviously right

Name your defaults in one line instead of asking about them.

## Default process

1. **Check Titan is connected.** The tools are `titan_search`, `titan_fetch`,
   `titan_crawl`, `titan_get_run`. If they are absent, the user has not connected their
   client — point them at <https://webscraping.titannet.io/overview> and stop. Do not
   substitute another web tool and present it as a Titan run.
2. **Read [titan-tools.md](../../references/titan-tools.md)** for the real caps,
   defaults, and the things Titan cannot do. Plan around them rather than discovering
   them mid-run.
3. **Discover.** `titan_search` for URLs, or `titan_crawl` with `mode=map` when the
   question is about one site. Pick the provider by market — see
   [regional-search.md](../../references/regional-search.md).
4. **Read.** `titan_fetch` in batches of up to 100 URLs. Use `freshness=live_only` for
   anything that changes, like prices.
5. **Extract.** Titan returns markdown, not records. Parsing it into the fields the
   deliverable needs is your job.
6. **Write a file.** Not a chat message. Keep every claim attached to the URL it came
   from.
7. **Close out.** Report roughly what the run consumed, and give the rerun inputs so the
   user or a scheduler can repeat it.

## Work in parallel where the units are independent

Use sub-agents or an equivalent parallel runner when the work splits cleanly: one
competitor each, one research angle each, one region each, one page each. Hand over the
unit, the URLs or queries, the fields to extract, and the output shape — nothing
harness-specific.

Synthesis stays sequential and central. Parallel researchers gather; one writer decides
what it means.

## Deliverable standards

Whatever the workflow, the file contains:

- a summary someone can act on without reading the rest
- the evidence, each claim next to its source URL
- what the run could not reach, and why — a login wall, a paywall, a dropped search
  refinement reported in `warnings`
- rerun inputs

The last two matter most. A report that hides its gaps is worse than a shorter one that
names them.

## Language

Write the deliverable in the language the user is writing in. Keep source titles and
quotes in their original language with the URL intact — a Chinese source cited in an
English report stays Chinese.
