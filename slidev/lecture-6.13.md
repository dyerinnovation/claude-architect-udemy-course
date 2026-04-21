---
theme: default
title: "Lecture 6.13: Batch Failure Handling with custom_id"
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
const customIdSchema = `{
  "requests": [
    {
      "custom_id": "doc-row-1847",      // ← your stable ID
      "params": {
        "model": "claude-opus-4-7",
        "max_tokens": 1024,
        "tools": [...],
        "tool_choice": {"type": "any"},
        "messages": [...]
      }
    },
    {
      "custom_id": "doc-row-1848",
      "params": {...}
    }
  ]
}`

const failureModes = [
  { label: 'Document exceeded context limit', detail: 'Token count too high for the model — needs chunking.' },
  { label: 'Rate limits mid-batch', detail: 'A burst partway through the job hits a rate ceiling.' },
  { label: 'Schema validation rejected', detail: 'Specific document produced output that failed schema validation.' },
  { label: 'Transient model errors', detail: 'Individual requests flake — retry typically resolves.' },
]

const resubmitSteps = [
  { title: 'Batch completes', body: 'Mix of successes and failures — the batch as a whole didn\u2019t fail.' },
  { title: 'Identify failures by custom_id', body: 'Iterate results, find the five out of one thousand that failed.' },
  { title: 'Apply the fix per failure type', body: 'Chunk oversized docs, adjust prompts for schema-validation failures.' },
  { title: 'Resubmit only the failed docs', body: 'Reuse the original custom_ids. Downstream waits for the second batch.' },
]

const chunkingCode = `# Doc X exceeded context — chunk and resubmit
original_id = "doc-X"

chunks = split_doc(doc_X, max_tokens=80_000)
# → ["doc-X-chunk-A", "doc-X-chunk-B", "doc-X-chunk-C"]

resubmit_batch([
  {"custom_id": f"{original_id}-chunk-{c.label}", "params": c.params}
  for c in chunks
])

# Merge the three extractions back under original_id
# in post-processing. custom_id lineage preserves traceability.`
</script>

<CoverSlide
  title="Batch Failure Handling with custom_id"
  subtitle="Your resubmission primary key. Resubmit the five, not the thousand."
  eyebrow="Domain 4 · Lecture 6.13"
  :stats="['Section 6', 'Scenario 6', 'Domain 4 · 20%', '7 min']"
/>

<!--
Third and final lecture in the batch-processing triplet. Seven minutes. We covered what batch is (6.11) and when to pick it (6.12). Now we handle what goes wrong mid-batch and how to recover cleanly. The unifying primitive is custom_id — your resubmission primary key. Without it, failures force you to resubmit the entire batch; with it, you resubmit only the failures. That's the exam question, and it's also how you don't blow through your token budget in production.
-->

---

<ConceptHero
  leadLine="A stable ID tied to each request — your primary key across the whole lifecycle."
  concept="Your correlation key"
  supportLine="custom_id ties request to response — and to retries. Without it, you can't tell which response belongs to which input document."
/>

<!--
Here's what custom_id is. A string you assign to each request in the batch — typically a stable identifier like a document ID, an S3 key, or a database primary key. It ties the request to the response, and — just as important — it ties the request to retries. Without a custom_id, you can't tell which response belongs to which input document. With it, you have a stable primary key across the whole lifecycle of a document through batch processing.
-->

---

<CodeBlockSlide
  eyebrow="Schema"
  title="A batch request carries custom_id + params"
  lang="json"
  :code="customIdSchema"
  annotation="For a 1,000-document extraction job, your custom_ids might be the document's row ID — so downstream processing writes back to the same row without ambiguity."
/>

<!--
Every batch request carries a custom_id field. Each request object in your batch has a custom_id and a params block — the params is your actual Messages API call, and the custom_id is your label. After the batch completes, responses come back keyed by custom_id. You join responses to inputs by that key. For a thousand-document extraction job, your custom_ids might be the document's row ID in your database, so downstream processing writes back to the same row without ambiguity.
-->

---

<BulletReveal
  eyebrow="Failure modes"
  title="What fails mid-batch — individual requests, not the whole batch"
  :bullets="failureModes"
/>

<!--
Here's what fails mid-batch. One: a document exceeded the context limit — token count too high for the model. Two: rate limits hit partway through. Three: a specific document produced output that failed schema validation. Four: transient model errors on individual requests. The batch as a whole doesn't fail — individual requests within it do. Your job is to identify which requests failed, fix the root cause for those, and resubmit only them. Not the thousand, the five.
-->

---

<StepSequence
  eyebrow="Resubmission pattern"
  title="Selective resubmit by custom_id"
  :steps="resubmitSteps"
/>

<!--
Here's the pattern. Step one: batch completes — mix of successes and failures. Step two: iterate the results, identify failures by custom_id. Step three: apply the fix for each failure type — chunk the oversized documents, adjust prompts for the schema-validation failures. Step four: resubmit only the failed documents, reusing their original custom_ids. Your downstream system just waits for the second batch — the successful results from batch one are already written, the failed ones get re-attempted. Clean, idempotent, token-efficient.
-->

---

<CodeBlockSlide
  eyebrow="Chunking example"
  title="Chunk oversize docs and resubmit"
  lang="python"
  :code="chunkingCode"
  annotation="Exam guide Task 4.5 — 'chunking documents that exceeded context limits.' Memorize 'chunking' as the move for oversize failures."
/>

<!--
Concrete example. Document X exceeded the context limit. You chunk it into three sections — say, sections A, B, and C. You derive new custom_ids by extending the original: doc-X-chunk-A, doc-X-chunk-B, doc-X-chunk-C. You resubmit these three in the next batch. When they complete, you merge the three extractions in post-processing back under the original doc-X identifier. The custom_id lineage preserves traceability. You didn't lose the document — you just processed it in chunks that fit. This is the exam guide's exact phrasing under Task 4.5 — "chunking documents that exceeded context limits." Memorize "chunking" as the move for oversize failures.
-->

---

<CalloutBox variant="tip" title="Scale discipline — refine before you scale">
  <p>Before batch-processing <strong>10,000</strong> documents, refine your prompt on a sample of <strong>50</strong>.</p>
  <p>If your prompt has a subtle bug, you want to find it at document 50 — not at document 6,000, after 20 hours of batch runtime.</p>
  <p>Exam guide Task 4.5: <em>&ldquo;using prompt refinement on a sample set before batch-processing large volumes to maximize first-pass success rates.&rdquo;</em></p>
  <p>The alternative is burning $100 of batch before you notice the error.</p>
</CalloutBox>

<!--
Scale discipline. Before batch-processing ten thousand documents, refine your prompt on a sample of fifty. If your prompt has a subtle bug, you want to find it at document fifty — not at document six thousand, after twenty hours of batch runtime. This is the exam guide's exact phrasing under Task 4.5 — "using prompt refinement on a sample set before batch-processing large volumes to maximize first-pass success rates." The alternative is burning through a hundred dollars' worth of batch before you notice the error.
-->

---

<CalloutBox variant="tip" title="On the exam — resubmit only the failed docs">
  <p>Stem: <em>&ldquo;how do you handle batch failures?&rdquo;</em></p>
  <p>Right answer: <strong>resubmit only the failed documents, identified by custom_id, with appropriate modifications.</strong></p>
  <p>Distractor: <em>&ldquo;resubmit the whole batch.&rdquo;</em> Sounds safer and simpler. Doubles your costs for no reason.</p>
  <p>Almost-right trap: whole-batch resubmission is wasteful and wrong. The exam rewards per-request recovery.</p>
</CalloutBox>

<!--
On the exam, the right answer to "how do you handle batch failures?" is: resubmit only the failed documents, identified by custom_id, with appropriate modifications. "Resubmit the whole batch" is the distractor — it's wasteful and wrong. Almost-right is the trap: whole-batch resubmission sounds safer and simpler, but it doubles your costs for no reason. The exam rewards per-request recovery, not all-or-nothing. And remember the thread from 6.11 and 6.12 — the batch API has constraints you're architecting around, not hoping will go away. custom_id is one of the primitives that makes batch usable at scale.
-->

---

<ClosingSlide nextLecture="6.14 — Multi-Instance Review Architecture" />

<!--
Carry this forward: custom_id is your correlation and resubmission key — use stable IDs, identify failures by custom_id, chunk oversized docs with derived IDs, and resubmit only the failures. Next lecture, 6.14, we shift from batch to review architecture — why a second independent Claude instance catches what self-review misses, and why "extended thinking" doesn't fix the underlying bias. See you there.
-->
