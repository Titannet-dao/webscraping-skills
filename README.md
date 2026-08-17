# Titan Web Scraping Skills

**English** | [简体中文](README.zh.md)

Agent skills that turn [Titan Web Scraping](https://webscraping.titannet.io) into finished
work. Ask your agent for a competitor analysis and get `competitors-<category>.md` — sourced,
dated, and re-runnable — instead of a pile of scraped pages.

Titan reads the open web on [Titan Network](https://titannet.io)'s own residential
infrastructure: 900,000+ IPs across 120+ countries, and eight search engines including
**Baidu, Yandex and Naver**. That is why a market map from these skills can show you a
category as it looks from inside China, Russia, or Korea, rather than as the
English-language internet describes it.

Each skill is a plain [Agent Skill](https://agentskills.io/specification) — a folder with a
`SKILL.md` — so the same folder works in Claude Code, Codex, Cursor, Gemini CLI,
Antigravity, and the [other clients](https://agentskills.io/clients) that adopted the
format. There is no per-harness variant to keep in sync.

## What you get

| Skill | Ask for | You get |
| --- | --- | --- |
| **[titan-deep-research](skills/titan-deep-research/SKILL.md)** | a report on a topic no single search answers | `research-<topic>.md` — findings, counter-evidence, every claim sourced |
| **[titan-seo-audit](skills/titan-seo-audit/SKILL.md)** | an SEO audit of a site | `seo-audit-<domain>.md` — issues by page, the exact fix, in priority order |
| **[titan-competitive-intel](skills/titan-competitive-intel/SKILL.md)** | what competitors charge and ship | `competitors-<category>.md` — pricing and feature matrix, diffed on every re-run |
| **[titan-investor-research](skills/titan-investor-research/SKILL.md)** | funding rounds, active funds, co-investors | `investors-<subject>.md` + `funding.csv` — from SEC filings and announcements |
| **[titan-lead-research](skills/titan-lead-research/SKILL.md)** | background before a call | `brief-<company>.md` — one page, with the specific things worth mentioning |
| **[titan-market-landscape](skills/titan-market-landscape/SKILL.md)** | who is in a category, per country | `landscape-<category>.md` — player table plus per-market findings |
| **[titan-audience-research](skills/titan-audience-research/SKILL.md)** | what people say about a brand or category | `audience-<subject>.md` — themes, counts, verbatim quotes, and their words vs. yours |

**[titan-workflows](skills/titan-workflows/SKILL.md)** is the router. If you don't know
which one you want, ask it — or ask it for a web-data job none of the above covers.

Your agent reaches for these on its own once installed. You can also name one directly.

## Requires a Titan connection

These skills call the Titan MCP server. Before installing them:

1. Sign in at [webscraping.titannet.io](https://webscraping.titannet.io) — the free plan
   grants 3,000 credits a month, self-serve, no call required.
2. On **Overview**, copy your MCP key and the setup snippet for your client.
3. Paste it in. Your agent now has `titan_search`, `titan_fetch`, `titan_crawl`, and
   `titan_get_run`.

Full setup instructions per client: [MCP quickstart](https://webscraping.titannet.io/docs/mcp/quickstart).

## Install

### Claude Code

Ships as a plugin, via this repo's own marketplace:

```
/plugin marketplace add titannet-dao/webscraping-skills
/plugin install titan-webscraping-skills@titan-webscraping
```

Or from a shell:

```bash
claude plugin marketplace add titannet-dao/webscraping-skills
claude plugin install titan-webscraping-skills@titan-webscraping
```

Updates arrive with every commit to `main` — run `/plugin marketplace update` to pull them.

### Codex, Cursor, Gemini CLI, Antigravity, and others

Copy the skill folders you want into the directory your harness scans:

| Harness | Project-level | Global |
| --- | --- | --- |
| Codex | `.agents/skills/` | `~/.agents/skills/` |
| Cursor | `.agents/skills/` (or `.cursor/skills/`) | `~/.agents/skills/` (or `~/.cursor/skills/`) |
| Antigravity | `.agents/skills/` | `~/.gemini/config/skills/` |
| Gemini CLI | `.agents/skills/` | — |

`.agents/skills/` is the path they all read, so one copy there covers every harness in the
table.

```bash
git clone https://github.com/titannet-dao/webscraping-skills.git
cd webscraping-skills
cp -R skills/titan-competitive-intel ~/.agents/skills/
```

**Take `references/` with them.** Every skill loads
[references/titan-tools.md](references/titan-tools.md) for the real tool caps and
[references/regional-search.md](references/regional-search.md) for the provider matrix.
Copying the whole repo, or all of `skills/` plus `references/`, is the safe move — a skill
installed without them still runs, but loses the facts that keep it from over-asking the
server.

To share these with a team, commit them to `.agents/skills/` in *their* repo instead — they
then travel with the project and go through code review like any other file.

## What these skills will not do

Named up front, because a skill that promises what the server cannot deliver wastes a run
and your credits:

- **No logged-in sources.** LinkedIn, X, Instagram, TikTok, internal dashboards, and
  paywalled databases such as Crunchbase and PitchBook need authenticated sessions. Titan
  has none. The skills say so and use the open-web equivalent.
- **No JavaScript rendering.** A price drawn in by client-side JS is reported as *not
  readable*, never estimated.
- **No structured extraction from the server.** Titan returns clean markdown; the agent
  parses it into tables and CSVs. No skill promises a shape Titan does not return.
- **No invented numbers.** Market sizes, valuations, and search volumes are cited or
  omitted.

Details in [references/titan-tools.md](references/titan-tools.md).

## Development

```bash
scripts/link-skills.sh   # symlink every skill into each harness directory
scripts/list-skills.sh   # list the skills in this repo
```

`link-skills.sh` links rather than copies, so a `git pull` updates every installed harness
at once. Re-run it after adding or renaming a skill.

Conventions for adding and writing skills are in [AGENTS.md](AGENTS.md) and
[references/skill-authoring.md](references/skill-authoring.md); the harness compatibility
details behind them are in [.agents/harnesses.md](.agents/harnesses.md).

## License

[MIT](LICENSE)
