---
theme: default
title: "Lecture 4.10: MCP Server Configuration — Project vs User Scope"
info: |
  Claude Certified Architect – Foundations
  Section 4 — Tool Design & MCP Integration (Domain 2, 18%)
highlighter: shiki
transition: fade-out
mdc: true
canvasWidth: 1920
aspectRatio: 16/9
---

<style>
@import './design-system.css';
</style>

<script setup>
const symptom_bullets = [
  { label: 'New team member', detail: '"Tool not found" — clones the repo, launches Claude Code, missing Jira MCP.' },
  { label: 'CI build', detail: 'Same story. CI doesn\'t have your home directory.' },
  { label: 'You', detail: 'Works fine — because you have it locally in ~/.claude.json.' },
]

const project_code = `// .mcp.json at project root — committed to repo
{
  "mcpServers": {
    "company-jira": {
      "command": "uvx",
      "args": ["mcp-server-jira", "--url", "https://company.atlassian.net"]
    },
    "internal-docs": {
      "command": "node",
      "args": ["./tools/internal-docs-mcp/server.js"]
    }
  }
}`

const user_code = `// ~/.claude.json — personal, never committed
{
  "mcpServers": {
    "local-prototype": {
      "command": "python",
      "args": ["/Users/me/dev/experiments/my-server.py"]
    }
  }
}`
</script>

<div class="di-cover">
  <div class="di-cover__inner">
    <div class="di-cover__eyebrow">Domain 2 · Lecture 4.10</div>
    <h1 class="di-cover__title">MCP <span class="di-cover__accent">Server Scopes</span></h1>
    <div class="di-cover__subtitle">Two locations. Two purposes. One onboarding bug.</div>
  </div>
</div>

<style scoped>
.di-cover { position: absolute; inset: 0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%); color: var(--mint-100); }
.di-cover__inner { padding: 110px 120px 96px; height: 100%; display: flex; flex-direction: column; justify-content: center; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px; }
.di-cover__title { font-family: var(--font-display); font-weight: 500; font-size: 128px; line-height: 1.05; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1600px; }
.di-cover__accent { color: var(--sprout-500); }
.di-cover__subtitle { font-family: var(--font-display); font-size: 38px; color: var(--mint-200); margin-top: 40px; font-weight: 400; }
</style>

<!--
Two locations. Two purposes. Get them mixed up and a new team member silently has fewer tools than you do. This lecture is short, but the question it answers is one of the highest-frequency onboarding bugs in Claude Code. Know it cold.
-->

---

<TwoColSlide
  title="Two locations"
  leftLabel=".mcp.json (project)"
  rightLabel="~/.claude.json (user)"
>
  <template #left>
    <div style="font-family: var(--font-body); font-size: 24px; line-height: 1.55;">
      Shared via version control. Committed to the repo. Everyone who clones gets it automatically.
      <br/><br/>
      <strong>Team's Jira. Company's internal MCP. Shared GitHub.</strong>
    </div>
  </template>
  <template #right>
    <div style="font-family: var(--font-body); font-size: 24px; line-height: 1.55;">
      Personal. In your home directory. Not shared. Never ships to the repo or CI.
      <br/><br/>
      <strong>Experimental servers. Personal utilities. Local prototypes.</strong>
    </div>
  </template>
</TwoColSlide>

<!--
Here are the two. On the left — .mcp.json at your project root. Shared via version control. Committed to the repo. Everyone who clones gets it automatically the next time they launch Claude Code. On the right — ~/.claude.json in your home directory. Personal. Not shared. Only you see it. Never ships to the repo, never touches CI, never touches your teammates' machines. Two files, two scopes. The distinction looks trivial until it bites somebody three weeks into a new hire's onboarding.
-->

---

<ConceptHero
  leadLine="Where does this server belong?"
  concept="Team uses it? Project. You alone? User."
  supportLine="Get this wrong — new hires silently lack tools, CI silently fails, only your machine works."
/>

<!--
Here's the decision rule. Where does this server belong? If the team uses it, it goes in project scope — .mcp.json. If it's you alone, user scope — ~/.claude.json. That's the whole rule. One question to ask. The team's Jira server, the company's internal MCP, the shared GitHub integration — project. Your experimental local server, your personal productivity tool, your homegrown prototype — user. Get this wrong and new hires silently lack tools, CI silently fails, and you silently wonder why it only works on your machine. Classic scope-confusion bug.
-->

---

<CodeBlockSlide
  title=".mcp.json — checked into the repo"
  lang="json"
  :code="project_code"
  annotation="Version-controlled. Reviewable in PRs. Reproducible. Config travels with the codebase."
/>

<!--
Here's a project-scoped .mcp.json. Checked into the repo. Contains the team's Jira server, the company's internal-docs MCP, a shared GitHub server. Everyone on the team gets these automatically when they clone. This is how you make MCP servers part of the team's toolchain — not something each developer has to install and configure separately. Version-controlled. Reviewable in PRs. Reproducible. If someone adds a new shared server, it ships in the same commit as the code that depends on it. That's the whole point of project scope — config travels with the codebase.
-->

---

<CodeBlockSlide
  title="~/.claude.json — personal"
  lang="json"
  :code="user_code"
  annotation="Same format. Different scope. Discovered at the same time as project servers — both are available."
/>

<!--
Here's the user-scoped flavor. ~/.claude.json. Your experimental local-database MCP. A personal utility server you're prototyping. A server with your personal credentials that you don't want to foist on teammates. A server that only makes sense on your specific machine setup. These stay in your home directory. They don't ship to the repo. They don't affect the team. Same server config format — totally different scope. And critically — they're discovered and loaded at the same time project-scoped servers are, so both kinds of servers are available simultaneously to the agent. Scope determines where the config lives, not whether the tools are available.
-->

---

<BulletReveal
  title="How you find out you got this wrong"
  :bullets="symptom_bullets"
/>

<!--
Here's how you find out you got this wrong. New team member joins, clones the repo, opens Claude Code — "tool not found" when they try to use the company's Jira MCP. Because you put the server in your ~/.claude.json instead of the project's .mcp.json. CI build — same story, missing MCP server, because CI doesn't have your home directory. And on your machine, everything works fine, because you have it locally. Those three symptoms together mean scope is wrong. The fix is one move — relocate the server config from ~/.claude.json to .mcp.json at the project root, commit it, and every teammate and every CI job picks it up.
-->

---

<CalloutBox variant="tip" title="On the exam">

"Shared team MCP server goes in <code>.mcp.json</code>." Memorize it. That's the Task 2.4 nugget.
<br/><br/>
Watch for distractors: <strong>"user-scoped <code>.mcp.json</code>"</strong> is a nonsense phrase the exam uses to catch skimmers. <code>.mcp.json</code> is always project. <code>~/.claude.json</code> is always user. No cross-over.

</CalloutBox>

<!--
Here's the exam move. "Shared team MCP server goes in .mcp.json." Memorize it. That's the Task 2.4 knowledge nugget you need. And watch for distractors — "user-scoped .mcp.json" is a nonsense phrase the exam puts in answer choices to catch skimmers who are matching on keywords instead of reading carefully. .mcp.json is always project-scoped. ~/.claude.json is always user-scoped. There's no cross-over. If an answer choice implies otherwise, it's wrong, and you now have the domain knowledge to catch it cold. One more "almost-right" distractor defused.
-->

---

<ConceptHero
  leadLine="Where Domain 2 and Domain 3 shake hands"
  concept="Tool integration in team-configured environments."
  supportLine="Scenario 2, 4, and 5 all touch this. Path B/C from 1.1 — you've probably hit this in the wild."
/>

<!--
This is where Domain 2 and Domain 3 shake hands. Scenario 2, Scenario 4, and Scenario 5 all touch Claude Code configuration for teams. The .mcp.json question is a Domain 2 item living in Domain 3 territory — tool integration inside a team-configured environment. If you took Path B or C from 1.1 — some or lots of experience — you've probably run into this bug in the wild. Lock it in, because the same pattern shows up under several scenario framings on the exam.
-->

---

<div class="di-close">
  <div class="di-close__inner">
    <div class="di-close__eyebrow">Next up</div>
    <h1 class="di-close__title">4.11 — <span class="di-close__accent">.mcp.json with Env Var Expansion</span></h1>
    <div class="di-close__subtitle">Commit the config. Don't commit the secret.</div>
  </div>
</div>

<style scoped>
.di-close { position: absolute; inset: 0; background: var(--mint-100); color: var(--forest-800); }
.di-close__inner { padding: 110px 120px 96px; height: 100%; display: flex; flex-direction: column; justify-content: center; }
.di-close__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.14em; text-transform: uppercase; color: var(--teal-500); margin-bottom: 36px; }
.di-close__title { font-family: var(--font-display); font-weight: 500; font-size: 92px; line-height: 1.05; letter-spacing: -0.02em; color: var(--forest-900); margin: 0; max-width: 1600px; }
.di-close__accent { color: var(--sprout-600); }
.di-close__subtitle { font-family: var(--font-display); font-size: 38px; color: var(--forest-500); margin-top: 32px; font-weight: 400; }
</style>

<!--
Next up, Lecture 4.11 — how to put secrets in .mcp.json without committing secrets. Environment variable expansion. See you there.
-->
