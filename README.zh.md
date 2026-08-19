# Titan 网页采集技能集

[English](README.md) | **简体中文**

一套让 [Titan Web Scraping](https://webscraping.titannet.io) 直接产出成品的 Agent 技能。
让你的 AI 助手做一次竞品分析，得到的是 `competitors-<category>.md`——每条结论都带来源、
带日期、可重复运行——而不是一堆抓取下来的网页。

Titan 运行在 [Titan Network](https://titannet.io) 自有的住宅网络基础设施上：覆盖 120 多个
国家的 90 万+ 住宅 IP，以及包括 **百度、Yandex、Naver** 在内的八个搜索引擎。所以这套技能
做出的市场地图，能呈现一个品类**在中国、俄罗斯或韩国市场内部**真实的样子，而不是英文互联网
对它的描述。

每个技能都是一个标准的 [Agent Skill](https://agentskills.io/specification)——一个含
`SKILL.md` 的文件夹——同一份文件夹在 Claude Code、Codex、Cursor、Gemini CLI、Antigravity
以及[其他采用该格式的客户端](https://agentskills.io/clients)中都能直接使用，无需为每个
客户端维护一份副本。

## 你会得到什么

| 技能 | 你要求的 | 你得到的 |
| --- | --- | --- |
| **[titan-deep-research](skills/titan-deep-research/SKILL.md)** | 一次搜索答不出来的课题报告 | `research-<topic>.md`——结论、反面证据，每条主张都附来源 |
| **[titan-seo-audit](skills/titan-seo-audit/SKILL.md)** | 网站 SEO 审计 | `seo-audit-<domain>.md`——按页面列出问题、给出确切改法，并排好优先级 |
| **[titan-competitive-intel](skills/titan-competitive-intel/SKILL.md)** | 竞品的定价与新功能 | `competitors-<category>.md`——定价与功能对照表，每次重跑自动对比变化 |
| **[titan-lead-research](skills/titan-lead-research/SKILL.md)** | 开会前的背景资料 | `brief-<company>.md`——一页纸，含值得在会上提起的具体细节 |
| **[titan-audience-research](skills/titan-audience-research/SKILL.md)** | 用户公开是怎么评价的 | `audience-<subject>.md`——主题、出现次数、原文引用，以及"用户的说法 vs 你的说法" |

**[titan-workflows](skills/titan-workflows/SKILL.md)** 是入口路由。不确定该用哪个，就问
它——上面没覆盖的网页数据任务也可以交给它。

装好之后，AI 助手会自己判断何时调用这些技能；你也可以直接点名某一个。

## 需要先连接 Titan

这些技能调用的是 Titan MCP 服务器。安装之前：

1. 在 [webscraping.titannet.io](https://webscraping.titannet.io) 注册登录——免费额度每月
   3,000 credits，自助开通，无需联系销售。
2. 在 **Overview** 页面复制你的 MCP key 和对应客户端的配置片段。
3. 粘贴进去。你的 AI 助手就拥有了 `titan_search`、`titan_fetch`、`titan_crawl` 和
   `titan_get_run`。

各客户端的完整配置说明见
[MCP 快速开始](https://webscraping.titannet.io/docs/mcp/quickstart)。

## 安装

一条命令，无论你用哪个 AI 助手：

```bash
npx skills add titannet-dao/webscraping-skills
```

它会写入 `.agents/skills/`——Codex、Cursor、Gemini CLI、Antigravity 以及十几个客户端都读取
这个目录——并同时为 Claude Code 建立软链接。加 `-g` 可以装到全局而不是当前项目。

只装其中一个技能：

```bash
npx skills add titannet-dao/webscraping-skills --skill titan-competitive-intel
```

只想看看里面都有什么、暂不安装：

```bash
npx skills add titannet-dao/webscraping-skills -l
```

之后用 `npx skills update` 拉取更新，用 `npx skills remove` 卸载。该 CLI 来自
[vercel-labs/skills](https://github.com/vercel-labs/skills)。

要和团队共享，就把安装好的文件夹提交到**他们仓库**的 `.agents/skills/` 里——这样它随项目
一起流转，并像其他文件一样走代码评审。

### Claude Code 插件

本仓库同时也是一个 Claude Code 插件 marketplace，如果你更习惯这样管理：

```
/plugin marketplace add titannet-dao/webscraping-skills
/plugin install titan-webscraping-skills@titan-webscraping
```

`npx skills add` 已经覆盖了 Claude Code，所以这只是另一种选择，不是额外的步骤。

## 这些技能不会做的事

提前讲清楚，因为一个承诺了服务器做不到的事的技能，只会白白浪费一次运行和你的额度：

- **不读需要登录的来源。** LinkedIn、X、Instagram、TikTok、企业内部看板，以及 Crunchbase、
  PitchBook 这类付费数据库都需要登录态，Titan 没有。技能会明确说明，并改用公开网络上的
  等价来源。
- **不执行 JavaScript。** 由前端 JS 渲染出来的价格会被标注为**无法读取**，绝不估算。
- **服务器不做结构化抽取。** Titan 返回干净的 markdown，由 AI 助手把它解析成表格或 CSV。
  没有任何技能会承诺 Titan 并不返回的数据结构。
- **不编造数字。** 市场规模、估值、搜索量——要么引用来源，要么不写。

细节见 [references/titan-tools.md](references/titan-tools.md)。

## 开发

```bash
scripts/link-skills.sh   # 把每个技能软链接到各客户端目录
scripts/list-skills.sh   # 列出本仓库的技能
```

`link-skills.sh` 用的是软链接而非复制，所以一次 `git pull` 就能更新所有已安装的客户端。
新增或重命名技能后重新运行一次。

新增和撰写技能的约定见 [AGENTS.md](AGENTS.md) 与
[references/skill-authoring.md](references/skill-authoring.md)；背后的客户端兼容性细节见
[.agents/harnesses.md](.agents/harnesses.md)。

## 许可

[MIT](LICENSE)
