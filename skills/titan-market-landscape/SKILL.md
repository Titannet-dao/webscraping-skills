---
name: titan-market-landscape
description: Map a market or product category through Titan — who is in it, how it segments, and how it differs by country — written to a file with a player table and per-region findings. Use when the user asks who is in a market or category, wants a market map or landscape, is evaluating entering a market or a new country, asks how a category looks in China, Russia, Korea, Japan, or another specific region, or wants to compare a market across geographies. For a deep dive on named rivals, follow with titan-competitive-intel.
license: MIT
metadata:
  author: titannet-dao
  homepage: https://webscraping.titannet.io
  source: https://github.com/titannet-dao/webscraping-skills
---

# Titan market landscape

Produces `landscape-<category>.md`: the players in a category, how the category divides,
and — where it matters most — how all of that changes when you look at it from inside a
different country.

This is the workflow that uses Titan's eight search providers and residential network for
what they are actually for. A market map built only from Google is a map of the
English-language internet's opinion of a market.

## Before you start

Infer the category and the geography from what the user said. Ask only:

- the category, in the words buyers would use, if it is ambiguous
- which markets — a single country, a comparison of several, or global. This is the
  question that most changes the work, so ask it if it is not stated.
- the segment, if the category is broad enough that "enterprise" and "consumer" are
  different markets

Default to a global view with the user's own market called out, and say so.

## Collect

Read [titan-tools.md](https://github.com/titannet-dao/webscraping-skills/blob/main/references/titan-tools.md) and
[regional-search.md](https://github.com/titannet-dao/webscraping-skills/blob/main/references/regional-search.md) before planning. The second one
decides the shape of this workflow.

**Search from inside each market.** One provider per market, chosen by where the market's
own answers live: `baidu` for China, `yandex` for Russia and CIS, `naver` for South Korea,
`yahoo` for Japan, `google` or `bing` for Western markets.

- **Query in the market's language.** A Baidu search phrased in English returns the
  expatriate view of a Chinese market, not the market.
- Run **the same question through two providers** when comparison is the point. Different
  players, different ranking, different vocabulary — the delta between the two result sets
  is a finding in its own right, and belongs in the report.
- Set `country` and `language` on the providers that honour them. Baidu, Yandex and Naver
  ignore both and serve their own locale, which is fine — that is what you wanted from
  them. Check `warnings` to see what was dropped, and never assume a locale applied.
- On DuckDuckGo, `country` and `language` must be passed together or both are dropped.

**Search several ways, not one.** Categories are named differently by the people in them:
the buyer's term, the vendor's term, the analyst's term. Also search sideways —
"alternatives to <known player>", "<category> vendors", directory and comparison pages,
industry association member lists. Each angle surfaces players the others miss.

**Read the players.** `titan_fetch` each candidate's homepage and product page, batched
up to 100 URLs per call, to confirm they are real and in the category rather than an SEO
page about it. A landscape padded with dead companies and content marketing is worse than
a shorter accurate one.

`titan_crawl` with `mode=map` is worth it on directories and association sites, where one
page links to the whole membership.

**Check availability by region when it matters.** Whether a player actually serves a
market is often only visible from inside it: localized pricing, a country selector, a
redirect, a "not available in your region" page. Fetch the same URL through
`titan_run_template` with `proxy_locations` for the markets in question — the recipe is in
[regional-search.md](https://github.com/titannet-dao/webscraping-skills/blob/main/references/regional-search.md) — and label each observation
with the location it was read from.

Use this where the answer turns on it, not as a sweep of every country.

**Numbers, if they exist.** Market sizing is mostly paywalled analyst reports. Reachable
substitutes: government and statistical agency publications, industry association reports,
public company filings, and the summary pages analysts publish for free. Cite what you
find and mark clearly what remained unavailable. Never estimate a market size.

## Parallel work

Split by market, if sub-agents are available — one region each, running its own provider in
its own language. Fixed return shape: player name, domain, one-line description in
English, segment, evidence URL, provider and locale it was found through.

One writer merges. Cross-market synthesis is where the value is, and it cannot be done by
agents that each saw one country.

## Analyse

- **Segment from the evidence.** Let the divisions come from how players actually describe
  themselves and price, not from a framework you brought with you.
- **Keep regional findings labelled.** Never merge a Baidu result set and a Google result
  set into one undifferentiated list. Which provider and locale surfaced a player is part
  of the finding.
- **Say who is absent where.** A global leader missing from Baidu results is one of the
  most useful things this report can tell someone.
- **Separate confirmed from listed.** A player you fetched and confirmed is stronger
  evidence than a name in a listicle.

## Deliverable

Write `landscape-<category>.md`:

```markdown
# Market landscape: <category>
Run date. Markets covered, with the provider and language used for each.

## Summary
The shape of the category, and what differs by region.

## Segments
How the category divides, derived from the evidence, with the players in each.

## Players
Table: name, domain, segment, market focus, positioning in their own words,
confirmed or listed-only, found via which provider and locale, source URL.

## By market
One section per market: who leads there, who is absent, local-only players,
vocabulary differences, availability and pricing observations with the proxy
location they were read from.

## Cross-market differences
What changes between markets and what that implies for entering one.

## Sizing evidence
What was found, from whom, dated. What was paywalled and left unmeasured.

## Coverage gaps
Providers that dropped refinements, markets not checked, sizing unavailable,
languages not searched.

## Rerun inputs
workflow: titan-market-landscape
category: <category>
markets: <countries>
providers: <provider per market>
languages: <language per market>
output: landscape-<category>.md
```

Report roughly what the run consumed and point at
<https://webscraping.titannet.io/usage>.

## Quality bar

- Every player was either fetched and confirmed, or explicitly marked listed-only.
- Every regional finding names the provider and locale it came from.
- No estimated market sizes. Cite or omit.
- If the report claims to cover a market, it was searched in that market's language
  through that market's provider. Otherwise say it was covered from outside.
- Read `warnings` on every call — a dropped `country` means the result set is not the one
  the report describes.
