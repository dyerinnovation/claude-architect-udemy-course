---
theme: default
title: "Lecture 3.2: tool_use vs end_turn — Control Flow Patterns"
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
  <div class="di-cover-title"><span style="color: #3CAF50;">tool_use</span> vs <span style="color: #A8D5C2;">end_turn</span><br>Control Flow Patterns</div>
  <div class="di-cover-subtitle">Lecture 3.2 · Claude Certified Architect – Foundations</div>
</div>

<img src="/logo.png" class="di-logo-centered" />

<!--
In the previous lecture, we looked at the overall agentic loop.

Now let's go deeper into the two branches — what happens in each one, and what specific patterns each enables.

Because the difference between these two paths isn't just "keep going" versus "stop."

It's about what you do with the response content, how you structure the conversation history, and what control flow patterns you can build on top of each.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 2 — The tool_use Path: Step by Step
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">The tool_use Path — Step by Step</div>

<div class="di-body" style="margin-top: 0.5rem;">

<v-click>
<div class="di-step-card" style="border-left-color: #0D7377;">
  <span class="di-step-num" style="color: #0D7377;">Step 1</span>
  Extract <code class="di-code-inline">tool_use</code> blocks from the content array — a single response can contain <strong>multiple</strong> tool_use blocks
</div>
</v-click>

<v-click>
<div class="di-step-card" style="border-left-color: #3CAF50;">
  <span class="di-step-num">Step 2</span>
  <strong>Execute each tool</strong> — query a database, call an API, read a file — whatever the tool does
</div>
</v-click>

<v-click>
<div class="di-step-card" style="border-left-color: #E3A008;">
  <span class="di-step-num" style="color: #E3A008;">Step 3</span>
  <strong>Package the results</strong> — each result needs: <code class="di-code-inline">tool_use_id</code> (matching Claude's request), <code class="di-code-inline">content</code> (the data), and <code class="di-code-inline">is_error</code> flag
</div>
</v-click>

<v-click>
<div class="di-step-card" style="border-left-color: #1B8A5A;">
  <span class="di-step-num" style="color: #1B8A5A;">Step 4</span>
  <strong>Append</strong> the original assistant response to messages, then append a new user message with all tool results → call the API again
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
When you receive a response with stop_reason = "tool_use", here's the exact sequence.

Step one: extract the tool_use blocks from the content array. A single response can contain multiple tool_use blocks — Claude can call several tools in one turn.

[click] Step two: execute each tool. This means running your actual function — querying a database, calling an API, reading a file — whatever the tool does.

[click] Step three: package the results. Each result goes into a tool_result block with the matching tool_use_id, the content (the actual result data), and an is_error flag if the tool failed.

[click] Step four: append the original assistant response to messages, then append a new user message containing all the tool results. Then call the API again.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 3 — The end_turn Path
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">The end_turn Path — What It Actually Means</div>

<div class="di-body" style="margin-top: 0.5rem;">

<v-click>
<p><code class="di-code-inline">"end_turn"</code> doesn't always mean the task is complete. It means Claude has decided to <strong>stop generating</strong> — for whatever reason.</p>
</v-click>

<div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 0.6rem; margin-top: 0.75rem;">
  <v-click>
  <div style="background: white; border: 1px solid #c8e6d0; border-top: 3px solid #3CAF50; border-radius: 6px; padding: 0.6rem 0.75rem; font-size: 0.88rem;">
    <div style="font-weight: 700; color: #1B8A5A; margin-bottom: 0.3rem;">✓ Task Complete</div>
    <div style="color: #111928;">Most common — Claude finished successfully</div>
    <div style="margin-top: 0.4rem; font-size: 0.8rem; color: #1A3A4A; font-style: italic;">→ Return response to user</div>
  </div>
  </v-click>
  <v-click>
  <div style="background: white; border: 1px solid #ffd5a0; border-top: 3px solid #E3A008; border-radius: 6px; padding: 0.6rem 0.75rem; font-size: 0.88rem;">
    <div style="font-weight: 700; color: #E3A008; margin-bottom: 0.3rem;">⚠ Can't Proceed</div>
    <div style="color: #111928;">Claude hit a blocker and is returning an explanation</div>
    <div style="margin-top: 0.4rem; font-size: 0.8rem; color: #1A3A4A; font-style: italic;">→ Inspect content, surface to user</div>
  </div>
  </v-click>
  <v-click>
  <div style="background: white; border: 1px solid #ffc8c8; border-top: 3px solid #E53E3E; border-radius: 6px; padding: 0.6rem 0.75rem; font-size: 0.88rem;">
    <div style="font-weight: 700; color: #E53E3E; margin-bottom: 0.3rem;">✗ Max Tokens</div>
    <div style="color: #111928;">Context limit reached mid-response</div>
    <div style="margin-top: 0.4rem; font-size: 0.8rem; color: #1A3A4A; font-style: italic;">→ Check <code>stop_reason</code>, handle truncation</div>
  </div>
  </v-click>
</div>

<v-click>
<div style="margin-top: 0.75rem; background: #FFF0F0; border-left: 3px solid #E53E3E; padding: 0.5rem 0.8rem; border-radius: 4px; font-size: 0.88rem;">
  <strong>Critical rule:</strong> Do not loop on <code class="di-code-inline">"end_turn"</code>. Whatever the reason, Claude has made a decision. Return the response and let the calling code or user handle it.
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
"end_turn" doesn't always mean the task is complete and everything is fine.

It means Claude has decided to stop generating — for whatever reason.

[click] The three typical reasons for "end_turn" are: the task is complete (most common), Claude determined it cannot proceed and is returning an explanation, or the context got close to the limit.

In your control flow, you should inspect the response content after an "end_turn" to understand why Claude stopped — especially in error-prone workflows.

But critically: do not loop on "end_turn". Whatever the reason, Claude has made a decision. Return the response and let the calling code or user handle it.
-->

---
layout: two-cols
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 4 — Model-Driven vs Pre-Configured
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header" style="margin: -1.5rem -1rem 1rem -2rem; padding-right: 1rem;">Model-Driven vs Pre-Configured Decision Trees</div>

<v-click>
<div style="padding-right: 1.2rem;">
  <div class="di-col-left-label">Model-Driven (Claude decides)</div>
  <div class="di-col-body">
    <ul>
      <li>Give Claude the full tool set</li>
      <li>Claude decides which tool to call and in what order</li>
      <li>The tool_use loop handles sequencing automatically</li>
    </ul>
    <div style="margin-top: 0.5rem; background: #E8F5EB; padding: 0.5rem 0.7rem; border-radius: 5px; font-size: 0.88rem;">
      <strong>Use for:</strong> flexible workflows where the right sequence is context-dependent
    </div>
    <div style="margin-top: 0.5rem; font-size: 0.88rem; color: #1A3A4A; font-style: italic;">
      Example: research agent that chooses between web search, file read, or API call
    </div>
  </div>
</div>
</v-click>

::right::

<v-click>
<div style="padding-left: 1.2rem; padding-top: 5rem;">
  <div class="di-col-right-label">Pre-Configured (your code decides)</div>
  <div class="di-col-body">
    <ul>
      <li>Your code has explicit decision trees</li>
      <li>Certain tools can only be called after others complete</li>
      <li>You inspect intermediate results and route next steps</li>
    </ul>
    <div style="margin-top: 0.5rem; background: #FFF8E6; border-left: 3px solid #E3A008; padding: 0.5rem 0.7rem; border-radius: 5px; font-size: 0.88rem;">
      <strong>Use for:</strong> <em>hard constraints</em> — things that must happen in a specific order for safety or correctness
    </div>
    <div style="margin-top: 0.5rem; font-size: 0.88rem; color: #1A3A4A; font-style: italic;">
      Example: can't process refund before looking up customer order
    </div>
  </div>
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
There are two philosophies for how to route between tools in an agentic workflow.

In the model-driven approach, you give Claude a full set of tools and let it decide which to call and in what order. The tool_use loop handles sequencing automatically. Claude's judgment is the routing logic.

[click] In the pre-configured approach, your code has explicit decision trees. Certain tools can only be called after others complete. You inspect intermediate results and decide what to do next.

For exam purposes: model-driven is the default for flexible workflows. Pre-configured (programmatic enforcement) is the right choice for hard constraints — things that must happen in a specific order for safety or correctness reasons.

The customer support scenario uses this explicitly: you can't process a refund before looking up the customer order. That order enforcement is programmatic, not left to Claude's judgment.
-->

---
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 5 — Handling Multiple Tool Calls
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">Handling Multiple Tool Calls in One Response</div>

<v-click>

```python {all|3-4|5-9|12-15}
tool_results = []

# Claude can return multiple tool_use blocks in one response
for block in response.content:
    if block.type == "tool_use":
        result = execute_tool(block.name, block.input)
        tool_results.append({
            "type": "tool_result",
            "tool_use_id": block.id,   # Must match Claude's request ID
            "content": result
        })

# All results go back in a single user message
messages.append({
    "role": "user",
    "content": tool_results   # List of all tool_result blocks
})
```

</v-click>

<v-click>
<div style="display: flex; gap: 0.75rem; margin-top: 0.5rem; font-size: 0.82rem; color: #1A3A4A;">
  <div style="flex: 1; background: white; padding: 0.4rem 0.6rem; border-radius: 4px; border-left: 2px solid #E53E3E;">
    <strong style="color: #E53E3E;">Don't:</strong> process tools one at a time with individual API calls
  </div>
  <div style="flex: 1; background: white; padding: 0.4rem 0.6rem; border-radius: 4px; border-left: 2px solid #3CAF50;">
    <strong style="color: #1B8A5A;">Do:</strong> batch all tool results into one combined user message
  </div>
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Claude can issue multiple tool calls in a single response turn.

When this happens, all the tool_use blocks appear together in the content array. Your code must process all of them before sending the next request.

Don't send partial results. Don't process tools one at a time with individual API calls. Process all tool calls from a single response in one batch, then send one combined user message.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 6 — Tool Results in Conversation History
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Tool Results in the Conversation History</div>

<div class="di-body" style="margin-top: 0.5rem;">

<v-click>
<p>The conversation history is how Claude maintains context. Every message matters.</p>
</v-click>

<v-click>
<div style="display: flex; align-items: center; gap: 0.4rem; flex-wrap: wrap; margin: 0.75rem 0; font-size: 0.85rem;">
  <div style="background: #E8F5EB; border: 1px solid #c8e6d0; border-radius: 5px; padding: 0.35rem 0.6rem; color: #111928;"><strong>user</strong><br><span style="font-size:0.75rem; color:#666;">initial request</span></div>
  <div style="color: #0D7377; font-size: 1.2rem;">→</div>
  <div style="background: #1A3A4A; color: white; border-radius: 5px; padding: 0.35rem 0.6rem; font-size: 0.82rem;"><strong>assistant</strong><br><span style="color: #E3A008; font-size: 0.75rem;">tool_use block</span></div>
  <div style="color: #0D7377; font-size: 1.2rem;">→</div>
  <div style="background: #E8F5EB; border: 1px solid #c8e6d0; border-radius: 5px; padding: 0.35rem 0.6rem; color: #111928;"><strong>user</strong><br><span style="font-size:0.75rem; color:#1B8A5A;">tool_result</span></div>
  <div style="color: #0D7377; font-size: 1.2rem;">→</div>
  <div style="background: #1A3A4A; color: white; border-radius: 5px; padding: 0.35rem 0.6rem; font-size: 0.82rem;"><strong>assistant</strong><br><span style="color: #A8D5C2; font-size: 0.75rem;">tool_use or end_turn</span></div>
</div>
</v-click>

<div style="display: flex; gap: 0.75rem; margin-top: 0.5rem;">
  <v-click>
  <div style="flex: 1; background: white; border: 1px solid #c8e6d0; border-radius: 6px; padding: 0.6rem 0.8rem; font-size: 0.88rem;">
    <div style="font-weight: 700; color: #1A3A4A; margin-bottom: 0.3rem;">Why alternating user/assistant?</div>
    Tool results are framed as <strong>user</strong> messages because they represent information coming <em>from</em> the external environment <em>to</em> Claude. The API enforces strict turn order.
  </div>
  </v-click>
  <v-click>
  <div style="flex: 1; background: #FFF0F0; border: 1px solid #ffc8c8; border-radius: 6px; padding: 0.6rem 0.8rem; font-size: 0.88rem;">
    <div style="font-weight: 700; color: #E53E3E; margin-bottom: 0.3rem;">API Rejection</div>
    Violating turn order (e.g., two consecutive assistant messages) will cause the API to <strong>reject the request</strong>. The alternating pattern is enforced.
  </div>
  </v-click>
</div>

</div>

<img src="/logo.png" class="di-logo" />

<!--
The conversation history is how Claude maintains context across an agentic loop.

Every message matters. Claude uses the full history to understand what it's already tried, what the results were, and what to do next.

[click] The pattern for the history looks like this: a user message (the initial request), followed by an assistant message containing tool_use blocks, followed by a user message containing the corresponding tool results, followed by the next assistant response.

This alternating pattern — user, assistant, user, assistant — must be maintained. The API will reject requests that violate turn order.

The tool results are framed as user messages because they represent information coming from the external environment to Claude.
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
<div class="di-exam-subtitle">Tool Result Message Role</div>

<div class="di-exam-body">
  The exam tests whether you know the correct message <strong>role</strong> for tool results.
  Two traps to watch for:
</div>
</v-click>

<v-click>
<div class="di-trap-box">
  <div class="di-trap-label">❌ Trap 1 — Wrong Role</div>
  Sending tool results as <code>assistant</code> messages.<br>
  <em>Feels intuitive</em> ("I ran Claude's tool, so I'm sending back to Claude") but is wrong — message structure is from Claude's perspective. Tool results come from the outside world → <strong>user</strong> role.
</div>
</v-click>

<v-click>
<div class="di-trap-box" style="margin-top: 0.5rem;">
  <div class="di-trap-label">❌ Trap 2 — Partial Results</div>
  Sending only some of the batch and expecting Claude to work with partial information.
  Always send <strong>all tool results</strong> in one user message before calling the API again.
</div>
</v-click>

<v-click>
<div class="di-correct-box" style="margin-top: 0.5rem;">
  <div class="di-correct-label">✓ Rule</div>
  Tool results go in <strong>user</strong> messages. All results from one response → one combined user message.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
The exam will test whether you know the correct message role for tool results.

Tool results go in user messages — not assistant messages.

This trips candidates up because intuitively, "I just ran Claude's tool, so I'm sending back to Claude" feels like the assistant providing output. But the message structure is from Claude's perspective: user messages are what Claude receives from the outside world.

A second exam trap: sending incomplete tool results (only some of the batch) and expecting Claude to work with partial information. Always send all tool results in one user message before calling the API again.
-->

---
layout: default
class: di-takeaway-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 8 — Key Takeaways
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-takeaway-title">tool_use vs end_turn — Control Flow</div>

<ul class="di-takeaway-list">
  <v-click><li><strong>"tool_use" path:</strong> extract blocks → execute tools → append both assistant msg AND tool results → loop</li></v-click>
  <v-click><li><strong>"end_turn" path:</strong> do not loop — inspect content to understand completion state, then return</li></v-click>
  <v-click><li>Tool results belong in <strong>user</strong> messages (not assistant messages)</li></v-click>
  <v-click><li>Multiple tool calls in one response → process all, send one combined user message</li></v-click>
  <v-click><li><strong>Model-driven routing:</strong> Claude decides tool order — use for flexible workflows</li></v-click>
  <v-click><li><strong>Programmatic enforcement:</strong> your code enforces order — use for hard constraints (safety, workflow requirements)</li></v-click>
</ul>

<img src="/logo.png" class="di-logo" style="opacity: 0.75;" />

<!--
To summarize the control flow patterns:

The "tool_use" path: extract blocks, execute tools, append both the assistant message AND tool results, then loop.

The "end_turn" path: do not loop. Inspect content to understand completion state, then return.

Tool results belong in user messages — not assistant messages.

Multiple tool calls in one response: process all of them, send one combined user message.

Model-driven routing — Claude decides tool order — for flexible workflows. Programmatic enforcement — your code enforces order — for hard constraints like safety and workflow requirements.
-->
