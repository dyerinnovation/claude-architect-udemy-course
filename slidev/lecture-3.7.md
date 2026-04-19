---
theme: default
title: "Lecture 3.7: The Task Tool: Spawning Subagents"
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
  <div class="di-cover-title">The Task Tool:<br>Spawning Subagents</div>
  <div class="di-cover-subtitle">Lecture 3.7 · Domain 1 — Agentic Architecture & Orchestration (27%)</div>
</div>

<img src="/logo.png" class="di-logo-centered" />

<!--
In the last lecture, we covered what happens inside a subagent's context. Now let's look at the mechanism that creates subagents in the first place.

The Task tool is the specific tool that coordinators use to spawn subagents in Claude's agent framework. It's not a generic API call — it's a structured primitive with specific parameters, specific behaviors, and specific constraints.

Understanding the Task tool in detail is exam-critical. The allowedTools parameter in particular is a tested trap that catches candidates who understand the theory but not the implementation.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 2 — What the Task Tool Is
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">What the Task Tool Is</div>

<div class="di-body" style="margin-top: 0.75rem;">

<v-click>
<p>The <strong>Task tool</strong> is the mechanism through which a coordinator Claude instance spawns a subagent Claude instance. It is the formal handoff of work in a multi-agent system.</p>
</v-click>

<v-click>
<div style="display: flex; gap: 1rem; margin-top: 0.5rem;">
  <div style="flex: 1; background: white; border: 1px solid #c8e6d0; border-top: 3px solid #3CAF50; border-radius: 6px; padding: 0.6rem 0.8rem; font-size: 0.88rem;">
    <div style="font-weight: 700; color: #1A3A4A; margin-bottom: 0.3rem;">What it does</div>
    <ul style="margin: 0; padding-left: 1.2rem;">
      <li>Creates an independent Claude instance</li>
      <li>Passes a task description and instructions</li>
      <li>Constrains the subagent to specific tools</li>
      <li>Returns the subagent's final output to the coordinator</li>
    </ul>
  </div>
  <div style="flex: 1; background: white; border: 1px solid #c8e6d0; border-top: 3px solid #0D7377; border-radius: 6px; padding: 0.6rem 0.8rem; font-size: 0.88rem;">
    <div style="font-weight: 700; color: #1A3A4A; margin-bottom: 0.3rem;">What it is NOT</div>
    <ul style="margin: 0; padding-left: 1.2rem;">
      <li>Not a generic HTTP call to another service</li>
      <li>Not a thread or process fork</li>
      <li>Not a shared-memory communication channel</li>
      <li>Not persistent — each call is independent</li>
    </ul>
  </div>
</div>
</v-click>

<v-click>
<div style="background: #FFF8E6; border-left: 3px solid #E3A008; padding: 0.5rem 0.8rem; border-radius: 4px; font-size: 0.88rem; margin-top: 0.6rem;">
  <strong>The analogy:</strong> The Task tool is Claude's native way of saying "I need a specialist to handle this part — let me formally assign the work."
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
The Task tool is the mechanism through which a coordinator Claude instance spawns a subagent Claude instance. It is the formal handoff of work in a multi-agent system.

What it does: creates an independent Claude instance, passes a task description and instructions, constrains the subagent to specific tools, and returns the subagent's final output to the coordinator.

What it is not: it's not a generic HTTP call to another service. It's not a thread or process fork. It's not a shared-memory communication channel. And it's not persistent — each call is independent.

The analogy: the Task tool is Claude's native way of saying "I need a specialist to handle this part — let me formally assign the work."
-->

---
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 3 — The Task Tool Parameters
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">The Task Tool — Key Parameters</div>

<v-click>

```python {all|2-3|4-11|12-17}
task_call = {
    "type": "tool_use",
    "name": "Task",
    "input": {
        "description": "Analyze the following documents and extract key claims",
        "prompt": f"""
            You are a document analysis specialist.
            Analyze these documents: {document_list}
            Extract: key claims, supporting evidence, contradictions.
            Output format: structured JSON.
        """,
        "allowedTools": [
            "Task",           # ← CRITICAL: required for subagent to accept task
            "read_file",
            "search_documents"
        ]
    }
}
```

</v-click>

<v-click>
<div style="display: flex; gap: 0.75rem; margin-top: 0.4rem; font-size: 0.83rem;">
  <div style="flex: 1; background: white; border-radius: 4px; padding: 0.4rem 0.6rem; border-left: 3px solid #E3A008;">
    <strong style="color: #E3A008;"><code>allowedTools</code></strong> — controls which tools the subagent can use. Must include <code>"Task"</code> for the subagent to process its assignment.
  </div>
  <div style="flex: 1; background: white; border-radius: 4px; padding: 0.4rem 0.6rem; border-left: 3px solid #3CAF50;">
    <strong style="color: #1B8A5A;"><code>prompt</code></strong> — the complete context for the subagent. This is all it knows. Make it self-contained.
  </div>
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Let's look at the Task tool parameters in detail.

The Task call has a name of "Task" and an input object with three key fields.

The description gives a brief label for what the subagent should do.

The prompt is the complete task context — everything the subagent needs to complete its work. This is all it knows, so it must be self-contained.

The allowedTools array specifies which tools the subagent is permitted to use. This is where the exam trap lives, which we'll cover in detail next.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 4 — The allowedTools Requirement
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">The <code style="color: #A8D5C2;">allowedTools</code> Requirement — The Critical Detail</div>

<div class="di-body" style="margin-top: 0.5rem;">

<v-click>
<p>For a subagent to accept and process its task assignment, <code class="di-code-inline">"Task"</code> must be included in <code class="di-code-inline">allowedTools</code>.</p>
</v-click>

<v-click>
<div style="display: flex; gap: 1rem; margin-top: 0.5rem;">
  <div style="flex: 1; background: #FFF0F0; border: 2px solid #E53E3E; border-radius: 6px; padding: 0.6rem 0.8rem; font-size: 0.86rem;">
    <div style="font-weight: 700; color: #E53E3E; margin-bottom: 0.3rem;">❌ Missing "Task" in allowedTools</div>

```python
"allowedTools": ["read_file", "search_documents"]
# No "Task" — subagent cannot properly
# accept its task specification
```

  </div>
  <div style="flex: 1; background: #F0FFF4; border: 2px solid #3CAF50; border-radius: 6px; padding: 0.6rem 0.8rem; font-size: 0.86rem;">
    <div style="font-weight: 700; color: #1B8A5A; margin-bottom: 0.3rem;">✓ "Task" included in allowedTools</div>

```python
"allowedTools": [
    "Task",             # ← Required
    "read_file",
    "search_documents"
]
```

  </div>
</div>
</v-click>

<v-click>
<div class="di-step-card" style="margin-top: 0.6rem; border-left-color: #E3A008;">
  <span class="di-step-num" style="color: #E3A008;">Why "Task" must be included</span>
  The Task tool is how an agent formally accepts an assignment. The subagent needs Task in its allowed set to process the task specification it was spawned with. Without it, the subagent cannot properly acknowledge and execute the assignment.
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
The allowedTools requirement is the most exam-tested detail of the Task tool.

For a subagent to accept and process its task assignment, "Task" must be included in allowedTools.

Without it, the subagent cannot properly acknowledge and execute the assignment. The Task tool is how an agent formally accepts an assignment — it needs to be in the subagent's allowed set for the mechanism to work.

This trips candidates up because it seems counterintuitive. The subagent is being called via the Task tool — why does it also need Task in its own allowedTools? Because the subagent needs the ability to process task-based interactions, including its own task specification.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 5 — Constraining Subagent Capabilities
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Constraining Subagent Capabilities via allowedTools</div>

<div class="di-body" style="margin-top: 0.5rem;">

<v-click>
<p><code class="di-code-inline">allowedTools</code> is also a <strong>security and predictability mechanism</strong> — not just a technical requirement.</p>
</v-click>

<v-click>
<div class="di-step-card">
  <span class="di-step-num">Principle of least privilege</span>
  Each subagent should only have the tools required for its specific job. A document analysis subagent does not need web search. A web search subagent does not need file write access.
</div>
</v-click>

<v-click>
<div class="di-step-card" style="border-left-color: #0D7377;">
  <span class="di-step-num" style="color: #0D7377;">Why it matters</span>
  An overpowered subagent can take unintended actions. A subagent with write access that was meant to be read-only can corrupt data. Constrained tool sets produce predictable, auditable, and safer behavior.
</div>
</v-click>

<v-click>
<div style="display: flex; gap: 0.75rem; margin-top: 0.5rem; font-size: 0.84rem;">
  <div style="flex: 1; background: white; border-radius: 5px; padding: 0.5rem 0.7rem; border: 1px solid #c8e6d0;">
    <strong style="color: #1A3A4A;">Research subagent</strong><br>
    <code class="di-code-inline">["Task", "web_search", "read_url"]</code>
  </div>
  <div style="flex: 1; background: white; border-radius: 5px; padding: 0.5rem 0.7rem; border: 1px solid #c8e6d0;">
    <strong style="color: #1A3A4A;">Report writer subagent</strong><br>
    <code class="di-code-inline">["Task", "write_file"]</code>
  </div>
  <div style="flex: 1; background: white; border-radius: 5px; padding: 0.5rem 0.7rem; border: 1px solid #c8e6d0;">
    <strong style="color: #1A3A4A;">Code reviewer subagent</strong><br>
    <code class="di-code-inline">["Task", "read_file", "run_tests"]</code>
  </div>
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
The allowedTools parameter is also a security and predictability mechanism — not just a technical requirement.

The principle of least privilege applies: each subagent should only have the tools required for its specific job. A document analysis subagent does not need web search. A web search subagent does not need file write access.

Why it matters: an overpowered subagent can take unintended actions. A subagent with write access that was meant to be read-only can corrupt data. Constrained tool sets produce predictable, auditable, and safer behavior.

The pattern across subagent types: a research subagent gets Task, web_search, and read_url. A report writer gets Task and write_file. A code reviewer gets Task, read_file, and run_tests. In each case, only what's needed for that job.
-->

---
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 6 — Coordinator Spawning Multiple Subagents
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">Coordinator Spawning Multiple Subagents in One Turn</div>

<v-click>

```python {all|4-17|18-31|all}
# Coordinator's single response contains multiple Task tool_use blocks
coordinator_response_content = [

    # First Task call — research subagent
    {
        "type": "tool_use",
        "id": "task_research_01",
        "name": "Task",
        "input": {
            "description": "Web research on topic X",
            "prompt": f"Research {topic}. Return structured findings.",
            "allowedTools": ["Task", "web_search", "read_url"]
        }
    },

    # Second Task call — document analysis subagent
    {
        "type": "tool_use",
        "id": "task_docanalysis_01",
        "name": "Task",
        "input": {
            "description": "Analyze provided documents",
            "prompt": f"Analyze: {documents}. Extract key claims.",
            "allowedTools": ["Task", "read_file", "search_documents"]
        }
    }

    # Both spawned in the SAME coordinator response turn
]
```

</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Here's what it looks like when a coordinator spawns multiple subagents in parallel — which we'll cover in depth in the next lecture.

The coordinator's response content array contains multiple Task tool_use blocks. Each one has its own id, its own description, its own prompt with explicit context, and its own allowedTools array that includes "Task" plus the tools specific to that subagent's job.

Both Task calls appear in the same coordinator response turn. That's the key: parallel spawning is multiple tool_use blocks in one response, not multiple separate API calls.

The coordinator then waits for all Task results before continuing.
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
<div class="di-exam-subtitle">The Task Tool — Two Exam Traps</div>

<div class="di-exam-body">
  The exam tests knowledge of the Task tool through scenario-based questions about why subagents fail or behave incorrectly.
</div>
</v-click>

<v-click>
<div class="di-trap-box">
  <div class="di-trap-label">❌ Trap 1 — Missing "Task" in allowedTools</div>
  A scenario describes a subagent that isn't processing its assignment correctly. The root cause: <code>allowedTools</code> doesn't include <code>"Task"</code>.
  <br><strong>Fix:</strong> Add <code>"Task"</code> to the subagent's <code>allowedTools</code> list.
</div>
</v-click>

<v-click>
<div class="di-trap-box" style="margin-top: 0.5rem;">
  <div class="di-trap-label">❌ Trap 2 — Overly Permissive allowedTools</div>
  A scenario gives every subagent access to all tools "for flexibility." This violates least privilege and creates unpredictable, hard-to-audit behavior.
  <br><strong>Fix:</strong> Each subagent gets only the tools its specific job requires.
</div>
</v-click>

<v-click>
<div class="di-correct-box" style="margin-top: 0.5rem;">
  <div class="di-correct-label">✓ The Rule</div>
  Every subagent's <code class="di-code-inline">allowedTools</code> must include <code class="di-code-inline">"Task"</code> plus only the tools needed for its specific job — nothing more.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
The exam tests knowledge of the Task tool through scenario-based questions about why subagents fail or behave incorrectly.

Trap one: a scenario describes a subagent that isn't processing its assignment correctly. The root cause is that allowedTools doesn't include "Task". The fix: add "Task" to the subagent's allowedTools list.

Trap two: a scenario gives every subagent access to all tools "for flexibility." This violates least privilege and creates unpredictable, hard-to-audit behavior. The fix: each subagent gets only the tools its specific job requires.

The rule: every subagent's allowedTools must include "Task" plus only the tools needed for its specific job — nothing more.
-->

---
layout: default
class: di-takeaway-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 8 — Key Takeaways
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-takeaway-title">The Task Tool — What to Know Cold</div>

<ul class="di-takeaway-list">
  <v-click><li>The <strong>Task tool</strong> is the mechanism coordinators use to spawn independent subagent instances</li></v-click>
  <v-click><li><code style="color: #A8D5C2;">allowedTools</code> must include <code style="color: #A8D5C2;">"Task"</code> — without it, the subagent cannot properly accept its assignment</li></v-click>
  <v-click><li>Each Task call creates a <strong>fresh, independent instance</strong> — no state persists between calls</li></v-click>
  <v-click><li>The <code style="color: #A8D5C2;">prompt</code> parameter must be self-contained — it's all the subagent knows</li></v-click>
  <v-click><li>Apply <strong>least privilege</strong> — each subagent only gets tools needed for its specific job</li></v-click>
  <v-click><li>Multiple Task calls in one coordinator response = parallel subagent spawning (covered in Lecture 3.8)</li></v-click>
</ul>

<img src="/logo.png" class="di-logo" style="opacity: 0.75;" />

<!--
To summarize what you need to know about the Task tool:

The Task tool is the mechanism coordinators use to spawn independent subagent instances.

allowedTools must include "Task" — without it, the subagent cannot properly accept its assignment. This is exam-critical.

Each Task call creates a fresh, independent instance — no state persists between calls.

The prompt parameter must be self-contained — it's all the subagent knows. Everything needed must be included.

Apply least privilege — each subagent only gets tools needed for its specific job.

And multiple Task calls in one coordinator response equals parallel subagent spawning — which we cover in the next lecture.
-->
