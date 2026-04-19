---
theme: default
title: "Lecture 2.11: The Complete Tool Use Loop (Hands-On)"
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
  <div class="di-cover-title">The Complete<br><span style="color: #3CAF50;">Tool Use Loop</span></div>
  <div class="di-cover-subtitle">Lecture 2.11 · The foundation of every agent you'll ever build</div>
</div>

<img src="/logo.png" class="di-logo-centered" />

<!--
In the last lecture, you learned the single-turn tool use exchange. One tool call, one result, done.

But real applications don't work that way.

Claude might call two tools in one response. It might call a tool, get a result, call another tool, and then answer.

That's not a bug — that's the agentic loop in action.

This lecture is about implementing the complete loop correctly, end to end.

And I want to be direct: this is the most important pattern in this entire section. If you understand this loop, you understand the foundation of every Claude agent you'll ever build.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 2 — The Loop Structure, Step by Step
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">The Loop Structure — Step by Step</div>

<div style="display: flex; flex-direction: column; gap: 0.35rem; margin-top: 0.5rem; max-width: 780px; margin-left: auto; margin-right: auto;">

  <v-click>
  <div class="di-flow-box">
    <strong>1.</strong> Initialize <code>messages</code> with the user's message
  </div>
  <div class="di-arrow">↓</div>
  </v-click>

  <v-click>
  <div class="di-flow-box" style="background: #1B8A5A;">
    <strong>2.</strong> Send to Claude with <code>tools</code> attached
  </div>
  <div class="di-arrow">↓</div>
  </v-click>

  <v-click>
  <div class="di-flow-stop">
    <strong>3.</strong> <code>stop_reason == "end_turn"</code>? → return response, <strong>stop</strong>
  </div>
  <div class="di-arrow">↓</div>
  </v-click>

  <v-click>
  <div class="di-flow-tool">
    <strong>4.</strong> <code>stop_reason == "tool_use"</code> → execute <strong>ALL</strong> tool_use blocks
  </div>
  <div class="di-arrow">↓</div>
  </v-click>

  <v-click>
  <div class="di-flow-box">
    <strong>5.</strong> Append the assistant message (with tool_use blocks) to history
  </div>
  <div class="di-arrow">↓</div>
  </v-click>

  <v-click>
  <div class="di-flow-box" style="background: #1B8A5A;">
    <strong>6.</strong> Append one user message with <strong>ALL</strong> tool_results → back to Step 2 ↺
  </div>
  </v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
Let's walk through the structure before we look at code.

Step one: initialize your messages list with the user's message.
Step two: send the messages to Claude with your tools attached.
Step three: check stop_reason. If it's "end_turn", Claude is done — return the response to the user.

[click] If it's "tool_use", there's work to do.

Step four: execute every tool_use block in the response content — not just the first one.
Step five: append Claude's full assistant message to your messages list.
Step six: build a single user message containing all the tool_result blocks, append it, and loop back to step two.

Notice the loop exits only when stop_reason is "end_turn". Everything else is iteration.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 3 — Handling Multiple Tool Calls in One Response
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Multiple Tool Calls — In One Response</div>

<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-top: 0.5rem; align-items: start;">

  <v-click>
  <div>
    <div class="di-col-left-label">Claude's response</div>

```json
{
  "role": "assistant",
  "content": [
    { "type": "tool_use", "id": "toolu_1",
      "name": "get_weather",  "input": {...} },
    { "type": "tool_use", "id": "toolu_2",
      "name": "get_forecast", "input": {...} }
  ]
}
```

  </div>
  </v-click>

  <v-click>
  <div>
    <div class="di-col-right-label">Your reply — ONE user message</div>

```json
{
  "role": "user",
  "content": [
    { "type": "tool_result",
      "tool_use_id": "toolu_1", "content": "..." },
    { "type": "tool_result",
      "tool_use_id": "toolu_2", "content": "..." }
  ]
}
```

  </div>
  </v-click>

</div>

<v-click>
<div style="margin-top: 0.7rem; background: #FFF0F0; border-left: 3px solid #E53E3E; border-radius: 4px; padding: 0.55rem 0.85rem; font-size: 0.9rem;">
  <strong style="color: #E53E3E;">Never</strong> send one user message per tool result. One assistant turn with N calls → one user turn with N results. <strong>Always.</strong>
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
This is where many implementations break.

Claude can return multiple tool_use blocks in a single response. That means it wants to call multiple tools before it continues.

[click] You must execute all of them. Then you collect all the results and put them in a single user message.

Not one message per result — one message with all results.

If you send them as separate messages, the conversation structure breaks. Claude expects one tool_result per tool_use id, all in the same turn.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 4 — The Message History After One Cycle
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Message History After One Tool Cycle</div>

<div style="display: flex; flex-direction: column; gap: 0.4rem; margin-top: 0.5rem; max-width: 820px; margin-left: auto; margin-right: auto;">

  <v-click>
  <div class="di-step-card">
    <span class="di-step-num">1 · user</span>
    Original question — e.g. <em>"What's the weather in Paris?"</em>
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card" style="border-left-color: #0D7377;">
    <span class="di-step-num" style="color: #0D7377;">2 · assistant</span>
    Content array with one or more <code>tool_use</code> blocks
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card" style="border-left-color: #E3A008;">
    <span class="di-step-num" style="color: #E3A008;">3 · user</span>
    Content array with matching <code>tool_result</code> blocks
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card" style="border-left-color: #1B8A5A;">
    <span class="di-step-num" style="color: #1B8A5A;">4 · assistant</span>
    Final natural-language answer — <code>stop_reason = "end_turn"</code>
  </div>
  </v-click>

</div>

<v-click>
<div style="margin-top: 0.7rem; font-size: 0.88rem; color: #1A3A4A; background: #E8F5EB; border-radius: 6px; padding: 0.5rem 0.8rem;">
  Two cycles before answering? <strong>Six entries.</strong> Assistant messages carry reasoning + tool calls. User messages after the first always carry tool results.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
It helps to see what your messages list looks like after one complete cycle.

The first entry is the original user message — the question that started everything.
The second entry is Claude's assistant message — it contains the tool_use block.
The third entry is your user message — it contains the tool_result block.

[click] The fourth entry is Claude's final assistant message — the natural language answer.

This four-entry pattern is what a single tool use cycle looks like in history. If Claude calls tools twice before answering, you'll have six entries.

The assistant messages always contain the reasoning and tool calls. The user messages after the first one are always your tool results.
-->

---
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 5a — Complete Implementation: Tool Setup
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">Complete Implementation — Tools &amp; Dispatcher</div>

<v-click>

```python {all|4-21|23-28|all}
import anthropic

client = anthropic.Anthropic()

# --- Tool definitions ---
tools = [
    {
        "name": "get_current_weather",
        "description": "Get current weather for a city.",
        "input_schema": {
            "type": "object",
            "properties": {"city": {"type": "string", "description": "City name"}},
            "required": ["city"]
        }
    },
    {
        "name": "get_5day_forecast",
        "description": "Get a 5-day weather forecast for a city.",
        "input_schema": {
            "type": "object",
            "properties": {"city": {"type": "string", "description": "City name"}},
            "required": ["city"]
        }
    }
]

def execute_tool(name: str, inputs: dict) -> str:
    """Route tool calls to real implementations."""
    if name == "get_current_weather":
        return f"Currently 22°C and sunny in {inputs['city']}."
    elif name == "get_5day_forecast":
        return f"5-day forecast for {inputs['city']}: sunny all week, highs ~23°C."
    return "Unknown tool."
```

</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Here is the complete implementation, split across two slides so you can see it clearly.

First: the tool definitions. Two weather tools — one for current conditions, one for a five-day forecast. Each has a name, a description, and an input_schema.

The execute_tool function is your dispatcher — it routes Claude's tool calls to the real implementations. In a production system, this is where you'd call an external API, query a database, or run a calculation.
-->

---
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 5b — Complete Implementation: The Loop
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">Complete Implementation — The Loop</div>

<v-click>

```python {all|4|6-12|14-16|18-31|28-30|all}
def run_agent(user_message: str) -> str:
    messages = [{"role": "user", "content": user_message}]

    while True:
        response = client.messages.create(
            model="claude-opus-4-5",
            max_tokens=1024,
            tools=tools,
            messages=messages,
        )

        # Exit condition: Claude is done
        if response.stop_reason == "end_turn":
            return response.content[0].text

        # Claude wants to use tools
        if response.stop_reason == "tool_use":
            tool_use_blocks = [
                b for b in response.content if b.type == "tool_use"
            ]
            tool_results = [
                {
                    "type": "tool_result",
                    "tool_use_id": tu.id,
                    "content": execute_tool(tu.name, tu.input),
                }
                for tu in tool_use_blocks
            ]
            # Append assistant + user turn BEFORE the next API call
            messages.append({"role": "assistant", "content": response.content})
            messages.append({"role": "user", "content": tool_results})

answer = run_agent("What's the weather in Paris right now, and the forecast?")
print(answer)
```

</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Walk through this carefully.

The while True loop is the engine. Every iteration sends the full message history. The only exit is stop_reason == "end_turn".

When Claude asks for tools, you collect every tool_use block from the content array, execute each one, and build a list of tool_result blocks. Then you append both the assistant message AND the user message with all the results before looping back.

That's the entire pattern.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 6 — Why the Loop Terminates
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Why the Loop Terminates</div>

<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-top: 0.75rem; align-items: start;">

  <v-click>
  <div>
    <div class="di-col-left-label" style="color: #1B8A5A; border-color: #1B8A5A;">end_turn</div>
    <div class="di-col-body">
      <p>Claude has enough information to respond.</p>
      <ul>
        <li>Return the answer</li>
        <li>Loop exits</li>
      </ul>
    </div>
  </div>
  </v-click>

  <v-click>
  <div>
    <div class="di-col-right-label" style="color: #E3A008; border-color: #E3A008;">tool_use</div>
    <div class="di-col-body">
      <p>Claude needs another piece of data.</p>
      <ul>
        <li>Execute tools, extend history</li>
        <li>Loop again</li>
      </ul>
    </div>
  </div>
  </v-click>

</div>

<v-click>
<div style="margin-top: 0.9rem; font-size: 0.92rem; color: #111928; line-height: 1.6;">
  <p><strong>Claude controls how many cycles happen.</strong> Most tasks finish in one or two.</p>
  <div style="margin-top: 0.5rem; background: white; border-left: 3px solid #E3A008; border-radius: 4px; padding: 0.55rem 0.85rem; font-size: 0.88rem;">
    <strong>Production tip:</strong> add a maximum-iteration safety counter alongside <code>stop_reason</code> — belt and suspenders for runaway loops. The primary exit stays <code>stop_reason</code>.
  </div>
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
A question worth asking: what stops this loop from running forever?

Claude does.

After you return a tool_result, Claude either calls another tool or generates a final answer. It chooses based on whether it has enough information to respond.

[click] In practice, most tool use loops complete in one or two cycles. For complex research or multi-step tasks, it might take more.

Production systems often add a safety counter — a maximum iteration limit — to prevent runaway loops. But the fundamental termination guarantee is Claude's own stop_reason. When Claude has what it needs, it returns "end_turn".
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 7 — Connection to Agentic Architecture
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Connection to Agentic Architecture</div>

<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1.25rem; margin-top: 0.5rem; align-items: start;">

  <v-click>
  <div>
    <div class="di-col-left-label">What You Just Built</div>
    <div class="di-col-body">
      <ul>
        <li><code>while</code> loop</li>
        <li><code>stop_reason</code> check</li>
        <li>Tool execution</li>
        <li>History accumulation</li>
      </ul>
    </div>
  </div>
  </v-click>

  <v-click>
  <div>
    <div class="di-col-right-label">Section 3 · Agentic Systems</div>
    <div class="di-col-body">
      <ul>
        <li>Agent loop</li>
        <li>State management</li>
        <li>Action execution</li>
        <li>Memory / context</li>
      </ul>
    </div>
  </div>
  </v-click>

</div>

<v-click>
<div style="margin-top: 0.9rem; text-align: center; font-size: 1.05rem; font-weight: 700; color: #1A3A4A;">
  Same pattern — different scale.
</div>
</v-click>

<v-click>
<div style="margin-top: 0.5rem; font-size: 0.9rem; color: #111928; line-height: 1.6;">
  <ul>
    <li>The <code class="di-code-inline">while</code> loop becomes the agent's main execution cycle</li>
    <li>Tool definitions become the agent's capabilities — search, code exec, API calls</li>
    <li>Message history becomes the agent's working memory</li>
    <li><code class="di-code-inline">execute_tool</code> becomes your integration layer with the real world</li>
  </ul>
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
This loop is not just an API trick. This is the literal foundation of every autonomous agent built on Claude.

In Section 3, we'll talk about agentic architecture at a higher level. But the mechanics are exactly what you implemented here.

[click] The while loop becomes the agent's main execution cycle. Tool definitions become the agent's capabilities — search, code execution, API calls. The message history becomes the agent's working memory. The execute_tool function becomes your integration layer with the real world.

When you see a diagram of an "agentic loop" in the exam or in production systems, you now know exactly what it looks like in code.
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
<div class="di-exam-subtitle">N tool_use blocks → N tool_result blocks in ONE user message</div>

<div class="di-exam-body">
  When Claude returns two <code class="di-code-inline">tool_use</code> blocks in one response, candidates send two <em>separate</em> user messages — one per result. This breaks the conversation structure. The exam will present this bug and ask what's wrong.
</div>
</v-click>

<v-click>
<div class="di-trap-box">
  <div class="di-trap-label">❌ Distractor Pattern</div>
  Two <code>user</code> messages, each with a single <code>tool_result</code> — splitting the turn
</div>
</v-click>

<v-click>
<div class="di-correct-box">
  <div class="di-correct-label">✓ The Only Correct Pattern</div>
  <strong>One assistant turn with N tool calls → one user turn with N tool results.</strong> Always. Each <code>tool_result</code> must carry the matching <code>tool_use_id</code>.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
The exam trap: when Claude returns two tool_use blocks in one response, candidates send two separate user messages — one for each result. This breaks the conversation structure. The exam will present a code snippet with this bug and ask what's wrong.

The correct approach: when Claude's content array contains multiple tool_use blocks, collect all results and send them in a single user message with a content array containing one tool_result block per tool_use block. Each tool_result must have the matching tool_use_id.

One assistant turn with N tool calls → one user turn with N tool results. Always.
-->

---
layout: default
class: di-takeaway-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 9 — Key Takeaways
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-takeaway-title">The Tool Use Loop — What to Know Cold</div>

<ul class="di-takeaway-list">
  <v-click><li>The loop runs until <code style="color: #3CAF50;">stop_reason == "end_turn"</code> — <strong>Claude</strong> controls termination</li></v-click>
  <v-click><li>Every cycle: append both the <strong>assistant message</strong> (with tool_use blocks) <em>and</em> the <strong>user message</strong> (with all tool_results) to history</li></v-click>
  <v-click><li>Multiple <code style="color: #3CAF50;">tool_use</code> blocks → execute all of them → one user message with all <code style="color: #3CAF50;">tool_result</code> blocks</li></v-click>
  <v-click><li>This pattern is the direct foundation of every agentic Claude architecture — master it here, and Section 3 makes complete sense</li></v-click>
</ul>

<img src="/logo.png" class="di-logo" style="opacity: 0.75;" />

<!--
Four things to know cold:

The agentic loop runs until stop_reason == "end_turn" — Claude controls termination.

Append both the assistant message (with tool_use blocks) and the tool results (as a user message) to history on every cycle.

If Claude returns multiple tool_use blocks, execute all of them and return all results in a single user message.

This loop pattern is the direct foundation of all agentic Claude architectures — master it here, and Section 3 will make complete sense.
-->
