---
theme: default
title: "Lecture 1.2: Exam Format Deep Dive"
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
  <div class="di-cover-title">Exam Format<br>Deep Dive</div>
  <div class="di-cover-subtitle">Lecture 1.2 · Section 1: Course Introduction & Exam Strategy</div>
</div>

<img src="/logo.png" class="di-logo-centered" />

<!--
Let's talk about the mechanics of this exam so you know exactly what you're walking into.

The Claude Certified Architect Foundations exam uses scaled scoring from 100 to 1000.

To pass, you need 720.

That's roughly 72% — a rigorous threshold, but one you can hit reliably with the right preparation.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 2 — Scaled Scoring — What That Means
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Scaled Scoring — What That Means</div>

<div class="di-body" style="margin-top: 0.75rem;">

<v-click>
<div style="display: flex; gap: 0; margin: 0.5rem 0 1rem 0; border-radius: 8px; overflow: hidden; font-size: 0.85rem; font-weight: 700;">
  <div style="background: #E53E3E; color: white; padding: 0.5rem 1rem; flex: 3; text-align: center;">100 – 719<br><span style="font-weight: 400; font-size: 0.75rem;">Below Passing</span></div>
  <div style="background: #E3A008; color: white; padding: 0.5rem 1rem; flex: 1; text-align: center;">720 – 800<br><span style="font-weight: 400; font-size: 0.75rem;">Pass</span></div>
  <div style="background: #1B8A5A; color: white; padding: 0.5rem 1rem; flex: 2; text-align: center;">800 – 1000<br><span style="font-weight: 400; font-size: 0.75rem;">Strong Pass</span></div>
</div>
<p>Scaled scoring means your raw number of correct answers is converted to a score on the 100–1000 scale. You don't need to score 720 out of 1000 questions. The 720 represents your <strong>adjusted performance</strong>.</p>
</v-click>

<v-click>
<div class="di-step-card">
  <span class="di-step-num">Strategy:</span> Aim to understand concepts thoroughly, not just clear the minimum. A strong understanding of Domains 1, 3, and 4 — which together account for <strong>67%</strong> of the exam — will carry you well past 720.
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
Scaled scoring means your raw number of correct answers is converted to a score on the 100-1000 scale.

You don't need to score 720 out of 1000 questions. The 720 represents your adjusted performance.

[click]

What this means practically: aim to understand concepts thoroughly, not just clear the minimum. A strong understanding of Domains 1, 3, and 4 — which together account for 67% of the exam — will carry you well past 720.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 3 — The Question Format
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">The Question Format</div>

<div class="di-body" style="margin-top: 0.75rem;">

<v-click>
<div class="di-step-card" style="margin-bottom: 0.75rem;">
  <span class="di-step-num">Format:</span> Every question is <strong>multiple choice</strong> with exactly four options and one correct answer.
</div>
</v-click>

<v-click>
<p>Questions are <strong>scenario-based</strong>. You won't be asked "define stop_reason." You'll be given a situation — an architecture decision, a broken system, a tradeoff — and asked which approach is best.</p>
</v-click>

<v-click>
<div style="background: white; border: 1px solid #c8e6d0; border-radius: 8px; padding: 0.75rem 1rem; margin-top: 0.5rem; font-size: 0.9rem;">
  <strong>No true/false or free-response questions</strong> appear on the exam. However, preparing by thinking through scenarios out loud is one of the best study techniques — the exam rewards explained reasoning, even if you don't write it down.
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
Every question is multiple choice with exactly four options and one correct answer.

The questions are scenario-based. You won't be asked "define stop_reason." You'll be given a situation — an architecture decision, a broken system, a tradeoff — and asked which approach is best.

[click]

There are no true/false questions or free-response items in the exam itself. However, preparing for this exam by thinking through scenarios out loud is one of the best study techniques, because the exam rewards explained reasoning — even if you don't write it down.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 4 — The Scenario Structure: 6 Presented, 4 Required
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">The Scenario Structure: 6 Presented, 4 Required</div>

<div class="di-body" style="margin-top: 0.75rem;">

<v-click>
<p>The exam presents <strong>six scenarios</strong>. You must answer questions related to <strong>four</strong> of them.</p>
<p>Which four? <em>You don't know in advance.</em> Anthropic chooses, not you.</p>
</v-click>

<v-click>
<p><strong>This means you must prepare for all six.</strong> You cannot skip two scenarios hoping they won't appear. The six scenarios are:</p>
<div style="display: flex; gap: 0.4rem; flex-wrap: wrap; margin-top: 0.5rem;">
  <div style="background: #1A3A4A; color: white; border-radius: 6px; padding: 0.35rem 0.65rem; font-size: 0.8rem;">Customer Support Resolution Agent</div>
  <div style="background: #1B8A5A; color: white; border-radius: 6px; padding: 0.35rem 0.65rem; font-size: 0.8rem;">Code Generation with Claude Code</div>
  <div style="background: #0D7377; color: white; border-radius: 6px; padding: 0.35rem 0.65rem; font-size: 0.8rem;">Multi-Agent Research System</div>
  <div style="background: #2a7a8a; color: white; border-radius: 6px; padding: 0.35rem 0.65rem; font-size: 0.8rem;">Developer Productivity with Claude</div>
  <div style="background: #3CAF50; color: white; border-radius: 6px; padding: 0.35rem 0.65rem; font-size: 0.8rem;">Claude Code for CI/CD</div>
  <div style="background: #4a6080; color: white; border-radius: 6px; padding: 0.35rem 0.65rem; font-size: 0.8rem;">Structured Data Extraction</div>
</div>
</v-click>

<v-click>
<p style="margin-top: 0.75rem; font-size: 0.9rem; color: #1A3A4A;">Each maps strongly to one or two exam domains. <strong>Section 7</strong> of this course does a deep dive on each.</p>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
Here's the piece of the exam format that surprises candidates most.

The exam presents six scenarios. You must answer questions related to four of them.

Which four? You don't know in advance. Anthropic chooses, not you.

[click]

This means you must prepare for all six. You cannot skip two scenarios hoping they won't appear. The six scenarios are:

Customer Support Resolution Agent, Code Generation with Claude Code, Multi-Agent Research System, Developer Productivity with Claude, Claude Code for CI/CD, and Structured Data Extraction.

Each maps strongly to one or two exam domains. Section 7 of this course does a deep dive on each.
-->

---
layout: two-cols
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 5 — No Penalty for Guessing
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">No Penalty for Guessing</div>

::left::
<div class="di-col-left-label" style="color: #E53E3E; border-color: #E53E3E;">❌ Penalty-Based Exam</div>
<div class="di-col-body">
<v-click at="1">
<ul>
  <li>Wrong answers subtract points from your total</li>
  <li>Strategy: skip questions you aren't sure about</li>
  <li>Leaving blanks can be the safer choice</li>
</ul>
</v-click>
</div>

::right::
<div class="di-col-right-label" style="color: #1B8A5A; border-color: #1B8A5A;">✓ CCA-F Exam</div>
<div class="di-col-body">
<v-click at="1">
<ul>
  <li>Incorrect answers score <strong>zero</strong> — no subtraction</li>
  <li><strong>Never leave a question blank</strong></li>
  <li>If down to two options, pick the one most consistent with: "programmatic constraints beat prompt guidance for hard rules"</li>
</ul>
</v-click>
<v-click at="2">
<div class="di-col-warning">
  Use your time budget to review flagged questions, but always submit an answer on <strong>every question</strong> before time runs out.
</div>
</v-click>
</div>

<img src="/logo.png" class="di-logo" />

<!--
There is no penalty for incorrect answers on this exam.

Wrong answers score zero. They do not subtract points from your total.

This changes your strategy for questions you're unsure about.

[click]

Never leave a question blank. If you're down to two options, pick the one that seems most consistent with the principle "programmatic constraints beat prompt guidance for hard rules" — that's often the tie-breaker pattern on Domain 1 and 4 questions.

Use your time budget to review flagged questions, but always submit an answer on every question before time runs out.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 6 — Time Management
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Time Management</div>

<div class="di-body" style="margin-top: 0.75rem;">

<v-click>
<p>There's no published time limit in the exam guide, so manage your time <strong>conservatively</strong>.</p>
</v-click>

<v-click>
<div style="display: flex; gap: 0; margin: 0.75rem 0; border-radius: 8px; overflow: hidden; font-size: 0.85rem; font-weight: 700; text-align: center;">
  <div style="background: #1A3A4A; color: white; padding: 0.6rem 1rem; flex: 7;">First Pass<br><span style="font-weight: 400; font-size: 0.75rem;">~90 sec/question</span></div>
  <div style="background: #0D7377; color: white; padding: 0.6rem 1rem; flex: 2;">Review Flagged</div>
  <div style="background: #3CAF50; color: white; padding: 0.6rem 1rem; flex: 1;">Final Check</div>
</div>
</v-click>

<v-click>
<div class="di-step-card">
  <span class="di-step-num">Rule:</span> If you're stuck on a question for more than two minutes, <strong>flag it and move on</strong>. Come back with fresh eyes.
</div>
</v-click>

<v-click>
<p>The scenario-based questions reward careful reading over quick intuition — take the time to identify what the question is actually testing before you look at the answers.</p>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
There's no published time limit in the exam guide, so manage your time conservatively.

For multiple-choice certification exams like this, a good heuristic is about 90 seconds per question on the first pass.

If you're stuck on a question for more than two minutes, flag it and move on. Come back with fresh eyes.

The scenario-based questions reward careful reading over quick intuition — take the time to identify what the question is actually testing before you look at the answers.
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
<div class="di-exam-subtitle">Read the Question Stem Before Looking at Options</div>
<div class="di-exam-body">
  The most common mistake candidates make is <strong>anchoring on the answer choices</strong> before fully reading the scenario.<br><br>
  Domain 1 questions in particular contain multiple architectural details. Missing one detail — like "the customer explicitly asked to speak with a human" — changes the correct answer completely.
</div>
</v-click>

<v-click>
<div class="di-trap-box">
  <div class="di-trap-label">❌ Wrong Approach</div>
  Skimming the scenario, reading the answers first, then confirming your gut choice
</div>
</v-click>

<v-click>
<div class="di-correct-box">
  <div class="di-correct-label">✓ Right Approach</div>
  Read the full question stem. Identify what problem it's describing. <strong>Then</strong> look at the answers.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
The most common mistake candidates make is anchoring on the answer choices before fully reading the scenario.

Domain 1 questions in particular contain multiple architectural details. Missing one detail — like "the customer explicitly asked to speak with a human" — changes the correct answer completely.

Read the full question stem. Identify what problem it's describing. Then look at the answers.
-->

---
layout: default
class: di-takeaway-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 8 — Key Takeaways
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-takeaway-title">What to Remember</div>

<ul class="di-takeaway-list">
  <v-click><li>Passing score is <strong>720 out of 1000</strong> (scaled scoring — not raw correct count)</li></v-click>
  <v-click><li>Four of six scenarios appear on your exam — you must <em>prepare for all six</em></li></v-click>
  <v-click><li>No penalty for wrong answers — always submit something on every question</li></v-click>
  <v-click><li>Read the full question stem before evaluating answer choices</li></v-click>
</ul>

<img src="/logo.png" class="di-logo" style="opacity: 0.75;" />

<!--
Four things to hold onto from this lecture.

Passing score is 720 out of 1000 — that's scaled scoring, not raw correct count.

Four of six scenarios appear on your exam — which means you must prepare for all six. You don't get to choose.

There's no penalty for wrong answers — always submit something on every question.

And read the full question stem before evaluating answer choices — anchoring on answers early is the most common mistake candidates make.
-->
