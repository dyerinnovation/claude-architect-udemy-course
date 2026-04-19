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

<div class="di-body" style="margin-top: 0.5rem; font-size: 0.98rem;">
The ideal candidate is a solution architect designing and implementing production applications with Claude.
</div>

<div style="font-weight: 700; color: #1A3A4A; margin-top: 0.6rem; margin-bottom: 0.5rem; font-size: 0.95rem;">You should have hands-on experience with:</div>

<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1.25rem; margin-top: 0.25rem;">
  <v-click>
  <div>
    <div class="di-col-body">
      <ul>
        <li>Building agentic applications with the Claude Agent SDK (multi-agent orchestration, subagent delegation, tool integration, lifecycle hooks)</li>
        <li>Configuring Claude Code for team workflows (CLAUDE.md, Agent Skills, MCP server integrations, plan mode)</li>
        <li>Designing MCP tool and resource interfaces for backend integration</li>
        <li>Engineering prompts for reliable structured output (JSON schemas, few-shot, extraction patterns)</li>
      </ul>
    </div>
  </div>
  </v-click>
  <v-click>
  <div>
    <div class="di-col-body">
      <ul>
        <li>Managing context windows across long documents, multi-turn conversations, and multi-agent handoffs</li>
        <li>Integrating Claude into CI/CD pipelines (automated code review, test generation, PR feedback)</li>
        <li>Making sound escalation and reliability decisions (error handling, human-in-the-loop, self-evaluation)</li>
      </ul>
    </div>
  </div>
  </v-click>
</div>

<v-click>
<div class="di-correct-box" style="margin-top: 0.9rem;">
  <div class="di-correct-label">Typical Profile</div>
  6+ months of practical experience with the Claude API, Agent SDK, Claude Code, and MCP.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
This course is built for a specific audience: solution architects who design and implement production applications with Claude. That's Anthropic's own description of the ideal certification candidate.

You should have hands-on experience across seven areas the exam draws from: building agentic applications with the Claude Agent SDK; configuring Claude Code for team workflows; designing MCP tool interfaces; engineering prompts for reliable structured output; managing context windows across long conversations and multi-agent handoffs; integrating Claude into CI/CD pipelines; and making sound escalation and reliability decisions.

[click]

Anthropic's guidance says candidates typically have six or more months of practical experience with the Claude API, Agent SDK, Claude Code, and MCP. If that's you, you're in the right place.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 3 — What This Course Covers
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">What This Course Covers</div>

<div style="margin-top: 0.5rem;">

<v-click>

<div style="display: flex; gap: 0.5rem; flex-wrap: wrap; margin: 0.25rem 0 0.4rem 0;">
  <div style="background: #1A3A4A; color: white; border-radius: 6px; padding: 0.4rem 0.7rem; font-size: 0.82rem; font-weight: 600;">1 · Intro & Exam Strategy</div>
  <div style="background: #1A3A4A; color: white; border-radius: 6px; padding: 0.4rem 0.7rem; font-size: 0.82rem; font-weight: 600; box-shadow: 0 0 0 2px #E3A008;">2 · Claude API Bootcamp <span style="font-size: 0.68rem; background: #E3A008; color: white; padding: 0.05rem 0.35rem; border-radius: 3px; margin-left: 0.25rem;">NEW</span></div>
</div>

<div style="display: flex; gap: 0.5rem; flex-wrap: wrap; margin: 0.4rem 0;">
  <div style="background: #1B8A5A; color: white; border-radius: 6px; padding: 0.4rem 0.7rem; font-size: 0.82rem; font-weight: 600;">3 · Agentic Architecture <span style="font-size:0.68rem; opacity:0.85;">(27%)</span></div>
  <div style="background: #2C9A5B; color: white; border-radius: 6px; padding: 0.4rem 0.7rem; font-size: 0.82rem; font-weight: 600;">4 · Tool Design & MCP <span style="font-size:0.68rem; opacity:0.85;">(18%)</span></div>
  <div style="background: #3CAF50; color: white; border-radius: 6px; padding: 0.4rem 0.7rem; font-size: 0.82rem; font-weight: 600;">5 · Claude Code Config <span style="font-size:0.68rem; opacity:0.85;">(20%)</span></div>
  <div style="background: #3CAF50; color: white; border-radius: 6px; padding: 0.4rem 0.7rem; font-size: 0.82rem; font-weight: 600;">6 · Prompt Engineering <span style="font-size:0.68rem; opacity:0.85;">(20%)</span></div>
  <div style="background: #4BBF60; color: white; border-radius: 6px; padding: 0.4rem 0.7rem; font-size: 0.82rem; font-weight: 600;">7 · Context & Reliability <span style="font-size:0.68rem; opacity:0.85;">(15%)</span></div>
</div>

<div style="display: flex; gap: 0.5rem; flex-wrap: wrap; margin: 0.4rem 0 0.6rem 0;">
  <div style="background: #0D7377; color: white; border-radius: 6px; padding: 0.4rem 0.7rem; font-size: 0.82rem; font-weight: 600;">8 · Scenario Deep Dives</div>
  <div style="background: #2a7a8a; color: white; border-radius: 6px; padding: 0.4rem 0.7rem; font-size: 0.82rem; font-weight: 600;">9 · Practice Exam & Review</div>
  <div style="background: #4a6080; color: white; border-radius: 6px; padding: 0.4rem 0.7rem; font-size: 0.82rem; font-weight: 600;">10 · Quick Reference & Final Review</div>
</div>

</v-click>

<v-click>

<div class="di-body" style="font-size: 0.92rem; margin-top: 0.4rem;">
Section 1 sets the exam strategy. Section 2 is a hands-on Claude API bootcamp — the exam expects a working understanding of the API underpinning everything else, so this builds that foundation. Sections 3 through 7 map directly to the five exam domains, ordered by weight. Sections 8 through 10 pivot to scenario analysis, the full practice exam, and a quick-reference final review with the 20 things you must know cold.
</div>

</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
This course follows the exam structure directly.

Section 1 — where you are now — covers exam strategy and orientation. Section 2 is a hands-on Claude API bootcamp. The exam assumes you understand the API that underpins everything else — tool use, structured output, streaming, the Messages API — so we build that foundation before we touch agentic patterns.

[click]

Sections 3 through 7 go deep on each of the five exam domains, in exam-weight order. Domain 1 — Agentic Architecture — is 27 percent of the exam, so it comes first.

Section 8 walks through all six exam scenarios. Section 9 is the full practice exam with answer review. Section 10 is your quick-reference and final review — the 20 things you must know cold.
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
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 5 — Three Ways to Work Through This Course
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Three Ways to Work Through This Course</div>

<div class="di-body" style="margin-top: 0.4rem; font-size: 0.95rem;">
Pick the path that matches your starting point.
</div>

<div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 0.9rem; margin-top: 0.8rem;">

  <v-click>
  <div class="di-step-card" style="border-left-color: #1A3A4A; padding: 0; overflow: hidden;">
    <div style="background: #1A3A4A; color: white; padding: 0.45rem 0.75rem; font-weight: 700; font-size: 0.9rem;">New to the Claude API</div>
    <div style="padding: 0.5rem 0.75rem; font-size: 0.78rem; color: #4a5568; font-style: italic; border-bottom: 1px solid #e5e7eb;">Little to no Claude API experience</div>
    <ol style="padding: 0.55rem 0.75rem 0.6rem 1.4rem; margin: 0; font-size: 0.82rem; line-height: 1.45; color: #111928;">
      <li>Start with the API Bootcamp (Section 2)</li>
      <li>Watch every lecture, in order</li>
      <li>Review the Study Guides</li>
      <li>Work through the Demos</li>
      <li>Take the Practice Exam</li>
      <li>Review weak sections</li>
      <li>Retake the Practice Exam until you score 900</li>
    </ol>
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card" style="border-left-color: #0D7377; padding: 0; overflow: hidden;">
    <div style="background: #0D7377; color: white; padding: 0.45rem 0.75rem; font-weight: 700; font-size: 0.9rem;">Familiar with Claude</div>
    <div style="padding: 0.5rem 0.75rem; font-size: 0.78rem; color: #4a5568; font-style: italic; border-bottom: 1px solid #e5e7eb;">Decent experience with Claude API, Claude Code, etc.</div>
    <ol style="padding: 0.55rem 0.75rem 0.6rem 1.4rem; margin: 0; font-size: 0.82rem; line-height: 1.45; color: #111928;">
      <li>Skim the API Bootcamp as a refresher (use as needed)</li>
      <li>Watch the remaining lectures</li>
      <li>Review the Study Guides</li>
      <li>Work through the Demos</li>
      <li>Take the Practice Exam (linked in course notes)</li>
      <li>Review weak sections</li>
      <li>Retake until 900</li>
    </ol>
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card" style="border-left-color: #E3A008; padding: 0; overflow: hidden;">
    <div style="background: #E3A008; color: white; padding: 0.45rem 0.75rem; font-weight: 700; font-size: 0.9rem;">Short on Time</div>
    <div style="padding: 0.5rem 0.75rem; font-size: 0.78rem; color: #4a5568; font-style: italic; border-bottom: 1px solid #e5e7eb;">Tons of experience with Claude / short on time</div>
    <ol style="padding: 0.55rem 0.75rem 0.6rem 1.4rem; margin: 0; font-size: 0.82rem; line-height: 1.45; color: #111928;">
      <li>Review the Study Guides</li>
      <li>Work through the Demos</li>
      <li>Take the Practice Exam (linked in course notes)</li>
      <li>Review weak sections</li>
      <li>Retake until 900</li>
    </ol>
  </div>
  </v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
There's no single 'right' way to study for this exam. Your starting point determines your path. Pick the one that fits.

[click]

Path one — if you're new to the Claude API. Start with Section 2, the API Bootcamp. Then watch every lecture in order, review the study guides, work through the demos, take the practice exam, review your weak sections, and retake the practice exam until you score a 900.

[click]

Path two — if you already have decent experience with the Claude API or Claude Code. Use the bootcamp as a refresher on anything rusty, then watch the remaining lectures, review the study guides and demos, take the practice exam linked in the course notes, review your weakest areas, and retake until 900.

[click]

Path three — if you have tons of experience and you're short on time. Skip straight to the study guides and demos, take the practice exam, review the sections you're weakest in, and retake until 900.

Whichever path you pick, the end state is the same: a 900 or higher on the practice exam before you sit the real one. A 900 gives you enough cushion over the 720 passing score to absorb exam-day variance.
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
