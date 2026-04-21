---
theme: default
title: "Section 3: Domain 1 - Agentic Architecture & Orchestration"
info: |
  Claude Certified Architect - Foundations
  Section 3: Domain 1 - Agentic Architecture & Orchestration (27%)
highlighter: shiki
transition: slide-left
mdc: true
canvasWidth: 1920
aspectRatio: 16/9
---

<style>
@import './design-system.css';
</style>

<!-- LECTURE 3.1 - The Agentic Loop: stop_reason Is Everything -->

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

<script setup>
const loopCode = `messages = [{"role": "user", "content": initial_prompt}]

while True:
    response = client.messages.create(
        model="claude-opus-4-7",
        tools=tools,
        messages=messages
    )

    # Exit condition -- always check stop_reason first
    if response.stop_reason == "end_turn":
        break

    # Continuation condition
    if response.stop_reason == "tool_use":
        tool_results = execute_tools(response.content)
        messages.append({"role": "assistant", "content": response.content})
        messages.append({"role": "user", "content": tool_results})
        # Loop continues`
</script>

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

<script setup>
const appendSteps = [
  { number: 'Step 1', title: 'Append the assistant response', body: 'Append the full assistant response (including the tool_use block) to the messages array.' },
  { number: 'Step 2', title: 'Append a user tool_result', body: 'Append a USER message with tool_result blocks -- each needs tool_use_id, content, and is_error.' },
  { number: 'Step 3', title: 'Call the API with full history', body: 'Make the next API call with the FULL updated messages array -- nothing else.' },
]
</script>

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

<script setup>
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
</script>

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

<script setup>
const takeawayBullets = [
  { label: "stop_reason='tool_use' -> continue", detail: 'Execute the tool, append the result, and loop back.' },
  { label: "stop_reason='end_turn' -> stop", detail: 'Return the response to the user.' },
  { label: 'Always append BOTH', detail: 'Assistant message AND tool result before the next call.' },
  { label: 'while True + explicit break', detail: 'Claude drives termination, not a counter.' },
  { label: 'Never inspect text content', detail: 'Do not use the response text to decide whether to keep looping.' },
  { label: 'Foundational pattern', detail: 'This is the pattern behind every scenario on the exam -- master it first.' },
]
</script>

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

---

<!-- LECTURE 3.2 - tool_use vs end_turn - Control Flow Patterns -->

<!-- SLIDE 1 — Cover -->

<Frame bg="var(--forest-900)" color="var(--mint-100)" :pad="false">
  <div style="position:absolute; inset:0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%);" />
  <div style="position:relative; z-index:1; padding:110px 120px 96px; width:100%; height:100%; display:flex; flex-direction:column; justify-content:space-between;">
    <div style="display:flex; align-items:center; gap:24px;">
      <img src="/assets/logo-mark.png" alt="" style="width:72px; height:auto;" />
      <div style="font-family: var(--font-body); font-size:26px; font-weight:500; letter-spacing:0.14em; text-transform:uppercase; color: var(--mint-200);">Dyer Innovation</div>
    </div>
    <div>
      <div style="font-family: var(--font-body); font-size:26px; font-weight:600; letter-spacing:0.16em; text-transform:uppercase; color: var(--sprout-500); margin-bottom:40px;">Domain 1 &middot; Lecture 3.2</div>
      <h1 style="font-family: var(--font-display); font-weight:500; font-size:128px; line-height:1.02; letter-spacing:-0.025em; color: var(--paper-0); margin:0; max-width:1500px;">
        <span style="color: var(--sprout-500);">tool_use</span> vs <span style="color: var(--sprout-500);">end_turn</span>
      </h1>
      <div style="font-family: var(--font-display); font-size:44px; color: var(--mint-200); margin-top:40px; font-weight:400; max-width:1200px; line-height:1.3;">
        Control flow patterns for the agentic loop
      </div>
    </div>
    <div style="display:flex; align-items:center; gap:48px; font-family: var(--font-body); font-size:26px; color: var(--mint-200); letter-spacing:0.06em;">
      <span>Lecture 3.2</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>~9 min</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>8 slides</span>
    </div>
  </div>
</Frame>

<!--
In the previous lecture, we looked at the overall agentic loop. Now let's go deeper into the two branches — what happens in each one, and what specific patterns each enables. Because the difference between these two paths isn't just "keep going" versus "stop." It's about what you do with the response content, how you structure the conversation history, and what control flow patterns you can build on top of each.
-->

---

<!-- SLIDE 2 — The tool_use path -->

<script setup>
const tuSteps = [
  { number: 'Step 1', title: 'Extract tool_use blocks', body: 'From the content array -- a single response can contain MULTIPLE tool_use blocks.' },
  { number: 'Step 2', title: 'Execute each tool', body: 'Run your actual function -- query a DB, call an API, read a file -- whatever the tool does.' },
  { number: 'Step 3', title: 'Package the results', body: 'Each result is a tool_result block with matching tool_use_id, content, and an is_error flag.' },
  { number: 'Step 4', title: 'Append + call again', body: 'Append the original assistant response, then a user message with ALL tool results -> API call.' },
]
</script>

<StepSequence
  eyebrow="The tool_use path"
  title="Step by Step"
  :steps="tuSteps"
  footerLabel="Lecture 3.2"
  :footerNum="2"
  :footerTotal="8"
/>

<!--
When you receive a response with stop_reason equals tool_use, here's the exact sequence. Step one: extract the tool_use blocks from the content array. A single response can contain multiple tool_use blocks — Claude can call several tools in one turn. Step two: execute each tool. This means running your actual function — querying a database, calling an API, reading a file — whatever the tool does. Step three: package the results. Each result goes into a tool_result block with the matching tool_use_id, the content — the actual result data — and an is_error flag if the tool failed. Step four: append the original assistant response to messages, then append a new user message containing all the tool results. Then call the API again.
-->

---

<!-- SLIDE 3 — end_turn isn't always success -->

<script setup>
const endTurnBullets = [
  { label: '✓ Task complete', detail: 'Most common -- Claude finished successfully. Return the response to the user.' },
  { label: '⚠ Cannot proceed', detail: 'Claude hit a blocker and is returning an explanation. Inspect content, then surface to caller.' },
  { label: '✗ Max tokens', detail: 'Context limit reached mid-response. Check stop_reason value, handle truncation.' },
]
</script>

<BulletReveal
  eyebrow="end_turn isn't always success"
  title="The end_turn Path — What It Actually Means"
  :bullets="endTurnBullets"
  footerLabel="Lecture 3.2"
  :footerNum="3"
  :footerTotal="8"
/>

<!--
end_turn doesn't always mean the task is complete and everything is fine. It means Claude has decided to stop generating — for whatever reason. The three typical reasons for end_turn are: the task is complete — most common — or Claude determined it cannot proceed and is returning an explanation, or the context got close to the limit. In your control flow, you should inspect the response content after an end_turn to understand why Claude stopped — especially in error-prone workflows. But critically: do not loop on end_turn. Whatever the reason, Claude has made a decision. Return the response and let the calling code or user handle it.
-->

---

<!-- SLIDE 4 — Model-driven vs pre-configured -->

<TwoColSlide
  variant="compare"
  title="Model-Driven vs Pre-Configured Decision Trees"
  leftLabel="Model-driven (Claude decides)"
  rightLabel="Pre-configured (your code decides)"
  footerLabel="Lecture 3.2"
  :footerNum="4"
  :footerTotal="8"
>
<template #left>

- Give Claude the full tool set.
- Claude decides which to call and in what order.
- The tool_use loop handles sequencing automatically.
- **Use for:** flexible workflows where the right sequence is context-dependent.
- **Example:** research agent chooses between web search, file read, API call.

</template>
<template #right>

- Your code has explicit decision trees.
- Certain tools are only callable after others complete.
- Inspect intermediate results, route next steps.
- **Use for:** HARD constraints — safety or correctness order.
- **Example:** cannot refund before looking up the customer order.

</template>
</TwoColSlide>

<!--
There are two philosophies for how to route between tools in an agentic workflow. In the model-driven approach, you give Claude a full set of tools and let it decide which to call and in what order. The tool_use loop handles sequencing automatically. Claude's judgment is the routing logic. In the pre-configured approach, your code has explicit decision trees. Certain tools can only be called after others complete. You inspect intermediate results and decide what to do next. For exam purposes: model-driven is the default for flexible workflows. Pre-configured — programmatic enforcement — is the right choice for hard constraints, things that must happen in a specific order for safety or correctness reasons. The customer support scenario uses this explicitly: you can't process a refund before looking up the customer order. That order enforcement is programmatic, not left to Claude's judgment.
-->

---

<!-- SLIDE 5 — Batch multiple tool calls -->

<script setup>
const batchCode = `tool_results = []

for block in response.content:
    if block.type == "tool_use":
        result = execute_tool(block.name, block.input)
        tool_results.append({
            "type": "tool_result",
            "tool_use_id": block.id,   # MUST match Claude's request ID
            "content": result
        })

# All results go back in a SINGLE user message
messages.append({
    "role": "user",
    "content": tool_results
})`
</script>

<CodeBlockSlide
  eyebrow="Batch processing"
  title="Handling Multiple Tool Calls in One Response"
  lang="python"
  :code="batchCode"
  annotation="Don't process tools one-at-a-time with individual API calls. Do batch all tool results into one combined user message."
  footerLabel="Lecture 3.2"
  :footerNum="5"
  :footerTotal="8"
/>

<!--
Claude can issue multiple tool calls in a single response turn. When this happens, all the tool_use blocks appear together in the content array. Your code must process all of them before sending the next request. Don't send partial results. Don't process tools one at a time with individual API calls. Process all tool calls from a single response in one batch, then send one combined user message.
-->

---

<!-- SLIDE 6 — Conversation turn order -->

<script setup>
const flowSteps = [
  { label: 'User', sublabel: 'initial request' },
  { label: 'Assistant', sublabel: 'tool_use block' },
  { label: 'User', sublabel: 'tool_result' },
  { label: 'Assistant', sublabel: 'tool_use or end_turn' },
]
</script>

<FlowDiagram
  eyebrow="Turn order"
  title="Tool Results in the Conversation History"
  :steps="flowSteps"
  footerLabel="Lecture 3.2"
  :footerNum="6"
  :footerTotal="8"
/>

<!--
The conversation history is how Claude maintains context across an agentic loop. Every message matters. Claude uses the full history to understand what it's already tried, what the results were, and what to do next. The pattern for the history looks like this: a user message — the initial request — followed by an assistant message containing tool_use blocks, followed by a user message containing the corresponding tool results, followed by the next assistant response. This alternating pattern — user, assistant, user, assistant — must be maintained. The API will reject requests that violate turn order. The tool results are framed as user messages because they represent information coming from the external environment to Claude.
-->

---

<!-- SLIDE 7 — Exam Tip -->

<script setup>
const examBad = `// Trap 1 -- tool result as an assistant message
{
  "role": "assistant",
  "content": [
    { "type": "tool_result",
      "tool_use_id": "toolu_01ABC",
      "content": "Seattle: 58\u00B0F" }
  ]
}`
const examGood = `// Tool results go in a USER message -- all of them, together
{
  "role": "user",
  "content": [
    { "type": "tool_result",
      "tool_use_id": "toolu_01ABC",
      "content": "Seattle: 58\u00B0F" }
  ]
}`
</script>

<AntiPatternSlide
  eyebrow="⚡ Exam Tip"
  title="Tool Result Message Role"
  lang="json"
  :badExample="examBad"
  whyItFails="Trap 1: tool results as assistant messages — feels intuitive, but wrong. Trap 2: sending only some of the batch and expecting Claude to work with partial info."
  :fixExample="examGood"
  footerLabel="Lecture 3.2"
  :footerNum="7"
  :footerTotal="8"
/>

<!--
The exam will test whether you know the correct message role for tool results. Tool results go in user messages — not assistant messages. This trips candidates up because intuitively, I just ran Claude's tool, so I'm sending back to Claude — that feels like the assistant providing output. But the message structure is from Claude's perspective: user messages are what Claude receives from the outside world. A second exam trap: sending incomplete tool results — only some of the batch — and expecting Claude to work with partial information. Always send all tool results in one user message before calling the API again.
-->

---

<!-- SLIDE 8 — Takeaways -->

<script setup>
const takeawayBullets = [
  { label: 'tool_use path', detail: 'Extract blocks -> execute -> append BOTH assistant msg AND tool results -> loop.' },
  { label: 'end_turn path', detail: 'Do not loop. Inspect content to understand completion state, then return.' },
  { label: 'Tool results = USER messages', detail: 'Tool results belong in user messages, not assistant messages.' },
  { label: 'Batch tool results', detail: 'Multiple tool calls in one response -> process all, send one combined user message.' },
  { label: 'Model-driven routing', detail: 'Claude decides tool order -- use for flexible workflows.' },
  { label: 'Programmatic enforcement', detail: 'Your code enforces order -- use for hard constraints (safety, correctness).' },
]
</script>

<BulletReveal
  eyebrow="Takeaway"
  title="tool_use vs end_turn — Control Flow"
  :bullets="takeawayBullets"
  footerLabel="Lecture 3.2"
  :footerNum="8"
  :footerTotal="8"
/>

<!--
Six things to carry into 3.3. tool_use path: extract blocks, execute tools, append both the assistant message and the tool results, and loop. end_turn path: do not loop — inspect content to understand completion state, then return. Tool results belong in user messages, not assistant messages. Multiple tool calls in one response → process all, send one combined user message. Model-driven routing: Claude decides the tool order — use for flexible workflows. Programmatic enforcement: your code enforces the order — use for hard constraints, safety and workflow requirements.
-->

---

<!-- LECTURE 3.3 - Anti-Patterns: What NOT to Do in Agentic Loops -->

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

<script setup>
const ap1Bad = `# Inspecting text to decide when to stop
if "task complete" in response.content[0].text:
    break`
const ap1Good = `# Use the structured signal the API already gives you
if response.stop_reason == "end_turn":
    break`
</script>

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

<script setup>
const ap2Bad = `# Cap as PRIMARY exit -- silent partial result if hit
for attempt in range(10):
    response = call_api()
    if done:
        break`
const ap2Good = `# Cap as SAFETY guard -- loop exits on end_turn
while True:
    response = call_api()
    if response.stop_reason == "end_turn":
        break
    if iterations > MAX:
        raise AgentLoopError("Max iterations exceeded")`
</script>

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

<script setup>
const ap3Bad = `Broken loop -- tool results never appended

User
  -> Assistant (tool_use block)
    -> NEXT API CALL  (no tool_results in history)

Claude has no memory of what the tool returned.
It repeats the call, or invents an answer.`
const ap3Good = `Correct loop -- tool results appended as a USER message

User
  -> Assistant (tool_use block)
    -> User (tool_result blocks, matching tool_use_id)
      -> NEXT API CALL`
</script>

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

<script setup>
const ap4Bad = `Stop the loop on the first tool error

Tool call executes
  -> Tool returns error
    -> Terminate loop
      -> Return error to user

Claude never gets a chance to recover.`
const ap4Good = `Pass the error to Claude -- let it reason

Tool call executes
  -> Tool returns error
    -> Append as tool_result with is_error: true
      -> Continue the loop

Claude can retry, pivot, or explain.`
</script>

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

<script setup>
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
</script>

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

<script setup>
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

<script setup>
const takeawayBullets = [
  { label: '1. Text parsing for completion', detail: 'Use stop_reason, not response content text.' },
  { label: '2. Iteration caps as primary exit', detail: 'Use while True + break on end_turn; caps are safety guards only.' },
  { label: '3. Skipping tool result appending', detail: 'Always append BOTH the assistant msg AND the tool results.' },
  { label: '4. Stopping on tool errors', detail: 'Append errors as is_error: true tool_results and let Claude reason.' },
  { label: '5. Tool results in assistant messages', detail: 'Tool results belong in USER role messages.' },
]
</script>

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

---

<!-- LECTURE 3.4 - Multi-Agent Hub-and-Spoke Architecture -->

<!-- SLIDE 1 — Cover -->

<Frame bg="var(--forest-900)" color="var(--mint-100)" :pad="false">
  <div style="position:absolute; inset:0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%);" />
  <div style="position:relative; z-index:1; padding:110px 120px 96px; width:100%; height:100%; display:flex; flex-direction:column; justify-content:space-between;">
    <div style="display:flex; align-items:center; gap:24px;">
      <img src="/assets/logo-mark.png" alt="" style="width:72px; height:auto;" />
      <div style="font-family: var(--font-body); font-size:26px; font-weight:500; letter-spacing:0.14em; text-transform:uppercase; color: var(--mint-200);">Dyer Innovation</div>
    </div>
    <div>
      <div style="font-family: var(--font-body); font-size:26px; font-weight:600; letter-spacing:0.16em; text-transform:uppercase; color: var(--sprout-500); margin-bottom:40px;">Domain 1 &middot; Lecture 3.4</div>
      <h1 style="font-family: var(--font-display); font-weight:500; font-size:128px; line-height:1.02; letter-spacing:-0.025em; color: var(--paper-0); margin:0; max-width:1500px;">
        Multi-Agent<br /><span style="color: var(--sprout-500);">Hub-and-Spoke</span>
      </h1>
      <div style="font-family: var(--font-display); font-size:44px; color: var(--mint-200); margin-top:40px; font-weight:400; max-width:1200px; line-height:1.3;">
        Coordinator-centered orchestration — the pattern the exam tests.
      </div>
    </div>
    <div style="display:flex; align-items:center; gap:48px; font-family: var(--font-body); font-size:26px; color: var(--mint-200); letter-spacing:0.06em;">
      <span>Lecture 3.4</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>~9 min</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>8 slides</span>
    </div>
  </div>
</Frame>

<!--
Single agents are powerful. But they have limits. They operate in a single context window. They can only do one thing at a time. And complex tasks — research, code review, customer support pipelines — often need multiple specialized capabilities running in parallel. Multi-agent systems solve these problems. But they introduce coordination challenges. The architecture that the CCA-F exam focuses on is hub-and-spoke — a central coordinator managing multiple specialized subagents.
-->

---

<!-- SLIDE 2 — Hub-and-Spoke core structure
     TODO: HubSpokeDiagram component needed. Wave 5 consolidator will
     either inline an SVG here or build a dedicated HubSpokeDiagram
     component. For now we use TwoColSlide with a text-rendered topology. -->

<TwoColSlide
  variant="compare"
  title="Hub-and-Spoke — The Core Structure"
  leftLabel="Topology"
  rightLabel="Mechanic"
  footerLabel="Lecture 3.4"
  :footerNum="2"
  :footerTotal="8"
>
<template #left>

```text
                  Coordinator (Hub)
                   /    |    |    \
                  /     |    |     \
             Research  Docs  Synth  Report
              Agent    Agent Agent  Writer
```

**4 subagents** around **one coordinator hub**. No arrows between outer nodes — all flow goes through the coordinator.

</template>
<template #right>

- **Subagents** — only ever communicate with the coordinator. Never each other.
- **Why not a mesh?** Direct subagent comms = mesh topology — harder to debug, monitor, reason about.
- **Deliberate** — centralized observability, consistent error handling, predictable control flow.

</template>
</TwoColSlide>

<!--
The hub-and-spoke pattern has one defining rule: all communication flows through the coordinator. The coordinator — the hub — receives the original task. It decomposes it. It assigns work to subagents. It collects results. It aggregates. And it produces the final output. The subagents — the spokes — only ever communicate with the coordinator. They never talk directly to each other. This is not a limitation. It's a deliberate design choice that gives you centralized observability, consistent error handling, and predictable control flow. If subagents communicated directly, you'd have a mesh topology — harder to debug, harder to monitor, and harder to reason about when something goes wrong.
-->

---

<!-- SLIDE 3 — Coordinator's Three Jobs -->

<script setup>
const jobsBullets = [
  { label: '1. Decompose', detail: 'Break the task into pieces with clear, bounded responsibility -- no implicit dependencies.' },
  { label: '2. Delegate', detail: 'Spawn each subagent with its task and context. Subagents do NOT inherit coordinator history.' },
  { label: '3. Aggregate', detail: 'Collect outputs, synthesize, handle failures gracefully -- retry, skip, or surface.' },
]
</script>

<BulletReveal
  eyebrow="Coordinator responsibilities"
  title="The Coordinator's Three Jobs"
  :bullets="jobsBullets"
  footerLabel="Lecture 3.4"
  :footerNum="3"
  :footerTotal="8"
/>

<!--
The coordinator has exactly three jobs: decompose, delegate, and aggregate. Decompose: break the original task into pieces that subagents can handle independently. Good decomposition means each subagent has a clear, bounded responsibility with no implicit dependencies on what other subagents are doing. Delegate: spawn each subagent with its specific task and the context it needs. This means explicit context passing — subagents don't inherit the coordinator's history. Each one starts fresh. Aggregate: collect all the subagent outputs, synthesize them into a coherent response, and handle any failures gracefully. The coordinator is responsible for catching subagent errors and deciding whether to retry, skip, or surface the failure.
-->

---

<!-- SLIDE 4 — Subagent Context Isolation -->

<TwoColSlide
  variant="antipattern-fix"
  title="Subagent Context Isolation"
  leftLabel="❌ What candidates assume"
  rightLabel="✓ What actually happens"
  footerLabel="Lecture 3.4"
  :footerNum="4"
  :footerTotal="8"
>
<template #left>

Coordinator holds the full conversation history →  
**inherits** →  
subagent "knows" everything the coordinator knows.

**Wrong.** Subagents do not see any of the coordinator's messages.

</template>
<template #right>

Coordinator passes context **explicitly** in the task prompt →  
subagent starts with a **fresh context** containing only what was passed.

**Rule:** nothing flows implicitly. Everything must be passed explicitly.

</template>
</TwoColSlide>

<!--
One of the most important things to understand about subagents: they don't inherit the coordinator's conversation history. Each subagent starts with a completely fresh context. This means the coordinator must be explicit about what information each subagent needs. If the research pipeline has already found key facts, and the synthesis subagent needs those facts, the coordinator must explicitly include them in the synthesis subagent's task prompt. Nothing flows implicitly. Everything that matters must be passed explicitly. This is why the exam asks about "explicit context passing" — it's the mechanism that makes multi-agent systems actually work.
-->

---

<!-- SLIDE 5 — The Task Tool -->

<script setup>
const taskCode = `# Coordinator spawns a subagent via the Task tool
response = client.messages.create(
    model="claude-opus-4-7",
    tools=[{
        "name": "Task",
        "description": "Delegate a bounded subtask to a specialist subagent.",
        "input_schema": {
            "type": "object",
            "properties": {
                "description": {"type": "string"},
                "prompt":      {"type": "string"},
                "allowedTools":{"type": "array", "items": {"type": "string"}}
            },
            "required": ["description", "prompt", "allowedTools"]
        }
    }],
    system=COORDINATOR_SYSTEM_PROMPT,
    messages=messages
)

# Example Task call the coordinator emits:
# {
#   "name": "Task",
#   "input": {
#     "description": "Analyze the Q3 report",
#     "prompt": "Extract revenue, margin, and growth numbers from ...",
#     "allowedTools": ["Task", "read_file"]   # Task MUST be present
#   }
# }`
</script>

<CodeBlockSlide
  eyebrow="Spawning"
  title="The Task Tool — Spawning Subagents"
  lang="python"
  :code="taskCode"
  annotation="allowedTools MUST include 'Task' — it's how an agent formally accepts an assignment. No Task in allowedTools → no assignment accepted."
  footerLabel="Lecture 3.4"
  :footerNum="5"
  :footerTotal="8"
/>

<!--
In Claude's agent framework, coordinators spawn subagents using the Task tool. A Task call has three key parameters: the task description — what to do — the prompt, which is the context and constraints, and allowedTools, which specifies what tools the subagent is permitted to use. The allowedTools parameter is an exam favorite. For a subagent to receive and process its task, allowedTools must include "Task". Without it, the subagent can't properly accept the task specification. Think of it this way: the Task tool is how an agent formally accepts an assignment. No Task in allowedTools means no assignment accepted.
-->

---

<!-- SLIDE 6 — Parallel vs Sequential -->

<TwoColSlide
  variant="compare"
  title="Parallel vs Sequential Subagent Execution"
  leftLabel="Sequential"
  rightLabel="Parallel"
  footerLabel="Lecture 3.4"
  :footerNum="6"
  :footerTotal="8"
>
<template #left>

```
Coordinator
  → Subagent 1
    → wait
      → Subagent 2
        → wait
          → Subagent 3
```

Use when subagent B depends on A's output.

</template>
<template #right>

```
Coordinator (one turn)
  ├─▶ Doc Analysis
  ├─▶ Web Search
  └─▶ Source Verify
          (all at once)
```

**Exam key phrase:** all parallel subagent spawning happens in ONE coordinator turn.

</template>
</TwoColSlide>

<!--
The hub-and-spoke architecture supports both sequential and parallel execution. Sequential: the coordinator spawns one subagent, waits for the result, then spawns the next. Use this when subagent B depends on subagent A's output. Parallel: the coordinator spawns multiple subagents in a single response turn. This is the key phrase for the exam. All parallel subagent spawning happens in one coordinator turn — multiple Task calls in one response. The coordinator then waits for all results before continuing. Parallel execution is the right choice when tasks are independent. The multi-agent research pipeline spawns document analysis, web search, and source verification subagents in parallel because their work doesn't depend on each other.
-->

---

<!-- SLIDE 7 — Exam Tip -->

<script setup>
const examBad = `Two traps the exam plants

Trap 1 -- Sequential spawning presented as parallel
  Coordinator emits one Task, waits, then emits another
  across multiple turns. That's sequential, not parallel.

Trap 2 -- Direct subagent-to-subagent communication
  Subagent A sends data directly to Subagent B. Violates
  hub-and-spoke -- all traffic must go through the hub.`
const examGood = `Two rules

(1) Parallel spawning = ONE coordinator turn,
    multiple Task calls in the same response.

(2) Subagents NEVER communicate directly --
    all traffic flows through the coordinator.`
</script>

<AntiPatternSlide
  eyebrow="⚡ Exam Tip"
  title="Hub-and-Spoke Exam Patterns"
  lang="text"
  :badExample="examBad"
  whyItFails="Parallel means ONE coordinator turn with multiple Task calls. Hub-and-spoke means subagents never talk to each other."
  :fixExample="examGood"
  footerLabel="Lecture 3.4"
  :footerNum="7"
  :footerTotal="8"
/>

<!--
Two patterns the exam tests heavily in the hub-and-spoke context. First: parallel subagent spawning happens in one coordinator response. The exam will offer an answer where the coordinator spawns subagents sequentially across multiple turns. That's slower and misses the point of parallelism. Second: direct subagent-to-subagent communication is always wrong in this architecture. If an answer choice has subagents sharing information directly, it's violating hub-and-spoke. In hub-and-spoke, everything goes through the coordinator.
-->

---

<!-- SLIDE 8 — Takeaways -->

<script setup>
const takeawayBullets = [
  { label: 'All traffic through the hub', detail: 'Subagents never talk directly to each other -- everything flows through the coordinator.' },
  { label: "Coordinator's three jobs", detail: 'Decompose -> Delegate -> Aggregate.' },
  { label: 'No inherited context', detail: 'Coordinator must pass everything the subagent needs, explicitly, in the task prompt.' },
  { label: "allowedTools must include 'Task'", detail: 'Without it, the subagent cannot properly accept its assignment.' },
  { label: 'Parallel = ONE coordinator turn', detail: 'All parallel subagent spawning happens in a single coordinator response turn.' },
  { label: 'Why hub-and-spoke?', detail: 'Centralized observability, consistent error handling, predictable control flow.' },
]
</script>

<BulletReveal
  eyebrow="Takeaway"
  title="Hub-and-Spoke Architecture"
  :bullets="takeawayBullets"
  footerLabel="Lecture 3.4"
  :footerNum="8"
  :footerTotal="8"
/>

<!--
Six things to carry forward. All communication flows through the coordinator — subagents never talk directly to each other. The coordinator's three jobs: Decompose, Delegate, Aggregate. Subagents have no inherited context — the coordinator must pass everything explicitly. allowedTools must include "Task" for a subagent to accept its assignment. Parallel spawning equals all subagents spawned in one coordinator response turn. Hub-and-spoke gives you centralized observability, consistent error handling, and predictable control flow.
-->

---

<!-- LECTURE 3.5 - The Coordinator's Role: Decompose, Delegate, Aggregate -->

<!-- SLIDE 1 — Cover -->

<Frame bg="var(--forest-900)" color="var(--mint-100)" :pad="false">
  <div style="position:absolute; inset:0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%);" />
  <div style="position:relative; z-index:1; padding:110px 120px 96px; width:100%; height:100%; display:flex; flex-direction:column; justify-content:space-between;">
    <div style="display:flex; align-items:center; gap:24px;">
      <img src="/assets/logo-mark.png" alt="" style="width:72px; height:auto;" />
      <div style="font-family: var(--font-body); font-size:26px; font-weight:500; letter-spacing:0.14em; text-transform:uppercase; color: var(--mint-200);">Dyer Innovation</div>
    </div>
    <div>
      <div style="font-family: var(--font-body); font-size:26px; font-weight:600; letter-spacing:0.16em; text-transform:uppercase; color: var(--sprout-500); margin-bottom:40px;">Domain 1 &middot; Lecture 3.5</div>
      <h1 style="font-family: var(--font-display); font-weight:500; font-size:128px; line-height:1.02; letter-spacing:-0.025em; color: var(--paper-0); margin:0; max-width:1500px;">
        The Coordinator's Role
      </h1>
      <div style="font-family: var(--font-display); font-size:44px; color: var(--mint-200); margin-top:40px; font-weight:400; max-width:1200px; line-height:1.3;">
        Decompose. Delegate. Aggregate.
      </div>
    </div>
    <div style="display:flex; align-items:center; gap:48px; font-family: var(--font-body); font-size:26px; color: var(--mint-200); letter-spacing:0.06em;">
      <span>Lecture 3.5</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>~8 min</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>8 slides</span>
    </div>
  </div>
</Frame>

<!--
In 3.4 we sketched the hub-and-spoke topology. Now we zoom into the hub itself — the coordinator. This lecture walks through its three jobs in detail: how to decompose a task well, how to delegate with explicit context, and how to aggregate results across every possible outcome. Get this right and your multi-agent system is debuggable and predictable. Get it wrong and it silently returns partial nonsense.
-->

---

<!-- SLIDE 2 — Coordinator is the brain -->

<TwoColSlide
  variant="compare"
  title="The Coordinator Is the Brain"
  leftLabel="Does"
  rightLabel="Does NOT do"
  footerLabel="Lecture 3.5"
  :footerNum="2"
  :footerTotal="8"
>
<template #left>

- Receives the original user task.
- Decides how to split it into subtasks.
- Selects which subagents handle which parts.
- Passes the right context to each subagent.
- Collects and synthesizes results.

</template>
<template #right>

- Browse the web.
- Analyze documents directly.
- Execute code.
- Write the final research report.

*These are subagent responsibilities.*

**Exam implication:** if an answer has the coordinator directly executing domain tasks instead of delegating, it's wrong.

</template>
</TwoColSlide>

<!--
The coordinator is the brain of a multi-agent system. It does five things: receives the original user task, decides how to split it into subtasks, selects which subagents handle which parts, passes the right context to each subagent, and collects and synthesizes results. It does NOT do the actual domain work — it doesn't browse the web, analyze documents directly, execute code, or write the final research report. Those are subagent responsibilities. The exam implication is direct: if an answer choice has the coordinator executing domain tasks instead of delegating, it's wrong. The coordinator orchestrates — it never operates.
-->

---

<!-- SLIDE 3 — Decompose -->

<TwoColSlide
  variant="antipattern-fix"
  title="Decompose — Breaking the Task Well"
  leftLabel="❌ Poor decomposition"
  rightLabel="✓ Good decomposition"
  footerLabel="Lecture 3.5"
  :footerNum="3"
  :footerTotal="8"
>
<template #left>

- "Research agent" does research **AND** writes the summary.
- Subtasks have unclear boundaries.
- Subagent A's output format is assumed by subagent B.
- One subagent is responsible for too much.

</template>
<template #right>

- Each subagent has one clearly defined job.
- Independent tasks can run in parallel.
- Dependent tasks are chained explicitly.
- Each subtask has a clear output contract.

*Dynamic selection:* coordinator chooses the right specialized subagent based on the subtask — requires reasoning about capabilities.

</template>
</TwoColSlide>

<!--
Decompose is the first job and the easiest to get wrong. Poor decomposition bundles responsibilities — a research agent that does research AND writes the summary, subtasks with unclear boundaries, or one subagent implicitly depending on another's output format. Good decomposition gives each subagent one clearly defined job, lets independent tasks run in parallel, chains dependent tasks explicitly, and gives each subtask a clear output contract. And the coordinator doesn't have a fixed map of subtask-to-subagent. Dynamic selection means the coordinator chooses the right specialized subagent based on the nature of the subtask — which requires it to reason about capabilities.
-->

---

<!-- SLIDE 4 — Delegate -->

<script setup>
const delegateSteps = [
  { number: 'Rule 1', title: 'Subagents start with fresh context', body: "The coordinator's conversation history is NOT passed down. Everything the subagent needs must be in the task prompt." },
  { number: 'Rule 2', title: 'Task prompt must include everything', body: 'Objective, relevant background, output format, constraints. If synthesis needs research facts, the coordinator injects them explicitly.' },
  { number: 'Rule 3', title: 'Least-privilege tools', body: 'Only give each subagent the tools it needs. Constrained tools = predictable, auditable behavior.' },
]
</script>

<StepSequence
  eyebrow="Delegation"
  title="Delegate — Explicit Context Passing"
  :steps="delegateSteps"
  footerLabel="Lecture 3.5"
  :footerNum="4"
  :footerTotal="8"
/>

<!--
Delegate is the second job. Three rules. Rule one: subagents start with fresh context. The coordinator's history is NOT passed down. Everything the subagent needs must be in the task prompt. Rule two: the task prompt must include everything — objective, relevant background, output format, constraints. If the synthesis subagent needs facts from the research pipeline, the coordinator injects them explicitly. Rule three: least-privilege tools. Only give each subagent the tools it needs. Document analysis doesn't need web search. Constrained tools make for predictable, auditable behavior. The failure mode here is assuming the subagent "knows what you mean" — it doesn't. Make every assumption explicit.
-->

---

<!-- SLIDE 5 — Aggregate -->

<script setup>
const aggregateSteps = [
  { number: 'Happy path', title: 'All subagents return results', body: 'Coordinator synthesizes -- combine, deduplicate, format into a single coherent output.' },
  { number: 'Partial failure', title: 'One subagent fails or returns no result', body: 'Coordinator decides: retry, proceed without, or surface the failure to the caller.' },
  { number: 'Total failure', title: 'A critical subagent fails', body: 'Coordinator surfaces clearly -- NOT a silently incomplete result.' },
]
</script>

<StepSequence
  eyebrow="Aggregation"
  title="Aggregate — Collecting and Synthesizing Results"
  :steps="aggregateSteps"
  footerLabel="Lecture 3.5"
  :footerNum="5"
  :footerTotal="8"
/>

<!--
Aggregate is the third job, and the one candidates underweight. Three outcomes to handle. Happy path: all subagents return results. Coordinator synthesizes — combine, deduplicate, format. Partial failure: one subagent fails or returns no result. The coordinator decides whether to retry, proceed without, or surface to the caller. Total failure: a critical subagent fails. The coordinator surfaces clearly — not a silently incomplete result. The aggregation rule is simple: the coordinator is the single point of error handling for all subagent outputs. Errors are caught here — not silently dropped.
-->

---

<!-- SLIDE 6 — Full lifecycle -->

<TwoColSlide
  variant="compare"
  title="The Full Coordinator Lifecycle"
  leftLabel="Flow"
  rightLabel="Per step"
  footerLabel="Lecture 3.5"
  :footerNum="6"
  :footerTotal="8"
>
<template #left>

```
Receive user task
  → Decompose into subtasks
    → Select subagents dynamically
      → Spawn via Task tool
        (explicit context)
          → Receive subagent results
            → Aggregate
              → Return final output
```

</template>
<template #right>

- **Decompose** — each subtask has one owner, clear scope, explicit output contract.
- **Select** — choose the right specialized subagent; not all tasks need the same agent.
- **Spawn** — pass exactly what's needed, no more, no less.
- **Aggregate** — handle errors, synthesize outputs, return a coherent result.

</template>
</TwoColSlide>

<!--
Put it all together and the coordinator has a clean lifecycle: receive the user task, decompose it into subtasks, select subagents dynamically, spawn them via the Task tool with explicit context, receive results, aggregate, and return the final output. At each step: decompose gives each subtask one owner and a clear output contract. Select means choosing the right specialized subagent for the subtask — not all tasks need the same agent. Spawn passes exactly what's needed, no more and no less. Aggregate handles errors, synthesizes outputs, and returns a coherent result.
-->

---

<!-- SLIDE 7 — Exam Tip -->

<script setup>
const examBad = `Two traps the exam plants

Trap 1 -- Coordinator doing domain work
  'Coordinator browses the web and writes the final report.'
  Coordinators orchestrate; they do not operate.

Trap 2 -- Implicit context propagation
  'Subagent picks up where the coordinator left off.'
  There is no implicit channel -- subagents start fresh.`
const examGood = `Remember

Coordinator = Decompose, Delegate (with explicit context),
              Aggregate (with error handling).

Dynamic subagent selection means the coordinator
chooses the right specialized agent based on the
nature of the subtask.`
</script>

<AntiPatternSlide
  eyebrow="⚡ Exam Tip"
  title="Coordinator Responsibility Boundaries"
  lang="text"
  :badExample="examBad"
  whyItFails="Coordinators only decompose, delegate, and aggregate. And subagents have no shared memory — everything must be passed explicitly."
  :fixExample="examGood"
  footerLabel="Lecture 3.5"
  :footerNum="7"
  :footerTotal="8"
/>

<!--
Two traps the exam loves to plant in coordinator questions. Trap one: the coordinator doing domain work — browsing the web, writing the report directly. Coordinators orchestrate; they do not operate. Trap two: implicit context propagation — an answer that suggests the subagent "picks up where the coordinator left off" without explicit passing. That's not how isolation works. Remember: coordinator equals decompose, delegate with explicit context, and aggregate with error handling. And dynamic subagent selection means the coordinator chooses the right agent based on the nature of the subtask.
-->

---

<!-- SLIDE 8 — Takeaways -->

<script setup>
const takeawayBullets = [
  { label: 'Orchestrator, never operator', detail: 'Coordinator orchestrates -- it never executes domain tasks directly.' },
  { label: 'Decompose cleanly', detail: 'Bounded subtasks with clear output contracts and no implicit dependencies.' },
  { label: 'Delegate explicitly', detail: 'Subagents start fresh -- everything they need lives in the task prompt.' },
  { label: 'Aggregate every outcome', detail: 'Handle success, partial failure, and total failure -- never drop silently.' },
  { label: 'Dynamic selection', detail: 'Choose the right specialized subagent based on the nature of the subtask.' },
  { label: 'Single point of error handling', detail: 'Coordinator owns error handling for all subagent outputs.' },
]
</script>

<BulletReveal
  eyebrow="Takeaway"
  title="The Coordinator's Role"
  :bullets="takeawayBullets"
  footerLabel="Lecture 3.5"
  :footerNum="8"
  :footerTotal="8"
/>

<!--
Six things to carry forward. Coordinator orchestrates — it never executes domain tasks directly. Decompose into bounded subtasks with clear output contracts and no implicit dependencies. Delegate with explicit context passing — subagents start fresh and everything lives in the prompt. Aggregate handles every outcome: success, partial failure, total failure. Dynamic subagent selection means choosing the right specialized agent based on the nature of the subtask. And the coordinator is the single point of error handling for all subagent outputs.
-->

---

<!-- LECTURE 3.6 - Subagent Context Isolation -->

<!-- SLIDE 1 — Cover -->

<Frame bg="var(--forest-900)" color="var(--mint-100)" :pad="false">
  <div style="position:absolute; inset:0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%);" />
  <div style="position:relative; z-index:1; padding:110px 120px 96px; width:100%; height:100%; display:flex; flex-direction:column; justify-content:space-between;">
    <div style="display:flex; align-items:center; gap:24px;">
      <img src="/assets/logo-mark.png" alt="" style="width:72px; height:auto;" />
      <div style="font-family: var(--font-body); font-size:26px; font-weight:500; letter-spacing:0.14em; text-transform:uppercase; color: var(--mint-200);">Dyer Innovation</div>
    </div>
    <div>
      <div style="font-family: var(--font-body); font-size:26px; font-weight:600; letter-spacing:0.16em; text-transform:uppercase; color: var(--sprout-500); margin-bottom:40px;">Domain 1 &middot; Lecture 3.6</div>
      <h1 style="font-family: var(--font-display); font-weight:500; font-size:128px; line-height:1.02; letter-spacing:-0.025em; color: var(--paper-0); margin:0; max-width:1500px;">
        Subagent <span style="color: var(--sprout-500);">Context Isolation</span>
      </h1>
      <div style="font-family: var(--font-display); font-size:44px; color: var(--mint-200); margin-top:40px; font-weight:400; max-width:1200px; line-height:1.3;">
        Each subagent starts with a blank slate. Make every assumption explicit.
      </div>
    </div>
    <div style="display:flex; align-items:center; gap:48px; font-family: var(--font-body); font-size:26px; color: var(--mint-200); letter-spacing:0.06em;">
      <span>Lecture 3.6</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>~8 min</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>8 slides</span>
    </div>
  </div>
</Frame>

<!--
In 3.4 and 3.5 we saw that subagents don't inherit the coordinator's history. This lecture goes deep on that rule — what isolation actually means, what the subagent does and doesn't have, and the design implications. Context isolation is the mechanism that makes multi-agent systems work. If you don't understand it, you'll pick distractors that assume implicit propagation.
-->

---

<!-- SLIDE 2 — What context isolation means -->

<TwoColSlide
  variant="compare"
  title="What Context Isolation Actually Means"
  leftLabel="Does NOT have"
  rightLabel="DOES have"
  footerLabel="Lecture 3.6"
  :footerNum="2"
  :footerTotal="8"
>
<template #left>

- Coordinator's conversation history.
- Results from other subagents.
- The original user request (unless passed).
- Any context from previous turns.

</template>
<template #right>

- Its own system prompt (if provided).
- The task prompt the coordinator constructed.
- The tools in its `allowedTools` list.
- **Only** what the coordinator explicitly passed.

*Design principle:* predictability + security. A subagent that can't accidentally SEE unrelated data can't accidentally ACT on it.

</template>
</TwoColSlide>

<!--
Let's be precise. The subagent does NOT have: the coordinator's conversation history, results from other subagents, the original user request unless it's passed, or any context from previous turns. The subagent DOES have: its own system prompt if one is provided, the task prompt the coordinator constructed, the tools in its allowedTools list, and only what the coordinator explicitly passed. The design principle is predictability plus security. A subagent that can't accidentally SEE unrelated data can't accidentally ACT on it.
-->

---

<!-- SLIDE 3 — Code pattern: explicit injection -->

<script setup>
const codePattern = `# Coordinator has rich context accumulated across the run:
#   - original user objective
#   - facts from the Research subagent
#   - notes from the Document subagent
# None of that flows to the next subagent automatically.

synthesis_task_prompt = f"""
You are the Synthesis subagent. Produce a concise brief.

## Objective (from the original user request)
{original_user_objective}

## Facts gathered by Research
{research_facts}

## Notes from Document Analysis
{document_notes}

## Output format
- Three-paragraph brief
- Cite sources inline
""".strip()

task_call = {
    "name": "Task",
    "input": {
        "description": "Synthesize research + doc analysis into a brief",
        "prompt": synthesis_task_prompt,
        "allowedTools": ["Task"]     # no external tools needed
    }
}`
</script>

<CodeBlockSlide
  eyebrow="Code pattern"
  title="Context Isolation in Code — What the Subagent Receives"
  lang="python"
  :code="codePattern"
  annotation="Every fact the subagent needs must be serialized into the task prompt by the coordinator."
  footerLabel="Lecture 3.6"
  :footerNum="3"
  :footerTotal="8"
/>

<!--
Here's what this actually looks like in code. The coordinator has rich context: original user objective, facts from the research subagent, notes from the document subagent. None of that flows automatically. The coordinator has to serialize everything the synthesis subagent needs into the task prompt — objective, facts, notes, output format. Then the Task call goes out. The subagent sees only that prompt. Every fact it needs must be injected by the coordinator. That's the contract.
-->

---

<!-- SLIDE 4 — The explicit passing requirement -->

<script setup>
const reqSteps = [
  { number: 'What to pass', title: 'Everything relevant, explicitly', body: 'Original user objective, background facts/data, output format, constraints, and results from prior subagents that this subagent needs.' },
  { number: 'What fails without it', title: 'Incomplete or redundant work', body: "Subagent produces output that doesn't fit the broader task -- or re-collects information via tools, wasting resources." },
  { number: 'What to NOT pass', title: 'The full history', body: "Don't dump the entire coordinator history. Pass only what's relevant -- irrelevant context increases cost and confuses the subagent." },
]
</script>

<StepSequence
  eyebrow="Explicit context passing"
  title="The Requirement"
  :steps="reqSteps"
  footerLabel="Lecture 3.6"
  :footerNum="4"
  :footerTotal="8"
/>

<!--
Three rules about what to pass. What to pass: original user objective, background facts or data, output format, constraints, and results from prior subagents that this subagent needs. What fails without it: the subagent produces output that doesn't fit the broader task, or it re-collects information via tools — wasting resources and time. What to NOT pass: don't dump the entire coordinator history. Pass only what's relevant. Irrelevant context increases cost and confuses the subagent.
-->

---

<!-- SLIDE 5 — Benefits and challenges -->

<TwoColSlide
  variant="compare"
  title="Isolation — Benefits and Challenges"
  leftLabel="Benefits"
  rightLabel="Challenges"
  footerLabel="Lecture 3.6"
  :footerNum="5"
  :footerTotal="8"
>
<template #left>

- **Predictability** — behavior depends only on what you gave it.
- **Security** — sensitive data doesn't leak between subagents.
- **Parallelism** — isolated subagents safely run concurrently.
- **Testability** — test each subagent with known inputs.

</template>
<template #right>

- **Context engineering burden** — coordinator must construct complete, accurate prompts.
- **Serialization overhead** — large data structures formatted for prompts.
- **No shared state** — all results flow through the coordinator.

*Design implication:* isolation shifts complexity to the coordinator's prompt construction logic.

</template>
</TwoColSlide>

<!--
Isolation has clear benefits and real costs. Benefits: predictability — behavior depends only on what you gave the subagent. Security — sensitive data doesn't leak between subagents. Parallelism — isolated subagents safely run concurrently. Testability — you can test each subagent with known inputs. Challenges: context engineering burden — the coordinator must construct complete, accurate prompts. Serialization overhead — large data structures have to be formatted for prompts. No shared state — all results flow through the coordinator. The design implication is that isolation shifts complexity to the coordinator's prompt construction logic. That's the tradeoff.
-->

---

<!-- SLIDE 6 — No persistence across calls -->

<script setup>
const persistenceSteps = [
  { number: 'Implication 1', title: 'Two calls = two instances', body: 'Call Task twice with the same subagent description -> two independent instances. The second has no memory of the first.' },
  { number: 'Implication 2', title: 'Retry reconstructs context', body: 'Retry logic must rebuild the full task context. You cannot resume a failed subagent -- spawn fresh with the same (or corrected) prompt.' },
  { number: 'Implication 3', title: 'Coordinator is the only persistent entity', body: 'It accumulates results across subagent calls and maintains workflow state.' },
]
</script>

<StepSequence
  eyebrow="No persistence"
  title="Each Task Call Creates an Independent Instance"
  :steps="persistenceSteps"
  footerLabel="Lecture 3.6"
  :footerNum="6"
  :footerTotal="8"
/>

<!--
Three implications of "no session persistence." Implication one: call the Task tool twice with the same subagent description and you get two independent instances. The second has no memory of the first. Implication two: retry logic must reconstruct the full task context. You cannot resume a failed subagent — you spawn a fresh one with the same, or corrected, prompt. Implication three: the coordinator is the only persistent entity. It accumulates results across subagent calls and maintains workflow state. Mental model: subagents are functions. Call them with arguments. They return results. They don't remember between calls.
-->

---

<!-- SLIDE 7 — Exam Tip -->

<script setup>
const examBad = `Two traps the exam plants

Trap 1 -- Implicit user-request access
  Answer assumes the subagent 'already knows' the user's
  original request because the coordinator received it.

Trap 2 -- Cross-call memory
  Answer describes the subagent being 'updated' or
  'continuing' from a prior call. No -- there is no
  memory between Task calls.`
const examGood = `Rule

Subagents start with a blank slate.
The coordinator is the sole source of context
for each subagent invocation.
EVERYTHING must be passed explicitly.`
</script>

<AntiPatternSlide
  eyebrow="⚡ Exam Tip"
  title="Context Isolation — The Exam Traps"
  lang="text"
  :badExample="examBad"
  whyItFails="Subagents start blank every time. The coordinator is the sole source of context."
  :fixExample="examGood"
  footerLabel="Lecture 3.6"
  :footerNum="7"
  :footerTotal="8"
/>

<!--
Two traps to recognize. Trap one: an answer that assumes the subagent "already knows" the user's original request because the coordinator received it. No — the subagent only knows what's in its task prompt. Trap two: an answer that describes the subagent being "updated" or "continuing" from a prior call. No — there's no memory between Task calls. The rule is short: subagents start with a blank slate. The coordinator is the sole source of context for each subagent invocation. Everything must be passed explicitly.
-->

---

<!-- SLIDE 8 — Takeaways -->

<script setup>
const takeawayBullets = [
  { label: 'No inherited history', detail: "Subagents do NOT inherit the coordinator's history -- each starts with a blank context." },
  { label: 'Independent per call', detail: 'Each Task call creates an independent instance -- no session persistence.' },
  { label: 'Explicit passing is mandatory', detail: 'Everything the subagent needs must live in the task prompt.' },
  { label: 'Relevant context only', detail: 'Dumping full history is inefficient and counterproductive -- pass only what matters.' },
  { label: 'Coordinator is persistent', detail: 'The coordinator accumulates results and maintains workflow state.' },
  { label: 'Isolation shifts complexity', detail: "Benefits: parallelism, predictability, security. Cost: coordinator's prompt construction logic." },
]
</script>

<BulletReveal
  eyebrow="Takeaway"
  title="Subagent Context Isolation"
  :bullets="takeawayBullets"
  footerLabel="Lecture 3.6"
  :footerNum="8"
  :footerTotal="8"
/>

<!--
Six things to carry forward. Subagents do NOT inherit the coordinator's history — each starts with a blank context. Each Task call creates an independent instance — no session persistence. Explicit context passing is mandatory — everything in the task prompt. Pass RELEVANT context only — dumping full history is inefficient and counterproductive. The coordinator is the only persistent entity — it accumulates results and maintains state. And isolation enables parallelism, predictability, and security — at the cost of shifting complexity to the coordinator's prompt construction logic.
-->

---

<!-- LECTURE 3.7 - The Task Tool - Spawning Subagents -->

<!-- SLIDE 1 — Cover -->

<Frame bg="var(--forest-900)" color="var(--mint-100)" :pad="false">
  <div style="position:absolute; inset:0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%);" />
  <div style="position:relative; z-index:1; padding:110px 120px 96px; width:100%; height:100%; display:flex; flex-direction:column; justify-content:space-between;">
    <div style="display:flex; align-items:center; gap:24px;">
      <img src="/assets/logo-mark.png" alt="" style="width:72px; height:auto;" />
      <div style="font-family: var(--font-body); font-size:26px; font-weight:500; letter-spacing:0.14em; text-transform:uppercase; color: var(--mint-200);">Dyer Innovation</div>
    </div>
    <div>
      <div style="font-family: var(--font-body); font-size:26px; font-weight:600; letter-spacing:0.16em; text-transform:uppercase; color: var(--sprout-500); margin-bottom:40px;">Domain 1 &middot; Lecture 3.7</div>
      <h1 style="font-family: var(--font-display); font-weight:500; font-size:128px; line-height:1.02; letter-spacing:-0.025em; color: var(--paper-0); margin:0; max-width:1500px;">
        The <span style="color: var(--sprout-500);">Task</span> Tool
      </h1>
      <div style="font-family: var(--font-display); font-size:44px; color: var(--mint-200); margin-top:40px; font-weight:400; max-width:1200px; line-height:1.3;">
        Spawning subagents — structure, constraints, and least privilege.
      </div>
    </div>
    <div style="display:flex; align-items:center; gap:48px; font-family: var(--font-body); font-size:26px; color: var(--mint-200); letter-spacing:0.06em;">
      <span>Lecture 3.7</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>~8 min</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>8 slides</span>
    </div>
  </div>
</Frame>

<!--
The Task tool is the mechanism behind everything we covered in 3.4, 3.5, and 3.6. When we say "the coordinator spawns a subagent," what we mean, concretely, is "the coordinator calls the Task tool." This lecture covers what the Task tool is, its key parameters, the allowedTools requirement the exam tests, and the least-privilege principle. Get this right and the multi-agent patterns all fall into place.
-->

---

<!-- SLIDE 2 — What the Task tool is / isn't -->

<TwoColSlide
  variant="compare"
  title="What the Task Tool Is"
  leftLabel="What it does"
  rightLabel="What it is NOT"
  footerLabel="Lecture 3.7"
  :footerNum="2"
  :footerTotal="8"
>
<template #left>

- Creates an **independent Claude instance**.
- Passes a task description and instructions.
- Constrains the subagent to specific tools.
- Returns the subagent's final output to the coordinator.

</template>
<template #right>

- **NOT** a generic HTTP call to another service.
- **NOT** a thread or process fork.
- **NOT** a shared-memory communication channel.
- **NOT** persistent — each call is independent.

*Analogy:* the Task tool is Claude's native way of saying "I need a specialist to handle this — let me formally assign the work."

</template>
</TwoColSlide>

<!--
Let's anchor what the Task tool actually is. It does four things: creates an independent Claude instance, passes a task description and instructions, constrains the subagent to specific tools, and returns the subagent's final output to the coordinator. What it is NOT: a generic HTTP call to another service, a thread or process fork, a shared-memory communication channel, or a persistent session. Each call is independent. The analogy I like: the Task tool is Claude's native way of saying "I need a specialist to handle this — let me formally assign the work."
-->

---

<!-- SLIDE 3 — Key parameters -->

<script setup>
const taskStructCode = `task_call = {
    "name": "Task",
    "input": {
        "description": "Short label for this subagent run",
        "prompt":      "Complete, self-contained task specification",
        "allowedTools": ["Task", "read_file", "search_documents"]
    }
}`
</script>

<CodeBlockSlide
  eyebrow="Structure"
  title="The Task Tool — Key Parameters"
  lang="python"
  :code="taskStructCode"
  annotation="allowedTools — which tools the subagent can use; MUST include 'Task'. prompt — complete self-contained context; it's all the subagent knows."
  footerLabel="Lecture 3.7"
  :footerNum="3"
  :footerTotal="8"
/>

<!--
The Task tool takes three key parameters. Description: a short label for what this subagent is doing. Prompt: the complete, self-contained task specification — objective, context, output format, constraints. This is all the subagent knows. And allowedTools: the list of tools the subagent is permitted to use. Two things the exam tests here. One: the prompt must be self-contained — because of context isolation, it's everything the subagent knows. Two: allowedTools must include "Task" or the subagent can't accept the assignment. That's the next slide.
-->

---

<!-- SLIDE 4 — allowedTools must include 'Task' -->

<script setup>
const allowedBad = `// Missing "Task" -- subagent cannot properly accept its task
{
  "allowedTools": ["read_file", "search_documents"]
}`
const allowedGood = `// "Task" present -- subagent can accept and execute
{
  "allowedTools": ["Task", "read_file", "search_documents"]
}`
</script>

<AntiPatternSlide
  eyebrow="Critical detail"
  title="The allowedTools Requirement"
  lang="json"
  :badExample="allowedBad"
  whyItFails="The Task tool is how an agent FORMALLY accepts an assignment. Without it in the allowed set, the subagent cannot acknowledge and execute the task specification."
  :fixExample="allowedGood"
  footerLabel="Lecture 3.7"
  :footerNum="4"
  :footerTotal="8"
/>

<!--
This is one of the highest-value slides in Domain 1. The allowedTools parameter MUST include "Task". If it's missing, the subagent cannot properly accept its task specification. The reason is mechanical: the Task tool is how an agent formally accepts an assignment. The subagent needs Task in its allowed set in order to process its task specification. Without it, it can't acknowledge and execute. The exam will hand you an answer where allowedTools lists everything except Task, and ask why the subagent isn't doing what's expected. Recognize the pattern on sight.
-->

---

<!-- SLIDE 5 — Least privilege for subagent tools -->

<script setup>
const capabilityBullets = [
  { label: 'Principle of least privilege', detail: 'Each subagent only has tools required for its specific job. Doc analysis doesn\'t need web search. Web search doesn\'t need file write.' },
  { label: 'Why it matters', detail: 'Overpowered subagent = unintended actions. Write access where read-only was meant -> data corruption. Constrained = predictable, auditable, safer.' },
  { label: 'Examples', detail: "Research: ['Task', 'web_search', 'read_url'] · Report writer: ['Task', 'write_file'] · Code reviewer: ['Task', 'read_file', 'run_tests']" },
]
</script>

<BulletReveal
  eyebrow="Security"
  title="Constraining Subagent Capabilities via allowedTools"
  :bullets="capabilityBullets"
  footerLabel="Lecture 3.7"
  :footerNum="5"
  :footerTotal="8"
/>

<!--
Beyond the required "Task," the rest of allowedTools is where you apply the principle of least privilege. Each subagent only gets the tools required for its specific job. Document analysis doesn't need web search. Web search doesn't need file write. Why it matters: an overpowered subagent can take unintended actions. Give write access where read-only was meant and you get data corruption. Constrained allowedTools means predictable, auditable, safer behavior. Three quick examples: Research gets Task, web_search, read_url. Report writer gets Task and write_file. Code reviewer gets Task, read_file, and run_tests. Narrow lists. No "just in case" tools.
-->

---

<!-- SLIDE 6 — Parallel spawning setup -->

<script setup>
const parallelCode = `# Coordinator spawns two subagents in ONE response turn
coordinator_response_content = [
    {
        "type": "tool_use",
        "id": "toolu_01RES",
        "name": "Task",
        "input": {
            "description": "Research Q3 industry trends",
            "prompt": "Find 5 sources on Q3 AI infra spend...",
            "allowedTools": ["Task", "web_search", "read_url"]
        }
    },
    {
        "type": "tool_use",
        "id": "toolu_01DOC",
        "name": "Task",
        "input": {
            "description": "Analyze the uploaded Q3 report",
            "prompt": "Extract revenue, margin, and growth...",
            "allowedTools": ["Task", "read_file"]
        }
    }
]

# Both Task calls go out in THE SAME coordinator turn = parallel.
# Coordinator waits for BOTH results before continuing.`
</script>

<CodeBlockSlide
  eyebrow="Parallel spawning"
  title="Coordinator Spawning Multiple Subagents in One Turn"
  lang="python"
  :code="parallelCode"
  annotation="Both Task calls in the SAME coordinator response = parallel. Coordinator waits for ALL Task results before continuing. Covered in depth in 3.8."
  footerLabel="Lecture 3.7"
  :footerNum="6"
  :footerTotal="8"
/>

<!--
Here's what parallel spawning looks like at the Task-call level. The coordinator emits a single response whose content array contains two tool_use blocks — both with name "Task." One spawns the research subagent, the other spawns the document subagent. Each has its own description, prompt, and allowedTools list. Both Task calls are in the same coordinator response turn. That's what "parallel" means here. The coordinator then waits for both Task results before continuing. We'll dive into parallel execution in depth in 3.8.
-->

---

<!-- SLIDE 7 — Exam Tip -->

<script setup>
const examBad = `Two traps the exam plants

Trap 1 -- Missing 'Task' in allowedTools
  Subagent fails to process its assignment; the question
  describes unexpected behavior. Root cause: 'Task' is
  absent from allowedTools.

Trap 2 -- Overly permissive allowedTools
  'Give every subagent access to all tools for flexibility.'
  Violates least privilege -- the right answer narrows the list.`
const examGood = `Rule

Every subagent's allowedTools must include 'Task'
PLUS only the tools needed for its specific job.
Nothing more.`
</script>

<AntiPatternSlide
  eyebrow="⚡ Exam Tip"
  title="The Task Tool — Two Exam Traps"
  lang="text"
  :badExample="examBad"
  whyItFails="Task is required to accept an assignment. Every unnecessary tool expands the blast radius of a misbehaving subagent."
  :fixExample="examGood"
  footerLabel="Lecture 3.7"
  :footerNum="7"
  :footerTotal="8"
/>

<!--
Two exam traps to watch for. Trap one: the subagent isn't processing its assignment correctly — and the root cause is that "Task" is missing from allowedTools. Trap two: an answer that hands every subagent access to all tools "for flexibility." That violates least privilege — the correct answer narrows the list. The rule the exam is looking for: every subagent's allowedTools must include "Task" plus only the tools needed for its specific job. Nothing more.
-->

---

<!-- SLIDE 8 — Takeaways -->

<script setup>
const takeawayBullets = [
  { label: 'Task = the spawn mechanism', detail: 'The Task tool is how coordinators spawn independent subagent instances.' },
  { label: "allowedTools must include 'Task'", detail: 'Without it, the subagent cannot properly accept its assignment.' },
  { label: 'Each call = fresh instance', detail: 'No state persists between Task calls.' },
  { label: 'prompt must be self-contained', detail: "It's all the subagent knows -- make every assumption explicit." },
  { label: 'Apply least privilege', detail: 'Each subagent gets only the tools needed for its specific job -- nothing more.' },
  { label: 'Multiple calls = parallel', detail: 'Multiple Task calls in one coordinator response = parallel spawning (covered in 3.8).' },
]
</script>

<BulletReveal
  eyebrow="Takeaway"
  title="The Task Tool — What to Know Cold"
  :bullets="takeawayBullets"
  footerLabel="Lecture 3.7"
  :footerNum="8"
  :footerTotal="8"
/>

<!--
Six things to carry into 3.8. The Task tool is the mechanism coordinators use to spawn independent subagent instances. allowedTools must include "Task" — without it, the subagent cannot properly accept its assignment. Each Task call creates a fresh independent instance — no state persists. The prompt must be self-contained — it's all the subagent knows. Apply least privilege — each subagent gets only the tools needed for its specific job. Multiple Task calls in one coordinator response equals parallel spawning, which we cover next.
-->

---

<!-- LECTURE 3.8 - Parallel Subagent Execution -->

<Frame bg="var(--forest-900)" color="var(--mint-100)" :pad="false">
  <div style="position:absolute; inset:0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%);"></div>
  <div style="position:relative; z-index:1; padding:110px 120px 96px; width:100%; height:100%; display:flex; flex-direction:column; justify-content:space-between;">
    <div style="display:flex; align-items:center; gap:24px;">
      <img src="/assets/logo-mark.png" alt="" style="width:72px; height:auto;" />
      <div style="font-family: var(--font-body); font-size:26px; font-weight:500; letter-spacing:0.14em; text-transform:uppercase; color: var(--mint-200);">Dyer Innovation</div>
    </div>
    <div>
      <div style="font-family: var(--font-body); font-size:26px; font-weight:600; letter-spacing:0.16em; text-transform:uppercase; color: var(--sprout-500); margin-bottom:40px;">Lecture 3.8 &middot; Domain 1</div>
      <h1 style="font-family: var(--font-display); font-weight:500; font-size:128px; line-height:1.02; letter-spacing:-0.025em; color: var(--paper-0); margin:0; max-width:1600px;">Parallel <span style="color: var(--sprout-500);">Subagent</span> Execution</h1>
      <div style="font-family: var(--font-display); font-size:44px; color: var(--mint-200); margin-top:40px; font-weight:400; max-width:1300px; line-height:1.3;">Multiple Task calls in a single coordinator response turn.</div>
    </div>
    <div style="display:flex; align-items:center; gap:48px; font-family: var(--font-body); font-size:26px; color: var(--mint-200); letter-spacing:0.06em;">
      <span>Domain 1 · 27%</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>Scenario 3 — Multi-Agent Research</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>Hub-and-spoke</span>
    </div>
  </div>
</Frame>

<!--
Welcome to Lecture 3.8 — Parallel Subagent Execution. In the last lecture we looked at how the Task tool spawns subagents. In this one we zero in on what "parallel" actually means inside Claude's agentic loop, because the term gets misused more than almost any other in Domain 1. Parallel subagent execution has a very precise structural signature, and the exam will try to catch you on it. Let's get that signature nailed down.
-->

---

<ConceptHero
  eyebrow="Precise definition"
  concept="Parallel = one response, many Task calls"
  supportLine="Sequential: spawn subagent 1 → wait → spawn subagent 2 → wait. Parallel: all Task calls in the SAME response — coordinator collects every result in one batch before its next turn."
  footerLabel="Exam phrase: all parallel subagent spawning happens in one coordinator response turn"
  :footerNum="2"
  :footerTotal="8"
/>

<!--
Here is the precise definition. Parallel subagent execution means the coordinator emits multiple Task tool_use blocks in a SINGLE response. Not across two turns. Not in a loop. One response, many Task calls. Sequential, by contrast, is: spawn subagent one, wait for its result, then spawn subagent two, wait, and so on. That's the contrast the exam tests. The exam-key phrase to memorise: "all parallel subagent spawning happens in one coordinator response turn." If an answer describes spawning across multiple turns, it is describing sequential — regardless of how the word "parallel" appears in the text.
-->

---

<script setup>
const compareLeft = [
  "Tasks do not depend on each other's output",
  'Web search + doc analysis + source verify -- each proceeds independently',
  'No need to know what others found',
]
const compareRight = [
  "Task B requires Task A's output",
  'Synthesis cannot happen until research produces findings',
  'Dependent subagent must wait',
]
</script>

<TwoColSlide
  variant="compare"
  title="Sequential vs Parallel — When to Use Each"
  eyebrow="Decision rule"
  leftLabel="Use parallel when"
  rightLabel="Use sequential when"
  :footerNum="3"
  :footerTotal="8"
>
  <template #left>
    <ul>
      <li v-for="(b, i) in compareLeft" :key="i">{{ b }}</li>
    </ul>
  </template>
  <template #right>
    <ul>
      <li v-for="(b, i) in compareRight" :key="i">{{ b }}</li>
    </ul>
  </template>
</TwoColSlide>

<!--
The decision rule is a single question: do the subagents depend on each other's output? If no, parallel is the right call — run them together and cut latency to the slowest branch. A classic parallel example: web search plus document analysis plus source verification. Each proceeds independently. If yes — task B genuinely needs task A's output — you must sequence them. Synthesis cannot happen until research has produced findings. The data dependency is the fork. Everything else is secondary.
-->

---

<script setup>
const parallelCode = `# Coordinator's single response contains THREE Task tool_use blocks.
coordinator_response_content = [

    # 1 -- web search subagent
    {
        "type": "tool_use",
        "id": "task_web_01",
        "name": "Task",
        "input": {
            "description": "Web research on topic X",
            "prompt": f"Research {topic}. Return structured findings.",
            "allowedTools": ["Task", "web_search", "read_url"]
        }
    },

    # 2 -- document analysis subagent
    {
        "type": "tool_use",
        "id": "task_docs_01",
        "name": "Task",
        "input": {
            "description": "Analyze provided documents",
            "prompt": f"Analyze: {documents}. Extract key claims.",
            "allowedTools": ["Task", "read_file", "search_documents"]
        }
    },

    # 3 -- source verification subagent
    {
        "type": "tool_use",
        "id": "task_verify_01",
        "name": "Task",
        "input": {
            "description": "Verify citations for the collected claims",
            "prompt": f"Verify each citation in: {claim_set}.",
            "allowedTools": ["Task", "read_url", "web_search"]
        }
    },
]
# All three Task calls in one response -> parallel spawning.
# Coordinator waits for all three tool_results in the next user message.`
</script>

<CodeBlockSlide
  eyebrow="Code pattern"
  title="Parallel Spawning — Coordinator Response"
  lang="python"
  :code="parallelCode"
  annotation="All three Task calls in one response → parallel. Coordinator waits for all three tool_results as a single batch before its next turn."
  :footerNum="4"
  :footerTotal="8"
/>

<!--
Here's what parallel spawning looks like in code. The coordinator's response content array contains three Task tool_use blocks — web search, document analysis, and source verification. Each has its own id, its own self-contained prompt, and its own allowedTools set following least privilege. Crucially, all three appear in the SAME response. The coordinator does not call the API three times. It calls it once, emits three Task blocks, and then waits for the next user message to carry three tool_results back in a single batch. That's the structural signature — one response, three Tasks, one batch of results.
-->

---

<script setup>
const flowSteps = [
  { label: 'Coordinator', sublabel: 'issues 3 Task calls in one response' },
  { label: 'Subagents run', sublabel: 'Web search · Doc analysis · Source verify -- all in parallel' },
  { label: 'user message', sublabel: '3 tool_results returned as a single batch' },
  { label: 'Coordinator', sublabel: 'aggregates results on the next turn' },
]
</script>

<FlowDiagram
  eyebrow="Result collection"
  title="Collecting Results from Parallel Subagents"
  :steps="flowSteps"
  footerLabel="Parallel fan-out and fan-in"
  :footerNum="5"
  :footerTotal="8"
/>

<!--
Let's walk the fan-out and fan-in. Step one: the coordinator issues three Task calls in a single response. Step two: the subagents execute independently — web search, document analysis, and source verification all running at the same time. Step three: the next user message returns all three tool_results as a single batch. One message, three results. Step four: the coordinator resumes and aggregates the three outputs on its next turn. Two things to remember. First, the coordinator does NOT see partial results streaming in — it sees the whole batch at once. Second, if any subagent fails, that shows up as an is_error:true tool_result inside the same batch. The coordinator must reason explicitly about partial failures; it does not get a clean retry.
-->

---

<script setup>
const seqLeft = [
  'One Task call per coordinator turn',
  'Coordinator waits for each result before proceeding',
  "Use when Task B depends on Task A's output",
  'Total time = sum of subagent times',
  'Example: Research -> wait -> Synthesis',
]
const parRight = [
  'Multiple Task calls in ONE coordinator turn',
  'All subagents run simultaneously',
  'Use when tasks are independent',
  'Total time ≈ slowest subagent',
  'Example: Web search + Doc analysis + Source verify',
]
</script>

<TwoColSlide
  variant="compare"
  title="Parallel vs Sequential — Full Comparison"
  eyebrow="Side-by-side"
  leftLabel="Sequential"
  rightLabel="Parallel"
  :footerNum="6"
  :footerTotal="8"
>
  <template #left>
    <ul>
      <li v-for="(b, i) in seqLeft" :key="i">{{ b }}</li>
    </ul>
  </template>
  <template #right>
    <ul>
      <li v-for="(b, i) in parRight" :key="i">{{ b }}</li>
    </ul>
  </template>
</TwoColSlide>

<!--
A side-by-side comparison. Sequential: one Task call per coordinator turn; coordinator waits for each result before proceeding; used when there's a data dependency; total time is the sum of every subagent's duration; the research-then-synthesis pipeline is the archetype. Parallel: multiple Task calls in ONE coordinator turn; subagents run simultaneously; used when tasks are independent; total time is approximately the slowest subagent's duration; web-search plus doc-analysis plus source-verify is the archetype. The big win for parallel is latency. The big constraint is that you cannot use it when task B depends on task A.
-->

---

<Frame>
  <Eyebrow>⚡ Exam tip</Eyebrow>
  <SlideTitle>Parallel Subagent Execution — Key Trap</SlideTitle>
  <div style="margin-top: 40px; display: grid; grid-template-columns: 1fr 1fr; gap: 32px; flex: 1; min-height: 0;">
    <v-clicks>
<CalloutBox variant="dont" title="Common trap">
      <p>An answer describes 'parallel' execution where the coordinator spawns subagents across multiple turns, waiting for each one. That is <strong>sequential</strong>, not parallel — regardless of the wording.</p>
      <p>Also wrong: subagents communicating directly to share intermediate results — violates hub-and-spoke isolation regardless of order.</p>
    </CalloutBox>
    <CalloutBox variant="do" title="Correct definition">
      <p>Parallel means <strong>multiple Task calls in ONE coordinator response turn</strong>. Independent tasks → parallel. Dependent tasks → sequential. All parallel results return as a single batch before the coordinator's next turn.</p>
    </CalloutBox>
</v-clicks>
  </div>
  <SlideFooter label="Domain 1 · Key trap" :num="7" :total="8" />
</Frame>

<!--
The exam trap you are most likely to see. A question describes "parallel" execution but the scenario says the coordinator spawned subagent one, waited for it, then spawned subagent two. That is sequential. The word "parallel" in the scenario is there to mislead you. Structure matters, not vocabulary — count the coordinator response turns. Another trap: subagents that communicate directly to share intermediate findings. That violates the hub-and-spoke isolation we established in Lecture 3.4, and it is wrong whether the execution is parallel or sequential. The correct definition: parallel means multiple Task calls in ONE coordinator response turn, period. Independent tasks parallelise; dependent tasks sequence. All results return as a batch before the coordinator's next turn.
-->

---

<script setup>
const takeaways = [
  { label: 'Parallel = multiple Task calls in ONE coordinator response turn', detail: 'Not across multiple turns. The structural signature is one response with many tool_use blocks.' },
  { label: 'Independent -> parallel; data dependency -> sequential', detail: "If Task B needs Task A's output, you cannot parallelise." },
  { label: 'All parallel results return as a SINGLE batch', detail: 'The next user message carries every tool_result before the coordinator continues.' },
  { label: 'Parallel time ≈ slowest subagent -- not sum of all', detail: 'Latency is bounded by the slowest branch, not the total work done.' },
  { label: 'Handle partial failures explicitly as is_error:true tool_results', detail: 'The coordinator must reason about which branches succeeded and which did not.' },
  { label: 'Real pipelines mix both', detail: 'A parallel collection phase followed by a sequential synthesis phase is common.' },
]
</script>

<BulletReveal
  eyebrow="Takeaways"
  title="Parallel Subagent Execution — What to Remember"
  :bullets="takeaways"
  :footerNum="8"
  :footerTotal="8"
/>

<!--
Six things to carry forward. One — parallel means multiple Task calls in ONE coordinator response turn, never across multiple turns. Two — independent tasks parallelise; data-dependent tasks must be sequenced. Three — all parallel results return as a single batch before the coordinator's next turn. Four — parallel execution time is bounded by the slowest subagent, not the sum of all. Five — partial failures show up as is_error:true tool_results inside the same batch, and the coordinator must handle them explicitly. And six — real pipelines almost always mix both: a parallel collection phase followed by a sequential synthesis phase. That pattern will show up in Scenario 3 and in Lecture 3.9, where we'll look at how context moves between the parallel and sequential parts of a pipeline.
-->

---

<!-- LECTURE 3.9 - Explicit Context Passing Between Agents -->

<Frame bg="var(--forest-900)" color="var(--mint-100)" :pad="false">
  <div style="position:absolute; inset:0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%);"></div>
  <div style="position:relative; z-index:1; padding:110px 120px 96px; width:100%; height:100%; display:flex; flex-direction:column; justify-content:space-between;">
    <div style="display:flex; align-items:center; gap:24px;">
      <img src="/assets/logo-mark.png" alt="" style="width:72px; height:auto;" />
      <div style="font-family: var(--font-body); font-size:26px; font-weight:500; letter-spacing:0.14em; text-transform:uppercase; color: var(--mint-200);">Dyer Innovation</div>
    </div>
    <div>
      <div style="font-family: var(--font-body); font-size:26px; font-weight:600; letter-spacing:0.16em; text-transform:uppercase; color: var(--sprout-500); margin-bottom:40px;">Lecture 3.9 &middot; Domain 1</div>
      <h1 style="font-family: var(--font-display); font-weight:500; font-size:128px; line-height:1.02; letter-spacing:-0.025em; color: var(--paper-0); margin:0; max-width:1600px;">Explicit Context<br /><span style="color: var(--sprout-500);">Passing</span> Between Agents</h1>
      <div style="font-family: var(--font-display); font-size:44px; color: var(--mint-200); margin-top:40px; font-weight:400; max-width:1300px; line-height:1.3;">Structured payloads, not narrative summaries.</div>
    </div>
    <div style="display:flex; align-items:center; gap:48px; font-family: var(--font-body); font-size:26px; color: var(--mint-200); letter-spacing:0.06em;">
      <span>Domain 1 · 27%</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>Scenario 3 — Multi-Agent Research</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>Provenance-preserving</span>
    </div>
  </div>
</Frame>

<!--
Welcome to Lecture 3.9 — Explicit Context Passing Between Agents. In the last lecture we saw how to spawn subagents in parallel. Now we tackle the question that trips up most multi-agent designs: how does information actually move from one agent to the next? Subagents share no ambient memory. Whatever downstream agents need to know, you have to pass in explicitly. And the way you pass it — narrative summary versus structured payload — decides whether your pipeline preserves truth or fabricates it.
-->

---

<script setup>
const narrativeLeft = "Agent A finds three claims. Passes: 'Here is a summary of findings.' Agent B has no idea where the claims came from, how recent they are, or whether they were primary sources."
const explicitRight = 'Agent A passes a structured payload: claim text, source URL, document name, page number, publication date, confidence level. Agent B can reason about the claims AND their provenance.'
</script>

<TwoColSlide
  variant="antipattern-fix"
  title="Context Doesn't Flow Automatically"
  eyebrow="Implicit vs explicit handoff"
  leftLabel="❌ Implicit Handoff"
  rightLabel="✓ Explicit Handoff"
  :footerNum="2"
  :footerTotal="8"
>
  <template #left>
    <p>{{ narrativeLeft }}</p>
  </template>
  <template #right>
    <p>{{ explicitRight }}</p>
  </template>
</TwoColSlide>

<!--
The mental model is simple. Agent A runs, produces findings, and hands off to Agent B. Implicit handoff: Agent A writes a summary — "here is what I found" — and Agent B inherits only that. Explicit handoff: Agent A passes a structured payload that carries the findings AND every piece of metadata the downstream agent needs to reason about them. The implicit version looks more natural in English. The explicit version is what production systems require. Everything from here on in this lecture is about making that explicit version routine.
-->

---

<Frame>
  <Eyebrow>Required payload fields</Eyebrow>
  <SlideTitle>What Must Be in a Context Payload</SlideTitle>
  <div style="margin-top: 48px; display: grid; grid-template-columns: 1fr 1fr; gap: 18px;">
    <SchemaField name="claim" type="string (verbatim)" :required="true" description="The extracted statement — not a paraphrase. Paraphrases lose precision." />
    <SchemaField name="source_url / document_name" type="string" :required="true" description="Where the claim came from — required for downstream agents to verify." />
    <SchemaField name="page / section" type="string" :required="true" description="Granular location inside the source. Without it, verification is impractical." />
    <SchemaField name="publication_date" type="ISO 8601" :required="true" description="Required for freshness evaluation. A 2019 claim may now be outdated." />
    <SchemaField name="confidence" type="'direct' | 'inferred'" :required="true" description="Was this directly stated or inferred? How much weight to give it." />
  </div>
  <SlideFooter label="Structured-payload contract" :num="3" :total="8" />
</Frame>

<!--
The contract. A claim payload that survives a multi-agent pipeline has five required fields. Claim text: verbatim, not paraphrased — paraphrase introduces drift the downstream cannot detect. Source URL or document name: the location the claim came from — required for verification. Page or section: granular location inside that source — without it, a verifier would have to re-read the entire document. Publication date in ISO 8601: required for freshness reasoning — a 2019 claim about model benchmarks may be worse than useless now. Confidence: was this stated directly in the source, or inferred from context — the downstream agent needs to know how much weight to give it. Five fields. Non-negotiable for anything where accuracy matters.
-->

---

<script setup>
const payloadCode = `# Build a structured context payload -- not a narrative summary.
def build_claim_payload(extracted_claims):
    return [
        {
            "claim": c["verbatim_text"],        # never paraphrase
            "source_url": c["url"],
            "document_name": c["doc"],
            "page": c["page"],
            "publication_date": c["date"],      # ISO 8601
            "confidence": c["confidence"],      # 'direct' | 'inferred'
        }
        for c in extracted_claims
    ]

# Inject that payload into the synthesis agent via the first user message.
def synthesize_with_context(claim_payload):
    context_block = "\\n".join(
        f"- [{c['confidence']}] {c['claim']}  "
        f"({c['document_name']}, p.{c['page']}, {c['publication_date']})  "
        f"<{c['source_url']}>"
        for c in claim_payload
    )
    return client.messages.create(
        model="claude-opus-4-7",
        system=SYNTHESIS_SYSTEM_PROMPT,
        messages=[{
            "role": "user",
            "content": (
                "Here are the verified claims with full provenance:\\n\\n"
                f"{context_block}\\n\\n"
                "Synthesize a report; cite each claim by source and page."
            ),
        }],
    )`
</script>

<CodeBlockSlide
  eyebrow="Code pattern"
  title="Structured Context Payload"
  lang="python"
  :code="payloadCode"
  annotation="Do: pass the full structured payload — Agent B never asks 'where did this come from?' Don't: narrative summaries — they discard provenance and embed the first agent's bias."
  :footerNum="4"
  :footerTotal="8"
/>

<!--
Here's the implementation. build_claim_payload takes a list of extracted claims and returns a list of dicts with the five required fields. The claim text is copied verbatim — never paraphrased. Then synthesize_with_context takes that payload, formats each claim into a line that preserves confidence, document name, page, date, and URL, and injects it into the first user message for the synthesis agent. The synthesis agent now has everything it needs to cite by source and page — and a human reviewer has everything they need to audit. Compare that to the alternative: ask the first agent to "summarize the findings." The summary looks fine, reads well, and is structurally useless.
-->

---

<script setup>
const narrativeBullets = [
  'Fast to produce -- just ask the first agent to summarise',
  'Easy to read -- easy to misinterpret',
  'Loses source attribution',
  'Loses publication dates and page references',
  "Embeds the first agent's paraphrase bias",
]
const structuredBullets = [
  'More design effort -- preserves all provenance',
  'Claim text is verbatim -- no interpretation loss',
  'All metadata intact: URL, date, page, confidence',
  'Downstream agents evaluate freshness and credibility',
  'Audit trail survives across the entire pipeline',
]
</script>

<TwoColSlide
  variant="compare"
  title="Narrative Summary vs Structured Payload"
  eyebrow="The real cost of summaries"
  leftLabel="Narrative Summary"
  rightLabel="Structured Payload"
  :footerNum="5"
  :footerTotal="8"
>
  <template #left>
    <ul>
      <li v-for="(b, i) in narrativeBullets" :key="i">{{ b }}</li>
    </ul>
  </template>
  <template #right>
    <ul>
      <li v-for="(b, i) in structuredBullets" :key="i">{{ b }}</li>
    </ul>
  </template>
</TwoColSlide>

<!--
Here's the real cost of the two approaches. A narrative summary is fast, easy to produce, easy to read — and easy to misinterpret. It loses source attribution. It loses publication dates and page references. And it embeds the first agent's paraphrase bias, which the downstream agent has no way to detect. A structured payload takes more design effort, but it preserves every piece of provenance. Claim text is verbatim. All metadata is intact. Downstream agents can evaluate freshness, credibility, and relevance independently. And the audit trail survives end-to-end. The rule: use structured payloads for any workflow where attribution, accuracy, or compliance matters. Summaries are only acceptable when downstream does not need to attribute, cite, or verify anything.
-->

---

<script setup>
const injectionSteps = [
  { title: 'System prompt injection', body: "Stable, reusable context -- agent's role, domain rules, output schema. Doesn't change per request." },
  { title: 'First user message injection', body: "Per-request context -- structured claim payload, task state, prior agent's output. Format clearly inside the first user turn." },
  { title: 'Tool result injection', body: 'Dynamic context fetched mid-task -- retrieved documents, DB lookups. Arrives via the tool result loop, appended to history.' },
]
</script>

<StepSequence
  eyebrow="Three injection patterns"
  title="How to Inject Context Into the Next Agent"
  :steps="injectionSteps"
  footerLabel="Match channel to lifecycle"
  :footerNum="6"
  :footerTotal="8"
/>

<!--
Three ways to inject context, and choosing the right one matters. Pattern one: system prompt injection. Put stable, reusable context there — the agent's role, domain rules, output schema. Things that don't change per request. Pattern two: first user message injection. Put per-request context there — the structured claim payload, the task state, prior agent output. This is the most common channel for multi-agent handoff. Pattern three: tool result injection. Dynamic context fetched mid-task — retrieved documents, database lookups — arrives through the tool-result loop and is appended to conversation history. The rule: context known before the call goes in system prompt or first user message. Context that depends on tool execution arrives via tool results. Never conflate the two — mixing them causes the agent to lose track of which context is stable and which is derived.
-->

---

<Frame>
  <Eyebrow>⚡ Exam tip</Eyebrow>
  <SlideTitle>Context Passing in Multi-Agent Pipelines</SlideTitle>
  <div style="margin-top: 40px; display: grid; grid-template-columns: 1fr 1fr; gap: 32px; flex: 1; min-height: 0;">
    <v-clicks>
<CalloutBox variant="dont" title="The trap">
      <p>A research agent passes a narrative summary to a synthesis agent. The synthesis agent then produces a report with source citations.</p>
      <p>Where do the citations come from? They can't come from the summary — attribution was discarded upstream. The synthesis agent will <strong>fabricate</strong> them.</p>
    </CalloutBox>
    <CalloutBox variant="do" title="Right answer">
      <p>Attribution metadata — source URL, document name, page number, publication date — <strong>must</strong> be in the structured payload.</p>
      <p>Summaries are only acceptable when the downstream agent does not need to attribute, cite, or verify.</p>
    </CalloutBox>
</v-clicks>
  </div>
  <SlideFooter label="Domain 1 · Multi-agent traps" :num="7" :total="8" />
</Frame>

<!--
The exam-tested trap. Scenario: a research agent extracts claims, summarizes them, and hands off to a synthesis agent that produces a report with citations. Question: what's the most likely failure mode? Wrong answers describe tone problems or prompt-engineering issues. The right answer: the synthesis agent will fabricate citations. The summary discarded attribution metadata upstream, so when the synthesis agent is asked to cite sources, it has no choice but to invent plausible-looking ones. This is a pipeline-design failure, not a prompt problem — and no amount of prompt engineering in the synthesis agent will fix it. The fix is structural: push attribution metadata into the handoff payload. Summaries are acceptable only when the downstream agent doesn't need to attribute or verify anything — and in multi-agent research, that's almost never the case.
-->

---

<script setup>
const takeaways = [
  { label: 'Each agent has only what you give it', detail: 'No ambient shared memory -- everything must be passed explicitly in system prompt, first user message, or tool result.' },
  { label: 'Structured payloads beat narrative summaries', detail: 'Always pass structured payloads whenever attribution or accuracy matters downstream.' },
  { label: 'Full claim payload has five fields', detail: 'Verbatim text, source URL, document name, page number, publication date, confidence level.' },
  { label: 'Never paraphrase when passing claims', detail: 'Verbatim preserves precision; paraphrase introduces drift the downstream agent cannot detect.' },
  { label: 'Match channel to context lifecycle', detail: 'Known context -> system prompt or first user. Dynamic context -> tool results. Never conflate.' },
  { label: 'Summaries without provenance cause citation fabrication', detail: 'Downstream will invent plausible-looking sources to fill the gap -- a pipeline-design failure.' },
]
</script>

<BulletReveal
  eyebrow="Takeaways"
  title="Explicit Context Passing — What to Remember"
  :bullets="takeaways"
  :footerNum="8"
  :footerTotal="8"
/>

<!--
Six things to carry forward. One — each agent has only what you give it; there's no ambient shared memory in a multi-agent system. Two — always pass structured payloads, never narrative summaries, when attribution or accuracy matters. Three — the full claim payload has five fields: verbatim text, source URL, document name, page or section, publication date, and confidence. Four — never paraphrase when passing claims; verbatim preserves precision. Five — match the injection channel to the context's lifecycle: known before the call goes in system prompt or first user message; dynamic context comes through tool results. And six — summaries that discard provenance cause downstream to fabricate citations, which is a pipeline-design failure, not a prompt problem. In Lecture 3.10 we shift from "what to pass" to "what to enforce": programmatic guarantees versus prompt-based guidance.
-->

---

<!-- LECTURE 3.10 - Programmatic Enforcement vs Prompt-Based Guidance -->

<Frame bg="var(--forest-900)" color="var(--mint-100)" :pad="false">
  <div style="position:absolute; inset:0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%);"></div>
  <div style="position:relative; z-index:1; padding:110px 120px 96px; width:100%; height:100%; display:flex; flex-direction:column; justify-content:space-between;">
    <div style="display:flex; align-items:center; gap:24px;">
      <img src="/assets/logo-mark.png" alt="" style="width:72px; height:auto;" />
      <div style="font-family: var(--font-body); font-size:26px; font-weight:500; letter-spacing:0.14em; text-transform:uppercase; color: var(--mint-200);">Dyer Innovation</div>
    </div>
    <div>
      <div style="font-family: var(--font-body); font-size:26px; font-weight:600; letter-spacing:0.16em; text-transform:uppercase; color: var(--sprout-500); margin-bottom:40px;">Lecture 3.10 &middot; Domain 1</div>
      <h1 style="font-family: var(--font-display); font-weight:500; font-size:128px; line-height:1.02; letter-spacing:-0.025em; color: var(--paper-0); margin:0; max-width:1600px;">Programmatic <span style="color: var(--sprout-500);">Enforcement</span><br />vs Prompt Guidance</h1>
      <div style="font-family: var(--font-display); font-size:44px; color: var(--mint-200); margin-top:40px; font-weight:400; max-width:1300px; line-height:1.3;">Deterministic code versus probabilistic prompts.</div>
    </div>
    <div style="display:flex; align-items:center; gap:48px; font-family: var(--font-body); font-size:26px; color: var(--mint-200); letter-spacing:0.06em;">
      <span>Domain 1 · 27%</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>Scenarios 1 &amp; 4</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>Sets up 3.11 hooks</span>
    </div>
  </div>
</Frame>

<!--
Welcome to Lecture 3.10 — Programmatic Enforcement vs Prompt-Based Guidance. This is one of the most frequently tested distinctions in Domain 1, and it's a distinction you have to internalize before the rest of the domain makes sense. Every rule in your agent system has a home: either your code enforces it, or your prompt requests it. Get the home wrong and you get production incidents. This lecture gives you the diagnostic test — and Lecture 3.11 will show you the mechanism.
-->

---

<script setup>
const progContent = "Your code prevents it -- unconditionally. The model never gets the opportunity to make a different choice. Reliability: deterministic. Example: block any refund > $500 in the tool execution layer."
const promptContent = "You instruct the model in the system prompt to follow a rule. The model generally will -- but it's a statistical outcome, not a guarantee. Reliability: probabilistic. Example: 'Always use a professional tone when responding to customers.'"
</script>

<TwoColSlide
  variant="compare"
  title="The Fundamental Fork: Deterministic vs Probabilistic"
  eyebrow="Two reliability models"
  leftLabel="Programmatic Enforcement"
  rightLabel="Prompt-Based Guidance"
  :footerNum="2"
  :footerTotal="8"
>
  <template #left>
    <p>{{ progContent }}</p>
  </template>
  <template #right>
    <p>{{ promptContent }}</p>
  </template>
</TwoColSlide>

<!--
Here's the fundamental fork. Programmatic enforcement means your code prevents a violation, unconditionally. The model never gets the opportunity to make a different choice — the guarantee lives in the tool execution layer, not in the prompt. Reliability is deterministic. If you block any refund over $500 in the refund tool, the refund is blocked — always. Prompt-based guidance is the opposite: you instruct the model in the system prompt, and the model generally follows the instruction — but "generally" is statistical, not guaranteed. Reliability is probabilistic. Asking the model to "always use a professional tone" is guidance. Blocking a tool call above a threshold is enforcement. These are not two flavors of the same thing; they're two different reliability models, and you choose between them based on the consequence of a violation.
-->

---

<script setup>
const enforceBullets = [
  { label: 'Financial operations', detail: 'Refund limits, transfer caps, transaction thresholds -- enforce in the tool execution layer, NOT the prompt.' },
  { label: 'Identity and authorization', detail: 'Only allow actions on resources the authenticated user owns -- verified by your code against your DB.' },
  { label: 'Compliance boundaries', detail: 'Data residency, PII handling, regulated data access -- legal consequences if violated.' },
  { label: 'Irreversible actions', detail: 'Deletions, sends, deployments -- require a confirmation gate in code, regardless of prompt.' },
]
</script>

<BulletReveal
  eyebrow="Enforce in code"
  title="When Programmatic Enforcement Is Required"
  :bullets="enforceBullets"
  :footerNum="3"
  :footerTotal="8"
/>

<!--
Four categories where programmatic enforcement is required. Financial operations: refund limits, transfer caps, transaction thresholds — enforce these in the tool execution layer, never in the prompt. A prompt instruction to "never refund more than $500" will work most of the time, and then one day it won't. Identity and authorization: only allow actions on resources the authenticated user actually owns. This is a correctness and security requirement that must be verified in code against your database, not described in a prompt. Compliance boundaries: data residency rules, PII handling, regulated data access — legal consequences if you violate them. Irreversible actions: deletions, emails, deployments — anything where "oops" is not recoverable needs a confirmation gate in code. The common thread: whenever the consequence of a violation is irreversible, financially material, legally significant, or a security risk, the rule belongs in code.
-->

---

<script setup>
const guideBullets = [
  { label: 'Tone and style', detail: "'Always respond professionally.' 'Avoid jargon.' Deviation is awkward, not catastrophic." },
  { label: 'Output format preferences', detail: "'Bullet points.' 'Markdown tables when comparing.' The model can exercise judgment." },
  { label: 'Scope guidance', detail: "'Focus on topics relevant to our product.' Violations are annoying, not harmful." },
  { label: 'UX preferences', detail: "'Ask clarifying questions when ambiguous.' Shape behavior without guarantees." },
]
</script>

<BulletReveal
  eyebrow="Prompt is enough"
  title="When Prompt-Based Guidance Is Appropriate"
  :bullets="guideBullets"
  :footerNum="4"
  :footerTotal="8"
/>

<!--
On the other side of the fork, four categories where prompt-based guidance is not only appropriate but preferable. Tone and style: "always respond professionally," "avoid jargon" — deviation here is awkward, not catastrophic. Output format preferences: bullets, tables, Markdown — the model can exercise judgment based on context. Scope guidance: "focus on topics relevant to our product" — violations are annoying, not harmful. UX preferences: "ask clarifying questions when ambiguous" — shapes behavior without requiring guarantees. The common thread: when "generally follows" is good enough, a prompt is the right tool. These are stylistic and behavioral, not financial or legal or safety-critical. A probabilistic instruction is exactly the right instrument for a probabilistic goal.
-->

---

<script setup>
const enforceCode = `# Programmatic enforcement -- the $500 limit is NOT in the system prompt.
def process_refund(order_id: str, amount_cents: int, user_id: str) -> dict:
    order = db.orders.get(order_id)

    # Authorization: only act on resources the user owns.
    if order.customer_id != user_id:
        return {
            "status": "error",
            "errorCategory": "authorization",
            "isRetryable": False,
            "description": f"User {user_id} not authorized for order {order_id}.",
        }

    # Financial limit -- enforced in code, not prompt.
    MAX_REFUND_CENTS = 50_000  # $500
    if amount_cents > MAX_REFUND_CENTS:
        return {
            "status": "error",
            "errorCategory": "limit_exceeded",
            "isRetryable": False,
            "description": (
                f"Refund of \${amount_cents/100:.2f} exceeds "
                f"auto-approval limit of $500. Escalate to human agent."
            ),
        }

    return db.process_refund(order_id, amount_cents)


# System prompt -- describes behavior but does NOT state the $500 limit.
SYSTEM_PROMPT = """
You are a customer support agent. Use the process_refund tool when
customers have a legitimate refund claim. Always respond empathetically
and professionally. Explain next steps clearly.
"""`
</script>

<CodeBlockSlide
  eyebrow="Code pattern"
  title="Programmatic Enforcement in Code"
  lang="python"
  :code="enforceCode"
  annotation="The $500 limit is in the code, not the prompt. Claude never gets the chance to bypass it. Structured error response tells Claude exactly how to recover."
  :footerNum="5"
  :footerTotal="8"
/>

<!--
Here's enforcement in practice. The process_refund function does two things before any refund executes. First, authorization: it checks that the authenticated user actually owns the order — if not, it returns a structured error with errorCategory, isRetryable, and a human-readable description. Second, the financial limit: $500 enforced in code. If the amount exceeds the cap, the tool returns a structured limit_exceeded error. Critically, the $500 figure appears only in the code — not in the system prompt. The system prompt describes tone and behavior: "respond empathetically, explain next steps clearly." It does NOT say "never refund more than $500." That limit does not belong in prose where it can be overridden or reasoned around. It belongs in the tool where Claude is physically incapable of exceeding it.
-->

---

<script setup>
const progLeft = [
  'Irreversible actions (delete, send, deploy)',
  'Financial thresholds and limits',
  'Identity and authorization checks',
  'Compliance and regulatory requirements',
  'Security controls (rate limits, input validation)',
  "Anything where 'almost always' is not good enough",
]
const promptRight = [
  'Tone, voice, and style',
  'Output format preferences',
  'Domain focus and scope',
  'Conversational behavior patterns',
  'Persona and branding guidelines',
  'Anything where judgment/flexibility is acceptable',
]
</script>

<TwoColSlide
  variant="compare"
  title="Decision Matrix: Which Mechanism to Use"
  eyebrow="Use this checklist"
  leftLabel="Use Programmatic Enforcement"
  rightLabel="Use Prompt-Based Guidance"
  :footerNum="6"
  :footerTotal="8"
>
  <template #left>
    <ul>
      <li v-for="(b, i) in progLeft" :key="i">{{ b }}</li>
    </ul>
  </template>
  <template #right>
    <ul>
      <li v-for="(b, i) in promptRight" :key="i">{{ b }}</li>
    </ul>
  </template>
</TwoColSlide>

<!--
A decision matrix you can apply on exam day and in production. On the left — programmatic enforcement — you get: irreversible actions, financial thresholds and limits, identity and authorization checks, compliance and regulatory requirements, security controls like rate limits and input validation, and anything where "almost always" is not good enough. On the right — prompt-based guidance — you get: tone and voice, output format preferences, domain focus and scope, conversational behavior patterns, persona and branding, and anything where judgment and flexibility are acceptable. The diagnostic test is simple: if a violation would require an incident response, it belongs in code. If a violation would just require a prompt update, it belongs in the prompt. That test answers almost every exam question in this category.
-->

---

<Frame>
  <Eyebrow>⚡ Exam tip</Eyebrow>
  <SlideTitle>The Probabilistic / Deterministic Distinction</SlideTitle>
  <div style="margin-top: 40px; display: grid; grid-template-columns: 1fr 1fr; gap: 32px; flex: 1; min-height: 0;">
    <v-clicks>
<CalloutBox variant="dont" title="Common wrong answer">
      <p>"Include the rule in the system prompt with emphasis — use ALL CAPS or multiple repetitions to ensure the model follows it."</p>
      <p>This is <strong>always wrong</strong> for financial, legal, safety, or irreversible constraints. Emphasis does not change the probabilistic nature of a prompt instruction.</p>
    </CalloutBox>
    <CalloutBox variant="do" title="Pattern to apply">
      <p>Ask: <em>is the consequence of violation a production incident?</em></p>
      <p>Yes → enforce in code: tool layer, middleware, pre-execution check. No → prompt instruction.</p>
    </CalloutBox>
</v-clicks>
  </div>
  <SlideFooter label="Domain 1 · Enforcement distinction" :num="7" :total="8" />
</Frame>

<!--
The exam trap. A question describes a scenario with a hard constraint — a financial limit, an authorization rule, something irreversible — and one of the distractor answers is "put it in the system prompt with emphasis, or repeat the rule multiple times." This answer is designed to look right because the rule IS about the model's behavior. But emphasis does not change the probabilistic nature of a prompt instruction. A system prompt that says "NEVER refund over $500" in all caps is still statistical — the model will usually follow it, and the one time it doesn't is a production incident. The decision rule: ask whether a violation would require incident response. If yes, enforce in code. If no, a prompt is fine. That's the whole exam-grade heuristic for this category.
-->

---

<script setup>
const takeaways = [
  { label: 'Programmatic enforcement = deterministic', detail: 'Code prevents violations unconditionally; the model never gets the chance to make a different call.' },
  { label: 'Prompt-based guidance = probabilistic', detail: 'The model generally follows instructions -- a statistical outcome, not a guarantee.' },
  { label: 'Use code for hard constraints', detail: 'Financial limits, authorization, compliance, irreversible actions, security controls.' },
  { label: 'Use prompts for soft preferences', detail: 'Tone, style, format preferences, domain scope, conversational behavior.' },
  { label: 'Diagnostic test', detail: "Ask: 'Would a violation require incident response?' Yes -> code. No -> prompt." },
  { label: 'Emphasis does not promote probabilistic to deterministic', detail: 'ALL CAPS, repetition, or strong wording in a system prompt does not change the statistical nature of the instruction.' },
]
</script>

<BulletReveal
  eyebrow="Takeaways"
  title="Programmatic Enforcement vs Prompt Guidance"
  :bullets="takeaways"
  :footerNum="8"
  :footerTotal="8"
/>

<!--
Six takeaways. One — programmatic enforcement is deterministic: your code prevents violations unconditionally. Two — prompt-based guidance is probabilistic: the model generally follows instructions, but it's a statistical outcome. Three — use code for financial limits, authorization, compliance, irreversible actions, and security controls. Four — use prompts for tone, style, format preferences, domain scope, and conversational behavior. Five — the diagnostic test: "would a violation require incident response?" Yes means code. No means prompt. And six — emphasis in a system prompt, even ALL CAPS or repetition, does NOT promote a probabilistic constraint to a deterministic one. In the next lecture, 3.11, we'll look at hooks — the specific Agent SDK mechanism that implements programmatic enforcement cleanly and centrally.
-->

---

<!-- LECTURE 3.11 - Agent SDK Hooks - PostToolUse and Tool Call Interception -->

<Frame bg="var(--forest-900)" color="var(--mint-100)" :pad="false">
  <div style="position:absolute; inset:0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%);"></div>
  <div style="position:relative; z-index:1; padding:110px 120px 96px; width:100%; height:100%; display:flex; flex-direction:column; justify-content:space-between;">
    <div style="display:flex; align-items:center; gap:24px;">
      <img src="/assets/logo-mark.png" alt="" style="width:72px; height:auto;" />
      <div style="font-family: var(--font-body); font-size:26px; font-weight:500; letter-spacing:0.14em; text-transform:uppercase; color: var(--mint-200);">Dyer Innovation</div>
    </div>
    <div>
      <div style="font-family: var(--font-body); font-size:26px; font-weight:600; letter-spacing:0.16em; text-transform:uppercase; color: var(--sprout-500); margin-bottom:40px;">Lecture 3.11 &middot; Domain 1</div>
      <h1 style="font-family: var(--font-display); font-weight:500; font-size:128px; line-height:1.02; letter-spacing:-0.025em; color: var(--paper-0); margin:0; max-width:1600px;">Agent SDK <span style="color: var(--sprout-500);">Hooks</span></h1>
      <div style="font-family: var(--font-display); font-size:44px; color: var(--mint-200); margin-top:40px; font-weight:400; max-width:1300px; line-height:1.3;">PostToolUse and tool call interception.</div>
    </div>
    <div style="display:flex; align-items:center; gap:48px; font-family: var(--font-body); font-size:26px; color: var(--mint-200); letter-spacing:0.06em;">
      <span>Domain 1 · 27%</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>Implements 3.10</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>Deterministic guarantees</span>
    </div>
  </div>
</Frame>

<!--
Welcome to Lecture 3.11 — Agent SDK Hooks: PostToolUse and Tool Call Interception. In the previous lecture we drew the line between programmatic enforcement and prompt-based guidance. Hooks are the specific mechanism the Agent SDK gives you to implement the programmatic side of that line. They're also exam-tested in their own right. By the end of this lecture you will know when to reach for PreToolUse, when to reach for PostToolUse, and how each delivers a centralized, deterministic guarantee that an individual tool function cannot.
-->

---

<script setup>
const flowContent = 'Claude emits tool_use block -> [PreToolUse hook: inspect / block / modify] -> Tool executes -> [PostToolUse hook: inspect / normalize / enrich] -> Result returned to Claude.'
const mechanics = [
  { label: 'PreToolUse', detail: 'Runs before the tool executes. Validate, enforce limits, or block unauthorized actions entirely.' },
  { label: 'PostToolUse', detail: 'Runs after the tool executes, before the result is returned to Claude. Normalize, enrich, or validate the output.' },
  { label: 'Key property', detail: 'Both are synchronous interception points -- stop the flow, modify data, or pass through.' },
]
</script>

<TwoColSlide
  variant="compare"
  title="Two Hook Points in the Agentic Loop"
  eyebrow="Where hooks run"
  leftLabel="Flow"
  rightLabel="Mechanics"
  :footerNum="2"
  :footerTotal="8"
>
  <template #left>
    <p>{{ flowContent }}</p>
    <p><strong>PreToolUse</strong> sits between Claude's tool_use block and the tool function. <strong>PostToolUse</strong> sits between the tool function's return and the result Claude sees.</p>
  </template>
  <template #right>
    <ul>
      <li v-for="(m, i) in mechanics" :key="i"><strong>{{ m.label }}.</strong> {{ m.detail }}</li>
    </ul>
  </template>
</TwoColSlide>

<!--
Here's where hooks fit in the agentic loop. Claude emits a tool_use block. Before the tool function runs, PreToolUse hooks get a chance to inspect the call, enforce limits, or block the execution entirely. The tool function then runs. Before the result is returned to Claude, PostToolUse hooks get a chance to normalize the data, enrich it, or validate it. Both are synchronous interception points — you can stop the flow, modify the data, or pass through unchanged. That's the structural picture. PreToolUse is for enforcement before side effects. PostToolUse is for data quality after execution. They are NOT the same hook in different coats — each has a specific job, and the exam will test which job belongs where.
-->

---

<script setup>
const postCode = `class TimestampNormalizationHook(PostToolUseHook):
    """Convert any Unix timestamps in tool results to ISO 8601."""

    def on_tool_result(self, tool_name: str, result: dict) -> dict:
        for key, value in list(result.items()):
            if key.endswith("_at") and isinstance(value, (int, float)):
                result[key] = datetime.fromtimestamp(
                    value, tz=timezone.utc
                ).isoformat()
        return result


# Register the hook with the agent loop so it applies to every tool.
agent = AgentLoop(
    model="claude-opus-4-7",
    tools=ALL_TOOLS,
    hooks=[TimestampNormalizationHook()],
)`
</script>

<CodeBlockSlide
  eyebrow="PostToolUse"
  title="Normalizing Tool Results"
  lang="python"
  :code="postCode"
  annotation="Claude reasons about dates in natural language; Unix 1711929600 is ambiguous, ISO 8601 is unambiguous. Register once — normalization applies to every tool, no per-tool changes."
  :footerNum="3"
  :footerTotal="8"
/>

<!--
Here's a canonical PostToolUse example: converting Unix timestamps to ISO 8601. The hook class overrides on_tool_result. For every tool that returns, it scans for fields ending in _at — a common naming convention for timestamps — and if the value is a number, it converts it to ISO 8601. The hook is registered once with the agent loop, and it applies to every tool call. Why it matters: Claude reasons about dates in natural language. The integer 1,711,929,600 is ambiguous — Claude might say "late March," but it can also miscount. ISO 8601 is unambiguous: 2024-04-01T00:00:00Z. Hook scope is centralized: you don't modify every tool function. One hook, one registration, applies globally.
-->

---

<script setup>
const preCode = `class RefundGuardHook(PreToolUseHook):
    """Block refunds above the auto-approval limit before execution."""

    max_refund_cents = 50_000  # $500

    def on_tool_call(self, tool_name: str, tool_input: dict, user):
        if tool_name != "process_refund":
            return  # pass through

        # Authorization gate
        order = db.orders.get(tool_input["order_id"])
        if order.customer_id != user.id:
            raise BlockToolCall(
                errorCategory="authorization",
                isRetryable=False,
                description=f"Order {order.id} not owned by user {user.id}.",
            )

        # Financial limit gate
        if tool_input["amount_cents"] > self.max_refund_cents:
            raise BlockToolCall(
                errorCategory="limit_exceeded",
                isRetryable=False,
                description=(
                    f"Refund of \${tool_input['amount_cents']/100:.2f} "
                    f"exceeds auto-approval limit of $500. "
                    f"Escalate to human agent."
                ),
            )`
</script>

<CodeBlockSlide
  eyebrow="PreToolUse"
  title="Blocking Unauthorized Tool Calls"
  lang="python"
  :code="preCode"
  annotation="BlockToolCall stops execution before the tool runs. The structured error becomes the tool_result Claude sees — it can explain the situation to the user."
  :footerNum="4"
  :footerTotal="8"
/>

<!--
And here's a canonical PreToolUse example: the RefundGuardHook. Two gates. First, authorization: the hook checks that the authenticated user actually owns the order the refund is being issued against. If not, it raises BlockToolCall with a structured error — errorCategory, isRetryable, description. Second, financial limit: if the refund amount exceeds $500, the hook raises BlockToolCall with errorCategory limit_exceeded. The critical property: BlockToolCall stops execution BEFORE the tool function runs. No partial refund. No side effect. The structured error becomes the tool_result Claude sees, which means Claude can explain the situation to the user — "I can't process refunds over $500 without a human's approval" — instead of silently failing. This is exactly the programmatic enforcement from Lecture 3.10, implemented cleanly as a hook.
-->

---

<script setup>
const useCases = [
  { label: 'PreToolUse -- Validation', detail: 'Check inputs before execution. Validate formats, required fields, data types.' },
  { label: 'PreToolUse -- Authorization', detail: 'Verify the user is allowed to invoke this tool with these inputs. Block unauthorized calls before any side effect.' },
  { label: 'PreToolUse -- Limit Enforcement', detail: 'Financial thresholds, rate limits, quota checks. Block with an explanatory error before execution.' },
  { label: 'PostToolUse -- Normalization', detail: 'Convert formats (Unix -> ISO 8601), normalize units, standardize field names.' },
  { label: 'PostToolUse -- Enrichment', detail: 'Add derived fields, resolve IDs to readable names, append metadata.' },
  { label: 'PostToolUse -- Audit Logging', detail: 'Log every tool invocation -- inputs, outputs, timestamps, user context.' },
]
</script>

<BulletReveal
  eyebrow="Use cases"
  title="Hook Use Cases at a Glance"
  :bullets="useCases"
  :footerNum="5"
  :footerTotal="8"
/>

<!--
Six common hook use cases. PreToolUse validation: check inputs before execution — formats, required fields, data types. PreToolUse authorization: verify the user is allowed to invoke this tool with these inputs, and block unauthorized calls before any side effect. PreToolUse limit enforcement: financial thresholds, rate limits, quota checks — all blocked with an explanatory error before execution. PostToolUse normalization: Unix to ISO 8601, unit conversion, field-name standardization. PostToolUse enrichment: resolving IDs to readable names, adding derived fields, appending metadata. PostToolUse audit logging: log every tool invocation with inputs, outputs, timestamps, and user context. The pattern: PreToolUse is for enforcement before execution. PostToolUse is for data quality after execution. Hold that dividing line in your head.
-->

---

<Frame>
  <Eyebrow>⚡ Exam tip</Eyebrow>
  <SlideTitle>Hooks vs Tool Logic vs Prompt Instructions</SlideTitle>
  <div style="margin-top: 40px; display: grid; grid-template-columns: 1fr 1fr; gap: 32px; flex: 1; min-height: 0;">
    <v-clicks>
<CalloutBox variant="dont" title="Trap answers">
      <p>Using a prompt instruction to enforce a financial limit — probabilistic, not guaranteed.</p>
      <p>Adding normalization logic inside every individual tool function — decentralized, breaks DRY, drifts over time.</p>
      <p>Putting authorization checks inside the tool function — too late if the tool has side effects before the check.</p>
    </CalloutBox>
    <CalloutBox variant="do" title="Hook rule">
      <p><strong>PreToolUse</strong> = enforcement before execution (limits, authorization, validation).</p>
      <p><strong>PostToolUse</strong> = data quality after execution (normalization, enrichment, logging).</p>
      <p>Hooks give centralized, deterministic guarantees — one registration, every matching tool call.</p>
    </CalloutBox>
</v-clicks>
  </div>
  <SlideFooter label="Domain 1 · Hook traps" :num="6" :total="8" />
</Frame>

<!--
Three traps the exam reliably tests. First: using a prompt instruction to enforce a financial limit. Probabilistic. Wrong. Hooks or tool-level code are the right answer. Second: adding normalization logic to every individual tool function. Works the first time, drifts over time, breaks DRY — a PostToolUse hook is centralized and consistent. Third: putting authorization checks inside the tool function rather than in a PreToolUse hook. If the tool does any work before the check, the check is too late — side effects may already have happened. The hook rule: PreToolUse is for enforcement before execution; PostToolUse is for data quality after execution; hooks are centralized and deterministic. One registration applies to every matching tool call — and that centralization is what turns a best-effort guideline into an actual guarantee.
-->

---

<script setup>
const takeaways = [
  { label: 'PreToolUse runs before execution', detail: 'Intercept, validate, authorize, or block the call before the tool side effect.' },
  { label: 'PostToolUse runs after execution', detail: 'Normalize, enrich, or log the result before Claude sees it.' },
  { label: 'Classic PostToolUse: Unix -> ISO 8601', detail: 'Converting timestamps so Claude reasons about dates unambiguously across every tool.' },
  { label: 'Classic PreToolUse: refund threshold block', detail: 'Block any refund above the financial limit before the tool executes.' },
  { label: 'Hooks are centralized, deterministic guarantees', detail: 'One hook applies to every matching tool call -- no per-tool drift.' },
  { label: 'Hooks are the mechanism for programmatic enforcement', detail: 'They are HOW you implement the deterministic guarantees from Lecture 3.10.' },
]
</script>

<BulletReveal
  eyebrow="Takeaways"
  title="Agent SDK Hooks — What to Know Cold"
  :bullets="takeaways"
  :footerNum="8"
  :footerTotal="8"
/>

<!--
Six takeaways to carry forward. One — PreToolUse runs before tool execution: intercept, validate, authorize, or block the call. Two — PostToolUse runs after tool execution: normalize, enrich, or log before Claude sees the result. Three — the classic PostToolUse example is converting Unix timestamps to ISO 8601 so Claude can reason about dates consistently. Four — the classic PreToolUse example is blocking a refund above the financial threshold before the tool executes. Five — hooks are centralized, deterministic guarantees: one hook registration applies to every matching tool call. And six — hooks are THE implementation mechanism for programmatic enforcement. When Lecture 3.10 said "enforce in code, not in the prompt," this is the code. In Lecture 3.12 we shift from runtime interception to task structure: how to decompose complex requests into sub-tasks, and when to choose a fixed chain versus a dynamic loop.
-->

---

<!-- LECTURE 3.12 - Task Decomposition - Prompt Chaining vs Dynamic Adaptive -->

<Frame bg="var(--forest-900)" color="var(--mint-100)" :pad="false">
  <div style="position:absolute; inset:0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%);"></div>
  <div style="position:relative; z-index:1; padding:110px 120px 96px; width:100%; height:100%; display:flex; flex-direction:column; justify-content:space-between;">
    <div style="display:flex; align-items:center; gap:24px;">
      <img src="/assets/logo-mark.png" alt="" style="width:72px; height:auto;" />
      <div style="font-family: var(--font-body); font-size:26px; font-weight:500; letter-spacing:0.14em; text-transform:uppercase; color: var(--mint-200);">Dyer Innovation</div>
    </div>
    <div>
      <div style="font-family: var(--font-body); font-size:26px; font-weight:600; letter-spacing:0.16em; text-transform:uppercase; color: var(--sprout-500); margin-bottom:40px;">Lecture 3.12 &middot; Domain 1</div>
      <h1 style="font-family: var(--font-display); font-weight:500; font-size:128px; line-height:1.02; letter-spacing:-0.025em; color: var(--paper-0); margin:0; max-width:1600px;">Task <span style="color: var(--sprout-500);">Decomposition</span></h1>
      <div style="font-family: var(--font-display); font-size:44px; color: var(--mint-200); margin-top:40px; font-weight:400; max-width:1300px; line-height:1.3;">Prompt chaining vs dynamic adaptive.</div>
    </div>
    <div style="display:flex; align-items:center; gap:48px; font-family: var(--font-body); font-size:26px; color: var(--mint-200); letter-spacing:0.06em;">
      <span>Domain 1 · 27%</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>Scenario 2 — Code Review Pipeline</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>Path C</span>
    </div>
  </div>
</Frame>

<!--
Welcome to Lecture 3.12 — Task Decomposition: Prompt Chaining vs Dynamic Adaptive. Every non-trivial agentic workflow is decomposed into sub-tasks. The exam-tested question is what KIND of decomposition to use. There are two main patterns — prompt chaining, where you define the steps upfront in code, and dynamic adaptive, where Claude decides the next step at runtime. This lecture gives you the decision rule and the safeguards each pattern needs to be production-safe.
-->

---

<ConceptHero
  eyebrow="Why decompose"
  concept="One question, many focused calls"
  supportLine="Single calls have context and attention limits. Focused prompts produce higher-quality outputs. Sub-tasks can be verified independently. Parallel execution is possible when steps are independent."
  footerLabel="Design question: fixed sequence → Prompt Chaining. Each step determines the next → Dynamic Adaptive."
  :footerNum="2"
  :footerTotal="8"
/>

<!--
Why decompose at all? Four reasons. First, single calls have context and attention limits — cramming an entire pipeline into one prompt degrades quality. Second, focused prompts produce higher-quality outputs than kitchen-sink prompts. Third, sub-tasks can be verified independently — you can test each step in isolation. And fourth, when sub-tasks are independent, you can execute them in parallel, which we covered in Lecture 3.8. Once you've decided to decompose, the design question is: is the sequence fixed in advance, or does each step determine the next? Fixed → prompt chaining. Each step determines the next → dynamic adaptive. That single question drives the rest of this lecture.
-->

---

<script setup>
const chainBullets = [
  'Steps defined upfront in code',
  "Each step receives the prior step's output",
  'Sequence never changes -- same order every time',
  'Easy to reason about, test, and debug',
  'Output quality of each step is independently verifiable',
]
const adaptiveBullets = [
  'Claude decides what to do next based on results',
  'Step sequence emerges from the task, not from code',
  'Handles novel paths and unexpected findings',
  'More powerful -- harder to predict and test',
  'Requires safeguards: loop limits, timeout, human checkpoints',
]
</script>

<TwoColSlide
  variant="compare"
  title="Prompt Chaining vs Dynamic Adaptive"
  eyebrow="Two decomposition patterns"
  leftLabel="Prompt Chaining (Fixed Sequential)"
  rightLabel="Dynamic Adaptive"
  :footerNum="3"
  :footerTotal="8"
>
  <template #left>
    <ul>
      <li v-for="(b, i) in chainBullets" :key="i">{{ b }}</li>
    </ul>
  </template>
  <template #right>
    <ul>
      <li v-for="(b, i) in adaptiveBullets" :key="i">{{ b }}</li>
    </ul>
  </template>
</TwoColSlide>

<!--
The two patterns side-by-side. Prompt chaining is fixed sequential — you define the steps in code, each step receives the prior step's output, the sequence never changes. It's easy to reason about, test, debug, and audit. Each step's output quality is independently verifiable. Dynamic adaptive is model-driven — Claude decides what to do next based on results, so the step sequence emerges from the task rather than from your code. It's more powerful for open-ended problems, it handles novel paths and unexpected findings, and it's harder to predict, test, and bound. It also requires safeguards: loop limits, timeouts, human checkpoints. The best fit for chaining: predictable workflows like code review, report generation, and structured analysis. The best fit for dynamic: open-ended investigation, debugging, research where the path depends on what you find.
-->

---

<script setup>
const chainCode = `def run_code_review_pipeline(repo_path: str, changed_files: list[str]) -> dict:
    """Fixed sequential pipeline. Same three steps every time."""

    # Step 1 -- per-file analysis (can be parallel internally, still fixed stage)
    per_file_findings = [
        analyze_single_file(path) for path in changed_files
    ]

    # Step 2 -- integration pass across all files
    integration_findings = analyze_integration(per_file_findings)

    # Step 3 -- synthesize the final report
    report = synthesize_report(per_file_findings, integration_findings)

    return report`
</script>

<CodeBlockSlide
  eyebrow="Example"
  title="Prompt Chaining — Code Review Pipeline"
  lang="python"
  :code="chainCode"
  annotation="The engineer determines the sequence, not Claude. Step 2 always follows Step 1. Testable, repeatable, auditable."
  :footerNum="4"
  :footerTotal="8"
/>

<!--
Here's prompt chaining in practice — the canonical code review pipeline. Step one: per-file analysis runs over every changed file. Step two: an integration pass looks across all the per-file findings for cross-file issues. Step three: synthesize the final report from both the per-file and integration findings. Three fixed steps. Step two always follows step one. Step three always follows step two. The sequence is determined by the engineer who wrote the pipeline, not by Claude at runtime. That's what makes this pattern testable, repeatable, and auditable — you can regression-test each stage independently, and the output of one run looks structurally identical to the next. Code review is the classic exam answer here: it's always prompt chaining, and the exam tests whether you know that.
-->

---

<script setup>
const adaptiveCode = `def run_investigation(initial_prompt: str, max_steps: int = 20) -> dict:
    """Dynamic adaptive -- Claude decides the next step each turn."""

    messages = [{"role": "user", "content": initial_prompt}]
    step_count = 0

    while step_count < max_steps:
        response = client.messages.create(
            model="claude-opus-4-7",
            tools=investigation_tools,
            messages=messages,
        )

        if response.stop_reason == "end_turn":
            return {"status": "complete", "result": response.content}

        if response.stop_reason == "tool_use":
            tool_results = execute_tools(response.content)
            messages.append({"role": "assistant", "content": response.content})
            messages.append({"role": "user", "content": tool_results})

        step_count += 1

    # Safety valve -- never ship dynamic adaptive without this.
    return summarize_partial_findings(messages)`
</script>

<CodeBlockSlide
  eyebrow="Example"
  title="Dynamic Adaptive — Open-Ended Investigation"
  lang="python"
  :code="adaptiveCode"
  annotation="max_steps is REQUIRED for dynamic adaptive. Without it, unexpected data could trigger infinite loops in production."
  :footerNum="5"
  :footerTotal="8"
/>

<!--
And here's dynamic adaptive — an investigation loop. The sequence is not defined in advance. On each turn, Claude decides whether to call a tool or stop. If stop_reason is end_turn, the investigation is complete. If stop_reason is tool_use, execute the tool, append the result to the conversation, and let Claude decide the next step. This is the right pattern for debugging a production incident where you don't know which logs to grep first, or for research where each document you read reshapes what you want to investigate next. Critical detail: the while-loop is bounded by max_steps. This safety valve is not optional. Without it, unexpected inputs — a page that keeps linking back to new pages, a log that keeps failing to parse — can trigger unbounded loops in production. If the loop hits the cap, we don't just error out; we summarize the partial findings so nothing learned is lost.
-->

---

<script setup>
const chooseSteps = [
  { title: 'Prompt chaining -- use when', body: 'Steps are known, sequence is fixed, correctness at each step is independently verifiable. Code review, report generation, data-transformation pipelines.' },
  { title: 'Dynamic adaptive -- use when', body: 'Task is open-ended, the relevant path depends on findings, and the task space is too large to enumerate upfront. Debugging, research, investigation.' },
  { title: 'Hybrid -- use when', body: 'Outer structure is known (phases) but each phase is open-ended. Phase 1 = gather evidence (dynamic). Phase 2 = write report (chained).' },
]
</script>

<StepSequence
  eyebrow="Choose strategy"
  title="Choosing the Right Decomposition Strategy"
  :steps="chooseSteps"
  footerLabel="Default to chaining unless the task requires dynamic"
  :footerNum="6"
  :footerTotal="8"
/>

<!--
Three scenarios and the right pattern for each. Prompt chaining — use when the steps are known, the sequence is fixed, and correctness at each step is independently verifiable. Code review. Report generation. Data-transformation pipelines. Dynamic adaptive — use when the task is open-ended, the relevant path depends on what you find, and the task space is too large to enumerate upfront. Debugging. Research. Investigation. Hybrid — use when the outer structure is known but each phase is open-ended. For example: phase one is gather evidence, and inside that phase Claude adapts. Phase two is write the report, and that phase is chained. Default posture: start with prompt chaining whenever you can define the steps. Only reach for dynamic adaptive when the task genuinely requires it — because dynamic pipelines are harder to test, audit, and bound.
-->

---

<Frame>
  <Eyebrow>⚡ Exam tip</Eyebrow>
  <SlideTitle>Recognising the Right Decomposition Strategy</SlideTitle>
  <div style="margin-top: 40px; display: grid; grid-template-columns: 1fr 1fr; gap: 32px; flex: 1; min-height: 0;">
    <v-clicks>
<CalloutBox variant="dont" title="Common trap">
      <p>Choosing dynamic adaptive for a code-review pipeline because "Claude should be flexible."</p>
      <p>Code review has well-defined steps: per-file → cross-file → report. Fixed chaining is correct. Dynamic only adds complexity without benefit.</p>
    </CalloutBox>
    <CalloutBox variant="do" title="Decision rule">
      <p>Can you enumerate the steps before the task starts? <strong>Yes → prompt chaining. No → dynamic adaptive.</strong></p>
      <p>In both cases: define safety limits — max_steps, timeout, human checkpoints.</p>
    </CalloutBox>
</v-clicks>
  </div>
  <SlideFooter label="Domain 1 · Decomposition" :num="7" :total="8" />
</Frame>

<!--
The exam trap. A question describes a code-review pipeline, and one of the distractor answers is "use dynamic adaptive so Claude can be flexible." Tempting, but wrong. Code review has well-defined steps — per-file analysis, then cross-file integration, then report synthesis. The sequence never changes. Fixed chaining is correct because it's testable, bounded, and predictable. Dynamic adaptive in this scenario adds complexity with no benefit — you'd have to pay for safety rails that aren't solving a real problem. Decision rule: can you enumerate the steps before the task starts? Yes → prompt chaining. No → dynamic adaptive. And in both cases, define safety limits — max_steps, timeout, human checkpoints for high-risk actions. That rule answers almost every decomposition question on the exam.
-->

---

<script setup>
const takeaways = [
  { label: 'Prompt chaining = fixed sequence in code', detail: 'Predictable, testable, each step is independently verifiable.' },
  { label: 'Dynamic adaptive = model-driven', detail: 'Claude decides the next step based on results; requires explicit safety limits.' },
  { label: 'Code review is always prompt chaining', detail: 'Per-file -> cross-file integration -> report. Fixed steps, never dynamic.' },
  { label: 'Dynamic adaptive requires a max_steps cap', detail: 'Without it, unexpected data can cause unbounded loops in production.' },
  { label: 'Default to chaining when steps are known', detail: 'Only use dynamic adaptive when the path genuinely depends on runtime findings.' },
  { label: 'Hybrid is valid', detail: 'Fixed phase boundaries with dynamic execution inside each phase is a common production pattern.' },
]
</script>

<BulletReveal
  eyebrow="Takeaways"
  title="Task Decomposition — What to Remember"
  :bullets="takeaways"
  :footerNum="8"
  :footerTotal="8"
/>

<!--
Six takeaways. One — prompt chaining is a fixed sequence in code: predictable, testable, independently verifiable. Two — dynamic adaptive is model-driven: Claude decides the next step at runtime, and it requires explicit safety limits. Three — code review is always prompt chaining: per-file, then cross-file integration, then report. Never dynamic. Four — dynamic adaptive requires a max_steps cap; without it, unexpected data can cause unbounded loops. Five — default to chaining when steps are known; reach for dynamic only when the path genuinely depends on runtime findings. And six — hybrid is a valid production pattern: fixed phase boundaries with dynamic execution inside each phase. In Lecture 3.13 we look at session management — how to resume, fork, or start fresh when a workflow spans multiple sessions.
-->

---

<!-- LECTURE 3.13 - Session Management - resume, fork_session, When to Start Fresh -->

<Frame bg="var(--forest-900)" color="var(--mint-100)" :pad="false">
  <div style="position:absolute; inset:0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%);"></div>
  <div style="position:relative; z-index:1; padding:110px 120px 96px; width:100%; height:100%; display:flex; flex-direction:column; justify-content:space-between;">
    <div style="display:flex; align-items:center; gap:24px;">
      <img src="/assets/logo-mark.png" alt="" style="width:72px; height:auto;" />
      <div style="font-family: var(--font-body); font-size:26px; font-weight:500; letter-spacing:0.14em; text-transform:uppercase; color: var(--mint-200);">Dyer Innovation</div>
    </div>
    <div>
      <div style="font-family: var(--font-body); font-size:26px; font-weight:600; letter-spacing:0.16em; text-transform:uppercase; color: var(--sprout-500); margin-bottom:40px;">Lecture 3.13 &middot; Domain 1</div>
      <h1 style="font-family: var(--font-display); font-weight:500; font-size:128px; line-height:1.02; letter-spacing:-0.025em; color: var(--paper-0); margin:0; max-width:1600px;">Session <span style="color: var(--sprout-500);">Management</span></h1>
      <div style="font-family: var(--font-display); font-size:44px; color: var(--mint-200); margin-top:40px; font-weight:400; max-width:1300px; line-height:1.3;">Resume, fork_session, and when to start fresh.</div>
    </div>
    <div style="display:flex; align-items:center; gap:48px; font-family: var(--font-body); font-size:26px; color: var(--mint-200); letter-spacing:0.06em;">
      <span>Domain 1 · 27%</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>Path C — Agent Architect</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>Context lifecycle</span>
    </div>
  </div>
</Frame>

<!--
Welcome to Lecture 3.13 — Session Management: resume, fork_session, and when to start fresh. A non-trivial agentic workflow almost always lives across more than one session. Sometimes a session gets interrupted. Sometimes you need two parallel branches from the same starting point. Sometimes the context you've accumulated is actively wrong and needs to be discarded. The Agent SDK gives you three primitives — resume, fork, and start-fresh-with-summary — and each has a specific situation where it is the right call. This lecture is about recognising the signals that pick which one.
-->

---

<script setup>
const decisions = [
  { label: 'Resume (--resume)', detail: "Continue from exactly where the session left off. Full history -- tool calls, results, reasoning -- available to Claude." },
  { label: 'Fork (fork_session)', detail: 'Duplicate the current context and start two independent branches from the same baseline. Explore divergent approaches without cross-contamination.' },
  { label: 'Start Fresh', detail: 'New session with no prior history. Inject a structured summary of what was learned. Use when prior raw context is stale or too expensive.' },
]
</script>

<BulletReveal
  eyebrow="Three decisions"
  title="The Three Session Management Decisions"
  :bullets="decisions"
  :footerNum="2"
  :footerTotal="8"
/>

<!--
Here are the three primitives at a glance. Resume, with the --resume flag, continues from exactly where the session left off — the full history, tool calls, results, and reasoning are all available to Claude. Fork, with fork_session, duplicates the current context and starts two independent branches from the same baseline — letting you explore divergent approaches without cross-contamination. Start fresh is a new session with no prior history, where you inject a structured summary of what was learned instead of carrying the raw history forward. That's the full menu. The rest of this lecture is about when each is appropriate.
-->

---

<script setup>
const resumeSteps = [
  { title: 'Interrupted task', body: 'Session cut off mid-execution -- network failure, timeout, graceful pause. Context still accurate. Resume.' },
  { title: 'Multi-phase work', body: 'Phase 1 completed with stable results. Phase 2 builds directly on Phase 1 output. Resume and continue.' },
  { title: 'Tool result reuse', body: 'Claude already retrieved data that is still current. Resuming avoids redundant tool calls -- saves latency and cost.' },
]
</script>

<StepSequence
  eyebrow="Resume path"
  title="When to Resume a Session"
  :steps="resumeSteps"
  footerLabel="Do NOT resume when tool results reference live data that has changed"
  :footerNum="3"
  :footerTotal="8"
/>

<!--
Three situations where resume is the right choice. First, an interrupted task: the session was cut off mid-execution because of a network failure, a timeout, or a graceful pause. The context is still accurate — nothing has changed. Resume. Second, multi-phase work: phase one completed with stable results, and phase two builds directly on phase one's output. Resume and continue. Third, tool result reuse: Claude already retrieved data that is still current. Resuming avoids redundant tool calls and saves latency and cost. The important contra-rule: do NOT resume when tool results reference live data that has since changed. Resuming in that case means Claude reasons on stale context — and that causes incorrect decisions, not just suboptimal ones. We'll come back to this on the next two slides.
-->

---

<script setup>
const forkBaseline = 'Same research findings, same document context, same task history -> Branch A: approach 1 · Branch B: approach 2. Both branches evolve independently.'
const forkUses = [
  { label: 'A/B evaluation', detail: 'Generate two candidate outputs from the same context for human review or automated scoring. Forking prevents cross-contamination.' },
  { label: 'Hypothesis testing', detail: 'Explore two investigative paths from the same starting evidence. A dead-end in one branch leaves the other unaffected.' },
]
</script>

<TwoColSlide
  variant="compare"
  title="When to Fork a Session"
  eyebrow="Branch from a shared baseline"
  leftLabel="Shared baseline"
  rightLabel="Use cases"
  :footerNum="4"
  :footerTotal="8"
>
  <template #left>
    <p>{{ forkBaseline }}</p>
    <p>Forking is cheaper than running two independent sessions from scratch — the shared baseline is only established once.</p>
  </template>
  <template #right>
    <ul>
      <li v-for="(u, i) in forkUses" :key="i"><strong>{{ u.label }}.</strong> {{ u.detail }}</li>
    </ul>
  </template>
</TwoColSlide>

<!--
Fork is the right primitive when you need divergent branches from the same trusted starting point. Picture a research session that has established a solid baseline — the same research findings, the same document context, the same task history. You want branch A to pursue one approach and branch B to pursue another. Both need to evolve independently, without cross-contamination. Two classic use cases. A/B evaluation: generate two candidate outputs from the same context for human review or automated scoring — forking prevents one branch's output from influencing the other. Hypothesis testing: explore two investigative paths from the same starting evidence, so that a dead-end in one branch leaves the other unaffected. Key property: forking is cheaper than running two independent sessions from scratch, because the baseline doesn't have to be re-established twice.
-->

---

<script setup>
const freshSteps = [
  { title: 'Stale tool results', body: 'Session has tool outputs referencing live data that has changed. Carrying forward causes incorrect reasoning. Summarize what was LEARNED (conclusions), discard raw results.' },
  { title: 'Context window pressure', body: 'Session history is large and approaching limits. Use /compact for in-session reduction, or start fresh for a clean slate.' },
  { title: 'Phase boundary with different tools', body: 'Phase 2 needs a different tool set and system prompt. Start fresh and inject Phase 1 conclusions as structured input.' },
]
</script>

<StepSequence
  eyebrow="Fresh start path"
  title="When to Start Fresh with an Injected Summary"
  :steps="freshSteps"
  footerLabel="Summary = conclusions and validated facts only — never raw tool outputs"
  :footerNum="5"
  :footerTotal="8"
/>

<!--
Start-fresh is the right primitive in three situations. First, stale tool results: the session has tool outputs that reference live data — stock prices, inventory, user status — that has since changed. Carrying the old outputs forward causes Claude to reason on incorrect data. Start fresh. Summarize what was LEARNED — the conclusions — and discard the raw results. Second, context-window pressure: the session history is large and approaching limits. Use /compact for in-session reduction when the history is still current, or start fresh for a clean slate. Third, phase boundary with different tools: phase two needs a different tool set and a different system prompt than phase one. Don't pollute the new system prompt with the old history — start fresh and inject phase one's conclusions as structured input. In all three cases, the injected summary carries conclusions and validated facts — never raw tool outputs.
-->

---

<script setup>
const freshCode = `def build_session_summary(prior_session_messages: list[dict]) -> str:
    """Extract validated conclusions from a completed session."""

    prompt = (
        "Review the conversation below and produce a structured summary "
        "containing ONLY:\\n"
        "  - Validated findings (facts confirmed by tool results)\\n"
        "  - Decisions made and their rationale\\n"
        "  - Open questions that remain\\n\\n"
        "Do NOT include raw tool outputs, timestamps, or step-by-step history.\\n\\n"
        f"<conversation>\\n{format_messages(prior_session_messages)}\\n</conversation>"
    )

    response = client.messages.create(
        model="claude-opus-4-7",
        messages=[{"role": "user", "content": prompt}],
    )
    return response.content[0].text


def start_fresh_with_summary(prior_summary: str, next_task_prompt: str):
    """Begin a new session with injected conclusions -- no stale tool results."""

    return client.messages.create(
        model="claude-opus-4-7",
        system=PHASE_2_SYSTEM_PROMPT,
        messages=[{
            "role": "user",
            "content": (
                f"<prior_summary>\\n{prior_summary}\\n</prior_summary>\\n\\n"
                f"{next_task_prompt}"
            ),
        }],
    )`
</script>

<CodeBlockSlide
  eyebrow="Code pattern"
  title="The Fresh Start + Injected Summary Pattern"
  lang="python"
  :code="freshCode"
  annotation="The new session has accurate, current context — no stale tool results. The summary carries conclusions, not raw history."
  :footerNum="6"
  :footerTotal="8"
/>

<!--
Here's the pattern in code. build_session_summary takes the prior session's messages and produces a structured summary using a specific prompt: include validated findings, decisions, and open questions; exclude raw tool outputs, timestamps, and step-by-step history. That constraint is the whole point — you're extracting conclusions, not compressing the transcript. Then start_fresh_with_summary opens a brand-new session with the phase-two system prompt and injects the prior summary inside a clearly tagged block in the first user message. The new session now has accurate, current context — no stale tool results dragging it into wrong conclusions. This is the pattern that makes long-horizon multi-session work viable: conclusions carry forward, raw history does not.
-->

---

<Frame>
  <Eyebrow>⚡ Exam tip</Eyebrow>
  <SlideTitle>Matching the Scenario to the Session Strategy</SlideTitle>
  <div style="margin-top: 40px; display: grid; grid-template-columns: 1fr 1fr; gap: 32px; flex: 1; min-height: 0;">
    <v-clicks>
<CalloutBox variant="dont" title="Traps to watch for">
      <p>Resuming a session whose tool results reference live data that has since changed — causes <strong>incorrect</strong> reasoning, not just inefficiency.</p>
      <p>Using fork_session when you just need to restart — fork preserves history, it doesn't clean it.</p>
      <p>Starting fresh without injecting context — the new session has no knowledge of prior findings.</p>
    </CalloutBox>
    <CalloutBox variant="do" title="Decision signals">
      <p><strong>Resume:</strong> context still valid.</p>
      <p><strong>Fork:</strong> divergent branches from a shared baseline.</p>
      <p><strong>Start fresh:</strong> stale results OR context-window pressure → inject a structured summary.</p>
      <p><strong>/compact:</strong> context large but still valid — reduce without discarding.</p>
    </CalloutBox>
</v-clicks>
  </div>
  <SlideFooter label="Domain 1 · Session strategy" :num="7" :total="8" />
</Frame>

<!--
The exam-tested traps in this area. Trap one: resuming a session whose tool results reference live data that has since changed. This is worse than it sounds — Claude doesn't know the data is stale, so it reasons confidently on wrong context. That produces incorrect outputs, not just inefficient ones. Trap two: using fork_session when what you actually need is a restart. Fork preserves history; if that history is the problem, forking just duplicates it. Trap three: starting fresh without injecting a summary — the new session has zero knowledge of prior findings, so anything you learned is gone. The decision signals: resume when context is still valid; fork for divergent branches from a shared baseline; start fresh with an injected summary when results are stale or the window is under pressure; use /compact when the context is large but still valid.
-->

---

<script setup>
const takeaways = [
  { label: 'Resume when context is still valid', detail: 'Interrupted tasks, stable multi-phase work, reuse of still-current tool results.' },
  { label: 'Fork for divergent branches from a shared baseline', detail: 'A/B evaluation and hypothesis testing -- both branches start from the same trusted context.' },
  { label: 'Start fresh when results are stale or window is full', detail: 'Inject a structured summary of conclusions; never carry raw stale tool outputs.' },
  { label: 'Stale tool results cause INCORRECT reasoning', detail: 'Not just inefficiency -- Claude will make wrong decisions on data that has since changed.' },
  { label: '/compact reduces size without discarding accuracy', detail: 'In-session compaction is right when the history is large but still current.' },
  { label: 'Injected summaries carry conclusions, never raw history', detail: 'Validated facts and decisions only -- no tool-result snapshots, no transcripts.' },
]
</script>

<BulletReveal
  eyebrow="Takeaways"
  title="Session Management — What to Remember"
  :bullets="takeaways"
  :footerNum="8"
  :footerTotal="8"
/>

<!--
Six takeaways. One — resume when context is still valid: interrupted tasks, stable multi-phase work. Two — fork when you need divergent branches from a shared baseline: A/B evaluation, hypothesis testing. Three — start fresh with an injected summary when tool results are stale or the context window is under pressure. Four — stale tool results cause INCORRECT reasoning, not just inefficiency; always start fresh and inject a summary in that case. Five — /compact reduces context size in-session when the history is still accurate. And six — the injected summary carries conclusions and validated facts; it never carries raw tool output. Lecture 3.14 closes this section with the final decision in the agentic loop: when you have to escalate to a human, how do you hand off structured context so the human isn't starting from scratch?
-->

---

<!-- LECTURE 3.14 - Structured Handoff Summaries for Human Escalation -->

<Frame bg="var(--forest-900)" color="var(--mint-100)" :pad="false">
  <div style="position:absolute; inset:0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%);"></div>
  <div style="position:relative; z-index:1; padding:110px 120px 96px; width:100%; height:100%; display:flex; flex-direction:column; justify-content:space-between;">
    <div style="display:flex; align-items:center; gap:24px;">
      <img src="/assets/logo-mark.png" alt="" style="width:72px; height:auto;" />
      <div style="font-family: var(--font-body); font-size:26px; font-weight:500; letter-spacing:0.14em; text-transform:uppercase; color: var(--mint-200);">Dyer Innovation</div>
    </div>
    <div>
      <div style="font-family: var(--font-body); font-size:26px; font-weight:600; letter-spacing:0.16em; text-transform:uppercase; color: var(--sprout-500); margin-bottom:40px;">Lecture 3.14 &middot; Domain 1</div>
      <h1 style="font-family: var(--font-display); font-weight:500; font-size:128px; line-height:1.02; letter-spacing:-0.025em; color: var(--paper-0); margin:0; max-width:1600px;">Structured <span style="color: var(--sprout-500);">Handoff</span> Summaries</h1>
      <div style="font-family: var(--font-display); font-size:44px; color: var(--mint-200); margin-top:40px; font-weight:400; max-width:1300px; line-height:1.3;">For human escalation in customer support and beyond.</div>
    </div>
    <div style="display:flex; align-items:center; gap:48px; font-family: var(--font-body); font-size:26px; color: var(--mint-200); letter-spacing:0.06em;">
      <span>Domain 1 · 27%</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>Scenario 1 — Customer Support</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>Sets up Trust &amp; Safety</span>
    </div>
  </div>
</Frame>

<!--
Welcome to Lecture 3.14 — Structured Handoff Summaries for Human Escalation. This is the closer for Section 3, and the capstone of the human-in-the-loop story inside Domain 1. Every production agent eventually hits a situation it cannot resolve autonomously — a refund above a limit, an authorization edge case, an ambiguous request. When that happens, the agent hands off to a human. Whether the human experience is thirty seconds of reading or five minutes of spelunking depends on the structure of that handoff. This lecture shows you the five required fields and the code pattern that enforces them.
-->

---

<script setup>
const withoutBullets = [
  'Human reads from the top -- wasting 3-5 minutes on context',
  'May miss a critical detail buried in tool output #7',
  'May re-run steps the agent already tried',
  'Has to guess at the recommended action',
]
const withBullets = [
  'Human reads one concise summary -- 30 seconds',
  'Knows exactly what was found, tried, and recommended',
  'Starts from where the agent stopped -- no duplicated work',
  'Can make a decision immediately',
]
</script>

<TwoColSlide
  variant="antipattern-fix"
  title="Humans Don't Have the Transcript"
  eyebrow="Why structure matters"
  leftLabel="❌ Without structured handoff"
  rightLabel="✓ With structured handoff"
  :footerNum="2"
  :footerTotal="7"
>
  <template #left>
    <ul>
      <li v-for="(b, i) in withoutBullets" :key="i">{{ b }}</li>
    </ul>
  </template>
  <template #right>
    <ul>
      <li v-for="(b, i) in withBullets" :key="i">{{ b }}</li>
    </ul>
  </template>
</TwoColSlide>

<!--
Here's the reality you have to design for. Human agents do not have the transcript. They do not see the tool calls the agent made. They do not see the reasoning the agent went through. Without a structured handoff, the human reads from the top, wastes three to five minutes piecing context together, may miss a critical detail buried in tool output number seven, may re-run steps the agent already tried, and ultimately has to guess at the recommended action. With a structured handoff, the human reads one concise summary in thirty seconds, knows exactly what was found and tried and recommended, starts from where the agent stopped with no duplicated work, and can make a decision immediately. That delta — five minutes of scavenger hunt versus thirty seconds of reading — is what this lecture designs for.
-->

---

<script setup>
const requiredFields = [
  { label: 'Who is this about?', detail: 'Customer ID, account number, case identifier. The human must pull up the right record instantly.' },
  { label: 'What happened?', detail: 'Root cause the agent determined -- with relevant amounts, dates, identifiers.' },
  { label: 'What was already tried?', detail: 'Every action attempted -- succeeded, failed, and why. The human must not retry failed approaches.' },
  { label: 'What is recommended?', detail: 'Specific action + the reason the agent cannot execute it autonomously (limit exceeded, authorization, ambiguity).' },
  { label: 'What is the urgency?', detail: 'Priority level + time constraints -- for triage across multiple escalations.' },
]
</script>

<BulletReveal
  eyebrow="The five required fields"
  title="What a Handoff Summary Must Include"
  :bullets="requiredFields"
  :footerNum="3"
  :footerTotal="7"
/>

<!--
The five required fields of any complete handoff. One — who is this about? Customer ID, account number, case identifier. The human needs to pull up the right record instantly. Two — what happened? The root cause the agent determined, with relevant amounts, dates, and identifiers. Not prose — specifics. Three — what was already tried? Every action the agent attempted, including the ones that failed and why. The human must not retry an approach the agent already ruled out. Four — what is recommended? A specific action, plus the reason the agent cannot execute it autonomously — limit exceeded, authorization required, ambiguity in the request. And five — what is the urgency? A priority level plus any time constraints, so the human team can triage across multiple escalations. Five fields. Not four. Not six. Miss one and the handoff leaks value.
-->

---

<script setup>
const handoffCode = `from dataclasses import dataclass

@dataclass
class HandoffSummary:
    customer_id: str
    case_id: str
    order_id: str
    urgency: str            # 'routine' | 'elevated' | 'urgent'
    situation: str          # root cause with specifics
    actions_tried: list[dict]   # each: {action, outcome, reason}
    recommendation: str     # specific action + why agent cannot execute
    escalation_reason: str  # limit exceeded / authorization / ambiguity


def generate_handoff_summary(session_state) -> HandoffSummary:
    """Build the structured summary from verified fields -- NOT the transcript."""

    prompt = (
        "Produce a HandoffSummary JSON object. Use only these VERIFIED fields:\\n"
        f"customer_id: {session_state.customer_id}\\n"
        f"case_id: {session_state.case_id}\\n"
        f"order_id: {session_state.order_id}\\n"
        f"verified_actions: {session_state.action_log}\\n"
        f"limit_check_result: {session_state.limit_check}\\n"
        f"auth_check_result: {session_state.auth_check}\\n\\n"
        "Rules:\\n"
        "  - Do NOT invent details not in the verified fields.\\n"
        "  - Every action in actions_tried must appear in verified_actions.\\n"
        "  - If a field is missing, return null -- do not fabricate."
    )

    return _parse_summary(
        client.messages.create(
            model="claude-opus-4-7",
            messages=[{"role": "user", "content": prompt}],
            tool_choice={"type": "tool", "name": "emit_handoff_summary"},
            tools=[HANDOFF_TOOL_SCHEMA],
        )
    )`
</script>

<CodeBlockSlide
  eyebrow="Code pattern"
  title="Generating a Structured Handoff Summary"
  lang="python"
  :code="handoffCode"
  annotation="Structured data model FIRST — never ask Claude to 'summarize the conversation.' Extract verified fields, then generate the handoff from those fields."
  :footerNum="4"
  :footerTotal="7"
/>

<!--
Here's the implementation pattern. We define a HandoffSummary dataclass with the five required fields as concrete attributes — customer, case, order IDs; urgency; situation; actions tried; recommendation; escalation reason. Then generate_handoff_summary builds the handoff FROM a structured session_state, not from a transcript. The prompt feeds Claude only verified fields — action log, limit-check result, auth-check result — and explicitly tells it: do not invent details, every action in actions_tried must appear in verified_actions, and return null for missing fields rather than fabricate. We use tool_choice to force structured output. The key design principle: extract the verified fields first, then generate the handoff from those fields. Never ask Claude to "summarize the conversation" — that prompt is open-ended enough that critical details get dropped or irrelevant history gets included.
-->

---

<!-- TODO: consider dedicated EscalationDocument component for layout fidelity -->
<ConceptHero
  eyebrow="Example output · URGENT"
  concept="Customer: CUST-48291 · Case: CASE-20241104-007"
  leadLine="$750 refund for damaged order — verified. Exceeds $500 auto-approval. Four-year customer requesting full refund after declining the $500 partial."
  supportLine="WHAT WAS TRIED: account lookup ✓ · damage verified ✓ · auto-refund blocked (limit exceeded) ✗ · partial $500 offered, declined by customer ✗. RECOMMENDATION: approve full $750 refund — legitimate claim, long-standing customer. Suggested response: apologise, issue refund, add $25 goodwill credit."
  footerLabel="Every element maps to one of the five required fields — nothing missing, nothing filler"
  :footerNum="5"
  :footerTotal="7"
/>

<!--
Here's what a handoff looks like when the pattern is working. Notice how every element maps to one of the five required fields. Who: customer CUST-48291, case CASE-20241104-007, order ORD-88401. What happened: $750 refund for damaged order, verified, which exceeds the $500 auto-approval limit — customer is four years long, declined the partial $500. What was tried: four concrete actions with outcomes — account lookup succeeded, damage verified, auto-refund blocked by the limit check, partial $500 offered and declined. What is recommended: approve the full $750, because the claim is legitimate and the customer is long-standing — plus a suggested response that apologises, issues the refund, and adds a $25 goodwill credit. Urgency: URGENT. Nothing missing. Nothing filler. The human reads that in thirty seconds and decides.
-->

---

<Frame>
  <Eyebrow>⚡ Exam tip</Eyebrow>
  <SlideTitle>What a Handoff Must Include — and the Missing Field Trap</SlideTitle>
  <div style="margin-top: 40px; display: grid; grid-template-columns: 1fr 1fr; gap: 32px; flex: 1; min-height: 0;">
    <v-clicks>
<CalloutBox variant="dont" title="Incomplete handoff">
      <p>"Customer is unhappy about a damaged order. Please help them."</p>
      <p>Missing: customer ID, order ID, damage verification, amounts, what was tried, recommendation. The human must start from scratch — the handoff provided zero value.</p>
    </CalloutBox>
    <CalloutBox variant="do" title="Five required fields">
      <p>1. <strong>Who</strong> — customer, case, order identifiers.</p>
      <p>2. <strong>What happened</strong> — root cause with specifics.</p>
      <p>3. <strong>What was tried</strong> — actions with outcomes.</p>
      <p>4. <strong>What is recommended</strong> — specific action + reason agent cannot proceed.</p>
      <p>5. <strong>Urgency</strong> — priority for triage.</p>
    </CalloutBox>
</v-clicks>
  </div>
  <SlideFooter label="Domain 1 · Handoff traps" :num="6" :total="7" />
</Frame>

<!--
The exam trap. A question shows an incomplete handoff — something like "customer is unhappy about a damaged order, please help them" — and asks what's wrong with it. Wrong answers will point at tone or format issues. The right answer: missing fields. No customer ID, no order ID, no damage verification, no amount, no record of what was tried, no recommendation. The human agent has to start from scratch — the handoff provided zero value. The five-field checklist is the answer. Who, what happened, what was tried, what is recommended, urgency. If any one of those is missing, the handoff is incomplete by design, and the downstream human experience degrades correspondingly.
-->

---

<script setup>
const takeaways = [
  { label: "Human agents don't have the transcript", detail: 'Everything the AI learned must be explicitly communicated in the handoff.' },
  { label: 'A complete handoff answers five questions', detail: 'Who, what happened, what was tried, what is recommended, urgency.' },
  { label: 'Always include verified identifiers', detail: 'Customer/case ID, root cause with specifics, actions attempted with outcomes, the recommended action, and the reason for escalation.' },
  { label: 'Structured data model FIRST', detail: 'Extract verified fields from the session, then generate the handoff FROM those fields.' },
  { label: 'Never ask Claude to "summarize the conversation"', detail: 'The agent may omit critical details or include irrelevant history if left unconstrained.' },
  { label: 'Handoffs without "what was tried" cause duplicated work', detail: 'The human re-runs steps the agent already completed -- wasted time, degraded UX.' },
]
</script>

<BulletReveal
  eyebrow="Takeaways"
  title="Structured Handoff Summaries — What to Remember"
  :bullets="takeaways"
  :footerNum="7"
  :footerTotal="7"
/>

<!--
Six takeaways to close Section 3. One — human agents do not have the transcript, so everything the AI learned must be explicitly communicated in the handoff. Two — a complete handoff answers five questions: who, what happened, what was tried, what is recommended, and urgency. Three — always include verified identifiers, root cause with specifics, actions attempted with outcomes, the recommended action, and the reason for escalation. Four — build the structured data model FIRST, extract the verified fields, and generate the handoff FROM those fields. Five — never ask Claude to "summarize the conversation" without constraints; the agent may omit critical details or include irrelevant history. And six — handoffs without a "what was tried" field cause the human to duplicate work, which is the single biggest UX failure in AI-assisted support. That wraps Section 3. Everything you've learned here — the loop, the subagents, the context passing, the enforcement, the hooks, the decomposition, the sessions, and now the escalation — these are the primitives Domain 1 tests. Onward to Domain 3.
-->
