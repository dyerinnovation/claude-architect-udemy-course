---
theme: default
title: "Lecture 6.11: The Message Batches API"
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
const threeFacts = [
  { label: '50% cheaper than synchronous', detail: 'Real, flat — not "up to," not "in some cases." Half off.' },
  { label: 'Up to 24-hour completion', detail: 'Could come back in 20 minutes. Could come back in 23 hours. You can\u2019t rely on faster.' },
  { label: 'No guaranteed latency SLA', detail: 'Plan against the 24-hour upper bound, not the average case.' },
]

const customIdCode = `{
  "requests": [
    {
      "custom_id": "doc-S3-key-abc123",
      "params": {
        "model": "claude-opus-4-7",
        "max_tokens": 1024,
        "messages": [...]
      }
    },
    {
      "custom_id": "doc-S3-key-def456",
      "params": {...}
    }
  ]
}

// After the batch completes, responses are keyed by
// custom_id. You match response ↔ doc without ambiguity.`
</script>

<CoverSlide
  title="The Message Batches API"
  subtitle="50% savings. 24-hour window. No multi-turn tool calling."
  eyebrow="Domain 4 · Lecture 6.11"
  :stats="['Section 6', 'Scenarios 5 & 6', 'Domain 4 · 20%', '8 min']"
/>

<!--
Gears shift. We've been in prompt engineering and structured output; the next three lectures are the batch-processing triplet. This one covers the Message Batches API — the offer, the trade, and the limitations. Eight minutes. Three facts to memorize cold, because this API is tested directly on Scenario 5 and Scenario 6 sample questions — including Sample Q11, which we'll quote later in this lecture.
-->

---

<BigNumber
  eyebrow="The offer"
  number="50%"
  unit=" cost savings"
  caption="Trade: up to 24-hour processing, no guaranteed latency SLA."
  detail="Real, flat — not &ldquo;up to 50%,&rdquo; not &ldquo;in some cases.&rdquo; Half off. The request might come back in 20 minutes or in 23 hours. You don't know, and you can't rely on faster."
  accent="var(--sprout-500)"
/>

<!--
Here's the offer in one number: fifty percent. Fifty percent cost savings compared to synchronous API calls. That's the hook, and it's real — not "up to fifty percent," not "in some cases." Half off. The trade: up to a 24-hour processing window, with no guaranteed latency SLA. The request might come back in twenty minutes. It might come back in twenty-three hours. You don't know, and you can't rely on it completing faster than 24 hours.
-->

---

<BulletReveal
  eyebrow="Memorize these cold"
  title="Three facts about the Batches API"
  :bullets="threeFacts"
/>

<!--
Three facts, memorized cold. One: fifty percent cheaper than synchronous. Two: up to 24-hour completion. Three: no guaranteed latency SLA. Those three show up in correct answers verbatim. If a distractor says "ninety percent cheaper" or "guaranteed 2-hour turnaround," that's the tell — it's wrong on the facts. The exam is precise about the numbers on this one, same way it's precise about seven hundred twenty for the passing score.
-->

---

<CalloutBox variant="tip" title="Good fit — use batch for...">
  <p><strong>Overnight reports</strong> — submit at 6pm, results by morning standup.</p>
  <p><strong>Weekly audits</strong> — submit Friday night, results by Monday.</p>
  <p><strong>Nightly test generation</strong> — submit after CI finishes, new tests by daybreak.</p>
  <p>Pattern: no human is waiting, job has hours or days of runway. Those are the workloads where 50% savings cost you nothing.</p>
</CalloutBox>

<!--
Where batch shines. Overnight reports — submit at 6pm, results by morning standup. Weekly audits — submit Friday night, results by Monday. Nightly test generation — submit after CI finishes, have new tests ready at daybreak. Any non-blocking, latency-tolerant workload. The pattern is: no human is waiting, and the job has hours or days of runway. Those are the workloads where fifty percent savings cost you nothing.
-->

---

<CalloutBox variant="warn" title="Bad fit — don't batch...">
  <p><strong>Pre-merge checks</strong> — developers can't wait 24 hours for CI.</p>
  <p><strong>Interactive UIs</strong> — users close the tab.</p>
  <p><strong>Anything a human is watching in real time.</strong></p>
  <p>Hard rule: if a person is blocked on the result, batch is the wrong API. The 50%-savings number is a strong pull toward &ldquo;batch everything&rdquo; — that pull is the exam's favorite trap.</p>
</CalloutBox>

<!--
Where batch fails. Pre-merge checks — developers can't wait 24 hours for CI. Interactive UIs — users close the tab. Anything a human is watching in real time. The hard rule: if a person is blocked on the result, batch is the wrong API. This sounds obvious, but the fifty-percent-savings number is a strong pull toward "batch everything." That pull is the exam's favorite trap — more on that two slides down.
-->

---

<CalloutBox variant="warn" title="Hard constraint — no multi-turn tool calling">
  <p>Batch does <strong>not</strong> support multi-turn tool calling within a single request.</p>
  <p>You cannot execute tools mid-request and feed results back. Any agentic workflow that depends on the <code>tool_use → tool_result → continuation</code> loop — which is <strong>most</strong> agentic workflows — cannot run on the batch API.</p>
  <p>Batch is for single-shot requests. If your prompt requires tool execution and continuation, synchronous is mandatory. Task 4.5.</p>
</CalloutBox>

<!--
Here's a limitation most people don't know, and the exam tests it. Batch does not support multi-turn tool calling within a single request. You cannot execute tools mid-request and feed results back. That means any agentic workflow that depends on the tool_use → tool_result → continuation loop — which is most agentic workflows — cannot run on the batch API. Batch is for single-shot requests. If your prompt requires tool execution and continuation, synchronous is mandatory. This is Task 4.5 in the exam guide.
-->

---

<CodeBlockSlide
  eyebrow="custom_id — correlation key"
  title="Each batch request carries a custom_id"
  lang="json"
  :code="customIdCode"
  annotation="Without custom_id, you'd match by order — which breaks if anything is dropped. With it, you have a stable primary key. Deep dive in 6.13."
/>

<!--
Each batch request carries a custom_id — a string you assign that lets you match response to request after the batch completes. If you submit a thousand documents in a batch, you tag each with a custom_id — say, the document's S3 key or database row ID — and when results come back, you correlate. Without custom_id, you'd have to match by order, which breaks if anything is dropped. We go deep on this in 6.13 — for now, know the field exists and it's your primary correlation key.
-->

---

<CalloutBox variant="warn" title="Sample Q11 — the both-workflows distractor">
  <p>Team has two workflows: <strong>a blocking pre-merge check</strong> and <strong>an overnight technical-debt report</strong>. Manager proposes switching both to batch for the 50% savings.</p>
  <p><strong>Correct answer:</strong> batch the overnight report only. Keep sync for pre-merge.</p>
  <p>Distractors are variants of &ldquo;batch everything with a fallback&rdquo; or &ldquo;batch everything with status polling.&rdquo; All wrong — they paper over the fact that batch can't serve a blocking workflow with any SLA.</p>
  <p>Almost-right is the whole trap of this exam, and Q11 is a clean example.</p>
</CalloutBox>

<!--
Sample Q11 from the official exam guide. Team has two workflows: a blocking pre-merge check and an overnight technical-debt report. Manager proposes switching both to batch for the fifty-percent savings. Correct answer: batch the overnight report only, keep sync for pre-merge. The distractors are variants of "batch everything with a fallback" or "batch everything with status polling." All wrong — they try to paper over the fact that batch can't serve a blocking workflow with any SLA. Almost-right is the whole trap of this exam, and Q11 is a clean example.
-->

---

<CalloutBox variant="tip" title="Continuity — two scenarios, same API">
  <p><strong>Scenario 5 (CI/CD):</strong> batch on overnight technical-debt reports vs blocking pre-merge checks.</p>
  <p><strong>Scenario 6 (extraction):</strong> batch on document processing pipelines.</p>
  <p>Six-pick-four: either could show up, both could show up. The batch API is the shared hinge. That's why this lecture is pinned in the middle of Domain 4.</p>
</CalloutBox>

<!--
Scenario 5 — Claude Code for CI/CD — tests batch on overnight technical-debt reports versus blocking pre-merge checks. Scenario 6 — structured data extraction — tests batch on document processing pipelines. Two scenarios, same API, different framings. Remember the six-pick-four: either could show up, both could show up, and the batch API is the shared hinge. That's why this lecture is pinned in the middle of Domain 4.
-->

---

<ClosingSlide nextLecture="6.12 — Matching API Choice to Latency Requirements" />

<!--
Carry this forward as three facts: fifty percent cheaper, up to 24 hours, no latency SLA. Plus one hard constraint: no multi-turn tool calling within a batch request. Next lecture, 6.12, we turn this into a decision framework — matching API choice to workflow latency requirements. You'll walk out with a matrix you can apply directly to exam stems. See you there.
-->
