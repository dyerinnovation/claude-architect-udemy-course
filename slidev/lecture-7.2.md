---
theme: default
title: "Lecture 7.2: Progressive Summarization Risks"
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
const erasedBullets = [
  { label: 'Specific dollar amounts', detail: '"$47.82" → "a refund"' },
  { label: 'Dates', detail: '"by Friday the 15th" → "soon"' },
  { label: 'Order numbers', detail: '"739421" → "the order"' },
  { label: 'Stated customer expectations', detail: '"replaced, not refunded" → "return options discussed"' },
  { label: 'Numerical thresholds', detail: 'Specifics softened into prose' },
]

const antiPatternBad = `Every turn: compress prior turns into natural language.

"The customer requested a refund and discussed options."

→ Specific amounts, dates, and verbatim expectations erased.`

const antiPatternFix = `Summarize conversational flow AND
persist facts in a structured block.

Prose memory   → tone, escalation, what was discussed
Facts block    → refund_amount: 47.82
                 stated_outcome: "replacement, not refund"`
</script>

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div class="di-cover">
    <div class="di-cover__eyebrow">Domain 5 · Lecture 7.2</div>
    <div class="di-cover__title">Progressive Summarization Risks</div>
    <div class="di-cover__subtitle">What gets lost when memory compresses</div>
  </div>
</Frame>

<style scoped>
.di-cover { flex: 1; display: flex; flex-direction: column; justify-content: center; gap: 32px; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 28px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); }
.di-cover__title { font-family: var(--font-display); font-size: 132px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); max-width: 1500px; }
.di-cover__subtitle { font-family: var(--font-display); font-size: 44px; color: var(--mint-200); font-style: italic; }
</style>

<!--
Lecture 7.2. Progressive summarization risks. If 7.1 was about where information lives inside a single prompt, this one is about what happens to information as a conversation keeps going — turn after turn, summary after summary.

Progressive summarization is the default memory strategy for most long-running agents. It sounds right. You keep recent turns verbatim, and every few turns you compress the older history into a natural-language recap. That's how most memory libraries ship by default. And it has a specific failure mode the exam tests directly.
-->

---

<BigQuote
  lead="The failure mode"
  quote="The customer said they wanted <em>$47.82</em>. Two summary rounds later, the agent remembers they 'requested a refund.'"
  attribution="First-contact resolution fails — and nobody can trace why"
/>

<!--
Here's the scenario that opens this lecture. The customer said they wanted a refund of forty-seven dollars and eighty-two cents. Two summary rounds later, the agent remembers they "requested a refund." That's the failure. The dollar amount — the exact number the customer stated — is gone. And the agent is now operating on a summary of a summary, confident that it knows what the customer wants. It doesn't.

If the agent closes the ticket by offering a standard thirty-dollar credit, it's missed the stated expectation by eighteen dollars. The customer re-opens. First-contact resolution fails. And nobody — neither the agent nor the downstream analytics — can trace why, because the summary looks plausible on inspection.
-->

---

<BulletReveal
  title="Summarization losses"
  :bullets="erasedBullets"
/>

<!--
When you summarize a conversation progressively — meaning every few turns you compress prior history into a shorter natural-language recap — you reliably erase a specific class of information. Specific dollar amounts. Dates. Order numbers. Stated customer expectations. Numerical thresholds. Anything with a precise numeric or transactional value gets softened into a phrase.

"Forty-seven dollars and eighty-two cents" becomes "a refund." "By Friday the fifteenth" becomes "soon." "Order number seven-three-nine-four-two-one" becomes "the order." "I want it replaced, not refunded" becomes "discussed return options." These are not equivalent. They were the specifics the customer cared about, and now they're prose — softer, friendlier, wrong.

This isn't a tuning problem. It's inherent to how natural-language summarization works — it compresses distinctiveness out of text. The fix isn't "summarize better." It's "don't summarize this class of information at all."
-->

---

<CalloutBox variant="warn" title="Why it's dangerous in Scenario 1">

Customer support lives or dies on honoring what the customer said — not a vague paraphrase of it.

The summarization that makes the conversation fit the context window is the same summarization that quietly rewrites what the customer asked for. Same mechanism. Two opposite consequences — one helpful, one damaging.

</CalloutBox>

<!--
Scenario 1 is customer support. Customer support lives or dies on honoring what the customer said — not a vague paraphrase of it. If your agent loses the dollar amount, it might offer the wrong refund. If it loses the stated expectation, it might close a ticket the customer considered unresolved. If it loses the deadline, the customer calls back asking where their replacement is.

The summarization that makes the conversation fit the context window is the same summarization that quietly rewrites what the customer asked for. Same mechanism. Two opposite consequences — one helpful, one damaging. You can't adjust one without affecting the other, because they're the same operation.
-->

---

<CalloutBox variant="tip" title="The fix — preview of 7.4">

Extract transactional facts into a persistent "case facts" block. Don't summarize those.

<p>Two layers of memory: prose summary for narrative (tone, escalation history, options discussed). Structured block for numeric precision. Don't try to make one layer do both jobs.</p>

</CalloutBox>

<!--
The fix is coming in 7.4 — the persistent case-facts block. The short version: transactional facts don't belong in prose. Extract them into structured storage. Reference the structured block every turn. Summarize the conversational flow all you want — tone, escalation history, what options were discussed — but the numbers live outside the summary, in a place where compression can't touch them.

Two layers of memory. The prose summary is fine for narrative. The structured block is the only safe place for numeric precision. Don't try to make one layer do both jobs.
-->

---

<AntiPatternSlide
  title="Don't summarize everything at each turn"
  lang="text"
  :badExample="antiPatternBad"
  whyItFails="Compression is lossy in exactly the ways that matter for transactional domains."
  :fixExample="antiPatternFix"
/>

<!--
The anti-pattern: every turn, compress prior turns into natural language. That's how most naive memory systems work, and it's how specifics quietly die. The system looks clever — "the agent has memory!" — but the memory it has is lossy in exactly the ways that matter for a transactional domain.

The better pattern: summarize conversational flow AND persist facts in a structured block. You keep the prose memory for tone and context — "the customer is frustrated because this is their second call" — and you keep the facts in a schema for correctness — "refund_amount: 47.82." Two layers, two responsibilities, no contamination.
-->

---

<CalloutBox variant="tip" title="On the exam">

"Agent forgets specific amounts/dates" → progressive summarization risk.

The right answer is <strong>structured persistent facts</strong>, not longer summaries. The distractor — "use a larger model" or "longer summaries" — is almost-right. Longer summaries still summarize; larger models still lose precision under compression.

</CalloutBox>

<!--
On the exam, the shape is: "The agent forgets specific amounts and dates across a long session." That's the progressive-summarization tell. The right answer is structured persistent facts — a case-facts block, or whatever the question labels it. The distractor is "use longer summaries" or "add a larger model." Almost-right — longer summaries still summarize, and larger models still lose precision under compression. This is another case where almost-right is the whole trap of this exam.

The exam sometimes writes this as "the agent lost track of what the customer asked for over the course of a fifteen-turn conversation." Same tell. Different words.
-->

---

<BigQuote
  lead="Continuity"
  quote="Scenario 1 — customer support — this is where <em>judgment questions</em> live."
  attribution="Progressive summarization is one of the top trap concepts"
/>

<!--
Scenario 1 — customer support — is where judgment questions on Domain 5 live. Remember the six-pick-four: you don't know which four scenarios show up on your exam, so skipping Scenario 1 isn't an option. And on Scenario 1, progressive summarization is one of the top trap concepts. Get this lecture, get 7.4, and you've locked in a cluster of questions that commonly appears together.
-->

---

<Frame bg="var(--mint-100)">
  <Eyebrow>Closing</Eyebrow>
  <SlideTitle>Next up: 7.3 — Trimming Verbose Tool Outputs.</SlideTitle>

  <div class="closing-body">
    <p>If summarization is one way context degrades, verbose tool results are the other — and the fix is just as structural.</p>
  </div>
</Frame>

<style scoped>
.closing-body { margin-top: 56px; font-family: var(--font-body); font-size: 30px; line-height: 1.5; color: var(--forest-500); max-width: 1400px; }
</style>

<!--
Next up: 7.3, trimming verbose tool outputs. If summarization is one way context degrades, verbose tool results are the other — and the fix is just as structural. See you there.
-->
