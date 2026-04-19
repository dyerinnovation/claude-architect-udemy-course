---
theme: default
title: "Lecture 2.7: Structured Output via the API"
info: |
  Claude Certified Architect – Foundations
  Section 2: Claude API Fundamentals Bootcamp
highlighter: shiki
transition: fade-out
mdc: true
---

<style>
@import './style.css';
</style>

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 1 — TITLE
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-cover-accent"></div>

<div style="height: 100%; display: flex; flex-direction: column; justify-content: center; align-items: center; text-align: center;">
  <div class="di-course-label">Section 2 · Claude API Fundamentals Bootcamp</div>
  <div class="di-cover-title">Structured Output<br>via the API</div>
  <div class="di-cover-subtitle">Lecture 2.7 · Claude Certified Architect – Foundations</div>
</div>

<img src="/logo.png" class="di-logo-centered" />

<!--
Imagine you've built a pipeline that extracts structured data from documents.

It works great — until one response comes back with a trailing comma and your JSON parser throws an exception.

You can't write a retry loop that catches every edge case. You need a guarantee.

This lecture is about three approaches to structured output — and which one actually gives you that guarantee.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 2 — When JSON From Claude Breaks Your Pipeline
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">When JSON From Claude Breaks Your Pipeline</div>

<div style="display: flex; align-items: stretch; gap: 1rem; margin-top: 0.75rem;">

  <v-click>
  <div style="flex: 1; background: white; border-left: 4px solid #E53E3E; border-radius: 6px; padding: 0.7rem 0.9rem; font-family: 'Courier New', monospace; font-size: 0.82rem; color: #1A3A4A;">
    {<br>
    &nbsp;&nbsp;"order_id": "A123",<br>
    &nbsp;&nbsp;"customer": "Jane",<br>
    &nbsp;&nbsp;"total": 49.99,<span style="color: #E53E3E; font-weight: 700;"> ←</span>
  </div>
  </v-click>

  <div class="di-arrow" style="align-self: center; font-size: 1.5rem;">→</div>

  <v-click>
  <div style="flex: 1; background: #FFF0F0; border: 2px solid #E53E3E; border-radius: 6px; padding: 0.7rem 0.9rem; color: #7a2020;">
    <div style="font-weight: 700; font-size: 0.95rem;">❌ JSONDecodeError</div>
    <div style="font-size: 0.82rem; margin-top: 0.3rem; font-family: 'Courier New', monospace;">Expecting property name enclosed in double quotes: line 5 column 1</div>
    <div style="font-size: 0.82rem; margin-top: 0.4rem;">One malformed response. One crashed pipeline.</div>
  </div>
  </v-click>

</div>

<v-click>
<div style="margin-top: 1rem; font-size: 1rem; color: #1A3A4A; text-align: center;">
  You can't write a retry loop for every edge case. <strong>You need a guarantee.</strong>
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Imagine you've built a pipeline that extracts structured data from documents.

It works great — until one response comes back with a trailing comma and your JSON parser throws an exception.

You can't write a retry loop that catches every edge case. You need a guarantee.

This lecture is about three approaches to structured output — and which one actually gives you that guarantee.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 3 — Three Approaches, One Winner
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Three Approaches, One Winner</div>

<div style="display: flex; align-items: flex-end; justify-content: center; gap: 0.8rem; margin-top: 1rem;">

  <!-- 3rd place -->
  <v-click>
  <div style="flex: 1; text-align: center;">
    <div style="background: #c89a6a; color: white; padding: 0.6rem; border-radius: 6px 6px 0 0; font-weight: 700; font-size: 0.85rem;">3rd</div>
    <div style="background: white; border: 1px solid #c89a6a; padding: 0.7rem 0.5rem; min-height: 70px;">
      <strong style="font-size: 0.9rem;">System Prompt + JSON Mode</strong>
      <div style="font-size: 0.78rem; color: #666; margin-top: 0.3rem;">Usually works. Not a guarantee.</div>
    </div>
  </div>
  </v-click>

  <!-- 1st place -->
  <v-click>
  <div style="flex: 1; text-align: center;">
    <div style="background: #E3A008; color: white; padding: 0.9rem; border-radius: 6px 6px 0 0; font-weight: 800; font-size: 1rem;">🏆 1st</div>
    <div style="background: white; border: 2px solid #E3A008; padding: 0.9rem 0.5rem; min-height: 110px;">
      <strong style="font-size: 0.95rem; color: #1A3A4A;">Tool Use + JSON Schema</strong>
      <div style="font-size: 0.8rem; color: #1B8A5A; margin-top: 0.4rem; font-weight: 600;">Most reliable. Schema enforced. Exam's preferred answer.</div>
    </div>
  </div>
  </v-click>

  <!-- 2nd place -->
  <v-click>
  <div style="flex: 1; text-align: center;">
    <div style="background: #9ca3af; color: white; padding: 0.75rem; border-radius: 6px 6px 0 0; font-weight: 700; font-size: 0.9rem;">2nd</div>
    <div style="background: white; border: 1px solid #9ca3af; padding: 0.75rem 0.5rem; min-height: 90px;">
      <strong style="font-size: 0.9rem;"><code>response_format</code></strong>
      <div style="font-size: 0.78rem; color: #666; margin-top: 0.3rem;">Valid JSON syntax, no schema check.</div>
    </div>
  </div>
  </v-click>

</div>

<v-click>
<div style="margin-top: 0.9rem; font-size: 0.95rem; color: #1A3A4A; text-align: center;">
  Three ways. <strong>Meaningfully different reliability profiles.</strong> Only one gives you a guarantee.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
There are three ways to get structured JSON out of Claude. They're not equivalent — they have meaningfully different reliability profiles.

Third place: telling Claude in your system prompt to respond in JSON. It usually works. But "usually" is not a guarantee.

Second place: using the response_format parameter set to json_object. This ensures Claude outputs valid JSON syntax, but doesn't enforce your specific schema.

First place: using tool use with a JSON schema. This is the most reliable approach, and it's the one the exam expects you to reach for when schema compliance is critical.

We'll cover all three — starting from the top.
-->

---
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 4 — The Gold Standard: Tool Use for Structured Output
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">Gold Standard: Tool Use for Structured Output</div>

<v-click>

```python {all|5-17|22|26|all}
import anthropic

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
    model="claude-opus-4-5",
    max_tokens=1024,
    tools=[extraction_tool],
    tool_choice={"type": "any"},   # Force Claude to call a tool
    messages=[{"role": "user", "content": "Order #A123, Jane Smith, $49.99, shipped."}]
)

order_data = response.content[0].input   # Already a validated dict
```

</v-click>

<v-click>
<div style="display: flex; gap: 1rem; margin-top: 0.5rem; font-size: 0.82rem; color: #1A3A4A;">
  <div style="flex: 1; background: white; border-radius: 4px; padding: 0.4rem 0.6rem; border-left: 2px solid #E3A008;">
    <strong style="color: #E3A008;">tool_choice: "any"</strong> forces a tool call — no plain text allowed
  </div>
  <div style="flex: 1; background: white; border-radius: 4px; padding: 0.4rem 0.6rem; border-left: 2px solid #3CAF50;">
    <strong style="color: #1B8A5A;">SDK validates</strong> output against your schema before returning
  </div>
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
The key insight: you're defining a tool purely to receive structured output.

Claude isn't actually calling an external function — you're using the tool-calling mechanism as a schema enforcement layer.

tool_choice type "any" is critical here. It forces Claude to call one of your tools — it cannot respond with plain text.

The SDK validates the output against your schema before returning. This is why you get a guarantee: malformed JSON never reaches your application code.
-->

---
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 5 — Reading the Tool Use Response
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">Reading the Tool Use Response</div>

<v-click>

```python {all|4|7|13-15|all}
# After the create() call from the previous slide...

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
print(structured_data["status"])      # "shipped"
```

</v-click>

<v-click>
<div style="display: flex; gap: 1rem; margin-top: 0.5rem; font-size: 0.85rem;">
  <div style="flex: 1; background: white; border-radius: 4px; padding: 0.5rem 0.7rem; border-left: 3px solid #E3A008;">
    <strong style="color: #E3A008;">stop_reason</strong> is <strong>always <code>"tool_use"</code></strong> when a tool was called — common exam question
  </div>
  <div style="flex: 1; background: white; border-radius: 4px; padding: 0.5rem 0.7rem; border-left: 3px solid #3CAF50;">
    <strong style="color: #1B8A5A;">content[0].input</strong> is already a Python dict — <em>no <code>json.loads()</code></em>
  </div>
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
When a tool is called, stop_reason is always "tool_use" — not "end_turn". This is a common exam question. Know it.

Notice that content[0].input is already a Python dict — the SDK parsed it for you. You're not doing json.loads() on a string. You get a native object.
-->

---
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 6 — The Silver Medal: response_format & System Prompt JSON
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">Silver Medal: <code>response_format</code> & System Prompt JSON</div>

<v-click>

```python
# APPROACH 2: response_format parameter — valid JSON, but no schema check
response = client.messages.create(
    model="claude-opus-4-5",
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
    model="claude-opus-4-5", max_tokens=1024, system=system,
    messages=[{"role": "user", "content": "Order #C789, Sara Kim, $99.50, delivered."}]
)
# Usually works. But Claude could add a markdown fence or a preamble sentence.
```

</v-click>

<v-click>
<div style="margin-top: 0.5rem; background: #FFF0F0; border-left: 4px solid #E53E3E; border-radius: 4px; padding: 0.55rem 0.9rem; font-size: 0.88rem; color: #7a2020;">
  <strong>⚠ Neither approach enforces your schema.</strong> Shape is Claude's best effort — you still need application-level validation after parsing.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
System prompt JSON mode is fine for quick extractions in low-stakes pipelines.

The risk: Claude might wrap the JSON in a markdown code block, or add a sentence before it.

The response_format approach is cleaner but still doesn't validate against your specific schema. You'll need to validate the shape yourself after parsing.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 7 — What Tool Use Guarantees — And What It Doesn't
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">What Tool Use Guarantees — And What It Doesn't</div>

<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1.2rem; margin-top: 0.5rem;">

  <v-click>
  <div>
    <div class="di-col-left-label">✓ Tool Use GUARANTEES</div>
    <div class="di-col-body">
      <ul>
        <li>Syntactically valid JSON</li>
        <li>Schema-conformant field names</li>
        <li>Correct data types per schema</li>
        <li>No parse errors</li>
      </ul>
    </div>
  </div>
  </v-click>

  <v-click>
  <div>
    <div class="di-col-right-label" style="color: #E53E3E; border-color: #E53E3E;">✗ Tool Use Does NOT Guarantee</div>
    <div class="di-col-body">
      <ul>
        <li>Factually correct values</li>
        <li>Data that actually exists in the source</li>
        <li>Freedom from hallucination</li>
        <li>Semantic accuracy</li>
      </ul>
    </div>
  </div>
  </v-click>

</div>

<v-click>
<div style="margin-top: 0.9rem; background: white; border: 1px solid #c8e6d0; border-left: 4px solid #0D7377; border-radius: 6px; padding: 0.75rem 1rem; font-size: 0.95rem; color: #111928;">
  <strong style="color: #0D7377;">Mental model:</strong> Tool use is a <em>syntax and structure</em> guarantee, not a <em>truth</em> guarantee. For critical pipelines you still need application-level validation of the <strong>values</strong>.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
This is the most important distinction in this lecture — and the exam tests it directly.

Tool use eliminates syntax errors. The JSON will be valid. The fields will match your schema. The types will be correct.

But tool use cannot prevent semantic errors. If you ask Claude to extract an order ID that doesn't exist in the document, it might hallucinate one. The hallucinated order ID will be a perfectly valid string in the right field. Schema enforcement is not fact enforcement.

The mental model: tool use is a syntax and structure guarantee, not a truth guarantee. For critical pipelines, you still need application-level validation of the values.
-->

---
layout: default
class: di-exam-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 8 — Exam Tip
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-exam-banner">⚡ EXAM TIP</div>

<v-click>
<div class="di-exam-subtitle">Schema Conformance ≠ Semantic Correctness</div>

<div class="di-exam-body">
  The exam tests this distinction specifically — don't conflate a structural guarantee with a truth guarantee.
</div>
</v-click>

<v-click>
<div class="di-trap-box">
  <div class="di-trap-label">❌ Trap</div>
  Choosing tool use because you believe it eliminates <em>all</em> errors in the output — including wrong values or hallucinated data.
</div>
</v-click>

<v-click>
<div class="di-correct-box">
  <div class="di-correct-label">✓ Correct Approach</div>
  Tool use with <code class="di-code-inline">tool_choice: "any"</code> guarantees syntactically valid, schema-conformant JSON — it eliminates parse errors and field-shape errors. It does <strong>not</strong> guarantee values are correct or that Claude hasn't hallucinated. Also: <code class="di-code-inline">stop_reason</code> is <code>"tool_use"</code> (not <code>"end_turn"</code>) whenever a tool is called.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Tool use with tool_choice "any" guarantees syntactically valid, schema-conformant JSON — it eliminates parse errors and field-shape errors. It does not guarantee that the values are correct or that Claude hasn't hallucinated data.

When an exam question asks "What does using tool_use for structured output guarantee?" — the answer is schema conformance, not factual accuracy.

Also remember: stop_reason will be "tool_use" (not "end_turn") whenever Claude calls a tool.
-->

---
layout: default
class: di-takeaway-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 9 — Key Takeaways
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-takeaway-title">What to Remember</div>

<ul class="di-takeaway-list">
  <v-click><li>Reliability ranking: <strong>tool use + JSON schema</strong> &gt; <code>response_format</code> &gt; system prompt instruction</li></v-click>
  <v-click><li>Use <code style="color: #3CAF50;">tool_choice={"type": "any"}</code> to force a tool call — prevents plain-text responses</li></v-click>
  <v-click><li><code style="color: #3CAF50;">stop_reason</code> is <code>"tool_use"</code> when a tool is called; data lives in <code>response.content[0].input</code> as a parsed dict</li></v-click>
  <v-click><li>Tool use guarantees <strong>syntactic</strong> and <strong>structural</strong> validity — <em>not</em> factually correct or hallucination-free values</li></v-click>
</ul>

<img src="/logo.png" class="di-logo" style="opacity: 0.75;" />

<!--
Four things to remember:

Three approaches ranked by reliability: tool use with JSON schema is most reliable, followed by the response_format parameter, followed by a system prompt instruction.

Use tool_choice type "any" to force Claude to call a tool. This prevents plain text responses.

stop_reason is "tool_use" when a tool is called, and structured data lives in response.content[0].input as a parsed dict.

Tool use guarantees syntactic and structural validity. It does not guarantee factually correct or hallucination-free values.
-->
