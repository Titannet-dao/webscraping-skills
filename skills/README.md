# Skills

One folder per skill, each a self-contained [Agent Skill](https://agentskills.io/specification).

All of them are model-invoked: your agent reaches for them on its own, and you can also
ask for one by name.

## Start here

- **[titan-workflows](./titan-workflows/SKILL.md)** — the router. Picks the right workflow
  below, and handles web-data jobs none of them covers. Ask it "what can Titan do for me?"

## The workflows

- **[titan-deep-research](./titan-deep-research/SKILL.md)** — a cited report on a question
  no single search answers. → `research-<topic>.md`
- **[titan-seo-audit](./titan-seo-audit/SKILL.md)** — site structure, on-page SEO, and a
  SERP comparison against whoever outranks you. → `seo-audit-<domain>.md`
- **[titan-competitive-intel](./titan-competitive-intel/SKILL.md)** — competitor pricing,
  features, positioning and releases, built to be re-run and diffed. →
  `competitors-<category>.md`
- **[titan-investor-research](./titan-investor-research/SKILL.md)** — funding rounds, funds
  actively deploying, portfolios, and the shared-investor graph, from SEC filings and
  announcements. → `investors-<subject>.md`, `funding.csv`
- **[titan-lead-research](./titan-lead-research/SKILL.md)** — a one-page brief on a company
  or person before a meeting. → `brief-<company>.md`
- **[titan-market-landscape](./titan-market-landscape/SKILL.md)** — who is in a category
  and how it changes by country. Uses Titan's regional search engines hardest. →
  `landscape-<category>.md`
- **[titan-audience-research](./titan-audience-research/SKILL.md)** — what people publicly
  say, from communities and review sites, and the words they use. →
  `audience-<subject>.md`

## Shared references

Skills load these on demand rather than restating them:

- [../references/titan-tools.md](../references/titan-tools.md) — the tool contract: real
  caps, defaults, and what Titan cannot do.
- [../references/regional-search.md](../references/regional-search.md) — which search
  provider for which market, what each one honours, and fetching from a chosen country.
- [../references/skill-authoring.md](../references/skill-authoring.md) — the rules for
  adding one.
