---
name: titan-audience-research
description: Find what people publicly say about a category, brand, or product through Titan — from communities, forums, review sites, and Q&A — and write the themes, complaints, and language to a file. Use when the user wants voice-of-customer or audience research, asks what people think or say about something, wants to know why customers switch or churn, needs the words their market actually uses for messaging or content, or wants review and community sentiment. Reads the open web only — LinkedIn, X, Instagram and TikTok require logins and are out of reach.
license: MIT
metadata:
  author: titannet-dao
  homepage: https://webscraping.titannet.io
  source: https://github.com/titannet-dao/webscraping-skills
---

# Titan audience research

Produces `audience-<subject>.md`: the themes in what people publicly say about a subject,
the words they use, and the complaints that repeat — with links to the threads, so every
theme can be read at source.

The output most people actually need from this is the **language**. Knowing that buyers
say "it keeps timing out" where the vendor says "reliability" is what changes a landing
page.

## What is reachable

Be straight about this at the start of the run, not at the end.

**Reachable**: Reddit threads and subreddits, Hacker News, Stack Overflow and Stack
Exchange, product-specific forums and community boards, GitHub issues and discussions,
review sites — G2, Trustpilot, Capterra, TrustRadius, App Store and Play Store listing
pages — YouTube video pages and their descriptions, blog comment sections, Q&A sites, and
in Chinese-language markets Zhihu, Baidu Tieba and similar, found through `baidu`.

**Not reachable**: LinkedIn, X/Twitter, Instagram, TikTok, Facebook, private Discord and
Slack communities, gated forums. Titan has no authenticated sessions and no browser
automation, so these return login walls. Do not fetch a login wall and characterise it as
thin discussion.

If the user specifically wants those platforms, say once that it needs their official APIs
and is outside what Titan does, then deliver what the open web has. Do not attempt
workarounds.

Some reachable sites are partly gated — review platforms increasingly show a few reviews
and paginate the rest behind a signup. Report how many you actually read.

## Before you start

Infer the subject and whether it is a brand, a category, or a competitor set. Ask only:

- the subject, if not clear
- whether they want the category conversation or their own brand's reception — these
  produce different reports
- the market and language, if not English-speaking

## Collect

Read [titan-tools.md](https://github.com/titannet-dao/webscraping-skills/blob/main/references/titan-tools.md) first for the caps.

**Search where the conversation is.** `titan_search` with `include_domains` pointed at one
community at a time — `["reddit.com"]`, `["news.ycombinator.com"]`,
`["g2.com"]` — is far more precise than an open query, because a bare search returns
marketing pages about the subject rather than discussion of it.

Search the way people complain, not the way vendors describe. Queries that surface real
discussion: "alternatives to X", "X vs Y", "switched from X", "X not working", "is X worth
it", "problems with X", "regret". Run several phrasings; each finds different threads.

Use `freshness` when the question is current sentiment — a 2019 complaint may describe a
product that no longer exists. Baidu, Yandex and Naver drop `freshness`, so for those
filter by thread date after fetching.

**For non-English markets**, search that market's platforms through that market's provider
and in its language — `baidu` for Chinese-language Q&A and forums, `naver` for Korean
community content, `yandex` for Russian. See
[regional-search.md](https://github.com/titannet-dao/webscraping-skills/blob/main/references/regional-search.md).

**Read the threads.** `titan_fetch`, batched up to 100 URLs per call.

- `only_main_content=false` on discussion pages. The replies are frequently outside the
  main content block, and the replies are the research — a thread read as its opening post
  is worthless here.
- Raise `max_chars_per_url` well above the 12,000 default. Long threads truncate, and
  truncation biases you toward whatever the top comments said.
- `include_links=true` picks up threads linking to other threads.

**Follow to saturation, not to a count.** Keep going while new threads add new themes.
Stop when they repeat. If a subject has almost no discussion, that is the finding —
report it as low volume rather than padding with tangential threads.

## Analyse

- **Count, do not just collect.** A theme mentioned once is an anecdote; mentioned in
  fifteen threads it is a pattern. State how many sources support each theme, and never
  present a single loud complaint as a trend.
- **Quote verbatim.** The exact words are the deliverable. Paraphrasing destroys the thing
  the user came for.
- **Date the themes.** Complaints about a version fixed a year ago must be labelled, or the
  report is actively misleading.
- **Separate the vendor's vocabulary from the buyers'.** Put them side by side; that
  contrast is the most directly usable output.
- **Note who is talking.** Practitioners, buyers, and people who never used the product
  are different populations. Where a thread makes it visible, say which.
- **Do not compute a sentiment score.** Communities self-select toward complaint. Report
  themes and their volume, not a number implying a measured population.

## Deliverable

Write `audience-<subject>.md`:

```markdown
# Audience research: <subject>
Run date. Sources searched, markets and languages, threads read, roughly how
recent they are.

## Summary
The themes that repeat, and how strongly supported each is.

## Themes
Per theme: what it is, how many sources mention it, date range, two or three
verbatim quotes with links.

## Complaints and switching triggers
What makes people leave or look elsewhere, ranked by how often it recurs, with
links.

## What they praise
The same treatment. Usually shorter, and more specific than marketing copy.

## Their words vs. the category's words
Two columns: how buyers say it, how vendors say it. The most directly usable
section — draw from it for messaging.

## Unanswered questions
What people keep asking that nobody answers well. Content opportunities.

## By market
Where a market's conversation differs, per market, with provider and language.

## Volume and coverage
Threads read per source, what was gated or paginated away, which platforms were
out of reach, and how confident the themes are given that.

## Rerun inputs
workflow: titan-audience-research
subject: <brand or category>
sources: <domains searched>
markets: <countries and languages>
output: audience-<subject>.md
```

Report roughly what the run consumed and point at
<https://webscraping.titannet.io/usage>.

## Quality bar

- Every theme is backed by a count and at least one linked verbatim quote.
- Say how many threads were read. "Community sentiment" from six threads must say six.
- No sentiment scores, no percentages implying a survey.
- Label the age of the evidence.
- Never present a login wall as an absence of discussion. Name the platform as
  unreachable.
- Quote public discussion; do not build profiles of the individuals posting it.
