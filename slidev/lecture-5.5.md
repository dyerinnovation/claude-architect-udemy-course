---
theme: default
title: "Lecture 5.5: Path-Specific Rules with YAML Frontmatter Glob Patterns"
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
const pathsYaml = [
  DASH,
  'paths:',
  '  - "**/*.test.tsx"',
  '  - "**/*.spec.tsx"',
  '  - "**/__tests__/**/*"',
  DASH,
  '',
  '# Test file conventions',
  '',
  '- Every new component needs one test',
  '- Tests use Testing Library, not shallow rendering',
  '- Accessibility queries over test-id queries',
].join('\n')

const loadSteps = [
  { label: 'User asks Claude to edit Button.test.tsx', sublabel: 'the trigger event' },
  { label: 'Harness scans .claude/rules/ frontmatter', sublabel: 'deterministic, no inference' },
  { label: 'Any rule whose paths glob matches loads', sublabel: 'others stay out of context' },
  { label: 'Claude sees only the rules that apply', sublabel: 'lean context, targeted guidance' },
]

const globColumns = ['When it fits', 'When it fails']
const globRows = [
  { label: 'Subdir CLAUDE.md', cells: ['All files under one path', 'Files spread across dirs'] },
  { label: 'paths glob', cells: ['Spans directories by file type', 'More flexible — no failure modes'] },
]

const multiScopeYaml = [
  '# .claude/rules/terraform-rules.md',
  'paths: ["terraform/**/*"]',
  '',
  '# .claude/rules/api-rules.md',
  'paths: ["src/api/**/*"]',
  '',
  '# .claude/rules/test-rules.md',
  'paths: ["**/*.test.*"]',
].join('\n')

const antiPatternBad = [
  '# src/components/CLAUDE.md',
  '# src/features/auth/CLAUDE.md',
  '# src/features/billing/CLAUDE.md',
  '# ... 20 more copies',
  '# All say the same thing about tests.',
].join('\n')

const antiPatternFix = [
  '# .claude/rules/testing.md',
  DASH,
  'paths: ["**/*.test.*"]',
  DASH,
  '# Conventions load only for test files.',
].join('\n')
</script>

<!-- SLIDE 1 — Cover -->

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div style="flex: 1; display: flex; flex-direction: column; justify-content: center;">
    <div style="font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px;">
      Domain 3 &middot; Lecture 5.5
    </div>
    <h1 style="font-family: var(--font-display); font-weight: 500; font-size: 108px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1500px;">
      Path-Specific Rules<br/><span style="color: var(--sprout-500);">paths:</span> glob frontmatter
    </h1>
    <div style="font-family: var(--font-display); font-size: 44px; color: var(--mint-200); margin-top: 40px; font-weight: 400; max-width: 1200px; line-height: 1.3;">
      Sample Q6 lives here. Pattern-match and move on.
    </div>
  </div>
</Frame>

<!--
`paths:` in YAML frontmatter is a glob list. The rule file loads only when Claude is editing files that match one of those globs. This is how you ship conventions that span directories — and it's the pattern behind Sample Question 6, one of the most common Domain 3 exam questions.
-->

---

<!-- SLIDE 2 — The problem -->

<BigQuote
  lead="The problem"
  quote="Test files live next to source files. <em>Button.test.tsx lives next to Button.tsx.</em> How do you apply test-specific conventions without bloating every CLAUDE.md?"
/>

<!--
"Test files live next to source files. Button.test.tsx lives next to Button.tsx. How do you apply test-specific conventions without bloating every CLAUDE.md?" That's the problem statement. React test files are scattered throughout the codebase. So are Python test files. So are any file type that follows co-location conventions. Subdirectory CLAUDE.md files don't help here — there's no single subdirectory that holds all your tests. You need path-based rules that span the whole tree.
-->

---

<!-- SLIDE 3 — The answer -->

<CodeBlockSlide
  eyebrow="The syntax"
  title="paths: glob in frontmatter"
  lang="yaml"
  :code="pathsYaml"
  annotation="Standard shell globbing. Double-star recurses. Single-star matches within a directory."
  footerLabel="Lecture 5.5 · Path-Specific Rules"
  :footerNum="3"
  :footerTotal="10"
/>

<!--
Here's the syntax. At the top of a rule file — say `.claude/rules/testing.md` — you put YAML frontmatter with a `paths:` field. Inside the YAML fences, `paths: ["**/*.test.tsx"]`. That's a glob. Any file Claude touches whose path matches `**/*.test.tsx` triggers this rule to load. Anything else — the rule stays out of context. You can list multiple globs in the same array — mix React test files and Python test files if your test conventions apply across both. You can use any standard glob syntax — double-star for recursive directories, single-star for within-directory matches, braces for alternation. Standard shell globbing rules, same as your `.gitignore`.
-->

---

<!-- SLIDE 4 — How it loads -->

<FlowDiagram
  eyebrow="The load sequence"
  title="Conditional rule load"
  :steps="loadSteps"
  footerLabel="Lecture 5.5 · Path-Specific Rules"
  :footerNum="4"
  :footerTotal="10"
/>

<!--
The load sequence is straightforward. User asks Claude to edit `src/components/Button.test.tsx`. The harness scans the frontmatter of every rule in `.claude/rules/`. Any rule whose `paths:` glob matches the file being edited loads. Others stay out of context. The decision is deterministic — no inference, no guessing. Claude either sees the rule because the path matched, or doesn't because it didn't. That determinism is the point.
-->

---

<!-- SLIDE 5 — Why glob > subdirectory CLAUDE.md -->

<ComparisonTable
  eyebrow="Glob vs subdirectory CLAUDE.md"
  title="Why path globs beat subdirectory files for scattered conventions"
  :columns="globColumns"
  :rows="globRows"
  footerLabel="Lecture 5.5 · Path-Specific Rules"
  :footerNum="5"
  :footerTotal="10"
/>

<!--
Compare glob rules to subdirectory CLAUDE.md. A subdir CLAUDE.md fits when all the files share one path — an `/api` directory with API conventions, a `/terraform` directory with infra conventions. Works great when your structure is grouped by convention. It fails when files spread across dirs — test files everywhere, migration scripts everywhere, config files everywhere. Globs handle that. They span directories by file type instead of by location. More flexible. No situation where a subdir CLAUDE.md works and a glob rule doesn't — but the reverse is common.
-->

---

<!-- SLIDE 6 — Multiple scopes -->

<CodeBlockSlide
  eyebrow="Real team, real globs"
  title="Different rules, different globs"
  lang="yaml"
  :code="multiScopeYaml"
  annotation="Three rules, three concerns. None load unless the current file matches."
  footerLabel="Lecture 5.5 · Path-Specific Rules"
  :footerNum="6"
  :footerTotal="10"
/>

<!--
Here's what a real team looks like. `terraform-rules.md` with `paths: ["terraform/**/*"]` — all your infra files, one convention file. `api-rules.md` with `paths: ["src/api/**/*"]` — API-specific handlers, validators, types. `test-rules.md` with `paths: ["**/*.test.*"]` — every test file, regardless of location or extension. Three rules, three globs, three concerns. None of them load unless the current file matches. That's the targeting you want.
-->

---

<!-- SLIDE 7 — Exam framing -->

<Frame>
  <Eyebrow>On the exam</Eyebrow>
  <SlideTitle>Sample Q6 — direct exam quote.</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="The question pattern">
      <p>"Test files are spread throughout the codebase alongside the code they test, and you want all tests to follow the same conventions regardless of location."</p>
      <p><strong>Correct:</strong> rule files in <code>.claude/rules/</code> with YAML frontmatter glob patterns. <strong>Distractors:</strong> consolidate in root CLAUDE.md (unreliable), use skills (manual invocation), drop CLAUDE.md in every subdir (can't span scattered files). Memorize the distractor list.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.5 · Path-Specific Rules" :num="7" :total="10" />
</Frame>

<!--
This is Sample Question 6 territory — direct exam quote. "Your codebase has distinct areas with different coding conventions. Test files are spread throughout the codebase alongside the code they test, and you want all tests to follow the same conventions regardless of location." The correct answer is rule files in `.claude/rules/` with YAML frontmatter glob patterns. The distractors are: consolidate in root CLAUDE.md — unreliable, relies on inference; use skills — requires manual invocation, not automatic; drop CLAUDE.md in every subdir — can't handle files spread across many directories. Memorize that distractor list. It'll save you points.
-->

---

<!-- SLIDE 8 — Anti-pattern -->

<AntiPatternSlide
  eyebrow="Anti-pattern"
  title="Don't scatter CLAUDE.md files"
  :badExample="antiPatternBad"
  whyItFails="Button.test.tsx lives next to Button.tsx. A subdir CLAUDE.md applies to both."
  :fixExample="antiPatternFix"
  lang="yaml"
  footerLabel="Lecture 5.5 · Path-Specific Rules"
  :footerNum="8"
  :footerTotal="10"
/>

<!--
Bad: drop CLAUDE.md in every subdirectory that needs test conventions. You've got Button.test.tsx living next to Button.tsx, which lives under `src/components/`, and you can't put a CLAUDE.md there without applying it to Button.tsx too. You end up with CLAUDE.md files scattered everywhere, most of them duplicating the same test conventions. Good: one file — `.claude/rules/testing.md` — with `paths: ["**/*.test.*"]`. The rule loads for tests, only for tests, no matter where they live.
-->

---

<!-- SLIDE 9 — Continuity -->

<ConceptHero
  eyebrow="Continuity"
  leadLine="Files spread across the codebase + apply conventions automatically"
  concept="Pattern-match, move on."
  supportLine="This is a direct exam-guide sample question. Don't read the distractors carefully — reflex the pattern."
  accent="var(--teal-600)"
  footerLabel="Lecture 5.5 · Path-Specific Rules"
  :footerNum="9"
  :footerTotal="10"
/>

<!--
This is a direct exam-guide sample question — know the pattern as a reflex. If the scenario says "files spread across the codebase" and "apply conventions automatically," the answer is `.claude/rules/` with glob frontmatter. Don't even read the distractors carefully — pattern-match and move on.
-->

---

<!-- SLIDE 10 — Closing -->

<Frame bg="var(--mint-100)">
  <Eyebrow>Takeaways</Eyebrow>
  <SlideTitle>Globs solve the co-location problem.</SlideTitle>
  <div style="margin-top: 48px; display: grid; grid-template-columns: 1fr 1fr; gap: 32px;">
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">01</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;"><code>paths:</code> is the field.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Array of globs in YAML frontmatter. Rule loads when current file matches.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">02</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Spans directories.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">By file type, not by location. Works where subdirectory CLAUDE.md fails.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">03</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Sample Q6 reflex.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Scattered files + auto-apply = <code>.claude/rules/</code> with glob frontmatter.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">04</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Next &mdash; 5.6.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Custom slash commands. Same team/personal split, different surface.</div>
    </div>
  </div>
</Frame>

<!--
Glob-scoped rule files solve the co-location problem. Frontmatter declares when to load — `paths:` with globs. Rules span directories by file type rather than by location. Sample Q6 is this pattern exactly — know the distractors. Next lecture — 5.6 — we pivot from rules to slash commands. Same `.claude/` versus `~/.claude/` split you've seen twice already — but a different surface, with its own frontmatter options.
-->
