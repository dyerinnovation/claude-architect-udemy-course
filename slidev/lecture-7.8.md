---
theme: default
title: "Lecture 7.8: Structured Error Propagation"
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
const fieldBullets = [
  { label: 'failure_type → which recovery path', detail: 'timeout retries; validation reformulates; permission routes elsewhere' },
  { label: 'attempted_query → don\'t re-try the same', detail: 'Coordinator knows the exact thing that failed' },
  { label: 'partial_results → don\'t waste what worked', detail: 'If 3 of 5 docs returned, use those' },
  { label: 'alternatives → subagent knows its domain', detail: 'Suggests broader query, different source, different tool' },
]

const errorCode = `// BAD — generic status, lost information
{
  "error": "search unavailable"
}

// GOOD — structured error for coordinator recovery
{
  "failure_type": "timeout",
  "attempted_query": "Q3 2025 analyst reports on cloud infra",
  "partial_results": [
    { "doc_id": "D-201", "title": "...", "excerpt": "..." },
    { "doc_id": "D-214", "title": "...", "excerpt": "..." }
  ],
  "alternatives": [
    "Retry with narrower query: 'Q3 2025 AWS revenue'",
    "Try the archive source instead of live web"
  ]
}`

const antiPatternBad = `Generic status
  → "search unavailable"
  → coordinator has nothing to act on.

Silent suppression
  → catch timeout, return [], success: true
  → coordinator thinks research finished.`

const antiPatternFix = `Structured context with partials:
  failure_type   →  "timeout"
  attempted_query → the exact query
  partial_results → whatever returned
  alternatives   → subagent suggestions

Coordinator reads → picks recovery.`
</script>

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div class="di-cover">
    <div class="di-cover__eyebrow">Domain 5 · Lecture 7.8</div>
    <div class="di-cover__title">Structured Error Propagation</div>
    <div class="di-cover__subtitle">The four fields that enable coordinator recovery</div>
  </div>
</Frame>

<style scoped>
.di-cover { flex: 1; display: flex; flex-direction: column; justify-content: center; gap: 32px; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 28px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); }
.di-cover__title { font-family: var(--font-display); font-size: 120px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); max-width: 1500px; }
.di-cover__subtitle { font-family: var(--font-display); font-size: 44px; color: var(--mint-200); font-style: italic; }
</style>

<!--
Lecture 7.8. Structured error propagation across multi-agent systems. We're now firmly in Scenario 3 territory — the multi-agent research system — and the reliability backbone of that scenario is how subagents report failure back to the coordinator. If you understand this pattern, a whole cluster of Scenario 3 questions become straightforward.
-->

---

<Frame>
  <Eyebrow>Structured subagent error</Eyebrow>
  <SlideTitle>Four fields. Memorize all of them.</SlideTitle>

  <div class="schema-grid">
    <SchemaField name="failure_type" type="enum" :required="true" description="timeout | validation | permission | rate_limit | …" example="&quot;timeout&quot;" />
    <SchemaField name="attempted_query" type="string" :required="true" description="What the subagent tried — so the coordinator doesn't re-issue the same thing." example="&quot;Q3 analyst reports on cloud infra&quot;" />
    <SchemaField name="partial_results" type="any" :required="false" description="Whatever the subagent did retrieve before failing. Downstream can still use it." example="[{...}, {...}]" />
    <SchemaField name="alternatives" type="list" :required="false" description="Subagent-proposed next approaches — it knows its own domain best." example="[&quot;narrower query&quot;, &quot;archive source&quot;]" />
  </div>
</Frame>

<style scoped>
.schema-grid { margin-top: 40px; display: grid; grid-template-columns: 1fr 1fr; gap: 24px; }
</style>

<!--
When a subagent fails, the error it propagates needs four fields. Failure_type — an enum: timeout, validation, permission, rate_limit, and so on. Attempted_query — the specific thing the subagent tried to do. Partial_results — whatever it did manage to retrieve before the failure. Alternatives — suggested next approaches, because the subagent knows its own domain better than the coordinator does.

Four fields. Hold them. This is the canonical shape, and it's the shape Sample Question 8 tests directly. Memorizing the four field names is worth the five minutes it takes — they appear almost verbatim in exam answer choices.
-->

---

<BulletReveal
  title="Each field answers..."
  :bullets="fieldBullets"
/>

<!--
Each field answers a specific coordinator question. Failure_type answers "which recovery path do I take?" — timeout gets retried, validation gets reformulated, permission gets routed to a different subagent or escalated. Attempted_query answers "don't re-try the same thing" — the coordinator has the exact query that already failed and can avoid re-issuing it. Partial_results answers "don't waste what worked" — if three of five documents came back before the timeout, those three are still useful to downstream subagents. Alternatives answers "the subagent knows its own domain" — it can suggest a broader query, a different source, a different tool.

Drop any one of these and the coordinator is guessing. Keep all four and recovery becomes deterministic.
-->

---

<CodeBlockSlide
  title="Web search timeout → coordinator"
  lang="json"
  :code="errorCode"
  annotation="Bad: 'search unavailable.' Good: structured context with partials and alternatives."
/>

<!--
The canonical example: web search times out. Bad error propagation: "search unavailable." That string tells the coordinator nothing. Was it a transient network issue? A rate limit? A bad query? Should the coordinator retry, reformulate, or skip this subagent? No way to know.

Good error propagation: failure_type is "timeout," attempted_query is the full search string the subagent tried, partial_results contains the two or three documents that returned before the timeout window closed, alternatives is a list — "retry with a narrower query" or "try the archive source instead of live web." That's actionable. The coordinator picks a recovery path by reading the structured fields. No guesswork.
-->

---

<AntiPatternSlide
  title="Two ways to propagate wrong"
  lang="text"
  :badExample="antiPatternBad"
  whyItFails="Both make the happy path simpler while actively harming the recovery path. Generic loses info; silent loses the fact that anything went wrong."
  :fixExample="antiPatternFix"
/>

<!--
Two ways to propagate errors wrong. Generic status — "search unavailable" — which I just walked through. And silent suppression — catching the timeout and returning an empty result with a success flag. Both are wrong. Generic loses information. Silent loses the fact that anything went wrong at all. The good shape: structured context with partials, explicit failure type, and alternatives.

Both anti-patterns are tempting because they make the happy path simpler. "Just return something the coordinator can process" feels like good engineering. In a reliability-critical pipeline, it's actively harmful.
-->

---

<CalloutBox variant="warn" title="Silent suppression — the worst anti-pattern">

Catch timeout → return empty result marked success. Coordinator thinks research finished. Synthesizes a report as if the search was complete.

The user receives a clean-looking report that silently lost entire research branches.

<p>Covered again in 7.9 — access failure vs valid empty result. Same failure mode, zoomed in.</p>

</CalloutBox>

<!--
Silent suppression is the worst of the two. If the subagent catches a timeout and returns `[]` with `success: true`, the coordinator thinks the research finished and found nothing. It proceeds to synthesize a report as if the search was complete. And the user receives a clean-looking report that silently lost entire research branches.

We're going to come back to this exact failure in 7.9, where we separate access failure from valid empty results. Those two look identical in the data structure — and collapsing them is the worst error you can make in a multi-agent system. Silent suppression is how the collapse happens.
-->

---

<CalloutBox variant="tip" title="Same pattern, different layer — callback to 4.7">

This is the Domain 5 counterpart to Domain 2's local-recovery-vs-propagate question from 4.7.

<p>Domain 2: <em>when</em> a tool handles an error itself versus kicks it up.<br/>Domain 5: <em>what</em> the kick-up looks like when it happens.</p>

One pattern, two layers — both tested on this exam.

</CalloutBox>

<!--
This is the Domain 5 counterpart to Domain 2's local-recovery-versus-propagate question from 4.7. Same pattern, different angle. Domain 2 is about when a tool handles an error itself versus kicks it up to the agent. Domain 5 is about what the kick-up looks like when it happens — the structured shape the coordinator needs in order to act.

One pattern, two layers — both tested on this exam. If you've already internalized 4.7, this lecture is reinforcement, not new material. The discipline is the same: structured errors, explicit categories, no silent swallows.
-->

---

<CalloutBox variant="tip" title="Sample Q8">

Structured error context — failure_type, attempted_query, partial_results, alternatives. Know all four.

<p>Exam phrasings: "best way for a subagent to report a timeout" — same pattern. The answer is always the four-field structure. Distractors: generic string error; silent-suppression empty result.</p>

</CalloutBox>

<!--
Sample Question 8 is the canonical form. The right answer names structured error context — failure_type, attempted_query, partial_results, alternatives. Know all four field names. The distractor is generic error propagation ("return a string") or silent suppression ("catch and return empty"). Both are exam-wrong. The four-field structured shape is exam-right.

The exam also tests this as "which of the following is the best way for a subagent to report a timeout" — same pattern, different phrasing. The answer is always the four-field structure.
-->

---

<BigQuote
  lead="Continuity"
  quote="Scenario 3 — multi-agent research — this is the <em>reliability backbone</em>."
  attribution="Don't skip it because Domain 5 is only 15%. The four fields are the kind of memorizable structure the exam rewards directly."
/>

<!--
Scenario 3 — multi-agent research — is where this is the reliability backbone. If you're preparing for Scenario 3 and you don't know the four fields cold, you will miss the question. Don't skip it because it's Domain 5 and Domain 5 is only fifteen percent. This particular pattern is worth the study time — it's the kind of concrete, memorizable structure that the exam rewards directly.
-->

---

<Frame bg="var(--mint-100)">
  <Eyebrow>Closing</Eyebrow>
  <SlideTitle>Next up: 7.9 — Access Failure vs Valid Empty Result.</SlideTitle>

  <div class="closing-body">
    <p>We just previewed it — now we're going to separate the two clearly. Single-concept lecture. One of the highest-leverage distinctions on the exam.</p>
  </div>
</Frame>

<style scoped>
.closing-body { margin-top: 56px; font-family: var(--font-body); font-size: 30px; line-height: 1.5; color: var(--forest-500); max-width: 1400px; }
</style>

<!--
Next up: 7.9, access failure versus valid empty result. We just previewed it — now we're going to separate the two clearly. This is a single-concept lecture and one of the highest-leverage distinctions on the exam. See you there.
-->
