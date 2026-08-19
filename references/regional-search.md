# Regional search

Use provider and language matching market. Always name provider explicitly; apply
[Titan safe call protocol](titan-tools.md#safe-call-protocol).

| market | provider order | note |
| --- | --- | --- |
| Global / Western | `bing`, `duckduckgo`, `brave`, `yahoo` | ranked by live reliability |
| China | `baidu` | search Chinese; CN proxy when local SERP matters |
| Russia / CIS | `yandex` | search Cyrillic; RU proxy when local SERP matters |
| South Korea | `naver` | search Korean; KR proxy when local SERP matters |
| Japan | `yahoo` | search Japanese; JP proxy when local SERP matters |

For comparison, preserve provider and location beside each finding. Never merge results from
different markets as one undifferentiated list.

## Provider limits

`country` and `language` work on Bing, Brave, and Yahoo. DuckDuckGo needs both together.
Baidu, Yandex, and Naver drop them, along with freshness; filter date after fetching. Yahoo,
Yandex, and Naver drop structured `file_types`, `title_terms`, and `url_terms`; place those
constraints in query text. Confirm response fields and `warnings`.

## Local SERP or page view

Use `titan_run_template` only when question is what user sees **inside** market. Call
`titan_list_templates` first; never hardcode slug. Search template requires provider SERP
URL, e.g. Baidu:

```text
titan_run_template {
  template_slug: "<slug returned by titan_list_templates>",
  urls: ["https://www.baidu.com/s?wd=<url-encoded-query>"],
  payload: { max_results: 10, include_ads: false },
  proxy_locations: ["CN"]
}
```

For localized pages use generic page-extraction template with `proxy_locations`. One
location = one run and one charge. Templates share account-wide rate limits with named tools.
