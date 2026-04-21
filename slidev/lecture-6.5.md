---
theme: default
title: "Lecture 6.5: tool_use + JSON Schemas"
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
const flowSteps = [
  { label: 'Define tool', sublabel: 'Extraction tool + JSON schema for input params' },
  { label: 'Claude returns tool_use', sublabel: 'Not free-form text — a tool_use call' },
  { label: 'API validates against schema', sublabel: 'Malformed output never reaches your code' },
  { label: 'Read structured data', sublabel: 'Dict, not a string — no JSON.loads()' },
]

const extractionTool = `tools = [{
  "name": "extract_invoice",
  "description": "Extract invoice data from a document.",
  "input_schema": {
    "type": "object",
    "required": ["invoice_number", "total_amount"],
    "properties": {
      "invoice_number": {"type": "string"},
      "total_amount":   {"type": "number"},
      "line_items": {
        "type": "array",
        "items": {
          "type": "object",
          "properties": {
            "description": {"type": "string"},
            "amount":      {"type": "number"}
          }
        }
      },
      "customer_email": {"type": ["string", "null"]}
    }
  }
}]`

const eliminated = [
  { label: 'Malformed JSON', detail: 'The API rejects the output before you see it.' },
  { label: 'Missing braces / truncated strings', detail: 'Schema validation catches structural damage.' },
  { label: 'Wrong field names', detail: 'Schema names are the contract — mismatches fail validation.' },
  { label: 'Wrong types', detail: 'If you declared a number, you get a number — not a numeric string.' },
]

const comparisonRows = [
  {
    label: 'Prompt: &ldquo;return JSON&rdquo;',
    cells: [
      { text: 'None', highlight: 'bad' },
      { text: 'Zero effort, unreliable' },
    ],
  },
  {
    label: 'tool_use + strict schema',
    cells: [
      { text: 'Syntax-valid, schema-compliant', highlight: 'good' },
      { text: 'Schema design work up front' },
    ],
  },
]
</script>

<CoverSlide
  title="tool_use + JSON Schemas"
  subtitle="Zero syntax errors. The most reliable structured-output mechanism Claude offers."
  eyebrow="Domain 4 · Lecture 6.5"
  :stats="['Section 6', 'Scenario 6', 'Domain 4 · 20%', '8 min']"
/>

<!--
This lecture is the anchor concept for Scenario 6 — structured data extraction. Everything in the next four lectures plugs into what I'm about to tell you. If you take one sentence from this entire section into the exam, let it be this one: tool_use with a strict JSON schema is the most reliable structured-output mechanism Claude offers. Those exact words — "most reliable structured-output mechanism" — show up in exam stems and in correct answers. Hold onto that.
-->

---

<ConceptHero
  leadLine="Not &ldquo;fewer.&rdquo; Not &ldquo;rare.&rdquo; Zero."
  concept="Zero syntax errors"
  supportLine="tool_use with a strict JSON schema eliminates JSON syntax errors by construction — the API validates the model's output against the schema before returning it to you. It's the most reliable structured-output mechanism Claude offers."
/>

<!--
The core claim is zero syntax errors. Not "fewer." Not "rare." Zero. Tool_use with a strict JSON schema eliminates JSON syntax errors by construction, because the API validates the model's output against the schema before returning it to you. Malformed braces, truncated strings, missing required fields — impossible. This is the most reliable structured-output mechanism Claude offers. Repeat that phrasing as you study. It's the one correct answer shape on multiple exam questions.
-->

---

<FlowDiagram
  eyebrow="How it works"
  title="tool_use flow — four steps"
  :steps="flowSteps"
/>

<!--
Here's the flow. Step one: you define an extraction tool — say, `extract_invoice` — with a JSON schema as its input parameters. Step two: Claude returns a tool_use call, not free-form text. Step three: the input to that call is already validated against your schema by the API. Step four: you read structured data directly from the tool_use.input block. No parsing. No try/except around JSON.loads. The data is already a dict when you receive it.
-->

---

<CodeBlockSlide
  eyebrow="Example"
  title="An extraction tool with a strict schema"
  lang="python"
  :code="extractionTool"
  annotation="When Claude processes an invoice, it responds with a tool_use block whose input is a dict matching this schema exactly. No intermediate string parsing."
/>

<!--
Concretely, you define a tool named `extract_invoice` with input_schema containing fields like invoice_number as a required string, total_amount as a required number, line_items as an array of objects, and customer_email as an optional nullable string. When Claude processes an invoice document, it responds with a tool_use block whose input is a dict matching that schema exactly. You pull invoice_number, total_amount, and so on directly. No intermediate string parsing.
-->

---

<BulletReveal
  eyebrow="What tool_use kills"
  title="A whole class of bugs, eliminated by construction"
  :bullets="eliminated"
/>

<!--
Here's what tool_use kills. Malformed JSON — eliminated. Missing braces — eliminated. Truncated strings from token limits — the API rejects the output before you see it. Wrong field names — eliminated, because the schema names are the contract. That's a class of bugs that ate hours of developer time before tool_use existed. You can delete your JSON-repair library. The schema does the work.
-->

---

<CalloutBox variant="warn" title="Semantic errors remain">
  <p>tool_use eliminates syntax errors. It does <strong>not</strong> eliminate semantic errors.</p>
  <p>Schema-valid JSON can still be wrong. Line items that don't sum to the stated total. Values in the wrong fields. Dates in the future for a past event. The schema only enforces types and shape — not meaning.</p>
  <p>Covered in depth in <strong>6.8</strong>. For now: <em>&ldquo;schema-valid&rdquo; is not &ldquo;correct.&rdquo;</em></p>
</CalloutBox>

<!--
And now the warning. Tool_use eliminates syntax errors. It does not eliminate semantic errors. Schema-valid JSON can still be wrong. Line items that don't sum to the stated total. Values in the wrong fields. Dates in the future for a past event. The schema can't see those — it only enforces types and shape, not meaning. We cover this in depth in 6.8. For now, know that "schema-valid" is not "correct." The model can produce a schema-valid invoice that has a total of one thousand dollars and line items summing to nine hundred fifty.
-->

---

<ComparisonTable
  eyebrow="Structured-output approaches"
  title="Prompt &ldquo;return JSON&rdquo; vs tool_use + schema"
  :columns="['Guarantees', 'Trade']"
  :rows="comparisonRows"
/>

<!--
Compare the two approaches. Approach one: prompt Claude "return JSON." Guarantees: none. The model might return JSON with a preamble, or JSON wrapped in prose, or — worst — almost-JSON that doesn't parse. Zero effort, unreliable output. Approach two: define a tool with a JSON schema and use tool_use. Guarantees: syntax-valid, schema-compliant. The trade is schema design work up front. The schema is the specification. That's the trade the exam wants you to recognize.
-->

---

<CalloutBox variant="tip" title="On the exam — the exact phrase">
  <p>Any stem asking for <em>&ldquo;the most reliable way to get structured output&rdquo;</em> or <em>&ldquo;guaranteed schema-compliant output&rdquo;</em> is testing <strong>tool_use with a schema</strong>. Every time.</p>
  <p>Distractors: &ldquo;prompt the model to return JSON,&rdquo; &ldquo;parse with a repair library,&rdquo; &ldquo;use a larger model.&rdquo; All wrong when the stem says <strong>reliable</strong>.</p>
</CalloutBox>

<!--
On the exam, any stem that asks for "the most reliable way to get structured output" or "guaranteed schema-compliant output" is testing tool_use with a schema. Every time. Distractors will include "prompt the model to return JSON," "parse JSON from the response text with a repair library," and "use a larger model." All wrong. The correct phrasing is tool_use with a JSON schema. Almost-right is the trap — the distractors are plausible in a different context, but when the exam says "reliable," it means tool_use.
-->

---

<CalloutBox variant="tip" title="Continuity — Scenario 6's foundation">
  <p>Structured data extraction from unstructured docs — invoices, contracts, medical records — all of it lives on tool_use with a schema.</p>
  <p><strong>6.6</strong> covers <code>tool_choice</code>, which controls whether Claude can skip the tool call.</p>
  <p><strong>6.7</strong> covers schema design patterns that prevent the model from fabricating values to fill required fields.</p>
</CalloutBox>

<!--
This is Scenario 6's foundation. Structured data extraction from unstructured docs — invoices, contracts, medical records — all of it lives on tool_use with a schema. The next two lectures build on this. 6.6 covers tool_choice — which controls whether Claude can skip the tool call, which matters a lot for guaranteed output. 6.7 covers schema design patterns that prevent the model from fabricating values to fill required fields. This lecture is the base. Those lectures are the superstructure.
-->

---

<ClosingSlide nextLecture="6.6 — tool_choice for Guaranteed Structured Output" />

<!--
Carry this forward: tool_use with a strict JSON schema is the most reliable structured-output mechanism Claude offers — zero syntax errors, schema validation by construction. But schema-valid is not correct; semantic errors still exist. Next lecture, 6.6, we cover tool_choice — auto, any, and forced — and why "auto" is the trap that lets the model skip your tool call entirely. See you there.
-->
