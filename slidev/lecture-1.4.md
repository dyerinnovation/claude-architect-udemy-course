---
theme: default
title: "Lecture 1.4: How to Use the 6 Scenarios"
info: |
  Claude Certified Architect – Foundations
  Section 1: Course Introduction & Exam Strategy
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
  <div class="di-cover-title">How to Use<br>the 6 Scenarios</div>
  <div class="di-cover-subtitle">Lecture 1.4 · Section 1: Course Introduction & Exam Strategy</div>
</div>

<img src="/logo.png" class="di-logo-centered" />

<!--
Here's what makes the CCA-F exam structurally different from most certification exams.

The exam isn't just a list of questions. It's organized around six real-world use cases called scenarios.

Every question on the exam is framed around one of these six scenarios.

And here's the catch: four of the six scenarios will appear on your exam. You don't know which four. Anthropic picks them.

So you must know all six — well.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 2 — The 6 Scenarios at a Glance
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">The 6 Scenarios at a Glance</div>

<div class="di-body" style="margin-top: 0.75rem; font-size: 0.93rem;">

<v-click>
<div class="di-step-card"><span class="di-step-num">Scenario 1:</span> <strong>Customer Support Resolution Agent</strong> — multi-turn agent handling customer inquiries, routing to tools, escalating to humans. Primary: <em>Domain 1 &amp; 5</em></div>
</v-click>

<v-click>
<div class="di-step-card"><span class="di-step-num">Scenario 2:</span> <strong>Code Generation with Claude Code</strong> — using Claude Code in a developer workflow. Primary: <em>Domain 3</em></div>
</v-click>

<v-click>
<div class="di-step-card"><span class="di-step-num">Scenario 3:</span> <strong>Multi-Agent Research System</strong> — coordinator spawning specialized subagents. Primary: <em>Domain 1, touching 5</em></div>
</v-click>

<v-click>
<div class="di-step-card"><span class="di-step-num">Scenario 4:</span> <strong>Developer Productivity with Claude</strong> — designing tools for software engineers. Primary: <em>Domain 2</em></div>
</v-click>

<v-click>
<div class="di-step-card"><span class="di-step-num">Scenario 5:</span> <strong>Claude Code for CI/CD</strong> — running Claude non-interactively in pipelines. Primary: <em>Domain 3 &amp; 4</em></div>
</v-click>

<v-click>
<div class="di-step-card"><span class="di-step-num">Scenario 6:</span> <strong>Structured Data Extraction</strong> — using JSON schemas and batch APIs. Primary: <em>Domain 4</em></div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
Let me walk through all six scenarios so you know what you're preparing for.

Scenario 1: Customer Support Resolution Agent — a multi-turn agent that handles customer inquiries, routes to tools, and escalates to humans. Primary domains: 1 (Agentic Architecture) and 5 (Context and Escalation).

Scenario 2: Code Generation with Claude Code — using Claude Code in a developer workflow. Primary domain: 3 (Claude Code Configuration).

[click]

Scenario 3: Multi-Agent Research System — a coordinator spawning specialized subagents. Primary domain: 1 (Agentic Architecture), touching 5 (Context Reliability).

Scenario 4: Developer Productivity with Claude — designing tools for software engineers. Primary domain: 2 (Tool Design and MCP).

Scenario 5: Claude Code for CI/CD — running Claude non-interactively in pipelines. Primary domain: 3 (Claude Code Config) and 4 (Prompt Engineering).

Scenario 6: Structured Data Extraction — using JSON schemas and batch APIs. Primary domain: 4 (Prompt Engineering).
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 3 — Why Scenarios Matter for Study Strategy
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Why Scenarios Matter for Study Strategy</div>

<div class="di-body" style="margin-top: 0.75rem;">

<v-click>
<p>Knowing domain theory isn't enough to pass this exam. You need to know how to <em>apply</em> domain concepts to specific scenarios.</p>
<p>For example: the <code>stop_reason</code> control flow from Domain 1 applies differently in a Customer Support agent (where escalation to human is a real exit) than in a Research Pipeline (where the coordinator needs to aggregate before stopping).</p>
</v-click>

<v-click>
<div class="di-step-card">
  <span class="di-step-num">Scenario-aware:</span> Can answer "In the Customer Support scenario, when should the agent escalate?" — applying the rule in context.
</div>
</v-click>

<v-click>
<div class="di-step-card" style="border-left-color: #E3A008;">
  <span class="di-step-num" style="color: #E3A008;">Domain-only:</span> Knows escalation rules in the abstract, but hesitates when the question is framed around a specific scenario.
</div>
</v-click>

<v-click>
<p style="font-size: 0.9rem; color: #1A3A4A; margin-top: 0.5rem;"><strong>That's the gap this course closes.</strong> Every domain section explicitly ties back to which scenarios use that concept.</p>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
Knowing domain theory isn't enough to pass this exam.

You need to know how to apply domain concepts to specific scenarios.

For example: the stop_reason control flow from Domain 1 applies differently in a Customer Support agent (where escalation to human is a real exit) than in a Research Pipeline (where the coordinator needs to aggregate before stopping).

[click]

The scenario-aware candidate can answer questions that ask "In the Customer Support scenario, when should the agent escalate?" The domain-only candidate might know escalation rules in the abstract, but hesitate when the question is framed around a specific context.

That's the gap this course closes. Every domain section explicitly ties back to which scenarios use that concept.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 4 — Scenarios and Domain Coverage — The Matrix
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Scenarios & Domain Coverage</div>

<div style="margin-top: 0.75rem; font-size: 0.85rem;">

<v-click>
<div style="display: grid; grid-template-columns: 2fr repeat(5, 1fr); gap: 2px; background: #c8e6d0; border-radius: 6px; overflow: hidden;">
  <div style="background: #1A3A4A; color: white; padding: 0.4rem 0.6rem; font-weight: 700;">Scenario</div>
  <div style="background: #1A3A4A; color: white; padding: 0.4rem 0.3rem; font-weight: 700; text-align: center;">D1</div>
  <div style="background: #1A3A4A; color: white; padding: 0.4rem 0.3rem; font-weight: 700; text-align: center;">D2</div>
  <div style="background: #1A3A4A; color: white; padding: 0.4rem 0.3rem; font-weight: 700; text-align: center;">D3</div>
  <div style="background: #1A3A4A; color: white; padding: 0.4rem 0.3rem; font-weight: 700; text-align: center;">D4</div>
  <div style="background: #1A3A4A; color: white; padding: 0.4rem 0.3rem; font-weight: 700; text-align: center;">D5</div>
  <div style="background: white; padding: 0.35rem 0.6rem;">1 · Customer Support</div>
  <div style="background: #1A3A4A; color: white; padding: 0.35rem; text-align: center; font-weight: 700;">●●</div>
  <div style="background: #E8F5EB; padding: 0.35rem; text-align: center;"></div>
  <div style="background: #E8F5EB; padding: 0.35rem; text-align: center;"></div>
  <div style="background: #E8F5EB; padding: 0.35rem; text-align: center;"></div>
  <div style="background: #1B8A5A; color: white; padding: 0.35rem; text-align: center;">●</div>
  <div style="background: #f9f9f9; padding: 0.35rem 0.6rem;">2 · Code Generation</div>
  <div style="background: #E8F5EB; padding: 0.35rem; text-align: center;"></div>
  <div style="background: #E8F5EB; padding: 0.35rem; text-align: center;"></div>
  <div style="background: #1A3A4A; color: white; padding: 0.35rem; text-align: center; font-weight: 700;">●●</div>
  <div style="background: #E8F5EB; padding: 0.35rem; text-align: center;"></div>
  <div style="background: #E8F5EB; padding: 0.35rem; text-align: center;"></div>
  <div style="background: white; padding: 0.35rem 0.6rem;">3 · Research System</div>
  <div style="background: #1A3A4A; color: white; padding: 0.35rem; text-align: center; font-weight: 700;">●●</div>
  <div style="background: #E8F5EB; padding: 0.35rem; text-align: center;"></div>
  <div style="background: #E8F5EB; padding: 0.35rem; text-align: center;"></div>
  <div style="background: #E8F5EB; padding: 0.35rem; text-align: center;"></div>
  <div style="background: #1B8A5A; color: white; padding: 0.35rem; text-align: center;">●</div>
  <div style="background: #f9f9f9; padding: 0.35rem 0.6rem;">4 · Dev Productivity</div>
  <div style="background: #E8F5EB; padding: 0.35rem; text-align: center;"></div>
  <div style="background: #1A3A4A; color: white; padding: 0.35rem; text-align: center; font-weight: 700;">●●</div>
  <div style="background: #E8F5EB; padding: 0.35rem; text-align: center;"></div>
  <div style="background: #E8F5EB; padding: 0.35rem; text-align: center;"></div>
  <div style="background: #E8F5EB; padding: 0.35rem; text-align: center;"></div>
  <div style="background: white; padding: 0.35rem 0.6rem;">5 · CI/CD</div>
  <div style="background: #E8F5EB; padding: 0.35rem; text-align: center;"></div>
  <div style="background: #E8F5EB; padding: 0.35rem; text-align: center;"></div>
  <div style="background: #1A3A4A; color: white; padding: 0.35rem; text-align: center; font-weight: 700;">●●</div>
  <div style="background: #1B8A5A; color: white; padding: 0.35rem; text-align: center;">●</div>
  <div style="background: #E8F5EB; padding: 0.35rem; text-align: center;"></div>
  <div style="background: #f9f9f9; padding: 0.35rem 0.6rem;">6 · Data Extraction</div>
  <div style="background: #E8F5EB; padding: 0.35rem; text-align: center;"></div>
  <div style="background: #E8F5EB; padding: 0.35rem; text-align: center;"></div>
  <div style="background: #E8F5EB; padding: 0.35rem; text-align: center;"></div>
  <div style="background: #1A3A4A; color: white; padding: 0.35rem; text-align: center; font-weight: 700;">●●</div>
  <div style="background: #E8F5EB; padding: 0.35rem; text-align: center;"></div>
</div>
</v-click>

<v-click>
<p style="margin-top: 0.6rem; font-size: 0.88rem; color: #1A3A4A;">If Domains 1, 3, and 4 are your strengths, you're well-positioned regardless of which four scenarios appear.</p>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
Each scenario primarily tests 2-3 domains. Here's how they map.

Scenario 1 (Customer Support) hits Domains 1 and 5 hardest — agentic loop control and escalation decision-making.

Scenario 3 (Research System) is almost pure Domain 1 — multi-agent coordination, subagent spawning, parallel execution.

[click]

Scenarios 2 and 5 both feature Claude Code, but they test different things: Scenario 2 tests development workflow (Domain 3), while Scenario 5 tests CI/CD integration (Domain 3 + 4).

Scenarios 4 and 6 pull in Domain 2 and 4 respectively — tool design and prompt engineering with structured output.

The takeaway: if Domains 1, 3, and 4 are your strengths, you're well-positioned regardless of which four scenarios appear.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 5 — How to Use Scenarios in Your Study
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">How to Use Scenarios in Your Study</div>

<div class="di-body" style="margin-top: 0.75rem;">

<v-click>
<div class="di-step-card">
  <span class="di-step-num">Step 1.</span> <strong>Learn the scenario context.</strong> What system are we building? Who's the end user? What constraints apply? The scenario details matter for answer evaluation.
</div>
</v-click>

<v-click>
<div class="di-step-card">
  <span class="di-step-num">Step 2.</span> <strong>Map each domain concept to the scenario.</strong> When you learn about programmatic vs. prompt enforcement in Domain 1, connect it to Scenario 1 (workflow order) and Scenario 3 (subagent coordination).
</div>
</v-click>

<v-click>
<div class="di-step-card">
  <span class="di-step-num">Step 3.</span> <strong>Practice the judgment call.</strong> For any decision pattern, be able to articulate: "In this scenario, I would use X instead of Y because…"
</div>
</v-click>

<v-click>
<p style="font-size: 0.9rem; color: #1A3A4A; margin-top: 0.5rem;"><strong>Section 7</strong> of this course is entirely dedicated to this third step.</p>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
Here's how to actually use the scenarios during preparation.

First: learn each scenario's context. What system are we building? Who's the end user? What constraints apply? The scenario details matter for answer evaluation.

[click]

Second: for each concept you learn in a domain section, ask yourself which scenarios it applies to. When you learn about programmatic vs. prompt enforcement in Domain 1, connect it to Scenario 1 (where workflow order matters) and Scenario 3 (where subagent coordination matters).

[click]

Third: practice the judgment call. For any decision pattern, be able to articulate: "In this scenario, I would use X instead of Y because..."

Section 7 of this course is entirely dedicated to this third step.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 6 — Which Scenarios to Study Hardest
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Which Scenarios to Study Hardest</div>

<div class="di-body" style="margin-top: 0.75rem;">

<v-click>
<div class="di-step-card" style="border-left-color: #1A3A4A;">
  <span class="di-step-num" style="color: #1A3A4A;">Tier 1 — Study most deeply:</span> Scenarios <strong>1</strong> (Customer Support) and <strong>3</strong> (Research System). Both test Domain 1 extensively — your biggest exam lever. Together these two could represent half your exam.
</div>
</v-click>

<v-click>
<div class="di-step-card" style="border-left-color: #0D7377;">
  <span class="di-step-num" style="color: #0D7377;">Tier 2 — Study thoroughly:</span> Scenarios <strong>5</strong> (CI/CD) and <strong>6</strong> (Structured Data Extraction). These pull from Domains 3 and 4, the two 20%-weight domains.
</div>
</v-click>

<v-click>
<div class="di-step-card" style="border-left-color: #3CAF50;">
  <span class="di-step-num" style="color: #3CAF50;">Tier 3 — Study confidently:</span> Scenarios <strong>2</strong> (Code Generation) and <strong>4</strong> (Developer Productivity). More domain-specific — easier to prep quickly with real-world Claude Code or tool design experience.
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
If you must prioritize, here's a practical ranking.

Tier 1 — Study most deeply: Scenarios 1 (Customer Support) and 3 (Research System). Both test Domain 1 extensively, which is your biggest exam lever. Together these two scenarios could represent half your exam.

[click]

Tier 2 — Study thoroughly: Scenarios 5 (CI/CD) and 6 (Structured Data Extraction). These pull from Domains 3 and 4, the two 20%-weight domains.

Tier 3 — Study confidently: Scenarios 2 (Code Generation) and 4 (Developer Productivity). These are more domain-specific (Domain 3 and 2) and may be easier to prep quickly if you have real-world Claude Code or tool design experience.
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
<div class="di-exam-subtitle">Know All 6 Scenarios — You Can't Skip 2</div>
<div class="di-exam-body">
  The most dangerous assumption is "I'll skip Scenario X because I'm weak in that domain."<br><br>
  You don't get to choose. The exam chooses.
</div>
</v-click>

<v-click>
<div class="di-trap-box">
  <div class="di-trap-label">❌ Wrong Approach</div>
  Skipping preparation for Scenarios 5 and 6 because they seem domain-specific — and then having both appear on your exam
</div>
</v-click>

<v-click>
<div class="di-correct-box">
  <div class="di-correct-label">✓ Right Approach</div>
  Prepare for all six at least to this level: know its <strong>primary system</strong>, its <strong>main domain</strong>, and the <strong>two or three key architectural decisions</strong> it tests
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
The most dangerous assumption is "I'll skip Scenario X because I'm weak in that domain."

You don't get to choose. The exam chooses.

A candidate who skips preparing for Scenarios 5 and 6 might walk into an exam where both appear. Prepare for all six at least to a level where you can handle questions about them.

The minimum for each scenario: know its primary system, its main domain, and the two or three key architectural decisions it tests.
-->

---
layout: default
class: di-takeaway-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 8 — Key Takeaways
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-takeaway-title">What to Remember About the Scenarios</div>

<ul class="di-takeaway-list">
  <v-click><li>Six scenarios are defined; exactly <strong>four</strong> will appear on your exam</li></v-click>
  <v-click><li>You don't choose — <em>prepare for all six</em></li></v-click>
  <v-click><li>Every question is framed around a specific scenario context</li></v-click>
  <v-click><li>Scenarios 1 and 3 test Domain 1 (27%) — study these deepest</li></v-click>
  <v-click><li><strong>Section 7</strong> of this course does a full scenario-by-scenario deep dive</li></v-click>
</ul>

<img src="/logo.png" class="di-logo" style="opacity: 0.75;" />

<!--
Five things to hold onto.

Six scenarios are defined; exactly four will appear on your exam.

You don't choose — prepare for all six.

Every question is framed around a specific scenario context — domain knowledge alone isn't enough.

Scenarios 1 and 3 test Domain 1 at 27% — study these deepest.

And Section 7 of this course does a full scenario-by-scenario deep dive.
-->
