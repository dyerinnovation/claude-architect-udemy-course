---
theme: default
title: "Lecture 5.8: context: fork — Isolating Skill Execution"
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
const DASH = '-'.repeat(3)

const forkBullets = [
  { label: 'Produces verbose exploration output', detail: 'Codebase analysis, dependency tracing, doc gathering' },
  { label: 'Brainstorms alternatives', detail: 'You want one chosen path, not the full branching exploration' },
  { label: 'Runs a multi-step analysis', detail: 'Security audits tracing each finding through the code' },
  { label: 'Has side-effect-free discovery phases', detail: 'Test: does the main session need the intermediate work, or just the conclusion?' },
]

const noForkBullets = [
  { label: 'Modifies state the main session tracks', detail: 'File edits, command runs whose effects matter downstream' },
  { label: 'Is short — forking adds overhead', detail: 'Spinning up a sub-agent has real cost' },
  { label: 'Needs continuity with prior turns', detail: 'If the skill needs context from 5 turns ago, a fresh sub-agent strips it' },
]

const forkExample = [
  DASH,
  'name: codebase-explorer',
  'description: Traces data flow through the codebase for a specified feature. Summarizes call sites, dependencies, and entry points.',
  'context: fork',
  DASH,
  '',
  '# Instructions',
  '',
  'Given a feature name:',
  '1. Grep for feature references',
  '2. Read and trace data flow',
  '3. Return a structured summary (not the exploration receipts)',
].join('\n')
</script>

<!-- SLIDE 1 — Cover -->

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div style="flex: 1; display: flex; flex-direction: column; justify-content: center;">
    <div style="font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px;">
      Domain 3 &middot; Lecture 5.8
    </div>
    <h1 style="font-family: var(--font-display); font-weight: 500; font-size: 108px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1500px;">
      <span style="color: var(--sprout-500);">context: fork</span><br/>Isolating Skill Execution
    </h1>
    <div style="font-family: var(--font-display); font-size: 44px; color: var(--mint-200); margin-top: 40px; font-weight: 400; max-width: 1200px; line-height: 1.3;">
      Main session gets output — not working tokens.
    </div>
  </div>
</Frame>

<!--
`context: fork` is the frontmatter field that runs a skill in a sub-agent context. The main conversation gets a clean summary, not forty tool-call receipts. This is how you stop verbose skills from eating your context budget. One field. Big operational lever.
-->

---

<!-- SLIDE 2 — The problem -->

<BigQuote
  lead="The failure mode"
  quote="A codebase-analysis skill runs — returns <em>35 tool calls and 8,000 tokens</em> of exploration to the main session. Now every turn is slower."
/>

<!--
"A codebase-analysis skill runs — returns thirty-five tool calls and eight thousand tokens of exploration to the main session. Now every turn is slower." That's the failure mode. You wrote a skill that does useful work. It works. But the byproduct is that every grep, every read, every trace step of the skill execution gets accumulated in your main context. The main session is now carrying that weight for the rest of the conversation — slower responses, more token spend, and context pressure that wasn't necessary because the user didn't need the receipts.
-->

---

<!-- SLIDE 3 — The fix -->

<ConceptHero
  eyebrow="The fix"
  leadLine="Fork the context"
  concept="context: fork."
  supportLine="Skill runs in isolation — sub-agent spins up, does its work, returns only the final output. Main session keeps the answer, not the working memory."
  accent="var(--sprout-600)"
  footerLabel="Lecture 5.8 · context: fork"
  :footerNum="3"
  :footerTotal="9"
/>

<!--
Fork the context. That's the move. Set `context: fork` in the skill's frontmatter. Now the skill runs in isolation — a sub-agent spins up with its own context window, does its work, and returns just the final output to the main session. The exploration tokens, the intermediate tool calls, the branching thoughts — none of it comes back. Main session gets the answer and none of the working memory that produced it.
-->

---

<!-- SLIDE 4 — When to fork -->

<BulletReveal
  eyebrow="When to fork"
  title="Fork when the skill..."
  :bullets="forkBullets"
  footerLabel="Lecture 5.8 · context: fork"
  :footerNum="4"
  :footerTotal="9"
/>

<!--
Fork when the skill produces verbose exploration output — codebase analysis, dependency tracing, documentation gathering, anything where getting the answer requires a lot of intermediate reading. Fork when the skill brainstorms alternatives — you want one chosen path returned, not the full branching exploration of options that didn't make the cut. Fork when the skill runs multi-step analysis — a security audit that traces each finding through the code doesn't need to leak every step into the main session. Fork when the skill has side-effect-free discovery phases. The test: does the main session need the intermediate work, or just the conclusion? If just the conclusion — fork.
-->

---

<!-- SLIDE 5 — When NOT to fork -->

<BulletReveal
  eyebrow="When NOT to fork"
  title="Keep in main when the skill..."
  :bullets="noForkBullets"
  footerLabel="Lecture 5.8 · context: fork"
  :footerNum="5"
  :footerTotal="9"
/>

<!--
Don't fork when the skill modifies state the main session needs to track — if the skill edits files or runs commands whose side effects matter for subsequent turns, the main session should see those. Don't fork short skills — the cost of spinning up a sub-agent is real, and a skill that fires quickly isn't benefiting from isolation. Don't fork when continuity with prior turns matters — if the skill needs to reason about what was said five turns ago, running in a fresh sub-agent context will strip that out. The decision isn't "fork always," it's "fork when the working tokens aren't the point."
-->

---

<!-- SLIDE 6 — Example -->

<CodeBlockSlide
  eyebrow="SKILL.md with fork"
  title="A codebase-exploration skill that forks"
  lang="yaml"
  :code="forkExample"
  annotation="Without fork, all the grepping and reading lands in main context. With fork, only the summary returns."
  footerLabel="Lecture 5.8 · context: fork"
  :footerNum="6"
  :footerTotal="9"
/>

<!--
Here's it in practice. SKILL.md with the frontmatter block up top. `name: codebase-explorer`. `description: traces data flow through the codebase for a specified feature`. `context: fork`. The skill will grep, read a bunch of files, build a mental model, summarize. Without `fork`, all that grepping and reading lands in the main context. With `fork`, only the summary returns. Same output to the user, an order of magnitude less context consumed.
-->

---

<!-- SLIDE 7 — Ties to Explore subagent -->

<Frame>
  <Eyebrow>Same idea, different surface</Eyebrow>
  <SlideTitle>context: fork is one of two isolation surfaces.</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="The Explore subagent is the other">
      <p>Domain 3 also has the Explore subagent — Task 3.4 — for the exact same purpose in a different place.</p>
      <p><code>context: fork</code> lives in SKILL.md. The Explore subagent is a plan-mode surface tool.</p>
      <p>Both isolate verbose discovery from main context. Covered in depth in 5.11. Same pattern, different invocation surface.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.8 · context: fork" :num="7" :total="9" />
</Frame>

<!--
Same idea, different surface. Domain 3 also has the Explore subagent — Task 3.4 — for the exact same purpose in a different place. `context: fork` in SKILL.md is the skills-surface version. The Explore subagent is the plan-mode surface version. Both isolate verbose discovery from main context. We cover Explore in depth in 5.11. If you know one, you know the other — the pattern is the reusable lesson.
-->

---

<!-- SLIDE 8 — Exam framing -->

<Frame>
  <Eyebrow>On the exam</Eyebrow>
  <SlideTitle>Verbose skill pollutes main context → fork.</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Isolation is the fix — not volume reduction">
      <p><strong>Not</strong> "fewer tool calls" — misses the point.</p>
      <p><strong>Not</strong> "better description" — that controls when the skill fires, not what it spills.</p>
      <p><strong>Not</strong> "shorter body" — truncating it makes the skill worse.</p>
      <p><strong>The answer:</strong> <code>context: fork</code>. Isolation is the fix.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.8 · context: fork" :num="8" :total="9" />
</Frame>

<!--
On the exam, a verbose skill output polluting main context is always `context: fork`. Not "fewer tool calls" — that's a distractor that misses the point. Not "better description" — descriptions control when the skill fires, not what it spills. Not "shorter body" — the body is the prompt, and truncating it makes the skill worse, not cleaner. The isolation is the fix. `context: fork` is how you isolate. Memorize the pair — verbose skill plus pollution equals fork.
-->

---

<!-- SLIDE 9 — Closing -->

<Frame bg="var(--mint-100)">
  <Eyebrow>Takeaways</Eyebrow>
  <SlideTitle>Fork when working tokens aren't the point.</SlideTitle>
  <div style="margin-top: 48px; display: grid; grid-template-columns: 1fr 1fr; gap: 32px;">
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">01</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Isolates execution.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Skill runs in sub-agent. Main session gets only the final output.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">02</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Fork when verbose.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Exploration, analysis, brainstorming. Working tokens aren't the answer.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">03</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Don't fork stateful skills.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">File edits, continuity, short skills — leave in main.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">04</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Next &mdash; 5.9.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;"><code>allowed-tools</code> and <code>argument-hint</code> — safety rail and UX polish.</div>
    </div>
  </div>
</Frame>

<!--
`context: fork` runs a skill in isolation. Main session gets output, not working tokens. Use it when the skill is verbose, exploratory, or analytical. Don't use it when the skill modifies state the main session tracks, when the skill is short, or when continuity across turns matters. Next lecture — 5.9 — covers the other two important frontmatter fields: `allowed-tools` for safety and `argument-hint` for UX. Small fields, big operational impact.
-->
