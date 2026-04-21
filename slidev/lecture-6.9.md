---
theme: default
title: "Lecture 6.9: Validation-Retry Loops"
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
const loopSteps = [
  { label: 'Extract', sublabel: 'tool_use with your schema' },
  { label: 'Validate', sublabel: 'Run computed invariants — sum checks, cross-field consistency' },
  { label: 'Retry with feedback', sublabel: 'Send: original doc + failed extraction + specific errors' },
  { label: 'Claude retries', sublabel: 'Re-extract with the error context in view' },
  { label: 'Validate again', sublabel: 'Commit or escalate to human review' },
]

const effectivenessRows = [
  {
    label: 'Date format wrong',
    cells: [
      { text: 'YES — information exists, just needs reformatting', highlight: 'good' },
    ],
  },
  {
    label: "Total doesn't sum",
    cells: [
      { text: 'YES — model can re-extract line items and get it right', highlight: 'good' },
    ],
  },
  {
    label: 'Required field absent from document',
    cells: [
      { text: 'NO — no amount of retrying conjures missing data', highlight: 'bad' },
    ],
  },
  {
    label: 'Customer ID in an external system not provided',
    cells: [
      { text: "NO — external data isn't in the source", highlight: 'bad' },
    ],
  },
]

const retryPrompt = `Original document:
<doc>{...}</doc>

Your prior extraction:
{
  "line_items": [...],
  "stated_total": 1000
}

Specific validation errors:
- line_items sum to 950 but stated_total is 1000;
  they must match.

Please re-extract, correcting the above errors.`

const badRetry = `for attempt in range(5):
    result = claude.extract(doc)
    if validate(result):
        break
# Same answer five times for absent-data docs.`

const goodRetry = `for attempt in range(2):
    result = claude.extract(doc, prior_errors=errors)
    if validate(result):
        return result
    errors = diff(result)

if data_absent_from_source(result):
    return null_out_or_route_to_human(result)`
</script>

<CoverSlide
  title="When Validation-Retry Works — and When It Doesn't"
  subtitle="Retries fix format and structure. They can't fix absence."
  eyebrow="Domain 4 · Lecture 6.9"
  :stats="['Section 6', 'Scenario 6', 'Domain 4 · 20%', '8 min']"
/>

<!--
Continuing from 6.8, where we drew the line between syntax errors — which tool_use eliminates — and semantic errors — which it doesn't. This lecture is about the pattern that catches the semantic ones: the validation-retry loop. Eight minutes. We cover what the loop looks like, what it fixes, and — critically — what it can't fix no matter how many times you retry. That last part is the exam question.
-->

---

<FlowDiagram
  eyebrow="The loop"
  title="Retry with feedback — five steps"
  :steps="loopSteps"
/>

<!--
Here's the loop in five steps. One: extract using tool_use with your schema. Two: validate — run your computed invariants, like sum checks or cross-field consistency. Three: if validation fails, send Claude a second request with the original document, the failed extraction, and the specific validation errors. Four: Claude retries with the error context. Five: validate again. That's the whole pattern — retry with error feedback, not blind retry. The feedback is what makes it work.
-->

---

<CalloutBox variant="tip" title="Works for — fixable errors">
  <p><strong>Format mismatches</strong> — <em>&ldquo;you returned the date as MM/DD/YYYY; return it as ISO-8601.&rdquo;</em> Claude re-reads and corrects.</p>
  <p><strong>Structural output errors</strong> — <em>&ldquo;you returned line_items as an object instead of an array.&rdquo;</em> Retry fixes that.</p>
  <p><strong>Semantic errors the document can resolve</strong> — <em>&ldquo;line items sum to $950 but stated_total is $1,000; check your extraction.&rdquo;</em></p>
  <p>If the correct answer exists in the source, retry-with-feedback usually finds it on pass two.</p>
</CalloutBox>

<!--
Here's what retry fixes. Format mismatches — "you returned the date as MM/DD/YYYY, return it as ISO-8601." Claude re-reads and corrects. Structural output errors — "you returned line_items as an object instead of an array." Retry fixes that too. Semantic errors the document can resolve — "line items sum to nine fifty but stated total is one thousand; check your extraction." If the correct answer exists in the source, retry-with-feedback usually finds it on pass two.
-->

---

<CalloutBox variant="warn" title="Doesn't work for — unfixable errors">
  <p>If the information isn't there, <strong>it isn't there</strong>. Retrying won't summon data that never existed in the source.</p>
  <p>Customer ID required but the document doesn't contain one → retry a hundred times; the model still can't produce what isn't there. Only outcomes: null (if schema allows) or fabrication (if field is required).</p>
  <p>Exam guide, Task 4.4: retries are ineffective when the required information is simply absent from the source.</p>
</CalloutBox>

<!--
Here's what retry cannot fix. If the information isn't there, it isn't there. Retrying won't summon data that never existed in the source. Customer ID required but the document doesn't contain one — retry a hundred times and the model still can't produce what isn't there. The only outcomes are null (if your schema allows it) or fabrication (if the field is required). The exam guide is explicit about this under Task 4.4: retries are ineffective when the required information is simply absent from the source.
-->

---

<ComparisonTable
  eyebrow="Retry effectiveness"
  title="Four concrete cases — know the split by stem wording"
  :columns="['Retry effective?']"
  :rows="effectivenessRows"
/>

<!--
Let me make the distinction concrete. Date format wrong? Retry works — the information exists, it just needs reformatting. Total doesn't sum? Retry usually works — the model can re-extract the line items and get it right. Required field absent from the document? Retry fails — no amount of retrying conjures missing data. Customer ID referenced in an external system not provided? Retry fails — external data isn't in the source. Four cases, and you need to know which is which by the wording of the stem.
-->

---

<CodeBlockSlide
  eyebrow="The retry prompt shape"
  title="Original doc + failed extraction + specific errors"
  lang="text"
  :code="retryPrompt"
  annotation="Vague retries don't work. Specific validation errors guide the model to the exact field that needs correction. Exam guide Task 4.4."
/>

<!--
The effective retry prompt has three components. One: the original document. Two: the failed extraction — what Claude returned that didn't validate. Three: the specific validation errors — not "this is wrong," but "line_items sum to 950 but stated_total is 1000; they must match." Vague retries don't work. Specific validation errors guide the model to the exact field that needs correction. This is the exam guide's wording under Task 4.4 — "appending specific validation errors to the prompt on retry."
-->

---

<CalloutBox variant="tip" title="When to stop — cap retries">
  <p>Detect <strong>information-absent</strong> cases before the loop runs forever. If retry two can't produce the required field, the data isn't there — it's not going to appear on retry five.</p>
  <p>Cap retries at <strong>two or three</strong>. On failure: null-out the field (if schema permits) or route to human review.</p>
  <p>Mental move: retry is a tactic for fixable errors, not a universal hammer.</p>
</CalloutBox>

<!--
When to stop looping. Before the retry loop runs forever, detect "information absent" cases. If your second retry still can't produce the required field, the data isn't there — it's not going to appear on retry five. Cap retries at two or three. On failure, either null-out the field (if your schema permits) or route the document to human review. Don't burn tokens in a loop that cannot succeed. The mental move is: retry is a tactic for fixable errors, not a universal hammer.
-->

---

<AntiPatternSlide
  title="Don't retry indefinitely"
  lang="python"
  :badExample="badRetry"
  whyItFails="Expensive, slow, and produces the same wrong answer for unfixable cases."
  :fixExample="goodRetry"
/>

<!--
The anti-pattern is the five-retry "hope for the best" loop. It's expensive, it's slow, and for the unfixable cases, it produces the same answer five times in a row. The replacement: detect when the document lacks the required field, null it out if allowed, route to human review if the field is genuinely required. Build the "can this be fixed by retry?" check into your validation layer, not after it.
-->

---

<CalloutBox variant="tip" title="On the exam — the absent-info question">
  <p>Stem: <em>&ldquo;When is a validation-retry loop ineffective?&rdquo;</em></p>
  <p>Answer: <strong>when the required information exists only in an external document or system not provided to the model.</strong></p>
  <p>That exact phrasing shows up in correct answers. Distractors — &ldquo;when the prompt is too long,&rdquo; &ldquo;when the temperature is high&rdquo; — are wrong.</p>
</CalloutBox>

<!--
On the exam, the stem often reads like: "when is a validation-retry loop ineffective?" The answer is almost always: when the required information exists only in an external document or system not provided to the model. That exact phrasing shows up in correct answers. Distractors will say "when the prompt is too long" or "when the temperature is high" — both wrong. The right answer is information-absence. Memorize that mapping. It's a specific Scenario 6 question type.
-->

---

<ClosingSlide nextLecture="6.10 — The detected_pattern Field for False Positive Analysis" />

<!--
Carry this forward: retry works for fixable errors — format, structure, resolvable semantic mismatches — and fails when the data isn't in the source. Cap retries, route absent-data cases to human review, and always include specific validation errors in the retry prompt. Next lecture, 6.10, we cover the detected_pattern field — a systematic way to analyze which prompts are generating false positives, so you can fix at the pattern layer instead of case-by-case. See you there.
-->
