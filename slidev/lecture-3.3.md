---
theme: default
title: "Lecture 3.3: Anti-Patterns: What NOT to Do in Agentic Loops"
info: |
  Claude Certified Architect – Foundations
  Section 3: Domain 1 — Agentic Architecture & Orchestration (27%)
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
  <div class="di-course-label">Claude Certified Architect – Foundations</div>
  <div class="di-cover-title">Anti-Patterns:<br>What NOT to Do in Agentic Loops</div>
  <div class="di-cover-subtitle">Lecture 3.3 · Domain 1 — Agentic Architecture & Orchestration (27%)</div>
</div>

<img src="/logo.png" class="di-logo-centered" />

<!--
You've seen the correct agentic loop pattern.

Now let's look at the ways it breaks — because the exam is filled with questions where the wrong answer is one of these anti-patterns.

These aren't edge cases. They're common intuitions that feel correct but aren't.

Understanding why each one fails is what separates a candidate who understands the loop from one who merely memorized it.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 2 — Anti-Pattern 1: Parsing Text to Detect Completion
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Anti-Pattern 1 — Parsing Text to Detect Completion</div>

<div class="di-body" style="margin-top: 0.5rem;">

<v-click>
<p>The most common anti-pattern: inspecting response text to decide whether the loop should continue.</p>
</v-click>

<v-click>
<div style="display: flex; gap: 1rem; margin-top: 0.5rem; align-items: flex-start;">
  <div style="flex: 1; background: #FFF0F0; border: 2px solid #E53E3E; border-radius: 6px; padding: 0.6rem 0.8rem;">
    <div style="font-weight: 700; color: #E53E3E; margin-bottom: 0.4rem; font-size: 0.85rem;">❌ ANTI-PATTERN</div>

```python
if "task complete" in response.content[0].text:
    break
```

  </div>
  <div style="flex: 1; background: #F0FFF4; border: 2px solid #3CAF50; border-radius: 6px; padding: 0.6rem 0.8rem;">
    <div style="font-weight: 700; color: #1B8A5A; margin-bottom: 0.4rem; font-size: 0.85rem;">✓ CORRECT</div>

```python
if response.stop_reason == "end_turn":
    break
```

  </div>
</div>
</v-click>

<v-click>
<div class="di-step-card" style="margin-top: 0.75rem; border-left-color: #E53E3E;">
  <span class="di-step-num" style="color: #E53E3E;">Why it fails #1</span>
  Claude's text output is non-deterministic — it may phrase completion differently each time, or not at all
</div>
</v-click>

<v-click>
<div class="di-step-card" style="border-left-color: #0D7377;">
  <span class="di-step-num" style="color: #0D7377;">Why it fails #2</span>
  <code class="di-code-inline">stop_reason</code> is a structured API contract — always present, always precise, always one of a defined set of values. It <em>exists</em> for this purpose.
</div>
</v-click>

<v-click>
<div style="background: #FFF8E6; border-left: 3px solid #E3A008; padding: 0.5rem 0.8rem; border-radius: 4px; font-size: 0.88rem;">
  Using text parsing to replace a structured API signal is like checking email subject lines instead of HTTP status codes. The signal exists — use it.
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
The first and most common anti-pattern: inspecting the response text to decide whether the loop should continue.

Something like this: if "I've completed your task" in response.text: break.

This is wrong for two reasons.

First, Claude's text output is non-deterministic. It might say "task complete" in different words each time, or not say it at all.

Second, stop_reason is a structured API contract. It's always present, always precise, and always one of a defined set of values. It's designed specifically to communicate termination state.

Using text parsing to replace a structured API signal is like checking email subject lines instead of HTTP status codes. The signal exists — use it.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 3 — Anti-Pattern 2: Iteration Caps as Primary Exit
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Anti-Pattern 2 — Using Iteration Caps as the Primary Exit</div>

<div class="di-body" style="margin-top: 0.5rem;">

<v-click>
<p>The second anti-pattern: a <code class="di-code-inline">for</code> loop with a hard cap on iterations as the <strong>primary</strong> exit mechanism.</p>
</v-click>

<v-click>
<div style="display: flex; gap: 1rem; margin-top: 0.4rem; align-items: flex-start;">
  <div style="flex: 1; background: #FFF0F0; border: 2px solid #E53E3E; border-radius: 6px; padding: 0.6rem 0.8rem;">
    <div style="font-weight: 700; color: #E53E3E; margin-bottom: 0.4rem; font-size: 0.85rem;">❌ Cap as Primary Exit</div>

```python
for attempt in range(10):
    response = call_api()
    if done: break
# Silent partial result if cap reached
```

  </div>
  <div style="flex: 1; background: #F0FFF4; border: 2px solid #3CAF50; border-radius: 6px; padding: 0.6rem 0.8rem;">
    <div style="font-weight: 700; color: #1B8A5A; margin-bottom: 0.4rem; font-size: 0.85rem;">✓ Cap as Safety Guard</div>

```python
while True:
    response = call_api()
    if response.stop_reason == "end_turn": break
    if iterations > MAX:
        raise AgentLoopError("Max exceeded")
```

  </div>
</div>
</v-click>

<v-click>
<div class="di-step-card" style="margin-top: 0.75rem; border-left-color: #E53E3E;">
  <span class="di-step-num" style="color: #E53E3E;">The problem</span>
  If the cap is reached before the task completes, you silently return a partial result. No error. No signal. The caller doesn't know why the loop ended.
</div>
</v-click>

<v-click>
<div class="di-step-card" style="border-left-color: #1B8A5A;">
  <span class="di-step-num" style="color: #1B8A5A;">The rule</span>
  Iteration caps are <strong>safety guards</strong> — not primary exits. The loop is <em>designed</em> to exit on <code class="di-code-inline">end_turn</code>. The cap is a failsafe for runaway loops, and must raise an explicit error when triggered.
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
The second anti-pattern: using a for loop with a hard cap on iterations as the primary exit mechanism.

Something like: for attempt in range(10): ... if done: break.

The problem is subtle. Iteration caps aren't wrong as safety guards. What's wrong is using them as the primary control signal.

If the cap is reached before the task completes, you silently return a partial result. There's no error. No signal. The caller doesn't know why the loop ended.

The correct pattern: use while True with break on "end_turn". Add an iteration cap as a safety guard with explicit error handling — something like if iterations > MAX: raise AgentLoopError("Max iterations exceeded"). The difference is intent: the loop is designed to exit on end_turn, and the cap is a failsafe for runaway loops.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 4 — Anti-Pattern 3: Skipping Tool Result Appending
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Anti-Pattern 3 — Skipping Tool Result Appending</div>

<div class="di-body" style="margin-top: 0.5rem;">

<v-click>
<p>Making the next API call without appending tool results to the conversation history.</p>
</v-click>

<v-click>
<div style="display: flex; align-items: stretch; gap: 1rem; margin-top: 0.5rem;">

  <div style="flex: 1; display: flex; flex-direction: column; align-items: center; gap: 0.2rem;">
    <div style="font-weight: 700; color: #E53E3E; font-size: 0.85rem; margin-bottom: 0.2rem;">❌ Broken Loop</div>
    <div class="di-flow-box" style="width: 100%; font-size: 0.82rem;">User message</div>
    <div class="di-arrow">↓</div>
    <div class="di-flow-tool" style="width: 100%; font-size: 0.82rem;">Assistant (tool_use)</div>
    <div class="di-arrow">↓</div>
    <div style="background: #E53E3E; color: white; border-radius: 6px; padding: 0.4rem 0.8rem; width: 100%; text-align: center; font-size: 0.8rem;">Next API call<br><em>— no tool results —</em></div>
  </div>

  <div style="flex: 1; display: flex; flex-direction: column; align-items: center; gap: 0.2rem;">
    <div style="font-weight: 700; color: #1B8A5A; font-size: 0.85rem; margin-bottom: 0.2rem;">✓ Correct Loop</div>
    <div class="di-flow-box" style="width: 100%; font-size: 0.82rem;">User message</div>
    <div class="di-arrow">↓</div>
    <div class="di-flow-tool" style="width: 100%; font-size: 0.82rem;">Assistant (tool_use)</div>
    <div class="di-arrow">↓</div>
    <div style="background: #1B8A5A; color: white; border-radius: 6px; padding: 0.4rem 0.8rem; width: 100%; text-align: center; font-size: 0.8rem;">User (tool_results)</div>
    <div class="di-arrow">↓</div>
    <div class="di-flow-stop" style="width: 100%; font-size: 0.82rem;">Next API call</div>
  </div>

</div>
</v-click>

<v-click>
<div class="di-step-card" style="margin-top: 0.75rem; border-left-color: #E53E3E;">
  <span class="di-step-num" style="color: #E53E3E;">What happens</span>
  Claude receives the next request with no memory of what the tool returned. It either repeats the same tool call, or invents an answer based on what it thinks the tool probably returned.
</div>
</v-click>

<v-click>
<div style="background: #FFF8E6; border-left: 3px solid #E3A008; padding: 0.5rem 0.8rem; border-radius: 4px; font-size: 0.88rem;">
  Claude has no side channel to your tool execution environment. It only knows what's in the message history. If you don't append the result, it's as if the tool never ran.
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
Anti-pattern three: making the next API call without appending the tool results to the conversation history.

Claude receives the next request. It has no memory of what the tool returned. So it either repeats the same tool call, or invents an answer based on what it thinks the tool probably returned.

This happens when developers miss that tool results are sent as user messages. It's easy to forget because it feels redundant — you're the one who ran the tool, so why tell Claude what it returned?

Because Claude doesn't have a side channel to your tool execution environment. It only knows what's in the message history. If you don't append the result, it's as if the tool never ran.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 5 — Anti-Pattern 4: Treating Tool Errors as end_turn
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Anti-Pattern 4 — Treating Tool Errors as end_turn</div>

<div class="di-body" style="margin-top: 0.5rem;">

<v-click>
<p>Stopping the agentic loop when a tool returns an error.</p>
</v-click>

<v-click>
<div style="display: flex; gap: 1rem; margin-top: 0.5rem; align-items: flex-start;">

  <div style="flex: 1;">
    <div style="font-weight: 700; color: #E53E3E; font-size: 0.85rem; margin-bottom: 0.4rem;">❌ Stop on Error</div>
    <div class="di-flow-box" style="font-size: 0.82rem; margin-bottom: 0.2rem;">Tool call executes</div>
    <div class="di-arrow">↓</div>
    <div style="background: #E53E3E; color: white; border-radius: 6px; padding: 0.4rem 0.8rem; text-align: center; font-size: 0.82rem;">Tool returns error<br>→ Terminate loop<br>→ Return error to user</div>
  </div>

  <div style="flex: 1;">
    <div style="font-weight: 700; color: #1B8A5A; font-size: 0.85rem; margin-bottom: 0.4rem;">✓ Pass Error to Claude</div>
    <div class="di-flow-box" style="font-size: 0.82rem; margin-bottom: 0.2rem;">Tool call executes</div>
    <div class="di-arrow">↓</div>
    <div style="background: #1B8A5A; color: white; border-radius: 6px; padding: 0.4rem 0.8rem; text-align: center; font-size: 0.82rem;">Tool returns error<br>→ Append as <code style="color: #A8D5C2;">is_error: true</code><br>→ Let Claude reason</div>
  </div>

</div>
</v-click>

<v-click>
<div class="di-step-card" style="margin-top: 0.75rem; border-left-color: #0D7377;">
  <span class="di-step-num" style="color: #0D7377;">What Claude can do with an error</span>
  Try a different tool, try different arguments, acknowledge the error and explain it to the user — Claude can reason about failures.
</div>
</v-click>

<v-click>
<div style="background: #FFF8E6; border-left: 3px solid #E3A008; padding: 0.5rem 0.8rem; border-radius: 4px; font-size: 0.88rem;">
  <strong>Exam note:</strong> Stopping on the first tool error collapses the agent's ability to recover. Expect scenarios on the exam where a tool fails partway through a multi-step workflow.
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
Anti-pattern four: stopping the agentic loop when a tool returns an error.

When a tool fails, the instinct is to terminate — return an error to the user, stop looping.

But that ignores something powerful: Claude can reason about errors.

The correct approach: append the tool error as a tool_result with is_error: true in the content. Let Claude see what went wrong. Claude may decide to try a different tool, try different arguments, or acknowledge the error and explain it to the user.

Stopping on the first tool error collapses the agent's ability to recover. The exam will test this in scenarios where a tool fails partway through a multi-step workflow.
-->

---
layout: two-cols
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 6 — Anti-Pattern 5: Tool Results as Assistant Messages
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header" style="margin: -1.5rem -1rem 1rem -2rem; padding-right: 1rem;">Anti-Pattern 5 — Tool Results in the Wrong Role</div>

<v-click>
<div style="padding-right: 1.2rem;">
  <div class="di-col-left-label">❌ Wrong — assistant role</div>
  <div class="di-col-body">

```json
{
  "role": "assistant",
  "content": [{
    "type": "tool_result",
    "tool_use_id": "toolu_01ABC",
    "content": "Seattle: 58°F"
  }]
}
```

  <div class="di-col-warning" style="margin-top: 0.5rem;">
    <strong>Result:</strong> API rejection or structurally invalid conversation history
  </div>
  </div>
</div>
</v-click>

::right::

<v-click>
<div style="padding-left: 1.2rem; padding-top: 5rem;">
  <div class="di-col-right-label">✓ Correct — user role</div>
  <div class="di-col-body">

```json
{
  "role": "user",
  "content": [{
    "type": "tool_result",
    "tool_use_id": "toolu_01ABC",
    "content": "Seattle: 58°F"
  }]
}
```

  <div style="margin-top: 0.5rem; background: #E8F5EB; border-radius: 4px; padding: 0.4rem 0.6rem; font-size: 0.88rem;">
    Tool results = information from the external environment <em>to</em> Claude → <strong>user</strong> role
  </div>
  </div>
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
This one catches candidates who understand the loop conceptually but haven't implemented it carefully.

Tool results must be sent in user role messages. Not assistant messages.

The API will reject a tool_result block inside an assistant message, but the more dangerous failure is a malformed request that gets silently ignored. The conversation history becomes structurally invalid.

Remember: from Claude's perspective, user messages represent information coming from the external environment. Tool results are exactly that — data from outside Claude, delivered back into the conversation. They belong in user messages.
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
<div class="di-exam-subtitle">Anti-Patterns as Distractors</div>

<div class="di-exam-body">
  Every anti-pattern in this lecture appears as a distractor somewhere in the practice exam. The exam is testing whether you can <strong>recognize the pattern</strong>, not just recall the rules.
</div>
</v-click>

<v-click>
<div class="di-trap-box">
  <div class="di-trap-label">❌ If You See Any of These in an Answer Choice — It's Wrong</div>
  <ul style="margin: 0; padding-left: 1.2rem; font-size: 0.9rem;">
    <li>Parsing response text for words like "done" or "complete"</li>
    <li>A <code>for</code> loop with a fixed cap as the primary exit mechanism</li>
    <li>API call made without appending tool results to conversation history</li>
    <li>Loop terminates when a tool returns an error</li>
    <li>Tool results sent as <code>assistant</code> role messages</li>
  </ul>
</div>
</v-click>

<v-click>
<div class="di-correct-box">
  <div class="di-correct-label">✓ The Decision Rule</div>
  If you're stuck between two choices, ask: which one reads <code class="di-code-inline">stop_reason</code> and follows the message structure contract?<br>That's the right answer.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Every anti-pattern in this lecture appears as a distractor somewhere in the practice exam.

When you see an answer choice that parses response text, uses a for loop with a cap, skips tool result appending, stops on tool errors, or puts tool results in an assistant message — it's wrong.

The exam is testing whether you can recognize the pattern, not just recall the rules.

If you're stuck between two choices, ask: which one reads stop_reason and follows the message structure contract? That's the right answer.
-->

---
layout: default
class: di-takeaway-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 8 — Key Takeaways
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-takeaway-title">The 5 Agentic Loop Anti-Patterns</div>

<ul class="di-takeaway-list">
  <v-click><li><strong>Text parsing for completion</strong> — use <code style="color: #A8D5C2;">stop_reason</code>, not response content</li></v-click>
  <v-click><li><strong>Iteration caps as primary exit</strong> — use <code style="color: #A8D5C2;">while True</code> + break on <code style="color: #A8D5C2;">end_turn</code>; caps are safety guards only</li></v-click>
  <v-click><li><strong>Skipping tool result appending</strong> — always append BOTH the assistant message AND the tool results</li></v-click>
  <v-click><li><strong>Stopping on tool errors</strong> — append errors as <code style="color: #A8D5C2;">is_error: true</code> tool_results and let Claude reason</li></v-click>
  <v-click><li><strong>Tool results in assistant messages</strong> — tool results belong in <strong>user</strong> role messages</li></v-click>
</ul>

<img src="/logo.png" class="di-logo" style="opacity: 0.75;" />

<!--
To summarize the five agentic loop anti-patterns:

Text parsing for completion — use stop_reason, not response content.

Iteration caps as primary exit — use while True plus break on end_turn. Caps are safety guards only, and must raise explicit errors when triggered.

Skipping tool result appending — always append BOTH the assistant message AND the tool results before the next API call.

Stopping on tool errors — append errors as is_error: true tool_results and let Claude reason about recovery.

Tool results in assistant messages — tool results belong in user role messages, always.
-->
