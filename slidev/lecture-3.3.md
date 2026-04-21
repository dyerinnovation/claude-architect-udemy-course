---
theme: default
title: "Lecture 3.3: Anti-Patterns: What NOT to Do in Agentic Loops"
info: |
  Claude Certified Architect – Foundations
  Section 3 — Agentic Architecture & Orchestration (Domain 1, 27%)
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
const takeawayBullets = [
  { label: '1. Text parsing for completion', detail: 'Use stop_reason, not response content text.' },
  { label: '2. Iteration caps as primary exit', detail: 'Use while True + break on end_turn; caps are safety guards only.' },
  { label: '3. Skipping tool result appending', detail: 'Always append BOTH the assistant msg AND the tool results.' },
  { label: '4. Stopping on tool errors', detail: 'Append errors as is_error: true tool_results and let Claude reason.' },
  { label: '5. Tool results in assistant messages', detail: 'Tool results belong in USER role messages.' },
]

// Anti-pattern 1: text parsing
const ap1Bad = `# Inspecting text to decide when to stop
if "task complete" in response.content[0].text:
    break`
const ap1Good = `# Use the structured signal the API already gives you
if response.stop_reason == "end_turn":
    break`

// Anti-pattern 2: iteration caps
const ap2Bad = `# Cap as PRIMARY exit — silent partial result if hit
for attempt in range(10):
    response = call_api()
    if done:
        break`
const ap2Good = `# Cap as SAFETY guard — loop exits on end_turn
while True:
    response = call_api()
    if response.stop_reason == "end_turn":
        break
    if iterations > MAX:
        raise AgentLoopError("Max iterations exceeded")`

// Anti-pattern 3: skipping tool_result append
const ap3Bad = `Broken loop — tool results never appended

User
  -> Assistant (tool_use block)
    -> NEXT API CALL  (no tool_results in history)

Claude has no memory of what the tool returned.
It repeats the call, or invents an answer.`
const ap3Good = `Correct loop — tool results appended as a USER message

User
  -> Assistant (tool_use block)
    -> User (tool_result blocks, matching tool_use_id)
      -> NEXT API CALL`

// Anti-pattern 4: tool errors terminate loop
const ap4Bad = `Stop the loop on the first tool error

Tool call executes
  -> Tool returns error
    -> Terminate loop
      -> Return error to user

Claude never gets a chance to recover.`
const ap4Good = `Pass the error to Claude — let it reason

Tool call executes
  -> Tool returns error
    -> Append as tool_result with is_error: true
      -> Continue the loop

Claude can retry, pivot, or explain.`

// Anti-pattern 5: tool_result in wrong role
const ap5Bad = `// Tool result inside an assistant message
{
  "role": "assistant",
  "content": [
    {
      "type": "tool_result",
      "tool_use_id": "toolu_01ABC",
      "content": "Seattle: 58\u00B0F"
    }
  ]
}`
const ap5Good = `// Tool result inside a USER message
{
  "role": "user",
  "content": [
    {
      "type": "tool_result",
      "tool_use_id": "toolu_01ABC",
      "content": "Seattle: 58\u00B0F"
    }
  ]
}`

// Exam tip: summary
const examTipBad = `Common wrong answers the exam plants

- Parsing response text for 'done' / 'complete'
- for-loop with a fixed cap as the primary exit
- Skipping the tool_result append step
- Terminating the loop on a tool error
- Tool results inside assistant messages`
const examTipGood = `Decision rule

If you're stuck between two answers, ask:
which one reads stop_reason AND follows
the message-structure contract?
That's the right answer.`
</script>

<!-- SLIDE 1 — Cover -->

<Frame bg="var(--forest-900)" color="var(--mint-100)" :pad="false">
  <div style="position:absolute; inset:0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%);" />
  <div style="position:relative; z-index:1; padding:110px 120px 96px; width:100%; height:100%; display:flex; flex-direction:column; justify-content:space-between;">
    <div style="display:flex; align-items:center; gap:24px;">
      <img src="/assets/logo-mark.png" alt="" style="width:72px; height:auto;" />
      <div style="font-family: var(--font-body); font-size:26px; font-weight:500; letter-spacing:0.14em; text-transform:uppercase; color: var(--mint-200);">Dyer Innovation</div>
    </div>
    <div>
      <div style="font-family: var(--font-body); font-size:26px; font-weight:600; letter-spacing:0.16em; text-transform:uppercase; color: var(--sprout-500); margin-bottom:40px;">Domain 1 &middot; Lecture 3.3</div>
      <h1 style="font-family: var(--font-display); font-weight:500; font-size:128px; line-height:1.02; letter-spacing:-0.025em; color: var(--paper-0); margin:0; max-width:1500px;">
        Anti-Patterns
      </h1>
      <div style="font-family: var(--font-display); font-size:44px; color: var(--mint-200); margin-top:40px; font-weight:400; max-width:1200px; line-height:1.3;">
        What NOT to do in agentic loops — five ways it breaks.
      </div>
    </div>
    <div style="display:flex; align-items:center; gap:48px; font-family: var(--font-body); font-size:26px; color: var(--mint-200); letter-spacing:0.06em;">
      <span>Lecture 3.3</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>~8 min</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>8 slides</span>
    </div>
  </div>
</Frame>

<!--
You've seen the correct agentic loop pattern. Now let's look at the ways it breaks — because the exam is filled with questions where the wrong answer is one of these anti-patterns. These aren't edge cases. They're common intuitions that feel correct but aren't. Understanding why each one fails is what separates a candidate who understands the loop from one who merely memorized it.
-->

---

<!-- SLIDE 2 — Anti-Pattern 1: text parsing -->

<AntiPatternSlide
  eyebrow="Anti-Pattern 1"
  title="Parsing Text to Detect Completion"
  lang="python"
  :badExample="ap1Bad"
  whyItFails="Claude's text is non-deterministic — it may phrase completion differently or not at all. stop_reason is a structured API contract — always present, always precise. Text-parsing a structured signal is like checking email subject lines instead of HTTP status codes."
  :fixExample="ap1Good"
  footerLabel="Lecture 3.3"
  :footerNum="2"
  :footerTotal="8"
/>

<!--
The first and most common anti-pattern: inspecting the response text to decide whether the loop should continue. Something like this: if "I've completed your task" in response.text: break. This is wrong for two reasons. First, Claude's text output is non-deterministic. It might say "task complete" in different words each time, or not say it at all. Second, stop_reason is a structured API contract. It's always present, always precise, and always one of a defined set of values. It's designed specifically to communicate termination state. Using text parsing to replace a structured API signal is like checking email subject lines instead of HTTP status codes. The signal exists — use it.
-->

---

<!-- SLIDE 3 — Anti-Pattern 2: iteration caps as primary exit -->

<AntiPatternSlide
  eyebrow="Anti-Pattern 2"
  title="Using Iteration Caps as the Primary Exit"
  lang="python"
  :badExample="ap2Bad"
  whyItFails="If the cap is reached before the task completes, you silently return a partial result. No error, no signal — the caller doesn't know why the loop ended. Caps are safety guards, not primary exits."
  :fixExample="ap2Good"
  footerLabel="Lecture 3.3"
  :footerNum="3"
  :footerTotal="8"
/>

<!--
The second anti-pattern: using a for loop with a hard cap on iterations as the primary exit mechanism. Something like: for attempt in range(10): ... if done: break. The problem is subtle. Iteration caps aren't wrong as safety guards. What's wrong is using them as the primary control signal. If the cap is reached before the task completes, you silently return a partial result. There's no error. No signal. The caller doesn't know why the loop ended. The correct pattern: use while True with break on end_turn. Add an iteration cap as a safety guard with explicit error handling — something like if iterations > MAX: raise AgentLoopError. The difference is intent: the loop is designed to exit on end_turn, and the cap is a failsafe for runaway loops.
-->

---

<!-- SLIDE 4 — Anti-Pattern 3: skipping tool result append -->

<AntiPatternSlide
  eyebrow="Anti-Pattern 3"
  title="Skipping Tool Result Appending"
  lang="text"
  :badExample="ap3Bad"
  whyItFails="Claude has no side channel to your tool execution environment. It only knows what's in the message history. If you don't append the result, it's as if the tool never ran."
  :fixExample="ap3Good"
  footerLabel="Lecture 3.3"
  :footerNum="4"
  :footerTotal="8"
/>

<!--
Anti-pattern three: making the next API call without appending the tool results to the conversation history. Claude receives the next request. It has no memory of what the tool returned. So it either repeats the same tool call, or invents an answer based on what it thinks the tool probably returned. This happens when developers miss that tool results are sent as user messages. It's easy to forget because it feels redundant — you're the one who ran the tool, so why tell Claude what it returned? Because Claude doesn't have a side channel to your tool execution environment. It only knows what's in the message history. If you don't append the result, it's as if the tool never ran.
-->

---

<!-- SLIDE 5 — Anti-Pattern 4: treating tool errors as end_turn -->

<AntiPatternSlide
  eyebrow="Anti-Pattern 4"
  title="Treating Tool Errors as end_turn"
  lang="text"
  :badExample="ap4Bad"
  whyItFails="Stopping on the first tool error collapses the agent's ability to recover. Claude can try a different tool, try different arguments, or acknowledge the error and explain it. The exam tests this with tools that fail partway through a workflow."
  :fixExample="ap4Good"
  footerLabel="Lecture 3.3"
  :footerNum="5"
  :footerTotal="8"
/>

<!--
Anti-pattern four: stopping the agentic loop when a tool returns an error. When a tool fails, the instinct is to terminate — return an error to the user, stop looping. But that ignores something powerful: Claude can reason about errors. The correct approach: append the tool error as a tool_result with is_error: true in the content. Let Claude see what went wrong. Claude may decide to try a different tool, try different arguments, or acknowledge the error and explain it to the user. Stopping on the first tool error collapses the agent's ability to recover. The exam will test this in scenarios where a tool fails partway through a multi-step workflow.
-->

---

<!-- SLIDE 6 — Anti-Pattern 5: tool results in wrong role -->

<AntiPatternSlide
  eyebrow="Anti-Pattern 5"
  title="Tool Results in the Wrong Role"
  lang="json"
  :badExample="ap5Bad"
  whyItFails="Tool results are information from the external environment TO Claude → user role. The API may reject the request outright, or the conversation history becomes structurally invalid."
  :fixExample="ap5Good"
  footerLabel="Lecture 3.3"
  :footerNum="6"
  :footerTotal="8"
/>

<!--
This one catches candidates who understand the loop conceptually but haven't implemented it carefully. Tool results must be sent in user role messages. Not assistant messages. The API will reject a tool_result block inside an assistant message, but the more dangerous failure is a malformed request that gets silently ignored. The conversation history becomes structurally invalid. Remember: from Claude's perspective, user messages represent information coming from the external environment. Tool results are exactly that — data from outside Claude, delivered back into the conversation. They belong in user messages.
-->

---

<!-- SLIDE 7 — Exam Tip: anti-patterns as distractors -->

<AntiPatternSlide
  eyebrow="⚡ Exam Tip"
  title="Anti-Patterns as Distractors"
  lang="text"
  :badExample="examTipBad"
  whyItFails="Every anti-pattern in this lecture appears as a distractor somewhere on the exam. When you see an answer doing one of these things, it's wrong."
  :fixExample="examTipGood"
  footerLabel="Lecture 3.3"
  :footerNum="7"
  :footerTotal="8"
/>

<!--
Every anti-pattern in this lecture appears as a distractor somewhere in the practice exam. When you see an answer choice that parses response text, uses a for loop with a cap, skips tool result appending, stops on tool errors, or puts tool results in an assistant message — it's wrong. The exam is testing whether you can recognize the pattern, not just recall the rules. If you're stuck between two choices, ask: which one reads stop_reason and follows the message structure contract? That's the right answer.
-->

---

<!-- SLIDE 8 — Takeaways -->

<BulletReveal
  eyebrow="Takeaway"
  title="The 5 Agentic Loop Anti-Patterns"
  :bullets="takeawayBullets"
  footerLabel="Lecture 3.3"
  :footerNum="8"
  :footerTotal="8"
/>

<!--
Five anti-patterns to recognize on sight. One: text parsing for completion — use stop_reason, not response content. Two: iteration caps as primary exit — use while True with break on end_turn; caps are safety guards only. Three: skipping tool result appending — always append both the assistant message and the tool results. Four: stopping on tool errors — append errors as is_error: true tool_results and let Claude reason. Five: tool results in assistant messages — tool results belong in user role messages.
-->
