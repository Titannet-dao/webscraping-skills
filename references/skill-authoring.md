# Skill authoring

Rules for adding or reviewing a skill in this repo. They exist because the failure modes
below have a cost: a skill that over-promises produces a confident report built on a
login wall, and the user has no way to tell.

## The shape

Every skill is one folder under `skills/`, holding a `SKILL.md` and an
`agents/openai.yaml`. Keep `SKILL.md` short — under ~200 lines. It loads in full the
moment the skill activates, so shared facts belong in `references/`, not in seven copies.

Standard sections, in this order:

1. **What this produces** — the named deliverable, in the first paragraph.
2. **Before you start** — the blocking questions, and nothing else.
3. **Collect** — which Titan tools, in what order, with what parameters.
4. **Analyse / Build** — how raw markdown becomes the deliverable.
5. **Deliverable** — the literal output template.
6. **Quality bar** — what makes the output wrong.

## Promise only what Titan returns

Read [titan-tools.md](titan-tools.md) before writing a collection plan. The three
capabilities are search, fetch, and crawl; there is no structured extraction, no
authenticated session, and no browser.

So:

- **The agent does the extraction.** Titan returns markdown. If the deliverable is a
  table or a CSV, the skill must say that the agent parses it out of the markdown, and
  must not imply the server returns records.
- **Name what is unreachable, up front.** If a user would reasonably expect a skill to
  read LinkedIn, or Crunchbase, or a dashboard behind a login, the skill says it cannot
  and names the open-web substitute. Discovering it mid-run wastes the run and the
  credits.
- **No invented sources.** Every claim in a deliverable carries the URL it came from.

## Let the agent judge evidence, bound cost

Do not write depth tiers, page budgets, or query counts into a skill. How much evidence a
question needs is not knowable in advance, and a number written here becomes either a
ceiling on a hard question or a floor on an easy one. State what *good enough* looks like
— coverage, corroboration, recency — and let the agent work until it gets there.

Add a **credit ceiling** beside the epistemic stopping rule. Collection is metered and an
agent cannot reliably reconcile final spend. State a modest default budget, let user raise
it, and tell report to list records delivered rather than guess charges. Server caps and
call safety live in [titan-tools.md](titan-tools.md).

## Onboarding stays short

Infer from the user's message, their files, and the URLs they gave you. If you can safely
start, start. Ask at most 1–3 questions, and only where a missing answer would change the
work — the target, or the deliverable shape. Pick defaults for everything else and name
them in one line.

## Write a file, not a chat message

Every deliverable is a file the user still has tomorrow: `research-<topic>.md`,
`seo-audit.md`, `competitors.md`. Say the filename in the skill. Summarise in chat, but
the artifact is the point.

Use one slug rule: lowercase input, replace each run of non-alphanumeric characters with
one hyphen, then trim edge hyphens. Example: `EU AI Act / GPAI` becomes
`eu-ai-act-gpai`. Rerun inputs must record exact URLs and per-batch content settings.

## Stay portable

One `SKILL.md` serves Claude Code, Codex, Cursor, Gemini CLI, and Antigravity. So:

- Name Titan's MCP tools (`titan_search`, `titan_fetch`, `titan_crawl`,
  `titan_get_run`) — they are the same in every harness.
- Do not name harness-specific functions, sub-agent APIs, or UI affordances. Write "ask
  the user", "use sub-agents if available", "run independent page research in parallel".
- Do not assume a writable path outside the user's working directory.

## Language

Skill bodies are English. The **deliverable** follows the language the user is writing
in — if they ask in Chinese, the report is in Chinese, and the sources stay in their
original language with the URL intact. Say this once in the skill rather than translating
the skill.

## Adding a skill

1. `skills/<name>/SKILL.md`. Frontmatter `name` must equal the folder name, lowercase
   `a-z0-9-`. Prefix with `titan-`.
2. Write the `description` trigger-rich — it is what the model reads to decide whether to
   reach for this skill. Say both what it does and when to use it, and where a
   neighbouring skill is the better fit, say that too.
3. `skills/<name>/agents/openai.yaml` with `interface.display_name` and
   `interface.short_description`.
4. Add a line to [../skills/README.md](../skills/README.md), the skill list in
   [../README.md](../README.md) and [../README.zh.md](../README.zh.md), and the
   catalogue on the `/skills` page in the `titan-webscraping` frontend.
5. Validate, then check what an installer actually sees:
   ```bash
   npx skills-ref validate ./skills/<name>
   claude plugin validate .
   npx skills add titannet-dao/webscraping-skills -l
   scripts/link-skills.sh
   ```
   `claude plugin validate` warning about a missing `version` is expected — see
   [../AGENTS.md](../AGENTS.md#versioning).
6. Run it against the live MCP server before shipping. A skill that has never completed
   once is a draft.
