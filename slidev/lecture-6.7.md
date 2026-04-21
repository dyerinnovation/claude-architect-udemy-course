---
theme: default
title: "Lecture 6.7: Schema Design for Honest Output"
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
const nullableCode = `{
  "customer_email": {
    "type": ["string", "null"]
  }
}

# Absent data → the model returns JSON null.
# Without the "null" alternative, the model would
# fabricate a string-shaped value.`

const enumOtherCode = `{
  "doc_category": {
    "enum": ["invoice", "contract", "receipt", "other"]
  },
  "other_detail": {
    "type": "string"
  }
}

# Statement of work? category = "other",
# other_detail = "statement of work".
# Taxonomy extended without a schema change.`

const fullSchemaCode = `{
  "type": "object",
  "required": ["invoice_number", "total_amount"],
  "properties": {
    "invoice_number":  {"type": "string"},
    "total_amount":    {"type": "number"},
    "customer_email":  {"type": ["string", "null"]},
    "doc_category": {
      "enum": ["invoice", "contract", "receipt", "other"]
    },
    "other_detail":    {"type": "string"},
    "sentiment": {
      "enum": ["positive", "negative", "neutral", "unclear"]
    }
  }
}`
</script>

<CoverSlide
  title="Schema Design for Honest Output"
  subtitle="Required, optional, nullable, enum + &lsquo;other&rsquo;, &lsquo;unclear.&rsquo; Give the model an honest way out."
  eyebrow="Domain 4 · Lecture 6.7"
  :stats="['Section 6', 'Scenario 6', 'Domain 4 · 20%', '9 min']"
/>

<!--
This lecture is the longest in Domain 4 because it has the most patterns to memorize — and because every distractor you see on Scenario 6 is a schema that forces the model to invent. Nine minutes, five schema patterns: required, optional, nullable, enum with "other," and the "unclear" enum value. If you nail these five patterns, you'll recognize the right answer on every Scenario 6 schema question.
-->

---

<BigQuote
  lead="Domain 4 · Lecture 6.7"
  quote="Required fields + absent data = the model invents a value to satisfy the schema."
  attribution="The fabrication problem, named"
/>

<!--
Here's the thesis, stated as a single line. Required fields plus absent data equals the model inventing a value to satisfy the schema. That's the fabrication problem. You marked customer_email as required. The document doesn't have an email. The model has no escape — the schema demands a string — so it fabricates one. "customer@example.com." Your downstream system ingests the fake email. The failure is silent and downstream. This is the most important sentence in the lecture: schema design is about giving the model an honest way out when the data isn't there.
-->

---

<ConceptHero
  leadLine="If the document might not have the field, mark it optional."
  concept="Required means required"
  supportLine="Only mark required when you can guarantee presence in the source. Over-marking required is the #1 schema bug — it forces fabrication."
/>

<!--
Required means required. If the document might not have the field, mark it optional. If you force it, you force fabrication. The mental move is: only mark a field required when you can guarantee its presence in the source. Invoice_number on an invoice — probably safe. Customer_email on an arbitrary contract — never safe, because contracts often omit it. Most first-time schema designers over-mark required, and then they wonder why the model is inventing fields. The fix is optional.
-->

---

<CodeBlockSlide
  eyebrow="Nullable pattern"
  title='type: ["string", "null"] — the honest way out'
  lang="json"
  :code="nullableCode"
  annotation="If you forget the 'null' alternative, the model has to produce something string-shaped — and something string-shaped is a lie."
/>

<!--
Here's the JSON Schema pattern for nullable. You write the type as an array: `{"type": ["string", "null"]}`. That tells the model: this field can be a string, or it can be explicit null. Now when the data is absent, the model returns null — not a fabricated string, not an empty string, but the explicit JSON null. Your downstream code branches on null cleanly. If you forget the "null" alternative, the model has to produce something string-shaped, and something string-shaped is a lie.
-->

---

<CodeBlockSlide
  eyebrow="Enum with &ldquo;other&rdquo;"
  title="Extensible enum — handle the unanticipated"
  lang="json"
  :code="enumOtherCode"
  annotation="You extended the taxonomy without a schema change. No inventing new enum values, no jamming SOWs into 'invoice.'"
/>

<!--
The extensible-enum pattern. Your schema has a category field: `{"enum": ["invoice", "contract", "receipt", "other"], ...}` — note the "other" value — plus a second field, `other_detail: {"type": "string"}`. When the document is a category you didn't anticipate — say, a statement of work — the model outputs category "other" and other_detail "statement of work." You extended the taxonomy without a schema change. This is how you handle open-ended categorization without the model inventing new enum values or jamming SOW into "invoice."
-->

---

<CalloutBox variant="tip" title="Enum + &ldquo;unclear&rdquo; — give ambiguity a home">
  <p>Add <code>&quot;unclear&quot;</code> as a valid enum value.</p>
  <p>When the document is genuinely ambiguous — sentiment could be neutral or slightly negative — the model reaches for <code>unclear</code> instead of picking wrong.</p>
  <p>Exam guide phrasing (Task 4.3): <em>&ldquo;adding enum values like &lsquo;unclear&rsquo; for ambiguous cases.&rdquo;</em> One line of schema that prevents a whole class of wrong answers.</p>
</CalloutBox>

<!--
A close cousin. Add "unclear" as a valid enum value. If the document is genuinely ambiguous — the sentiment could be neutral or slightly negative — the model reaches for "unclear" instead of picking wrong. This is the exam guide's exact phrasing under Task 4.3: "adding enum values like 'unclear' for ambiguous cases." Without "unclear," the model has to pick one of your categories — and it picks confidently, even when the data doesn't support confidence. Adding "unclear" to your enum is one line of schema that prevents a whole class of wrong answers.
-->

---

<CodeBlockSlide
  eyebrow="All patterns combined"
  title="A full extraction schema using every pattern"
  lang="json"
  :code="fullSchemaCode"
  annotation="Every Scenario 6 correct answer looks something like this. Study the shape."
/>

<!--
Here's the combined pattern in a schema. invoice_number required string. total_amount required number. customer_email type `["string", "null"]` — nullable. doc_category enum including "other." other_detail optional string. sentiment enum of positive, negative, neutral, unclear. That one schema uses every pattern we just covered. Study the shape. Every Scenario 6 correct answer looks something like this.
-->

---

<CalloutBox variant="tip" title="Format normalization — in the prompt, not the schema">
  <p>Mixed date formats in the source — <code>&quot;Jan 3, 2025&quot;</code>, <code>&quot;2025-01-03&quot;</code>, <code>&quot;3/1/25&quot;</code>?</p>
  <p>Don't enforce format in the JSON schema. Normalize in the <strong>prompt instructions</strong> alongside the strict schema.</p>
  <ul>
    <li><strong>Prompt:</strong> &ldquo;Return all dates in ISO-8601 format.&rdquo;</li>
    <li><strong>Schema:</strong> <code>{"type": "string"}</code></li>
  </ul>
  <p>Schema constrains type and shape. Prompt handles normalization. Don't cross the streams.</p>
</CalloutBox>

<!--
One more pattern that catches people. When the source document has mixed date formats — "Jan 3, 2025" and "2025-01-03" and "3/1/25" — you don't enforce the format in the JSON schema. You normalize in the prompt instructions alongside the strict schema. Prompt: "Return all dates in ISO-8601 format." Schema: `{"type": "string"}`. The schema constrains type and shape. The prompt handles normalization. Don't cross the streams.
-->

---

<CalloutBox variant="tip" title="On the exam — two exact mappings">
  <p><strong>&ldquo;The model fabricates values for fields not present in the source&rdquo;</strong> → make those fields nullable or optional.</p>
  <p><strong>&ldquo;The source documents contain categories not anticipated in the schema&rdquo;</strong> → enum + &ldquo;other&rdquo; + detail string.</p>
  <p>Almost-right traps will offer <em>&ldquo;use a more capable model&rdquo;</em> or <em>&ldquo;increase temperature.&rdquo;</em> Both wrong. The fix is schema design.</p>
</CalloutBox>

<!--
On the exam, two exact phrasings show up. One: "the model fabricates values for fields not present in the source." The correct answer is making those fields nullable or optional. Two: "the source documents contain categories not anticipated in the schema." The correct answer is enum plus "other" plus a detail string. Memorize both mappings. Almost-right traps will offer "use a more capable model" or "increase temperature" — both wrong. The fix is schema design.
-->

---

<CalloutBox variant="tip" title="Scenario 6 lives on these patterns">
  <p>Every distractor in Scenario 6 schema questions is a schema that forces the model to invent — a required field where data is absent, an enum without &ldquo;other,&rdquo; a type without null.</p>
  <p>The correct answer is always the schema that gives the model <strong>an honest way out</strong>. Remember the six-pick-four — you don't know whether Scenario 6 shows up, so prepare as if it will.</p>
</CalloutBox>

<!--
Scenario 6 lives on these patterns. Every distractor in Scenario 6 schema questions is a schema that forces the model to invent — a required field where the data is absent, an enum without "other," a type without null. The correct answer is always the schema that gives the model an honest way out. Remember the six-pick-four — you don't know whether Scenario 6 shows up, so you prepare as if it will.
-->

---

<ClosingSlide nextLecture="6.8 — Syntax Errors vs Semantic Errors" />

<!--
Carry this forward: mark optional when the data might be absent, make types nullable when absence is real, use enum plus "other" for extensible categories, add "unclear" to give ambiguity a home, and normalize formats in the prompt — not the schema. Next lecture, 6.8, we hit the other limit of tool_use: semantic errors. Schema-valid does not mean correct. That distinction is testable, and it's the setup for the validation-retry loops in 6.9. See you there.
-->
