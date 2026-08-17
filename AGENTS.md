# Working in this repo

A collection of agent skills that drive the **Titan Web Scraping MCP server**. The skills
*are* the product — there is no application code here.

## Layout

```
skills/<skill-name>/          canonical source; one folder per skill
  SKILL.md                    required: frontmatter + instructions
  agents/openai.yaml          Codex picker metadata
references/                   shared docs, loaded on demand by skills
  titan-tools.md              the tool contract: caps, defaults, what Titan cannot do
  regional-search.md          providers by market, per-provider support, proxy locations
  skill-authoring.md          rules for adding or reviewing a skill
.claude-plugin/               Claude Code plugin + marketplace manifests
.codex-plugin/                Codex plugin manifest
.cursor-plugin/               Cursor plugin manifest
.agents/harnesses.md          how each harness discovers and reads skills
scripts/                      dev-only install/list helpers
```

`skills/` is flat. Bucket folders are only worth adding once the flat list is hard to
scan; adding them early means inventing categories before knowing what they are.

## One canonical copy

Each skill exists **once**, in `skills/<skill-name>/`. Claude Code, Codex, Cursor, Gemini
CLI and Antigravity all read the same `SKILL.md`; they differ only in which directory they
scan. `scripts/link-skills.sh` symlinks each skill into every one of those directories, so
a `git pull` updates every harness at once.

Never copy a skill's content to make it work in another harness. If a harness needs
something extra it goes in a sidecar next to `SKILL.md`, as Codex's `agents/openai.yaml`
does. See [.agents/harnesses.md](.agents/harnesses.md) for discovery paths, the full
frontmatter spec, and the invocation rules.

## Facts about Titan live in one place

The tool caps, defaults, and limitations are in
[references/titan-tools.md](references/titan-tools.md); the provider support matrix is in
[references/regional-search.md](references/regional-search.md). A skill **links** to
those, and does not restate them.

This is the rule that matters most here. Eight skills each carrying their own copy of
"max 100 URLs per fetch" is eight numbers that will disagree after the first backend
change, and a wrong cap in a skill misinforms the model directly rather than failing
loudly.

Those two files are derived from the MCP service's own source — `internal/bounds`,
`internal/tools`, and `internal/searchquery` in `webscraping-backend`. When the backend
changes a cap, a default, or a provider's behaviour, update them there and nowhere else.
Do not edit them from memory.

**Skills link to them by absolute URL, never by relative path.** `npx skills add` installs
a skill as a lone folder under `.agents/skills/<name>/` and does **not** carry `references/`
with it — verified against the live repo — so `../../references/titan-tools.md` resolves in
this checkout and is a dead link in every install. The absolute
`https://github.com/titannet-dao/webscraping-skills/blob/main/references/…` form works in
both places.

Sibling *skill* links stay relative (`../titan-seo-audit/SKILL.md`). Installed skills are
siblings under `.agents/skills/`, so those do resolve.

## Adding a skill

Read [references/skill-authoring.md](references/skill-authoring.md) — it holds the
authoring rules. The mechanical steps:

1. Create `skills/<skill-name>/SKILL.md`. Frontmatter `name` must equal the folder name,
   lowercase `a-z0-9-`, prefixed `titan-`.
2. Write the `description` trigger-rich — it is what the model reads to decide whether to
   reach for the skill. Say what it does, when to use it, and which neighbouring skill is
   the better fit otherwise.
3. Add `skills/<skill-name>/agents/openai.yaml` with `interface.display_name` and
   `interface.short_description`.
4. Add a line to [skills/README.md](skills/README.md), to the skill lists in
   [README.md](README.md) and [README.zh.md](README.zh.md), and to the catalogue behind
   the `/skills` page in the `titan-webscraping` frontend.
5. Validate, then check what an installer actually sees:
   ```bash
   npx skills-ref validate ./skills/<skill-name>              # frontmatter + naming rules
   claude plugin validate .                                   # the .claude-plugin manifests
   npx skills add titannet-dao/webscraping-skills -l          # what the CLI lists
   scripts/link-skills.sh                                     # (re)link into every harness
   ```
   One expected complaint: `claude plugin validate` warns that no `version` is set. That
   is intentional — see [Versioning](#versioning). Don't pass `--strict`, which promotes
   it to an error.
6. **Run it against the live MCP server before shipping.** A skill nobody has completed
   once is a draft.

Neither manifest in `.claude-plugin/` lists individual skills — Claude Code
auto-discovers everything under `skills/`. Adding a skill means touching the READMEs, not
the JSON.

### Watch for colons in `description`

A `description` is a plain YAML scalar, so `... only: LinkedIn ...` parses as a mapping
and the skill fails to load. Use an em dash instead. `npx skills-ref validate` catches it.

## Writing the skill body

Keep `SKILL.md` under ~200 lines. It loads in full the moment the skill activates, so
anything long, optional, or reference-shaped belongs in `references/` and is pulled in
only when needed.

Link the shared references by absolute URL, per the rule above. Depend on
another skill by naming it in prose, not by reaching into its folder, so each skill stays
installable on its own.

## Versioning

`.claude-plugin/plugin.json` deliberately has **no** `version` field. Claude Code then
falls back to the git commit SHA, so installed users pick up every commit. Adding a
`version` flips that: users receive nothing until it is bumped, and forgetting to bump it
silently strands them. Only add one alongside a real release process.
