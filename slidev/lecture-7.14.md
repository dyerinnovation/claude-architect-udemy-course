---
theme: default
title: "Lecture 7.14: Human Review & Confidence Calibration"
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
const routingSteps = [
  { label: 'Model outputs field + confidence', sublabel: 'Confidence per field — calibrated, not self-reported' },
  { label: 'Below threshold → human queue', sublabel: 'Threshold set from labeled validation set' },
  { label: 'Above → auto-accept', sublabel: 'Pipeline keeps flowing' },
  { label: 'Periodic sample above threshold', sublabel: 'Drift detection — 7.15' },
]

const antiPatternBad = `Overall accuracy is 97%. Team reduces
human review without validating
per-segment accuracy.

→ 40%-accuracy bucket starts shipping
  bad extractions downstream.
→ Nobody's sampling stratified.
→ Errors compound. Unnoticed.`

const antiPatternFix = `Validate per document type AND per
field BEFORE reducing review.

Automation earns its reduction in
oversight — it doesn't get it just
because the average looks good.`
</script>

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div class="di-cover">
    <div class="di-cover__eyebrow">Domain 5 · Lecture 7.14</div>
    <div class="di-cover__title">Human Review &<br/>Confidence Calibration</div>
    <div class="di-cover__subtitle">Scenario 6 — with a direct 7.5 reconciliation on slide 6</div>
  </div>
</Frame>

<style scoped>
.di-cover { flex: 1; display: flex; flex-direction: column; justify-content: center; gap: 32px; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 28px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); }
.di-cover__title { font-family: var(--font-display); font-size: 108px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); max-width: 1500px; }
.di-cover__subtitle { font-family: var(--font-display); font-size: 40px; color: var(--mint-200); font-style: italic; }
</style>

<!--
Lecture 7.14. Human review workflows and confidence calibration. This is a Scenario 6 lecture — structured data extraction — and I flagged at the end of 7.13 that it contains a nuance that directly contradicts something you learned in 7.5. That's intentional. The exam tests whether you understand the difference. Pay attention to the reconciliation — slide 6 is the load-bearing slide of this lecture.
-->

---

<BigQuote
  lead="The aggregate accuracy trap"
  quote="<em>97% overall accuracy</em> can mask <em>40% accuracy</em> on one document type."
  attribution="A good-looking average hiding a disaster bucket"
/>

<!--
Here's the hook. Ninety-seven percent overall accuracy can mask forty percent accuracy on one document type. That's the trap. A pipeline that reads ninety-seven percent overall looks like it's done — ready to automate, ready to reduce human review, ready to ship. But if that ninety-seven is an average across five document types where four are at ninety-nine and one is at forty, the forty-percent bucket is a disaster hiding inside a good-looking average.

Aggregate metrics hide per-segment failures. Full stop. If you reduce human review on the basis of aggregate accuracy alone, the forty-percent bucket starts shipping bad extractions downstream — and nobody knows until the damage shows up in production data.
-->

---

<ConceptHero
  leadLine="Measure by segment"
  concept="Stratify. Always."
  supportLine="Accuracy per document type, per field, per source. Aggregate hides the worst segments. Stratified surfaces them."
/>

<!--
The fix is to measure by segment. Accuracy per document type. Accuracy per field. Accuracy per source. You don't get one number — you get a matrix. And the matrix is what tells you whether the pipeline is safe to automate.

Aggregate hides the worst segments. Stratified surfaces them. Always measure by segment when the segments behave differently. We'll cover the sampling mechanics in 7.15.
-->

---

<CalloutBox variant="tip" title="Calibrated, not self-reported">

The model can output a confidence score per field. Useful — but only if CALIBRATED.

<p>Calibration means: on a labeled validation set, fields with confidence 0.9 really are correct 90% of the time. Fields with confidence 0.5 really are correct 50% of the time. The number maps to reality because you measured it against ground truth.</p>

<p>Self-reported confidence without calibration is just a number the model picked. <strong>Calibrated confidence is data-driven. The routing threshold is calibrated against labeled data, not a gut call.</strong></p>

</CalloutBox>

<!--
The model can output a confidence score per field it extracts. That's useful — but only if the confidence is CALIBRATED, not self-reported. Calibration means: on a labeled validation set, fields with confidence 0.9 really are correct ninety percent of the time. Fields with confidence 0.5 really are correct fifty percent of the time. The number maps to reality because you measured it against ground truth.

Self-reported confidence without calibration is just a number the model picked. Calibrated confidence is data-driven. The routing threshold — "send below X to humans" — is calibrated against labeled data, not a gut call.
-->

---

<FlowDiagram
  title="Review routing"
  :steps="routingSteps"
/>

<!--
The routing flow. Model extracts a field and emits a confidence. If confidence is below threshold, route to a human review queue. If above, auto-accept. Periodically, sample a subset of above-threshold extractions for drift detection — to catch the case where novel error patterns start slipping through high-confidence outputs.

Four-step loop. Model, compare, route, sample. Every piece of the loop has to be present for the system to stay reliable — you can't skip the sampling and trust the routing forever, because input distributions drift over time.
-->

---

<TwoColSlide
  title="Why self-reported confidence is OK here — but NOT for escalation"
  variant="compare"
  leftLabel="Scenario 6 (correct)"
  rightLabel="Scenario 1 (distractor)"
>
  <template #left>
    <p><strong>Extraction pipeline.</strong> Confidence-based routing is <em>CORRECT</em>.</p>
    <ul>
      <li>You have a labeled validation set.</li>
      <li>You calibrate confidence scores against that ground truth.</li>
      <li>Scores become real probabilities — "90% confidence" really does mean "90% correct" in aggregate.</li>
    </ul>
    <p><strong>Calibrated confidence works.</strong></p>
  </template>
  <template #right>
    <p><strong>Customer-support escalation.</strong> Self-reported confidence is a <em>DISTRACTOR</em>. That's what 7.5 told you, and it's still true.</p>
    <ul>
      <li>Agent's self-confidence is uncalibrated against case complexity.</li>
      <li>Nobody measured it against labeled outcomes.</li>
      <li>The agent is already wrongly confident on cases it gets wrong.</li>
    </ul>
    <p><strong>Self-report can't detect its own miss.</strong></p>
  </template>
</TwoColSlide>

<!--
Here's the reconciliation with 7.5. This is the single most important callout in Section 7 — do not skim it.

For escalation in Scenario 1 — customer support — self-reported confidence is a DISTRACTOR. Wrong answer. That's what 7.5 told you, and that's still true. Why? Because the agent's self-confidence is uncalibrated against case complexity. Nobody measured it against labeled outcomes. The agent is already wrongly confident on the cases it gets wrong. Self-report can't detect its own miss.

For extraction in Scenario 6 — this lecture — confidence-based routing is CORRECT. Why? Because in an extraction pipeline, you have a labeled validation set. You calibrate the confidence scores against that ground truth. The scores become real probabilities — "ninety percent confidence" really does mean "ninety percent correct" in aggregate.

Same mechanism, two very different contexts. Uncalibrated self-report fails. Calibrated confidence works. The exam tests whether you know the difference — and the wrong answer on Scenario 1 is the right answer on Scenario 6. Hold onto that. If you forget this distinction, you'll learn contradictory rules and miss both questions. If you remember it, you pick up both.

The callback rule: before you pick "confidence-based routing" on any exam question, ask yourself — is there a labeled validation set in this scenario? If yes, it's likely correct. If no, it's likely a distractor. Scenario 1 has no validation set for escalation decisions. Scenario 6 does. Go back and re-read 7.5 after this lecture if you need to. The two lectures are meant to be held together.
-->

---

<CalloutBox variant="tip" title="Stratified sampling preview — 7.15">

For ongoing accuracy measurement, stratified random sampling of above-threshold extractions catches novel error patterns that random sampling would miss.

<p>That's the drift-detection piece of the routing loop. Preview now; we build it out next lecture.</p>

</CalloutBox>

<!--
We're going to cover this in 7.15. For ongoing accuracy measurement, stratified random sampling of above-threshold extractions catches novel error patterns that random sampling would miss. That's the drift-detection piece of the routing loop. Preview now; build out next lecture.
-->

---

<AntiPatternSlide
  title="Don't reduce human review without segment validation"
  lang="text"
  :badExample="antiPatternBad"
  whyItFails="Aggregate hides the bad bucket. Reducing oversight on aggregate evidence ships errors into production."
  :fixExample="antiPatternFix"
/>

<!--
The anti-pattern: overall accuracy is high, so the team reduces human review without validating per-segment accuracy. Then the forty-percent bucket starts shipping bad extractions downstream — and because nobody's sampling stratified, nobody notices until the errors compound.

The better pattern: validate per document type AND per field before reducing review. Automation earns its reduction in oversight. It doesn't get it just because the average looks good.
-->

---

<CalloutBox variant="tip" title="On the exam — memorize both halves">

"Route low-confidence extractions to human review" — correct WHEN confidence is calibrated.

<p>Route <strong>AND</strong> calibrate. Memorize both halves.</p>

<p>Scenario 6 + labeled validation set mentioned → confidence-based routing is right. Scenario 1 escalation without calibration data → confidence-based routing is wrong. <strong>Context is the whole test.</strong></p>

</CalloutBox>

<!--
On the exam, the shape is: "Route low-confidence extractions to human review." That's correct — WHEN confidence is calibrated. Memorize both halves. Route AND calibrate. If the question is about Scenario 6 and mentions a labeled validation set, confidence-based routing is right. If the question is about Scenario 1 escalation without calibration data, confidence-based routing is wrong. Context is the whole test.
-->

---

<Frame bg="var(--mint-100)">
  <Eyebrow>Closing</Eyebrow>
  <SlideTitle>Next up: 7.15 — Stratified Sampling for Accuracy Measurement.</SlideTitle>

  <div class="closing-body">
    <p>We previewed it — now we build it out. Together with 7.14 it forms the full Scenario 6 reliability toolkit.</p>
  </div>
</Frame>

<style scoped>
.closing-body { margin-top: 56px; font-family: var(--font-body); font-size: 30px; line-height: 1.5; color: var(--forest-500); max-width: 1400px; }
</style>

<!--
Next up: 7.15, stratified sampling for accuracy measurement. We previewed it — now we build it out. Together with 7.14 it forms the full Scenario 6 reliability toolkit. See you there.
-->
