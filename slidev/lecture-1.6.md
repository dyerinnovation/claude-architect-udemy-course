---
theme: default
title: "Lecture 1.6: How to Navigate the Official Exam Guide"
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
  <div class="di-cover-title">How to Navigate the<br>Official Exam Guide</div>
  <div class="di-cover-subtitle">Lecture 1.6 · Section 1: Course Introduction & Exam Strategy</div>
</div>

<img src="/logo.png" class="di-logo-centered" />

<!--
Anthropic publishes an official exam guide for the CCA-F certification.

Most candidates read it once, acknowledge it exists, and then set it aside.

That's a mistake.

The exam guide is your highest-fidelity signal for what Anthropic considers important enough to test. This lecture shows you how to use it as a study tool, not just a reference document.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 2 — What's in the Exam Guide
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">What's in the Exam Guide</div>

<div class="di-body" style="margin-top: 0.75rem;">

<v-click>
<div class="di-step-card">
  <span class="di-step-num">1. Domain Overview</span> — a description of each domain and its weight. You already know these from the previous lecture.
</div>
</v-click>

<v-click>
<div class="di-step-card">
  <span class="di-step-num">2. Task Statements</span> — specific things Anthropic says the exam will test in each domain. These are the closest thing to a public answer key for what to study.
</div>
</v-click>

<v-click>
<div class="di-step-card" style="border-left-color: #E3A008;">
  <span class="di-step-num" style="color: #E3A008;">3. 12 Sample Questions</span> — with correct answers. These are the only questions where you have the official answer. Study each one deeply. We dissect all 12 in <strong>Section 8</strong> of this course.
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
The exam guide contains three things that matter to you.

First: the domain overview — a description of each domain and its weight. You already know these weights from the previous lecture.

[click]

Second: the task statements — specific things Anthropic says the exam will test in each domain. These are the closest thing to a public answer key for what to study.

[click]

Third: 12 sample questions with correct answers. These are the only questions where you have the official answer. Study each one deeply. We dissect all 12 in Section 8 of this course.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 3 — Reading the Task Statements
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Reading the Task Statements</div>

<div class="di-body" style="margin-top: 0.75rem;">

<v-click>
<p>Task statements follow a pattern: <strong>verb + concept in context.</strong></p>
</v-click>

<v-click>
<div class="di-step-card">
  <span class="di-step-num">The verb</span> tells you the cognitive level Anthropic is testing. "Identify" is lower-order. <strong>"Design" and "Evaluate" are higher-order</strong> — and the CCA-F is almost entirely higher-order.
</div>
</v-click>

<v-click>
<div class="di-step-card">
  <span class="di-step-num">The concept</span> tells you the exact capability being tested. If the statement says "configure MCP servers at project and user scope," you need to know not just what MCP is, but specifically <em>how project vs. user scope differ and when each applies.</em>
</div>
</v-click>

<v-click>
<div style="background: white; border: 1px solid #c8e6d0; border-radius: 8px; padding: 0.65rem 1rem; margin-top: 0.5rem; font-size: 0.9rem;">
  For every task statement: ask yourself — <strong>can I apply this in a scenario I've never seen?</strong> If yes, you're ready. If no, that's a study gap.
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
Task statements follow a pattern: verb + concept in context.

The verb tells you the cognitive level Anthropic is testing. "Identify" is lower-order. "Design" and "Evaluate" are higher-order — and the CCA-F is almost entirely higher-order.

[click]

The concept tells you the exact capability being tested. If the task statement says "configure MCP servers at project and user scope," you need to know not just what MCP is, but specifically how project vs. user scope differ and when each applies.

For every task statement in the guide, ask yourself: can I apply this in a scenario I've never seen? If yes, you're ready. If no, that's a study gap.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 4 — The 12 Sample Questions — How to Use Them
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">The 12 Sample Questions — How to Use Them</div>

<div class="di-body" style="margin-top: 0.75rem;">

<v-click>
<p>The 12 official sample questions are the most valuable resource Anthropic has given you. Anthropic wrote them — they show exactly how test-writers frame scenarios, what information they include, and what distractors they consider plausible.</p>
</v-click>

<v-click>
<p><strong>For each sample question, do this analysis:</strong></p>
<ul>
  <li>What domain is this testing?</li>
  <li>What specific concept within that domain?</li>
  <li>Which distractor looks most plausible, and why is it wrong?</li>
  <li>What's the principle that makes the correct answer correct?</li>
</ul>
</v-click>

<v-click>
<div style="background: #E3A008; color: white; border-radius: 6px; padding: 0.6rem 1rem; margin-top: 0.5rem; font-size: 0.95rem; font-weight: 600;">
  ~10 minutes per question × 12 questions = 2 hours. That investment will pay off on exam day.
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
The 12 official sample questions are the most valuable resource Anthropic has given you.

Here's why: Anthropic wrote them. These questions show exactly how the test-writers frame scenarios, what information they include, and what distractors they consider plausible.

[click]

For each sample question, don't just find the correct answer. Do this analysis:

What domain is this testing? What specific concept within that domain? Which distractor looks most plausible, and why is it wrong? What's the principle that makes the correct answer correct?

This analysis takes about 10 minutes per question. All 12 questions is two hours. That investment will pay off on exam day.
-->

---
layout: two-cols
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 5 — What the Exam Guide Explicitly Excludes
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">What the Exam Guide Explicitly Excludes</div>

::left::
<div class="di-col-left-label">✓ In Scope</div>
<div class="di-col-body">
<v-click at="1">
<ul>
  <li>Agentic loop control and stop reasons</li>
  <li>Tool description design for reliable selection</li>
  <li>MCP server configuration and error handling</li>
  <li>CLAUDE.md hierarchy and CI/CD integration</li>
  <li>Escalation decisions and context management</li>
</ul>
</v-click>
</div>

::right::
<div class="di-col-right-label" style="color: #E53E3E; border-color: #E53E3E;">❌ Out of Scope</div>
<div class="di-col-body">
<v-click at="1">
<ul>
  <li>Fine-tuning and model training internals</li>
  <li>Prompt caching mechanics</li>
  <li>Embeddings</li>
  <li>Streaming internals</li>
  <li>Vision / multimodal capabilities</li>
  <li>API authentication internals</li>
</ul>
</v-click>
<v-click at="2">
<div class="di-col-warning">
  Use the out-of-scope list to <strong>stay focused</strong>. Don't study what you don't need.
</div>
</v-click>
</div>

<img src="/logo.png" class="di-logo" />

<!--
The exam guide also tells you what's not on the exam. This matters.

Fine-tuning, prompt caching mechanics, embeddings, streaming internals, and vision/multimodal capabilities are all explicitly out of scope.

[click]

If you see a question that feels like it's testing fine-tuning knowledge or API authentication internals, you've misread the question. The CCA-F is about how to use Claude effectively in production — not about Anthropic's training process or internal API plumbing.

Use the out-of-scope list to stay focused. Don't study what you don't need.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 6 — How This Course Maps to the Exam Guide
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">How This Course Maps to the Exam Guide</div>

<div class="di-body" style="margin-top: 0.75rem;">

<v-click>
<p>Every lecture in this course maps to one or more task statements from the official exam guide. When you're studying a lecture and wondering "will this actually appear on the exam?" — the answer is <strong>always yes</strong>.</p>
</v-click>

<v-click>
<div style="background: white; border: 1px solid #c8e6d0; border-radius: 8px; overflow: hidden; margin-top: 0.5rem; font-size: 0.88rem;">
  <div style="display: grid; grid-template-columns: 1fr 1fr; background: #1A3A4A; color: white; font-weight: 700; padding: 0.4rem 0.75rem;">
    <div>Exam Guide Task Statement</div>
    <div>Course Section / Lecture</div>
  </div>
  <div style="display: grid; grid-template-columns: 1fr 1fr; padding: 0.35rem 0.75rem; background: #f9f9f9; border-bottom: 1px solid #e2e8f0;">
    <div>Design multi-agent hub-and-spoke architecture</div>
    <div>Section 2 — Lectures 2.3 &amp; 2.4</div>
  </div>
  <div style="display: grid; grid-template-columns: 1fr 1fr; padding: 0.35rem 0.75rem; background: white; border-bottom: 1px solid #e2e8f0;">
    <div>Configure MCP servers at project and user scope</div>
    <div>Section 3 — Lecture 3.4</div>
  </div>
  <div style="display: grid; grid-template-columns: 1fr 1fr; padding: 0.35rem 0.75rem; background: #f9f9f9; border-bottom: 1px solid #e2e8f0;">
    <div>Design tool descriptions for reliable selection</div>
    <div>Section 3 — Lectures 3.1 &amp; 3.2</div>
  </div>
  <div style="display: grid; grid-template-columns: 1fr 1fr; padding: 0.35rem 0.75rem; background: white;">
    <div>Apply CLAUDE.md hierarchy in team workflows</div>
    <div>Section 4 — Lectures 4.1 &amp; 4.2</div>
  </div>
</div>
</v-click>

<v-click>
<p style="font-size: 0.88rem; margin-top: 0.6rem; color: #1A3A4A;">The lecture titles are deliberately named after the task statement concepts — open both side by side to verify the alignment yourself.</p>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
Every lecture in this course maps to one or more task statements from the official exam guide.

When you're studying a lecture and wondering "will this actually appear on the exam?" — the answer is always yes. Every lecture covers a tested concept.

[click]

If you want to verify the mapping yourself, open the exam guide to the task statements for a domain, then open the corresponding section in this course. The lecture titles are deliberately named after the task statement concepts.

For example: the task statement "Design tool descriptions that enable reliable tool selection" maps directly to lectures 3.1 and 3.2 in Section 3.
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
<div class="di-exam-subtitle">The 12 Sample Questions Are the Only Public Ground Truth</div>
<div class="di-exam-body">
  The sample questions in the exam guide are the single most reliable study material for exam-day readiness.<br><br>
  Not because the questions will repeat — they won't. But because they show you Anthropic's specific phrasing style, the level of scenario complexity they use, and the type of distractor they consider plausible.
</div>
</v-click>

<v-click>
<div class="di-trap-box">
  <div class="di-trap-label">❌ Wrong Approach</div>
  Reading the sample questions, noting the correct answers, and moving on without analyzing distractors
</div>
</v-click>

<v-click>
<div class="di-correct-box">
  <div class="di-correct-label">✓ Right Approach</div>
  Deeply analyze all 12 — you'll recognize the <strong>pattern</strong> of CCA-F questions even when the content is completely new
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
The exam guide's sample questions are the single most reliable study material for exam-day readiness.

Not because the questions will repeat — they won't. But because they show you Anthropic's specific phrasing style, the level of scenario complexity they use, and the type of distractor they consider plausible.

If you've deeply analyzed all 12 sample questions, you'll recognize the pattern of CCA-F questions even when the content is completely new.
-->

---
layout: default
class: di-takeaway-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 8 — Key Takeaways
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-takeaway-title">How to Use the Exam Guide</div>

<ul class="di-takeaway-list">
  <v-click><li><strong>Task statements</strong> = the most precise list of what Anthropic will test — study them</li></v-click>
  <v-click><li>The <strong>12 sample questions</strong> reveal testing patterns — analyze all 12, including distractors</li></v-click>
  <v-click><li>The <strong>out-of-scope list</strong> protects your study time — don't study what you don't need</li></v-click>
  <v-click><li>This course covers every task statement — trust the lecture sequence</li></v-click>
  <v-click><li><strong>Section 8</strong> of this course does full distractor analysis on all 12 official sample questions</li></v-click>
</ul>

<img src="/logo.png" class="di-logo" style="opacity: 0.75;" />

<!--
Five things to hold onto from this lecture.

Task statements are the most precise list of what Anthropic will test — study them, not just the domain descriptions.

The 12 sample questions reveal testing patterns — analyze all 12, including the distractors.

The out-of-scope list protects your study time — don't study fine-tuning, embeddings, or streaming internals.

This course covers every task statement — trust the lecture sequence.

And Section 8 of this course does full distractor analysis on all 12 official sample questions.
-->
