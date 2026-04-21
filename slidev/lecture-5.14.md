---
theme: default
title: "Lecture 5.14: Fresh-Session Review"
info: |
  Claude Certified Architect – Foundations
  Section 5 — Claude Code Configuration (Domain 3, 20%)
highlighter: shiki
transition: fade-out
mdc: true
canvasWidth: 1920
aspectRatio: 16/9
---

<style>
@import './design-system.css';
</style>

<!-- SLIDE 1 — Cover -->

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div style="flex: 1; display: flex; flex-direction: column; justify-content: center;">
    <div style="font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px;">
      Domain 3 &middot; Lecture 5.14
    </div>
    <h1 style="font-family: var(--font-display); font-weight: 500; font-size: 108px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1500px;">
      <span style="color: var(--sprout-500);">Fresh-Session</span> Review
    </h1>
    <div style="font-family: var(--font-display); font-size: 44px; color: var(--mint-200); margin-top: 40px; font-weight: 400; max-width: 1200px; line-height: 1.3;">
      The session that wrote the code is the worst one to review it in.
    </div>
  </div>
</Frame>

<!--
The session that generated code is the worst session to review it in. Fresh session equals fresh eyes. Domain 4 covers the multi-instance pattern in depth; Domain 3 covers its Claude Code surface. The exam tests both. Know the principle — independent review beats self-review, always.
-->

---

<!-- SLIDE 2 — The problem -->

<BigQuote
  lead="The failure mode"
  quote="Same session that wrote the code is biased toward saying <em>it's fine.</em>"
  attribution="Self-review looks like review but doesn't function like one"
/>

<!--
"Same session that wrote the code is biased toward saying it's fine." That's the failure mode. When a single Claude session both generates and reviews code, it carries reasoning context from generation — "I chose this approach for reasons X, Y, Z" — and that reasoning biases the review. Claude is less likely to question its own decisions because the decisions seemed justified at the time. Self-review looks like review but doesn't function like one. It's not that Claude is sloppy — it's that the generation context contaminates the review context. Structurally weaker, not effortfully weaker.
-->

---

<!-- SLIDE 3 — Why -->

<ConceptHero
  eyebrow="Why self-review fails"
  leadLine="Reasoning context biases review"
  concept="Less questioning."
  supportLine="Claude's 'why I wrote it' makes it less likely to question itself. Fresh session strips the reasons — review must stand on what's in the diff."
  accent="var(--sprout-600)"
  footerLabel="Lecture 5.14 · Fresh-Session Review"
  :footerNum="3"
  :footerTotal="9"
/>

<!--
Reasoning context biases review. That's the anchor. Claude's "why I wrote it this way" makes it less likely to question itself. If you wrote a function and you know the trade-offs you considered, you're more forgiving of the function than someone encountering it cold. Same mechanism here. Self-review is a weaker test than independent review. Not because Claude is trying to be kind to itself, but because the context that produced the code also produces the rationalization of the code. You can't unknow the reasons once you've held them. Fresh session strips the reasons away — the review has to stand on what's in the diff, not what was in the prior thought process.
-->

---

<!-- SLIDE 4 — The fix -->

<StepSequence
  eyebrow="Independent review flow"
  title="Four steps to real review"
  :steps="[
    { title: 'Session A generates the code', body: 'Full context of requirements and reasoning' },
    { title: 'Commit the code', body: 'The diff is the artifact' },
    { title: 'Session B — fresh — runs the review', body: 'Only CLAUDE.md context; no generation reasoning' },
    { title: 'Review reads the code cold', body: 'Catches what the generation session missed' },
  ]"
  footerLabel="Lecture 5.14 · Fresh-Session Review"
  :footerNum="4"
  :footerTotal="9"
/>

<!--
Independent review flow is four steps. Session A generates the code. Commit the code. Session B — fresh, no prior context — runs the review. The review session has only the CLAUDE.md context and the code diff. No generation reasoning. No attachment to particular approaches. It reads the code cold, the way a new teammate would. That fresh perspective catches things the generation session missed — subtle bugs, missed edge cases, approaches that looked fine at generation time but look off when read cold. The four-step pattern is the architecture, not the afterthought.
-->

---

<!-- SLIDE 5 — CI integration -->

<Frame>
  <Eyebrow>CI naturally isolates</Eyebrow>
  <SlideTitle>Every CI run is a fresh session.</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Good default — use it">
      <p>No memory of previous runs. No carryover from the developer's interactive session.</p>
      <p>When you run <code>claude -p</code> in a CI job to review a PR, that Claude instance has no idea how the code got written — it just sees the diff and the project context.</p>
      <p>CI isn't just automation — it's structural session isolation.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.14 · Fresh-Session Review" :num="5" :total="9" />
</Frame>

<!--
CI naturally isolates. Every CI run is a fresh session — no memory of previous runs, no carryover from the developer's interactive session. Good default. Use it. When you run `claude -p` in a CI job to review a PR, that Claude instance has no idea how the code got written — it just sees the diff and the project context. That's the architecture you want for reliable review. CI isn't just automation — it's structural session isolation.
-->

---

<!-- SLIDE 6 — Re-review on new commits -->

<Frame>
  <Eyebrow>Re-review on new commits</Eyebrow>
  <SlideTitle>Pass prior findings — skip duplicates.</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Avoid noise without losing independence">
      <p>When you re-run review on a new commit, include prior findings in the new session's context.</p>
      <p>Instruct Claude: "Report only new or still-unaddressed issues. Don't repeat anything already flagged in the prior review."</p>
      <p>The fresh session still doesn't inherit generation reasoning — it just deduplicates against the prior review. Task 3.6 calls this pattern out.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.14 · Fresh-Session Review" :num="6" :total="9" />
</Frame>

<!--
One subtlety — when you re-run review on a new commit, you want to avoid duplicate findings. The fix is to include prior findings in the new session's context and instruct Claude: "report only new or still-unaddressed issues. Don't repeat anything already flagged in the prior review." That instruction lets the fresh session act independently — it still doesn't inherit generation reasoning — but it avoids noise from repeated findings. Task 3.6 calls this pattern out specifically.
-->

---

<!-- SLIDE 7 — Exam framing -->

<Frame>
  <Eyebrow>On the exam</Eyebrow>
  <SlideTitle>"Self-review is good enough" is always a distractor.</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Two domains, one principle">
      <p><strong>Always wrong:</strong> "self-review is good enough" — sounds efficient, isn't.</p>
      <p><strong>Always right:</strong> independent Claude instance runs the review.</p>
      <p>Domain 3 covers the Claude Code surface. Domain 4 covers the broader multi-instance pattern — revisited in 6.14. Two places, same principle.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.14 · Fresh-Session Review" :num="7" :total="9" />
</Frame>

<!--
On the exam, "self-review is good enough" is always a distractor. Always. It sounds efficient, it sounds like it saves tokens, and it's wrong. The correct answer for any review-quality question is an independent Claude instance. Domain 3 covers the Claude Code surface of this pattern. Domain 4 covers the broader multi-instance review architecture — we revisit it in Section 6, lecture 6.14. Two places, same principle. Know both.
-->

---

<!-- SLIDE 8 — Continuity -->

<ConceptHero
  eyebrow="Continuity"
  leadLine="Scenario 5 — Claude Code for CI"
  concept="Isolation is structural."
  supportLine="Without session isolation, CI review is no better than self-review. With it, you have a genuinely independent second pair of eyes."
  accent="var(--teal-600)"
  footerLabel="Lecture 5.14 · Fresh-Session Review"
  :footerNum="8"
  :footerTotal="9"
/>

<!--
Scenario 5 — Claude Code for CI — this is the architecture pattern that makes Scenario 5 work. Without session isolation, your CI review is no better than self-review. With session isolation, it's a genuinely independent second pair of eyes. That's why CI-based review is a strong default — the isolation is structural.
-->

---

<!-- SLIDE 9 — Closing -->

<Frame bg="var(--mint-100)">
  <Eyebrow>Takeaways</Eyebrow>
  <SlideTitle>Fresh session = fresh eyes.</SlideTitle>
  <div style="margin-top: 48px; display: grid; grid-template-columns: 1fr 1fr; gap: 32px;">
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">01</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Self-review is biased.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Generation context contaminates review — structurally, not effortfully.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">02</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">CI naturally isolates.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Every CI run is fresh. Use it as the default review surface.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">03</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Pass prior findings.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Re-review deduplicates against them — still no generation reasoning inherited.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">04</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Next &mdash; 5.15.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Two commands: <code>/memory</code> for diagnostics, <code>/compact</code> for context.</div>
    </div>
  </div>
</Frame>

<!--
Same session that wrote the code is biased toward saying it's fine. Fresh session is the fix. CI naturally isolates — every run is independent. When re-reviewing, include prior findings and instruct Claude to skip duplicates. Exam rule of thumb — any answer saying "self-review is enough" is wrong. Independent instance is the right pattern. Next lecture — 5.15 — closes out Section 5 with two commands: `/memory` for diagnostics and `/compact` for context management.
-->
