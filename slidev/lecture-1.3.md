---
theme: default
title: "Lecture 1.3: The 5 Domains & Their Weights"
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
  <div class="di-cover-title">The 5 Domains &<br>Their Weights</div>
  <div class="di-cover-subtitle">Lecture 1.3 · Section 1: Course Introduction & Exam Strategy</div>
</div>

<img src="/logo.png" class="di-logo-centered" />

<!--
The CCA-F exam is organized into five domains.

Each domain tests a different set of skills you need to build production systems with Claude.

Understanding the domains — and their weights — is the first step to an effective study strategy.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 2 — Domain 1 — Agentic Architecture & Orchestration (27%)
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Domain 1 — Agentic Architecture & Orchestration</div>

<div class="di-body" style="margin-top: 0.75rem;">

<v-click>
<div style="display: flex; align-items: center; gap: 1.5rem; margin-bottom: 0.75rem;">
  <div style="background: #1A3A4A; color: white; border-radius: 8px; padding: 0.75rem 1.2rem; font-size: 2rem; font-weight: 800; min-width: 90px; text-align: center;">27%</div>
  <div>
    <p style="margin: 0;"><strong>Highest weight on the exam.</strong> Covers how agentic systems work: the control loop, subagent coordination, task decomposition, session management, and escalation to humans.</p>
  </div>
</div>
</v-click>

<v-click>
<div class="di-step-card">
  <span class="di-step-num">Core concept:</span> <code>stop_reason</code> — everything flows from understanding that <code>"tool_use"</code> means the loop continues and <code>"end_turn"</code> means it stops. Get this wrong, and your agent either terminates prematurely or loops forever.
</div>
</v-click>

<v-click>
<div style="background: #E3A008; color: white; border-radius: 6px; padding: 0.6rem 1rem; margin-top: 0.5rem; font-size: 0.95rem; font-weight: 600;">
  If you have limited study time, Domain 1 is where you invest it first.
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
Domain 1 is Agentic Architecture and Orchestration, and it carries the highest weight on the exam at 27%.

This domain covers how agentic systems work: the control loop, subagent coordination, task decomposition, session management, and escalation to humans.

[click]

The core concept in Domain 1 is stop_reason. Everything flows from understanding that "tool_use" means the loop continues and "end_turn" means it stops. Get this wrong, and your agent either terminates prematurely or loops forever.

If you have limited study time, Domain 1 is where you invest it first.
-->

---
layout: two-cols
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 3 — Domains 3 and 4 — Tied at 20% Each
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Domains 3 & 4 — Tied at 20% Each</div>

::left::
<div class="di-col-left-label">Domain 3: Claude Code Config (20%)</div>
<div class="di-col-body">
<v-click at="1">
<ul>
  <li>CLAUDE.md hierarchy and scope</li>
  <li><code>.claude/</code> directory structure</li>
  <li>Skills and slash commands</li>
  <li>Custom rules and CI/CD integration</li>
  <li>Plan mode</li>
</ul>
</v-click>
</div>

::right::
<div class="di-col-right-label">Domain 4: Prompt Engineering (20%)</div>
<div class="di-col-body">
<v-click at="1">
<ul>
  <li>When to use few-shot examples</li>
  <li>Enforcing structured output via <code>tool_choice</code></li>
  <li>Message Batches API</li>
  <li>Validation-retry patterns</li>
  <li>Multi-instance review architectures</li>
</ul>
</v-click>
<v-click at="2">
<div class="di-col-warning">
  These two domains reward hands-on experience. If you've built real Claude Code workflows or prompt pipelines, a lot of this will feel familiar.
</div>
</v-click>
</div>

<img src="/logo.png" class="di-logo" />

<!--
Domains 3 and 4 are tied at 20% each, and together they account for 40% of the exam.

Domain 3 — Claude Code Configuration — covers CLAUDE.md hierarchy, the .claude/ directory structure, skills, slash commands, custom rules, CI/CD integration, and plan mode.

[click]

Domain 4 — Prompt Engineering and Structured Output — covers when to use few-shot examples, how to enforce structured output through tool_choice, the Message Batches API, validation-retry patterns, and multi-instance review architectures.

These two domains reward hands-on experience. If you've built real Claude Code workflows or prompt pipelines, a lot of this domain will feel familiar.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 4 — Domain 2 — Tool Design & MCP (18%)
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Domain 2 — Tool Design & MCP</div>

<div class="di-body" style="margin-top: 0.75rem;">

<v-click>
<div style="display: flex; align-items: center; gap: 1.5rem; margin-bottom: 0.75rem;">
  <div style="background: #0D7377; color: white; border-radius: 8px; padding: 0.75rem 1.2rem; font-size: 2rem; font-weight: 800; min-width: 90px; text-align: center;">18%</div>
  <div>
    <p style="margin: 0;">Covers how to write tool descriptions that Claude actually selects correctly, how to structure MCP error responses, how to configure MCP servers at project and user scope, and when to use MCP resources versus MCP tools.</p>
  </div>
</div>
</v-click>

<v-click>
<div class="di-step-card">
  <span class="di-step-num">Exam-critical:</span> The error response structure — every tool error needs three fields: <code>errorCategory</code>, <code>isRetryable</code>, and a human-readable description. Miss one of these on the exam and you'll pick a distractor that looks almost right.
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
Domain 2 — Tool Design and Model Context Protocol — weighs in at 18%.

This domain covers how to write tool descriptions that Claude actually selects correctly, how to structure MCP error responses, how to configure MCP servers at project and user scope, and when to use MCP resources versus MCP tools.

[click]

The most exam-critical concept in Domain 2 is the error response structure: every tool error needs three fields — errorCategory, isRetryable, and a human-readable description. Miss one of these on the exam and you'll pick a distractor that looks almost right.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 5 — Domain 5 — Context Management & Reliability (15%)
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Domain 5 — Context Management & Reliability</div>

<div class="di-body" style="margin-top: 0.75rem;">

<v-click>
<div style="display: flex; align-items: center; gap: 1.5rem; margin-bottom: 0.75rem;">
  <div style="background: #4a6080; color: white; border-radius: 8px; padding: 0.75rem 1.2rem; font-size: 2rem; font-weight: 800; min-width: 90px; text-align: center;">15%</div>
  <div>
    <p style="margin: 0;">Covers how to manage long context windows, when and how to escalate to a human agent, how to propagate errors across multi-agent systems, and how to handle conflicting information from multiple sources.</p>
  </div>
</div>
</v-click>

<v-click>
<div class="di-step-card">
  <span class="di-step-num">Note:</span> Domain 5 has a higher <strong>value-per-study-hour</strong> ratio than its weight suggests. The escalation decision framework appears in at least two of the six scenarios, and the "lost in the middle" effect is a common trap question.
</div>
</v-click>

<v-click>
<div style="background: #E3A008; color: white; border-radius: 6px; padding: 0.6rem 1rem; margin-top: 0.5rem; font-size: 0.95rem; font-weight: 600;">
  Spend at least one study session here even if time is short.
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
Domain 5 — Context Management and Reliability — is the smallest domain at 15%.

It covers how to manage long context windows, when and how to escalate to a human agent, how to propagate errors across multi-agent systems, and how to handle conflicting information from multiple sources.

[click]

Domain 5 has a higher value-per-study-hour ratio than its weight suggests. The escalation decision framework appears in at least two of the six scenarios, and the "lost in the middle" effect is a common trap question. Spend at least one study session here even if time is short.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 6 — How to Use the Weights
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">How to Use the Weights</div>

<div class="di-body" style="margin-top: 0.75rem;">

<v-click>
<div class="di-step-card">
  <span class="di-step-num">2+ weeks:</span> Work through each section sequentially in this course. Domains are ordered by weight — you automatically prioritize correctly.
</div>
</v-click>

<v-click>
<div class="di-step-card">
  <span class="di-step-num">1 week:</span> Spend half your time on Domain 1, then split the remaining time between Domains 3 and 4 (the tied 20% domains), and use any remaining time for Domains 2 and 5.
</div>
</v-click>

<v-click>
<div class="di-step-card" style="border-left-color: #E3A008;">
  <span class="di-step-num" style="color: #E3A008;">Tomorrow:</span> Go to <strong>Section 9</strong> first — the 20 things you must know cold. Then take the practice exam in Section 8. Then review your weakest domain's cheat sheet.
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
The domain weights tell you where to invest your study time.

With two or more weeks, work through each section sequentially in this course. Domains are ordered by weight — you automatically prioritize correctly.

[click]

With one week, spend half your time on Domain 1, then split the remaining time between Domains 3 and 4 (the tied 20% domains), and use any remaining time for Domains 2 and 5.

[click]

If your exam is tomorrow? Go to Section 9 first — the 20 things you must know cold. Then take the practice exam in Section 8. Then review your weakest domain's cheat sheet.
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
<div class="di-exam-subtitle">Don't Split Study Time Evenly Across All Domains</div>
<div class="di-exam-body">
  A common mistake is treating all five domains as equally important and spreading study time evenly.<br><br>
  Domain 1 at <strong>27%</strong> is nearly twice the weight of Domain 5 at <strong>15%</strong>.
</div>
</v-click>

<v-click>
<div class="di-trap-box">
  <div class="di-trap-label">❌ Wrong Approach</div>
  Spending equal time on each domain (one day per domain for a 5-day plan)
</div>
</v-click>

<v-click>
<div class="di-correct-box">
  <div class="di-correct-label">✓ Right Approach</div>
  Weight your study time <strong>proportionally</strong>. If you have five study days, spend Day 1 entirely on Domain 1. Don't split days evenly across domains.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
A common mistake is treating all five domains as equally important and spreading study time evenly.

Domain 1 at 27% is nearly twice the weight of Domain 5 at 15%.

The right approach: weight your study time proportionally. If you have five study days, spend Day 1 entirely on Domain 1. Don't split days evenly across domains.
-->

---
layout: default
class: di-takeaway-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 8 — Key Takeaways
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-takeaway-title">The Domain Weights — Commit This to Memory</div>

<ul class="di-takeaway-list">
  <v-click><li>Domain 1: Agentic Architecture — <strong>27%</strong> (highest weight, start here)</li></v-click>
  <v-click><li>Domain 3: Claude Code Config — <strong>20%</strong> (tied for second)</li></v-click>
  <v-click><li>Domain 4: Prompt Engineering — <strong>20%</strong> (tied for second)</li></v-click>
  <v-click><li>Domain 2: Tool Design & MCP — <strong>18%</strong></li></v-click>
  <v-click><li>Domain 5: Context Management — <strong>15%</strong> (lowest weight — still worth studying)</li></v-click>
  <v-click><li><strong>Total: 100%</strong> — you need 72% overall to pass</li></v-click>
</ul>

<img src="/logo.png" class="di-logo" style="opacity: 0.75;" />

<!--
Commit these five weights to memory — they tell you how to invest your time.

Domain 1: Agentic Architecture — 27%. Highest weight, start here.

Domain 3: Claude Code Config — 20%. Tied for second.

Domain 4: Prompt Engineering — 20%. Also tied for second.

Domain 2: Tool Design and MCP — 18%.

Domain 5: Context Management — 15%. Lowest weight, but still worth studying.

Total: 100%. You need 72% overall to pass.
-->
