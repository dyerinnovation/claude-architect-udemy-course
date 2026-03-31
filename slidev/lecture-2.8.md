---
theme: default
title: "Lecture 2.8: Parallel Subagent Execution"
info: |
  Claude Certified Architect – Foundations
  Section 2: Domain 1 — Agentic Architecture & Orchestration (27%)
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
  <div class="di-cover-title">Parallel Subagent Execution</div>
  <div class="di-cover-subtitle">Lecture 2.8 · Domain 1 — Agentic Architecture & Orchestration (27%)</div>
</div>

<img src="/logo.png" class="di-logo-centered" />

<!--
We've covered what subagents are, how context isolation works, and how to spawn them with the Task tool.

Now we're going to look at the most powerful capability in multi-agent architecture: running subagents in parallel.

Parallel execution is what takes a multi-agent system from "interesting" to "fast." Instead of waiting for each subagent to finish before starting the next, you run multiple subagents simultaneously and collect their results when they're all done.

But parallel execution in Claude's architecture has a specific definition — and the exam tests whether you know the exact mechanism.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 2 — What Parallel Execution Means
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">What "Parallel" Means in This Architecture</div>

<div class="di-body" style="margin-top: 0.5rem;">

<v-click>
<p>Parallel subagent execution has a precise definition in Claude's agent framework:</p>
</v-click>

<v-click>
<div style="background: #1A3A4A; color: white; border-radius: 8px; padding: 0.8rem 1.2rem; margin-top: 0.5rem; text-align: center;">
  <span style="font-size: 1.2rem; font-weight: 800; color: #3CAF50;">Multiple Task calls</span>
  <span style="font-size: 1.1rem;"> issued in a </span>
  <span style="font-size: 1.2rem; font-weight: 800; color: #E3A008;">single coordinator response turn</span>
</div>
</v-click>

<v-click>
<div style="display: flex; gap: 1rem; margin-top: 0.6rem;">
  <div style="flex: 1; background: #FFF0F0; border: 1px solid #ffc8c8; border-top: 3px solid #E53E3E; border-radius: 6px; padding: 0.6rem 0.8rem; font-size: 0.86rem;">
    <div style="font-weight: 700; color: #E53E3E; margin-bottom: 0.3rem;">❌ NOT parallel</div>
    Coordinator spawns subagent 1 → <em>waits for result</em> → spawns subagent 2 → <em>waits for result</em> → spawns subagent 3. This is sequential across multiple coordinator turns.
  </div>
  <div style="flex: 1; background: #F0FFF4; border: 1px solid #c8e6d0; border-top: 3px solid #3CAF50; border-radius: 6px; padding: 0.6rem 0.8rem; font-size: 0.86rem;">
    <div style="font-weight: 700; color: #1B8A5A; margin-bottom: 0.3rem;">✓ Parallel</div>
    Coordinator issues Task calls for subagents 1, 2, and 3 <em>in the same response</em>. All three run simultaneously. Coordinator collects all results in one batch.
  </div>
</div>
</v-click>

<v-click>
<div style="background: #FFF8E6; border-left: 3px solid #E3A008; padding: 0.45rem 0.8rem; border-radius: 4px; font-size: 0.88rem; margin-top: 0.5rem;">
  <strong>Exam key phrase:</strong> "all parallel subagent spawning happens in <em>one</em> coordinator response turn"
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
Parallel subagent execution has a precise definition in Claude's agent framework.

It means: multiple Task calls issued in a single coordinator response turn.

What it is not: the coordinator spawning subagent 1, waiting for the result, then spawning subagent 2, and so on. That's sequential — it spans multiple coordinator turns.

What it is: the coordinator issues Task calls for subagents 1, 2, and 3 in the same response. All three run simultaneously. The coordinator collects all results in one batch.

The exam key phrase: all parallel subagent spawning happens in one coordinator response turn.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 3 — Sequential vs Parallel — When to Use Each
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Sequential vs Parallel — When to Use Each</div>

<div class="di-body" style="margin-top: 0.5rem;">

<v-click>
<p>The decision rule is simple: <strong>independent tasks can run in parallel; dependent tasks must run sequentially.</strong></p>
</v-click>

<v-click>
<div class="di-step-card">
  <span class="di-step-num">Use parallel when</span>
  The tasks do not depend on each other's output. Web search, document analysis, and source verification for the same research topic — each can proceed without knowing what the others found.
</div>
</v-click>

<v-click>
<div class="di-step-card" style="border-left-color: #E3A008;">
  <span class="di-step-num" style="color: #E3A008;">Use sequential when</span>
  Task B requires the output of Task A. A synthesis subagent cannot write a synthesis until the research subagent has produced findings. The dependent subagent must wait.
</div>
</v-click>

<v-click>
<div style="display: flex; gap: 0.75rem; margin-top: 0.4rem; font-size: 0.84rem;">
  <div style="flex: 1; background: white; border-radius: 5px; padding: 0.5rem 0.7rem; border: 1px solid #c8e6d0;">
    <div style="font-weight: 700; color: #1B8A5A; margin-bottom: 0.3rem;">Parallel example</div>
    <em>Research pipeline:</em><br>
    Doc analysis + Web search + Source verify → all independent → spawn together
  </div>
  <div style="flex: 1; background: white; border-radius: 5px; padding: 0.5rem 0.7rem; border: 1px solid #c8e6d0;">
    <div style="font-weight: 700; color: #E3A008; margin-bottom: 0.3rem;">Sequential example</div>
    <em>Research pipeline:</em><br>
    Research phase (parallel) → <em>wait for all results</em> → Synthesis (depends on research)
  </div>
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
The decision rule is simple: independent tasks can run in parallel; dependent tasks must run sequentially.

Use parallel when the tasks do not depend on each other's output. Web search, document analysis, and source verification for the same research topic — each can proceed without knowing what the others found.

Use sequential when Task B requires the output of Task A. A synthesis subagent cannot write a synthesis until the research subagent has produced findings. The dependent subagent must wait.

In the research pipeline example: the first phase — document analysis, web search, and source verification — all run in parallel. Then the coordinator waits for all three results. The synthesis subagent runs after, because it depends on what the first phase found.
-->

---
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 4 — Parallel Spawning in Code
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">Parallel Spawning — What the Coordinator Response Looks Like</div>

<v-click>

```python {all|3-16|17-30|31-35}
# The coordinator's response.content contains multiple Task blocks
# — all in ONE response turn — that's what makes it parallel
coordinator_response_content = [
    {
        "type": "tool_use",
        "id": "task_web_01",
        "name": "Task",
        "input": {
            "description": "Web search on AI safety regulations",
            "prompt": "Search for recent AI safety regulations. Return structured summary.",
            "allowedTools": ["Task", "web_search", "read_url"]
        }
    },
    {
        "type": "tool_use",
        "id": "task_docs_01",
        "name": "Task",
        "input": {
            "description": "Analyze uploaded policy documents",
            "prompt": "Analyze these policy documents: {docs}. Extract requirements.",
            "allowedTools": ["Task", "read_file"]
        }
    },
    {
        "type": "tool_use",
        "id": "task_verify_01",
        "name": "Task",
        "input": {
            "description": "Verify source credibility",
            "prompt": "Verify credibility of sources: {source_list}.",
            "allowedTools": ["Task", "web_search"]
        }
    }
    # All three Task calls in one response = parallel execution
]
```

</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Here's what parallel subagent spawning looks like in code.

The coordinator's response.content contains three Task tool_use blocks — all in one response turn. Each has its own ID, description, prompt with explicit context, and allowedTools including "Task."

Because all three appear in the same response, they are considered parallel. The coordinator issued three task assignments simultaneously. All three subagents execute. The coordinator then collects all three results as tool_result messages before continuing.

This is the key: it's not about what's happening at the infrastructure level — it's about the fact that all Task calls were issued in a single coordinator turn.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 5 — Collecting Results from Parallel Subagents
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Collecting Results from Parallel Subagents</div>

<div class="di-body" style="margin-top: 0.5rem;">

<v-click>
<p>After issuing parallel Task calls, the coordinator waits for all results. The results arrive as <code class="di-code-inline">tool_result</code> messages — one per Task call — all in a single user message batch.</p>
</v-click>

<v-click>
<div style="display: flex; align-items: center; gap: 0.4rem; flex-wrap: wrap; margin: 0.5rem 0; font-size: 0.82rem;">
  <div style="background: #1A3A4A; color: white; border-radius: 5px; padding: 0.3rem 0.6rem;">Coordinator<br><span style="color: #E3A008; font-size: 0.75rem;">3 Task calls</span></div>
  <div style="color: #0D7377;">→</div>
  <div style="display: flex; flex-direction: column; gap: 0.2rem;">
    <div style="background: #E3A008; color: white; border-radius: 5px; padding: 0.25rem 0.5rem; font-size: 0.78rem;">Web search agent</div>
    <div style="background: #E3A008; color: white; border-radius: 5px; padding: 0.25rem 0.5rem; font-size: 0.78rem;">Doc analysis agent</div>
    <div style="background: #E3A008; color: white; border-radius: 5px; padding: 0.25rem 0.5rem; font-size: 0.78rem;">Source verify agent</div>
  </div>
  <div style="color: #0D7377;">→</div>
  <div style="background: #E8F5EB; border: 1px solid #c8e6d0; border-radius: 5px; padding: 0.3rem 0.6rem; font-size: 0.82rem; color: #111928;">user message<br><span style="font-size: 0.75rem; color: #1B8A5A;">3 tool_results</span></div>
  <div style="color: #0D7377;">→</div>
  <div style="background: #1A3A4A; color: white; border-radius: 5px; padding: 0.3rem 0.6rem; font-size: 0.82rem;">Coordinator<br><span style="color: #A8D5C2; font-size: 0.75rem;">aggregates</span></div>
</div>
</v-click>

<v-click>
<div class="di-step-card" style="margin-top: 0.4rem;">
  <span class="di-step-num">All results, one batch</span>
  Just like single-agent tool results, all tool_result blocks for parallel subagent calls go in a single user message. The coordinator receives all three results before its next turn.
</div>
</v-click>

<v-click>
<div class="di-step-card" style="border-left-color: #E53E3E;">
  <span class="di-step-num" style="color: #E53E3E;">Handling partial failures</span>
  If one parallel subagent fails, its result arrives as <code class="di-code-inline">is_error: true</code>. The coordinator must handle this gracefully — not silently drop the failure or return an incomplete result.
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
After issuing parallel Task calls, the coordinator waits for all results. The results arrive as tool_result messages — one per Task call — all in a single user message batch.

Just like single-agent tool results, all tool_result blocks for parallel subagent calls go in a single user message. The coordinator receives all three results before its next turn.

If one parallel subagent fails, its result arrives with is_error: true. The coordinator must handle this gracefully — not silently drop the failure or return an incomplete result.

This is the same pattern as parallel tool calls in a single-agent loop, applied to subagents. The mechanics are identical.
-->

---
layout: two-cols
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 6 — Parallel vs Sequential: The Full Comparison
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header" style="margin: -1.5rem -1rem 1rem -2rem; padding-right: 1rem;">Parallel vs Sequential — Full Comparison</div>

<v-click>
<div style="padding-right: 1.2rem;">
  <div class="di-col-left-label">Sequential Execution</div>
  <div class="di-col-body">
    <ul>
      <li>One Task call per coordinator turn</li>
      <li>Coordinator waits for each result before proceeding</li>
      <li>Use when: Task B depends on Task A's output</li>
      <li>Total time: sum of all subagent execution times</li>
    </ul>
    <div style="margin-top: 0.5rem; background: #E8F5EB; border-radius: 5px; padding: 0.5rem 0.7rem; font-size: 0.86rem;">
      <strong>Example:</strong> Research → <em>wait</em> → Synthesis
    </div>
    <div style="margin-top: 0.4rem; font-size: 0.84rem; color: #1A3A4A; font-style: italic;">Required when there's a data dependency</div>
  </div>
</div>
</v-click>

::right::

<v-click>
<div style="padding-left: 1.2rem; padding-top: 5rem;">
  <div class="di-col-right-label">Parallel Execution</div>
  <div class="di-col-body">
    <ul>
      <li>Multiple Task calls in <strong>one</strong> coordinator turn</li>
      <li>All subagents run simultaneously</li>
      <li>Use when: tasks are independent of each other</li>
      <li>Total time: roughly the slowest subagent's time</li>
    </ul>
    <div style="margin-top: 0.5rem; background: #E8F5EB; border-radius: 5px; padding: 0.5rem 0.7rem; font-size: 0.86rem;">
      <strong>Example:</strong> Web search + Doc analysis + Source verify
    </div>
    <div style="margin-top: 0.4rem; font-size: 0.84rem; color: #1A3A4A; font-style: italic;">Use when there's no data dependency</div>
  </div>
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Let's put the full comparison side by side.

Sequential: one Task call per coordinator turn. The coordinator waits for each result before proceeding. Use when Task B depends on Task A's output. Total time is the sum of all subagent execution times.

Parallel: multiple Task calls in one coordinator turn. All subagents run simultaneously. Use when tasks are independent of each other. Total time is roughly the slowest subagent's time — a major efficiency gain.

The deciding factor is always data dependency. If there's a dependency, use sequential. If there isn't, use parallel.

In a real pipeline like the research system, you'll use both: a parallel phase for independent data collection, followed by a sequential synthesis step that depends on the collected data.
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
<div class="di-exam-subtitle">Parallel Subagent Execution — The Key Trap</div>

<div class="di-exam-body">
  The exam specifically tests whether candidates understand the mechanism of parallel execution — not just the concept.
</div>
</v-click>

<v-click>
<div class="di-trap-box">
  <div class="di-trap-label">❌ The Common Trap</div>
  An answer describes "parallel" execution where the coordinator spawns subagents across multiple turns, waiting for each before spawning the next. This is <strong>sequential</strong> — not parallel.
  <br><br>
  Also: answer choices that have subagents communicating with each other directly to share intermediate results. This violates hub-and-spoke regardless of execution order.
</div>
</v-click>

<v-click>
<div class="di-correct-box" style="margin-top: 0.5rem;">
  <div class="di-correct-label">✓ The Correct Definition</div>
  Parallel = <strong>multiple Task calls in one coordinator response turn</strong>.<br>
  Independent tasks → parallel. Dependent tasks → sequential.<br>
  All results come back as a batch before the coordinator's next turn.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
The exam specifically tests whether candidates understand the mechanism of parallel execution — not just the concept.

The common trap: an answer describes "parallel" execution where the coordinator spawns subagents across multiple turns, waiting for each before spawning the next. That's sequential. It may describe independent tasks, but if they're spawned one at a time across multiple turns, the execution is sequential.

Also watch for: answer choices that have subagents communicating with each other directly to share intermediate results. That violates hub-and-spoke regardless of execution order.

The correct definition: parallel means multiple Task calls in one coordinator response turn. Independent tasks go parallel. Dependent tasks go sequential. All results come back as a batch before the coordinator's next turn.
-->

---
layout: default
class: di-takeaway-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 8 — Key Takeaways
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-takeaway-title">Parallel Subagent Execution</div>

<ul class="di-takeaway-list">
  <v-click><li><strong>Parallel = multiple Task calls in ONE coordinator response turn</strong> — not across multiple turns</li></v-click>
  <v-click><li><strong>Independent tasks → parallel</strong>; tasks with data dependencies → sequential</li></v-click>
  <v-click><li>All parallel subagent results return as a <strong>single batch</strong> before the coordinator's next turn</li></v-click>
  <v-click><li>Parallel execution time ≈ the <strong>slowest subagent</strong> — not the sum of all subagents</li></v-click>
  <v-click><li>Partial failures in parallel batches must be handled explicitly — <code style="color: #A8D5C2;">is_error: true</code> tool_results</li></v-click>
  <v-click><li>Real pipelines mix both: <strong>parallel phase</strong> (independent collection) then <strong>sequential phase</strong> (dependent synthesis)</li></v-click>
</ul>

<img src="/logo.png" class="di-logo" style="opacity: 0.75;" />

<!--
To summarize parallel subagent execution:

Parallel means multiple Task calls in one coordinator response turn — not across multiple turns.

Independent tasks go parallel; tasks with data dependencies go sequential.

All parallel subagent results return as a single batch before the coordinator's next turn.

Parallel execution time is approximately the slowest subagent — not the sum of all subagents. That's the efficiency gain.

Partial failures in parallel batches must be handled explicitly — they arrive as is_error: true tool_results.

And real pipelines mix both patterns: a parallel phase for independent data collection, followed by a sequential phase for dependent synthesis.
-->
