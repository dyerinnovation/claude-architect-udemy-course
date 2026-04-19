---
theme: default
title: "Lecture 3.5: The Coordinator's Role: Decompose, Delegate, Aggregate"
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
  <div class="di-cover-title">The Coordinator's Role:<br>Decompose, Delegate, Aggregate</div>
  <div class="di-cover-subtitle">Lecture 3.5 · Domain 1 — Agentic Architecture & Orchestration (27%)</div>
</div>

<img src="/logo.png" class="di-logo-centered" />

<!--
In the last lecture, we introduced hub-and-spoke architecture and named the coordinator's three jobs.

Now we're going deeper.

The coordinator is the most important agent in any multi-agent system. It doesn't do the domain work — but every architectural decision that determines whether the system works correctly flows through it.

In this lecture, we'll look at each of the three jobs in detail: what good decomposition looks like, how delegation works in practice, and what aggregation requires from the coordinator when subagents succeed, fail, or return partial results.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 2 — The Coordinator Is the Brain
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">The Coordinator Is the Brain</div>

<div class="di-body" style="margin-top: 0.75rem;">

<v-click>
<p>The coordinator never runs the actual domain work. It orchestrates the agents that do.</p>
</v-click>

<v-click>
<div style="display: flex; gap: 1rem; margin-top: 0.5rem;">
  <div style="flex: 1; background: white; border: 1px solid #c8e6d0; border-top: 3px solid #3CAF50; border-radius: 6px; padding: 0.6rem 0.8rem; font-size: 0.88rem;">
    <div style="font-weight: 700; color: #1B8A5A; margin-bottom: 0.3rem;">What the coordinator does</div>
    <ul style="margin: 0; padding-left: 1.2rem;">
      <li>Receives the original user task</li>
      <li>Decides how to split it into subtasks</li>
      <li>Selects which subagents handle which parts</li>
      <li>Passes the right context to each subagent</li>
      <li>Collects and synthesizes results</li>
    </ul>
  </div>
  <div style="flex: 1; background: white; border: 1px solid #ffd5a0; border-top: 3px solid #E3A008; border-radius: 6px; padding: 0.6rem 0.8rem; font-size: 0.88rem;">
    <div style="font-weight: 700; color: #E3A008; margin-bottom: 0.3rem;">What the coordinator does NOT do</div>
    <ul style="margin: 0; padding-left: 1.2rem;">
      <li>Browse the web</li>
      <li>Analyze documents directly</li>
      <li>Execute code</li>
      <li>Write the final research report</li>
    </ul>
    <div style="margin-top: 0.4rem; font-size: 0.82rem; color: #1A3A4A; font-style: italic;">These are subagent responsibilities</div>
  </div>
</div>
</v-click>

<v-click>
<div style="background: #FFF8E6; border-left: 3px solid #E3A008; padding: 0.5rem 0.8rem; border-radius: 4px; font-size: 0.88rem; margin-top: 0.6rem;">
  <strong>The exam implication:</strong> If an answer choice has the coordinator directly executing domain tasks instead of delegating, it's wrong.
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
Let's start with the big picture: what the coordinator actually is.

The coordinator never runs the actual domain work. It orchestrates the agents that do.

The coordinator receives the task, decides how to split it, selects subagents, passes context, collects results, and synthesizes them. It does not browse the web. It does not analyze documents. It does not write the final output. Those are subagent responsibilities.

This separation is important for the exam: if an answer choice has the coordinator directly executing domain tasks instead of delegating, that's a design violation.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 3 — Decompose: Breaking the Task Well
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Decompose — Breaking the Task Well</div>

<div class="di-body" style="margin-top: 0.5rem;">

<v-click>
<p>Good decomposition produces subtasks with <strong>clear, bounded responsibilities and no implicit dependencies</strong> on each other.</p>
</v-click>

<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.75rem; margin-top: 0.5rem;">

<v-click>
<div style="background: #FFF0F0; border: 1px solid #ffc8c8; border-top: 3px solid #E53E3E; border-radius: 6px; padding: 0.6rem 0.75rem; font-size: 0.86rem;">
  <div style="font-weight: 700; color: #E53E3E; margin-bottom: 0.3rem;">❌ Poor Decomposition</div>
  <ul style="margin: 0; padding-left: 1.1rem;">
    <li>"Research agent" does research AND writes summary</li>
    <li>Subtasks have unclear boundaries</li>
    <li>Subagent A's output format is assumed by subagent B</li>
    <li>One subagent is responsible for too much</li>
  </ul>
</div>
</v-click>

<v-click>
<div style="background: #F0FFF4; border: 1px solid #c8e6d0; border-top: 3px solid #3CAF50; border-radius: 6px; padding: 0.6rem 0.75rem; font-size: 0.86rem;">
  <div style="font-weight: 700; color: #1B8A5A; margin-bottom: 0.3rem;">✓ Good Decomposition</div>
  <ul style="margin: 0; padding-left: 1.1rem;">
    <li>Each subagent has one clearly defined job</li>
    <li>Independent tasks can run in parallel</li>
    <li>Dependent tasks are chained explicitly</li>
    <li>Each subtask has a clear output contract</li>
  </ul>
</div>
</v-click>

</div>

<v-click>
<div class="di-step-card" style="margin-top: 0.6rem; border-left-color: #0D7377;">
  <span class="di-step-num" style="color: #0D7377;">Dynamic selection</span>
  The coordinator may also select subagents dynamically — choosing which specialized subagent to use based on the nature of the task. This is called <strong>dynamic subagent selection</strong> and requires the coordinator to reason about capabilities, not just dispatch blindly.
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
The first job is decompose.

Good decomposition produces subtasks with clear, bounded responsibilities and no implicit dependencies on each other.

Poor decomposition means one subagent has too many responsibilities, subtasks have unclear output contracts, or one subagent implicitly assumes what another will produce without the coordinator managing that dependency.

Good decomposition means each subagent has one clearly defined job. Independent tasks can run in parallel. Dependent tasks are chained explicitly by the coordinator. And each subtask has a clear output contract so aggregation is straightforward.

The coordinator may also do dynamic subagent selection — choosing which specialized subagent to use based on the nature of the request. This requires the coordinator to reason about capabilities.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 4 — Delegate: Explicit Context Passing
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Delegate — Explicit Context Passing</div>

<div class="di-body" style="margin-top: 0.5rem;">

<v-click>
<p>Delegation is not just spawning. It's spawning with <strong>exactly the right context</strong>.</p>
</v-click>

<v-click>
<div class="di-step-card">
  <span class="di-step-num">Rule 1</span>
  Subagents start with <strong>fresh context</strong>. The coordinator's conversation history is not passed down. Everything the subagent needs must be included in its task prompt.
</div>
</v-click>

<v-click>
<div class="di-step-card" style="border-left-color: #0D7377;">
  <span class="di-step-num" style="color: #0D7377;">Rule 2</span>
  The task prompt must include: the specific objective, all relevant background, output format requirements, and any constraints. If the synthesis subagent needs facts discovered by the research subagent, the <strong>coordinator injects those facts explicitly</strong>.
</div>
</v-click>

<v-click>
<div class="di-step-card" style="border-left-color: #1B8A5A;">
  <span class="di-step-num" style="color: #1B8A5A;">Rule 3</span>
  Only give each subagent the tools it needs for its specific job. A document analysis subagent doesn't need web search tools. Constrained tool sets = predictable, auditable behavior.
</div>
</v-click>

<v-click>
<div style="background: #FFF0F0; border-left: 3px solid #E53E3E; padding: 0.45rem 0.8rem; border-radius: 4px; font-size: 0.86rem; margin-top: 0.25rem;">
  <strong>The delegation failure mode:</strong> Assuming the subagent "knows what you mean." It doesn't. Every assumption must be made explicit.
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
Delegation is not just spawning. It's spawning with exactly the right context.

Three rules for delegation:

Rule one: subagents start with fresh context. The coordinator's conversation history is not passed down. Everything the subagent needs must be included in its task prompt.

Rule two: the task prompt must include the specific objective, all relevant background, output format requirements, and any constraints. If the synthesis subagent needs facts discovered by the research subagent, the coordinator injects those facts explicitly. The coordinator bridges the gap between subagents.

Rule three: only give each subagent the tools it needs for its specific job. A document analysis subagent doesn't need web search tools. Constrained tool sets produce predictable, auditable behavior.

The delegation failure mode: assuming the subagent "knows what you mean." It doesn't. Every assumption must be made explicit.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 5 — Aggregate: Collecting and Synthesizing Results
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Aggregate — Collecting and Synthesizing Results</div>

<div class="di-body" style="margin-top: 0.5rem;">

<v-click>
<p>Aggregation is the coordinator's final responsibility — and the most complex, because subagents can fail.</p>
</v-click>

<v-click>
<div class="di-step-card">
  <span class="di-step-num">Happy path</span>
  All subagents return results. The coordinator synthesizes them into a coherent output — combining, deduplicating, and formatting the final response.
</div>
</v-click>

<v-click>
<div class="di-step-card" style="border-left-color: #E3A008;">
  <span class="di-step-num" style="color: #E3A008;">Partial failure</span>
  One subagent fails or returns no result. The coordinator must decide: retry the failing subagent, proceed without that result, or surface the failure explicitly to the caller.
</div>
</v-click>

<v-click>
<div class="di-step-card" style="border-left-color: #E53E3E;">
  <span class="di-step-num" style="color: #E53E3E;">Total failure</span>
  Critical subagent fails (one whose output is required for the final response). The coordinator must surface this clearly — not return a silently incomplete result.
</div>
</v-click>

<v-click>
<div style="background: #FFF8E6; border-left: 3px solid #E3A008; padding: 0.45rem 0.8rem; border-radius: 4px; font-size: 0.86rem; margin-top: 0.4rem;">
  <strong>The aggregation rule:</strong> The coordinator is the single point of error handling for all subagent outputs. Errors must be caught here — not silently dropped.
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
Aggregation is the coordinator's final responsibility — and the most complex, because subagents can fail.

On the happy path, all subagents return results and the coordinator synthesizes them into a coherent output, combining, deduplicating, and formatting the final response.

On partial failure, one subagent fails or returns no result. The coordinator must decide: retry the failing subagent, proceed without that result, or surface the failure explicitly to the caller.

On total failure, a critical subagent fails — one whose output is required for the final response. The coordinator must surface this clearly. Not return a silently incomplete result.

The aggregation rule: the coordinator is the single point of error handling for all subagent outputs. Errors must be caught here — not silently dropped.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 6 — The Full Coordinator Lifecycle
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">The Full Coordinator Lifecycle</div>

<v-click>
<div style="display: flex; align-items: stretch; gap: 1.5rem; margin-top: 0.5rem;">

  <div style="flex: 0 0 42%; display: flex; flex-direction: column; align-items: center; gap: 0.2rem;">
    <div class="di-flow-box" style="width: 100%; font-size: 0.82rem;">Receive user task</div>
    <div class="di-arrow">↓</div>
    <div class="di-flow-box" style="width: 100%; font-size: 0.82rem; background: #0D7377;">Decompose into subtasks</div>
    <div class="di-arrow">↓</div>
    <div class="di-flow-box" style="width: 100%; font-size: 0.82rem; background: #2a4a6a;">Select subagents dynamically</div>
    <div class="di-arrow">↓</div>
    <div class="di-flow-tool" style="width: 100%; font-size: 0.82rem;">Spawn subagents via Task tool<br>(with explicit context)</div>
    <div class="di-arrow">↓</div>
    <div class="di-flow-box" style="width: 100%; font-size: 0.82rem; background: #0D7377;">Receive subagent results</div>
    <div class="di-arrow">↓</div>
    <div class="di-flow-stop" style="width: 100%; font-size: 0.82rem;">Aggregate → Return final output</div>
  </div>

  <div style="flex: 1; font-size: 0.88rem; color: #111928; line-height: 1.65;">
    <v-click at="2">
    <div class="di-step-card" style="margin-bottom: 0.4rem;">
      <span class="di-step-num">Decompose</span> Each subtask has one owner, clear scope, explicit output contract
    </div>
    </v-click>
    <v-click at="3">
    <div class="di-step-card" style="border-left-color: #0D7377; margin-bottom: 0.4rem;">
      <span class="di-step-num" style="color: #0D7377;">Select</span> Choose the right specialized subagent — not all tasks need the same agent
    </div>
    </v-click>
    <v-click at="4">
    <div class="di-step-card" style="border-left-color: #E3A008; margin-bottom: 0.4rem;">
      <span class="di-step-num" style="color: #E3A008;">Spawn</span> Pass exactly what's needed — no more, no less
    </div>
    </v-click>
    <v-click at="5">
    <div class="di-step-card" style="border-left-color: #1B8A5A;">
      <span class="di-step-num" style="color: #1B8A5A;">Aggregate</span> Handle errors, synthesize outputs, return coherent result
    </div>
    </v-click>
  </div>

</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Let's put the full coordinator lifecycle together.

The coordinator receives the user task. It decomposes it into subtasks with clear owners and output contracts. It selects the right specialized subagent for each subtask — dynamic subagent selection. It spawns each subagent via the Task tool, passing exactly the context needed. It receives the results. And it aggregates — handling errors, synthesizing outputs, and returning a coherent final result.

Every step in this lifecycle has an architectural constraint that the exam may test.
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
<div class="di-exam-subtitle">Coordinator Responsibility Boundaries</div>

<div class="di-exam-body">
  The exam tests whether you know which responsibilities belong to the coordinator vs the subagent. Two common traps:
</div>
</v-click>

<v-click>
<div class="di-trap-box">
  <div class="di-trap-label">❌ Trap 1 — Coordinator Doing Domain Work</div>
  Answer choice shows coordinator browsing the web, analyzing documents, or writing the final report directly.
  The coordinator <strong>delegates</strong> — it never executes domain tasks.
</div>
</v-click>

<v-click>
<div class="di-trap-box" style="margin-top: 0.5rem;">
  <div class="di-trap-label">❌ Trap 2 — Assuming Implicit Context Propagation</div>
  Answer choice describes a subagent that "picks up where the coordinator left off" without the coordinator explicitly passing context.
  Subagents start fresh — <strong>all context must be passed explicitly by the coordinator</strong>.
</div>
</v-click>

<v-click>
<div class="di-correct-box" style="margin-top: 0.5rem;">
  <div class="di-correct-label">✓ Remember</div>
  Coordinator = Decompose, Delegate (with explicit context), Aggregate (with error handling).<br>
  Dynamic subagent selection = coordinator chooses the right agent based on task nature.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
The exam tests whether you know which responsibilities belong to the coordinator versus the subagent. Two common traps.

Trap one: coordinator doing domain work. The answer choice shows the coordinator browsing the web, analyzing documents, or writing the final report directly. The coordinator delegates — it never executes domain tasks.

Trap two: assuming implicit context propagation. The answer choice describes a subagent that "picks up where the coordinator left off" without the coordinator explicitly passing context. Subagents start fresh — all context must be passed explicitly by the coordinator.

Remember: Coordinator equals Decompose, Delegate with explicit context, and Aggregate with error handling. Dynamic subagent selection means the coordinator chooses the right agent based on the nature of the task.
-->

---
layout: default
class: di-takeaway-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 8 — Key Takeaways
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-takeaway-title">The Coordinator's Role</div>

<ul class="di-takeaway-list">
  <v-click><li>The coordinator <strong>orchestrates</strong> — it never executes domain tasks directly</li></v-click>
  <v-click><li><strong>Decompose:</strong> bounded subtasks with clear output contracts and no implicit dependencies</li></v-click>
  <v-click><li><strong>Delegate:</strong> explicit context passing — subagents start fresh, so everything must be in the prompt</li></v-click>
  <v-click><li><strong>Aggregate:</strong> handle all outcomes — success, partial failure, and total failure</li></v-click>
  <v-click><li><strong>Dynamic subagent selection:</strong> coordinator chooses the right specialized agent based on task nature</li></v-click>
  <v-click><li>The coordinator is the single point of error handling for all subagent outputs</li></v-click>
</ul>

<img src="/logo.png" class="di-logo" style="opacity: 0.75;" />

<!--
To summarize the coordinator's role:

The coordinator orchestrates — it never executes domain tasks directly.

Decompose: bounded subtasks with clear output contracts and no implicit dependencies.

Delegate: explicit context passing — subagents start fresh, so everything must be in the prompt.

Aggregate: handle all outcomes — success, partial failure, and total failure. Errors cannot be silently dropped.

Dynamic subagent selection: the coordinator chooses the right specialized agent based on the nature of the task.

And the coordinator is the single point of error handling for all subagent outputs.
-->
