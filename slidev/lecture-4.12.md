---
theme: default
title: "Lecture 4.12: MCP Resources vs MCP Tools"
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
const tool_bullets = [
  { label: 'Side effects', detail: 'Creates, modifies, or triggers something downstream.' },
  { label: 'Parameters drive the result', detail: 'Different inputs, different outputs.' },
  { label: 'Claude reasons about WHEN to call', detail: 'The decision to invoke is part of the agent\'s reasoning.' },
]
const resource_bullets = [
  { label: 'See the catalog upfront', detail: 'No call needed to discover what\'s there.' },
  { label: 'Browsable content', detail: 'Issues, schemas, docs, configs — scan and pick.' },
  { label: 'Reduce exploratory tool calls', detail: 'If Claude knows what exists, it doesn\'t guess-and-search.' },
]

const antipattern_bad = `search_all_docs()
// Tool Claude calls every turn to discover what docs exist.
// Token cost every call. Latency every call.
// Sometimes Claude skips it entirely and guesses.`

const antipattern_fix = `docs://catalog
// Exposed as a resource. Claude sees it directly in context
// at the start of conversation. References it without calling.
// Uses targeted get_doc(id) only when it needs specific content.`
</script>

<div class="di-cover">
  <div class="di-cover__inner">
    <div class="di-cover__eyebrow">Domain 2 · Lecture 4.12</div>
    <h1 class="di-cover__title">MCP <span class="di-cover__accent">Resources vs Tools</span></h1>
    <div class="di-cover__subtitle">When to use each. Verbs vs nouns.</div>
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
MCP gives you two primitives. Tools and resources. Not the same thing. Not interchangeable. And the exam tests whether you know which is which. Seven minutes to lock it down.
-->

---

<ConceptHero
  leadLine="Verbs vs nouns"
  concept="Tools DO. Resources EXPOSE."
  supportLine="A tool call changes state or fetches dynamically. A resource shows Claude what's available without a call."
/>

<!--
Here's the distinction. Verbs versus nouns. Tools do. Resources expose. A tool call changes state, or fetches something dynamically based on arguments. A resource exposes a catalog of what's available, and Claude can read it without making a tool call. One is an action. The other is a listing. Once you internalize "verbs versus nouns," the rest of this lecture is just application.
-->

---

<BulletReveal
  title="Use a tool when..."
  :bullets="tool_bullets"
/>

<!--
Use a tool when three conditions hold. One — the action has side effects. It creates something, modifies something, triggers something downstream. Two — parameters drive the result. Different inputs, different outputs; the call is meaningful because of what you pass in. Three — you want Claude to reason about when to call it, not just that it exists — the decision to invoke is part of the agent's reasoning. Tools are for doing. Reach for a tool whenever the semantics include a verb and an effect.
-->

---

<BulletReveal
  title="Use a resource when..."
  :bullets="resource_bullets"
/>

<!--
Use a resource when three different conditions hold. One — you want Claude to see the catalog upfront, without having to call anything to discover what's there. Two — the content is browsable. Issues, schemas, docs, configs — stuff Claude can scan and pick from. Three — you want to reduce exploratory tool calls. If Claude knows what's available, it doesn't have to guess-and-search. Resources are for exposing. Think of them as the "here's what exists" layer, sitting alongside the "here's how you act on it" layer that tools provide.
-->

---

<TwoColSlide
  title="Concrete pair — same Jira backend"
  leftLabel="Tool: search_jira_issue"
  rightLabel="Resource: jira://issues/open"
>
  <template #left>
    <div style="font-family: var(--font-body); font-size: 22px; line-height: 1.5;">
      Takes a query, runs a search, returns matching issues dynamically.
      <br/><br/>
      Different query → different result set. <strong>Call it, run it, get results back.</strong>
      <br/><br/>
      Targeted follow-up search.
    </div>
  </template>
  <template #right>
    <div style="font-family: var(--font-body); font-size: 22px; line-height: 1.5;">
      Exposes the current list of open issues as browsable content.
      <br/><br/>
      <strong>No parameters. No execution.</strong> Claude reads it like a document.
      <br/><br/>
      Open-issue discovery — cheap.
    </div>
  </template>
</TwoColSlide>

<!--
Concrete. On the left — a tool: search_jira_issue. Takes a query, runs a search, returns matching issues dynamically. Call it, run it, get results back. Different query, different result set. On the right — a resource: jira://issues/open. Exposes the current list of all open issues as browsable content Claude can read without making a tool call at all. No parameters. No execution. Claude already knows what's there, just by reading the resource. Same backend — Jira — powering both. Different MCP primitive. Radically different agent behavior. The resource makes open-issue discovery cheap; the tool handles the targeted follow-up search.
-->

---

<CalloutBox variant="tip" title="Cost and reliability">

Resources cut exploratory tool calls. Fewer round-trips, less latency, less token cost — and Claude doesn't have to choose between a redundant list-the-catalog tool and the targeted-action tool.
<br/><br/>
Going back to 4.8 — tool count degrades selection reliability. <strong>Stuff readable as a resource is stuff you don't need as a tool.</strong>

</CalloutBox>

<!--
This matters for cost and reliability both. Resources cut exploratory tool calls. If Claude can see the open-issue list upfront as a resource, it doesn't call list_issues() to find out what exists — which means fewer tool-call round-trips, less latency, less token cost, and frankly less chance of the agent getting confused about which tool to call. Every tool you don't need is a selection decision Claude doesn't have to make. Which, going back to Lecture 4.8, matters — tool count degrades selection reliability, and "stuff I can read as a resource" is stuff I don't need as a tool. Exposing content as resources removes a class of selection decisions from the agent's plate entirely.
-->

---

<CalloutBox variant="tip" title="On the exam — keyword cues">

<strong>"Content catalog," "database schemas," "issue summaries," "documentation hierarchy"</strong> → resource.
<br/><br/>
<strong>"Action," "query," "execute," "process," "trigger"</strong> → tool.
<br/><br/>
Distractors swap the two primitives to catch inattentive readers.

</CalloutBox>

<!--
Here's the exam move. Keywords matter. If the question mentions "content catalog," "database schemas," "issue summaries," "documentation hierarchy" — anything that sounds like browsable listings — that's a resource. If the question mentions "action," "query with parameters," "execute," "process," "trigger" — anything that sounds like a verb with side effects — that's a tool. Task 2.4 tests this distinction directly, and the distractors often swap the two primitives in answer choices to catch candidates who aren't paying attention. Train your ear on those keywords, and when you see them, you'll know which primitive is correct before you've finished reading the answers.
-->

---

<AntiPatternSlide
  title="Don't force a catalog into a tool"
  :badExample="antipattern_bad"
  whyItFails="Token cost every call. Latency every call. Sometimes Claude skips it and guesses — worst of both worlds."
  :fixExample="antipattern_fix"
  lang="text"
/>

<!--
Anti-pattern. Forcing a catalog into a tool. Left side — search_all_docs() — a tool Claude calls every turn to discover what docs exist. Token cost every call. Round-trip latency every call. Worse, Claude sometimes skips the call entirely and guesses at what's available, which is the worst of both worlds. Right side — expose docs://catalog as a resource. Claude sees the catalog directly in context at the start of the conversation, references it without calling, and only uses a targeted tool call — like get_doc(id) — when it needs specific content. Better cost, better reliability, same underlying data. That's the cleanest pattern.
-->

---

<div class="di-close">
  <div class="di-close__inner">
    <div class="di-close__eyebrow">Next up</div>
    <h1 class="di-close__title">4.13 — <span class="di-close__accent">Grep, Glob, Read, Edit</span></h1>
    <div class="di-close__subtitle">Four built-ins. Four jobs. Pick wrong, waste context.</div>
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
Next up, Lecture 4.13 — built-in tool selection. Grep, Glob, Read, Edit. Each has one job. See you there.
-->
