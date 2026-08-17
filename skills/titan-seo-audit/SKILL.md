---
name: titan-seo-audit
description: Audit a website's SEO through Titan and write a prioritised fix list to a file. Use when the user asks for an SEO audit or SEO evaluation, wants their site structure, titles, meta descriptions, or heading hierarchy reviewed, asks why a page or site is not ranking, wants a keyword or SERP comparison against competitors, or wants to know what to fix first for search. Covers on-page and structural SEO from crawlable HTML.
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

Read [titan-tools.md](../../references/titan-tools.md) first for the caps.

**Map the site.** `titan_crawl` with `mode=map` on the domain. This returns a URL
inventory with no page content, which is exactly what you want first: the shape of the
site before you spend anything reading it.

- Raise `max_depth` above the default of 1 — depth 1 sees only what the homepage links
  to. The cap is 5.
- `max_pages` defaults to 25 and caps at 500. Scope with `include_patterns` /
  `exclude_patterns` rather than raising the cap blindly, and be explicit that an audit
  of 500 pages out of 50,000 is a sample.
- Crawl is **asynchronous by default** — it returns a `run_id`. Collect with
  `titan_get_run`.
- Also fetch `/sitemap.xml` and `/robots.txt` directly. Compare the sitemap against what
  the crawl actually found: URLs in the sitemap that the crawl never reached are orphans,
  and pages the crawl found that the sitemap omits are invisible to search engines that
  trust it.

**Read the pages that matter.** `titan_fetch` on the homepage, the money pages —
product, pricing, category, high-intent landing pages — plus a representative sample of
the long tail. Batch them; the limit is 100 URLs per call.

- `include_links=true`. Internal linking is half of structural SEO and you cannot see it
  otherwise.
- `only_main_content=false` for this workflow. You need the nav, the footer, and the
  boilerplate — that is where site-wide linking and duplicated metadata live.
- Raise `max_chars_per_url` past the 12,000 default on long pages, or thin-content
  findings will be an artifact of truncation rather than the page.

**Compare against the SERP.** `titan_search` each target keyword, then `titan_fetch` the
pages that rank above the site. What those pages do that this site does not is the
audit's most actionable section.

Set `country` and `language` to the market being ranked in. Rankings are local, and an
audit run from the wrong locale describes a SERP the user's customers never see. Note the
per-provider support table in
[regional-search.md](../../references/regional-search.md) — and if the site targets
China, Russia, or Korea, audit against Baidu, Yandex, or Naver rather than Google.

### What Titan can and cannot see

Say this in the report rather than letting the reader assume otherwise.

**Can**: titles, meta descriptions, heading hierarchy, body content and its depth,
internal and outbound links, image alt text, canonical and hreflang tags when present in
the HTML, structured-data blocks in the markup, sitemap and robots contents, indexable
URL structure.

**Cannot**: Core Web Vitals or any timing metric, rendered output of client-side
JavaScript, server response headers and redirect chains, actual crawl-budget behaviour,
search volume, difficulty scores, or backlink profiles. Those need Search Console, a
Lighthouse run, or a backlink tool. Do not estimate them.

## Parallel work

If sub-agents are available, split by dimension after the crawl completes — structure,
on-page, keyword and SERP, technical signals — each returning findings as `page`,
`issue`, `evidence`, `fix`, `impact`. One writer merges and orders them, so severity is
judged consistently across dimensions instead of four times over.

## Analyse

For every issue: the URL, what is wrong, the evidence from the page, the exact change,
and the expected impact. "Improve your meta descriptions" is not a finding. "17 pages
share the description on line 3 of `/products/*`; write per-product descriptions, here
are the three highest-traffic ones" is.

Judge impact by what the page is for. A missing H1 on a pricing page matters more than
one on a 2019 blog post.

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
Per-page table: URL, title, meta description, H1/H2 hierarchy, word count,
internal links in/out, alt-text coverage, issues.

## Keywords and SERP
Target keywords, who ranks above this site, what those pages do differently,
where the content gaps are. Provider and locale stated.

## Technical signals
Canonicals, hreflang, robots, structured data — from the HTML.

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
output: seo-audit-<domain>.md
```

Report roughly what the run consumed and point at
<https://webscraping.titannet.io/usage>.

## Quality bar

- Every issue names a URL and a change. No generic advice.
- Say how much of the site was audited. A 25-page crawl of a large site is a sample and
  must be labelled one.
- Never report a metric Titan cannot measure. If the user needs Core Web Vitals, tell
  them where to get them.
- Check `warnings` on every call. A dropped search refinement means the SERP comparison
  is not the comparison you asked for.
