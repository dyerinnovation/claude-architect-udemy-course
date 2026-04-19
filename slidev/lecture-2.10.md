---
theme: default
title: "Lecture 2.10: Tool Use Fundamentals — Your First Function Call"
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
  <div class="di-cover-title">Tool Use Fundamentals:<br><span style="color: #3CAF50;">Your First</span> Function Call</div>
  <div class="di-cover-subtitle">Lecture 2.10 · Connecting Claude's reasoning to real-world actions</div>
</div>

<img src="/logo.png" class="di-logo-centered" />

<!--
Here's a constraint that trips up a lot of architects early on.

Claude is a language model — it reasons and generates text.

It cannot look up today's stock price, query your database, or send an email. Not by itself.

But you can give Claude tools — and Claude will call them when it needs to.

This is how you connect Claude's reasoning to real-world actions and live data.

The mechanism is called tool use, and it is one of the most important API concepts you'll learn in this course.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 2 — Anatomy of a Tool Definition
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Anatomy of a Tool Definition</div>

<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-top: 0.5rem; align-items: start;">

  <v-click>
  <div>

```json
{
  "name": "get_weather",
  "description": "Retrieves current weather for a city.",
  "input_schema": {
    "type": "object",
    "properties": {
      "city": { "type": "string" }
    },
    "required": ["city"]
  }
}
```

  </div>
  </v-click>

  <div style="font-size: 0.9rem; color: #111928; line-height: 1.65; padding-top: 0.25rem;">
    <v-click>
    <div class="di-step-card">
      <span class="di-step-num">name</span> snake_case identifier Claude uses when calling the tool
    </div>
    </v-click>
    <v-click>
    <div class="di-step-card" style="border-left-color: #1B8A5A;">
      <span class="di-step-num" style="color: #1B8A5A;">description</span> Natural-language — <strong>Claude's ability to pick the right tool depends entirely on this</strong>
    </div>
    </v-click>
    <v-click>
    <div class="di-step-card" style="border-left-color: #E3A008;">
      <span class="di-step-num" style="color: #E3A008;">input_schema</span> JSON Schema object — the function signature. Must have <code>type</code>, <code>properties</code>, <code>required</code>
    </div>
    </v-click>
  </div>

</div>

<img src="/logo.png" class="di-logo" />

<!--
Every tool you give Claude has exactly three required fields.

name — a string identifier in snake_case, like "get_weather" or "search_database". This is the name Claude uses when it calls the tool.

description — a natural language explanation of what the tool does and when to use it.

[click] This field is critical. Claude's ability to choose the right tool depends entirely on a good description.

input_schema — a JSON Schema object that defines the tool's parameters. It must have "type": "object", a properties map, and a required array.

Think of input_schema as the function signature — it tells Claude what arguments to provide.
-->

---
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 3 — A Concrete Tool Definition
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">A Concrete Tool Definition</div>

<v-click>

```python {all|2-6|7-21|10-13|17|all}
get_weather_tool = {
    "name": "get_current_weather",
    "description": (
        "Retrieves the current weather for a given city. "
        "Use this when the user asks about current weather conditions."
    ),
    "input_schema": {
        "type": "object",
        "properties": {
            "city": {
                "type": "string",
                "description": "The city name, e.g. 'San Francisco'"
            },
            "unit": {
                "type": "string",
                "enum": ["celsius", "fahrenheit"],
                "description": "Temperature unit to return"
            }
        },
        "required": ["city"]  # unit is optional
    }
}
```

</v-click>

<v-click>
<div style="display: flex; gap: 1rem; margin-top: 0.5rem; font-size: 0.82rem; color: #1A3A4A;">
  <div style="flex: 1; background: white; border-radius: 4px; padding: 0.4rem 0.6rem; border-left: 2px solid #3CAF50;">
    <strong style="color: #1B8A5A;">Per-property description</strong> — Claude reads these too; they guide value choice
  </div>
  <div style="flex: 1; background: white; border-radius: 4px; padding: 0.4rem 0.6rem; border-left: 2px solid #E3A008;">
    <strong style="color: #E3A008;">required[]</strong> — which args Claude must always supply; optional args may be omitted
  </div>
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Let's make this concrete with a real example.

The description inside input_schema.properties is also read by Claude. It helps Claude understand what value to put in each argument.

The required array tells Claude which arguments it must always provide.

Optional fields like unit can be omitted by Claude if they're not relevant.
-->

---
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 4 — Sending the Request with Tools
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">Sending the Request With Tools</div>

<v-click>

```python {all|8|9-14|all}
import anthropic

client = anthropic.Anthropic()

response = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=1024,
    tools=[get_weather_tool],          # Pass your tool definitions here
    messages=[
        {
            "role": "user",
            "content": "What's the weather like in Tokyo right now?"
        }
    ]
)
```

</v-click>

<v-click>
<div style="margin-top: 0.6rem; background: white; border-left: 3px solid #E3A008; border-radius: 4px; padding: 0.6rem 0.9rem; font-size: 0.9rem;">
  If Claude decides to call a tool, <code class="di-code-inline">response.stop_reason == "tool_use"</code>.<br>
  <span style="color: #E3A008; font-weight: 600;">That's your signal.</span> Claude is handing control back to you — it's <em>not</em> done.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
You pass tools to messages.create() using the tools parameter.

Claude evaluates the conversation and decides whether to call a tool.

If it decides to call one, stop_reason in the response will be "tool_use". That's your signal — Claude is handing control back to you.

It's not done. It's waiting for you to execute the tool and return the result.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 5 — Reading the Tool Use Response
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Reading the Tool Use Response</div>

<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-top: 0.5rem; align-items: start;">

  <v-click>
  <div>

```json
{
  "stop_reason": "tool_use",
  "content": [
    {
      "type": "tool_use",
      "id": "toolu_01XFb...",
      "name": "get_current_weather",
      "input": {
        "city": "Tokyo",
        "unit": "celsius"
      }
    }
  ]
}
```

  </div>
  </v-click>

  <div style="font-size: 0.9rem; color: #111928; line-height: 1.65; padding-top: 0.25rem;">
    <v-click>
    <div class="di-step-card">
      <span class="di-step-num">type</span> Always <code class="di-code-inline">"tool_use"</code> — find this block in content
    </div>
    </v-click>
    <v-click>
    <div class="di-step-card" style="border-left-color: #E3A008;">
      <span class="di-step-num" style="color: #E3A008;">id</span> Unique per call — <strong>echo this back</strong> in your result
    </div>
    </v-click>
    <v-click>
    <div class="di-step-card" style="border-left-color: #1B8A5A;">
      <span class="di-step-num" style="color: #1B8A5A;">name</span> Matches the tool you defined
    </div>
    <div class="di-step-card" style="border-left-color: #0D7377;">
      <span class="di-step-num" style="color: #0D7377;">input</span> A ready-to-use dict — call your function directly with it
    </div>
    </v-click>
  </div>

</div>

<img src="/logo.png" class="di-logo" />

<!--
When stop_reason is "tool_use", the response content array contains a tool_use block.

That block has four important fields.

type is always "tool_use" — use this to identify it in the array.

id is a unique identifier like "toolu_01XFb..." — you'll need this to send the result back.

[click] name is the tool name Claude chose — matches what you defined.

input is a Python dict containing the parsed arguments Claude generated. You don't need to parse anything — Claude gives you a ready-to-use dict. Just call your function with those arguments directly.
-->

---
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 6 — Executing the Tool and Returning the Result
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">Execute the Tool — and Return the Result</div>

<v-click>

```python {all|2-4|7|10-26|19-22|all}
# Step 1: find the tool_use block in the response content
tool_use_block = next(
    block for block in response.content if block.type == "tool_use"
)

# Step 2: execute your actual function with Claude's arguments
result = get_current_weather(**tool_use_block.input)

# Step 3: send the result back as a user message with a tool_result block
followup = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=1024,
    tools=[get_weather_tool],
    messages=[
        {"role": "user", "content": "What's the weather like in Tokyo right now?"},
        {"role": "assistant", "content": response.content},   # Include Claude's tool call
        {
            "role": "user",
            "content": [
                {
                    "type": "tool_result",
                    "tool_use_id": tool_use_block.id,  # Must match the tool_use id
                    "content": str(result),            # Your function's return value
                }
            ],
        },
    ],
)
```

</v-click>

<v-click>
<div style="display: flex; gap: 1rem; margin-top: 0.5rem; font-size: 0.82rem; color: #1A3A4A;">
  <div style="flex: 1; background: white; border-radius: 4px; padding: 0.4rem 0.6rem; border-left: 2px solid #3CAF50;">
    <strong style="color: #1B8A5A;">tool_result</strong> goes in a <code>user</code> message — never assistant
  </div>
  <div style="flex: 1; background: white; border-radius: 4px; padding: 0.4rem 0.6rem; border-left: 2px solid #E3A008;">
    <strong style="color: #E3A008;">tool_use_id</strong> links result back to the specific call
  </div>
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Here is the pattern for executing the tool and sending the result back.

The tool_result block goes in a user message — not an assistant message.

The tool_use_id links your result back to the specific tool call Claude made.

Claude reads the result and generates its final natural language response.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 7 — The Request-Response Cycle Visualized
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">The Request-Response Cycle</div>

<div style="display: flex; flex-direction: column; gap: 0.35rem; margin-top: 0.5rem; max-width: 820px; margin-left: auto; margin-right: auto;">

  <v-click>
  <div class="di-flow-box" style="background: #2a4a6a;">
    <strong>1 · You</strong> — user message + tool definitions
  </div>
  <div class="di-arrow">↓</div>
  </v-click>

  <v-click>
  <div class="di-flow-tool">
    <strong>2 · Claude</strong> — returns <code>tool_use</code> block, <code>stop_reason = "tool_use"</code>
  </div>
  <div class="di-arrow">↓</div>
  </v-click>

  <v-click>
  <div class="di-flow-box" style="background: #E3A008;">
    <strong>3 · You</strong> — execute the real function
  </div>
  <div class="di-arrow">↓</div>
  </v-click>

  <v-click>
  <div class="di-flow-box" style="background: #2a4a6a;">
    <strong>4 · You</strong> — send <code>tool_result</code> inside a <code>user</code> message
  </div>
  <div class="di-arrow">↓</div>
  </v-click>

  <v-click>
  <div class="di-flow-stop">
    <strong>5 · Claude</strong> — final response, <code>stop_reason = "end_turn"</code>
  </div>
  </v-click>

</div>

<v-click>
<div style="margin-top: 0.8rem; text-align: center; font-size: 0.95rem; color: #1A3A4A; font-weight: 600;">
  Two-step exchange. Everything in agentic architecture builds on this.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Let's step back and see the full cycle.

You send Claude a message with tool definitions attached.

Claude reasons about whether a tool is needed and generates a tool_use block. It pauses with stop_reason: "tool_use" — your application must take action.

[click] You execute the real function and collect the result.

You send that result back as a tool_result block inside a user message.

Claude reads it, generates the final answer, and returns with stop_reason: "end_turn".

That two-step exchange is the core of the tool use pattern. Everything in agentic architecture builds on this foundation.
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
<div class="di-exam-subtitle">Tool Results Go in a <code style="color: #3CAF50;">user</code> Message</div>

<div class="di-exam-body">
  Candidates put <code class="di-code-inline">tool_result</code> blocks inside the <code class="di-code-inline">assistant</code> message alongside the <code class="di-code-inline">tool_use</code> block. <strong>Wrong.</strong>
</div>
</v-click>

<v-click>
<div class="di-trap-box">
  <div class="di-trap-label">❌ Wrong Structure</div>
  <ul style="margin: 0; padding-left: 1.2rem; font-size: 0.9rem;">
    <li>Putting <code>tool_result</code> inside the assistant message</li>
    <li>Omitting <code>tool_use_id</code> or using the wrong value</li>
    <li>Skipping the assistant message (with <code>tool_use</code>) in the replayed history</li>
  </ul>
</div>
</v-click>

<v-click>
<div class="di-correct-box">
  <div class="di-correct-label">✓ The Only Correct Pattern</div>
  Append the <strong>assistant message</strong> (with its <code>tool_use</code> content) to history, <em>then</em> append a new <strong>user message</strong> containing a <code>tool_result</code> block with the matching <code>tool_use_id</code>.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
The exam trap: candidates put tool_result blocks inside the assistant message alongside the tool_use block. This is wrong. The assistant message contains the tool_use block. Your follow-up goes in a separate user message.

The correct approach: after receiving a tool_use response, append the assistant message (with its tool_use content) to the conversation history. Then append a new user message containing a tool_result content block with the matching tool_use_id.

The tool_use_id field is mandatory — omitting it or using the wrong value will break the link between call and result.
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
  <v-click><li>Every tool needs three fields: <code style="color: #3CAF50;">name</code>, <code style="color: #3CAF50;">description</code>, and <code style="color: #3CAF50;">input_schema</code> (a JSON Schema object)</li></v-click>
  <v-click><li>Pass tools via <code style="color: #3CAF50;">tools=[...]</code> in <code>messages.create()</code> — Claude decides whether to call one</li></v-click>
  <v-click><li>When <code style="color: #3CAF50;">stop_reason == "tool_use"</code>, the response content contains a <code>tool_use</code> block with <code>id</code>, <code>name</code>, and <code>input</code></li></v-click>
  <v-click><li>Return results as a <code style="color: #3CAF50;">tool_result</code> content block in a <code>user</code> message, using <code>tool_use_id</code> to link it back</li></v-click>
</ul>

<img src="/logo.png" class="di-logo" style="opacity: 0.75;" />

<!--
Four things to remember:

Every tool needs three fields — name, description, and input_schema (a JSON Schema object).

Pass tools via tools=[...] in messages.create() — Claude decides whether to call one.

When stop_reason equals "tool_use", the response content contains a tool_use block with id, name, and input.

Return results as a tool_result content block in a user message, using tool_use_id to link it back.
-->
