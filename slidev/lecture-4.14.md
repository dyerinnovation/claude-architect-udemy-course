---
theme: default
title: "Lecture 4.14: Incremental Codebase Exploration Pattern"
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
const flow_steps = [
  { label: 'Grep entry points', sublabel: 'Function names, identifiers, error strings' },
  { label: 'Read matching files', sublabel: 'Only what the Grep surfaced' },
  { label: 'Grep again', sublabel: 'For imports or calls found in the reads' },
  { label: 'Read + repeat', sublabel: 'Until the question is answered' },
]

const trace_steps = [
  { title: 'Grep process_refund', body: 'Returns three callers: HTTP handler, CLI command, MCP tool impl.' },
  { title: 'Read the HTTP handler', body: 'See it imports a refund function from a wrapper module.' },
  { title: 'Grep the wrapper module', body: 'Finds the refund function and one helper.' },
  { title: 'Read the MCP tool impl', body: 'See how it maps to the business logic. Four calls. Seventy files untouched.' },
]

const antipattern_bad = `Read all files upfront: context wall, no understanding.

OR: blind Grep with no plan — Grep random strings, read what pops out, Grep again without any thread. Burning calls without a trace.`

const antipattern_fix = `Each Grep is motivated by the last Read.
Every step is connected to the previous one.
If you can't name WHY you're running the next Grep — stop and think.`
</script>

<div class="di-cover">
  <div class="di-cover__inner">
    <div class="di-cover__eyebrow">Domain 2 · Lecture 4.14</div>
    <h1 class="di-cover__title">Incremental <span class="di-cover__accent">Codebase Exploration</span></h1>
    <div class="di-cover__subtitle">Grep → Read → follow imports. Never read-everything-upfront.</div>
  </div>
</div>

<style scoped>
.di-cover { position: absolute; inset: 0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%); color: var(--mint-100); }
.di-cover__inner { padding: 110px 120px 96px; height: 100%; display: flex; flex-direction: column; justify-content: center; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px; }
.di-cover__title { font-family: var(--font-display); font-weight: 500; font-size: 108px; line-height: 1.05; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1600px; }
.di-cover__accent { color: var(--sprout-500); }
.di-cover__subtitle { font-family: var(--font-display); font-size: 36px; color: var(--mint-200); margin-top: 40px; font-weight: 400; }
</style>

<!--
Last lecture of Domain 2. The pattern that ties the built-in tools together into a workflow. Grep, Read, follow imports. Never read-everything-upfront. Eight minutes, and then we close the section.
-->

---

<BigQuote quote="Read every file upfront — you hit the context wall before you learn anything." />

<!--
Here's the trap. "Read every file upfront: you hit the context wall before you learn anything." That's the opening move that kills agents — loading the whole codebase into context in the hope of understanding it, and running out of tokens before you've traced a single call path. Doesn't work on ten files. Definitely doesn't work on ten thousand. The fix isn't a bigger context window. It's a better workflow.
-->

---

<FlowDiagram
  title="The right flow"
  :steps="flow_steps"
/>

<!--
Here's the pattern. Four steps. Step one — Grep for entry points. Function names, identifiers, error strings — whatever anchors the question you're trying to answer. Step two — Read the files the Grep surfaced. Step three — Grep again, for imports or calls you found in those reads. Step four — Read what that second Grep surfaces. Repeat until the question is answered. Each Grep is motivated by the last Read. Each Read is motivated by the last Grep. You never touch files the trace doesn't implicate.
-->

---

<ConceptHero
  leadLine="Incrementality is a context strategy"
  concept="You never exhaust tokens on files irrelevant to the question."
  supportLine="The question drives the files you touch — not the filesystem. Pattern that works on one file works on a million."
/>

<!--
Incrementality isn't just a code convention — it's a context strategy. You never exhaust tokens on files irrelevant to the question. The question drives the files you touch, not the filesystem. That's the reframe. You're not exploring the codebase; you're answering a specific question, and the files you need are the ones your trace walks through. The pattern that works on one file works on a million. The shape is the same.
-->

---

<StepSequence
  title="Trace example: process_refund"
  :steps="trace_steps"
/>

<!--
Concrete walkthrough. Trace process_refund across a hypothetical codebase. Step one — Grep process_refund. Returns three callers: an HTTP handler, a CLI command, an MCP tool implementation. Step two — Read the HTTP handler. You see it imports a refund function from a wrapper module. Step three — Grep that wrapper module's exports. Finds the refund function and one helper. Step four — Read the MCP tool impl to see how it maps to the business logic. Now you understand the refund path — how the HTTP call flows to the wrapper to the business logic, and how the MCP tool uses the same underlying function. Four tool calls. You never touched the seventy other files in the project.
-->

---

<CalloutBox variant="tip" title="Domain 3 crossover — when to spawn an Explore subagent">

If exploration will be verbose — dozens of files, long trails — delegate to an Explore subagent. The subagent does the Grep-Read loop in its own context, returns a summary.
<br/><br/>
Preserves your main context from file-reading noise. Task 3.4, covered in depth in Section 5.

</CalloutBox>

<!--
One more tool in the toolkit. If the exploration is going to be verbose — dozens of files, long trails — delegate it to an Explore subagent. The subagent does the Grep-Read loop in its own context, then returns a summary to the main conversation. This preserves your main context from getting cluttered with file-reading noise. Task 3.4 covers Explore in depth, and we'll come back to it in Section 5 when we handle Domain 3. For now, know it exists as the escape hatch for big traces.
-->

---

<AntiPatternSlide
  title="Two exploration traps"
  :badExample="antipattern_bad"
  whyItFails="Either you load everything and learn nothing, or you Grep blindly with no thread."
  :fixExample="antipattern_fix"
  lang="text"
/>

<!--
Two anti-patterns. Left side — read all files upfront. Context wall, no understanding. Right side — blind Grep with no plan. You Grep random strings, read what pops out, Grep again without any thread — burning calls without a trace. The fix for both: each Grep is motivated by the last Read. Every step is connected to the previous one. If you can't name why you're running the next Grep, stop and think.
-->

---

<CalloutBox variant="tip" title="On the exam — Scenario 4 'trace this function'">

Scenario 4 often shows a developer asking "trace this function" or "understand this module." Correct pattern: <strong>incremental — Grep, Read, follow imports, repeat.</strong>
<br/><br/>
<em>"Load all files upfront"</em> and <em>"read the whole module"</em> are distractor classics. They sound thorough. Thorough isn't the same as right.

</CalloutBox>

<!--
Here's the exam move. Scenario 4 frequently asks "a developer wants to trace this function" or "how should Claude approach understanding this unfamiliar module?" The correct pattern is always incremental — Grep, Read, follow imports, repeat. "Load all files upfront" and "read the whole module" are the distractor classics. They sound thorough. They're the wrong answer. Remember 1.1's "almost-right is the whole trap" — loading everything looks thorough, but thorough isn't the same as right.
-->

---

<ConceptHero
  leadLine="Domain 2 in one sentence"
  concept="Descriptions. Errors. Scope. Exploration."
  supportLine="Four parts of a great description. Three error fields. Four error categories. 4–5 tools per agent. Three tool_choice modes. Grep-Read incremental pattern."
/>

<!--
Section recap. Domain 2 in one sentence — tool descriptions, structured errors, scoped tool access, and incremental exploration. Eighteen percent of your exam. If you can name the four parts of a great tool description — purpose, inputs, examples, boundaries — the three fields of an MCP error response — errorCategory, isRetryable, description — the four error categories — transient, validation, business, permission — the tool-count ceiling of four to five, the three tool_choice modes, and the Grep-Read incremental pattern — you've covered the section. Know those cold.
-->

---

<div class="di-close">
  <div class="di-close__inner">
    <div class="di-close__eyebrow">Section closes · Next section</div>
    <h1 class="di-close__title">Domain 3 — <span class="di-close__accent">Claude Code Configuration &amp; Workflows</span></h1>
    <div class="di-close__subtitle">Twenty percent of your exam. Next up.</div>
  </div>
</div>

<style scoped>
.di-close { position: absolute; inset: 0; background: var(--mint-100); color: var(--forest-800); }
.di-close__inner { padding: 110px 120px 96px; height: 100%; display: flex; flex-direction: column; justify-content: center; }
.di-close__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.14em; text-transform: uppercase; color: var(--teal-500); margin-bottom: 36px; }
.di-close__title { font-family: var(--font-display); font-weight: 500; font-size: 84px; line-height: 1.05; letter-spacing: -0.02em; color: var(--forest-900); margin: 0; max-width: 1600px; }
.di-close__accent { color: var(--sprout-600); }
.di-close__subtitle { font-family: var(--font-display); font-size: 38px; color: var(--forest-500); margin-top: 32px; font-weight: 400; }
</style>

<!--
That closes Section 4 and Domain 2. Next section — Domain 3 — Claude Code Configuration and Workflows. Twenty percent. See you there.
-->
