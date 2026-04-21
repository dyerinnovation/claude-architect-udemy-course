---
theme: default
title: "Lecture 6.8: Syntax vs Semantic Errors"
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
const errorRows = [
  {
    label: 'Syntax',
    cells: [
      { text: 'Malformed JSON, missing fields, wrong types, truncation', highlight: 'neutral' },
      { text: 'YES — eliminated by construction', highlight: 'good' },
    ],
  },
  {
    label: 'Semantic',
    cells: [
      { text: "Wrong values, line items don't sum, cross-field inconsistency", highlight: 'neutral' },
      { text: 'NO — the schema can\u2019t see meaning', highlight: 'bad' },
    ],
  },
]

const syntaxKilled = [
  { label: 'Invalid JSON', detail: 'API rejects the model\u2019s output before you see it.' },
  { label: 'Missing required fields', detail: 'Schema validation catches the gap.' },
  { label: 'Wrong types', detail: 'Declared number → you get a number, not a numeric string.' },
  { label: 'Truncated output from token limits', detail: 'API enforces completion.' },
]

const semanticUnseen = [
  { label: 'Values in the wrong fields', detail: 'Invoice number in customer_id slot — schema happy, data wrong.' },
  { label: 'Math doesn\u2019t add up', detail: 'Line items sum to $950, stated_total is $1,000.' },
  { label: 'Logical contradictions', detail: 'Contract signed 2025, expires 2020.' },
  { label: 'Dates in the future for a past event', detail: 'Schema valid, reality inverted.' },
]

const canonicalExample = `{
  "invoice_number": "INV-1847",
  "line_items": [
    {"description": "Widget A", "amount": 400},
    {"description": "Widget B", "amount": 300},
    {"description": "Widget C", "amount": 250}
  ],
  "stated_total": 1000.00
}

// Line items sum to 950. stated_total is 1000.
// Schema-valid. Semantically broken. You've been
// short-changed by 50 — and the schema never flagged it.`

const badShipSchema = `if validate_schema(extracted_json):
    ship_to_downstream(extracted_json)
# Schema-valid != correct. Wrong values go through.`

const goodInvariants = `if validate_schema(extracted_json):
    invariants_ok = (
        sum_of_line_items_matches_stated_total(extracted_json)
        and dates_are_consistent(extracted_json)
    )
    if invariants_ok:
        ship_to_downstream(extracted_json)
    else:
        flag_for_review(extracted_json)`
</script>

<CoverSlide
  title="Syntax vs Semantic Errors"
  subtitle="tool_use eliminates syntax errors. It doesn't eliminate semantic ones."
  eyebrow="Domain 4 · Lecture 6.8"
  :stats="['Section 6', 'Scenario 6', 'Domain 4 · 20%', '7 min']"
/>

<!--
Short lecture. One distinction. Seven minutes. The distinction is: tool_use eliminates syntax errors — it doesn't eliminate semantic errors. That sentence is the whole lecture, and it's also one of the most tested single claims in Domain 4. The exam will give you a scenario where a schema-valid extraction is still wrong, and the right answer requires knowing exactly what tool_use can and can't guarantee.
-->

---

<ComparisonTable
  eyebrow="Two error classes"
  title="What tool_use solves — and what it doesn't"
  :columns="['Example', 'tool_use solves?']"
  :rows="errorRows"
/>

<!--
Two classes of error. Syntax errors — the output is malformed. Invalid JSON, missing braces, wrong types. tool_use solves these — yes, completely. Semantic errors — the output is well-formed but factually wrong. Line items don't sum to the stated total. Dates are inconsistent. Values are in the wrong fields. tool_use does not solve these. At all. The schema can't see meaning — only shape and type.
-->

---

<BulletReveal
  eyebrow="What tool_use kills by construction"
  title="Syntax errors — eliminated"
  :bullets="syntaxKilled"
/>

<!--
Here's what tool_use eliminates by construction. Invalid JSON. Missing required fields — the API rejects the model's output before you see it. Wrong types — if you said number, you get a number, not a numeric string. Truncated output from token limits — the API enforces completion. That entire category of problems is gone. You can delete the JSON-repair code you wrote in 2023. Tool_use made it redundant.
-->

---

<BulletReveal
  eyebrow="What tool_use can't see"
  title="Semantic errors — still there"
  :bullets="semanticUnseen"
/>

<!--
And here's what tool_use can't see. Values in the wrong fields — the model puts the invoice number in the customer_id slot. The schema accepts a string in each, so the schema is happy. The data is wrong. Math doesn't add up — line items sum to nine hundred fifty, stated total is one thousand. Schema-valid, semantically broken. Logical contradictions — a contract signed in 2025 with an expiration in 2020. Schema passes, reality fails. Dates in the future for a past event. Schema happy, data lies. Each of these is a different flavor of the same failure: the shape is right, the meaning is wrong.
-->

---

<CodeBlockSlide
  eyebrow="The canonical example"
  title="Schema-valid. Semantically wrong."
  lang="json"
  :code="canonicalExample"
  annotation="This is the difference between syntax-valid and correct. The API returns success. Your downstream code pays $1,000. You've been short-changed by $50 and the schema never knew."
/>

<!--
Here's the canonical example that shows up in exam stems. Invoice extraction: line_items is an array of three items totaling nine hundred fifty dollars, stated_total is one thousand dollars. The schema accepts both — line_items is a valid array of valid objects, stated_total is a valid number. The API returns success. Your downstream code reads stated_total and pays one thousand. You've been short-changed by fifty, and the schema never flagged it. This is the difference between syntax-valid and correct.
-->

---

<CalloutBox variant="tip" title="Next lecture preview — validation-retry">
  <p>The fix is in <strong>6.9</strong>. Preview: extract <code>calculated_total</code> (computed from line_items) alongside <code>stated_total</code>, compare in post-processing.</p>
  <p>If they don't match, flag the extraction or retry with feedback. The schema can't enforce the equality — your validation layer can. Exam guide Task 4.4.</p>
</CalloutBox>

<!--
The fix for this is in 6.9. Quick preview: you add a computed invariant to the extraction — extract calculated_total (computed from line_items) alongside stated_total, and compare them in post-processing. If they don't match, you flag the extraction or retry with feedback. The schema can't enforce the equality, but your validation layer can. This is the pattern the exam guide names explicitly under Task 4.4. We go deep on it next lecture.
-->

---

<AntiPatternSlide
  title="Don't ship on &ldquo;schema passed&rdquo;"
  lang="python"
  :badExample="badShipSchema"
  whyItFails="Schema passed means syntactically valid — nothing about meaning."
  :fixExample="goodInvariants"
/>

<!--
The anti-pattern is shipping on "schema passed." Schema passed means syntactically valid — nothing about the meaning. The fix is computing invariants after extraction: sum checks, cross-field consistency, date ordering, any relationship your domain has. Then catch semantic errors before the data hits downstream systems. This is where validation-retry earns its keep — and where many production extraction pipelines silently fail for months before someone notices the numbers. The mental move is: treat the schema as the input contract, not the correctness guarantee. Your validation layer is what enforces correctness, and it has to know the domain invariants the schema can't express.
-->

---

<CalloutBox variant="tip" title="On the exam — what &ldquo;X&rdquo; is in &ldquo;tool_use eliminates X&rdquo;">
  <p>X = <strong>syntax errors</strong>. Not all errors.</p>
  <p>If the question hints at wrong values, mismatched numbers, or cross-field inconsistencies → <strong>semantic validation</strong> is the answer, not tool_use alone.</p>
  <p>Almost-right trap: a distractor might say <em>&ldquo;tool_use guarantees the extraction is correct.&rdquo;</em> It doesn't. It guarantees the extraction is <strong>well-formed</strong>. Two different claims.</p>
  <p>Tell in the stem: <em>correct, wrong values, doesn't match, sum mismatch</em> — all point at semantic validation.</p>
</CalloutBox>

<!--
On the exam, this distinction is sharp. "Tool_use eliminates X" — X is syntax errors. Not all errors. If the question hints at wrong values, mismatched numbers, or cross-field inconsistencies, semantic validation is the answer — not tool_use alone. Almost-right is the trap: a distractor might say "tool_use guarantees the extraction is correct." It doesn't. It guarantees the extraction is well-formed. Two different claims. Scenario 6 — structured extraction — tests this distinction directly, and remember the six-pick-four, you don't know whether Scenario 6 lands in your four, so you prepare for it. The tell in the stem is words like "correct," "wrong values," "doesn't match," or "sum mismatch" — all point at semantic validation, not tool_use.
-->

---

<ClosingSlide nextLecture="6.9 — Validation-Retry Loops: When They Work and When They Don't" />

<!--
Carry this forward as one sentence: tool_use eliminates syntax errors — not semantic errors. Schema-valid is not correct. Next lecture, 6.9, we build the validation-retry loop: when retries work (format and structural errors), when they don't (information absent from the source), and the prompt shape that makes retry effective. See you there.
-->
