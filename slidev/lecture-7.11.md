---
theme: default
title: "Lecture 7.11: Context Degradation in Long Sessions"
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
const detectionBullets = [
  { label: '"Typically" appears in answers', detail: '"Usually," "in code like this" — generic filler replacing specifics.' },
  { label: 'Earlier specifics no longer quoted', detail: 'Class names, file paths, line numbers absent from later turns.' },
  { label: 'Answers feel generic', detail: 'Pattern-matching from training data, not from what was read earlier.' },
]

const countermeasureRows = [
  { label: 'Scratchpads', cells: [{ text: '7.12', highlight: 'good' }] },
  { label: 'State manifests (crash recovery)', cells: [{ text: '7.13', highlight: 'good' }] },
  { label: 'Subagent delegation + /compact', cells: [{ text: '5.11 + 5.15', highlight: 'good' }] },
]
</script>

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div class="di-cover">
    <div class="di-cover__eyebrow">Domain 5 · Lecture 7.11</div>
    <div class="di-cover__title">Context Degradation<br/>in Long Sessions</div>
    <div class="di-cover__subtitle">When sessions start referencing "typical patterns"</div>
  </div>
</Frame>

<style scoped>
.di-cover { flex: 1; display: flex; flex-direction: column; justify-content: center; gap: 32px; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 28px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); }
.di-cover__title { font-family: var(--font-display); font-size: 112px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); max-width: 1500px; }
.di-cover__subtitle { font-family: var(--font-display); font-size: 40px; color: var(--mint-200); font-style: italic; }
</style>

<!--
Lecture 7.11. Context degradation in long sessions. This is a Scenario 2 and Scenario 4 problem — the code-generation and developer-productivity scenarios — where a single long session starts producing inconsistent answers because it's forgotten its own early exploration.

If 7.2's progressive summarization is what happens to customer-support transactions across turns, this lecture is what happens to code-exploration findings across turns. Different symptom, same underlying cause: specifics dilute as conversation grows.
-->

---

<BigQuote
  lead="The exam's keyword"
  quote="Models start giving inconsistent answers and referencing <em>'typical patterns'</em> rather than specific classes discovered earlier."
  attribution="When 'typically' shows up in answers → you've lost specifics to degradation"
/>

<!--
Here's the quote I want you to memorize as the exam's keyword. "Models start giving inconsistent answers and referencing 'typical patterns' rather than specific classes discovered earlier." That's the tell. When the model drops from "the OrderProcessor class at /src/services/orders.py line forty-two" back to "typically, in code like this, there's usually a service class…" — you've lost specifics to degradation.

The agent isn't lying. It isn't getting worse at the task. It's just operating on a diluted version of its own earlier findings, and generic knowledge is filling the space where specifics used to live.
-->

---

<ConceptHero
  leadLine="Specifics dilute"
  concept="Generic fills the gap."
  supportLine="Early facts get buried under intervening conversation. The model falls back to training data — 'typical,' 'usually,' 'in code like this.'"
/>

<!--
Specifics dilute. In an early turn, the model read the actual code, extracted the actual class names, and referenced them. Ten turns later, those specifics are buried under intervening conversation. The model's attention — limited by the same lost-in-the-middle dynamic we covered in 7.1 — can't reliably surface the early findings. So it falls back to generic knowledge. "Typically." "Usually." "In code like this."

Generic answers are the degraded state. Specifics are what got lost. Once you recognize the pattern, you stop wondering why the session suddenly got dumber — it didn't; it just lost its own notes.
-->

---

<BulletReveal
  title="How to spot it"
  :bullets="detectionBullets"
/>

<!--
How do you spot it in practice? Three signs. One: the word "typically" starts showing up in answers. Two: earlier specifics stop getting quoted — the class names, file paths, and line numbers the model knew in turn three are absent in turn thirteen. Three: answers feel generic, pattern-matching, text-book — like the model is reasoning from its training data rather than from the code it read earlier in the session.

That triangle is degradation. Once you see it, you stop trusting the session and do one of the fixes below.
-->

---

<ComparisonTable
  title="Three countermeasures"
  :columns="['Covered in']"
  :rows="countermeasureRows"
/>

<!--
Three countermeasures, all covered elsewhere in the course. Scratchpad files — next lecture, 7.12. State manifests for crash recovery — 7.13, which also helps with long-session state. And subagent delegation with /compact — we covered those in Section 5, lectures 5.11 and 5.15. Three tools. Same goal: keep the specifics accessible even as the raw conversation grows too long for the model to track.

The mental move is: you don't fight degradation by telling the model to "remember harder." You externalize the memory into mechanisms where forgetting isn't possible — files, state manifests, fresh subagent contexts.
-->

---

<CalloutBox variant="tip" title="Fresh beats resumed">

When prior tool results are stale, a fresh session with an injected summary often beats resume. Callback to Domain 1 Task 1.7.

<p>The math: degraded context costs you every turn; fresh context with a clean summary costs one turn of injection, then runs clean. The conversation is disposable once a scratchpad or state manifest exists — the work is already captured there.</p>

</CalloutBox>

<!--
There's a fourth option — restart the session. When prior tool results are stale, a fresh session with an injected summary often beats trying to resume. That's a callback to Domain 1 Task 1.7. The math: degraded context costs you every turn; fresh context with a clean summary costs you one turn of injection, then runs clean. For exploration-heavy sessions, fresh beats resumed more often than you'd think.

The instinct is to preserve the session "because we've done so much work." But the work is already captured in the scratchpad, the state manifest, or the compacted summary. The conversation itself is disposable once those exist.
-->

---

<CalloutBox variant="tip" title="On the exam">

"Model referencing typical patterns" — that phrase is the exam's flag for context degradation.

<p>Right answer: <strong>scratchpads + fresh sessions</strong> (structural fixes). Distractor: "switch to a larger context window." Larger windows give you more middle to lose.</p>

<p>Same trap as 7.1 and 7.2 — "use a bigger model." Different symptom, same wrong answer. Same correct-answer family: externalize state.</p>

</CalloutBox>

<!--
On the exam, the keyword is "model referencing typical patterns." That phrase is the exam's flag for context degradation. The right answer is scratchpads plus fresh sessions — structural fixes. The distractor, as usual, is "switch to a larger context window." Larger windows give you more middle to lose. The fix is discipline, not capacity.

Same pattern as 7.1 and 7.2 — the "use a bigger model" distractor. Different symptom, same wrong answer. Same correct answer family: externalize state.
-->

---

<BigQuote
  lead="Continuity"
  quote="Domain 2 taught you <em>WHAT</em> to do. Domain 5 teaches you <em>WHY your context dies</em> if you skip the discipline."
  attribution="Either framing → same answer: scratchpads, fresh sessions, externalized state"
/>

<!--
This is where the code-exploration patterns from Section 4 matter most — Domain 2 taught you WHAT to do with tools; Domain 5 teaches you WHY your context dies if you skip the discipline. The exam will sometimes frame this as a Domain 2 question and sometimes as a Domain 5 question — the answer is the same pattern either way. Scratchpads. Fresh sessions. Externalized state.
-->

---

<Frame bg="var(--mint-100)">
  <Eyebrow>Closing</Eyebrow>
  <SlideTitle>Next up: 7.12 — Scratchpad Files for Cross-Context Persistence.</SlideTitle>

  <div class="closing-body">
    <p>We just previewed scratchpads as the main fix. Now we build them out in detail, and learn the pattern name the exam uses directly.</p>
  </div>
</Frame>

<style scoped>
.closing-body { margin-top: 56px; font-family: var(--font-body); font-size: 30px; line-height: 1.5; color: var(--forest-500); max-width: 1400px; }
</style>

<!--
Next up: 7.12, scratchpad files for cross-context persistence. We just previewed scratchpads as the main fix. Now we'll build them out in detail, and learn the pattern name the exam uses directly. See you there.
-->
