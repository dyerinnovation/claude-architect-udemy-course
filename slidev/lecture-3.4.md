---
theme: default
title: "Lecture 3.4: Multi-Agent Hub-and-Spoke Architecture"
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
  <div class="di-cover-title">Multi-Agent<br>Hub-and-Spoke Architecture</div>
  <div class="di-cover-subtitle">Lecture 3.4 · Domain 1 — Agentic Architecture & Orchestration (27%)</div>
</div>

<img src="/logo.png" class="di-logo-centered" />

<!--
Single agents are powerful. But they have limits.

They operate in a single context window. They can only do one thing at a time. And complex tasks — research, code review, customer support pipelines — often need multiple specialized capabilities running in parallel.

Multi-agent systems solve these problems. But they introduce coordination challenges.

The architecture that the CCA-F exam focuses on is hub-and-spoke — a central coordinator managing multiple specialized subagents.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 2 — Hub-and-Spoke: The Core Structure
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Hub-and-Spoke — The Core Structure</div>

<v-click>
<div style="display: flex; align-items: stretch; gap: 1.5rem; margin-top: 0.5rem;">

  <div style="flex: 0 0 44%; display: flex; flex-direction: column; align-items: center; gap: 0.3rem;">
    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.4rem; width: 100%;">
      <div style="background: #E8F5EB; border: 1px solid #c8e6d0; border-radius: 6px; padding: 0.4rem 0.6rem; text-align: center; font-size: 0.78rem; font-weight: 600; color: #1A3A4A;">Research<br>Subagent</div>
      <div style="background: #E8F5EB; border: 1px solid #c8e6d0; border-radius: 6px; padding: 0.4rem 0.6rem; text-align: center; font-size: 0.78rem; font-weight: 600; color: #1A3A4A;">Document<br>Subagent</div>
    </div>
    <div style="color: #0D7377; font-size: 0.9rem; display: flex; justify-content: space-around; width: 100%;">↑&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↑</div>
    <div style="background: #1A3A4A; color: white; border: 3px solid #3CAF50; border-radius: 8px; padding: 0.6rem 1rem; width: 100%; text-align: center; font-weight: 700; font-size: 0.95rem;">
      Coordinator<br><span style="color: #A8D5C2; font-size: 0.8rem;">Hub</span>
    </div>
    <div style="color: #0D7377; font-size: 0.9rem; display: flex; justify-content: space-around; width: 100%;">↓&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↓</div>
    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.4rem; width: 100%;">
      <div style="background: #E8F5EB; border: 1px solid #c8e6d0; border-radius: 6px; padding: 0.4rem 0.6rem; text-align: center; font-size: 0.78rem; font-weight: 600; color: #1A3A4A;">Synthesis<br>Subagent</div>
      <div style="background: #E8F5EB; border: 1px solid #c8e6d0; border-radius: 6px; padding: 0.4rem 0.6rem; text-align: center; font-size: 0.78rem; font-weight: 600; color: #1A3A4A;">Report<br>Subagent</div>
    </div>
    <div style="font-size: 0.75rem; color: #E53E3E; font-style: italic; margin-top: 0.3rem; text-align: center;">No arrows between the outer nodes</div>
  </div>

  <div style="flex: 1; font-size: 0.92rem; color: #111928; line-height: 1.65;">
    <p>The hub-and-spoke pattern has one defining rule: <strong>all communication flows through the coordinator</strong>.</p>
    <v-click at="2">
    <div class="di-step-card" style="margin-top: 0.5rem;">
      <span class="di-step-num">Subagents</span> only ever communicate with the coordinator. They <em>never</em> talk directly to each other.
    </div>
    </v-click>
    <v-click at="3">
    <div class="di-step-card" style="margin-top: 0.4rem; border-left-color: #0D7377;">
      <span class="di-step-num" style="color: #0D7377;">Why not a mesh?</span> Direct subagent communication creates a mesh topology — harder to debug, harder to monitor, and harder to reason about when something goes wrong.
    </div>
    </v-click>
    <v-click at="4">
    <p style="margin-top: 0.6rem; font-size: 0.88rem; color: #1A3A4A;">This is a <strong>deliberate design choice</strong>: centralized observability, consistent error handling, predictable control flow.</p>
    </v-click>
  </div>

</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
The hub-and-spoke pattern has one defining rule: all communication flows through the coordinator.

The coordinator — the hub — receives the original task. It decomposes it. It assigns work to subagents. It collects results. It aggregates. And it produces the final output.

The subagents — the spokes — only ever communicate with the coordinator. They never talk directly to each other.

This is not a limitation. It's a deliberate design choice that gives you centralized observability, consistent error handling, and predictable control flow.

If subagents communicated directly, you'd have a mesh topology — harder to debug, harder to monitor, and harder to reason about when something goes wrong.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 3 — The Coordinator's Three Jobs
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">The Coordinator's Three Jobs</div>

<div class="di-body" style="margin-top: 0.75rem;">

<v-click>
<div class="di-step-card">
  <span class="di-step-num">1. Decompose</span>
  Break the original task into pieces that subagents can handle independently. Good decomposition means each subagent has a <strong>clear, bounded responsibility</strong> with no implicit dependencies on what other subagents are doing.
</div>
</v-click>

<v-click>
<div class="di-step-card" style="border-left-color: #0D7377;">
  <span class="di-step-num" style="color: #0D7377;">2. Delegate</span>
  Spawn each subagent with its specific task and the context it needs. This means <strong>explicit context passing</strong> — subagents don't inherit the coordinator's history. Each one starts fresh.
</div>
</v-click>

<v-click>
<div class="di-step-card" style="border-left-color: #1B8A5A;">
  <span class="di-step-num" style="color: #1B8A5A;">3. Aggregate</span>
  Collect all subagent outputs, synthesize them into a coherent response, and handle any failures gracefully. The coordinator is responsible for catching subagent errors and deciding whether to <strong>retry, skip, or surface the failure</strong>.
</div>
</v-click>

<v-click>
<div style="background: #FFF8E6; border-left: 3px solid #E3A008; padding: 0.5rem 0.8rem; border-radius: 4px; font-size: 0.88rem; margin-top: 0.5rem;">
  <strong>The coordinator is the brain.</strong> It never runs the actual domain work — it orchestrates the agents that do.
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
The coordinator has exactly three jobs: decompose, delegate, and aggregate.

Decompose: break the original task into pieces that subagents can handle independently. Good decomposition means each subagent has a clear, bounded responsibility with no implicit dependencies on what other subagents are doing.

Delegate: spawn each subagent with its specific task and the context it needs. This means explicit context passing — subagents don't inherit the coordinator's history. Each one starts fresh.

Aggregate: collect all the subagent outputs, synthesize them into a coherent response, and handle any failures gracefully. The coordinator is responsible for catching subagent errors and deciding whether to retry, skip, or surface the failure.
-->

---
layout: two-cols
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 4 — Subagent Context Isolation
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header" style="margin: -1.5rem -1rem 1rem -2rem; padding-right: 1rem;">Subagent Context Isolation</div>

<v-click>
<div style="padding-right: 1.2rem;">
  <div class="di-col-left-label">❌ What candidates assume</div>
  <div class="di-col-body">
    <div style="background: #1A3A4A; color: white; border-radius: 6px; padding: 0.5rem 0.75rem; font-size: 0.85rem; margin-bottom: 0.35rem;">
      Coordinator<br><span style="color: #A8D5C2; font-size: 0.78rem;">full conversation history</span>
    </div>
    <div style="text-align: center; color: #0D7377;">↓ inherits history</div>
    <div style="background: #E8F5EB; border: 1px solid #c8e6d0; border-radius: 6px; padding: 0.5rem 0.75rem; font-size: 0.85rem; color: #111928;">
      Subagent<br><span style="font-size: 0.78rem; color: #1B8A5A;">knows everything coordinator knows</span>
    </div>
    <div class="di-col-warning" style="margin-top: 0.5rem;">
      <strong>Wrong:</strong> Subagents do not see the coordinator's messages
    </div>
  </div>
</div>
</v-click>

::right::

<v-click>
<div style="padding-left: 1.2rem; padding-top: 5rem;">
  <div class="di-col-right-label">✓ What actually happens</div>
  <div class="di-col-body">
    <div style="background: #1A3A4A; color: white; border-radius: 6px; padding: 0.5rem 0.75rem; font-size: 0.85rem; margin-bottom: 0.35rem;">
      Coordinator<br><span style="color: #A8D5C2; font-size: 0.78rem;">passes context explicitly</span>
    </div>
    <div style="text-align: center; color: #0D7377;">↓ explicit prompt only</div>
    <div style="background: #E8F5EB; border: 1px solid #c8e6d0; border-radius: 6px; padding: 0.5rem 0.75rem; font-size: 0.85rem; color: #111928;">
      Subagent<br><span style="font-size: 0.78rem; color: #1B8A5A;">starts with fresh context</span>
    </div>
    <div style="margin-top: 0.5rem; background: #F0FFF4; border-left: 3px solid #3CAF50; padding: 0.4rem 0.6rem; border-radius: 3px; font-size: 0.88rem;">
      <strong>Rule:</strong> Nothing flows implicitly. Everything that matters must be passed explicitly.
    </div>
  </div>
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
One of the most important things to understand about subagents: they don't inherit the coordinator's conversation history.

Each subagent starts with a completely fresh context.

This means the coordinator must be explicit about what information each subagent needs. If the research pipeline has already found key facts, and the synthesis subagent needs those facts, the coordinator must explicitly include them in the synthesis subagent's task prompt.

Nothing flows implicitly. Everything that matters must be passed explicitly.

This is why the exam asks about "explicit context passing" — it's the mechanism that makes multi-agent systems actually work.
-->

---
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 5 — The Task Tool: Spawning Subagents
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">The Task Tool — Spawning Subagents</div>

<v-click>

```python {all|4-6|7-9|11-14}
# Coordinator spawning a research subagent
response = client.messages.create(
    model="claude-opus-4-6",
    tools=[{
        "type": "computer_use",
        "name": "Task",
        "description": "Spawn a subagent to complete a specific task",
        "input_schema": { ... }
    }],
    messages=[...],
    system="""You are a coordinator. Use the Task tool to delegate
              work to specialized subagents. Pass all required
              context explicitly — subagents have no shared memory."""
)
```

</v-click>

<v-click>
<div style="display: flex; gap: 0.75rem; margin-top: 0.5rem; font-size: 0.84rem;">
  <div style="flex: 1; background: white; border-radius: 4px; padding: 0.5rem 0.7rem; border-left: 3px solid #E3A008;">
    <strong style="color: #E3A008;">Key parameter: <code>allowedTools</code></strong><br>
    Must include <code>"Task"</code> for a subagent to accept its assignment. Without it, the subagent cannot properly process its task specification.
  </div>
  <div style="flex: 1; background: white; border-radius: 4px; padding: 0.5rem 0.7rem; border-left: 3px solid #3CAF50;">
    <strong style="color: #1B8A5A;">Think of it this way</strong><br>
    The Task tool is how an agent formally accepts an assignment. No Task in allowedTools → no assignment accepted.
  </div>
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
In Claude's agent framework, coordinators spawn subagents using the Task tool.

A Task call has three key parameters: the task description (what to do), the instructions (context and constraints), and allowedTools (what tools the subagent is permitted to use).

The allowedTools parameter is an exam favorite. For a subagent to receive and process its task, allowedTools must include "Task". Without it, the subagent can't properly accept the task specification.

Think of it this way: the Task tool is how an agent formally accepts an assignment. No Task in allowedTools means no assignment accepted.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 6 — Parallel vs Sequential Subagent Execution
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Parallel vs Sequential Subagent Execution</div>

<div class="di-body" style="margin-top: 0.5rem;">

<v-click>
<div class="di-step-card" style="border-left-color: #E3A008;">
  <span class="di-step-num" style="color: #E3A008;">Sequential</span>
  Coordinator spawns subagent 1 → waits for result → spawns subagent 2 → waits → spawns subagent 3. Use when subagent B depends on subagent A's output.
</div>
</v-click>

<v-click>
<div style="display: flex; align-items: center; gap: 0.4rem; flex-wrap: nowrap; margin: 0.3rem 0; font-size: 0.82rem; overflow: hidden;">
  <div style="background: #1A3A4A; color: white; border-radius: 5px; padding: 0.3rem 0.5rem; white-space: nowrap;">Coordinator</div>
  <div style="color: #0D7377;">→</div>
  <div style="background: #E3A008; color: white; border-radius: 5px; padding: 0.3rem 0.5rem; white-space: nowrap; font-size: 0.78rem;">Subagent 1</div>
  <div style="color: #0D7377;">→ wait →</div>
  <div style="background: #E3A008; color: white; border-radius: 5px; padding: 0.3rem 0.5rem; white-space: nowrap; font-size: 0.78rem;">Subagent 2</div>
  <div style="color: #0D7377;">→ wait →</div>
  <div style="background: #E3A008; color: white; border-radius: 5px; padding: 0.3rem 0.5rem; white-space: nowrap; font-size: 0.78rem;">Subagent 3</div>
</div>
</v-click>

<v-click>
<div class="di-step-card" style="border-left-color: #3CAF50; margin-top: 0.5rem;">
  <span class="di-step-num">Parallel</span>
  Coordinator spawns <strong>all independent subagents in a single response turn</strong> — multiple Task calls in one response. The coordinator then waits for all results before continuing.
</div>
</v-click>

<v-click>
<div style="display: flex; flex-direction: column; align-items: center; gap: 0.15rem; margin: 0.3rem 0; font-size: 0.82rem;">
  <div style="background: #1A3A4A; color: white; border-radius: 5px; padding: 0.3rem 0.8rem;">Coordinator (one turn)</div>
  <div style="display: flex; gap: 1.5rem; color: #0D7377;">↓&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↓&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↓</div>
  <div style="display: flex; gap: 0.75rem;">
    <div style="background: #1B8A5A; color: white; border-radius: 5px; padding: 0.3rem 0.6rem; font-size: 0.78rem;">Doc Analysis</div>
    <div style="background: #1B8A5A; color: white; border-radius: 5px; padding: 0.3rem 0.6rem; font-size: 0.78rem;">Web Search</div>
    <div style="background: #1B8A5A; color: white; border-radius: 5px; padding: 0.3rem 0.6rem; font-size: 0.78rem;">Src Verify</div>
  </div>
</div>
</v-click>

<v-click>
<div style="background: #FFF8E6; border-left: 3px solid #E3A008; padding: 0.45rem 0.8rem; border-radius: 4px; font-size: 0.88rem; margin-top: 0.25rem;">
  <strong>Exam key phrase:</strong> "all parallel subagent spawning happens in one coordinator turn"
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
The hub-and-spoke architecture supports both sequential and parallel execution.

Sequential: the coordinator spawns one subagent, waits for the result, then spawns the next. Use this when subagent B depends on subagent A's output.

Parallel: the coordinator spawns multiple subagents in a single response turn. This is the key phrase for the exam. All parallel subagent spawning happens in one coordinator turn — multiple Task calls in one response. The coordinator then waits for all results before continuing.

Parallel execution is the right choice when tasks are independent. The multi-agent research pipeline spawns document analysis, web search, and source verification subagents in parallel because their work doesn't depend on each other.
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
<div class="di-exam-subtitle">Hub-and-Spoke Exam Patterns</div>

<div class="di-exam-body">
  Two patterns the exam tests heavily in the hub-and-spoke context.
</div>
</v-click>

<v-click>
<div class="di-trap-box">
  <div class="di-trap-label">❌ Trap 1 — Sequential Spawning Presented as Parallel</div>
  The exam will offer an answer where the coordinator spawns subagents across multiple turns. That's sequential — slower and misses the point of parallelism.
  <br><strong>Correct:</strong> Parallel subagents are ALL spawned in ONE coordinator response turn.
</div>
</v-click>

<v-click>
<div class="di-trap-box" style="margin-top: 0.5rem;">
  <div class="di-trap-label">❌ Trap 2 — Direct Subagent Communication</div>
  If an answer choice has subagents sharing information directly with each other, it violates hub-and-spoke. In hub-and-spoke, <strong>everything goes through the coordinator</strong>.
</div>
</v-click>

<v-click>
<div class="di-correct-box" style="margin-top: 0.5rem;">
  <div class="di-correct-label">✓ Two Rules to Remember Cold</div>
  1. Parallel spawning = one coordinator turn, multiple Task calls.<br>
  2. Subagents never communicate directly — all traffic flows through the coordinator.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Two patterns the exam tests heavily in the hub-and-spoke context.

First: parallel subagent spawning happens in one coordinator response. The exam will offer an answer where the coordinator spawns subagents sequentially across multiple turns. That's slower and misses the point of parallelism.

Second: direct subagent-to-subagent communication is always wrong in this architecture. If an answer choice has subagents sharing information directly, it's violating hub-and-spoke. In hub-and-spoke, everything goes through the coordinator.
-->

---
layout: default
class: di-takeaway-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 8 — Key Takeaways
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-takeaway-title">Hub-and-Spoke Architecture</div>

<ul class="di-takeaway-list">
  <v-click><li><strong>All communication flows through the coordinator</strong> — subagents never talk directly to each other</li></v-click>
  <v-click><li>The coordinator's three jobs: <strong>Decompose → Delegate → Aggregate</strong></li></v-click>
  <v-click><li>Subagents have <strong>no inherited context</strong> — the coordinator must pass everything explicitly</li></v-click>
  <v-click><li><code style="color: #A8D5C2;">allowedTools</code> must include <code style="color: #A8D5C2;">"Task"</code> for a subagent to accept its assignment</li></v-click>
  <v-click><li><strong>Parallel spawning = all subagents spawned in one coordinator response turn</strong></li></v-click>
  <v-click><li>Hub-and-spoke gives you centralized observability, consistent error handling, and predictable control flow</li></v-click>
</ul>

<img src="/logo.png" class="di-logo" style="opacity: 0.75;" />

<!--
To summarize the hub-and-spoke architecture:

All communication flows through the coordinator — subagents never talk directly to each other.

The coordinator's three jobs: Decompose, Delegate, Aggregate.

Subagents have no inherited context — the coordinator must pass everything explicitly.

allowedTools must include "Task" for a subagent to accept its assignment.

Parallel spawning means all subagents are spawned in one coordinator response turn.

And the reason to use this pattern: centralized observability, consistent error handling, and predictable control flow.
-->
