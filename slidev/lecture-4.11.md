---
theme: default
title: "Lecture 4.11: .mcp.json with Environment Variable Expansion"
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
const onboard_steps = [
  { title: 'Clone the repo', body: 'New teammate pulls the project. The .mcp.json is already there, with placeholders.' },
  { title: 'cp .env.example .env', body: 'Template becomes their personal env file. Shows which variables to fill in.' },
  { title: 'Fill in personal tokens', body: 'Each developer uses their own credentials. Scales across the team.' },
  { title: 'Launch Claude Code', body: 'Env-var placeholders resolve at runtime. Server authenticates. Works.' },
]

const expansion_code = `// .mcp.json — committed, with env placeholders
{
  "mcpServers": {
    "github": {
      "command": "uvx",
      "args": ["mcp-server-github"],
      "env": {
        "GITHUB_TOKEN": "\${GITHUB_TOKEN}",
        "GITHUB_ORG":   "\${GITHUB_ORG}"
      }
    }
  }
}`

const antipattern_bad = `// .mcp.json — DO NOT COMMIT THIS
{
  "env": {
    "GITHUB_TOKEN": "ghp_abc123XYZ..."
  }
}
// Literal secret. Pushed to git history forever.
// GitHub's scanners WILL find it.`

const antipattern_fix = `// .mcp.json — committed safely
{
  "env": {
    "GITHUB_TOKEN": "\${GITHUB_TOKEN}"
  }
}
// Placeholder only. Real value stays in .env (gitignored).`
</script>

<div class="di-cover">
  <div class="di-cover__inner">
    <div class="di-cover__eyebrow">Domain 2 · Lecture 4.11</div>
    <h1 class="di-cover__title"><span class="di-cover__mono">.mcp.json</span> with<br/><span class="di-cover__accent">Environment Variable Expansion</span></h1>
    <div class="di-cover__subtitle">Commit the config. Don't commit the secret.</div>
  </div>
</div>

<style scoped>
.di-cover { position: absolute; inset: 0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%); color: var(--mint-100); }
.di-cover__inner { padding: 110px 120px 96px; height: 100%; display: flex; flex-direction: column; justify-content: center; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px; }
.di-cover__title { font-family: var(--font-display); font-weight: 500; font-size: 100px; line-height: 1.05; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1600px; }
.di-cover__mono { font-family: var(--font-mono); color: var(--sprout-500); }
.di-cover__accent { color: var(--sprout-500); }
.di-cover__subtitle { font-family: var(--font-display); font-size: 38px; color: var(--mint-200); margin-top: 40px; font-weight: 400; }
</style>

<!--
Short lecture. Six minutes. One pattern. ${GITHUB_TOKEN}. Commit the config — don't commit the secret. This is one of those memorize-it-and-ship-it topics the exam likes to test. It sits right on top of Lecture 4.10's project-scope pattern, and together they answer every shared-MCP-with-auth question.
-->

---

<BigQuote quote="I need credentials in config, but I can't commit credentials." />

<!--
Here's the tension. You need credentials in your MCP config — GitHub tokens, Jira API keys, database URLs. But your config lives in .mcp.json, which is committed to the repo. You can't commit credentials. That's a security incident and a compliance problem, and every team-wide GitHub scanner will flag it in seconds. And you can't not have credentials — without them, the MCP server can't authenticate against whatever backend it talks to. So how do you commit the config without committing the secret? That's the question this lecture answers in one pattern. It's a pattern every mature repo already uses for other secrets — you're just applying it to .mcp.json specifically.
-->

---

<CodeBlockSlide
  title=".mcp.json with env expansion"
  lang="json"
  :code="expansion_code"
  annotation="At runtime, Claude Code substitutes the value of each env var from the shell launching the process."
/>

<!--
Environment variable expansion. Inside .mcp.json, you write "${GITHUB_TOKEN}" — literal dollar-sign-curly-brace-GITHUB_TOKEN-curly-brace — as the value for the token field, usually in an env block attached to a server definition. At runtime, Claude Code reads the file, sees the placeholder, and substitutes the value of the GITHUB_TOKEN environment variable from the shell launching the process. The committed file has the placeholder. The running process has the real value. Same mechanism you've used in docker-compose files and Kubernetes manifests. Same pattern. No magic.
-->

---

<TwoColSlide
  title="Commit vs don't commit"
  leftLabel="Commit"
  rightLabel="Don't commit"
>
  <template #left>
    <div style="font-family: var(--font-body); font-size: 22px; line-height: 1.5;">
      <code>.mcp.json</code> with <code>"${GITHUB_TOKEN}"</code> placeholders
      <br/><br/>
      <code>.env.example</code> — template showing which vars to set, fake values
      <br/><br/>
      Reviewable. Reproducible. No secrets in git history.
    </div>
  </template>
  <template #right>
    <div style="font-family: var(--font-body); font-size: 22px; line-height: 1.5;">
      <code>.env</code> with real token values
      <br/><br/>
      Listed in <code>.gitignore</code>. Each developer keeps their own.
      <br/><br/>
      Token rotates? Only the individual updates locally — no repo change.
    </div>
  </template>
</TwoColSlide>

<!--
Here's the split. On the left — commit. The .mcp.json with "${GITHUB_TOKEN}" placeholders. Reviewable, reproducible, no secrets. Anyone can read it in a PR without spilling credentials. Also commit a .env.example — a template showing which variables need to be set, with fake values. That's how you tell new teammates what to fill in. On the right — don't commit. The .env file with the actual token value ghp_abc123.... That stays in .gitignore. Each developer has their own. Same config, different secrets, no shared-credential problems. If that secret ever rotates, only the individual updates their .env — nobody needs a repo change.
-->

---

<StepSequence
  title="Onboarding steps"
  :steps="onboard_steps"
/>

<!--
Here's the onboarding flow for a new teammate. One — clone the repo. Two — copy .env.example to .env. Three — fill in their personal tokens into the .env file. Four — launch Claude Code; the MCP server reads the config, Claude Code substitutes the env-var placeholders with real values from the environment, authenticates, and works. Four steps, zero committed secrets, every developer using their own credentials against the shared config. This is the pattern every reasonable repo ships. It scales to as many servers and as many teammates as you need, and it plays nicely with CI — CI sets the env vars from its secret store and runs the same config.
-->

---

<AntiPatternSlide
  title="Don't inline the token"
  :badExample="antipattern_bad"
  whyItFails="In git history forever. Rotating credentials and rewriting history before lunch."
  :fixExample="antipattern_fix"
  lang="json"
/>

<!--
Anti-pattern. Inline the token. The .mcp.json has "token": "ghp_abc123..." with the literal secret. Committed. Pushed. Now it's in your git history forever, even if you remove it in the next commit — GitHub's secret scanners will find it, security will find it, and you'll be rotating the token and rewriting git history before lunch. The right version uses "token": "${GITHUB_TOKEN}" and keeps the real value out of git entirely. Two different lines, two radically different security postures. This is a rotating-credentials incident waiting to happen, and the exam tests the distinction because the industry has seen this bug a thousand times. It's one of the easiest distractor traps to spot once you know to look for it — any answer choice that literally commits a token is wrong.
-->

---

<CalloutBox variant="tip" title="On the exam">

If the question mentions <strong>team sharing AND credentials</strong>, the answer includes <code>${VAR}</code> environment expansion.
<br/><br/>
Inline tokens → always wrong.<br/>
Committing credential files → always wrong.<br/>
Separate auth service → over-engineered.<br/>
<strong>Project-scoped <code>.mcp.json</code> + env-var expansion</strong> → correct shape.

</CalloutBox>

<!--
Here's the exam move. If the question mentions team sharing AND credentials, the answer includes ${VAR} environment expansion. Inline tokens is always wrong. Committing a credential file is always wrong. Creating a separate auth service just to dodge the question is over-engineered. The correct pattern is project-scoped .mcp.json — the project scope from Lecture 4.10 — plus env-var expansion for anything sensitive. That's the shape of the right answer for every shared-MCP-with-auth question on this exam. Two lectures, one combined pattern. Hold onto both.
-->

---

<div class="di-close">
  <div class="di-close__inner">
    <div class="di-close__eyebrow">Next up</div>
    <h1 class="di-close__title">4.12 — <span class="di-close__accent">MCP Resources vs Tools</span></h1>
    <div class="di-close__subtitle">Tools do. Resources expose.</div>
  </div>
</div>

<style scoped>
.di-close { position: absolute; inset: 0; background: var(--mint-100); color: var(--forest-800); }
.di-close__inner { padding: 110px 120px 96px; height: 100%; display: flex; flex-direction: column; justify-content: center; }
.di-close__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.14em; text-transform: uppercase; color: var(--teal-500); margin-bottom: 36px; }
.di-close__title { font-family: var(--font-display); font-weight: 500; font-size: 96px; line-height: 1.05; letter-spacing: -0.02em; color: var(--forest-900); margin: 0; max-width: 1600px; }
.di-close__accent { color: var(--sprout-600); }
.di-close__subtitle { font-family: var(--font-display); font-size: 38px; color: var(--forest-500); margin-top: 32px; font-weight: 400; }
</style>

<!--
Next up, Lecture 4.12 — MCP resources versus MCP tools. When to use each. Tools do, resources expose. See you there.
-->
