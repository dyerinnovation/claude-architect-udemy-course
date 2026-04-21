---
theme: default
title: "Lecture 6.12: Matching API Choice to Latency"
info: |
  Claude Certified Architect – Foundations
  Section 6 — Prompt Engineering & Structured Output (Domain 4, 20%)
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
    label: 'Pre-merge PR check',
    cells: [
      { text: 'Seconds', highlight: 'neutral' },
      { text: 'Sync', highlight: 'good' },
    ],
  },
  {
    label: 'IDE autocomplete',
    cells: [
      { text: 'Milliseconds', highlight: 'neutral' },
      { text: 'Sync', highlight: 'good' },
    ],
  },
  {
    label: 'Interactive chat',
    cells: [
      { text: 'Seconds', highlight: 'neutral' },
      { text: 'Sync', highlight: 'good' },
    ],
  },
  {
    label: 'Overnight tech-debt report',
    cells: [
      { text: 'Hours', highlight: 'neutral' },
      { text: 'Batch', highlight: 'good' },
    ],
  },
  {
    label: 'Weekly audit',
    cells: [
      { text: 'Days', highlight: 'neutral' },
      { text: 'Batch', highlight: 'good' },
    ],
  },
  {
    label: 'Monthly compliance scan',
    cells: [
      { text: 'Days', highlight: 'neutral' },
      { text: 'Batch', highlight: 'good' },
    ],
  },
]

const badBatchAll = `# "Batch everything for 50% savings."
#   - Pre-merge: batch
#   - Interactive chat: batch
#   - Nightly tests: batch
# Ignores the latency budget of the blocking workflows.`

const goodMixed = `# Match each workflow to its latency budget first,
# then apply cost optimization within that.
#   - Pre-merge: sync (seconds budget)
#   - Interactive chat: sync (seconds budget)
#   - Nightly tests: batch (hours budget) → 50% savings`
</script>

<CoverSlide
  title="Matching API Choice to Latency"
  subtitle="Latency drives the API. Cost savings live on the batch row."
  eyebrow="Domain 4 · Lecture 6.12"
  :stats="['Section 6', 'Scenarios 5 & 6', 'Domain 4 · 20%', '7 min']"
/>

<!--
From 6.11 you know the facts about the batch API. This lecture makes them operational. Seven minutes. The single decision rule, a matrix of workflows to API choices, the SLA math for batch cadence, and the answer to the Sample Q11 trap restated plainly. If the exam asks "which API for this workflow?", this lecture is the one that gets you to the right pick in five seconds.
-->

---

<ConceptHero
  leadLine="Latency drives the API, not cost savings."
  concept="How long can the caller wait?"
  supportLine="Seconds → sync. Milliseconds → sync. Hours → batch. Days → batch. The 50% savings is a reward for tolerating the 24-hour window — not a reason to push a workflow into batch when it doesn't tolerate it."
/>

<!--
Here's the decision rule. Latency drives the API, not cost savings. How long can the caller wait? Seconds — sync. Milliseconds — sync. Hours — batch. Days — batch. That's the entire framework. The fifty-percent savings is a reward you get when the workflow tolerates the 24-hour window — not a reason to push a workflow into batch when it doesn't. The mental move: match each workflow to its latency budget, then optimize cost within that constraint.
-->

---

<ComparisonTable
  eyebrow="API by workflow"
  title="Draw this matrix from memory"
  :columns="['Latency tolerance', 'API']"
  :rows="matrixRows"
/>

<!--
Here's the matrix you should be able to draw from memory. Pre-merge PR check: tolerance seconds, API sync. IDE autocomplete: tolerance milliseconds, API sync. Interactive chat: tolerance seconds, API sync. Overnight tech-debt report: tolerance hours, API batch. Weekly audit: tolerance days, API batch. Monthly compliance scan: tolerance days, API batch. The pattern is clean — short tolerance means sync, long tolerance means batch. Cost savings live on the batch row, which is why we pick it when we can.
-->

---

<CalloutBox variant="tip" title="SLA math — batch cadence">
  <p>You have a <strong>30-hour</strong> delivery SLA on a report. Batch takes up to <strong>24 hours</strong>.</p>
  <p>Submit once at the last minute → you'd need 6-hour completion, which isn't guaranteed. Risk the SLA.</p>
  <p><strong>Submit every 4 hours</strong> — any given batch has up to 24 hours to complete; worst-case delivery from job submission is <strong>4 + 24 = 28 hours</strong>, under your 30-hour SLA.</p>
  <p>Task 4.5 in the exam guide. Memorize the cadence calculation.</p>
</CalloutBox>

<!--
Practical math that the exam tests. You have a 30-hour delivery SLA on a report. Batch takes up to 24 hours. If you submit once at the last minute, you risk missing the SLA — you'd need completion in six hours, which isn't guaranteed. The move: submit every 4 hours. That way any given batch has up to 24 hours to complete, and your worst-case delivery from job submission is 4 hours plus 24, which is 28 — under your 30-hour SLA. This is Task 4.5 in the exam guide. Memorize the cadence calculation.
-->

---

<CalloutBox variant="tip" title="Hybrid workflows — split the workload">
  <p>Same team often uses <strong>both APIs</strong>: pre-merge sync, overnight tech-debt batch.</p>
  <p>Not a contradiction — it is the right architecture. Different workflows, different latency budgets, different API choices, same team, same codebase.</p>
  <p>Mature engineering orgs run three or four distinct workflows across both APIs, each matched to its own latency budget. You pick <strong>per workflow</strong>, not per team.</p>
</CalloutBox>

<!--
The same team may use both APIs. Pre-merge sync, overnight tech-debt batch. That is not a contradiction — it is the right architecture. Different workflows, different latency budgets, different API choices, same team, same codebase. The instinct to pick one API for the whole team is wrong. You pick per workflow. This is exactly the Sample Q11 framing, which we cover next. And this pattern scales — a mature engineering org often runs three or four distinct workflows across both APIs, each matched to its own latency budget.
-->

---

<CalloutBox variant="warn" title="Sample Q11 restated — the fork">
  <p>Two workflows: blocking pre-merge and overnight tech-debt. Manager wants 50% savings, proposes batch for both.</p>
  <p><strong>Right answer:</strong> batch for the tech-debt report, sync for pre-merge. &ldquo;Both&rdquo; — running each on its appropriate API — is the only correct answer.</p>
  <ul>
    <li>Options B and D: batch everything with fallback logic → wrong (paper over a hard constraint).</li>
    <li>Option C: keep both on sync → wastes money.</li>
    <li>Option A: sync for blocking, batch for overnight → clean fork.</li>
  </ul>
</CalloutBox>

<!--
Sample Q11 restated. Two workflows: blocking pre-merge and overnight tech-debt. Manager wants fifty-percent savings, proposes batch for both. The right answer is: batch for the tech-debt report, sync for pre-merge. "Both" — running each on its appropriate API — is the only correct answer. Options B and D in the sample try to batch everything with fallback logic; they're wrong because they paper over a hard constraint. Option C keeps both on sync; it wastes money. Option A — sync for blocking, batch for overnight — is the clean fork.
-->

---

<AntiPatternSlide
  title="Don't chase savings into a blocking workflow"
  lang="text"
  :badExample="badBatchAll"
  whyItFails="Looks like good engineering. Ignores the latency budget of the blocking workflow."
  :fixExample="goodMixed"
/>

<!--
The anti-pattern is the "batch everything for fifty percent savings" move. It looks like good engineering — lower costs, simpler architecture, one API to learn. It's wrong because it ignores the latency budget of the blocking workflow. The replacement: match each workflow to its latency budget first, then apply cost optimization within that. You will see this anti-pattern in multiple exam distractors. Almost-right is the trap — batch for cost savings is plausible in a different context, but not over a blocking workflow.
-->

---

<CalloutBox variant="tip" title="On the exam — blocking + batch = distractor">
  <p>Any question that pairs <strong>&ldquo;blocking&rdquo;</strong> with <strong>&ldquo;batch&rdquo;</strong> in the correct-answer framing is a distractor. Batch doesn't fit blocking. Period.</p>
  <p>Stem mentions <em>pre-merge</em>, <em>developers waiting</em>, <em>interactive UI</em> → <strong>sync</strong>.</p>
  <p>Stem mentions <em>overnight</em>, <em>weekly</em>, <em>nightly generation</em> → <strong>batch</strong>.</p>
  <p>Read the stem for the latency word, not the cost word. Scenarios 5 and 6 both touch this.</p>
</CalloutBox>

<!--
On the exam, any question that pairs "blocking" with "batch" in the correct-answer framing is a distractor. Batch doesn't fit blocking workflows. Period. If the stem mentions "pre-merge check" or "developers waiting" or "interactive UI," sync wins. If the stem mentions "overnight" or "weekly" or "nightly generation," batch wins. Read the stem for the latency word, not the cost word. Scenarios 5 and 6 both touch this — Scenario 5 on CI/CD workflows, Scenario 6 on document extraction pipelines — so the question of matching API to latency can land from two directions. Same rule applies either way.
-->

---

<ClosingSlide nextLecture="6.13 — Batch Failure Handling with custom_id" />

<!--
Carry this forward: latency drives the API, same team often uses both, and the SLA math for batch cadence is simple — submit at an interval that covers your worst case. Next lecture, 6.13, we go into batch failure handling — what goes wrong mid-batch, how custom_id saves you, and why resubmitting the whole batch is an expensive distractor. See you there.
-->
