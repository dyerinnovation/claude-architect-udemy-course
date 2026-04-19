---
theme: default
title: "Lecture 3.12: Task Decomposition: Prompt Chaining vs Dynamic Adaptive"
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
  <div class="di-cover-title">Task Decomposition:<br>Prompt Chaining vs Dynamic Adaptive</div>
  <div class="di-cover-subtitle">Lecture 3.12 · Domain 1 — Agentic Architecture & Orchestration (27%)</div>
</div>

<img src="/logo.png" class="di-logo-centered" />

<!--
Complex tasks are almost never solved in a single model call. You decompose them.

But how you decompose a task determines how reliable, flexible, and maintainable your system is.

There are two fundamentally different strategies: prompt chaining — a fixed, predetermined sequence of steps — and dynamic adaptive decomposition — where the next step is determined by the results of the current one.

Each has its place. This lecture teaches you to tell them apart and apply them correctly.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 2 — What Is Task Decomposition
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">What Is Task Decomposition and Why It Matters</div>

<div class="di-body" style="margin-top: 0.75rem;">

<v-click>
<p>Task decomposition is the practice of breaking a complex request into a sequence of smaller, focused subtasks — each handled by a separate model call or agent.</p>
</v-click>

<v-click>
<div style="display: flex; gap: 1rem; margin-top: 0.75rem;">
  <div style="flex: 1; background: white; border: 1px solid #c8e6d0; border-radius: 6px; padding: 0.65rem 0.85rem; font-size: 0.9rem;">
    <div style="font-weight: 700; color: #1B8A5A; margin-bottom: 0.25rem;">Why decompose?</div>
    <ul style="margin: 0; padding-left: 1.1rem; line-height: 1.6;">
      <li>Single calls have context and attention limits</li>
      <li>Focused prompts produce higher-quality outputs</li>
      <li>Subtasks can be verified independently</li>
      <li>Parallel execution is possible when steps are independent</li>
    </ul>
  </div>
</div>
</v-click>

<v-click>
<div style="display: flex; gap: 1rem; margin-top: 0.6rem;">
  <div style="flex: 1; background: #FFF8E6; border-left: 3px solid #E3A008; border-radius: 4px; padding: 0.55rem 0.8rem; font-size: 0.9rem;">
    <strong>The design question:</strong> Is the sequence of subtasks fixed and known in advance — or does each step's output determine what the next step should be?
  </div>
</div>
</v-click>

<v-click>
<div style="display: flex; gap: 1rem; margin-top: 0.5rem;">
  <div style="flex: 1; text-align: center; background: white; border: 1px solid #c8e6d0; border-radius: 6px; padding: 0.55rem; font-size: 0.9rem; font-weight: 700; color: #1B8A5A;">Fixed sequence → Prompt Chaining</div>
  <div style="display: flex; align-items: center; font-size: 1.2rem; color: #0D7377;">·</div>
  <div style="flex: 1; text-align: center; background: white; border: 1px solid #c8e6d0; border-radius: 6px; padding: 0.55rem; font-size: 0.9rem; font-weight: 700; color: #0D7377;">Results-driven sequence → Dynamic Adaptive</div>
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
Task decomposition is breaking a complex request into smaller, focused subtasks. Each subtask is handled by a separate model call or agent.

[click] Why decompose at all? Context limits, attention quality, independent verification, and parallel execution are all reasons. A focused prompt on a well-scoped subtask produces better output than one massive prompt trying to do everything at once.

[click] The key design question is: do you know the sequence of steps in advance, or does each step's output determine what comes next?

[click] If the sequence is fixed and known upfront, you want prompt chaining. If the sequence adapts based on results, you want dynamic adaptive decomposition. These are not interchangeable — choosing the wrong one makes your system either too rigid or unnecessarily complex.
-->

---
layout: two-cols
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 3 — Prompt Chaining vs Dynamic Adaptive
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header" style="margin: -1.5rem -1rem 1rem -2rem; padding-right: 1rem;">Prompt Chaining vs Dynamic Adaptive</div>

<v-click>
<div style="padding-right: 1.2rem;">
  <div class="di-col-left-label">Prompt Chaining (Fixed Sequential)</div>
  <div class="di-col-body">
    <ul>
      <li>Steps are defined upfront in code</li>
      <li>Each step receives the prior step's output as input</li>
      <li>The sequence never changes — same order every time</li>
      <li>Easy to reason about, test, and debug</li>
      <li>Output quality of each step is independently verifiable</li>
    </ul>
    <div style="margin-top: 0.5rem; background: #E8F5EB; padding: 0.5rem 0.7rem; border-radius: 5px; font-size: 0.88rem;">
      <strong>Best for:</strong> predictable, well-understood workflows (code review, report generation, structured analysis)
    </div>
  </div>
</div>
</v-click>

::right::

<v-click>
<div style="padding-left: 1.2rem; padding-top: 5rem;">
  <div class="di-col-right-label">Dynamic Adaptive</div>
  <div class="di-col-body">
    <ul>
      <li>Claude decides what to do next based on current results</li>
      <li>The step sequence emerges from the task, not from code</li>
      <li>Handles novel paths and unexpected findings</li>
      <li>More powerful — but harder to predict and test</li>
      <li>Requires safeguards: loop limits, timeout, human checkpoints</li>
    </ul>
    <div style="margin-top: 0.5rem; background: #FFF8E6; border-left: 3px solid #E3A008; padding: 0.5rem 0.7rem; border-radius: 5px; font-size: 0.88rem;">
      <strong>Best for:</strong> open-ended investigation, research, debugging, tasks where the path is unknown upfront
    </div>
  </div>
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Let's compare them directly.

Prompt chaining is a fixed sequence. The steps are defined in your code. Each step receives the prior step's output as input. The order never changes. It's predictable, easy to test, and easy to debug.

[click] Dynamic adaptive decomposition is model-driven. Claude decides what to do next based on what it found. The step sequence emerges from the task itself. This is more powerful — it handles unexpected findings and novel paths — but it requires safeguards to prevent infinite loops and runaway execution.

The choice is driven by the task structure. Code review? Fixed. You know the steps: read the file, analyze it, produce a report. You don't need Claude to invent new steps. But a bug investigation? Dynamic. You don't know upfront whether the bug is in the API layer, the database, or the frontend — Claude needs to follow the evidence.
-->

---
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 4 — Prompt Chaining Pattern: Code Review
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">Prompt Chaining — Code Review Pipeline</div>

<v-click>

```python {all|3-13|16-24|27-33|all}
# Fixed sequential pipeline: per-file analysis → cross-file integration pass
def run_code_review_pipeline(file_paths: list[str]) -> dict:

    # Step 1: Per-file analysis — run in parallel, each is independent
    per_file_results = []
    for path in file_paths:
        result = client.messages.create(
            model="claude-opus-4-6",
            system="You are a code reviewer. Analyze this file for bugs, style, and security issues.",
            messages=[{"role": "user", "content": f"File: {path}\n\n{read_file(path)}"}]
        )
        per_file_results.append({"file": path, "analysis": result.content[0].text})

    # Step 2: Cross-file integration pass — depends on Step 1
    integration_context = format_per_file_results(per_file_results)
    integration_result = client.messages.create(
        model="claude-opus-4-6",
        system="You are a senior engineer. Identify cross-file issues: import cycles, interface mismatches, architectural concerns.",
        messages=[{"role": "user", "content": f"Per-file analyses:\n\n{integration_context}\n\nIdentify cross-cutting issues."}]
    )

    # Step 3: Final report synthesis — depends on Step 2
    return synthesize_report(per_file_results, integration_result.content[0].text)
```

</v-click>

<v-click>
<div style="background: white; padding: 0.4rem 0.75rem; border-radius: 4px; border-left: 2px solid #3CAF50; font-size: 0.82rem; margin-top: 0.4rem;">
  <strong style="color: #1B8A5A;">Key property:</strong> the sequence is determined by the engineer, not by Claude. Step 2 always follows Step 1. The pipeline is testable, repeatable, and auditable.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Here's the prompt chaining pattern in practice: a code review pipeline.

Step one: per-file analysis. Each file is reviewed independently by Claude. These calls can run in parallel because they don't depend on each other.

[click] Step two: cross-file integration pass. This step depends on Step 1 completing first. Claude receives all the per-file analyses and identifies cross-cutting issues — import cycles, interface mismatches, architectural concerns that only appear when you look across files.

[click] Step three: final report synthesis. This depends on Step 2.

The sequence is fixed in code. The engineer defines it. Claude executes each step — but it doesn't decide what step comes next. That predictability is what makes this pattern easy to test and reliable in production.
-->

---
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 5 — Dynamic Adaptive Pattern
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">Dynamic Adaptive — Open-Ended Investigation</div>

<v-click>

```python {all|4-9|12-24|all}
# Dynamic adaptive: Claude decides what to investigate based on results
def run_investigation(initial_query: str, max_steps: int = 10) -> str:
    messages = [{"role": "user", "content": initial_query}]
    step_count = 0

    while step_count < max_steps:
        response = client.messages.create(
            model="claude-opus-4-6",
            tools=investigation_tools,   # search, read_file, query_db, check_logs
            messages=messages
        )
        step_count += 1

        if response.stop_reason == "end_turn":
            # Claude decided it has enough information to answer
            return response.content[0].text

        if response.stop_reason == "tool_use":
            # Claude is choosing what to investigate next — dynamic
            tool_results = execute_tools(response.content)
            messages.append({"role": "assistant", "content": response.content})
            messages.append({"role": "user", "content": tool_results})

    # Safety valve: max_steps exceeded — surface partial findings
    return summarize_partial_findings(messages)
```

</v-click>

<v-click>
<div style="background: white; padding: 0.4rem 0.75rem; border-radius: 4px; border-left: 2px solid #E3A008; font-size: 0.82rem; margin-top: 0.4rem;">
  <strong style="color: #E3A008;">Safety valve:</strong> <code>max_steps</code> is required for dynamic adaptive. Without it, unexpected data could trigger infinite loops in production.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Here's the dynamic adaptive pattern.

The outer loop is the same agentic loop we've seen before. But the investigation tools give Claude full latitude to decide what to look at next: search logs, read files, query the database, check API responses.

[click] Claude drives the investigation. If it finds a database anomaly, it queries deeper into that. If it finds a relevant log entry, it reads more logs. The sequence of steps is not predetermined — it emerges from the task.

[click] The critical safety requirement: max_steps. In a dynamic adaptive system, Claude's decisions are driven by what it finds. Unexpected data or complex scenarios can lead to many more tool calls than anticipated. Without a step limit, you risk runaway loops in production. The max_steps cap is a safety valve — when it's hit, surface whatever partial findings exist rather than failing silently.

Dynamic adaptive is powerful. But power requires guardrails.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 6 — Choosing the Right Strategy
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Choosing the Right Decomposition Strategy</div>

<div class="di-body" style="margin-top: 0.75rem;">

<v-click>
<p>The choice depends on how much you know about the task structure before it starts executing.</p>
</v-click>

<div style="display: flex; flex-direction: column; gap: 0.45rem; margin-top: 0.6rem;">

  <v-click>
  <div class="di-step-card">
    <span class="di-step-num">Prompt chaining — use when:</span> the steps are known, the sequence is fixed, and correctness at each step can be independently verified. Code review, report generation, data transformation pipelines.
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card" style="border-left-color: #0D7377;">
    <span class="di-step-num" style="color: #0D7377;">Dynamic adaptive — use when:</span> the task is open-ended, the relevant path depends on findings, or the task space is too large to enumerate steps upfront. Debugging, research, investigative analysis.
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card" style="border-left-color: #E3A008;">
    <span class="di-step-num" style="color: #E3A008;">Hybrid — use when:</span> the outer structure is known (phases) but each phase is open-ended. Example: phase 1 = gather evidence (dynamic), phase 2 = write report from evidence (chained).
  </div>
  </v-click>

  <v-click>
  <div style="background: #FFF8E6; border-left: 3px solid #E3A008; padding: 0.5rem 0.8rem; border-radius: 4px; font-size: 0.88rem; margin-top: 0.25rem;">
    <strong>Default posture:</strong> start with prompt chaining whenever you can define the steps. Only use dynamic adaptive when the task genuinely requires it — it's harder to test, audit, and bound.
  </div>
  </v-click>

</div>

</div>

<img src="/logo.png" class="di-logo" />

<!--
How do you choose?

The determining factor is how much you know about the task structure before execution starts.

[click] If you know the steps and can define the sequence in code, use prompt chaining. Code review, report generation, data transformation — these have well-understood, repeatable sequences.

[click] If the task is open-ended and the path depends on what you find, use dynamic adaptive. Debugging, research investigation, root cause analysis — you can't enumerate the steps upfront.

[click] For many real systems, the answer is hybrid: the outer pipeline has a fixed structure — gather evidence, then synthesize, then report — but the gathering phase itself is dynamic. Phase boundaries are fixed; execution within phases is adaptive.

[click] The default posture: prefer prompt chaining when you can define the steps. Dynamic adaptive is more powerful but harder to test and harder to bound. Use it when the task genuinely requires it.
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
<div class="di-exam-subtitle">Recognizing the Right Decomposition Strategy</div>

<div class="di-exam-body">
  The exam will describe a workflow and ask which decomposition strategy is appropriate. The key signal is whether the step sequence is known upfront or depends on runtime findings.
</div>
</v-click>

<v-click>
<div class="di-trap-box">
  <div class="di-trap-label">❌ Common Trap</div>
  Choosing dynamic adaptive for a code review pipeline because "Claude should be flexible."
  Code review has well-defined steps: per-file analysis → cross-file integration → report. Fixed chaining is correct. Dynamic adaptive adds complexity without benefit.
</div>
</v-click>

<v-click>
<div class="di-correct-box">
  <div class="di-correct-label">✓ The Decision Rule</div>
  <strong>Can you enumerate the steps before the task starts?</strong><br>
  Yes → prompt chaining. The sequence is code, not model judgment.<br>
  No → dynamic adaptive. The model decides the next step based on results.<br>
  In both cases: define safety limits (max_steps, timeout, human checkpoints).
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
On the exam, you'll see a workflow description and a question about decomposition strategy.

The key signal: can you enumerate the steps before the task starts?

[click] The trap is choosing dynamic adaptive for predictable workflows — "to give Claude flexibility." A code review pipeline doesn't need flexibility. It needs predictability. Per-file analysis, then cross-file integration, then report. Fixed chaining is the correct answer. Dynamic adaptive adds complexity with no benefit for a known sequence.

[click] The decision rule: if the steps are known, use chaining. If the steps depend on findings, use dynamic adaptive. In both cases, define safety limits — max_steps for dynamic adaptive, timeouts for both.

Another exam signal: if the scenario mentions a "safety limit" or "step cap," that points to dynamic adaptive (since chaining doesn't need one). If it mentions "per-file, then integration pass," that points to chaining.
-->

---
layout: default
class: di-takeaway-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 8 — Key Takeaways
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-takeaway-title">Task Decomposition — What to Remember</div>

<ul class="di-takeaway-list">
  <v-click><li><strong>Prompt chaining</strong> = fixed sequence defined in code — predictable, testable, each step independently verifiable</li></v-click>
  <v-click><li><strong>Dynamic adaptive</strong> = model-driven — Claude decides the next step based on results — powerful but requires safety limits</li></v-click>
  <v-click><li>Code review pattern: per-file analysis → cross-file integration pass → report — always prompt chaining, never dynamic adaptive</li></v-click>
  <v-click><li>Dynamic adaptive requires a <code style="color: #A8D5C2;">max_steps</code> cap — without it, unexpected data can trigger unbounded loops</li></v-click>
  <v-click><li>Default to chaining when steps are known; use dynamic adaptive only when the path depends on runtime findings</li></v-click>
  <v-click><li>Hybrid is valid: fixed phase boundaries with dynamic execution within each phase</li></v-click>
</ul>

<img src="/logo.png" class="di-logo" style="opacity: 0.75;" />

<!--
To summarize:

Prompt chaining is a fixed sequence in code — predictable, testable, each step independently verifiable.

Dynamic adaptive is model-driven — Claude decides next steps based on results — powerful but requiring safety limits.

The code review pattern is the canonical prompt chaining example: per-file, then cross-file integration, then report. Fixed. Never dynamic adaptive.

Dynamic adaptive requires a max_steps cap. Without it, unexpected data can cause unbounded loops.

Default to chaining. Use dynamic adaptive only when the task is genuinely open-ended.

And hybrid is valid — fixed phases with dynamic execution within them — for systems where the outer structure is known but the inner investigation isn't.
-->
