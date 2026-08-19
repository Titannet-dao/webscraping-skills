---
name: titan-lead-research
description: Build brief on one company or person before meeting or outreach, from open-web evidence gathered through Titan. Use when user has call, demo, interview, or pitch, asks "what should I know about <company>", wants personalised outreach, qualifies prospect, or needs what company sells, who it sells to, and recent changes.
license: MIT
metadata:
  author: titannet-dao
  homepage: https://webscraping.titannet.io
  source: https://github.com/titannet-dao/webscraping-skills
---

# Titan lead research

Produces `brief-<company>.md`: what they do, who they sell to, what changed recently, and
the specific things worth mentioning — short enough to read in the five minutes before a
call.

Length is the constraint. A twelve-page dossier fails at the job this brief exists for.

## Before you start

If you have a company name or domain, start. Ask only:

- the company, if not given
- what the meeting is for — sales call, interview, partnership, investment — because it
  changes what matters. Default to a sales call and say so.
- what the operator sells, for sales or partnership context — read target against this offer.
- the person, if the brief should cover an individual as well

## Collect

Read [titan-tools.md](https://github.com/titannet-dao/webscraping-skills/blob/main/references/titan-tools.md) first for the caps.

**Their own site is primary source.** For known company, fetch standard paths first:
homepage, `/pricing`, `/product`, `/customers`, `/careers`, `/blog`, `/changelog`, and
`/about`; use `titan_crawl mode=map` only when those paths leave a gap. Then fetch:

- homepage — how they describe themselves this week
- product or platform pages — what it actually is
- pricing — how they sell, and to whom the price implies they sell
- customers, case studies, logos — who they serve
- about, team, careers — size, structure, and what they are building next. Open roles are
  the most reliable public signal of priorities: three infra hires means something.
- blog and news — recent direction

Batch fetch 5–10 URLs. Apply `titan_get_run` after every call returning `run_id`; never
re-issue rate-limited request carrying `run_id`. Use `only_main_content=true` for reading;
`include_links=true` when you need to reach case studies and press from an index page.

**Then outside sources.** `titan_search` with `search_provider: "bing"`, `max_results: 10`,
for recent news, funding, launches, and
leadership changes, with `freshness=month` or `year` depending on how much you need. Fetch
the ones that matter.

**Then what customers say.** Prefer `old.reddit.com`, product forums, and Hacker News.
G2, Trustpilot, Capterra, and similar review sites often return blocks; probe one URL alone
and report unavailable evidence rather than retrying.

**For a person**: their own writing is fetchable — a personal site, a company bio page,
conference talk pages, podcast episode notes, published articles. Their LinkedIn, X, or
Instagram is **not**: no authenticated sessions, no browser. Say that in the brief rather
than leaving a thin section unexplained.

Stay proportionate. Default ceiling: 20 credits. This is meeting brief, not research report.
Stop when offer-relevant picture is clear or ceiling ends.

### Only what they published

Everything in the brief comes from what the company or person chose to publish, or what
was published about them. Do not compile personal details beyond someone's professional
public record, and do not go looking for personal contact details, home addresses, or
anything about their family. If the user asks for that, decline that part and deliver the
professional brief.

## Analyse

- **Quote their own words** for positioning. Your paraphrase of what a company does is
  less useful than the sentence they wrote.
- **Infer the buyer** from price point, case studies, and the roles they are hiring —
  then say it is an inference.
- **Recency wins.** A launch three weeks ago is worth more than a 2022 funding round.
- **Find the specific hook** — the thing to mention that proves the brief was read. One
  concrete, current, checkable detail beats a paragraph of summary.

## Deliverable

Write `brief-<company>.md`. Keep it to one page:

```markdown
# <Company>
One line: what they do, for whom. Site, sector, size if known.

## What they sell
Product, how it is packaged, price point if public.

## Who they sell to
Segments, named customers, and what the evidence for that is.

## What's changed recently
Launches, funding, leadership, hiring direction. Dated, with sources.

## What customers say
Themes from reviews and community threads, with links. Volume noted —
four reviews is not a signal.

## Worth mentioning
Two or three specific, current, checkable things to raise on the call.

## Questions to ask
Three questions the research raised that their site does not answer.

## Sources
URLs, grouped by their site and outside sources.

## Not covered
What was unreachable — social platforms, gated reviews, anything JS-rendered.

## Rerun inputs
workflow: titan-lead-research
company: <domain>
person: <name, optional>
context: <sales | interview | partnership | investment>
operator_offer: <what operator sells, optional>
urls_read: <exact URL list>
output: brief-<company>.md
```

Report records delivered, blocked records, and credit ceiling used.

## Quality bar

- One page. If it does not fit, cut the general and keep the specific.
- Every claim has a URL, including the ones from their own site.
- Mark inferences as inferences. "Likely selling to mid-market, based on pricing and
  named customers" is useful; stated as fact it is not.
- Date everything. Undated recency is the failure mode of this brief.
- Professional public record only.
- Prefer primary sources. When credible sources conflict, name conflict and source chosen.
