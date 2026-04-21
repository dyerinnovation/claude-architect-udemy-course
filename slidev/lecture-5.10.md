---
theme: default
title: "Lecture 5.10: Plan Mode vs Direct Execution"
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

<script setup>
const decisionsColumns = ['Mode', 'Why']
const decisionsRows = [
  { label: 'Monolith → microservices', cells: ['Plan', 'Architectural — Sample Q5'] },
  { label: 'Date-validation conditional', cells: ['Direct', 'Well-scoped single-file'] },
  { label: 'Library migration — 45 files', cells: ['Plan', 'Multi-file, approach matters'] },
  { label: 'Fix stack trace', cells: ['Direct', 'Root cause is clear'] },
]

const planOutput = `# Refactor plan: user-service → microservices

## Files touched
- services/user/* (new)
- services/auth/* (modified)
- infra/k8s/user-service.yaml (new)
- ... 38 more

## Order
1. Extract session helpers → services/auth
2. Create services/user scaffolding
3. Migrate controllers
4. Wire inter-service auth
5. Cut over + remove monolith routes

## Trade-offs considered
- Shared Postgres instance vs per-service DB → chose shared (migration cost)
- gRPC vs REST for internal → REST (existing observability)

## Risks
- Session TTL drift during cutover
- Transaction boundary across services
`
</script>

<!-- SLIDE 1 — Cover -->

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div style="flex: 1; display: flex; flex-direction: column; justify-content: center;">
    <div style="font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px;">
      Domain 3 &middot; Lecture 5.10
    </div>
    <h1 style="font-family: var(--font-display); font-weight: 500; font-size: 108px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1500px;">
      Plan Mode vs <span style="color: var(--sprout-500);">Direct</span> Execution
    </h1>
    <div style="font-family: var(--font-display); font-size: 44px; color: var(--mint-200); margin-top: 40px; font-weight: 400; max-width: 1200px; line-height: 1.3;">
      Sample Q5 territory. One question answers the decision.
    </div>
  </div>
</Frame>

<!--
Plan mode. Direct execution. Two modes of Claude Code work. The decision rule is one question. If more than one valid approach exists, plan. If you already know the fix, direct. This lecture is Sample Question 5 territory — know the framework as reflex.
-->

---

<!-- SLIDE 2 — The question -->

<BigQuote
  lead="The plan-mode test"
  quote="Is there more than one reasonable way to do this?"
  attribution="One question. The whole decision rides on it."
/>

<!--
"Is there more than one reasonable way to do this?" That's the plan-mode test. One question, yes or no. If yes — architectural choice, approach ambiguity, multiple valid paths — plan. If no — there's a clear best path, you already know it, the scope is tight — direct. Don't overthink the framework. It's one sentence. The whole decision rides on whether the approach itself needs deliberation or just execution.
-->

---

<!-- SLIDE 3 — Plan mode -->

<Frame>
  <Eyebrow>Plan mode</Eyebrow>
  <SlideTitle>Think before you touch.</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="When approach is ambiguous">
      <p>Large-scale changes. Architectural decisions. Multi-file edits. Multiple valid approaches where picking the wrong one is expensive to undo.</p>
      <p>Plan mode does codebase exploration, designs an approach, writes a plan, and <strong>waits for you to approve it before any file gets modified</strong>. Output is a plan, not a diff. Review, adjust, commit to the approach, then execute.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.10 · Plan vs Direct" :num="3" :total="11" />
</Frame>

<!--
Plan mode is for when you need to think before you touch. Large-scale changes. Architectural decisions. Multi-file edits. Tasks where multiple valid approaches exist and picking the wrong one is expensive to undo. Plan mode does codebase exploration, designs an approach, writes a plan, and waits for you to approve it before any file gets modified. The output is a plan, not a diff. You review, you adjust, you commit to the approach, and then you execute.
-->

---

<!-- SLIDE 4 — Direct execution -->

<Frame>
  <Eyebrow>Direct execution</Eyebrow>
  <SlideTitle>Path is clear — just ship it.</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="When approach is unambiguous">
      <p>Single-file bug with a clean stack trace. Adding a validation check to one function. Well-scoped change where the approach isn't in question — only the implementation.</p>
      <p>You already know what to do. Going into plan mode here adds overhead without benefit. Direct execution just writes the fix and moves on.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.10 · Plan vs Direct" :num="4" :total="11" />
</Frame>

<!--
Direct is for when the path is clear. Single-file bug with a clean stack trace. Adding a validation check to one function. Well-scoped change where the approach isn't in question — only the implementation. You already know what to do. Going into plan mode here adds overhead without benefit. Direct execution just writes the fix and moves on.
-->

---

<!-- SLIDE 5 — Concrete examples -->

<ComparisonTable
  eyebrow="Real decisions, real framework"
  title="Concrete decisions"
  :columns="decisionsColumns"
  :rows="decisionsRows"
  footerLabel="Lecture 5.10 · Plan vs Direct"
  :footerNum="5"
  :footerTotal="11"
/>

<!--
Put real decisions next to the framework. Monolith to microservices — plan mode, because that's architectural, and it's exactly Sample Question 5. Date-validation conditional inside one function — direct, because the scope is a single file and the approach is unambiguous. Library migration affecting forty-five files — plan mode, because cross-file implications matter and the approach is non-trivial. Fix a stack trace where the root cause is obvious — direct, because there's one clear fix. Four decisions, four applications of the same rule.
-->

---

<!-- SLIDE 6 — Combined pattern -->

<ConceptHero
  eyebrow="The move that beats either alone"
  leadLine="Plan to design. Direct to implement."
  concept="Both. In order."
  supportLine="Explore the codebase, trace dependencies, pick the approach. Commit to the plan. Switch to direct and ship."
  accent="var(--sprout-600)"
  footerLabel="Lecture 5.10 · Plan vs Direct"
  :footerNum="6"
  :footerTotal="11"
/>

<!--
Here's the move that's better than either alone. Plan mode to design, then direct execution to implement. Use plan mode to explore the codebase, trace the dependencies, pick the approach. Review the plan. Commit to it. Switch to direct execution and ship it. Best of both — deliberation where it earns its keep, speed where it doesn't. The exam guide calls this out explicitly — "combining plan mode for investigation with direct execution for implementation." Remember the phrase.
-->

---

<!-- SLIDE 7 — The plan-mode output -->

<CodeBlockSlide
  eyebrow="The plan artifact"
  title="What plan mode produces"
  lang="markdown"
  :code="planOutput"
  annotation="A first-class artifact. You review it like any proposal before any code changes."
  footerLabel="Lecture 5.10 · Plan vs Direct"
  :footerNum="7"
  :footerTotal="11"
/>

<!--
What does plan mode actually produce? A written plan — in markdown, typically — that describes the change: what files will be touched, in what order, with what approach, and what trade-offs were considered. You read the plan before any code changes. You push back on decisions you disagree with. Claude revises. When you're happy, you commit to the plan and exit plan mode for the execution phase. The plan is a first-class artifact. It gets reviewed like any proposal.
-->

---

<!-- SLIDE 8 — Anti-pattern -->

<AntiPatternSlide
  eyebrow="Anti-pattern"
  title="Don't direct-execute architectural changes"
  badExample="# Strategy: 'I'll start in direct mode
#            and switch to plan if it gets hard.'
# Problem: complexity is stated in the requirements.
# You commit to a bad approach and pay in rework."
  whyItFails="The complexity isn't going to emerge mid-execution — it's stated up front."
  fixExample="# Strategy: read the requirements.
# Architectural → plan mode from the start.
# Well-scoped single-file → direct mode.
# Match the mode to what the task is."
  lang="text"
  footerLabel="Lecture 5.10 · Plan vs Direct"
  :footerNum="8"
  :footerTotal="11"
/>

<!--
Bad: "I'll start in direct mode and switch to plan if it gets hard." That sounds reasonable, but it's wrong. The requirements already told you the task was architectural — Sample Question 5 says "dozens of files, decisions about service boundaries and module dependencies." The complexity isn't going to emerge mid-execution — it's stated up front. Starting direct and hoping you don't hit turbulence is exactly how you commit to a bad approach and pay for it in rework. Good: if the requirements say architectural, start in plan mode. If they say well-scoped single-file, start direct.
-->

---

<!-- SLIDE 9 — Exam framing -->

<Frame>
  <Eyebrow>Sample Q5 — the template</Eyebrow>
  <SlideTitle>Monolith → microservices = plan mode from the start.</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="The correct reflex">
      <p><strong>Question:</strong> "Restructure monolith into microservices. Changes across dozens of files. Decisions about service boundaries and module dependencies."</p>
      <p><strong>Correct:</strong> enter plan mode, explore, understand dependencies, design before any changes.</p>
      <p><strong>Classic distractor:</strong> "start in direct execution and switch to plan mode if you encounter unexpected complexity." Almost-right trap. The complexity isn't unexpected — it's stated.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.10 · Plan vs Direct" :num="9" :total="11" />
</Frame>

<!--
Sample Question 5 is the template. "Restructure monolith into microservices. Changes across dozens of files. Decisions about service boundaries and module dependencies." Correct answer — enter plan mode, explore, understand dependencies, design before any changes. The classic distractor — "start in direct execution and switch to plan mode if you encounter unexpected complexity." That's the almost-right trap. The complexity isn't unexpected — it's stated. Plan mode from the start is the correct reflex.
-->

---

<!-- SLIDE 10 — Continuity -->

<ConceptHero
  eyebrow="Continuity"
  leadLine="Path A, Path B, Path C — doesn't matter."
  concept="Plan mode scales."
  supportLine="Experienced devs still benefit from plan mode on architectural work. What changes with experience is how quickly you spot the multiple-approaches case."
  accent="var(--teal-600)"
  footerLabel="Lecture 5.10 · Plan vs Direct"
  :footerNum="10"
  :footerTotal="11"
/>

<!--
Path A, Path B, Path C — doesn't matter. Experienced devs still benefit from plan mode on architectural work, and brand-new users benefit even more. The decision framework scales with experience — what changes is how quickly you can tell whether a task has multiple valid approaches, not whether the framework applies.
-->

---

<!-- SLIDE 11 — Closing -->

<Frame bg="var(--mint-100)">
  <Eyebrow>Takeaways</Eyebrow>
  <SlideTitle>The plan-mode test: more than one valid approach?</SlideTitle>
  <div style="margin-top: 48px; display: grid; grid-template-columns: 1fr 1fr; gap: 32px;">
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">01</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Plan when ambiguous.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Architectural, multi-file, multiple valid approaches.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">02</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Direct when clear.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Single-file scope, clean stack trace, you know the fix.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">03</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Combine for big work.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Plan to design, direct to implement. Best of both.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">04</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Next &mdash; 5.11.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">The Explore subagent — same isolation idea as <code>context: fork</code>, different surface.</div>
    </div>
  </div>
</Frame>

<!--
Plan mode when the approach is ambiguous. Direct when the approach is clear. Combine them — plan to design, direct to implement. Sample Question 5 lives here. Next lecture — 5.11 — covers the Explore subagent, the other tool for isolating discovery from main context. Same idea as `context: fork`, different surface.
-->
