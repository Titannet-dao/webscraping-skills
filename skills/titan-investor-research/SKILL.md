---
name: titan-investor-research
description: Research funding and investors through Titan — recent rounds, which funds are actively deploying, a fund's portfolio, what a firm is publishing, and the shared-investor graph between companies — written to a file with every claim sourced. Use when the user asks about funding rounds, who raised recently, which VCs are active or writing cheques now, a fund's new vehicle or fund size, a firm's portfolio, what a firm has been saying or investing in lately, who backed a company, or which competitors share investors. Works from SEC filings, press announcements, and firms' own sites, blogs, and newsletters; paywalled databases like Crunchbase and PitchBook are out of reach.
license: MIT
metadata:
  author: titannet-dao
  homepage: https://webscraping.titannet.io
  source: https://github.com/titannet-dao/webscraping-skills
---

# Titan investor research

Produces `investors-<subject>.md` and, when the user wants a list, `funding.csv`: rounds,
funds, portfolios, and co-investor relationships, each fact next to the document that
supports it.

The discipline that makes this workflow worth running is knowing which questions the
public record actually answers. Read the next section before planning.

## What the public record does and does not say

Getting this wrong produces a confident report that is wrong, so be exact:

- **A US company raising a private round usually files a Form D with the SEC.** It gives
  the issuer, the offering amount, the amount sold, the date, and related persons —
  executives, directors, promoters. It is the closest thing to a primary source for "did
  they raise, when, and how much".
- **Form D does not name the investors.** It lists related persons of the issuer, not
  participating funds. Who led the round comes from the company's own announcement, the
  fund's portfolio page, or press coverage — never from the filing. Do not infer an
  investor from a Form D.
- **A VC firm raising a new fund files a Form D too**, as the issuer, for the fund vehicle
  itself — "Fund VII, L.P." with a target offering amount and a first-close date. This is
  the strongest public signal that a firm is **actively deploying**: fresh capital,
  recently closed. Search for the firm's fund entities, not just the firm name.
- **Form ADV** covers registered investment advisers and carries assets under management
  and ownership. Useful for larger firms; smaller venture managers may not be registered.
- **13F holdings are public-market positions.** Irrelevant to venture rounds. Do not use
  them as a portfolio.
- **Non-US rounds have no Form D.** UK companies file at Companies House; other
  jurisdictions vary. Outside the US, press and the fund's own site carry more of the
  weight, and confidence should be lower.
- **Crunchbase, PitchBook, CB Insights and Dealroom are paywalled** and will return a
  login or teaser page. Do not fetch them and read a partial page as data. If the user
  needs their coverage, say plainly that it needs a subscription.

Valuations are almost never in the public record. Treat any valuation as a press claim
attributed to the outlet that printed it.

## Before you start

Infer the subject and which of the four questions is being asked. Ask only:

- the subject — company, fund, or category
- which question: rounds for a company, funds actively deploying in a space, a fund's
  portfolio, or the shared-investor graph between named companies
- geography and time window, when the user has one in mind — default to the last 18
  months and say so

## Collect

Read [titan-tools.md](https://github.com/titannet-dao/webscraping-skills/blob/main/references/titan-tools.md) first for the caps.

**Start with SEC filings when the subject is US.** EDGAR is free and unauthenticated.
Discover the current entry points rather than assuming them: `titan_search` with
`include_domains: ["sec.gov"]` for EDGAR full-text search and company browse, then
`titan_fetch` one filing to confirm the URL pattern works before building a plan on it.

- If EDGAR returns an error, a rate-limit page, or an empty body, **say so in the report
  and fall back to press sources** — do not silently proceed as though filings were
  checked. Note it under coverage gaps.
- Filings are long. Raise `max_chars_per_url` well above the 12,000 default, or the
  offering amounts near the end of the document will be missing.
- `file_types: ["pdf"]` on search helps when a document is only published as a PDF.

**Then press and announcements.** `titan_search` for the round or the fund close, and
`titan_fetch` the results. The company's or fund's own announcement page is the primary
source; a news article about it is secondary. Prefer the announcement, cite the article
when it adds detail.

Use `freshness=month` or `week` when the question is who is active *now*. Remember Baidu,
Yandex and Naver drop `freshness` — if the market is China, Russia, or Korea, filter by
date after fetching instead. See
[regional-search.md](https://github.com/titannet-dao/webscraping-skills/blob/main/references/regional-search.md).

**Then what the firms publish themselves.** A first-class source, not a nice-to-have: this
is where a fund says what it is doing before anyone reports it — new fund announcements,
new partners, thesis shifts, portfolio news, and "why we invested in X" posts naming the
round, the stage, and sometimes the co-investors. It is often the document the press
article was written from.

1. **Find the channel.** Which of three it is cannot be guessed: a news or blog section on
   their own domain, a Medium publication, or a Substack newsletter — the latter two
   frequently on a custom subdomain like `blog.<firm>.com`. Take the URL from the firm's own
   site (`titan_crawl` with `mode=map`, or `titan_fetch` the homepage with
   `include_links=true`) rather than searching blind; `titan_search` with
   `include_domains: ["medium.com", "substack.com"]` catches the ones that stayed put.
2. **Read the index, then the posts.** Fetch the blog index or `/archive` first for titles
   and dates, pick the posts inside your window, then `titan_fetch` those in one batch — the
   limit is 100 URLs, so a firm's whole recent output usually fits. If the index returns no
   post links, an RSS feed at `/feed` or `/rss` is worth one attempt with `format=text`;
   if that fails too, report the channel as unreadable rather than the firm as quiet.
3. **Read a teaser as a teaser.** Both platforms gate some posts behind a paid
   subscription. Record the title and date; never present a truncated post as the firm's
   full position.

**Then portfolio pages.** `titan_crawl` with `mode=map` on the firm's domain to find the
portfolio and news sections, then `titan_fetch` them with `include_links=true` — portfolio
pages link out to the companies, which is how the graph gets built. Portfolio pages are
often paginated or JS-rendered; if you get a shell with no companies in it, say so rather
than reporting a short portfolio.

**For the shared-investor graph**, work from three ends: each company's announcements name
its investors, each fund's portfolio page names its companies, and a firm's own
"why we invested" post names both — often with the stage and the co-investors, which is the
one place that relationship is stated rather than inferred. Build the edges from whichever
side the evidence is strongest on, and record the direction — "X's site lists Y" is a
different quality of evidence from "a 2021 article mentioned Y invested in X".

## Parallel work

One entity per sub-agent, if available — one company, one fund. Fixed return shape: entity,
event, date, amount, currency, source URL, source type (filing, own publication, press),
confidence. Merge centrally so the same round reported by three outlets collapses to one
row.

## Analyse

- **Deduplicate rounds.** The same raise appears as a filing, an announcement, and five
  articles with different numbers. One row, primary source cited, discrepancies noted.
- **"Actively deploying" needs a stated basis.** Say what you counted: recently closed
  fund vehicles, announced investments in the window, or both. A firm with a fresh fund
  and no announced deals is a different signal from one with many deals and no new fund —
  report which.
- **Date every amount** and name the currency. An undated round reads as recent.
- **Distinguish lead from participant** only when a source says so. Otherwise list
  investors without a hierarchy.
- **A firm's own writing is evidence of intent, not of fact.** What they say they are
  focused on, and that they published it on a date, are both reliable. Their claims about a
  market, a portfolio company's traction, or their own track record are marketing until
  something else corroborates them. Quote the intent, corroborate the numbers.

## Deliverable

Write `investors-<subject>.md`:

```markdown
# Investor research: <subject>
Run date. Time window. Geography. What question this answers.

## Summary
What the evidence supports, and how firmly.

## Funding rounds
Table: company, round, date, amount, currency, investors named, primary source URL,
source type, confidence.

## Funds and deployment activity
Per firm: new vehicles and their filing dates and target sizes, announced deals in
the window, the basis for calling them active.

## What the firms are saying
Per firm: the channel and where it lives, recent posts with titles and dates, and
the stated focus or thesis in their own words. Note where a post is the primary
source for a round listed above.

## Portfolio
Per firm, the companies found, with the URL that lists them.

## Shared investors
Which companies share which backers, and the evidence for each edge with its
direction.

## Coverage gaps
Jurisdictions with no filing equivalent, paywalled sources not read, EDGAR
unreachable, portfolio pages that returned no companies, blogs or newsletters
whose index could not be read, subscriber-only posts seen as teasers only,
valuations unavailable.

## Rerun inputs
workflow: titan-investor-research
subject: <company, fund, or category>
question: <rounds | active funds | portfolio | shared investors>
window: <months>
geography: <region>
output: investors-<subject>.md
```

When the user wants a list, also write `funding.csv` with one row per round and a column
per field above. Titan returns markdown, not records — you assemble the CSV from what you
read.

Report roughly what the run consumed and point at
<https://webscraping.titannet.io/usage>.

## Quality bar

- Never name an investor that no source names. Form D does not identify investors.
- Label every fact filing / own publication / press, and never present press as primary.
- No estimated round sizes and no estimated valuations.
- Say when a jurisdiction has no public filing trail, rather than reporting thinner
  coverage as fewer rounds.
- Check each firm's own channel before calling it quiet. A firm with nothing in the press
  and three posts on its Substack is active, and reporting it as inactive is the mistake
  this section exists to prevent.
- Read `warnings` on every call.
