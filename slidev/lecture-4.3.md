---
theme: default
title: "Lecture 4.3: Diagnosing and Fixing Tool Selection Failures"
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
const failure_modes = [
  { label: 'Overlap', detail: 'Two descriptions that look near-identical to the model.' },
  { label: 'Keyword hijack', detail: 'A word in the system prompt steers the pick.' },
  { label: 'Missing boundary', detail: "Neither description rules itself out when the other applies." },
]
const diagnostic_steps = [
  { label: 'Observe wrong pick', sublabel: 'In logs — confirm it\'s a pattern' },
  { label: 'Read descriptions', sublabel: 'Side-by-side on one screen' },
  { label: 'Audit system prompt', sublabel: 'Keyword collisions with tool names' },
  { label: 'Rewrite / rename', sublabel: 'Or both — the diagnosis tells you' },
]

const keyword_collision = `System prompt:
  "Analyze the user's request carefully before acting."

Tools available:
  analyze_content   ← model gravitates here
  analyze_document
  extract_summary

Fix: swap the word ("evaluate"), rename the tool, or both.`
</script>

<div class="di-cover">
  <div class="di-cover__inner">
    <div class="di-cover__eyebrow">Domain 2 · Lecture 4.3</div>
    <h1 class="di-cover__title">Diagnosing and Fixing<br/><span class="di-cover__accent">Tool Selection Failures</span></h1>
    <div class="di-cover__subtitle">Logs first. Hypothesis second. Fix third.</div>
  </div>
</div>

<style scoped>
.di-cover { position: absolute; inset: 0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%); color: var(--mint-100); }
.di-cover__inner { padding: 110px 120px 96px; height: 100%; display: flex; flex-direction: column; justify-content: center; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px; }
.di-cover__title { font-family: var(--font-display); font-weight: 500; font-size: 104px; line-height: 1.05; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1600px; }
.di-cover__accent { color: var(--sprout-500); }
.di-cover__subtitle { font-family: var(--font-display); font-size: 40px; color: var(--mint-200); margin-top: 40px; font-weight: 400; }
</style>

<!--
You've written the description. You've included all four parts. And the agent is still picking the wrong tool. What now? That's this lecture. Diagnostic workflow. Logs first, hypothesis second, fix third. Because the fix is almost always the description — but you have to confirm the cause before you rewrite.
-->

---

<BigQuote
  quote="The agent keeps calling <em>analyze_content</em> when it should call <em>analyze_document</em>. Both tools work. Why is it picking wrong?"
/>

<!--
Here's the setup. Scenario from the exam: "The agent keeps calling analyze_content when it should call analyze_document. Both tools work. Why is it picking wrong?" Both descriptions look reasonable in isolation. Both tools return useful output. The agent is confidently wrong. This is the Domain 2 trap in its purest form — almost-right at every layer.
-->

---

<BulletReveal
  title="What 'wrong tool' actually means"
  :bullets="failure_modes"
/>

<!--
When we say "wrong tool," we actually mean one of three things, and they look similar at first glance. One — overlap. Two descriptions that look near-identical to the model. Two — keyword hijack. A word in the system prompt that steers the pick regardless of description. Three — missing boundary. Neither tool's description rules itself out when the other would apply. Each one has a different fix. If you skip straight to rewriting without diagnosing which of the three is in play, you'll rewrite the wrong thing and the failure will persist under new words.
-->

---

<FlowDiagram
  title="From log to fix"
  :steps="diagnostic_steps"
/>

<!--
Here's the flow. Step one — observe the wrong pick in logs. Not once, a handful of times, so you know it's a pattern and not a one-off. Step two — read both descriptions side by side, on the same screen. You're looking for overlap, for lines that could apply to either tool, for missing boundary clauses. Step three — read the system prompt with those tool names in mind. You're looking for keyword collisions — the word "analyze" steering toward the analyze_* family, the word "lookup" steering toward lookup_*. Step four — rewrite the description, rename the tool, or both. The diagnosis tells you which. Skip any step and you're guessing.
-->

---

<TwoColSlide
  title="Fix 1 — Rename and rescope"
  leftLabel="Before"
  rightLabel="After"
>
  <template #left>
    <div style="font-family: var(--font-mono); font-size: 32px;">
      <strong>analyze_content</strong>
      <br/><br/>
      <span style="font-family: var(--font-body); font-size: 22px;">Competes with every other <code>analyze_*</code> tool in the agent. Name does no disambiguation work.</span>
    </div>
  </template>
  <template #right>
    <div style="font-family: var(--font-mono); font-size: 32px;">
      <strong>extract_web_results</strong>
      <br/><br/>
      <span style="font-family: var(--font-body); font-size: 22px;">Specific to the web-search output it handles. The rename does half the disambiguation work before the description even loads.</span>
    </div>
  </template>
</TwoColSlide>

<!--
First fix. Rename and rescope. Left column — the before: analyze_content. Right column — the after: extract_web_results. This is the exact fix cited in the exam guide Task 2.1. The name carries semantic weight, not just the description. analyze_content competes with every other analyze_* tool in the agent. extract_web_results doesn't compete with anything — it's specific to the web-search output it handles. The rename does half the disambiguation work before the description even loads.
-->

---

<CodeBlockSlide
  title="Fix 2 — System prompt audit"
  lang="text"
  :code="keyword_collision"
/>

<!--
Second fix. Audit the system prompt. This is the one people miss. If your system prompt says "analyze the user's request carefully before acting," that word "analyze" is steering the model toward any analyze_* tool. The description can be perfect and still get overridden by a keyword collision in the surrounding prompt. The exam guide calls this out explicitly — keyword-sensitive instructions can override well-written tool descriptions. Read your system prompt with the tool names loaded. Swap the word, rename the tool, or both.
-->

---

<CalloutBox variant="tip" title="Fix 3 — the one-line versus clause">

<strong>"Use for X. Do NOT use for Y — use <code>tool_Y</code> instead."</strong>
<br/><br/>
Adds nothing semantically. Disambiguates completely in the prose Claude actually reads. The cheapest high-leverage fix in this entire section. Every pair of tools that could collide should have this line in at least one description.

</CalloutBox>

<!--
Third fix. Add the versus clause. "Use for X. Do NOT use for Y — use tool_Y instead." Adds nothing semantically — the tools already only handle their respective cases. But it disambiguates completely in the prose Claude actually reads. If overlap is the diagnosis and rename isn't possible — maybe the name is already exposed in an external API contract — the versus clause does the work in prose. One line. Every pair of tools that could collide should have this line in at least one of their descriptions. It's the cheapest high-leverage fix in this entire section.
-->

---

<AntiPatternSlide
  title="Don't jump to a routing layer"
  badExample="Pre-parse user input.
Force tool selection based on keyword match.
Ship infrastructure to fix prose."
  whyItFails="Same anti-pattern from 4.1. Infrastructure answering a prose problem."
  fixExample="Rewrite description.
Confirm against eval set.
Escalate to routing ONLY if fix didn't take."
  lang="text"
/>

<!--
Don't jump to a routing layer. Same anti-pattern from 4.1, showing up again because it's that tempting. Pre-parsing the input, forcing tool selection based on keywords — it's infrastructure for a prose problem. The right escalation path: rewrite the description, confirm against an eval set, and then escalate to routing or consolidation if the fix didn't take. Routing is not the first move. Scenario 3 — multi-agent research — leans on this: the synthesis agent's tool confusion is almost always a description fix, not a router.
-->

---

<CalloutBox variant="tip" title="On the exam">

On Domain 2 tool-selection questions, the correct answer is <em>almost always</em> the one that rewrites the description, renames the tool, or adds the versus clause. Few-shots and routing classifiers are the distractor classics — plausible in a different context, not the proportionate first fix.

</CalloutBox>

<!--
Here's the exam move. On Domain 2 tool-selection questions, the correct answer is almost always the one that rewrites the description, renames the tool, or adds the versus clause. Few-shot examples and routing classifiers are the distractor classics — they're plausible in a different context, but they're not the proportionate first fix. Remember "almost-right is the whole trap of this exam." The proportionate answer is the one that matches the cost of the problem.
-->

---

<div class="di-close">
  <div class="di-close__inner">
    <div class="di-close__eyebrow">Next up</div>
    <h1 class="di-close__title">4.4 — <span class="di-close__accent">Splitting Generic Tools vs Consolidating</span></h1>
    <div class="di-close__subtitle">When one tool becomes three. When three become one.</div>
  </div>
</div>

<style scoped>
.di-close { position: absolute; inset: 0; background: var(--mint-100); color: var(--forest-800); }
.di-close__inner { padding: 110px 120px 96px; height: 100%; display: flex; flex-direction: column; justify-content: center; }
.di-close__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.14em; text-transform: uppercase; color: var(--teal-500); margin-bottom: 36px; }
.di-close__title { font-family: var(--font-display); font-weight: 500; font-size: 88px; line-height: 1.05; letter-spacing: -0.02em; color: var(--forest-900); margin: 0; max-width: 1600px; }
.di-close__accent { color: var(--sprout-600); }
.di-close__subtitle { font-family: var(--font-display); font-size: 38px; color: var(--forest-500); margin-top: 32px; font-weight: 400; }
</style>

<!--
Next up, Lecture 4.4 — splitting generic tools versus consolidating. When does one tool become three, and when do three tools become one? See you there.
-->
