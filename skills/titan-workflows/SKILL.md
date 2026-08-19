---
name: titan-workflows
description: Pick and run right Titan web-data workflow, then produce finished file. Use when user wants research report, SEO audit, competitor tracker, pre-meeting company brief, audience research, or web-data job with no obvious workflow. Also use when job needs regional search engine or country-specific view.
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
- **[titan-lead-research](../titan-lead-research/SKILL.md)** — a brief on one company or
  person before a meeting or an outreach message.
- **[titan-audience-research](../titan-audience-research/SKILL.md)** — what people
  publicly say about a category or brand, from communities and review sites.

For a market map or investor question, use `titan-deep-research` with a modest credit
ceiling. These workflows are intentionally not standalone skills until they complete a
reliable live run.

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
2. **Read [titan-tools.md](https://github.com/titannet-dao/webscraping-skills/blob/main/references/titan-tools.md)** for the real caps,
   defaults, and the things Titan cannot do. Plan around them rather than discovering
   them mid-run.
3. **Discover.** `titan_search` with explicit `search_provider: "bing"` for URLs, or
   `titan_crawl` with `mode=map` when the
   question is about one site. Pick the provider by market — see
   [regional-search.md](https://github.com/titannet-dao/webscraping-skills/blob/main/references/regional-search.md).
4. **Collect.** Every call can return `run_id`; poll it with `titan_get_run`. On
   `provider_rate_limited` with run ID, poll and never re-issue. Without run ID, wait
   minutes before retrying once.
5. **Read.** `titan_fetch` in batches of 5–10 URLs. Validate status, final URL, and content
   length before use. Use `freshness=live_only` for
   anything that changes, like prices.
6. **Extract.** Titan returns markdown, not records. Parsing it into the fields the
   deliverable needs is your job.
7. **Write a file.** Not a chat message. Keep every claim attached to URL it came
   from.
8. **Close out.** Report records delivered, blocked records, credit ceiling, and rerun inputs.
   user or a scheduler can repeat it.

## Pace work

Use one active Titan call per API key. Parallel agents share account quota and trigger
rate limits; research and collection stay sequential.

## Deliverable standards

Whatever the workflow, the file contains:

- a summary someone can act on without reading the rest
- the evidence, each claim next to its source URL
- what run could not reach, and why — block, login wall, JS shell, invalid page, or dropped
  refinement
- rerun inputs

The last two matter most. A report that hides its gaps is worse than a shorter one that
names them.

## Language

Write the deliverable in the language the user is writing in. Keep source titles and
quotes in their original language with the URL intact — a Chinese source cited in an
English report stays Chinese.
