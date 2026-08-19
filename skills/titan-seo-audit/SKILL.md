---
name: titan-seo-audit
description: Audit website SEO through Titan and write prioritised fix list to file. Use when user asks for SEO audit/evaluation, site structure, titles, meta descriptions, crawlable content, SERP comparison, or what to fix first for search. Covers only signals Titan can reliably read.
license: MIT
metadata:
  author: titannet-dao
  homepage: https://webscraping.titannet.io
  source: https://github.com/titannet-dao/webscraping-skills
---

# Titan SEO audit

Produces `seo-audit-<domain>.md`: every issue found, the page it is on, the exact change
to make, and the order to make them in.

The value is in the ordering. A list of 200 undifferentiated issues is not an audit —
the deliverable has to say what to do on Monday.

## Before you start

Infer the site from what the user gave you. If you have a domain, start.

Ask only:

- the site, if not given
- target keywords, if the user has ones they care about — otherwise infer them from the
  site's own copy and say you did
- the competitors to compare against, if they have a specific set in mind — otherwise
  take whoever ranks for the target keywords

## Collect

Read [titan-tools.md](https://github.com/titannet-dao/webscraping-skills/blob/main/references/titan-tools.md) first for the caps.

**Map the site.** `titan_crawl` with `mode=map` on the domain. This returns a URL
inventory with no page content, which is exactly what you want first: the shape of the
site before you spend anything reading it.

- Set `max_pages` and `max_depth` together. Page limit binds first, so depth 3 has no value
  when depth 1 consumes page budget. Scope with `include_patterns` / `exclude_patterns`.
- Default crawl budget: 15 pages / 15 credits. Raise only with user-approved ceiling; audit
  of part of large site is sample.
- Apply `titan_get_run` after every call returning `run_id`.
- Also fetch `/sitemap.xml` and `/robots.txt` directly. Compare the sitemap against what
  the crawl actually found: URLs in the sitemap that the crawl never reached are orphans,
  and pages the crawl found that the sitemap omits are invisible to search engines that
  trust it.

**Read the pages that matter.** `titan_fetch` on the homepage, the money pages —
product, pricing, category, high-intent landing pages — plus a representative sample of
the long tail. Batch 5–10 URLs per call.

- `include_links=true`. Internal linking is half of structural SEO and you cannot see it
  otherwise.
- `only_main_content=false` for this workflow. You need the nav, the footer, and the
  boilerplate — that is where site-wide linking and duplicated metadata live.
- Raise `max_chars_per_url` past the 12,000 default on long pages, or thin-content
  findings will be an artifact of truncation rather than the page.

**Compare against SERP.** `titan_search` each target keyword with
`search_provider: "bing"` and `max_results: 10`, then `titan_fetch` the
pages that rank above the site. What those pages do that this site does not is the
audit's most actionable section.

Set `country` and `language` to the market being ranked in. Rankings are local, and an
audit run from the wrong locale describes a SERP the user's customers never see. Note the
per-provider support table in
[regional-search.md](https://github.com/titannet-dao/webscraping-skills/blob/main/references/regional-search.md) — and if the site targets
China, Russia, or Korea, audit against Baidu, Yandex, or Naver rather than Google.
Fetch in 5–10 URL batches. Never re-issue rate-limited request carrying `run_id`.

### What Titan can and cannot see

Say this in the report rather than letting the reader assume otherwise.

**Can**: crawlable body content, links returned in fetched content, sitemap and robots
contents, and URL structure. Titles and descriptions only when returned in record metadata.
Heading extraction is unreliable and cannot support missing-H1/H2 findings.

**Cannot**: canonical, hreflang, structured data, reliable heading hierarchy, Core Web
Vitals, rendered JS output, server headers/redirect chains, crawl-budget behaviour, search
volume, difficulty scores, or backlink profiles. These need other tools. Do not estimate.

## Pace work

Use one active Titan call per API key. Parallel agents share quota. Default full-workflow
ceiling: 30 credits; stop when ceiling ends and label remaining coverage gap.

## Analyse

For every issue: the URL, what is wrong, the evidence from the page, the exact change,
and the expected impact. "Improve your meta descriptions" is not a finding. "17 pages
share the description on line 3 of `/products/*`; write per-product descriptions, here
are the three highest-traffic ones" is.

Judge impact by what page is for. Do not create heading findings from Titan output.

Keep technical findings separate from content strategy. The first are facts from the
markup; the second are your recommendations. Labelling them the same way is how audits
lose credibility.

## Deliverable

Write `seo-audit-<domain>.md`:

```markdown
# SEO audit: <site>

## Summary
The biggest problems, and what to do first.

## Fix first
Ordered. Each: page, issue, exact change, why it ranks here.

## Site structure
Pages found, URL patterns, depth, orphans, sitemap vs. crawl disagreements,
internal-linking notes.

## On-page
Per-page table: URL, available title/description metadata, content length, returned links,
issues. Mark unavailable fields as unavailable.

## Keywords and SERP
Target keywords, who ranks above this site, what those pages do differently,
where the content gaps are. Provider and locale stated.

## Technical signals
Robots.txt and sitemap contents. List signals not measurable by Titan as not checked.

## Not covered
Coverage of the crawl (pages audited out of pages found), and the checks this audit
cannot make: performance metrics, JS-rendered content, redirect chains, backlinks,
search volume.

## Rerun inputs
workflow: titan-seo-audit
site: <domain>
keywords: <list>
provider: <provider>
country: <country>
urls_read: <exact URL list>
content_settings: <per-batch only_main_content values>
output: seo-audit-<domain>.md
```

Report pages/records delivered, blocked records, and credit ceiling used.

## Quality bar

- Every issue names a URL and a change. No generic advice.
- Say how much of the site was audited. A 25-page crawl of a large site is a sample and
  must be labelled one.
- Never report a metric Titan cannot measure. If the user needs Core Web Vitals, tell
  them where to get them.
- Check response status, code, run ID, applied settings, and warnings. A dropped search
  refinement means SERP comparison is not comparison requested.
