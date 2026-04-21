---
theme: default
title: "Lecture 7.7: Sentiment vs Complexity"
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
const matrixRows = [
  {
    label: 'Calm',
    cells: [
      { text: 'Resolve', highlight: 'good' },
      { text: 'Escalate (complexity)', highlight: 'neutral' },
    ],
  },
  {
    label: 'Frustrated',
    cells: [
      { text: 'Acknowledge + resolve', highlight: 'good' },
      { text: 'Acknowledge + escalate', highlight: 'neutral' },
    ],
  },
]
</script>

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div class="di-cover">
    <div class="di-cover__eyebrow">Domain 5 · Lecture 7.7</div>
    <div class="di-cover__title">Sentiment vs Complexity</div>
    <div class="di-cover__subtitle">Why they're not the same</div>
  </div>
</Frame>

<style scoped>
.di-cover { flex: 1; display: flex; flex-direction: column; justify-content: center; gap: 32px; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 28px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); }
.di-cover__title { font-family: var(--font-display); font-size: 132px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); max-width: 1500px; }
.di-cover__subtitle { font-family: var(--font-display); font-size: 44px; color: var(--mint-200); font-style: italic; }
</style>

<!--
Lecture 7.7. Sentiment versus complexity. This is one of the cleanest "almost-right" traps on the entire exam. If you get this one, you're going to pick up points other candidates miss — and more importantly, you're going to understand a distinction that shows up in multiple question variants.
-->

---

<ComparisonTable
  title="Sentiment × Complexity"
  :columns="['Simple', 'Complex']"
  :rows="matrixRows"
/>

<!--
Picture a two-by-two grid. One axis is sentiment — calm or frustrated. The other axis is case complexity — simple or complex. That gives you four cells.

Calm and simple: resolve. The agent handles it, no drama. Calm and complex: escalate, because the case needs it — calm isn't a signal to keep pushing. Frustrated and simple: acknowledge the frustration AND resolve — the simple case is still simple, the frustration just changes the tone. Frustrated and complex: acknowledge AND escalate — the complexity drives the escalation, not the frustration.

Notice what's consistent across the grid: escalation branches on complexity, not sentiment. Sentiment only changes whether you acknowledge. The same case complexity always produces the same routing decision, regardless of how the customer feels.
-->

---

<ConceptHero
  leadLine="Orthogonal signals"
  concept="Feel ≠ Need."
  supportLine="Sentiment = how they feel. Complexity = what the case needs. Using one as a proxy for the other routes simple cases away from resolution."
/>

<!--
Here's the principle. Sentiment is how the customer feels. Complexity is what the case needs. Those are orthogonal signals — they measure different things entirely. A customer can be calm about a case that's legitimately unsolvable by the agent; a customer can be furious about a case that's a two-click fix.

Using sentiment as a proxy for complexity conflates the two, and it routes simple cases away from resolution just because the customer sounds upset. That's bad service AND bad architecture — the human queue fills with simple-but-frustrating cases while genuinely hard problems wait their turn behind them.
-->

---

<CalloutBox variant="warn" title="Sample Q3 — distractor D">

"Sentiment analysis for automatic escalation" — wrong. Sentiment doesn't correlate with complexity.

<p>Once you recognize the 2×2, this is a one-line distractor rule-out. <strong>The correct answer is always explicit criteria plus few-shot examples</strong> — the pattern from 7.5.</p>

</CalloutBox>

<!--
This ties directly to Sample Question 3. One of the distractors is "use sentiment analysis for automatic escalation." Wrong. Sentiment doesn't correlate with complexity — we just walked through the 2x2 that proves the two axes are independent. The exam specifically lists sentiment-based routing as an incorrect answer, and the correct answer is always explicit criteria plus few-shot examples — the pattern from 7.5.

This is one of the "known-wrong" distractors on this exam. Once you recognize it, you can rule it out on sight.
-->

---

<CalloutBox variant="tip" title="Acknowledge, don't route">

Sentiment still has a role — it's just not the escalation trigger.

<p>Right use: "I can hear this has been frustrating — let me see what I can do." That's the job sentiment does. It sets the <em>tone</em> of the response. Not the routing decision.</p>

<p>Acknowledgment costs nothing. Routing costs a human-agent slot.</p>

</CalloutBox>

<!--
Sentiment still has a role — it's just not the escalation trigger. The right use: acknowledge the feeling. "I can hear this has been frustrating — let me see what I can do." That's the job sentiment does. It doesn't set the routing decision; it sets the tone of the response.

Acknowledge, don't route. That's the phrase to hold. Acknowledgment costs nothing and preserves the customer experience. Routing costs a human-agent slot and should be reserved for cases that actually need one.
-->

---

<BigQuote
  lead="Continuity — 1.1's frame"
  quote="<em>Almost-right is the whole trap.</em> Sentiment-based escalation <em>looks</em> empathetic. It's not the right mechanism."
  attribution="Right in a different context — wrong for the complexity-routing question the exam is asking"
/>

<!--
Remember 1.1's frame — almost-right is the whole trap of this exam. Sentiment-based escalation LOOKS empathetic. It reads like the right answer if you're thinking about customer experience and not about case routing. But it conflates two different signals, and the exam penalizes the conflation every time. This is the kind of distractor that shows up because it'd be right in a different context — routing to a human-tone-specialist, maybe, or prioritizing a de-escalation workflow — but it's wrong for the complexity-routing question the exam is asking.
-->

---

<CalloutBox variant="tip" title="On the exam — pattern rule-out">

"Automate escalation via sentiment" is always a distractor in Scenario 1 questions.

<p>The right answer is explicit criteria, written into the system prompt, with few-shot examples for edge cases.</p>

<p>If you see "sentiment" in an answer choice for a Scenario 1 escalation question → eliminate without re-reading. That's the shortcut this lecture earns you.</p>

</CalloutBox>

<!--
On the exam, the shape: "Automate escalation via sentiment analysis" is always a distractor in Scenario 1 questions. The right answer is explicit criteria, written into the system prompt, with few-shot examples for the edge cases. Memorize the pattern — sentiment is out, explicit criteria plus few-shots is in.

If you see sentiment in the answer choices for a Scenario 1 escalation question, you can eliminate that choice without re-reading the question. That's the shortcut this lecture earns you.
-->

---

<Frame bg="var(--mint-100)">
  <Eyebrow>Closing</Eyebrow>
  <SlideTitle>Next up: 7.8 — Structured Error Propagation.</SlideTitle>

  <div class="closing-body">
    <p>The sentiment-vs-complexity shape shows up elsewhere: self-reported confidence as a proxy for accuracy, conversation length as a proxy for difficulty. <em>One signal as a proxy for another when the two are orthogonal.</em> Rule it out across multiple lecture topics.</p>
    <p>Now we shift from Scenario 1 customer support into Scenario 3 multi-agent research — and the error patterns over there are a whole different discipline.</p>
  </div>
</Frame>

<style scoped>
.closing-body { margin-top: 56px; font-family: var(--font-body); font-size: 28px; line-height: 1.5; color: var(--forest-500); max-width: 1400px; }
.closing-body p + p { margin-top: 24px; }
.closing-body p em { color: var(--forest-800); font-style: italic; }
</style>

<!--
One more thing to carry forward before we leave this lecture. The sentiment-versus-complexity distinction isn't just for the escalation question. The same conflation pattern shows up elsewhere on the exam — using one signal as a proxy for another when the two are orthogonal. Self-reported confidence as a proxy for accuracy — same conflation, different domain, covered in 7.5 and 7.14. Conversation length as a proxy for difficulty — same conflation, different axis. Once you recognize the shape, you can rule out distractors across multiple lecture topics. That's the leverage Domain 5 gives you when you study it carefully — the patterns compose.

Next up: 7.8, structured error propagation across multi-agent systems. We're shifting from Scenario 1 customer support into Scenario 3 multi-agent research — and the error patterns over there are a whole different discipline. See you there.
-->
