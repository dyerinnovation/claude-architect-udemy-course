---
theme: default
title: "Lecture 5.4: .claude/rules/ — Topic-Specific Rule Files"
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
const rulesLayout = `.claude/
  rules/
    testing.md
    api-conventions.md
    deployment.md
    security.md
  CLAUDE.md
`

const DASH = '-'.repeat(3)
const ruleFileSample = [
  DASH,
  'paths:',
  '  - "**/*.test.ts"',
  '  - "**/*.spec.ts"',
  DASH,
  '',
  '# Testing conventions',
  '',
  '- Prefer Vitest + Testing Library',
  '- Co-locate tests next to source files',
  '- Name test files with .test.ts suffix',
].join('\n')

const ruleColumns = ['Loads when', 'Best for']
const ruleRows = [
  { label: '@import', cells: ['Always, when CLAUDE.md loads', 'Universal standards'] },
  { label: '.claude/rules/*', cells: ['Conditionally — by path glob', 'File-type specific conventions'] },
]
</script>

<!-- SLIDE 1 — Cover -->

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div style="flex: 1; display: flex; flex-direction: column; justify-content: center;">
    <div style="font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px;">
      Domain 3 &middot; Lecture 5.4
    </div>
    <h1 style="font-family: var(--font-display); font-weight: 500; font-size: 108px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1500px;">
      <span style="color: var(--sprout-500);">.claude/rules/</span><br/>Topic-Specific Rule Files
    </h1>
    <div style="font-family: var(--font-display); font-size: 44px; color: var(--mint-200); margin-top: 40px; font-weight: 400; max-width: 1200px; line-height: 1.3;">
      One file per topic. The harness decides which to load.
    </div>
  </div>
</Frame>

<!--
`.claude/rules/` is the directory that breaks the CLAUDE.md monolith apart by topic. One file per concern. The harness decides which rules to load based on context. Ships with the repo like everything else in `.claude/`.
-->

---

<!-- SLIDE 2 — Why -->

<ConceptHero
  eyebrow="The idea"
  leadLine="Split by topic, load by context"
  concept="One file, one concern."
  supportLine="The harness decides which rules to load. Better than a 400-line CLAUDE.md in every session."
  accent="var(--sprout-600)"
  footerLabel="Lecture 5.4 · .claude/rules/"
  :footerNum="2"
  :footerTotal="9"
/>

<!--
Split by topic, load by context. That's the idea. One file per topic — testing in one file, API conventions in another, deployment in a third, security in a fourth. Each file is focused. Each file can be maintained by the team that owns that topic — the platform team owns testing, the product team owns API conventions, SRE owns deployment. And critically — Claude doesn't have to load all of them at once. The harness picks which rules apply based on what Claude is actually doing. Better than a 400-line CLAUDE.md for every session where you actually only needed the testing rules.
-->

---

<!-- SLIDE 3 — Structure -->

<CodeBlockSlide
  eyebrow="The layout"
  title=".claude/rules/ — one file per topic"
  lang="text"
  :code="rulesLayout"
  annotation="Names are for humans — the harness uses frontmatter to decide when to load."
  footerLabel="Lecture 5.4 · .claude/rules/"
  :footerNum="3"
  :footerTotal="9"
/>

<!--
Here's the layout. Inside your repo, `.claude/rules/` holds a handful of markdown files. `testing.md`. `api-conventions.md`. `deployment.md`. `security.md`. Each file is one topic. The names are for humans — the harness uses frontmatter to decide when to load them, not the filename. But the filename matters for the maintainers, the people who open the repo six months from now and need to know where the testing standards live. Keep names descriptive so the next teammate can find what they need without opening every file. Your rule directory should read like a table of contents for your team's conventions.
-->

---

<!-- SLIDE 4 — Each file format -->

<CodeBlockSlide
  eyebrow="File shape"
  title="testing.md — a rule file"
  lang="markdown"
  :code="ruleFileSample"
  annotation="YAML frontmatter declares scope. Markdown body is the convention."
  footerLabel="Lecture 5.4 · .claude/rules/"
  :footerNum="4"
  :footerTotal="9"
/>

<!--
Each rule file has two parts — YAML frontmatter at the top, markdown body below. The frontmatter declares when the rule loads — that's where the `paths:` field lives, which we cover in depth next lecture. The body is the actual convention — the content Claude reads when the rule fires. Think of it as the same shape as a blog post with metadata, or a Jekyll page, or a Notion database entry, or an Obsidian note. Frontmatter declares scope. Body is content. Same two-part pattern across the whole Claude Code ecosystem — commands, skills, rules all follow it.
-->

---

<!-- SLIDE 5 — vs @import -->

<ComparisonTable
  eyebrow="Two modular patterns"
  title="rules/ vs @import"
  :columns="ruleColumns"
  :rows="ruleRows"
  footerLabel="Lecture 5.4 · .claude/rules/"
  :footerNum="5"
  :footerTotal="9"
/>

<!--
Put `.claude/rules/` next to `@import` from the last lecture. `@import` loads always — whenever the parent CLAUDE.md loads, the imported content comes with it. `.claude/rules/*` loads conditionally — by path glob, only when Claude is editing files that match. Best for what? `@import` fits universal standards — things every session needs. `.claude/rules/` fits file-type-specific conventions — test files, terraform files, migration scripts, API handlers. Two patterns, two jobs. Know when to reach for each.
-->

---

<!-- SLIDE 6 — Next lecture preview -->

<Frame>
  <Eyebrow>Next lecture preview</Eyebrow>
  <SlideTitle>Path scoping — coming in 5.5.</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Rules get their power from YAML paths:">
      <p>A rule file has frontmatter that controls when it loads. The loading is conditional on file paths matched by glob patterns.</p>
      <p>We'll make this concrete with globs and real codebase examples in the next ten minutes. Sample Question 6 lives there.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.4 · .claude/rules/" :num="6" :total="9" />
</Frame>

<!--
The real power of `.claude/rules/` comes from YAML frontmatter `paths:` globs. That's next lecture — 5.5. For now, know that a rule file has frontmatter that controls when it loads, and the loading is conditional on file paths. We'll make this concrete with globs and real codebase examples in the next ten minutes.
-->

---

<!-- SLIDE 7 — Exam framing -->

<Frame>
  <Eyebrow>On the exam</Eyebrow>
  <SlideTitle>"Split conventions by topic without bloating CLAUDE.md."</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Task 3.1 — structural answer">
      <p>"Splitting large CLAUDE.md files into focused topic-specific files in <code>.claude/rules/</code>, like <code>testing.md</code>, <code>api-conventions.md</code>, <code>deployment.md</code>." Quote from the exam guide.</p>
      <p>Whenever a question describes a monolithic CLAUDE.md problem and asks for modularity, <code>.claude/rules/</code> is the structural answer. Read the sentence, own it.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.4 · .claude/rules/" :num="7" :total="9" />
</Frame>

<!--
On the exam, the keyword match is "split conventions by topic without bloating CLAUDE.md." That's `.claude/rules/`. It's the structural answer whenever a question describes a monolithic CLAUDE.md problem and asks for modularity. The exam skill is literally — quote from Task 3.1 — "splitting large CLAUDE.md files into focused topic-specific files in .claude/rules/, like testing.md, api-conventions.md, deployment.md." That's the sentence. Read it, own it.
-->

---

<!-- SLIDE 8 — Continuity -->

<ConceptHero
  eyebrow="Continuity"
  leadLine="Same hierarchy logic as 1.1 — biggest levers get the biggest share of context."
  concept="Load what's relevant."
  supportLine="Testing rules don't need to load when editing deployment YAML. Adding a new rule file doesn't bloat every session's context."
  accent="var(--teal-600)"
  footerLabel="Lecture 5.4 · .claude/rules/"
  :footerNum="8"
  :footerTotal="9"
/>

<!--
Same hierarchy logic as 1.1 — biggest levers get the biggest share of context. Your testing conventions don't need to load when you're editing deployment YAML. Your API error-handling rules don't need to load when you're editing a migration script. Load what's relevant. Leave out what isn't. That's how you keep Claude's attention on the thing in front of it — and it scales as your repo grows, because adding a new rule file doesn't bloat every session's context.
-->

---

<!-- SLIDE 9 — Closing -->

<Frame bg="var(--mint-100)">
  <Eyebrow>Takeaways</Eyebrow>
  <SlideTitle>Split by topic. Load by context.</SlideTitle>
  <div style="margin-top: 48px; display: grid; grid-template-columns: 1fr 1fr; gap: 32px;">
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">01</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">One file per topic.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Testing, API, deployment, security — each in its own file in <code>.claude/rules/</code>.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">02</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Conditional load.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Harness picks which rules apply based on context — not always loaded like <code>@import</code>.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">03</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Two-part shape.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">YAML frontmatter declares scope. Markdown body is the convention.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">04</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Next &mdash; 5.5.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Path-specific rules with YAML frontmatter glob patterns. Sample Q6 lives here.</div>
    </div>
  </div>
</Frame>

<!--
`.claude/rules/` splits CLAUDE.md by topic. One file per topic, loaded conditionally by the harness. Different from `@import` — that's always-loaded, this is conditional. Different from subdirectory CLAUDE.md — that's path-bound, this is file-type-bound. Next lecture — 5.5 — we look at the frontmatter that makes conditional loading actually work. The field is `paths:`, the values are globs, and this is where Sample Question 6 lives.
-->
