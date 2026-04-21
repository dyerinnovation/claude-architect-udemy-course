---
theme: default
title: "Lecture 4.9: tool_choice — auto, any, Forced Selection"
info: |
  Claude Certified Architect – Foundations
  Section 4 — Tool Design & MCP Integration (Domain 2, 18%)
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
const mode_columns = ['Guarantees', 'Use when']
const mode_rows = [
  {
    label: 'auto',
    cells: [
      { text: 'Claude decides text or tool', highlight: 'neutral' },
      { text: 'Default; conversational agents', highlight: 'neutral' },
    ],
  },
  {
    label: 'any',
    cells: [
      { text: 'A tool IS called', highlight: 'good' },
      { text: 'Structured output; multiple schemas', highlight: 'good' },
    ],
  },
  {
    label: '{type:"tool",name:X}',
    cells: [
      { text: 'Specific tool X is called', highlight: 'good' },
      { text: 'Force ordering — metadata before enrichment', highlight: 'good' },
    ],
  },
]

const auto_code = `{
  "tool_choice": { "type": "auto" }
}
// Claude may return text.
// Claude may return a tool_use block.
// It decides based on the conversation.`

const any_code = `{
  "tool_choice": { "type": "any" },
  "tools": [extract_invoice, extract_receipt, extract_po]
}
// Claude MUST call a tool.
// Picks the matching schema per document.`

const forced_code = `{
  "tool_choice": { "type": "tool", "name": "extract_metadata" }
}
// Guarantees extract_metadata runs first, every time.
// Subsequent turns can use auto or any.`

const antipattern_bad = `tool_choice: { type: "tool", name: "extract_v1" }

Feed in a receipt: Claude still runs extract_v1 — on a receipt, against an invoice schema. Garbage out.`

const antipattern_fix = `Offer three schemas: extract_invoice, extract_receipt, extract_po.
Set tool_choice: { type: "any" }.
Let Claude pick per doc. Schema-compliant every time.`
</script>

<div class="di-cover">
  <div class="di-cover__inner">
    <div class="di-cover__eyebrow">Domain 2 · Lecture 4.9</div>
    <h1 class="di-cover__title"><span class="di-cover__mono">tool_choice</span> —<br/><span class="di-cover__accent">auto, any, Forced</span></h1>
    <div class="di-cover__subtitle">Three modes. Three guarantees.</div>
  </div>
</div>

<style scoped>
.di-cover { position: absolute; inset: 0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%); color: var(--mint-100); }
.di-cover__inner { padding: 110px 120px 96px; height: 100%; display: flex; flex-direction: column; justify-content: center; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px; }
.di-cover__title { font-family: var(--font-display); font-weight: 500; font-size: 110px; line-height: 1.05; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1600px; }
.di-cover__mono { font-family: var(--font-mono); color: var(--sprout-500); }
.di-cover__accent { color: var(--sprout-500); }
.di-cover__subtitle { font-family: var(--font-display); font-size: 40px; color: var(--mint-200); margin-top: 40px; font-weight: 400; }
</style>

<!--
Three modes. Three guarantees. auto guarantees nothing. any guarantees a tool is called. Forced guarantees a specific tool is called. This lecture is about knowing which guarantee you need, and reaching for the matching mode.
-->

---

<ComparisonTable
  title="tool_choice options"
  :columns="mode_columns"
  :rows="mode_rows"
/>

<!--
Here's the table. Three rows. auto — Claude decides whether to call a tool or return text. That's the default. Use it for conversational agents where sometimes a reply is the right move and sometimes a tool call is. any — a tool is called. Claude picks which one from your set. Use it for structured output or when you're choosing among multiple schemas. Forced — {type: "tool", name: "X"} — specific tool X is called. Use it to force ordering. Those three modes cover every real case.
-->

---

<CodeBlockSlide
  title="auto — the default"
  lang="json"
  :code="auto_code"
  annotation="Conversational agents. Half the turns are text, half are tool calls — Claude decides."
/>

<!--
Mode one. auto. This is what you get if you don't pass tool_choice at all. Claude may return text, Claude may call a tool — it decides based on the conversation and what the user actually needs. Perfect for a conversational agent where half the time the answer is "here's your refund status, processing now" — text — and half the time it's a tool call to look the order up. The trade-off: auto gives you no guarantee of any particular output shape. That matters when you're downstream of structured output, or when your pipeline assumes a tool call on every turn. For those cases, auto is the wrong mode.
-->

---

<CodeBlockSlide
  title="any — guaranteed tool use"
  lang="json"
  :code="any_code"
  annotation="Scenario 6 pattern — extract from varied documents. Claude picks the right schema per doc."
/>

<!--
Mode two. any. The model must call a tool. It picks which one from your set, but it can't skip straight to text. This is the mode you reach for when you need structured output and you have multiple schemas to choose between. Scenario 6 pattern — you're extracting from a hundred documents, and each doc might be an invoice or a receipt or a purchase order. You register three extraction tools, one per schema. Set tool_choice: any. Claude reads the doc, picks the right schema, returns a tool call. Always a tool call. Never conversational text.
-->

---

<CodeBlockSlide
  title="Forced — exact tool"
  lang="json"
  :code="forced_code"
  annotation="Force-first, free after. Metadata runs every time, then auto/any for subsequent enrichment."
/>

<!--
Mode three. Forced. The JSON looks like {"type": "tool", "name": "extract_metadata"}. This guarantees that exact tool runs, every time, on the current turn. Use case: you want extract_metadata to run first on every document, before any enrichment or follow-up calls. Forced selection is how you order operations when the ordering matters. The exam guide calls this out explicitly in Task 2.3 — forcing a specific tool to guarantee ordering, then handling subsequent steps in follow-up turns with auto or any. Force first, free up the model after.
-->

---

<CalloutBox variant="warn" title="Domain 2 + Domain 4 overlap">

Most reliable way to get schema-compliant JSON: define your schema as a tool's input, set <code>tool_choice: any</code>, extract the arguments from the tool-use response.
<br/><br/>
No JSON parsing fragility. No "please output valid JSON" in the prompt. Schema enforcement comes from the tool-use protocol.

</CalloutBox>

<!--
Here's where Domain 2 and Domain 4 shake hands, and the exam tests it. Structured output via tool use. The most reliable way to get schema-compliant JSON from Claude is to define your schema as a tool's input, set tool_choice: any so Claude is forced to call it, and extract the arguments from the tool-use response. No JSON parsing fragility. No "please output valid JSON" in the system prompt. No regex wrangling on malformed output. Schema enforcement comes from the tool-use protocol, not from prompting. Task 4.3 tests this directly — we'll come back to it in Section 6, but the tool_choice: any lever is how Domain 2 contributes to reliable structured output. That's the cleanest way to do it.
-->

---

<CalloutBox variant="tip" title="Scenario 6 pattern — concrete">

Batch-processing 100 varied documents — invoices, receipts, purchase orders.
<br/><br/>
Define <code>extract_invoice</code>, <code>extract_receipt</code>, <code>extract_po</code> — three tools, three JSON schemas. Set <code>tool_choice: any</code>. Claude picks the right extraction tool per doc, always returns a tool call. Structured data every time.

</CalloutBox>

<!--
Concrete. Scenario 6. Batch-processing a hundred varied documents. Mixed types — some invoices, some receipts, some purchase orders. You define extract_invoice, extract_receipt, extract_po — three tools, three JSON schemas. You set tool_choice: any. For each document, Claude picks the right extraction tool per doc and always returns a tool call. You get structured data every time, matched to the doc type, no wasted calls on conversational filler. This is the structured-extraction pattern the exam tests.
-->

---

<AntiPatternSlide
  title="Don't force a specific tool for multi-schema output"
  :badExample="antipattern_bad"
  whyItFails="Force is for ordering a single specific tool. Mismatched schema = garbage."
  :fixExample="antipattern_fix"
  lang="text"
/>

<!--
Anti-pattern. Forcing a specific tool when you want structured output across multiple schemas. If you set tool_choice: {type: "tool", name: "extract_v1"} and feed in a receipt, Claude still runs extract_v1 — on a receipt, against an invoice schema. Garbage out. The right move: offer the three schemas, set any, let Claude pick per doc. Force is for ordering a single specific tool. any is for guaranteeing something gets called when the choice depends on the input. Don't mix them up.
-->

---

<div class="di-close">
  <div class="di-close__inner">
    <div class="di-close__eyebrow">Next up</div>
    <h1 class="di-close__title">4.10 — <span class="di-close__accent">MCP Server Scopes</span></h1>
    <div class="di-close__subtitle">Project vs user. Two locations, two purposes.</div>
  </div>
</div>

<style scoped>
.di-close { position: absolute; inset: 0; background: var(--mint-100); color: var(--forest-800); }
.di-close__inner { padding: 110px 120px 96px; height: 100%; display: flex; flex-direction: column; justify-content: center; }
.di-close__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.14em; text-transform: uppercase; color: var(--teal-500); margin-bottom: 36px; }
.di-close__title { font-family: var(--font-display); font-weight: 500; font-size: 96px; line-height: 1.05; letter-spacing: -0.02em; color: var(--forest-900); margin: 0; max-width: 1600px; }
.di-close__accent { color: var(--sprout-600); }
.di-close__subtitle { font-family: var(--font-display); font-size: 38px; color: var(--forest-500); margin-top: 32px; font-weight: 400; }
</style>

<!--
Next up, Lecture 4.10 — MCP server scoping. Project versus user. Two locations, two purposes. See you there.
-->
