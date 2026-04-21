---
theme: default
title: "Lecture 3.4: Multi-Agent Hub-and-Spoke Architecture"
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
const jobsBullets = [
  { label: '1. Decompose', detail: 'Break the task into pieces with clear, bounded responsibility — no implicit dependencies.' },
  { label: '2. Delegate', detail: 'Spawn each subagent with its task and context. Subagents do NOT inherit coordinator history.' },
  { label: '3. Aggregate', detail: 'Collect outputs, synthesize, handle failures gracefully — retry, skip, or surface.' },
]

const takeawayBullets = [
  { label: 'All traffic through the hub', detail: 'Subagents never talk directly to each other — everything flows through the coordinator.' },
  { label: "Coordinator's three jobs", detail: 'Decompose → Delegate → Aggregate.' },
  { label: 'No inherited context', detail: 'Coordinator must pass everything the subagent needs, explicitly, in the task prompt.' },
  { label: "allowedTools must include 'Task'", detail: 'Without it, the subagent cannot properly accept its assignment.' },
  { label: 'Parallel = ONE coordinator turn', detail: 'All parallel subagent spawning happens in a single coordinator response turn.' },
  { label: 'Why hub-and-spoke?', detail: 'Centralized observability, consistent error handling, predictable control flow.' },
]

const examBad = `Two traps the exam plants

Trap 1 — Sequential spawning presented as parallel
  Coordinator emits one Task, waits, then emits another
  across multiple turns. That's sequential, not parallel.

Trap 2 — Direct subagent-to-subagent communication
  Subagent A sends data directly to Subagent B. Violates
  hub-and-spoke — all traffic must go through the hub.`

const examGood = `Two rules

(1) Parallel spawning = ONE coordinator turn,
    multiple Task calls in the same response.

(2) Subagents NEVER communicate directly —
    all traffic flows through the coordinator.`

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
