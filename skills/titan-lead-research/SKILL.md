---
name: titan-lead-research
description: Build a brief on one company or person before a meeting or an outreach message, from open-web evidence gathered through Titan. Use when the user has a call, demo, interview, or pitch coming up and wants background, asks "what should I know about <company>", wants to personalise outreach, is qualifying a prospect, or wants to know what a company does, who it sells to, and what changed recently. For many companies at once use titan-market-landscape; for funding detail use titan-investor-research.
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
- the person, if the brief should cover an individual as well

## Collect

Read [titan-tools.md](https://github.com/titannet-dao/webscraping-skills/blob/main/references/titan-tools.md) first for the caps.

**Their own site is the primary source.** `titan_crawl` with `mode=map` on the domain to
find the pages worth reading, then `titan_fetch`:

- homepage — how they describe themselves this week
- product or platform pages — what it actually is
- pricing — how they sell, and to whom the price implies they sell
- customers, case studies, logos — who they serve
- about, team, careers — size, structure, and what they are building next. Open roles are
  the most reliable public signal of priorities: three infra hires means something.
- blog and news — recent direction

Batch the fetch, up to 100 URLs per call. `only_main_content=true` for reading;
`include_links=true` when you need to reach case studies and press from an index page.

**Then outside sources.** `titan_search` for recent news, funding, launches, and
leadership changes, with `freshness=month` or `year` depending on how much you need. Fetch
the ones that matter.

**Then what customers say.** Review sites — G2, Trustpilot, Capterra — and community
threads are reachable and often more honest than the case studies. Search for the company
name alongside the site, and expect partial reads: review platforms paginate and
increasingly gate content.

**For a person**: their own writing is fetchable — a personal site, a company bio page,
conference talk pages, podcast episode notes, published articles. Their LinkedIn, X, or
Instagram is **not**: no authenticated sessions, no browser. Say that in the brief rather
than leaving a thin section unexplained.

Stay proportionate. This is a brief for one meeting, not a research report. When the
picture is clear enough to walk into the call, stop.

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
output: brief-<company>.md
```

Report roughly what the run consumed and point at
<https://webscraping.titannet.io/usage>.

## Quality bar

- One page. If it does not fit, cut the general and keep the specific.
- Every claim has a URL, including the ones from their own site.
- Mark inferences as inferences. "Likely selling to mid-market, based on pricing and
  named customers" is useful; stated as fact it is not.
- Date everything. Undated recency is the failure mode of this brief.
- Professional public record only.
