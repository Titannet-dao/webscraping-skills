# Regional search

Titan runs on Titan Network's own residential infrastructure — 900,000+ IPs across 120+
countries — and exposes eight search providers rather than one. That combination is what
lets a workflow answer questions a single-provider tool cannot: what a market looks like
*from inside it*.

Read this when the question has a country in it.

## Pick the provider by market, not by habit

Defaulting to Google hides whole markets. In China, Russia, Korea and Japan, Google is
not where the market's own answers live.

| market | provider | why |
| --- | --- | --- |
| Global / Western | `google`, `bing`, `brave`, `duckduckgo` | broadest coverage |
| China | `baidu` | dominant; surfaces Chinese-language sources Google never returns |
| Russia / CIS | `yandex` | dominant; better Cyrillic coverage |
| South Korea | `naver` | dominant; Korean portals, blogs, and community content |
| Japan | `yahoo` | Yahoo! Japan holds share Google does not |

Run the *same query in two providers* when the point is comparison. Two result sets from
Google and Baidu for one product category is a finding in itself: different players,
different pricing, different positioning.

Query in the market's language, not in English translated. A Baidu search in English
returns the expatriate view of a Chinese market.

## What each provider actually honours

`titan_search` compiles your refinements into provider-specific query syntax. Providers
that cannot express a refinement have it **dropped**, and the drop is reported in
`warnings` — never assumed to have applied.

| provider | `include_domains` / `exclude_domains` | `file_types`, `title_terms`, `url_terms` | `country` | `language` | `freshness` |
| --- | --- | --- | --- | --- | --- |
| `google` | yes | yes | yes | yes | yes |
| `bing` | yes | yes | yes | yes | yes |
| `brave` | yes | yes | yes | yes | yes |
| `duckduckgo` | yes | yes | **both required** | **both required** | yes |
| `yahoo` | yes | **dropped** | yes | yes | yes |
| `baidu` | yes | yes | **dropped** | **dropped** | **dropped** |
| `yandex` | yes | **dropped** | **dropped** | **dropped** | **dropped** |
| `naver` | yes (`site:` only) | **dropped** | **dropped** | **dropped** | **dropped** |

Consequences worth planning around:

- DuckDuckGo encodes locale as one region code, so `country` and `language` must be
  passed **together** or both are dropped.
- Baidu, Yandex and Naver serve their own locale and offer no usable recency parameter.
  To bound a Baidu result set by time, filter by date after fetching rather than asking
  the provider.
- On Yahoo, Yandex and Naver, `file_types` / `title_terms` / `url_terms` never apply.
  Put the constraint in the query text instead, and expect looser results.

## Fetching from a specific country

`titan_fetch` has no country parameter. When a page's *content* varies by visitor
location — localized pricing, regional catalogues, country-gated availability — the
geography goes through `titan_run_template` with `proxy_locations`:

1. Call `titan_list_templates` and take the generic page-extraction template's slug.
   Never hardcode it; slugs are configurable per deployment.
2. Call `titan_run_template` with that slug, the `urls`, and
   `proxy_locations: ["US", "DE", "JP"]`.

Fetch the same URL from two or three locations and compare. A price that differs, a
product that disappears, or a redirect to a different domain is the answer to a question
plain fetching cannot ask.

Use it deliberately — one location per question, not a sweep of every country in the
pool. Each location is a separate run and separate credits.

## Saying it in the deliverable

Regional evidence is only useful if the reader knows it is regional. Record which
provider and which location produced each finding, and never merge a Baidu result set
and a Google result set into one undifferentiated list — the difference between them is
usually the insight.
