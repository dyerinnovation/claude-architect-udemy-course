---
theme: default
title: "Lecture 7.9: Access Failure vs Valid Empty Result"
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
const distinctionRows = [
  {
    label: 'Empty because access failed',
    cells: [
      { text: 'Answer unknown — try again or alternative', highlight: 'bad' },
      { text: 'Retry / route / escalate', highlight: 'neutral' },
    ],
  },
  {
    label: 'Empty because no matches',
    cells: [
      { text: 'THAT is the answer', highlight: 'good' },
      { text: 'Proceed with null result', highlight: 'neutral' },
    ],
  },
]

const statusCode = `// CLEAN MISS — the search ran, answer is none
{
  "status": "empty_result",
  "success": true,
  "results": []
}

// ACCESS FAILURE — the search didn't complete
{
  "status": "access_failure",
  "success": false,
  "failure_type": "timeout",
  "attempted_query": "customer@example.com",
  "partial_results": [],
  "alternatives": [
    "Retry in 5s",
    "Check replica database"
  ]
}`

const antiPatternBad = `On timeout: return empty list, log success.

{
  "results": []
}

→ Indistinguishable from a real miss.
→ Coordinator can't tell the two apart.`

const antiPatternFix = `On timeout: return structured error.
On no match: return empty + success flag.

{ "status": "empty_result", "success": true }
  vs.
{ "status": "access_failure",
  "success": false, ... }`
</script>

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div class="di-cover">
    <div class="di-cover__eyebrow">Domain 5 · Lecture 7.9</div>
    <div class="di-cover__title">Access Failure vs<br/>Valid Empty Result</div>
    <div class="di-cover__subtitle">Two shapes of empty. One is the answer. One is silence.</div>
  </div>
</Frame>

<style scoped>
.di-cover { flex: 1; display: flex; flex-direction: column; justify-content: center; gap: 32px; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 28px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); }
.di-cover__title { font-family: var(--font-display); font-size: 108px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); max-width: 1500px; }
.di-cover__subtitle { font-family: var(--font-display); font-size: 40px; color: var(--mint-200); font-style: italic; }
</style>

<!--
Lecture 7.9. Access failure versus valid empty result. This is a single-concept lecture, and the concept is: two very different things can produce the same empty data structure, and collapsing them is the worst error you can make in a reliability system.

This is a short lecture, but it's high-leverage. The exam tests this distinction across Scenarios 1, 3, and 6 — anywhere a tool or subagent can return nothing. If you internalize this one distinction, you pick up points in three scenarios from a single pattern.
-->

---

<ComparisonTable
  title="Two empty shapes"
  :columns="['Meaning', 'Recovery']"
  :rows="distinctionRows"
/>

<!--
Two shapes of empty. The first: empty because the query failed to execute. Timeout, permission denied, service unavailable, rate limit. The answer is unknown. Recovery is retry or route to an alternative.

The second: empty because the query succeeded but found no matches. "No customer with that email." "No documents mentioning that topic." "No orders in the date range." That IS the answer. Recovery is proceed with the null result — the search ran, and the answer is none.

Same data structure in the naive implementation. Totally different meanings. Totally different next actions. The exam asks about this collapse directly.
-->

---

<ConceptHero
  leadLine="Collapsing is worse than failing loudly"
  concept="Silent ≠ safe."
  supportLine="Treating access failure as empty is a false negative. Coordinator proceeds as if the search ran and found nothing."
/>

<!--
Collapsing is worse than failing loudly. If you treat access failure as empty, you've produced a false negative — you're asserting "we checked and there's nothing" when actually you never checked. The coordinator proceeds as if the search ran successfully and found nothing. The report ships. The decision gets made on non-data.

Failing loudly — propagating the failure explicitly — is recoverable. The coordinator knows to retry, to route, to flag. Collapsing silently is not recoverable. Nobody knows anything went wrong, because everything looks like it worked. The report is produced; the user reads it; the error surfaces days later when someone notices the research missed a whole branch.
-->

---

<CodeBlockSlide
  title="Distinct statuses in the schema"
  lang="json"
  :code="statusCode"
  annotation="Two statuses, two recovery branches. Never the same [] for both."
/>

<!--
The fix is distinct statuses in the response schema. On a clean miss: status "empty_result," success true. On a failure: status "access_failure," success false, plus the failure fields we covered in 7.8 — failure_type, attempted_query, partial_results, alternatives.

Two statuses, two branches in the coordinator's recovery logic. Never the same `[]` for both cases. The schema itself enforces the distinction — it's not a convention, it's a contract.
-->

---

<CalloutBox variant="tip" title="Scenario 1 — customer support angle">

"Customer not found" vs "customer database timed out" — two completely different user experiences.

<p>If the agent says "we don't have a record of you" when actually the database timed out, you've insulted the customer AND lost the transaction. Distinguish the two, or apologize twice.</p>

</CalloutBox>

<!--
This isn't just a Scenario 3 problem. Customer support — Scenario 1 — hits it too. "Customer not found" and "customer database timed out" are completely different user experiences. If the agent says "we don't have a record of you" when actually the database timed out, you've insulted the customer AND lost the transaction. The customer leaves angry; the ticket closes wrong; the business sees "resolved" in the metrics and can't diagnose the underlying outage.

Distinguish the two, or apologize twice. Once for the outage, once for calling them a non-customer.
-->

---

<AntiPatternSlide
  title="Don't return [] for both"
  lang="text"
  :badExample="antiPatternBad"
  whyItFails="The schema allows both cases to return the same shape. That's an interface bug, not a convention you can follow carefully."
  :fixExample="antiPatternFix"
/>

<!--
The anti-pattern: on timeout, return an empty list and log success. That's the silent-suppression shape we warned about in 7.8 — same failure mode, zoomed in. The better pattern: on timeout, return a structured error; on no match, return an empty result with a success flag. Two distinct shapes. Two distinct statuses. No ambiguity at the coordinator layer.

If your subagent interface allows both cases to return `{"results": []}` with no status field, that's a bug in the interface, not a convention you can follow carefully. Fix the interface.
-->

---

<CalloutBox variant="tip" title="On the exam">

Sample questions test this collapse. The right answer always distinguishes the two.

<p>Distractors: "treat empty as empty" or "retry all empty results." Both collapse — one wastes tokens, the other silently loses data. Almost-right again.</p>

</CalloutBox>

<!--
On the exam, the shape is: the question describes a subagent returning empty results under two different conditions — timeout and genuine no-match — and asks how to handle them. The right answer always distinguishes the two in the response. The distractor is "treat empty as empty" or "retry all empty results" — both collapse the two cases and lose the distinction. Almost-right again. Retrying a valid empty result is a waste of tokens; not retrying an access failure is a silent loss.
-->

---

<Frame bg="var(--mint-100)">
  <Eyebrow>Closing</Eyebrow>
  <SlideTitle>Next up: 7.10 — Coverage Annotations in Synthesis Output.</SlideTitle>

  <div class="closing-body">
    <p>The generic name for today's distinction: <em>"distinguishing failure from null."</em> It shows up everywhere an empty response can happen. Ask: does the schema let me tell failure from null? If not, you're one flaky connection away from a silent data-loss bug.</p>
    <p>Now we zoom back out from the subagent layer to the coordinator layer — how synthesis surfaces what DIDN'T get covered.</p>
  </div>
</Frame>

<style scoped>
.closing-body { margin-top: 56px; font-family: var(--font-body); font-size: 28px; line-height: 1.5; color: var(--forest-500); max-width: 1400px; }
.closing-body p + p { margin-top: 20px; }
.closing-body p em { color: var(--forest-800); font-style: italic; }
</style>

<!--
One more framing note. This distinction has a generic name worth knowing — "distinguishing failure from null." It shows up across every subagent interface, every tool response, every database query the agent touches. Wherever an empty response can happen, ask: does the schema let me tell failure from null? If not, you're one flaky network connection away from a silent data-loss bug. Fix it in the interface before you need it in production.

Next up: 7.10, coverage annotations in synthesis output. We're zooming back out from the subagent layer to the coordinator layer — and asking how the coordinator surfaces what DIDN'T get covered in its final synthesis. Same honesty principle, one layer up. See you there.
-->
