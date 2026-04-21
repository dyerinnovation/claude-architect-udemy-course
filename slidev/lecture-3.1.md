---
theme: default
title: "Lecture 3.1: The Agentic Loop: stop_reason Is Everything"
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
const tuBullets = [
  { label: 'tool_use →', detail: 'Keep going. Execute the tool, append the result, and send the next request.' },
  { label: 'end_turn →', detail: 'Stop. Return the response to the user.' },
]

const fieldBullets = [
  { label: 'type', detail: "Always 'tool_use' — identifies this block in the content array." },
  { label: 'name', detail: 'Which tool Claude selected from the set you provided.' },
  { label: 'input', detail: 'The arguments Claude decided to pass to the tool.' },
  { label: 'id  ⚠', detail: 'Echo it back on the tool_result — matches each result to its request.' },
]

const appendSteps = [
  { number: 'Step 1', title: 'Append the assistant response', body: 'Append the full assistant response (including the tool_use block) to the messages array.' },
  { number: 'Step 2', title: 'Append a user tool_result', body: 'Append a USER message with tool_result blocks — each needs tool_use_id, content, and is_error.' },
  { number: 'Step 3', title: 'Call the API with full history', body: 'Make the next API call with the FULL updated messages array — nothing else.' },
]

const takeawayBullets = [
  { label: "stop_reason='tool_use' → continue", detail: 'Execute the tool, append the result, and loop back.' },
  { label: "stop_reason='end_turn' → stop", detail: 'Return the response to the user.' },
  { label: 'Always append BOTH', detail: 'Assistant message AND tool result before the next call.' },
  { label: 'while True + explicit break', detail: 'Claude drives termination, not a counter.' },
  { label: 'Never inspect text content', detail: 'Do not use the response text to decide whether to keep looping.' },
  { label: 'Foundational pattern', detail: 'This is the pattern behind every scenario on the exam — master it first.' },
]

const examTipBad = `# Distractors the exam plants

if 'done' in response.content[0].text:
    break

for attempt in range(10):      # cap as PRIMARY exit
    ...

if any(b.type == 'tool_use' for b in response.content):
    continue                    # inspecting content instead of stop_reason`

const examTipGood = `# The only correct pattern

if response.stop_reason == 'end_turn':
    break
elif response.stop_reason == 'tool_use':
    # execute tools, append results, continue
    ...`

const loopCode = `messages = [{"role": "user", "content": initial_prompt}]

while True:
    response = client.messages.create(
        model="claude-opus-4-7",
        tools=tools,
        messages=messages
    )

    # Exit condition — always check stop_reason first
    if response.stop_reason == "end_turn":
        break

    # Continuation condition
    if response.stop_reason == "tool_use":
        tool_results = execute_tools(response.content)
        messages.append({"role": "assistant", "content": response.content})
        messages.append({"role": "user", "content": tool_results})
        # Loop continues`
</script>

<!-- ═══════════════════════════════════════════════════════════════════
     SLIDE 1 — Cover
     ═══════════════════════════════════════════════════════════════ -->

<Frame bg="var(--forest-900)" color="var(--mint-100)" :pad="false">
  <div style="position:absolute; inset:0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%);" />
  <div style="position:relative; z-index:1; padding:110px 120px 96px; width:100%; height:100%; display:flex; flex-direction:column; justify-content:space-between;">
    <div style="display:flex; align-items:center; gap:24px;">
      <img src="/assets/logo-mark.png" alt="" style="width:72px; height:auto;" />
      <div style="font-family: var(--font-body); font-size:26px; font-weight:500; letter-spacing:0.14em; text-transform:uppercase; color: var(--mint-200);">Dyer Innovation</div>
    </div>
    <div>
      <div style="font-family: var(--font-body); font-size:26px; font-weight:600; letter-spacing:0.16em; text-transform:uppercase; color: var(--sprout-500); margin-bottom:40px;">Domain 1 &middot; Lecture 3.1</div>
      <h1 style="font-family: var(--font-display); font-weight:500; font-size:128px; line-height:1.02; letter-spacing:-0.025em; color: var(--paper-0); margin:0; max-width:1500px;">
        The Agentic Loop:<br /><span style="color: var(--sprout-500);">stop_reason</span> Is Everything
      </h1>
      <div style="font-family: var(--font-display); font-size:44px; color: var(--mint-200); margin-top:40px; font-weight:400; max-width:1200px; line-height:1.3;">
        Domain 1 · Agentic Architecture & Orchestration (27%)
      </div>
    </div>
    <div style="display:flex; align-items:center; gap:48px; font-family: var(--font-body); font-size:26px; color: var(--mint-200); letter-spacing:0.06em;">
      <span>Lecture 3.1</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>~9 min</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>8 slides</span>
    </div>
  </div>
</Frame>

<!--
Here's the fundamental question you must answer when building any agentic system with Claude. How does Claude communicate to your code whether it's done — or whether it needs you to do something first? The answer is a single field in every API response: stop_reason. Get this wrong, and your agent either terminates before it finishes, or loops forever. There is no middle ground.
-->

---

<!-- SLIDE 2 — What the Agentic Loop Looks Like -->

<TwoColSlide
  variant="compare"
  title="What the Agentic Loop Looks Like"
  leftLabel="Flow"
  rightLabel="What stop_reason tells you"
  footerLabel="Lecture 3.1"
  :footerNum="2"
  :footerTotal="8"
>
<template #left>

1. **Send request** to Claude with tools + messages.
2. **Check `stop_reason`** on the response.
3. Branch:
   - **`tool_use`** → execute tool, append result, loop back.
   - **`end_turn`** → return response, stop.

That's the entire loop. `stop_reason` is the signal — your code responds to it.

</template>
<template #right>

<div style="display:flex; flex-direction:column; gap:18px;">
  <div><strong><code>tool_use →</code></strong><br/>Keep going. Execute the tool, append the result, and send the next request.</div>
  <div><strong><code>end_turn →</code></strong><br/>Stop. Return the response to the user.</div>
</div>

</template>
</TwoColSlide>

<!--
Let me show you the complete loop structure. You send a request to Claude. Claude responds with a message that always includes a stop_reason field. If stop_reason is tool_use, Claude is telling you: I've decided to call a tool. Execute the tool, take the result, append it to the conversation, and send the next request. Keep going. If stop_reason is end_turn, Claude is telling you: I'm done. The response is complete. Don't loop. Return it to the user. That's the entire loop. The stop_reason field is the signal. Your code responds to it.
-->

---

<!-- SLIDE 3 — The Code Pattern -->

<CodeBlockSlide
  eyebrow="Canonical loop"
  title="The Code Pattern"
  lang="python"
  :code="loopCode"
  annotation="while True — Claude drives termination, not a counter. Append BOTH the assistant message AND the tool result before the next call."
  footerLabel="Lecture 3.1"
  :footerNum="3"
  :footerTotal="8"
/>

<!--
Here's what this looks like in code. Notice the structure: while True loop with an explicit break on end_turn. The loop is intentionally unbounded — Claude drives the termination, not a counter. And the tool results get appended to the conversation history before the next call. That's not optional. Claude needs to see what its tools returned.
-->

---

<!-- SLIDE 4 — Tool Use Response -->

<TwoColSlide
  variant="compare"
  title="What's in a Tool Use Response"
  leftLabel="JSON"
  rightLabel="Key fields"
  footerLabel="Lecture 3.1"
  :footerNum="4"
  :footerTotal="8"
>
<template #left>

```json
{
  "stop_reason": "tool_use",
  "content": [
    {
      "type": "tool_use",
      "id": "toolu_01ABC123",
      "name": "get_weather",
      "input": {"location": "Seattle, WA"}
    }
  ]
}
```

</template>
<template #right>

- **`type`** — always `"tool_use"`, identifies this block.
- **`name`** — which tool Claude selected.
- **`input`** — arguments Claude decided to pass.
- **`id` ⚠** — echo it back on the tool_result; matches results to requests.

</template>
</TwoColSlide>

<!--
When stop_reason is tool_use, the response content contains a tool use block. It has four key parts: the type — always tool_use — the id which is a unique identifier for this specific call, the name which tells you which tool Claude selected, and the input which is the arguments Claude decided to pass. The id matters because when you send the tool result back, you must reference this same ID. Claude uses it to match results to requests — especially when multiple tools are called in the same response. Your code's job: find all tool_use blocks in the content, execute each tool with the provided inputs, and package the results back with matching IDs.
-->

---

<!-- SLIDE 5 — Appending Tool Results -->

<StepSequence
  eyebrow="Common mistake"
  title="Appending Tool Results Correctly"
  :steps="appendSteps"
  footerLabel="Lecture 3.1"
  :footerNum="5"
  :footerTotal="8"
/>

<!--
The most common implementation mistake: forgetting to append both the assistant message AND the tool result before the next call. This is the required sequence on every iteration. First, append the full assistant response, the one containing the tool_use block, to the messages array. Second, append a user message containing the tool result. This is formatted as a list of tool_result blocks, each with the tool_use_id matching Claude's request, the content — the actual result — and whether it's an error. Then make the next API call with the full updated messages array. Skip either step, and Claude's context is incomplete. It will either repeat itself or hallucinate what the tool returned.
-->

---

<!-- SLIDE 6 — Two stop_reason Values -->

<TwoColSlide
  variant="compare"
  title="The Two stop_reason Values You Must Know"
  leftLabel="tool_use"
  rightLabel="end_turn"
  footerLabel="Lecture 3.1"
  :footerNum="6"
  :footerTotal="8"
>
<template #left>

Claude has decided to call a tool. The loop **must continue**.

- Execute tools, append results, call the API again.
- **Do not** treat as complete.
- **Do not** return to the user yet.

</template>
<template #right>

Claude has completed its response. The loop **must stop**.

- Return the response to the user.
- **Do not** keep looping "just to check."
- **Do not** inspect text for "done" keywords.

*The field speaks. Believe it.*

</template>
</TwoColSlide>

<!--
There are other stop_reason values — like max_tokens and stop_sequence — but for agentic loops, these two are the only ones you need to make decisions about. tool_use means Claude made a decision to call a tool. The loop must continue. Do not treat this as a complete response. Do not return this to the user. end_turn means Claude has completed its response. The loop must stop. Do not keep looping just to check. Do not inspect the text for keywords like done or finished. The field speaks. Believe it.
-->

---

<!-- SLIDE 7 — Exam Tip -->

<AntiPatternSlide
  eyebrow="⚡ Exam Tip"
  title="How to Control the Loop"
  lang="text"
  :badExample="examTipBad"
  whyItFails="Text is non-deterministic. Caps-as-primary hide partial results. Inspecting content blocks duplicates a signal the API already gives you."
  :fixExample="examTipGood"
  footerLabel="Lecture 3.1"
  :footerNum="7"
  :footerTotal="8"
/>

<!--
The exam will present scenarios where a candidate is doing something other than reading stop_reason to control the loop. Examples you'll see as distractors: checking if the response text contains the word done or complete, setting a maximum iteration counter as the primary exit condition, or checking whether the response includes a tool_use block in the content — instead of checking the stop_reason field. All of these are anti-patterns. The correct pattern is exactly one thing: read stop_reason from the response object. If it's end_turn, stop. If it's tool_use, execute tools and continue. That's it.
-->

---

<!-- SLIDE 8 — Takeaways -->

<BulletReveal
  eyebrow="Takeaway"
  title="The Agentic Loop — What to Know Cold"
  :bullets="takeawayBullets"
  footerLabel="Lecture 3.1"
  :footerNum="8"
  :footerTotal="8"
/>

<!--
Six things to carry forward. stop_reason tool_use means execute the tool, append the result, and loop back. stop_reason end_turn means return the response to the user and stop. Always append both the assistant message AND the tool result before the next call. The loop is while True with an explicit break — Claude drives termination, not a counter. Never use text content inspection to decide whether to continue looping. And this pattern applies to every scenario on the exam — master it first.
-->
