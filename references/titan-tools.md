# Titan tools

Use this measured operating contract before any Titan run. It reflects live runs on
2026-08-18. Server responses win if they differ.

## Connection and cost

Titan MCP: `https://mcp.webscraping.titannet.io/mcp`. If Titan tools are unavailable,
ask user to connect an API key at <https://webscraping.titannet.io/overview>. Do not
substitute another scraper and call it Titan run.

Plan before calling: search costs 1 credit per run, fetch about 1 per URL delivered, and
crawl about 1 per page returned. Template run costs like equivalent tool; each proxy
location is separate run. These are planning units, not exact account balance.

Set credit ceiling before collection. `credits_estimated` is pending work, not spend;
async results may expose no credit total. Report URLs/pages delivered and ceiling used,
not guessed final charge.

## Safe call protocol

All work may be synchronous **or** asynchronous, depending on backend load. After every
`titan_search`, `titan_fetch`, `titan_crawl`, or `titan_run_template` call:

1. If response has `status: running` or `queued` and `run_id`, poll `titan_get_run`.
2. If results arrive directly, use `pages` for synchronous fetch responses; use `results`
   for data returned by `titan_get_run`.
3. On `provider_rate_limited`, inspect `run_id`. If present, poll it — work may be live and
   billable. Never re-issue identical request.
4. If no live run exists, wait minutes, not seconds, before one retry. Limits are shared per
   account; provider rotation and parallel agents do not create more capacity.
5. Read `code`, `retryable`, `run_id`, `status`, `status_reason`, and `warnings`. `warnings`
   can be empty or absent when call fails.

`titan_get_run` is free. Use `titan_list_templates` as free health check: available while
other work may be rate-limited.

## `titan_search` — find URLs

Returns titles, URLs, and snippets only. Fetch pages before treating them as evidence.

Always pass `search_provider`; no provider is safe as implicit default. For Western
searches try `bing`, then `duckduckgo`, then `brave`, then `yahoo`; move down only after a
real failure and shared-rate-limit wait. See [regional-search.md](regional-search.md) for
regional providers.

```text
titan_search {
  query: "<query in market language>",
  search_provider: "bing",
  max_results: 10,
  freshness: "month" // only when recency matters
}
```

`max_results` defaults to 10 and caps at 100. `country`, `language`, and refinements vary
by provider; verify applied settings in response fields and `warnings`.

## `titan_fetch` — read pages

Start with batches of **5–10 URLs**, never 100. Batch delivery is all-or-nothing: one slow
URL can hold every result. Probe unknown or often-blocked domains separately.

Useful inputs: `format: markdown`, `only_main_content`, `include_links`,
`max_chars_per_url` (default 12,000; cap 100,000), and `freshness` (`cache_ok`,
`prefer_live`, `live_only`). Use `only_main_content=false` for pricing, changelogs, release
notes, and discussion pages.

Validate each record before using it. Reject a `403`/`429`/`503`, empty body, soft-404
redirect, JS shell, or content under roughly 1,000 characters. For short page expected to
contain real content, retry once with `only_main_content=false`. `failed[]` is not billing
or validity signal; blocked records can be returned and billed normally.

## `titan_crawl` — map one site

`mode=map` inventories URLs; `mode=crawl` extracts content. Same-origin only. It may return
`run_id`, so apply safe call protocol.

| input | default | cap |
| --- | --- | --- |
| `max_pages` | 25 | 500 |
| `max_depth` | 1 | 5 |
| `content_max_chars` | 8,000 | 100,000 |

`max_pages` binds before `max_depth`: depth does nothing if page budget ends at shallower
level. Set both to fit credit ceiling; scope with include/exclude patterns first.

## Templates and regional runs

Call `titan_list_templates` before `titan_run_template`; slugs vary by deployment. Search
templates require pre-built provider SERP URL in `urls`, not query. They accept `payload`
such as `max_results` and `include_ads`; use `proxy_locations` for geographic search or
fetch. They add location, not rate-limit capacity.

## Limits

Titan has no authenticated sessions, browser interaction, JS rendering, structured output,
or cross-origin crawling. It returns markdown; agent extracts tables and fields. Do not
claim access to content behind login, only client-rendered content, or HTML metadata Titan
does not return.
