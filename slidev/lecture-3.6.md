---
theme: default
title: "Lecture 3.6: Subagent Context Isolation"
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
  <div class="di-cover-title">Subagent Context Isolation</div>
  <div class="di-cover-subtitle">Lecture 3.6 · Domain 1 — Agentic Architecture & Orchestration (27%)</div>
</div>

<img src="/logo.png" class="di-logo-centered" />

<!--
Here's a question that trips up candidates who understand the theory of multi-agent systems but haven't worked through the implications.

You have a coordinator that has been working through a complex research task. It has a rich conversation history — user requests, web search results, document summaries, analysis notes. It now needs to spawn a synthesis subagent to write the final report.

What does the subagent see when it starts?

Nothing. It starts with a completely blank context.

That's subagent context isolation. It's one of the most important — and most misunderstood — properties of multi-agent systems in Claude's architecture.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 2 — What Context Isolation Means
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">What Context Isolation Actually Means</div>

<div class="di-body" style="margin-top: 0.75rem;">

<v-click>
<p>Each subagent spawned via the Task tool is an <strong>independent Claude instance</strong>. It has its own context window, starting from scratch.</p>
</v-click>

<v-click>
<div style="display: flex; gap: 1rem; margin-top: 0.5rem;">
  <div style="flex: 1; background: #FFF0F0; border: 1px solid #ffc8c8; border-top: 3px solid #E53E3E; border-radius: 6px; padding: 0.6rem 0.8rem; font-size: 0.86rem;">
    <div style="font-weight: 700; color: #E53E3E; margin-bottom: 0.3rem;">What the subagent does NOT have</div>
    <ul style="margin: 0; padding-left: 1.1rem;">
      <li>Coordinator's conversation history</li>
      <li>Results from other subagents</li>
      <li>The original user request (unless passed)</li>
      <li>Any context from previous turns</li>
    </ul>
  </div>
  <div style="flex: 1; background: #F0FFF4; border: 1px solid #c8e6d0; border-top: 3px solid #3CAF50; border-radius: 6px; padding: 0.6rem 0.8rem; font-size: 0.86rem;">
    <div style="font-weight: 700; color: #1B8A5A; margin-bottom: 0.3rem;">What the subagent DOES have</div>
    <ul style="margin: 0; padding-left: 1.1rem;">
      <li>Its own system prompt (if provided)</li>
      <li>The task prompt the coordinator constructed</li>
      <li>The tools in its <code class="di-code-inline">allowedTools</code> list</li>
      <li>Only what the coordinator explicitly passed</li>
    </ul>
  </div>
</div>
</v-click>

<v-click>
<div style="background: #FFF8E6; border-left: 3px solid #E3A008; padding: 0.5rem 0.8rem; border-radius: 4px; font-size: 0.88rem; margin-top: 0.6rem;">
  <strong>The design principle behind isolation:</strong> predictability and security. A subagent that can't accidentally see unrelated data can't accidentally act on it.
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
Each subagent spawned via the Task tool is an independent Claude instance. It has its own context window, starting from scratch.

What the subagent does not have: the coordinator's conversation history, results from other subagents, the original user request unless explicitly passed, and any context from previous turns.

What the subagent does have: its own system prompt if one is provided, the task prompt the coordinator constructed for it, the tools in its allowedTools list, and only what the coordinator explicitly passed.

The design principle behind isolation: predictability and security. A subagent that can't accidentally see unrelated data can't accidentally act on it.
-->

---
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 3 — Context Isolation in Code
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">Context Isolation in Code — What the Subagent Receives</div>

<v-click>

```python {all|3-12|14-20|all}
# Coordinator has rich context after several turns:
# - Original user request
# - Web search results
# - Document analysis summaries
# When it spawns a synthesis subagent, that subagent sees NONE of this.

# The coordinator must construct the full context explicitly:
synthesis_task_prompt = f"""
You are a synthesis agent. Your task is to write a comprehensive report.

Background (collected by the research pipeline):
{coordinator_collected_facts}   # ← explicitly injected

Key findings from document analysis:
{document_analysis_results}     # ← explicitly injected

Output format: structured report with executive summary,
findings, and recommendations.
"""

# The subagent receives ONLY this prompt — nothing else from the coordinator
```

</v-click>

<v-click>
<div style="background: white; border-radius: 4px; padding: 0.4rem 0.7rem; font-size: 0.84rem; border-left: 3px solid #E3A008; margin-top: 0.4rem;">
  <strong style="color: #E3A008;">Every fact the subagent needs</strong> must be serialized into the task prompt by the coordinator.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Let's look at what this means in code.

The coordinator has rich context after several turns. It has the original user request, web search results, and document analysis summaries. When it spawns a synthesis subagent, that subagent sees none of this.

The coordinator must construct the full context explicitly. It builds a task prompt that includes the background, the collected facts, the key findings — everything injected directly into the string.

The subagent receives only this prompt. Nothing else from the coordinator's context window is accessible.

Every fact the subagent needs must be serialized into the task prompt by the coordinator.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 4 — The Explicit Context Passing Requirement
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">The Explicit Context Passing Requirement</div>

<div class="di-body" style="margin-top: 0.5rem;">

<v-click>
<p><strong>Explicit context passing</strong> is not optional. It is the mechanism that makes multi-agent systems work.</p>
</v-click>

<v-click>
<div class="di-step-card">
  <span class="di-step-num">What to pass</span>
  The original user objective, any background facts or data collected so far, output format requirements, constraints and boundaries, and any results from prior subagents that this subagent needs.
</div>
</v-click>

<v-click>
<div class="di-step-card" style="border-left-color: #E53E3E;">
  <span class="di-step-num" style="color: #E53E3E;">What fails without it</span>
  The subagent will produce output that doesn't fit the broader task because it lacks context. Or it will use tools to re-collect information that the coordinator already has, wasting resources and time.
</div>
</v-click>

<v-click>
<div class="di-step-card" style="border-left-color: #0D7377;">
  <span class="di-step-num" style="color: #0D7377;">What to NOT pass</span>
  Don't dump the entire coordinator history into every subagent prompt. Pass only what's relevant to that subagent's specific task. Irrelevant context increases cost and can confuse the subagent.
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
Explicit context passing is not optional. It is the mechanism that makes multi-agent systems work.

What to pass: the original user objective, any background facts or data collected so far, output format requirements, constraints and boundaries, and any results from prior subagents that this subagent needs to do its job.

What fails without it: the subagent will produce output that doesn't fit the broader task because it lacks context. Or it will use tools to re-collect information that the coordinator already has, wasting resources and time.

What to not pass: don't dump the entire coordinator history into every subagent prompt. Pass only what's relevant to that subagent's specific task. Irrelevant context increases cost and can confuse the subagent.
-->

---
layout: two-cols
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 5 — Isolation Benefits vs Challenges
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header" style="margin: -1.5rem -1rem 1rem -2rem; padding-right: 1rem;">Isolation — Benefits and Challenges</div>

<v-click>
<div style="padding-right: 1.2rem;">
  <div class="di-col-left-label">Benefits of Context Isolation</div>
  <div class="di-col-body">
    <ul>
      <li><strong>Predictability</strong> — each subagent's behavior depends only on what you gave it</li>
      <li><strong>Security</strong> — sensitive data from one part of the workflow doesn't leak to other subagents</li>
      <li><strong>Parallelism</strong> — isolated subagents can safely run concurrently without shared state conflicts</li>
      <li><strong>Testability</strong> — you can test each subagent in isolation with known inputs</li>
    </ul>
  </div>
</div>
</v-click>

::right::

<v-click>
<div style="padding-left: 1.2rem; padding-top: 5rem;">
  <div class="di-col-right-label">Challenges to Design Around</div>
  <div class="di-col-body">
    <ul>
      <li><strong>Context engineering burden</strong> — the coordinator must construct complete, accurate task prompts</li>
      <li><strong>Serialization overhead</strong> — large data structures must be formatted for inclusion in prompts</li>
      <li><strong>No shared state</strong> — subagents can't update a shared object; all results flow through the coordinator</li>
    </ul>
    <div class="di-col-warning" style="margin-top: 0.5rem;">
      <strong>Design implication:</strong> context isolation shifts the complexity to the coordinator's prompt construction logic.
    </div>
  </div>
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Context isolation has clear benefits and some design challenges.

Benefits: predictability — each subagent's behavior depends only on what you gave it. Security — sensitive data from one part of the workflow doesn't leak to other subagents. Parallelism — isolated subagents can safely run concurrently without shared state conflicts. And testability — you can test each subagent in isolation with known inputs.

Challenges: the coordinator must construct complete, accurate task prompts — that's real engineering work. Large data structures must be serialized for inclusion in prompts. And subagents can't update shared state — all results flow through the coordinator.

The design implication: context isolation shifts complexity to the coordinator's prompt construction logic. That's where most multi-agent bugs occur in practice.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 6 — Each Task Call Creates an Independent Instance
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Each Task Call Creates an Independent Instance</div>

<div class="di-body" style="margin-top: 0.5rem;">

<v-click>
<p>Every call to the Task tool spawns a <strong>new, independent agent instance</strong>. There is no session persistence between calls.</p>
</v-click>

<v-click>
<div class="di-step-card">
  <span class="di-step-num">Implication 1</span>
  If you call the Task tool twice with the same subagent description, you get two completely independent instances. The second one has no memory of the first.
</div>
</v-click>

<v-click>
<div class="di-step-card" style="border-left-color: #0D7377;">
  <span class="di-step-num" style="color: #0D7377;">Implication 2</span>
  Retry logic must reconstruct the full task context. You cannot resume a failed subagent — you spawn a fresh one with the same (or corrected) task prompt.
</div>
</v-click>

<v-click>
<div class="di-step-card" style="border-left-color: #E3A008;">
  <span class="di-step-num" style="color: #E3A008;">Implication 3</span>
  The coordinator is the only persistent entity in the system. It accumulates results across subagent calls and maintains the workflow state.
</div>
</v-click>

<v-click>
<div style="background: #FFF8E6; border-left: 3px solid #E3A008; padding: 0.45rem 0.8rem; border-radius: 4px; font-size: 0.86rem; margin-top: 0.3rem;">
  <strong>Mental model:</strong> Subagents are functions. You call them with arguments. They return results. They don't remember between calls.
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
Every call to the Task tool spawns a new, independent agent instance. There is no session persistence between calls.

Implication one: if you call the Task tool twice with the same subagent description, you get two completely independent instances. The second one has no memory of the first.

Implication two: retry logic must reconstruct the full task context. You cannot resume a failed subagent — you spawn a fresh one with the same or corrected task prompt.

Implication three: the coordinator is the only persistent entity in the system. It accumulates results across subagent calls and maintains the workflow state.

The mental model that makes this intuitive: subagents are like functions. You call them with arguments. They return results. They don't remember between calls.
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
<div class="di-exam-subtitle">Context Isolation — The Exam Traps</div>

<div class="di-exam-body">
  The exam will present scenarios involving multi-agent coordination. Context isolation is tested through specific assumptions candidates make.
</div>
</v-click>

<v-click>
<div class="di-trap-box">
  <div class="di-trap-label">❌ Trap 1 — Assuming Inherited Context</div>
  An answer assumes the subagent "already knows" the user's original request because the coordinator received it.
  <strong>Wrong</strong> — the coordinator must explicitly include the user objective in the subagent's task prompt.
</div>
</v-click>

<v-click>
<div class="di-trap-box" style="margin-top: 0.5rem;">
  <div class="di-trap-label">❌ Trap 2 — Assuming Subagent Memory Across Calls</div>
  An answer describes a subagent being "updated" or "continuing" from a prior call.
  <strong>Wrong</strong> — each Task call creates a fresh instance. Continuity is the coordinator's responsibility.
</div>
</v-click>

<v-click>
<div class="di-correct-box" style="margin-top: 0.5rem;">
  <div class="di-correct-label">✓ The Rule</div>
  Subagents start with a blank slate. The coordinator is the sole source of context for each subagent invocation.
  <strong>Everything must be passed explicitly.</strong>
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
The exam will present scenarios involving multi-agent coordination. Context isolation is tested through specific assumptions candidates make.

Trap one: an answer assumes the subagent "already knows" the user's original request because the coordinator received it. Wrong — the coordinator must explicitly include the user objective in the subagent's task prompt.

Trap two: an answer describes a subagent being "updated" or "continuing" from a prior call. Wrong — each Task call creates a fresh instance. Continuity is the coordinator's responsibility.

The rule: subagents start with a blank slate. The coordinator is the sole source of context for each subagent invocation. Everything must be passed explicitly.
-->

---
layout: default
class: di-takeaway-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 8 — Key Takeaways
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-takeaway-title">Subagent Context Isolation</div>

<ul class="di-takeaway-list">
  <v-click><li>Subagents do <strong>not</strong> inherit the coordinator's conversation history — each starts with a blank context</li></v-click>
  <v-click><li>Each Task call creates an <strong>independent agent instance</strong> — no session persistence between calls</li></v-click>
  <v-click><li><strong>Explicit context passing</strong> is mandatory — the coordinator must include everything the subagent needs in its task prompt</li></v-click>
  <v-click><li>Pass <em>relevant</em> context only — dumping the full coordinator history is inefficient and counterproductive</li></v-click>
  <v-click><li>The coordinator is the <strong>only persistent entity</strong> — it accumulates results and maintains workflow state</li></v-click>
  <v-click><li>Isolation enables parallelism, predictability, and security — but shifts complexity to the coordinator's prompt construction</li></v-click>
</ul>

<img src="/logo.png" class="di-logo" style="opacity: 0.75;" />

<!--
To summarize subagent context isolation:

Subagents do not inherit the coordinator's conversation history. Each starts with a blank context.

Each Task call creates an independent agent instance — no session persistence between calls.

Explicit context passing is mandatory — the coordinator must include everything the subagent needs in its task prompt.

Pass relevant context only — dumping the full coordinator history is inefficient and counterproductive.

The coordinator is the only persistent entity — it accumulates results and maintains workflow state.

And isolation enables parallelism, predictability, and security — but shifts complexity to the coordinator's prompt construction logic.
-->
