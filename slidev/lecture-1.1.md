---
theme: default
title: "Lecture 1.1: Welcome & What You'll Learn"
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
  <div class="di-cover-title">Welcome &<br>What You'll Learn</div>
  <div class="di-cover-subtitle">Lecture 1.1 · Section 1: Course Introduction & Exam Strategy</div>
</div>

<img src="/logo.png" class="di-logo-centered" />

<!--
If you're watching this, you're preparing for one of the most interesting certification exams in AI right now.

The Claude Certified Architect Foundations exam tests something most exams don't — judgment.

Not memorization. Not syntax recall. Judgment about when to use which pattern, and why.

That's what this course is built around.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 2 — Who This Course Is For
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Who This Course Is For</div>

<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem; margin-top: 0.5rem;">
  <v-click>
  <div>
    <div class="di-col-left-label">✓ Good Fit</div>
    <div class="di-col-body">
      <ul>
        <li>Solution architects building production AI systems with Claude</li>
        <li>Senior engineers integrating Claude into real workflows</li>
        <li>Developers with basic LLM API familiarity (calling endpoints, parsing responses)</li>
      </ul>
    </div>
  </div>
  </v-click>
  <div>
    <v-click>
    <div class="di-col-right-label" style="color: #E3A008; border-color: #E3A008;">⚠ Harder Fit</div>
    <div class="di-col-body">
      <ul>
        <li>No prior API experience at all → pair with the Anthropic quickstart first</li>
      </ul>
      <div style="margin-top: 1rem; padding: 0.75rem; background: #F0FFF4; border-left: 3px solid #3CAF50; border-radius: 4px; font-size: 0.9rem;">
        <strong>Not required:</strong> ML theory, Claude training internals, or neural network knowledge — completely out of scope.
      </div>
    </div>
    </v-click>
  </div>
</div>

<img src="/logo.png" class="di-logo" />

<!--
This course is for solution architects and senior engineers building production AI systems with Claude.

You should have basic familiarity with LLM APIs — calling an endpoint, parsing a response, that kind of thing.

[click] You don't need deep Anthropic SDK experience. But if you've never made an API call at all, pair this course with the Anthropic quickstart guide first.

What you don't need: machine learning theory, Claude training internals, or neural network knowledge. Those topics are completely out of scope for this exam.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 3 — What This Course Covers
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">What This Course Covers</div>

<div class="di-body" style="margin-top: 0.5rem;">

<v-click>

This course follows the exam structure directly.

</v-click>

<v-click>

<div style="display: flex; gap: 0.5rem; flex-wrap: wrap; margin: 0.75rem 0;">
  <div style="background: #1A3A4A; color: white; border-radius: 6px; padding: 0.4rem 0.7rem; font-size: 0.85rem; font-weight: 600;">1 · Intro & Strategy</div>
  <div style="background: #1B8A5A; color: white; border-radius: 6px; padding: 0.4rem 0.7rem; font-size: 0.85rem; font-weight: 600;">2 · Agentic Architecture <span style="font-size:0.7rem; opacity:0.8;">(27%)</span></div>
  <div style="background: #0D7377; color: white; border-radius: 6px; padding: 0.4rem 0.7rem; font-size: 0.85rem; font-weight: 600;">3 · Tool Design & MCP</div>
  <div style="background: #3CAF50; color: white; border-radius: 6px; padding: 0.4rem 0.7rem; font-size: 0.85rem; font-weight: 600;">4 · Claude Code Config</div>
  <div style="background: #2a7a8a; color: white; border-radius: 6px; padding: 0.4rem 0.7rem; font-size: 0.85rem; font-weight: 600;">5 · Safety & Trust</div>
  <div style="background: #4a6080; color: white; border-radius: 6px; padding: 0.4rem 0.7rem; font-size: 0.85rem; font-weight: 600;">6 · Responsible Use</div>
</div>

Sections 2–6 go deep on each of the five domains, in exam-weight order. The most heavily weighted domain comes first.

</v-click>

</div>

<v-click>
<div style="background: white; border: 1px solid #c8e6d0; border-radius: 8px; padding: 0.75rem 1rem; margin-top: 0.5rem; font-size: 0.92rem;">
  <div style="display: flex; gap: 0.5rem; flex-wrap: wrap;">
    <div style="background: #E8F5EB; border-radius: 5px; padding: 0.3rem 0.6rem; font-size: 0.83rem;"><strong>Section 7</strong> · All 6 exam scenarios</div>
    <div style="background: #E8F5EB; border-radius: 5px; padding: 0.3rem 0.6rem; font-size: 0.83rem;"><strong>Section 8</strong> · Every official sample question</div>
    <div style="background: #E3A008; color: white; border-radius: 5px; padding: 0.3rem 0.6rem; font-size: 0.83rem; font-weight: 700;"><strong>Section 9</strong> · Last-night cram: 20 things cold</div>
  </div>
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
This course follows the exam structure directly.

Section 1 — where you are now — covers exam strategy and orientation.

Sections 2 through 6 go deep on each of the five domains, in exam-weight order. The most heavily weighted domain comes first.

[click] Section 7 dissects all six exam scenarios. Section 8 walks through every official sample question. And Section 9 is your last-night cram guide — the 20 things you must know cold.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 4 — What You'll Be Able to Do
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">By the End of This Course</div>

<div class="di-body" style="margin-top: 0.75rem;">
  <v-click>
  <div class="di-step-card">
    <span class="di-step-num">Understand</span>
    exactly how Claude's agentic loop works — and precisely what breaks it
  </div>
  </v-click>
  <v-click>
  <div class="di-step-card">
    <span class="di-step-num">Design</span>
    tool interfaces that Claude reliably selects, and write error responses that guide the agent to recover correctly
  </div>
  </v-click>
  <v-click>
  <div class="di-step-card">
    <span class="di-step-num">Configure</span>
    Claude Code for a multi-developer team environment, not just personal use
  </div>
  </v-click>
  <v-click>
  <div class="di-step-card">
    <span class="di-step-num">Analyze</span>
    all 12 official sample questions from Anthropic's exam guide — including every distractor and why it fails
  </div>
  </v-click>
</div>

<img src="/logo.png" class="di-logo" />

<!--
By the end of this course, you'll understand exactly how Claude's agentic loop works — and precisely what breaks it.

You'll be able to design tool interfaces that Claude reliably selects, and write error responses that guide the agent to recover correctly.

You'll know how to configure Claude Code for a multi-developer team environment, not just for personal use.

And you'll have analyzed all 12 official sample questions from Anthropic's exam guide — including every distractor and why it fails.
-->

---
layout: default
class: di-exam-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 5 — Exam Tip
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-exam-banner">⚡ EXAM TIP</div>

<v-click>
<div class="di-exam-subtitle">The Most Important Thing Before You Start Studying</div>

<div class="di-exam-body">
  The exam doesn't test trivia. It tests <strong>judgment</strong>.
  <br><br>
  Every question gives you a scenario and asks you to choose the <em>best</em> architectural decision. The wrong answers aren't obviously wrong — they're decisions that would be correct in a different context.
</div>
</v-click>

<v-click>
<div class="di-trap-box">
  <div class="di-trap-label">❌ Wrong Approach</div>
  Memorizing API parameter names, syntax, or specific values
</div>
</v-click>

<v-click>
<div class="di-correct-box">
  <div class="di-correct-label">✓ Right Approach</div>
  Understand the <strong>principles</strong> well enough to apply them to scenarios you've never seen before
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Here's the most important thing to understand about this exam before you start studying.

The exam doesn't test trivia. It tests judgment.

Every question gives you a scenario and asks you to choose the best architectural decision. The wrong answers aren't obviously wrong — they're decisions that would be correct in a different context.

So your study goal is not to memorize API parameters. It's to understand the principles well enough to apply them to scenarios you've never seen before.
-->

---
layout: default
class: di-takeaway-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 6 — Key Takeaways
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-takeaway-title">What to Remember</div>

<ul class="di-takeaway-list">
  <v-click><li>This exam tests judgment about <em>when</em> to use each pattern — not syntax recall</li></v-click>
  <v-click><li>Domain 1 (Agentic Architecture) at 27% is your biggest lever — start there</li></v-click>
  <v-click><li>Wrong answers are carefully designed distractors — understanding why they fail is as important as knowing the right answer</li></v-click>
</ul>

<img src="/logo.png" class="di-logo" style="opacity: 0.75;" />

<!--
Three things to hold onto:

This exam tests judgment about when to use each pattern — not syntax recall.

Domain 1 — Agentic Architecture — at 27% of the exam, is your biggest lever. Start there.

And wrong answers are carefully designed distractors. Understanding why they fail is as important as knowing the right answer.

Let's get into it.
-->
