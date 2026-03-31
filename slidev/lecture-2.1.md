---
theme: default
title: "Lecture 2.1: The Agentic Loop: stop_reason Is Everything"
info: |
  Claude Certified Architect – Foundations
  Domain 1 — Agentic Architecture & Orchestration (27%)
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
  <div class="di-course-label">Domain 1 · Agentic Architecture & Orchestration (27%)</div>
  <div class="di-cover-title">The Agentic Loop:<br><span style="color: #3CAF50;">stop_reason</span> Is Everything</div>
  <div class="di-cover-subtitle">Lecture 2.1 · Claude Certified Architect – Foundations</div>
</div>

<img src="/logo.png" class="di-logo-centered" />

<!--
Here's the fundamental question you must answer when building any agentic system with Claude.

How does Claude communicate to your code whether it's done — or whether it needs you to do something first?

The answer is a single field in every API response: stop_reason.

Get this wrong, and your agent either terminates before it finishes, or loops forever. There is no middle ground.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 2 — What the Agentic Loop Looks Like
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">What the Agentic Loop Looks Like</div>

<v-click>
<div style="display: flex; align-items: stretch; gap: 1.5rem; margin-top: 0.5rem;">

  <!-- Flowchart column -->
  <div style="flex: 0 0 42%; display: flex; flex-direction: column; align-items: center; gap: 0.2rem;">
    <div class="di-flow-box" style="width: 100%;">Send request to Claude</div>
    <div class="di-arrow">↓</div>
    <div style="background: #2a4a6a; color: white; border-radius: 6px; padding: 0.5rem 1rem; width: 100%; text-align: center; font-weight: 600; font-size: 0.9rem;">
      check <code style="color: #3CAF50;">stop_reason</code>
    </div>
    <div style="display: flex; width: 100%; gap: 0.5rem; margin-top: 0.2rem;">
      <div style="flex: 1; text-align: center;">
        <v-click at="2">
        <div style="font-size: 0.75rem; color: #E3A008; font-weight: 600; margin-bottom: 0.2rem;">"tool_use"</div>
        <div class="di-flow-tool" style="font-size: 0.82rem;">Execute tool<br>→ append result<br>→ loop back ↺</div>
        </v-click>
      </div>
      <div style="flex: 1; text-align: center;">
        <v-click at="4">
        <div style="font-size: 0.75rem; color: #1B8A5A; font-weight: 600; margin-bottom: 0.2rem;">"end_turn"</div>
        <div class="di-flow-stop" style="font-size: 0.82rem;">Return response<br>to user<br>→ stop ■</div>
        </v-click>
      </div>
    </div>
  </div>

  <!-- Explanation column -->
  <div style="flex: 1; font-size: 0.92rem; color: #111928; line-height: 1.65;">
    <p>You send a request to Claude. Every response includes a <code class="di-code-inline">stop_reason</code> field.</p>
    <v-click at="3">
    <div class="di-step-card" style="margin-top: 0.5rem;">
      <span class="di-step-num" style="color: #E3A008;">tool_use →</span>
      <em>Keep going.</em> Execute the tool, append the result to the conversation, send the next request.
    </div>
    </v-click>
    <v-click at="5">
    <div class="di-step-card" style="margin-top: 0.5rem; border-left-color: #1B8A5A;">
      <span class="di-step-num" style="color: #1B8A5A;">end_turn →</span>
      <em>Stop.</em> The response is complete. Return it to the user.
    </div>
    </v-click>
    <v-click at="6">
    <p style="margin-top: 0.75rem; font-size: 0.88rem; color: #1A3A4A;">
      That's the entire loop. <code class="di-code-inline">stop_reason</code> is the signal. Your code responds to it.
    </p>
    </v-click>
  </div>

</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Let me show you the complete loop structure.

You send a request to Claude. Claude responds with a message that always includes a stop_reason field.

[click] If stop_reason is "tool_use", Claude is telling you: I've decided to call a tool. Execute the tool, take the result, append it to the conversation, and send the next request. Keep going.

[click] If stop_reason is "end_turn", Claude is telling you: I'm done. The response is complete. Don't loop. Return it to the user.

That's the entire loop. The stop_reason field is the signal. Your code responds to it.
-->

---
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 3 — The Canonical Loop (Code)
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">The Code Pattern — The Canonical Loop</div>

<v-click>

```python {all|9-10|13-16|all}
messages = [{"role": "user", "content": initial_prompt}]

while True:
    response = client.messages.create(
        model="claude-opus-4-6",
        tools=tools,
        messages=messages
    )

    # The exit condition — always check stop_reason first
    if response.stop_reason == "end_turn":
        break

    # The continuation condition
    if response.stop_reason == "tool_use":
        tool_results = execute_tools(response.content)
        messages.append({"role": "assistant", "content": response.content})
        messages.append({"role": "user", "content": tool_results})
        # Loop continues
```

</v-click>

<v-click>
<div style="display: flex; gap: 1rem; margin-top: 0.5rem; font-size: 0.82rem; color: #1A3A4A;">
  <div style="flex: 1; background: white; border-radius: 4px; padding: 0.4rem 0.6rem; border-left: 2px solid #3CAF50;">
    <strong style="color: #1B8A5A;">while True</strong> — Claude drives termination, not a counter
  </div>
  <div style="flex: 1; background: white; border-radius: 4px; padding: 0.4rem 0.6rem; border-left: 2px solid #E3A008;">
    <strong style="color: #E3A008;">Append both</strong> assistant msg + tool result before next call
  </div>
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Here's what this looks like in code.

Notice the structure: while True loop with an explicit break on end_turn.

The loop is intentionally unbounded — Claude drives the termination, not a counter.

And the tool results get appended to the conversation history before the next call. That's not optional. Claude needs to see what its tools returned.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 4 — What's in a Tool Use Response
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">What's in a Tool Use Response</div>

<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-top: 0.5rem; align-items: start;">

  <v-click>
  <div>

```json
{
  "stop_reason": "tool_use",
  "content": [
    {
      "type": "tool_use",
      "id": "toolu_01ABC123",
      "name": "get_weather",
      "input": {
        "location": "Seattle, WA"
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
      <span class="di-step-num">type</span> Always <code class="di-code-inline">"tool_use"</code> — identifies this block
    </div>
    <div class="di-step-card">
      <span class="di-step-num">name</span> Which tool Claude selected
    </div>
    <div class="di-step-card">
      <span class="di-step-num">input</span> Arguments Claude decided to pass
    </div>
    </v-click>
    <v-click>
    <div class="di-step-card" style="border-left-color: #E3A008;">
      <span class="di-step-num" style="color: #E3A008;">id ⚠</span> Must be echoed back when you return the result — Claude uses it to match results to requests when multiple tools are called
    </div>
    </v-click>
  </div>

</div>

<img src="/logo.png" class="di-logo" />

<!--
When stop_reason is "tool_use", the response content contains a tool use block.

It has four key parts: the type ("tool_use"), the id (a unique identifier for this specific call), the name (which tool Claude selected), and the input (the arguments Claude decided to pass).

[click] The id matters because when you send the tool result back, you must reference this same ID. Claude uses it to match results to requests — especially when multiple tools are called in the same response.

Your code's job: find all "tool_use" blocks in the content, execute each tool with the provided inputs, and package the results back with matching IDs.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 5 — Appending Tool Results Correctly
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Appending Tool Results Correctly</div>

<div class="di-body" style="margin-top: 0.5rem;">

<v-click>
<p style="color: #E53E3E; font-weight: 600; font-size: 0.95rem;">Most common mistake: forgetting to append <em>both</em> the assistant message AND the tool result.</p>
</v-click>

<div style="display: flex; flex-direction: column; gap: 0.4rem; margin-top: 0.5rem;">

  <v-click>
  <div class="di-step-card">
    <span class="di-step-num">Step 1</span>
    Append the full assistant response (the one with the <code class="di-code-inline">tool_use</code> block) to the messages array
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card" style="border-left-color: #0D7377;">
    <span class="di-step-num" style="color: #0D7377;">Step 2</span>
    Append a <strong>user</strong> message with the tool result — each result block needs: <code class="di-code-inline">tool_use_id</code>, <code class="di-code-inline">content</code>, and <code class="di-code-inline">is_error</code>
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card" style="border-left-color: #1B8A5A;">
    <span class="di-step-num" style="color: #1B8A5A;">Step 3</span>
    Make the next API call with the <strong>full updated messages array</strong>
  </div>
  <div style="background: #FFF0F0; border-left: 3px solid #E53E3E; padding: 0.5rem 0.8rem; border-radius: 4px; font-size: 0.88rem; margin-top: 0.25rem;">
    <strong>Skip either step:</strong> Claude's context is incomplete → it will repeat itself or hallucinate what the tool returned
  </div>
  </v-click>

</div>
</div>

<img src="/logo.png" class="di-logo" />

<!--
The most common implementation mistake: forgetting to append both the assistant message AND the tool result before the next call.

This is the required sequence on every iteration:

First, append the full assistant response (the one containing the tool_use block) to the messages array.

[click] Second, append a user message containing the tool result. This is formatted as a list of tool_result blocks, each with the tool_use_id matching Claude's request, the content (the actual result), and whether it's an error.

[click] Then make the next API call with the full updated messages array.

Skip either step, and Claude's context is incomplete. It will either repeat itself or hallucinate what the tool returned.
-->

---
layout: two-cols
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 6 — The Two stop_reason Values
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header" style="margin: -1.5rem -1rem 1rem -2rem; padding-right: 1rem;">The Two stop_reason Values You Must Know</div>

<v-click>
<div style="padding-right: 1rem;">
  <div class="di-col-left-label"><code>"tool_use"</code></div>
  <div class="di-col-body">
    <p><em>Claude has decided to call a tool.</em></p>
    <ul>
      <li>The loop <strong>must continue</strong></li>
      <li>Execute tools, append results, call API again</li>
    </ul>
    <div class="di-col-warning">
      <strong>Do NOT:</strong> treat this as a complete response<br>
      <strong>Do NOT:</strong> return this to the user
    </div>
  </div>
</div>
</v-click>

::right::

<div style="padding-left: 1rem; padding-top: 5rem;">
  <v-click>
  <div class="di-col-right-label"><code>"end_turn"</code></div>
  <div class="di-col-body">
    <p><em>Claude has completed its response.</em></p>
    <ul>
      <li>The loop <strong>must stop</strong></li>
      <li>Return response to user</li>
    </ul>
    <div class="di-col-warning">
      <strong>Do NOT:</strong> keep looping "just to check"<br>
      <strong>Do NOT:</strong> inspect text for keywords like "done"
    </div>
    <div style="margin-top: 0.75rem; text-align: center; font-size: 1.1rem; font-weight: 700; color: #1A3A4A;">
      The field speaks. Believe it.
    </div>
  </div>
  </v-click>
</div>

<img src="/logo.png" class="di-logo" />

<!--
There are other stop_reason values — like "max_tokens" and "stop_sequence" — but for agentic loops, these two are the only ones you need to make decisions about.

"tool_use" means: Claude made a decision to call a tool. The loop must continue. Do not treat this as a complete response. Do not return this to the user.

[click] "end_turn" means: Claude has completed its response. The loop must stop. Do not keep looping "just to check." Do not inspect the text for keywords like "done" or "finished."

The field speaks. Believe it.
-->

---
layout: default
class: di-exam-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 7 — Exam Tip
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-exam-banner">⚡ EXAM TIP</div>

<v-click>
<div class="di-exam-subtitle">How to Control the Loop</div>

<div class="di-exam-body">
  The exam will present scenarios where the candidate uses something other than <code class="di-code-inline">stop_reason</code> to control the loop. These are <strong>all</strong> anti-patterns.
</div>
</v-click>

<v-click>
<div class="di-trap-box">
  <div class="di-trap-label">❌ Distractor Patterns</div>
  <ul style="margin: 0; padding-left: 1.2rem; font-size: 0.9rem;">
    <li>Checking if response text contains "done" or "complete"</li>
    <li>Setting a maximum iteration counter as the <em>primary</em> exit condition</li>
    <li>Checking whether <code>content</code> includes a tool_use block (instead of the <code>stop_reason</code> field)</li>
  </ul>
</div>
</v-click>

<v-click>
<div class="di-correct-box">
  <div class="di-correct-label">✓ The Only Correct Pattern</div>
  Read <code class="di-code-inline">stop_reason</code> from the response object.<br>
  <strong>"end_turn"</strong> → stop. &nbsp; <strong>"tool_use"</strong> → execute tools and continue.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
The exam will present scenarios where a candidate is doing something other than reading stop_reason to control the loop.

Examples you'll see as distractors: checking if the response text contains the word "done" or "complete," setting a maximum iteration counter as the primary exit condition, or checking whether the response includes a tool_use block in the content (instead of checking the stop_reason field).

All of these are anti-patterns. The correct pattern is exactly one thing: read stop_reason from the response object.

If it's "end_turn", stop. If it's "tool_use", execute tools and continue. That's it.
-->

---
layout: default
class: di-takeaway-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 8 — Key Takeaways
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-takeaway-title">The Agentic Loop — What to Know Cold</div>

<ul class="di-takeaway-list">
  <v-click><li><code style="color: #3CAF50;">stop_reason = "tool_use"</code> → execute tool, append result, loop back</li></v-click>
  <v-click><li><code style="color: #3CAF50;">stop_reason = "end_turn"</code> → return response to user, stop</li></v-click>
  <v-click><li><strong>Always append both</strong> the assistant message AND tool result before the next call</li></v-click>
  <v-click><li><strong>The loop is <code style="color: #A8D5C2;">while True</code> with an explicit break</strong> — Claude drives termination</li></v-click>
  <v-click><li><strong>Never use text content inspection</strong> to decide whether to continue looping</li></v-click>
  <v-click><li>This pattern applies to every scenario on the exam — master it first</li></v-click>
</ul>

<img src="/logo.png" class="di-logo" style="opacity: 0.75;" />

<!--
To summarize what you need to know cold:

stop_reason = "tool_use" → execute tool, append result, loop back.
stop_reason = "end_turn" → return response to user, stop.

Always append both the assistant message AND the tool result before the next call.

The loop is while True with an explicit break — Claude drives termination, not your code.

Never use text content inspection to decide whether to continue looping.

This pattern is the foundation for every agentic scenario on the exam. Master it first.
-->
