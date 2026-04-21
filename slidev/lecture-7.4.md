---
theme: default
title: "Lecture 7.4: The Case Facts Block"
info: |
  Claude Certified Architect – Foundations
  Section 7 — Context & Reliability (Domain 5, 15%)
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
const caseFactsCode = `{
  "customer_id": "C-9921",
  "order_ids": ["O-739421"],
  "amounts": {
    "refund_requested": 47.82,
    "currency": "USD"
  },
  "stated_expectations": [
    "Replacement, not refund — stated on turn 3"
  ],
  "policy_constraints": [
    "Within 30-day return window",
    "Electronics: manager approval required >$50"
  ],
  "timestamps": {
    "refund_requested_at": "2026-04-12T14:22:00Z"
  }
}`

const locationRows = [
  { label: 'Casual conversation', cells: [{ text: 'Summarized history', highlight: 'neutral' }] },
  { label: 'Dollar amounts, dates', cells: [{ text: 'Case-facts block', highlight: 'good' }] },
  { label: 'Stated customer requests', cells: [{ text: 'Case-facts block', highlight: 'good' }] },
  { label: 'Explored options', cells: [{ text: 'Summarized history', highlight: 'neutral' }] },
]

const antiPatternBad = `Trust prior summaries to preserve amounts.

"The summary says the customer wanted a refund."
 — for how much?
"Uh, it doesn't say."

Also avoid: inflating the block with non-facts.
("customer_mood: frustrated" — that's narrative.)`

const antiPatternFix = `Extract amounts at the moment the
customer states them. Reference the
block every turn.

Keep the block tight — transactional data only.
Narrative belongs in the summary. Facts
belong in the block. Don't mix.`
</script>

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div class="di-cover">
    <div class="di-cover__eyebrow">Domain 5 · Lecture 7.4</div>
    <div class="di-cover__title">The Case Facts Block</div>
    <div class="di-cover__subtitle">Structured persistence for transactional facts</div>
  </div>
</Frame>

<style scoped>
.di-cover { flex: 1; display: flex; flex-direction: column; justify-content: center; gap: 32px; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 28px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); }
.di-cover__title { font-family: var(--font-display); font-size: 132px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); max-width: 1500px; }
.di-cover__subtitle { font-family: var(--font-display); font-size: 44px; color: var(--mint-200); font-style: italic; }
</style>

<!--
Lecture 7.4. The persistent case-facts block pattern. This is the single most exam-critical pattern in Domain 5 for Scenario 1 — customer support. Memorize the shape, memorize why it works, and you've locked in a question that shows up in almost every practice pool and in the official sample questions.

Everything in 7.2 and 7.3 was setup for this lecture. Progressive summarization erases numbers; verbose tool outputs clutter context. The case-facts block is the structural pattern that solves both problems at once for transactional conversations.
-->

---

<ConceptHero
  leadLine="Facts don't belong in prose"
  concept="Structure beats narrative."
  supportLine="Transactional facts live in structured storage, not conversation history. That's how they survive summarization."
/>

<!--
Here's the claim. Facts don't belong in prose. Transactional facts — dollar amounts, dates, order numbers, stated expectations — live in structured storage, not in conversation history. That's how they survive summarization. That's how they survive session restarts. That's how they stop silently drifting across long conversations.

The mental move is: stop thinking about conversation memory as one unified thing. There are two memory surfaces. One is narrative — the flow of the conversation, the tone, the escalation history. That one can be summarized. The other is structured — the transactional facts that must remain precise. That one doesn't get summarized, ever.
-->

---

<CodeBlockSlide
  title="Case facts block"
  lang="json"
  :code="caseFactsCode"
  annotation="A schema, not a paragraph. Every field has a type."
/>

<!--
The structure is a JSON block. Customer_id. Order_id, or order_ids if the session touches multiple orders. Amounts — including the specific cents, not rounded. Stated_expectations — the exact phrasing the customer used, pulled verbatim where it matters. Policy_constraints that apply to this case. Timestamps for each fact.

It's a schema, not a paragraph. Every field has a type, and every value either exists or is null — no "the customer mentioned something about forty dollars" fuzziness. If the customer said forty-seven eighty-two, the field is 47.82, not "about forty dollars." If the customer said "by Friday," the field is the specific Friday date with timezone, not "soon."
-->

---

<CalloutBox variant="tip" title="Where it lives — every prompt">

Prepend the block to each turn. Outside summarized conversation history. Part of the context contract.

When you summarize prior turns, you're summarizing narrative. When you reference the case-facts block, you're reading a data structure. Two separate channels. Neither erases the other.

</CalloutBox>

<!--
The block lives outside summarized conversation history. Every prompt — every single turn — prepends the case-facts block. It's not part of the conversation that gets compressed. It's part of the context contract. When you summarize prior turns, you're summarizing narrative. When you reference the case-facts block, you're reading a data structure. Two separate channels. Neither erases the other.

In practice, this means the system prompt or the turn-construction code always inserts the block above the compressed history. Tooling matters here — if your memory library doesn't let you inject a separate structured block, you'll have to build that layer. Don't skip it.
-->

---

<ComparisonTable
  title="Where facts go"
  :columns="['Location']"
  :rows="locationRows"
/>

<!--
Compare the two locations directly. Casual conversation — "the customer is frustrated about a late delivery" — goes in summarized history. That's fine to paraphrase. Dollar amounts, dates, stated customer requests go in the case-facts block. Never paraphrased. Explored options — "we discussed a refund or a replacement" — go back in summarized history.

The rule: if it's transactional or if the customer said it verbatim, it's a fact. If it's context or tone, it's prose. The split is simple once you internalize it, but it requires discipline — the temptation is to "just summarize everything" for simplicity, and that's what breaks.
-->

---

<CalloutBox variant="tip" title="Multi-issue sessions — structured entry per issue">

Order + billing + return? Each gets its own structured entry in the case-facts block.

Structured: <code>order_issue, billing_issue, return_issue</code> each as its own object — stays actionable. A single prose blob that blends them loses all three.

</CalloutBox>

<!--
Real customer sessions often touch multiple issues. An order problem, then a billing question, then a return. Each issue gets its own structured entry in the case-facts block — not a single prose blob that blends them. Order issue has its own order_id, its own amounts, its own stated outcome. Billing issue has its own. Return has its own.

Keep them separate or you'll summarize them together, and once you do, you can't untangle them. "The customer had questions about an order, a bill, and a return" is useless when the agent needs to act on any one of them. "order_issue: {...}, billing_issue: {...}, return_issue: {...}" stays actionable.
-->

---

<CalloutBox variant="note" title="Why this matters in Scenario 1">

Customer-support agents regularly lose track of amounts across summaries (7.2 — progressive summarization risk). The case-facts block is the structural fix.

You don't tell the model to "remember harder." You externalize the memory into a place where forgetting isn't possible — it's a schema field, not a sentence that can be rewritten.

</CalloutBox>

<!--
This is why it matters in Scenario 1. Customer support agents regularly lose track of amounts across summaries — we covered that in 7.2 as progressive summarization risk. The case-facts block is the structural fix. You don't tell the model to "remember harder." You externalize the memory into a place where forgetting isn't possible, because it's a schema field, not a sentence that can be rewritten.

The exam treats this as table-stakes knowledge for Scenario 1. If you see a question about preserving transactional data across long support conversations, the answer is this pattern.
-->

---

<AntiPatternSlide
  title="Don't rely on conversation history"
  lang="text"
  :badExample="antiPatternBad"
  whyItFails="Summarization softens amounts into prose. Non-facts bloat the schema and go stale."
  :fixExample="antiPatternFix"
/>

<!--
The anti-pattern: trust prior summaries to preserve amounts. "The summary says the customer wanted a refund." Great — for how much? "Uh, it doesn't say." That's the failure mode. The better pattern: extract amounts to the facts block at the moment the customer states them, and reference the block every turn. The summary is for tone. The block is for correctness.

There's a second anti-pattern worth flagging — inflating the block with non-facts. "customer_mood: frustrated" does not belong in a facts block. That's narrative, it's paraphrased, and it'll go stale. Keep the block tight. Transactional data only.
-->

---

<CalloutBox variant="tip" title="On the exam">

"Preserve transactional facts across long customer conversations" → persistent structured facts block.

The distractor — "use a larger model" or "longer summaries" — is the same trap from 7.2 and 7.3. Larger models still lose specifics to summarization. Structural fix wins every time.

</CalloutBox>

<!--
On the exam, the shape is: "Preserve transactional facts across long customer conversations." The right answer is a persistent structured facts block. The distractor, again, is "use a larger model" or "longer summaries." Same trap pattern from 7.2 and 7.3 — almost-right. Larger models still lose specifics to summarization. The structural fix is the correct answer every time. This is a Domain 5 pattern that maps directly to Scenario 1 and also informs Scenario 3 — the same "structured persistence beats unstructured memory" principle.
-->

---

<Frame bg="var(--mint-100)">
  <Eyebrow>Closing</Eyebrow>
  <SlideTitle>Next up: 7.5 — Escalation Decision Framework.</SlideTitle>

  <div class="closing-body">
    <p>When does the agent resolve, and when does it hand off to a human? Very specific triggers — and two very specific wrong ones. Remember the shape of 7.5 when you get to 7.14.</p>
  </div>
</Frame>

<style scoped>
.closing-body { margin-top: 56px; font-family: var(--font-body); font-size: 30px; line-height: 1.5; color: var(--forest-500); max-width: 1400px; }
</style>

<!--
Next up: 7.5, the escalation decision framework. When does the agent resolve, and when does it hand off to a human? This one has a very specific set of triggers — and two very specific wrong ones. It's also a lecture that pairs tightly with 7.14, so remember the shape of 7.5 when you get to 7.14. See you there.
-->
