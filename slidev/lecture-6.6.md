---
theme: default
title: "Lecture 6.6: tool_choice — Guaranteed Structured Output"
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
const modesRows = [
  {
    label: 'auto',
    cells: [
      { text: 'Nothing — model may return text', highlight: 'bad' },
    ],
  },
  {
    label: 'any',
    cells: [
      { text: 'Some tool WILL be called', highlight: 'good' },
    ],
  },
  {
    label: '{type: "tool", name: X}',
    cells: [
      { text: 'THIS specific tool WILL be called', highlight: 'good' },
    ],
  },
]

const multiSchemaCode = `tools = [extract_invoice, extract_contract, extract_medical_record]

response = client.messages.create(
    model="claude-opus-4-7",
    tools=tools,
    tool_choice={"type": "any"},   # structured output guaranteed
    messages=[{"role": "user", "content": [doc_block]}]
)
# Claude sees the doc, picks the right schema,
# and ALWAYS returns a tool_use block.`

const forcedCode = `# Step 1: force metadata extraction first
tool_choice = {"type": "tool", "name": "extract_metadata"}

# Step 2 (next request): force enrichment
tool_choice = {"type": "tool", "name": "extract_enrichment"}

# tool_choice is a workflow-ordering primitive here.`
</script>

<CoverSlide
  title="tool_choice — Guaranteed Structured Output"
  subtitle="auto lets the model return text. any and forced do not. Know the difference."
  eyebrow="Domain 4 · Lecture 6.6"
  :stats="['Section 6', 'Scenario 6', 'Domain 4 · 20%', '7 min']"
/>

<!--
If you saw Section 4, lecture 4.9, tool_choice is a parameter you've already met. Here we're reusing it — same three modes, different angle. There, we used tool_choice to control tool selection. Here, we're using it to guarantee structured output. Two sides of the same parameter, both testable on the exam. This lecture takes eight minutes, closes with a single decision rule, and flags the one trap that catches people who skim: tool_choice: auto is not a structured-output guarantee.
-->

---

<ComparisonTable
  eyebrow="The three modes"
  title="tool_choice — what each mode guarantees"
  :columns="['Guarantees']"
  :rows="modesRows"
/>

<!--
Three modes. Auto — the default — guarantees nothing. The model may return free-form text instead of calling a tool. Any — the model must call a tool, but picks which one from your tool list. Forced — specified as `{"type": "tool", "name": "extract_invoice"}` — the model must call that specific tool by name. Read those again. Auto: no guarantee. Any: some tool will be called. Forced: this tool will be called. That's the entire API surface for this parameter, and the exam tests all three.
-->

---

<CodeBlockSlide
  eyebrow="any — multi-schema extraction"
  title='tool_choice: &ldquo;any&rdquo; with three schemas'
  lang="python"
  :code="multiSchemaCode"
  annotation="Without any, the model could return prose like 'this looks like a contract' and skip the tool call. With any, structured output is guaranteed on every request."
/>

<!--
Here's the pattern where `any` shines. You're processing documents of unknown type — invoices, contracts, and medical records all arrive in the same pipeline. You define three tools: extract_invoice, extract_contract, extract_medical_record. You set tool_choice to any. Claude sees the document, picks the right schema, and always returns structured output. Without `any`, the model could return prose like "this looks like a contract" and skip the tool call. With `any`, structured output is guaranteed on every request.
-->

---

<CodeBlockSlide
  eyebrow="Forced — ordering by name"
  title="Pipeline sequencing via tool_choice"
  lang="python"
  :code="forcedCode"
  annotation="Step one guaranteed first, step two guaranteed second. tool_choice as a workflow-ordering primitive."
/>

<!--
The forced mode is for pipeline ordering. Say your flow is: extract metadata first, then enrich the record. You set tool_choice to `{"type": "tool", "name": "extract_metadata"}` on the first call. Claude must call extract_metadata, not any other tool. Then on the next request, you switch to extract_enrichment. This lets you orchestrate a fixed sequence of structured extractions — step one guaranteed first, step two guaranteed second. You're using tool_choice as a workflow-ordering primitive.
-->

---

<ConceptHero
  leadLine="The whole decision tree in one sentence."
  concept="Never auto for structured output"
  supportLine="Need structured output? Never auto. Know which tool you want? Force it. Don't know which? Use any. Three lines; catches most exam questions on tool_choice in under five seconds."
/>

<!--
Here's the whole decision tree in one sentence. Need structured output? Never auto. Know which tool you want? Force it. Don't know which? Use any. That's it. Three lines, catches most exam questions on tool_choice. The mental move is: structured output and auto are incompatible by design. Every time you see auto in the context of "guaranteed structure," that's the distractor. Simple rule, catches most exam questions on tool_choice in under five seconds of scanning the options.
-->

---

<CalloutBox variant="warn" title="The auto trap">
  <p>Distractors will say something like <em>&ldquo;use tool_choice: auto with a well-named tool and clear description — the model will naturally pick the tool.&rdquo;</em> Nope.</p>
  <p>Auto still allows the model to return text. A well-named tool makes the model <em>more likely</em> to call it. &ldquo;More likely&rdquo; is not &ldquo;guaranteed.&rdquo;</p>
  <p>If the question asks for guarantees, <strong>auto is always wrong</strong>. Almost-right is the trap — auto is plausible for general agentic work, fails for structured-output guarantees.</p>
</CalloutBox>

<!--
Here's the trap. Distractors will say something like "use tool_choice: auto with a well-named tool and clear description — the model will naturally pick the tool." Nope. Auto still allows the model to return text. A well-named tool makes the model more likely to call it, but "more likely" is not "guaranteed." If the question asks for guarantees, auto is always wrong. Almost-right is the trap: the auto answer sounds reasonable in a different context — like general agentic work — but for structured output guarantees, it fails.
-->

---

<CalloutBox variant="tip" title="Scenario 6 — batch-processing varied docs">
  <p>Multiple schemas + <code>tool_choice: any</code> = Claude picks the right schema per document and <strong>always</strong> returns structured output. No &ldquo;this document is ambiguous, here's some prose&rdquo; escape hatches.</p>
  <p>Revisited in <strong>6.11</strong>: batch + guaranteed structure is how you run a thousand-document extraction overnight and wake up to clean data.</p>
  <p>The architecture: <strong>tool_use + schema</strong> (reliability) · <strong>tool_choice: any</strong> (guarantee) · <strong>batch API</strong> (cost). Three primitives composed into one production pipeline.</p>
</CalloutBox>

<!--
Scenario 6 uses this pattern heavily. Batch-processing a queue of varied documents — multiple schemas plus tool_choice any — means Claude picks the right schema per document and always returns structured output. No "this document is ambiguous, here's some prose" escape hatches. We come back to this in 6.11 when we cover the Message Batches API, because batch plus guaranteed structure is how you run a thousand-document extraction job overnight and wake up to clean data. The combination is the architecture: tool_use + schema for reliability, tool_choice: any for guarantee, batch API for cost. Three primitives composed into one production pipeline.
-->

---

<CalloutBox variant="tip" title="Callback to 4.9 — same param, different angle">
  <p>In <strong>Section 4.9</strong> we used <code>tool_choice</code> to control which tool Claude selects among many — a <em>selection</em> primitive.</p>
  <p>Here we're using the same parameter for <em>structured output</em> guarantees — a format primitive.</p>
  <p>If the stem says <em>&ldquo;the model returned text when I needed a tool call,&rdquo;</em> the answer is <code>tool_choice: any</code> or forced. If it says <em>&ldquo;the model picked the wrong tool,&rdquo;</em> re-read 4.9.</p>
</CalloutBox>

<!--
Callback to 4.9 for anyone who took Section 4 recently. Same three modes of tool_choice, different angle. In 4.9 we talked about tool_choice for controlling which tool Claude selects among many — a selection primitive. Here we're using the same parameter for structured output guarantees — a format primitive. The exam can test either angle. If the stem talks about "the model returned text when I needed a tool call," the answer is tool_choice: any or forced. If it talks about "the model picked the wrong tool," re-read 4.9.
-->

---

<ClosingSlide nextLecture="6.7 — Schema Design: Required, Optional, Nullable, Enum + 'other'" />

<!--
Carry this forward: auto guarantees nothing, any guarantees some tool runs, forced guarantees a specific tool runs. For structured output, never auto. Next lecture, 6.7, we design the schemas themselves — required vs optional, nullable patterns, enum with "other," and the "unclear" value that gives ambiguity a home so the model stops inventing to fill required fields. See you there.
-->
