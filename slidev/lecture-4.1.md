---
theme: default
title: "Lecture 4.1: Why Tool Descriptions Are the Most Important Thing You Write"
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
const s5_bullets = [
  { label: 'Name', detail: 'The identifier Claude sees first — semantic weight.' },
  { label: 'One-line summary', detail: 'Short hint, usually insufficient on its own.' },
  { label: 'Input schema', detail: 'Argument shapes — matters for calling, not routing.' },
  { label: 'Your prose', detail: 'The lever. This is what drives the selection decision.' },
]
</script>

<div class="di-cover">
  <div class="di-cover__inner">
    <div class="di-cover__eyebrow">Domain 2 · Lecture 4.1</div>
    <h1 class="di-cover__title">Why Tool Descriptions Are the Most<br/><span class="di-cover__accent">Important Thing You Write</span></h1>
    <div class="di-cover__subtitle">Section 4 — Tool Design &amp; MCP Integration · 18%</div>
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
Welcome to Domain 2. Eighteen percent of your exam. And if you only take one thing from this entire section, take this: the single most important piece of code you'll write for an agent isn't the agent loop, the system prompt, or the tool implementation. It's the tool description. This lecture is about why.
-->

---

<BigQuote
  lead="Production logs · 12% of cases"
  quote="Agent skipped <em>get_customer</em> entirely and called <em>lookup_order</em> using only the customer's stated name."
  attribution="Sample Question 1, exam guide"
/>

<!--
Here's what the exam is actually testing. Production logs, Scenario 1 — customer support. Twelve percent of cases, the agent skips get_customer entirely and calls lookup_order using only the customer's stated name. That's real money on the line. Misidentified accounts. Wrong refunds. Sample Question 1 from the exam guide opens with exactly this failure. The agent isn't broken. The loop isn't broken. Claude is picking the wrong tool — and picking it confidently — one time out of eight. That's where this domain lives.
-->

---

<ConceptHero
  leadLine="Tool selection happens in the description, not the code."
  concept="The description IS the prompt."
  supportLine="Minimal descriptions produce unreliable selection among similar tools. Reliably unreliable."
/>

<!--
So here's the core claim. Tool selection happens in the description, not the code. The description Claude reads is a prompt — the exact same prompt it uses for everything else. Minimal descriptions produce unreliable selection among similar tools. Not sometimes. Reliably unreliable. The description isn't metadata. It's not documentation. It's the single piece of text Claude uses, at every turn, to decide which tool to call. If that text is weak, selection is weak. Everything flows from understanding that.
-->

---

<TwoColSlide
  title="Same tool, same schema. Only prose changed."
  leftLabel="Minimal (wrong 12%)"
  rightLabel="Differentiated (right)"
>
  <template #left>
    <div style="font-family: var(--font-mono); font-size: 22px; line-height: 1.5;">
      <strong>get_customer</strong><br/>
      "Retrieves customer information."<br/><br/>
      <strong>lookup_order</strong><br/>
      "Retrieves order details."
    </div>
  </template>
  <template #right>
    <div style="font-family: var(--font-mono); font-size: 20px; line-height: 1.5;">
      <strong>get_customer</strong><br/>
      "Retrieves customer identity and verification status. Use BEFORE any order operation. Input: customer_id or email. Do NOT use for order lookups — use <code>lookup_order</code> instead."
    </div>
  </template>
</TwoColSlide>

<!--
Look at the difference. On the left, the minimal version — the one that produces the twelve-percent failure rate. get_customer: "Retrieves customer information." That's it. Seven words. And then lookup_order: "Retrieves order details." Another six words. Two tools with near-identical shapes, near-identical prose. Claude has nothing to choose between them. On the right, the differentiated version. get_customer: "Retrieves customer identity and verification status. Use BEFORE any order operation. Input: customer_id or email. Do NOT use for order lookups — use lookup_order instead." That's the fix. Same tool, same backend, same schema. The only thing that changed is the prose. Misroutes drop to near zero.
-->

---

<BulletReveal
  title="The description is a context-window line item"
  :bullets="s5_bullets"
/>

<!--
Hold that in mind while I show you what Claude actually sees at selection time. It's four things. The tool name. A one-line summary. The input schema. And your prose. That prose is the lever. The name matters — we'll come back to that in 4.3. The schema matters for arguments, not routing. But for the question of "which tool do I call right now?", Claude is reading your prose. If the prose is vague, the decision is a coin flip between plausible options. If the prose is differentiated, the decision is easy.
-->

---

<BigNumber
  number="12%"
  unit=" misroute rate"
  caption="Minimal descriptions → wrong tool picked in one out of eight production cases"
  detail="Sample Question 1 cites this directly. 88% looks fine — until you realize what one-in-eight means in customer support."
/>

<!--
Twelve percent. One in eight calls. That's the misroute rate that the exam puts in front of you with minimal descriptions. And that's not theoretical — the exam guide cites it directly in Sample Question 1. Eighty-eight percent success looks almost okay on a dashboard, until you realize what it means in customer support: one in eight refunds goes to the wrong account. That number is the reason Domain 2 carries eighteen percent of the exam weight. Selection reliability is the production problem.
-->

---

<CalloutBox variant="tip" title="Exam move">

Domain 2 distractors look correct at the system-prompt layer — routing classifiers, consolidation, few-shot examples. The root cause is almost always the description. Remember from 1.1: "almost-right is the whole trap of this exam." This is the canonical example.

</CalloutBox>

<!--
Here's the exam move. Domain 2 questions will hand you a distractor that looks reasonable. Few-shot examples showing the agent calling the right tool. A routing classifier that parses user input before each turn. Consolidating two tools into one lookup_entity. These aren't wrong everywhere — they're wrong as the first move when the root cause is the description. And the root cause is almost always the description. Remember that phrase from Lecture 1.1 — "almost-right is the whole trap of this exam." This is the canonical example.
-->

---

<AntiPatternSlide
  title="Don't fix this with a routing classifier"
  badExample="Pre-parse user input. Enable only tool subset per turn.
Build a keyword router in front of the agent."
  whyItFails="Infrastructure answering a prose problem."
  fixExample="Rewrite the description first.
Confirm with an eval set.
Escalate to routing only if prose doesn't solve it."
  lang="text"
/>

<!--
Don't reach for the routing classifier. That's the anti-pattern. Pre-parsing user input, enabling only a subset of tools per turn — it's infrastructure answering a prose problem. The proportionate fix rewrites the description first, confirms with an eval set, and only escalates to routing or consolidation if differentiated prose doesn't solve it. If you see a distractor proposing a classifier, treat it as the almost-right trap. The exam is testing whether you jump to infrastructure or stay on the proportionate lever.
-->

---

<ConceptHero
  leadLine="One line to hold onto"
  concept="Descriptions are the #1 lever."
  supportLine="Every other fix — few-shots, routers, consolidation — is downstream of this. Scenario 1 lives or dies on this."
/>

<!--
One line to hold onto. Descriptions are the number-one lever for tool-selection reliability. Every other fix — few-shots, routers, consolidation, splitting — is downstream of this. Scenario 1 lives or dies on this. If you can name the tool-selection root cause in under ten seconds on exam day, you've banked points on multiple Domain 2 questions.
-->

---

<div class="di-close">
  <div class="di-close__inner">
    <div class="di-close__eyebrow">Next up</div>
    <h1 class="di-close__title">4.2 — <span class="di-close__accent">What Makes a Great Tool Description</span></h1>
    <div class="di-close__subtitle">Four parts. Every great description has all four.</div>
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
Next up, Lecture 4.2 — what actually goes into a great tool description. Four parts. Every great description has all four. See you there.
-->
