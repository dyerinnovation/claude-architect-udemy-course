---
theme: default
title: "Lecture 2.11: The Complete Tool Use Loop (Hands-On)"
info: |
  Claude Certified Architect – Foundations
  Section 2: Claude API Fundamentals Bootcamp (Domain 1 · 27%)
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
const loopSteps = [
  { label: '1 · Initialize', sublabel: "messages = [user message]" },
  { label: '2 · Send', sublabel: "client.messages.create() with tools" },
  { label: "3 · Check stop_reason", sublabel: "end_turn? return, STOP" },
  { label: '4 · Execute', sublabel: "Run ALL tool_use blocks" },
  { label: '5 · Append assistant', sublabel: "Add Claude's message to history" },
  { label: '6 · Append user results', sublabel: "ONE user msg with ALL tool_results → loop back" },
]

const historySteps = [
  { number: '1 · user', title: 'Original question', body: "e.g. 'What's the weather in Paris?'" },
  { number: '2 · assistant', title: 'Tool use blocks', body: 'Content array with one or more tool_use blocks' },
  { number: '3 · user', title: 'Tool results', body: 'Content array with matching tool_result blocks' },
  { number: '4 · assistant', title: 'Final answer', body: "Natural-language answer — stop_reason='end_turn'" },
]

const takeaways = [
  { label: 'Loop until end_turn', detail: "Claude controls termination — while True + break on stop_reason=='end_turn'" },
  { label: 'Append both on every cycle', detail: 'Assistant message (with tool_use) AND user message (with ALL tool_results)' },
  { label: 'N tool_use → N tool_result', detail: 'Multiple tool calls → execute all → ONE user message with all tool_result blocks' },
  { label: 'Foundation of agents', detail: 'This pattern is the direct foundation of every agentic Claude architecture' },
]

const toolsCode = `import anthropic

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
    return "Unknown tool."`

const loopCode = `def run_agent(user_message: str) -> str:
    messages = [{"role": "user", "content": user_message}]

    while True:
        response = client.messages.create(
            model="claude-opus-4-7",
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
print(answer)`
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
      <div class="lec-cover__section">Section 2 · Lecture 2.11 · Domain 1</div>
      <h1 class="lec-cover__title">The Complete Tool Use Loop</h1>
      <div class="lec-cover__subtitle">Foundation of every agent you'll ever build</div>
    </div>
    <div class="lec-cover__stats">
      <span>API Fundamentals Bootcamp</span>
      <span class="lec-cover__dot">&middot;</span>
      <span>Domain 1 · 27% weight</span>
    </div>
  </div>
</Frame>

<style>
.lec-cover { position: relative; z-index: 1; padding: 110px 120px 96px; width: 100%; height: 100%; display: flex; flex-direction: column; justify-content: space-between; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%); }
.lec-cover__brand { display: flex; align-items: center; gap: 24px; }
.lec-cover__logo { width: 72px; height: auto; }
.lec-cover__brand-text { font-family: var(--font-body); font-size: 26px; font-weight: 500; letter-spacing: 0.14em; text-transform: uppercase; color: var(--mint-200); }
.lec-cover__section { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px; }
.lec-cover__title { font-family: var(--font-display); font-weight: 500; font-size: 112px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1500px; }
.lec-cover__subtitle { font-family: var(--font-display); font-size: 48px; color: var(--mint-200); margin-top: 32px; font-weight: 400; max-width: 1400px; line-height: 1.3; }
.lec-cover__stats { display: flex; align-items: center; gap: 36px; font-family: var(--font-body); font-size: 24px; color: var(--mint-200); letter-spacing: 0.06em; }
.lec-cover__dot { opacity: 0.4; }
.exam-stack { margin-top: 48px; display: flex; flex-direction: column; gap: 28px; flex: 1; min-height: 0; }
</style>

<!--
In the previous lecture, you saw how one tool call works — Claude says it wants to call get_weather, you execute the function, you send the result back, Claude gives a final answer.

But real systems do more than one tool call. A user asks "what's the weather in Paris and the 5-day forecast?" Claude might call two tools. Or chain three. Or query, inspect results, and refine.

The tool use loop is the mechanism that handles all of this. Understand this pattern and you understand the foundation of every agent you'll ever build with Claude.
-->

---

<!-- SLIDE 2 — The loop structure -->

<FlowDiagram
  eyebrow="The loop"
  title="The Loop Structure — Step by Step"
  :steps="loopSteps"
/>

<!--
Let's walk through the structure before we look at code.

Step one: initialize your messages list with the user's message.
Step two: send the messages to Claude with your tools attached.
Step three: check stop_reason. If it's "end_turn", Claude is done — return the response to the user.

If it's "tool_use", there's work to do.

Step four: execute every tool_use block in the response content — not just the first one.
Step five: append Claude's full assistant message to your messages list.
Step six: build a single user message containing all the tool_result blocks, append it, and loop back to step two.

Notice the loop exits only when stop_reason is "end_turn". Everything else is iteration.
-->

---

<!-- SLIDE 3 — Multiple tool calls in one response -->

<TwoColSlide
  variant="compare"
  title="Multiple Tool Calls — In One Response"
  leftLabel="Claude's response"
  rightLabel="Your reply — ONE user message"
>
  <template #left>
    <pre><code>{"role": "assistant",
 "content": [
   {"type": "tool_use",
    "id": "toolu_1",
    "name": "get_weather",
    "input": {...}},
   {"type": "tool_use",
    "id": "toolu_2",
    "name": "get_forecast",
    "input": {...}}
 ]}</code></pre>
  </template>
  <template #right>
    <pre><code>{"role": "user",
 "content": [
   {"type": "tool_result",
    "tool_use_id": "toolu_1",
    "content": "..."},
   {"type": "tool_result",
    "tool_use_id": "toolu_2",
    "content": "..."}
 ]}</code></pre>
    <p style="margin-top: 18px;"><strong>NEVER</strong> one user message per tool result. One assistant turn with N calls → one user turn with N results. Always.</p>
  </template>
</TwoColSlide>

<!--
This is where many implementations break.

Claude can return multiple tool_use blocks in a single response. That means it wants to call multiple tools before it continues.

You must execute all of them. Then you collect all the results and put them in a single user message.

Not one message per result — one message with all results.

If you send them as separate messages, the conversation structure breaks. Claude expects one tool_result per tool_use id, all in the same turn.
-->

---

<!-- SLIDE 4 — Message history after one cycle -->

<StepSequence
  eyebrow="History shape"
  title="Message History After One Tool Cycle"
  :steps="historySteps"
/>

<!--
It helps to see what your messages list looks like after one complete cycle.

The first entry is the original user message — the question that started everything.
The second entry is Claude's assistant message — it contains the tool_use block.
The third entry is your user message — it contains the tool_result block.

The fourth entry is Claude's final assistant message — the natural language answer.

This four-entry pattern is what a single tool use cycle looks like in history. If Claude calls tools twice before answering, you'll have six entries.

The assistant messages always contain the reasoning and tool calls. The user messages after the first one are always your tool results.
-->

---

<!-- SLIDE 5a — Tools & dispatcher -->

<CodeBlockSlide
  eyebrow="Implementation — part 1"
  title="Tools & Dispatcher"
  lang="python"
  :code="toolsCode"
  annotation="Two weather tools and a dispatcher. In production, this is where you call external APIs, query DBs, run calculations."
/>

<!--
Here is the complete implementation, split across two slides so you can see it clearly.

First: the tool definitions. Two weather tools — one for current conditions, one for a five-day forecast. Each has a name, a description, and an input_schema.

The execute_tool function is your dispatcher — it routes Claude's tool calls to the real implementations. In a production system, this is where you'd call an external API, query a database, or run a calculation.
-->

---

<!-- SLIDE 5b — The loop implementation -->

<CodeBlockSlide
  eyebrow="Implementation — part 2"
  title="The Loop"
  lang="python"
  :code="loopCode"
  annotation="while True is the engine. Only exit: stop_reason=='end_turn'. Execute every tool_use block, append BOTH assistant message AND user tool_results before looping."
/>

<!--
Walk through this carefully.

The while True loop is the engine. Every iteration sends the full message history. The only exit is stop_reason == "end_turn".

When Claude asks for tools, you collect every tool_use block from the content array, execute each one, and build a list of tool_result blocks. Then you append both the assistant message AND the user message with all the results before looping back.

That's the entire pattern.
-->

---

<!-- SLIDE 6 — Why the loop terminates -->

<TwoColSlide
  variant="compare"
  title="Why the Loop Terminates"
  leftLabel="end_turn"
  rightLabel="tool_use"
>
  <template #left>
    <p><em>Claude has enough information to respond.</em></p>
    <ul>
      <li>Return the answer</li>
      <li>Loop exits</li>
    </ul>
  </template>
  <template #right>
    <p><em>Claude needs another piece of data.</em></p>
    <ul>
      <li>Execute tools, extend history</li>
      <li>Loop again</li>
    </ul>
    <p style="margin-top: 18px;"><strong>Claude controls how many cycles.</strong> Most finish in 1–2. Production tip: add a max-iteration safety counter alongside <code>stop_reason</code>. Primary exit stays <code>stop_reason</code>.</p>
  </template>
</TwoColSlide>

<!--
A question worth asking: what stops this loop from running forever?

Claude does.

After you return a tool_result, Claude either calls another tool or generates a final answer. It chooses based on whether it has enough information to respond.

In practice, most tool use loops complete in one or two cycles. For complex research or multi-step tasks, it might take more.

Production systems often add a safety counter — a maximum iteration limit — to prevent runaway loops. But the fundamental termination guarantee is Claude's own stop_reason. When Claude has what it needs, it returns "end_turn".
-->

---

<!-- SLIDE 7 — Connection to agentic architecture -->

<TwoColSlide
  variant="compare"
  title="Connection to Agentic Architecture"
  leftLabel="What You Just Built"
  rightLabel="Section 3 · Agentic Systems"
>
  <template #left>
    <ul>
      <li><code>while</code> loop</li>
      <li><code>stop_reason</code> check</li>
      <li>Tool execution</li>
      <li>History accumulation</li>
    </ul>
  </template>
  <template #right>
    <ul>
      <li>Agent loop</li>
      <li>State management</li>
      <li>Action execution</li>
      <li>Memory / context</li>
    </ul>
    <p style="margin-top: 18px;"><strong>Same pattern — different scale.</strong> The while loop = agent's main cycle · tool defs = agent capabilities · history = working memory · execute_tool = real-world integration.</p>
  </template>
</TwoColSlide>

<!--
Let me pull back the curtain on what you just built.

You implemented an agent.

Really. The while loop with tool execution IS the agent loop. Tool definitions are your agent's capabilities. Message history is the agent's working memory. execute_tool is your integration layer with the real world.

Section 3 covers this pattern at scale — multiple agents, subagent delegation, task decomposition. But all of it builds on what you just wrote.

If you understand this loop, you understand the spine of every agentic architecture you'll see on the exam.
-->

---

<!-- SLIDE 8 — Exam Tip -->

<Frame>
  <Eyebrow>⚡ Exam Tip</Eyebrow>
  <SlideTitle>N tool_use blocks → N tool_result blocks in ONE user message</SlideTitle>
  <div class="exam-stack">
    <CalloutBox variant="dont" title="Distractor">
      <p>Two user messages, each with a single <code>tool_result</code> — splitting the turn across multiple user messages.</p>
    </CalloutBox>
    <CalloutBox variant="do" title="Only correct pattern">
      <p>One assistant turn with N tool calls → one user turn with N tool results. Always. Each <code>tool_result</code> carries the matching <code>tool_use_id</code>.</p>
    </CalloutBox>
  </div>
</Frame>

<!--
The exam will present scenarios with multiple tool calls and ask you how to return the results.

The trap: splitting the results into separate user messages.

The rule: one assistant turn with N tool calls → one user turn with N tool results. Always. Each tool_result carries the matching tool_use_id so Claude knows which call each result belongs to.
-->

---

<!-- SLIDE 9 — Takeaways -->

<BulletReveal
  eyebrow="Takeaway"
  title="The Tool Use Loop — What to Know Cold"
  :bullets="takeaways"
/>

<!--
Four things to know cold.

The loop runs until stop_reason=='end_turn' — Claude controls termination.

Every cycle: append assistant message (with tool_use) AND user message (with ALL tool_results).

Multiple tool_use blocks → execute all → one user message with all tool_result blocks.

This pattern is the direct foundation of every agentic Claude architecture — master it before Section 3.
-->
