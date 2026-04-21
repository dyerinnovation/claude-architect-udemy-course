---
theme: default
title: "Lecture 3.2: tool_use vs end_turn — Control Flow Patterns"
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
const tuSteps = [
  { number: 'Step 1', title: 'Extract tool_use blocks', body: 'From the content array — a single response can contain MULTIPLE tool_use blocks.' },
  { number: 'Step 2', title: 'Execute each tool', body: 'Run your actual function — query a DB, call an API, read a file — whatever the tool does.' },
  { number: 'Step 3', title: 'Package the results', body: 'Each result is a tool_result block with matching tool_use_id, content, and an is_error flag.' },
  { number: 'Step 4', title: 'Append + call again', body: 'Append the original assistant response, then a user message with ALL tool results → API call.' },
]

const endTurnBullets = [
  { label: '✓ Task complete', detail: 'Most common — Claude finished successfully. Return the response to the user.' },
  { label: '⚠ Cannot proceed', detail: 'Claude hit a blocker and is returning an explanation. Inspect content, then surface to caller.' },
  { label: '✗ Max tokens', detail: 'Context limit reached mid-response. Check stop_reason value, handle truncation.' },
]

const takeawayBullets = [
  { label: 'tool_use path', detail: 'Extract blocks → execute → append BOTH assistant msg AND tool results → loop.' },
  { label: 'end_turn path', detail: 'Do not loop. Inspect content to understand completion state, then return.' },
  { label: 'Tool results = USER messages', detail: 'Tool results belong in user messages, not assistant messages.' },
  { label: 'Batch tool results', detail: 'Multiple tool calls in one response → process all, send one combined user message.' },
  { label: 'Model-driven routing', detail: 'Claude decides tool order — use for flexible workflows.' },
  { label: 'Programmatic enforcement', detail: 'Your code enforces order — use for hard constraints (safety, correctness).' },
]

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

const flowSteps = [
  { label: 'User', sublabel: 'initial request' },
  { label: 'Assistant', sublabel: 'tool_use block' },
  { label: 'User', sublabel: 'tool_result' },
  { label: 'Assistant', sublabel: 'tool_use or end_turn' },
]

const examBad = `// Trap 1 — tool result as an assistant message
{
  "role": "assistant",
  "content": [
    { "type": "tool_result",
      "tool_use_id": "toolu_01ABC",
      "content": "Seattle: 58\u00B0F" }
  ]
}`

const examGood = `// Tool results go in a USER message — all of them, together
{
  "role": "user",
  "content": [
    { "type": "tool_result",
      "tool_use_id": "toolu_01ABC",
      "content": "Seattle: 58\u00B0F" }
  ]
}`
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
