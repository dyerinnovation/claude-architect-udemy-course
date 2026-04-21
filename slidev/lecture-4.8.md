---
theme: default
title: "Lecture 4.8: Tool Distribution: How Many Tools Per Agent?"
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
const distribution_bullets = [
  { label: 'Coordinator', detail: 'Task + a few policy/routing tools. Three, maybe four.' },
  { label: 'Search subagent', detail: 'web_search, load_document. Two tools, tightly scoped.' },
  { label: 'Synthesis subagent', detail: 'verify_fact only — narrow cross-role for the 85% case.' },
  { label: 'Everything else', detail: 'Routes through the coordinator.' },
]

const antipattern_bad = `Synthesis agent with web_search, load_document, and every other search tool attached.

Agent's job: combining findings. But now it runs web searches on its own. Uses tools outside its role.`

const antipattern_fix = `Scope tools to role.
Cross-role work routes through the coordinator.
Synthesis gets one narrow tool (verify_fact) for the common case.`
</script>

<div class="di-cover">
  <div class="di-cover__inner">
    <div class="di-cover__eyebrow">Domain 2 · Lecture 4.8</div>
    <h1 class="di-cover__title">How Many <span class="di-cover__accent">Tools Per Agent?</span></h1>
    <div class="di-cover__subtitle">Four to five. Eighteen breaks things.</div>
  </div>
</div>

<style scoped>
.di-cover { position: absolute; inset: 0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%); color: var(--mint-100); }
.di-cover__inner { padding: 110px 120px 96px; height: 100%; display: flex; flex-direction: column; justify-content: center; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px; }
.di-cover__title { font-family: var(--font-display); font-weight: 500; font-size: 128px; line-height: 1.05; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1600px; }
.di-cover__accent { color: var(--sprout-500); }
.di-cover__subtitle { font-family: var(--font-display); font-size: 40px; color: var(--mint-200); margin-top: 40px; font-weight: 400; }
</style>

<!--
Four to five tools per agent. That's the ceiling. Past it, selection reliability degrades sharply. This lecture explains why, what scoped tool access looks like in practice, and the one exception the exam tests explicitly.
-->

---

<BigNumber
  number="4–5"
  unit=" tools per agent"
  caption="Selection reliability stays high in that range. Drops off fast past it."
  detail="18 tools on one agent — the number the exam guide cites — produces selection failures even with well-written descriptions."
/>

<!--
Four to five. That's the number. Selection reliability stays high in that range and drops off fast past it. Eighteen tools on one agent, the number the exam guide explicitly cites, produces selection failures even with well-written descriptions. The lever from 4.1 — prose differentiation — only goes so far. Past a handful of tools, you run out of room to differentiate them all against each other.
-->

---

<ConceptHero
  leadLine="Tool selection is a decision"
  concept="Each extra tool = another 'not this one.'"
  supportLine="18 tools ≠ 18× capability. It's 18× selection overhead. The math isn't linear — it compounds with weak descriptions."
/>

<!--
Here's why. Tool selection is a decision, and each extra tool adds another "not this one" the model has to reason through. Eighteen tools is not eighteen times the capability — it's eighteen times the selection overhead. Claude isn't picking the right tool from a menu; it's ruling out every wrong tool on the way to the right one. More tools, more wrong tools to rule out, more chances to get it wrong. The math isn't linear. It's worse. And it compounds with weak descriptions from Lecture 4.1 — add bad descriptions to a big tool set and the misroute rate doesn't just add, it multiplies.
-->

---

<AntiPatternSlide
  title="Dump every tool onto one agent"
  :badExample="antipattern_bad"
  whyItFails="Agent uses tools outside its role, because they're right there in the toolbelt."
  :fixExample="antipattern_fix"
  lang="text"
/>

<!--
Anti-pattern. Dump every tool onto one agent. The exam's canonical example: a synthesis agent that has web-search tools attached to it. Now the synthesis agent — whose job is combining findings — starts running web searches on its own. It's using tools outside its role, because they're right there in its toolbelt. The right pattern: scope tools to role. If synthesis needs web data, it routes through the coordinator, which delegates to the search subagent. Cross-role work runs through the coordinator.
-->

---

<BulletReveal
  title="The right distribution"
  :bullets="distribution_bullets"
/>

<!--
Here's what scoped distribution looks like. Coordinator — gets the Task tool for spawning subagents, plus a few policy or routing tools. Three, maybe four. Search subagent — web_search, load_document. That's it. Two tools, tightly scoped. Synthesis subagent — verify_fact only, and we'll come back to why it has even that. Everything else routes through the coordinator. Each agent has a small, purpose-fit toolbelt. Nothing it can misuse. Nothing extraneous that dilutes its selection decisions. Each subagent is effectively specialized by its tool set.
-->

---

<CalloutBox variant="tip" title="Sample Q9 — scoped cross-role exception">

Synthesis verifies claims — dates, names, stats — in 85% of cases on simple lookups. Round-tripping through the coordinator adds 40% latency.
<br/><br/>
<strong>Correct answer:</strong> narrow <code>verify_fact</code> on synthesis for the 85% common case. Route the 15% complex cases through the coordinator. Principle of least privilege with a targeted exception.

</CalloutBox>

<!--
Now the exception, and this is Sample Question 9 from the exam guide, almost word-for-word. Synthesis needs to verify specific claims — dates, names, statistics — and the data says it does this eighty-five percent of the time on simple lookups. If every verification round-trips through the coordinator, latency climbs forty percent. The right answer isn't "give synthesis all the web search tools" — that's the anti-pattern from slide 4, the exact distractor the question tests. The right answer is a narrow, scoped verify_fact tool on synthesis for the eighty-five-percent common case, and route the fifteen-percent complex cases through the coordinator. Principle of least privilege with a targeted exception. Scope tightly. Exception narrowly. That's the pattern.
-->

---

<CalloutBox variant="tip" title="On the exam — 'more tools' is the distractor">

<strong>"Give the agent more tools"</strong> → almost always wrong.<br/>
<strong>"Consolidate into one mega-tool"</strong> → almost always wrong.<br/>
<strong>"Scope tools + narrow cross-role tool for the frequent need"</strong> → almost always correct.

</CalloutBox>

<!--
Here's the exam move. "Give the agent more tools" is almost always a distractor. "Give the agent access to every search tool" — wrong. "Consolidate into one mega-tool" — wrong. Both options miss the principle of least privilege that the exam rewards. The correct answer usually scopes the tools to the role and, when latency or round-trip cost demands it, adds a narrow cross-role tool for the frequent need. Scoped plus a narrow exception. That's the pattern. Remember the scoping pattern cold — Scenario 3 leans on it hard, and remember the six-pick-four from 1.1: you don't know which four scenarios will appear, so skipping Scenario 3's tool distribution isn't an option.
-->

---

<ConceptHero
  leadLine="Six-pick-four reminder"
  concept="Low effort. High payoff. Bank it."
  supportLine="Know 4–5 as the ceiling. Know scoped-plus-narrow-exception. Know 'more tools' is a distractor. That's a real share of your exam."
/>

<!--
One more framing before we close. Domain 2 is eighteen percent. Task 2.3 — tool distribution — is a chunk of that. And Scenario 3's questions almost always touch distribution in some way. If you walk in knowing four-to-five is the ceiling, knowing the scoped-plus-narrow-exception pattern, and knowing that "give the agent more tools" is a distractor signal — you've covered a real share of your exam. Low effort, high payoff. Bank it.
-->

---

<div class="di-close">
  <div class="di-close__inner">
    <div class="di-close__eyebrow">Next up</div>
    <h1 class="di-close__title">4.9 — <span class="di-close__accent">tool_choice: auto, any, Forced</span></h1>
    <div class="di-close__subtitle">Three modes. Three guarantees.</div>
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
Next up, Lecture 4.9 — tool_choice. Three modes. Each guarantees something different. See you there.
-->
