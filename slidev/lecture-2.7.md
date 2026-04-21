---
theme: default
title: "Lecture 2.7: Structured Output via the API"
info: |
  Claude Certified Architect – Foundations
  Section 2: Claude API Fundamentals Bootcamp (Domain 2 · 18%)
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
const ranking = [
  { label: '🏆 1st — Tool Use + JSON Schema', detail: 'Most reliable · schema enforced · exam\'s preferred answer' },
  { label: '2nd — response_format', detail: 'Valid JSON syntax · no schema check' },
  { label: '3rd — System Prompt + JSON mode', detail: 'Usually works · not a guarantee' },
]

const takeaways = [
  { label: 'Reliability order', detail: 'Tool use + JSON schema > response_format > system prompt instruction' },
  { label: "Force with tool_choice", detail: "tool_choice={'type':'any'} prevents plain text — Claude MUST call a tool" },
  { label: 'stop_reason = tool_use', detail: "When a tool is called; data arrives as parsed dict at response.content[0].input" },
  { label: 'Syntax, not truth', detail: 'Tool use guarantees syntactic/structural validity — NOT factually correct values' },
]

const badJsonCode = `{
  "order_id": "A123",
  "customer": "Jane",
  "total": 49.99,  ← trailing comma
}`

const goldCode = `import anthropic

client = anthropic.Anthropic()

# Define your schema as a "fake" tool — Claude must call this
extraction_tool = {
    "name": "extract_order",
    "description": "Extract structured order data from the user message.",
    "input_schema": {
        "type": "object",
        "properties": {
            "order_id": {"type": "string"},
            "customer_name": {"type": "string"},
            "total_amount": {"type": "number"},
            "status": {"type": "string", "enum": ["pending", "shipped", "delivered"]}
        },
        "required": ["order_id", "customer_name", "total_amount", "status"]
    }
}

response = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=1024,
    tools=[extraction_tool],
    tool_choice={"type": "any"},   # Force Claude to call a tool
    messages=[{"role": "user", "content": "Order #A123, Jane Smith, $49.99, shipped."}]
)

order_data = response.content[0].input   # Already a validated dict`

const readCode = `# After the create() call from the previous slide...

# stop_reason tells you Claude called a tool, not finished naturally
print(response.stop_reason)           # "tool_use"

# The content block type
print(response.content[0].type)       # "tool_use"

# Which tool was called
print(response.content[0].name)       # "extract_order"

# The validated, schema-conformant data
structured_data = response.content[0].input
print(type(structured_data))          # <class 'dict'> — already parsed
print(structured_data["order_id"])    # "A123"
print(structured_data["status"])      # "shipped"`

const silverCode = `# APPROACH 2: response_format parameter — valid JSON, but no schema check
response = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=1024,
    messages=[{
        "role": "user",
        "content": "Extract as JSON: Order #B456, Tom Lee, $29.00, pending."
    }]
)
raw_json = response.content[0].text   # Still a string — you must parse it

# APPROACH 3: System prompt instruction — most flexible, least enforced
system = """You are a data extractor. Always respond with valid JSON matching:
{"order_id": string, "customer_name": string, "total_amount": number, "status": string}
Never include any text outside the JSON object."""

response = client.messages.create(
    model="claude-opus-4-7", max_tokens=1024, system=system,
    messages=[{"role": "user", "content": "Order #C789, Sara Kim, $99.50, delivered."}]
)
# Usually works. But Claude could add a markdown fence or a preamble sentence.`
</script>

---

<!-- SLIDE 1 — Cover -->

<Frame bg="var(--forest-900)" color="var(--mint-100)" :pad="false">
  <div class="lec-cover">
    <div class="lec-cover__brand">
      <img src="/assets/logo-mark.png" alt="" class="lec-cover__logo" />
      <div class="lec-cover__brand-text">Dyer Innovation</div>
    </div>
    <div>
      <div class="lec-cover__section">Section 2 · Lecture 2.7 · Domain 2</div>
      <h1 class="lec-cover__title">Structured Output via the API</h1>
      <div class="lec-cover__subtitle">Three approaches, one winner</div>
    </div>
    <div class="lec-cover__stats">
      <span>API Fundamentals Bootcamp</span>
      <span class="lec-cover__dot">&middot;</span>
      <span>Domain 2 · 18% weight</span>
    </div>
  </div>
</Frame>

<style>
.lec-cover { position: relative; z-index: 1; padding: 110px 120px 96px; width: 100%; height: 100%; display: flex; flex-direction: column; justify-content: space-between; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%); }
.lec-cover__brand { display: flex; align-items: center; gap: 24px; }
.lec-cover__logo { width: 72px; height: auto; }
.lec-cover__brand-text { font-family: var(--font-body); font-size: 26px; font-weight: 500; letter-spacing: 0.14em; text-transform: uppercase; color: var(--mint-200); }
.lec-cover__section { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px; }
.lec-cover__title { font-family: var(--font-display); font-weight: 500; font-size: 112px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1500px; }
.lec-cover__subtitle { font-family: var(--font-display); font-size: 48px; color: var(--mint-200); margin-top: 32px; font-weight: 400; max-width: 1400px; line-height: 1.3; }
.lec-cover__stats { display: flex; align-items: center; gap: 36px; font-family: var(--font-body); font-size: 24px; color: var(--mint-200); letter-spacing: 0.06em; }
.lec-cover__dot { opacity: 0.4; }
.exam-stack { margin-top: 48px; display: flex; flex-direction: column; gap: 28px; flex: 1; min-height: 0; }
</style>

<!--
You need structured data from Claude. A name, an amount, a status — parsed into a clean object your code can consume. You tell Claude "respond in JSON."

Usually it works. But once in a while Claude wraps the JSON in a markdown code block. Or adds a trailing comma that blows up your parser. Or returns "Sure! Here's your JSON:" followed by the object.

One malformed response crashes your pipeline. In production, "usually works" is not good enough.

There's a right way to do this. Let me show you.
-->

---

<!-- SLIDE 2 — Broken pipeline -->

<CodeBlockSlide
  eyebrow="Broken pipeline"
  title="When JSON From Claude Breaks Your Pipeline"
  lang="json"
  :code="badJsonCode"
  annotation="JSONDecodeError: Expecting property name enclosed in double quotes: line 5 column 1. One malformed response. One crashed pipeline. You need a guarantee — not a retry loop."
/>

<!--
Here's what "usually works" looks like in production. One trailing comma. One markdown fence. One friendly preamble. Any of these breaks your JSON parser instantly.

The fix isn't more retry logic. The fix is reaching for an API feature that gives you a structural guarantee — not a best-effort hint.
-->

---

<!-- SLIDE 3 — Ranked by reliability -->

<BulletReveal
  eyebrow="Three approaches"
  title="Ranked by Reliability"
  :bullets="ranking"
/>

<!--
There are three ways to get structured JSON out of Claude. They're not equivalent — they have meaningfully different reliability profiles.

Third place: telling Claude in your system prompt to respond in JSON. It usually works. But "usually" is not a guarantee.

Second place: using the response_format parameter. This ensures Claude outputs valid JSON syntax, but doesn't enforce your specific schema.

First place: using tool use with a JSON schema. This is the most reliable approach, and it's the one the exam expects you to reach for when schema compliance is critical.
-->

---

<!-- SLIDE 4 — Tool use for structured output -->

<CodeBlockSlide
  eyebrow="Gold standard"
  title="Tool Use for Structured Output"
  lang="python"
  :code="goldCode"
  annotation="tool_choice='any' forces a tool call — no plain text · SDK validates against schema before returning."
/>

<!--
The key insight: you're defining a tool purely to receive structured output.

Claude isn't actually calling an external function — you're using the tool-calling mechanism as a schema enforcement layer.

tool_choice type "any" is critical here. It forces Claude to call one of your tools — it cannot respond with plain text.

The SDK validates the output against your schema before returning. This is why you get a guarantee: malformed JSON never reaches your application code.
-->

---

<!-- SLIDE 5 — Reading the response -->

<CodeBlockSlide
  eyebrow="Reading response"
  title="How to Read the Tool-Use Response"
  lang="python"
  :code="readCode"
  annotation="stop_reason is ALWAYS 'tool_use' when a tool was called · content[0].input is already a dict — no json.loads()."
/>

<!--
When a tool is called, stop_reason is always "tool_use" — not "end_turn". This is a common exam question. Know it.

Notice that content[0].input is already a Python dict — the SDK parsed it for you. You're not doing json.loads() on a string. You get a native object.
-->

---

<!-- SLIDE 6 — Silver: response_format & system-prompt JSON -->

<CodeBlockSlide
  eyebrow="Runners-up"
  title="response_format & System-Prompt JSON"
  lang="python"
  :code="silverCode"
  annotation="⚠ Neither enforces your schema. Shape is Claude's best effort. You need application-level validation after parsing."
/>

<!--
System prompt JSON mode is fine for quick extractions in low-stakes pipelines.

The risk: Claude might wrap the JSON in a markdown code block, or add a sentence before it.

The response_format approach is cleaner but still doesn't validate against your specific schema. You'll need to validate the shape yourself after parsing.
-->

---

<!-- SLIDE 7 — What tool use guarantees -->

<TwoColSlide
  variant="compare"
  title="What Tool Use Guarantees — and What It Doesn't"
  leftLabel="✓ Guarantees"
  rightLabel="✗ Does NOT guarantee"
>
  <template #left>
    <ul>
      <li>Syntactically valid JSON</li>
      <li>Schema-conformant field names</li>
      <li>Correct data types per schema</li>
      <li>No parse errors</li>
    </ul>
  </template>
  <template #right>
    <ul>
      <li>Factually correct values</li>
      <li>Data that actually exists in source</li>
      <li>Freedom from hallucination</li>
      <li>Semantic accuracy</li>
    </ul>
    <p style="margin-top: 18px;"><strong>Tool use is a syntax/structure guarantee — not a truth guarantee.</strong> Still validate values.</p>
  </template>
</TwoColSlide>

<!--
This is the most important distinction in this lecture — and the exam tests it directly.

Tool use eliminates syntax errors. The JSON will be valid. The fields will match your schema. The types will be correct.

But tool use cannot prevent semantic errors. If you ask Claude to extract an order ID that doesn't exist in the document, it might hallucinate one. The hallucinated order ID will be a perfectly valid string in the right field. Schema enforcement is not fact enforcement.

The mental model: tool use is a syntax and structure guarantee, not a truth guarantee. For critical pipelines, you still need application-level validation of the values.
-->

---

<!-- SLIDE 8 — Exam Tip -->

<Frame>
  <Eyebrow>⚡ Exam Tip</Eyebrow>
  <SlideTitle>Schema Conformance ≠ Semantic Correctness</SlideTitle>
  <div class="exam-stack">
    <CalloutBox variant="dont" title="Trap">
      <p>Choosing tool use because it eliminates <em>all</em> errors in the output — including wrong values or hallucinated data.</p>
    </CalloutBox>
    <CalloutBox variant="do" title="Correct pattern">
      <p>Tool use + <code>tool_choice:'any'</code> guarantees syntactically valid, schema-conformant JSON. It does NOT guarantee values are correct or hallucination-free. <code>stop_reason</code> is <code>'tool_use'</code> (not <code>'end_turn'</code>) whenever a tool is called.</p>
    </CalloutBox>
  </div>
</Frame>

<!--
The exam tests the distinction between structural guarantee and truth guarantee.

If you choose tool use because "it eliminates all errors" — that's the trap.

Tool use guarantees valid JSON, conformant fields, correct types. It does not guarantee the values are correct or free of hallucination.

And know this cold: when a tool is called, stop_reason is 'tool_use' — never 'end_turn'.
-->

---

<!-- SLIDE 9 — Takeaways -->

<BulletReveal
  eyebrow="Takeaway"
  title="What to Remember"
  :bullets="takeaways"
/>

<!--
Four things to hold onto.

Reliability order: tool use with JSON schema > response_format > system prompt instruction.

Use tool_choice type "any" to force a tool call — prevents plain text.

stop_reason is "tool_use" when a tool is called; data arrives as a parsed dict at response.content[0].input.

Tool use guarantees syntactic and structural validity — not factually correct values. Still validate.
-->
