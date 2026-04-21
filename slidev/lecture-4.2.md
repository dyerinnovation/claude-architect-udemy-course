---
theme: default
title: "Lecture 4.2: What Makes a Great Tool Description"
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
const anatomy_bullets = [
  { label: 'Purpose', detail: 'One sentence, unambiguous. What does this tool do?' },
  { label: 'Input formats', detail: 'What identifiers this tool actually accepts.' },
  { label: 'Example queries', detail: 'Two or three concrete examples of valid calls.' },
  { label: 'Boundaries', detail: 'When to use vs when NOT — the heaviest lifter.' },
]
const edge_bullets = [
  { label: 'Weird formats', detail: 'Pound signs, "order" prefixes, extra whitespace — say so.' },
  { label: 'Empty / null handling', detail: 'Return an error? Ask for one? Spell it out.' },
  { label: 'Collision case', detail: 'When two tools could apply — which wins and why.' },
]

const process_refund_code = `{
  "name": "process_refund",
  "description": "Issues a refund against a verified customer order.

  Input formats: Requires a confirmed order_id from lookup_order and
  a refund amount in USD cents.

  Example queries:
    - 'Refund the $49 charge on order 7821'
    - 'Cancel and refund order 9003 for damaged item'

  Boundaries: Use for refunds up to $500. For amounts above,
  use escalate_to_human. Do NOT call without a prior get_customer
  verification."
}`
</script>

<div class="di-cover">
  <div class="di-cover__inner">
    <div class="di-cover__eyebrow">Domain 2 · Lecture 4.2</div>
    <h1 class="di-cover__title">What Makes a <span class="di-cover__accent">Great Tool Description</span></h1>
    <div class="di-cover__subtitle">Four parts. Applied to a real tool.</div>
  </div>
</div>

<style scoped>
.di-cover { position: absolute; inset: 0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%); color: var(--mint-100); }
.di-cover__inner { padding: 110px 120px 96px; height: 100%; display: flex; flex-direction: column; justify-content: center; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px; }
.di-cover__title { font-family: var(--font-display); font-weight: 500; font-size: 116px; line-height: 1.05; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1600px; }
.di-cover__accent { color: var(--sprout-500); }
.di-cover__subtitle { font-family: var(--font-display); font-size: 40px; color: var(--mint-200); margin-top: 40px; font-weight: 400; }
</style>

<!--
Last lecture I told you descriptions are the lever. This one is about what a great description actually looks like. Not best practices in the abstract — four concrete parts, applied to a real tool. By the end of these eight minutes you'll be able to write a description that Claude picks correctly on the first try.
-->

---

<ConceptHero
  leadLine="Last lecture: descriptions are the lever."
  concept="This lecture: what goes in one."
  supportLine="Four parts. Every great tool description has all four. Miss one — you're back to the 12% misroute rate."
/>

<!--
Quick recap. Last lecture: tool descriptions are the number-one lever for selection reliability, and the evidence is that twelve-percent misroute rate the exam guide puts in front of you on Sample Question 1. This lecture: what goes into a great one. Four parts. Every great tool description has all four. Miss one and you're back to the twelve-percent misroute rate from 4.1. Get all four and the routing problem mostly disappears. That's the simple framing. Now let's actually put it together.
-->

---

<BulletReveal
  title="Anatomy of a useful description"
  :bullets="anatomy_bullets"
/>

<!--
Here are the four. Purpose — one sentence, unambiguous. Input formats — what identifiers this tool actually accepts. Example queries — two or three concrete examples of what a valid call looks like. Boundaries — when to use this versus when NOT to. That last one is the one most descriptions skip, and it's the one that does the heaviest lifting. These four are the anchor concept for this domain. Get the anchor concept first — the same move 1.1 told you to make at the domain level, now at the tool level.
-->

---

<CodeBlockSlide
  title="Applied: process_refund"
  lang="json"
  :code="process_refund_code"
/>

<!--
Let me show you this applied. Here's process_refund with all four parts. Purpose: "Issues a refund against a verified customer order." Input formats: "Requires a confirmed order_id from lookup_order and a refund amount in USD cents." Example queries: "Refund the $49 charge on order 7821," and "Cancel and refund order 9003 for damaged item." Boundaries: "Use for refunds up to five hundred dollars. For amounts above, use escalate_to_human. Do NOT call without a prior get_customer verification." That's it. One description. Claude knows exactly when to call this tool and when not to.
-->

---

<CalloutBox variant="warn" title="The 'versus' clause">

"Use for refunds up to $500. For amounts above, use <code>escalate_to_human</code>." That one sentence eliminates ~80% of misroutes. Semantically it adds nothing — the limit is in business logic anyway. But for the model choosing between two plausible tools, this is what breaks the tie.

</CalloutBox>

<!--
That last line is the one to pay attention to. "Use for refunds up to five hundred dollars. For amounts above, use escalate_to_human." The versus clause. It's the single sentence that eliminates most misroutes. Semantically it adds nothing — the dollar limit exists in your business logic anyway. But for the model, staring at two tools that both look plausible, the versus clause is what breaks the tie. This is the line that converts a forty-percent confidence call into a ninety-percent confidence call.
-->

---

<BulletReveal
  title="Include the weird inputs"
  :bullets="edge_bullets"
/>

<!--
Part of a great description is telling Claude what the weird inputs look like. Formats the model might actually see — customers paste order numbers with pound signs, with "order" prefixed, with extra whitespace. Say so. What to do with empty or null — if the user asks to refund an order with no order ID, does the tool return an error or ask for one? Say so. And the collision case — when two tools could apply, which one wins and why. Spell it out in prose. These edge cases aren't comprehensive — they're targeted. Two or three lines that cover the failure modes you've actually seen.
-->

---

<TwoColSlide
  title="Generic vs Complete"
  leftLabel="Generic (5 words)"
  rightLabel="Complete (~60 words)"
>
  <template #left>
    <div style="font-family: var(--font-mono); font-size: 24px; line-height: 1.6;">
      "Processes customer refunds."
      <br/><br/>
      <span style="font-family: var(--font-body); font-size: 22px; color: var(--clay-500);">No input shape. No example. No boundary. 12% misroute rate in production.</span>
    </div>
  </template>
  <template #right>
    <div style="font-family: var(--font-mono); font-size: 18px; line-height: 1.5;">
      Purpose + Input formats + Example queries + Boundaries
      <br/><br/>
      <span style="font-family: var(--font-body); font-size: 22px; color: var(--sprout-600);">Written once. Every subsequent call benefits. Highest ROI prompt-engineering move.</span>
    </div>
  </template>
</TwoColSlide>

<!--
Side by side. On the left, generic: "Processes customer refunds." Five words. Model has nothing to work with — no input shape, no example, no boundary. On the right, complete: the full process_refund description from slide 4 — purpose, inputs, examples, boundaries. Maybe sixty words. That's the investment. Sixty words, written once, versus a twelve-percent misroute rate in production. There is no other prompt-engineering move with a higher return on effort. You write the description once, every subsequent call benefits, and you never have to touch the agent loop or the system prompt to fix selection.
-->

---

<CalloutBox variant="tip" title="On the exam">

Sample Question 2, answer B: <strong>"Expand each tool's description to include input formats, example queries, edge cases, and boundaries."</strong> Memorize those four words. Few-shots, routing, consolidation — those are the distractors.

</CalloutBox>

<!--
Here's the direct exam connection. Sample Question 2 from the exam guide asks what's the most effective first step when descriptions are minimal and two tools — get_customer and lookup_order again — are getting confused. The correct answer is B — and the wording is almost verbatim what I just gave you: "Expand each tool's description to include input formats, example queries, edge cases, and boundaries." Memorize those four words. If you see them in an answer choice on exam day, that's your signal. Few-shot examples, routing layers, consolidating into one lookup_entity — those are the distractors. Each one is plausible in a different context. None of them is the proportionate first move. The description rewrite is.
-->

---

<div class="di-close">
  <div class="di-close__inner">
    <div class="di-close__eyebrow">Next up</div>
    <h1 class="di-close__title">4.3 — <span class="di-close__accent">Diagnosing and Fixing Tool Selection Failures</span></h1>
    <div class="di-close__subtitle">From log to fix — the diagnostic workflow.</div>
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
Next up, Lecture 4.3 — diagnosing tool selection failures. We'll take a concrete bad case and walk the workflow from log to fix. See you there.
-->
