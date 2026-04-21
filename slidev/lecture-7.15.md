---
theme: default
title: "Lecture 7.15: Stratified Sampling for Accuracy"
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
const strataBullets = [
  { label: 'Document type', detail: 'The obvious one — different formats, different error profiles.' },
  { label: 'Field', detail: 'Individual fields may fail at different rates inside the same doc type.' },
  { label: 'Source', detail: 'Different input pipelines, different error profiles.' },
  { label: 'Time window', detail: 'Recent extractions may drift from historical baselines.' },
  { label: 'Confidence band', detail: 'High / medium / low — each at a different risk level.' },
]

const processSteps = [
  { title: 'Stratify population', body: 'Segment by doc type, field, source, time window, confidence band.' },
  { title: 'Sample within each stratum', body: 'Enough for the segment estimate to be statistically meaningful.' },
  { title: 'Human-label the sample', body: 'Ground truth per item in the sample.' },
  { title: 'Compute per-stratum accuracy', body: 'Not just one aggregate number.' },
  { title: 'Flag strata below threshold', body: 'Targeted remediation — route review investment there.' },
]

const antiPatternBad = `1000 random samples. Compute one
overall accuracy number. Ship it.

→ When the number drops, you can't
  tell where the failures concentrate.
→ Might be one stratum. Might be spread
  across many. You can only panic,
  not act.`

const antiPatternFix = `Stratified sampling. Per-stratum accuracy
surfaces weak areas.

→ Route human review investment to
  the strata that need it.
→ Targeted effort beats uniform effort.
→ Fix what's actually broken.`
</script>

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div class="di-cover">
    <div class="di-cover__eyebrow">Domain 5 · Lecture 7.15</div>
    <div class="di-cover__title">Stratified Sampling<br/>for Accuracy</div>
    <div class="di-cover__subtitle">Catch novel error patterns before aggregate slides</div>
  </div>
</Frame>

<style scoped>
.di-cover { flex: 1; display: flex; flex-direction: column; justify-content: center; gap: 32px; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 28px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); }
.di-cover__title { font-family: var(--font-display); font-size: 112px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); max-width: 1500px; }
.di-cover__subtitle { font-family: var(--font-display); font-size: 40px; color: var(--mint-200); font-style: italic; }
</style>

<!--
Lecture 7.15. Stratified sampling for accuracy measurement. This is Scenario 6 — structured data extraction — and it's the follow-up to 7.14's routing loop. We're now zoomed in on the drift-detection step, which is where most production extraction pipelines silently fail when they're not set up correctly.
-->

---

<ConceptHero
  leadLine="Random misses rare patterns"
  concept="Stratify to guarantee coverage."
  supportLine="Pure random sampling under-represents small segments. Stratified sampling ensures rare-but-important segments get measurement coverage."
/>

<!--
Random sampling misses rare patterns. If ninety-five percent of your extractions are one document type and five percent are a second type, a thousand-sample random pull gives you about fifty examples of the rare type — not enough to catch a failure mode concentrated there. The rare type might be failing at thirty percent, but you only see fifteen errors and they get drowned in the overall noise.

Stratified sampling fixes this by sampling proportionally — or deliberately over-sampling small segments — within each stratum, so rare-but-important segments get the same measurement coverage as common ones. You guarantee coverage of segments that pure random sampling would under-represent.
-->

---

<BulletReveal
  title="Sample by..."
  :bullets="strataBullets"
/>

<!--
What to stratify by. Document type — the obvious one. Field — individual fields may fail at different rates even within a single document type. Source — different input pipelines may have different error profiles. Time window — recent extractions may drift from historical baselines. Confidence band — high-confidence, medium, and low each deserve their own sampling because they're each at different risk levels.

Five strata. You don't need all five on every run — pick the ones that matter for your pipeline. At minimum, stratify by document type and confidence band. Those two cover most of the exam's framing and most of the production risk.
-->

---

<CalloutBox variant="tip" title="Two purposes for stratified sampling">

<p><strong>1. Ongoing error-rate measurement</strong> across high-confidence extractions — the auto-accepted pipeline. You need to know if those accept decisions remain safe over time.</p>
<p><strong>2. Novel pattern detection</strong> as inputs drift — new document formats, new vendor templates, new input sources that your model wasn't validated on.</p>
<p>Both purposes need stratification. Aggregate measurement misses both.</p>

</CalloutBox>

<!--
Two purposes for stratified sampling. One: ongoing error-rate measurement across high-confidence extractions — the automated pipeline you're auto-accepting. You need to know if those accept decisions remain safe over time. Two: novel pattern detection as inputs drift — new document formats, new vendor templates, new input sources that your model wasn't validated on.

Both purposes need stratification. Aggregate measurement misses both.
-->

---

<StepSequence
  title="Measurement loop"
  :steps="processSteps"
/>

<!--
The measurement loop. Stratify the population into segments. Sample within each stratum — enough that the segment estimate is statistically meaningful. Human-label the sample. Compute per-stratum accuracy. Flag any stratum that drops below its threshold.

Five steps. Repeat on a cadence that matches your input volume — daily for high-volume pipelines, weekly for lower-volume ones. The cadence matters because drift is faster than most teams assume — a vendor template change that lands on a Tuesday can corrupt a week's worth of extractions by Friday if you're not sampling frequently.
-->

---

<CalloutBox variant="tip" title="Drift detection — catch novel patterns early">

New document format arrives — vendor template change, new source sending data.

<p>Aggregate accuracy may not move meaningfully — the new format is 5% of volume, the 95% is still fine. <strong>Stratified sampling catches the drift early because the new format shows up as its own stratum with its own accuracy number.</strong> You see divergence before the aggregate starts to slide.</p>

<p>Early detection beats late cleanup. That's why stratified sampling is in the exam objectives.</p>

</CalloutBox>

<!--
This is the novel-patterns piece. A new document format shows up — a vendor changes their invoice template, or a new source starts sending data. Aggregate accuracy may not move meaningfully — the new format is five percent of volume, and ninety-five percent of old volume is still fine. Stratified sampling catches the drift early because the new format shows up as its own stratum with its own accuracy number. You see the divergence before the aggregate starts to slide.

Early detection beats late cleanup. That's the whole reason stratified sampling is in the exam objectives. The pipeline that detects drift in week one recovers gracefully. The pipeline that notices in week four has already shipped thousands of bad extractions downstream.
-->

---

<AntiPatternSlide
  title="Don't use random sampling alone"
  lang="text"
  :badExample="antiPatternBad"
  whyItFails="Random under-represents rare strata. The aggregate number loses the location of the problem."
  :fixExample="antiPatternFix"
/>

<!--
The anti-pattern: take a thousand random samples, compute one overall accuracy number, ship it. When the number drops, you can't tell where the failures are concentrated — they might be in one stratum, they might be spread across all of them. You can't act on a single aggregate number; you can only panic on it.

The better pattern: stratified sampling, per-stratum accuracy surfaces weak areas, and you route human review investment to the strata that need it. Targeted effort beats uniform effort. You fix what's actually broken.
-->

---

<CalloutBox variant="tip" title="On the exam — the exact phrase">

"Detect novel error patterns in high-confidence extractions" → stratified random sampling.

<p>Memorize the phrase. <strong>"Stratified random sampling"</strong> — the exam uses it directly.</p>

<p>Distractor: "increase overall sample size." Doesn't fix the segment-coverage problem. 10,000 random samples still under-represent the 5% stratum.</p>

</CalloutBox>

<!--
On the exam, the exact phrase is "detect novel error patterns in high-confidence extractions." That's the exam's keyword. The right answer is stratified random sampling. Memorize the phrase — stratified random sampling — because the exam uses it directly, and the distractor is often "increase overall sample size," which doesn't fix the segment-coverage problem. Ten thousand random samples still under-represent the five-percent stratum.
-->

---

<Frame bg="var(--mint-100)">
  <Eyebrow>Closing</Eyebrow>
  <SlideTitle>Next up: 7.16 — Information Provenance: Claim-Source Mappings.</SlideTitle>

  <div class="closing-body">
    <p>Aggregate accuracy is a <em>lagging</em> indicator. Stratified per-segment accuracy is a <em>leading</em> indicator. You want the leading signal — the lagging one tells you the damage already shipped.</p>
    <p>Now we pivot back to Scenario 3 for the final stretch of Section 7 — keeping attribution alive through synthesis. Another "structured beats prose" lesson.</p>
  </div>
</Frame>

<style scoped>
.closing-body { margin-top: 56px; font-family: var(--font-body); font-size: 28px; line-height: 1.5; color: var(--forest-500); max-width: 1400px; }
.closing-body p + p { margin-top: 20px; }
.closing-body p em { color: var(--forest-800); font-style: italic; }
</style>

<!--
Before we move on, hold onto the mental frame. Aggregate accuracy is a lagging indicator. Stratified per-segment accuracy is a leading indicator. On any production pipeline, you want the leading signal, because the lagging signal tells you the damage has already shipped. This is the same principle as case-facts blocks and state manifests — externalize the discipline so that forgetting or averaging isn't possible. The exam's Scenario 6 questions consistently reward the leading-indicator answer over the lagging one.

Next up: 7.16, information provenance — claim-source mappings. We're pivoting back to Scenario 3 for the final stretch of Section 7. The discipline there is about keeping attribution alive through synthesis — another "structured beats prose" lesson. See you there.
-->
