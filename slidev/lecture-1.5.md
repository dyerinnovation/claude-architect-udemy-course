---
theme: default
title: "Lecture 1.5: Study Strategy for Tomorrow vs 2 Weeks Out"
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
  <div class="di-cover-title">Study Strategy:<br>Tomorrow vs 2 Weeks Out</div>
  <div class="di-cover-subtitle">Lecture 1.5 · Section 1: Course Introduction & Exam Strategy</div>
</div>

<img src="/logo.png" class="di-logo-centered" />

<!--
People come to this course with very different time horizons.

Some of you scheduled the exam weeks out and have time to work through everything systematically.

Others have the exam in 24 hours and need the fastest possible path to 720.

This lecture gives you a concrete study plan for both situations.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 2 — If Your Exam Is Tomorrow
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">If Your Exam Is Tomorrow</div>

<div class="di-body" style="margin-top: 0.75rem;">

<v-click>
<p>You don't have time to watch this course from start to finish. Here's your three-step plan.</p>
</v-click>

<v-click>
<div class="di-step-card" style="border-left-color: #E3A008;">
  <span class="di-step-num" style="color: #E3A008;">Step 1.</span> Go to <strong>Section 9</strong> right now. Watch all three lectures. The "20 Things You Must Know Cold" lecture alone covers the highest-probability exam concepts in under 20 minutes.
</div>
</v-click>

<v-click>
<div class="di-step-card" style="border-left-color: #E3A008;">
  <span class="di-step-num" style="color: #E3A008;">Step 2.</span> Work through the <strong>Section 8 practice exam</strong>. Attempt every question before looking at the answer. Spending five seconds glancing at answers doesn't help — the practice only works if you commit to an answer first.
</div>
</v-click>

<v-click>
<div class="di-step-card" style="border-left-color: #E3A008;">
  <span class="di-step-num" style="color: #E3A008;">Step 3.</span> Identify your <strong>weakest domain</strong> from the practice exam, then review that domain's cheat sheet in the resources folder. Sleep. Go pass the exam.
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
If your exam is tomorrow, you don't have time to watch this course from start to finish.

Here's your three-step plan.

Step one: go to Section 9 right now. Watch all three lectures. The "20 Things You Must Know Cold" lecture alone covers the highest-probability exam concepts in under 20 minutes.

[click]

Step two: work through the Section 8 practice exam. Attempt every question before looking at the answer. Spending five seconds glancing at answers doesn't help. The practice only works if you commit to an answer first.

[click]

Step three: identify your weakest domain from the practice exam, then review that domain's cheat sheet in the resources folder. Sleep. Go pass the exam.
-->

---
layout: two-cols
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 3 — The Systematic 2-Week Plan
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">The Systematic 2-Week Plan</div>

::left::
<div class="di-col-left-label">Week 1 — Domain Foundations</div>
<div class="di-col-body">
<v-click at="1">
<ul>
  <li><strong>Day 1:</strong> Section 2 — Domain 1 (Agentic Architecture, 27%)</li>
  <li><strong>Day 2:</strong> Section 3 — Domain 2 (Tool Design & MCP)</li>
  <li><strong>Day 3:</strong> Section 4 — Domain 3 (Claude Code Config)</li>
  <li><strong>Day 4:</strong> Section 5 — Domain 4 (Prompt Engineering)</li>
  <li><strong>Day 5:</strong> Section 6 — Domain 5 (Context Management)</li>
</ul>
<p style="font-size: 0.85rem; margin-top: 0.5rem;"><em>Take the section quiz before moving on each day.</em></p>
</v-click>
</div>

::right::
<div class="di-col-right-label">Week 2 — Application & Review</div>
<div class="di-col-body">
<v-click at="2">
<ul>
  <li><strong>Days 6–8:</strong> Section 7 — Scenario Deep Dives</li>
  <li><strong>Day 9:</strong> Section 8 — Full Practice Exam</li>
  <li><strong>Day 10:</strong> Review weakest domain cheat sheet</li>
  <li><strong>Night before:</strong> Section 9 — Final review</li>
</ul>
</v-click>
</div>

<img src="/logo.png" class="di-logo" />

<!--
With two weeks, here's how to approach this course systematically.

In Week 1: work through Sections 2 through 6 — one domain section per day, in order. Start with Domain 1 (Section 2) since it's the highest weight. Each section has a quiz — take it before moving on.

[click]

In Week 2: start with Section 7 (Scenario Deep Dives) to cement how domain concepts apply in context. Then do the Section 8 practice exam. Use the results to identify your weakest domain and spend a day reviewing it. Finish with Section 9 (final review) the night before the exam.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 4 — Why Domain Order Matters
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Why Domain Order Matters</div>

<div class="di-body" style="margin-top: 0.75rem;">

<v-click>
<div style="display: flex; flex-direction: column; align-items: center; gap: 0; margin: 0.5rem 0;">
  <div class="di-flow-box" style="width: 60%; font-size: 0.9rem;">Domain Knowledge<br><span style="font-weight: 400; font-size: 0.78rem;">The foundation — what the rules are</span></div>
  <div class="di-arrow">▼</div>
  <div class="di-flow-tool" style="width: 60%; font-size: 0.9rem;">Scenario Application<br><span style="font-weight: 400; font-size: 0.78rem;">How to apply rules in context</span></div>
  <div class="di-arrow">▼</div>
  <div class="di-flow-stop" style="width: 60%; font-size: 0.9rem;">Exam Questions<br><span style="font-weight: 400; font-size: 0.78rem;">Judgment under pressure</span></div>
</div>
</v-click>

<v-click>
<div class="di-step-card" style="margin-top: 0.5rem;">
  <span class="di-step-num">Pitfall 1:</span> Skipping domain sections to go straight to scenario practice = navigating without a map.
</div>
</v-click>

<v-click>
<div class="di-step-card">
  <span class="di-step-num">Pitfall 2:</span> Spending all time on domain theory and never applying it to scenarios = exam questions feel slightly unfamiliar.
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
The course is sequenced this way deliberately.

Domain knowledge is the foundation. Scenario application is how you convert domain knowledge into judgment. The exam tests judgment.

If you skip the domain sections and go straight to scenario practice, you're trying to navigate without a map.

[click]

Conversely, if you spend all your time on domain theory and never practice applying it to scenarios, you'll find the exam questions feel slightly unfamiliar — because you've only ever seen the concepts in isolation.

The two-week plan threads both.
-->

---
layout: two-cols
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 5 — The Most Common Preparation Mistake
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">The Most Common Preparation Mistake</div>

::left::
<div class="di-col-left-label" style="color: #E53E3E; border-color: #E53E3E;">❌ What Most Candidates Do</div>
<div class="di-col-body">
<v-click at="1">
<ul>
  <li>Read all the lecture notes and slides</li>
  <li>Skim the practice exam answers</li>
  <li>Glance at wrong answers and move on</li>
</ul>
<div class="di-col-warning">Reading feels productive — but the exam doesn't test whether you remember reading something.</div>
</v-click>
</div>

::right::
<div class="di-col-right-label">✓ What Works</div>
<div class="di-col-body">
<v-click at="1">
<ul>
  <li>Take the quiz at the end of each section</li>
  <li>Work the practice exam under time pressure</li>
  <li>For wrong answers: explain <em>why</em> the wrong answer felt right</li>
</ul>
</v-click>
<v-click at="2">
<div style="background: #F0FFF4; border-left: 3px solid #3CAF50; border-radius: 4px; padding: 0.5rem 0.75rem; margin-top: 0.5rem; font-size: 0.88rem;">
  <strong>Distractor analysis</strong> — understanding why wrong answers fail — is the single most valuable exam prep activity in this course.
</div>
</v-click>
</div>

<img src="/logo.png" class="di-logo" />

<!--
Most candidates spend too much time reading and not enough time practicing.

Reading lecture notes feels productive. But the exam doesn't test whether you remember reading something — it tests whether you can apply it to a new scenario.

[click]

The higher-value activities: taking the quiz at the end of each section, working through the practice exam under time pressure, and being able to explain why each wrong answer is wrong — not just why the right answer is right.

That last habit — distractor analysis — is probably the single most valuable exam prep activity in this course.
-->

---
layout: default
class: di-exam-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 6 — Exam Tip
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-exam-banner">⚡ EXAM TIP</div>

<v-click>
<div class="di-exam-subtitle">Distractor Analysis Beats Passive Reading</div>
<div class="di-exam-body">
  The candidates who fail usually <strong>know the right answer intuitively</strong> but get pulled into a distractor that sounds plausible.<br><br>
  For every practice question you get wrong, don't just note the correct answer. Understand <em>why the wrong answer felt right</em>, and identify the specific concept it misrepresents.
</div>
</v-click>

<v-click>
<div class="di-trap-box">
  <div class="di-trap-label">❌ Wrong Approach</div>
  Mark the question correct or incorrect, note the right answer, and move on
</div>
</v-click>

<v-click>
<div class="di-correct-box">
  <div class="di-correct-label">✓ Right Approach</div>
  For every wrong answer: ask "what specific concept does this distractor misrepresent, and why did it feel right?" — Section 8 does this systematically for all 12 official questions
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
The candidates who fail usually know the right answer intuitively but get pulled into a distractor that sounds plausible.

For every practice question you get wrong, don't just note the correct answer. Understand why the wrong answer felt right, and identify the specific concept it misrepresents.

This is what Section 8 of this course does systematically for all 12 official sample questions.
-->

---
layout: default
class: di-takeaway-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 7 — Key Takeaways
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-takeaway-title">What to Remember</div>

<ul class="di-takeaway-list">
  <v-click><li><strong>Exam tomorrow:</strong> Section 9 → Section 8 practice exam → weakest domain cheat sheet</li></v-click>
  <v-click><li><strong>2 weeks out:</strong> Sections 2–6 in order → Section 7 scenarios → Section 8 practice → Section 9 the night before</li></v-click>
  <v-click><li>In both cases: practice <em>distractor analysis</em> — understand why wrong answers fail, not just why the right answer is right</li></v-click>
</ul>

<img src="/logo.png" class="di-logo" style="opacity: 0.75;" />

<!--
Three things to hold onto.

If your exam is tomorrow: Section 9, then Section 8 practice exam, then your weakest domain cheat sheet.

If your exam is two weeks out: Sections 2 through 6 in order, then Section 7 for scenario application, then Section 8 practice exam, then Section 9 the night before.

In both cases: practice distractor analysis. Don't just mark questions correct or incorrect — understand why the wrong answers fail.
-->
