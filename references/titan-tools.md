# Titan tools

The contract every skill in this repo depends on. Read this before deciding how to
collect evidence; the caps and defaults below are what the server actually enforces,
not guidance.

Values here are taken from the MCP service's own bounds and handlers. If a number here
disagrees with what the server tells you in `warnings`, the server is right — say so in
the deliverable rather than retrying blind.

## Connection

MCP server: `https://mcp.webscraping.titannet.io/mcp`, authenticated with a Titan API
key as a bearer token. If the tools below are not available in the session, the user has
not connected their client yet — send them to <https://webscraping.titannet.io/overview>
for the key and the per-client setup snippet, and stop. Do not fall back to a generic web
fetch and present the result as a Titan run.

Consumption is metered in credits. The free plan grants 3,000 per month.

## The three capabilities

Titan does three things. Everything in this repo is built out of them.

### `titan_search` — find URLs

Returns **metadata only**: title, URL, snippet. No page content. Always follow it with
`titan_fetch` for the pages you actually want to read.

| input | default | notes |
| --- | --- | --- |
| `query` | required | |
| `max_results` | 10 | cap 100 |
| `search_provider` | `google` | one of `google` `bing` `yahoo` `brave` `duckduckgo` `baidu` `yandex` `naver`. No auto-fallback — if a provider fails, choose another explicitly |
| `country`, `language` | — | support varies by provider, see [regional-search.md](regional-search.md) |
| `freshness` | — | `any` `day` `week` `month` `year`. Not the same vocabulary as fetch's `freshness` |
| `include_domains`, `exclude_domains` | — | compiled to `site:` / `-site:`, supported everywhere |
| `file_types`, `title_terms`, `url_terms` | — | compiled to `filetype:` / `intitle:` / `inurl:`; **dropped on yahoo, yandex, naver** |
| `operator_mode` | `raw_and_structured` | `raw` sends the query untouched; `structured` sends only the compiled operators |

Runs synchronously by default and returns results in the response.

### `titan_fetch` — read pages

| input | default | notes |
| --- | --- | --- |
| `urls` | required | up to **100 per call**. Batch rather than looping one at a time |
| `format` | `markdown` | or `text` |
| `only_main_content` | — | strips nav, footers, and boilerplate |
| `include_links`, `include_image_links` | — | needed when the next step depends on outbound links |
| `max_chars_per_url` | 12,000 | cap 100,000. Raise it for long pages, or the tail is silently missing |
| `freshness` | `cache_ok` | `cache_ok` \| `prefer_live` \| `live_only`. Use `live_only` when the value being read changes — prices, stock, changelogs |

Runs synchronously by default. URLs that fail come back in `failed[]` and **do not consume
credits** — a partial result is normal, not an error to retry wholesale.

Unsafe URLs (private IPs, localhost, non-http schemes) are rejected.

### `titan_crawl` — walk a site

Same-origin only. Two modes:

- `mode=map` (default) — URL inventory, no page content. This is how you learn a site's
  shape before choosing what to read.
- `mode=crawl` — pages with content extracted.

| input | default | cap |
| --- | --- | --- |
| `max_pages` | 25 | 500 |
| `max_depth` | 1 | 5 |
| `content_max_chars` | 8,000 | 100,000 |
| `include_patterns`, `exclude_patterns` | — | scope the walk instead of raising `max_pages` |
| `respect_robots_txt` | — | |

**Asynchronous by default** — it returns a `run_id`, not results. Collect them with
`titan_get_run`. `wait_for_completion=true` works only for short runs; the synchronous
wait is capped at 30 seconds.

Values above a cap are accepted, clamped, and the applied value is reported in
`warnings`.

### `titan_get_run` — collect an async run

`run_id` from a previous call, plus `limit` (default 100, max 1,000) and `offset` to
page through results. Poll it after any call that returned `status=running` or
`status=queued`.

## Always read `warnings`

Every response carries a `warnings` array, and it is the only place the server tells you
it did something other than what you asked: an operator dropped because the provider does
not support it, a `max_pages` clamped to the cap, a locale ignored. A skill that ignores
`warnings` will report a filtered result that was never filtered.

When a warning changes what the evidence covers, say so in the deliverable.

## What Titan does not do

Design around these rather than discovering them mid-run.

- **No structured extraction.** There is no schema parameter and no JSON records
  capability. Titan returns clean markdown; turning it into a table, a CSV, or typed
  fields is your job as the agent. Never promise the user a shape Titan does not return.
- **No authenticated sessions and no browser actions.** No logging in, no clicking, no
  form filling. Anything behind a login wall is out of reach: LinkedIn, X, Instagram,
  TikTok, internal dashboards, paywalled databases such as Crunchbase and PitchBook.
  When a user asks for one of those, say what is unreachable and offer the open-web
  equivalent instead of returning a page of login HTML as if it were data.
- **No cross-origin crawl.** `titan_crawl` stays on one origin. A multi-domain sweep is
  several crawls, or search plus fetch.
- **No paper index.** Academic work goes through ordinary search against publisher and
  preprint sites.

## Templates

`titan_list_templates` and `titan_run_template` exist, and the templates behind them are
the same implementations that `titan_search`, `titan_fetch`, and `titan_crawl` already
use. Prefer the three named tools.

The one thing `titan_run_template` adds is `proxy_locations` — see
[regional-search.md](regional-search.md).

Template slugs are configurable per deployment. **Never hardcode a slug**: call
`titan_list_templates` and use what it returns.

## Report what the run cost

Search, fetch, crawl, and template responses carry a `usage` object. When a workflow
finishes, tell the user roughly what it consumed and where to see the detail
(<https://webscraping.titannet.io/usage>). Someone on 3,000 free credits a month should
never have to discover the cost of a run afterwards.
