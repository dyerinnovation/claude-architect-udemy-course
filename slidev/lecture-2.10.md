---
theme: default
title: "Lecture 2.10: Tool Use Fundamentals — Your First Function Call"
info: |
  Claude Certified Architect – Foundations
  Section 2: Claude API Fundamentals Bootcamp (Domain 1 & 2)
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
const cycleSteps = [
  { label: '1 · You', sublabel: 'user message + tool definitions' },
  { label: '2 · Claude', sublabel: "returns tool_use block, stop_reason='tool_use'" },
  { label: '3 · You', sublabel: 'execute the real function' },
  { label: '4 · You', sublabel: 'send tool_result inside a user message' },
  { label: '5 · Claude', sublabel: "final response, stop_reason='end_turn'" },
]

const takeaways = [
  { label: 'Three required fields', detail: 'Every tool needs name, description, and input_schema (JSON Schema)' },
  { label: 'Pass via tools=[...]', detail: 'In messages.create() — Claude decides whether to call one' },
  { label: "tool_use block", detail: "When stop_reason=='tool_use', content has a tool_use block with id, name, input" },
  { label: "Return in USER message", detail: "tool_result block in a user turn, using tool_use_id to link back" },
]

const weatherToolCode = `get_weather_tool = {
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
}`

const requestCode = `import anthropic

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

# If Claude decides to call a tool, response.stop_reason == "tool_use"
# That's your signal — Claude is handing control back to you.`

const executeCode = `# Step 1: find the tool_use block in the response content
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
)`
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
      <div class="lec-cover__section">Section 2 · Lecture 2.10 · Domain 1 & 2</div>
      <h1 class="lec-cover__title">Tool Use Fundamentals</h1>
      <div class="lec-cover__subtitle">Your First Function Call</div>
    </div>
    <div class="lec-cover__stats">
      <span>API Fundamentals Bootcamp</span>
      <span class="lec-cover__dot">&middot;</span>
      <span>Agentic foundations</span>
    </div>
  </div>
</Frame>

<style>
.lec-cover { position: relative; z-index: 1; padding: 110px 120px 96px; width: 100%; height: 100%; display: flex; flex-direction: column; justify-content: space-between; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%); }
.lec-cover__brand { display: flex; align-items: center; gap: 24px; }
.lec-cover__logo { width: 72px; height: auto; }
.lec-cover__brand-text { font-family: var(--font-body); font-size: 26px; font-weight: 500; letter-spacing: 0.14em; text-transform: uppercase; color: var(--mint-200); }
.lec-cover__section { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px; }
.lec-cover__title { font-family: var(--font-display); font-weight: 500; font-size: 128px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1500px; }
.lec-cover__subtitle { font-family: var(--font-display); font-size: 48px; color: var(--mint-200); margin-top: 32px; font-weight: 400; max-width: 1400px; line-height: 1.3; }
.lec-cover__stats { display: flex; align-items: center; gap: 36px; font-family: var(--font-body); font-size: 24px; color: var(--mint-200); letter-spacing: 0.06em; }
.lec-cover__dot { opacity: 0.4; }
.exam-stack { margin-top: 48px; display: flex; flex-direction: column; gap: 28px; flex: 1; min-height: 0; }
</style>

<!--
Here's a constraint that trips up a lot of architects early on.

Claude is a language model — it reasons and generates text.

It cannot look up today's stock price, query your database, or send an email. Not by itself.

But you can give Claude tools — and Claude will call them when it needs to.

This is how you connect Claude's reasoning to real-world actions and live data.

The mechanism is called tool use, and it is one of the most important API concepts you'll learn in this course.
-->

---

<!-- SLIDE 2 — Anatomy of a tool definition -->

<TwoColSlide
  variant="compare"
  title="Anatomy of a Tool Definition"
  leftLabel="JSON"
  rightLabel="Three required fields"
>
  <template #left>
    <pre><code>{"name": "get_weather",
 "description": "Retrieves current weather for a city.",
 "input_schema": {
   "type": "object",
   "properties": {
     "city": {"type": "string"}
   },
   "required": ["city"]
 }}</code></pre>
  </template>
  <template #right>
    <ul>
      <li><strong>name</strong> — snake_case identifier Claude uses when calling</li>
      <li><strong>description</strong> — Claude's ability to pick the right tool depends entirely on this</li>
      <li><strong>input_schema</strong> — JSON Schema — the function signature — type, properties, required</li>
    </ul>
  </template>
</TwoColSlide>

<!--
Every tool you give Claude has exactly three required fields.

name — a string identifier in snake_case, like "get_weather" or "search_database". This is the name Claude uses when it calls the tool.

description — a natural language explanation of what the tool does and when to use it. This field is critical. Claude's ability to choose the right tool depends entirely on a good description.

input_schema — a JSON Schema object that defines the tool's parameters. It must have "type": "object", a properties map, and a required array.

Think of input_schema as the function signature — it tells Claude what arguments to provide.
-->

---

<!-- SLIDE 3 — Concrete tool definition -->

<CodeBlockSlide
  eyebrow="Concrete example"
  title="A Full Tool Definition"
  lang="python"
  :code="weatherToolCode"
  annotation="Per-property description — Claude reads these too · required[] — which args Claude must always supply; optional args may be omitted."
/>

<!--
Let's make this concrete with a real example.

The description inside input_schema.properties is also read by Claude. It helps Claude understand what value to put in each argument.

The required array tells Claude which arguments it must always provide.

Optional fields like unit can be omitted by Claude if they're not relevant.
-->

---

<!-- SLIDE 4 — Sending the request -->

<CodeBlockSlide
  eyebrow="The request"
  title="Sending the Request With Tools"
  lang="python"
  :code="requestCode"
  annotation="If Claude decides to call a tool, response.stop_reason == 'tool_use' — Claude is handing control back to you, it's not done."
/>

<!--
You pass tools to messages.create() using the tools parameter.

Claude evaluates the conversation and decides whether to call a tool.

If it decides to call one, stop_reason in the response will be "tool_use". That's your signal — Claude is handing control back to you.

It's not done. It's waiting for you to execute the tool and return the result.
-->

---

<!-- SLIDE 5 — Reading the tool use response -->

<TwoColSlide
  variant="compare"
  title="Reading the Tool-Use Response"
  leftLabel="JSON"
  rightLabel="Four fields"
>
  <template #left>
    <pre><code>{"stop_reason": "tool_use",
 "content": [
   {"type": "tool_use",
    "id": "toolu_01XFb...",
    "name": "get_current_weather",
    "input": {
      "city": "Tokyo",
      "unit": "celsius"
    }}
 ]}</code></pre>
  </template>
  <template #right>
    <ul>
      <li><strong>type</strong> — always <code>'tool_use'</code> — find this in content</li>
      <li><strong>id</strong> — unique per call — echo this back in your result</li>
      <li><strong>name</strong> — matches the tool you defined</li>
      <li><strong>input</strong> — ready-to-use dict — call your function directly</li>
    </ul>
  </template>
</TwoColSlide>

<!--
When stop_reason is "tool_use", the response content array contains a tool_use block.

That block has four important fields.

type is always "tool_use" — use this to identify it in the array.

id is a unique identifier like "toolu_01XFb..." — you'll need this to send the result back.

name is the tool name Claude chose — matches what you defined.

input is a Python dict containing the parsed arguments Claude generated. You don't need to parse anything — Claude gives you a ready-to-use dict. Just call your function with those arguments directly.
-->

---

<!-- SLIDE 6 — Execute and return -->

<CodeBlockSlide
  eyebrow="Returning the result"
  title="Execute the Tool — and Return the Result"
  lang="python"
  :code="executeCode"
  annotation="tool_result goes in a user message — never assistant · tool_use_id links result back to the specific call."
/>

<!--
Here is the pattern for executing the tool and sending the result back.

The tool_result block goes in a user message — not an assistant message.

The tool_use_id links your result back to the specific tool call Claude made.

Claude reads the result and generates its final natural language response.
-->

---

<!-- SLIDE 7 — Request-response cycle -->

<FlowDiagram
  eyebrow="The full cycle"
  title="The Request-Response Cycle"
  :steps="cycleSteps"
/>

<!--
Let's step back and see the full cycle.

You send Claude a message with tool definitions attached. Claude decides to call a tool and returns a tool_use block with stop_reason "tool_use".

You execute the real function with the arguments Claude provided.

You send the result back as a tool_result block inside a user message — matching the tool_use_id to link it to Claude's call.

Claude reads the result and generates its final natural-language response with stop_reason "end_turn".

Two-step exchange. Everything in agentic architecture builds on this.
-->

---

<!-- SLIDE 8 — Exam Tip -->

<Frame>
  <Eyebrow>⚡ Exam Tip</Eyebrow>
  <SlideTitle>Tool Results Go in a user Message</SlideTitle>
  <div class="exam-stack">
    <CalloutBox variant="dont" title="Wrong structure">
      <p>Putting <code>tool_result</code> inside the assistant message alongside <code>tool_use</code> · omitting <code>tool_use_id</code> · skipping the assistant message in replayed history.</p>
    </CalloutBox>
    <CalloutBox variant="do" title="Only correct pattern">
      <p>Append assistant message (with <code>tool_use</code> content) to history, THEN append a new user message containing a <code>tool_result</code> block with matching <code>tool_use_id</code>.</p>
    </CalloutBox>
  </div>
</Frame>

<!--
The exam will present scenarios where candidates put tool_result in the wrong message, or skip the assistant message entirely.

The rule: assistant message (with tool_use content) first, then a new user message with tool_result. The tool_use_id on the result must match the id on the original tool_use.

Skip either step and Claude's conversation history is malformed — you'll see errors or broken behavior.
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

Every tool needs name, description, and input_schema (JSON Schema).

Pass tools via tools=[...] in messages.create() — Claude decides whether to call one.

When stop_reason=='tool_use', content has a tool_use block with id, name, input.

Return results as tool_result in a USER message, using tool_use_id to link back.
-->
