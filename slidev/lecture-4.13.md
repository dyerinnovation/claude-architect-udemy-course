---
theme: default
title: "Lecture 4.13: Built-in Tool Selection — Grep, Glob, Read, Edit"
info: |
  Claude Certified Architect – Foundations
  Section 4 — Tool Design & MCP Integration (Domain 2, 18%)
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
const tool_columns = ['Job', 'Use when']
const tool_rows = [
  {
    label: 'Grep',
    cells: [
      { text: 'Search file contents', highlight: 'good' },
      { text: 'Finding callers, error messages, imports', highlight: 'good' },
    ],
  },
  {
    label: 'Glob',
    cells: [
      { text: 'Match file paths', highlight: 'good' },
      { text: 'Finding **/*.test.tsx', highlight: 'good' },
    ],
  },
  {
    label: 'Read',
    cells: [
      { text: 'Load full file', highlight: 'neutral' },
      { text: 'Understanding a specific file', highlight: 'neutral' },
    ],
  },
  {
    label: 'Edit',
    cells: [
      { text: 'Targeted change', highlight: 'neutral' },
      { text: 'Unique anchor text exists', highlight: 'neutral' },
    ],
  },
]

const grep_code = `# Grep — content search
grep "process_refund" **/*.py

# Returns files + line numbers for every caller.
# From there: Read the handler files that surfaced.`

const glob_code = `# Glob — path match
**/*.test.tsx
infra/**/*.tf

# Returns file paths matching the pattern.
# Doesn't read file contents. Just names.`

const antipattern_bad = `Read every file upfront "so you understand the codebase."

You hit the context wall before you understand anything.`

const antipattern_fix = `Grep for entry points — function names, key identifiers.
Read only the files the Grep surfaces.
Each Read is motivated by what the last Grep told you.`
</script>

<div class="di-cover">
  <div class="di-cover__inner">
    <div class="di-cover__eyebrow">Domain 2 · Lecture 4.13</div>
    <h1 class="di-cover__title">Grep, Glob, Read, Edit —<br/><span class="di-cover__accent">Pick the Right Built-in</span></h1>
    <div class="di-cover__subtitle">Four tools. Four jobs. Pick wrong, waste context.</div>
  </div>
</div>

<style scoped>
.di-cover { position: absolute; inset: 0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%); color: var(--mint-100); }
.di-cover__inner { padding: 110px 120px 96px; height: 100%; display: flex; flex-direction: column; justify-content: center; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px; }
.di-cover__title { font-family: var(--font-display); font-weight: 500; font-size: 102px; line-height: 1.05; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1600px; }
.di-cover__accent { color: var(--sprout-500); }
.di-cover__subtitle { font-family: var(--font-display); font-size: 40px; color: var(--mint-200); margin-top: 40px; font-weight: 400; }
</style>

<!--
Four tools. Four jobs. Pick wrong, waste context. Grep is content. Glob is paths. Read is the whole file. Edit is a surgical change with a unique anchor. This lecture makes sure you can distinguish the four cleanly — which is exactly what Task 2.5 tests.
-->

---

<ComparisonTable
  title="Built-in tools"
  :columns="tool_columns"
  :rows="tool_rows"
/>

<!--
Here's the table. Grep — search file contents for a pattern. Use it for function callers, error message locations, import statements. Glob — match file paths. Use it for "find all **/*.test.tsx." Read — load a full file. Use it when you need the whole thing to understand one specific file. Edit — make a targeted change using unique anchor text. Use it when you want to modify a small slice without rewriting the file. Four rows. Memorize them. Treating one as the other is a distractor classic.
-->

---

<CodeBlockSlide
  title="Grep — content search"
  lang="bash"
  :code="grep_code"
  annotation="How you start understanding a function's footprint across the codebase."
/>

<!--
Grep first. It searches content, not paths. The canonical use: find every caller of process_refund across the codebase. You Grep for the string process_refund and you get a list of files and line numbers. From there you Read the relevant handlers. Grep is how you start understanding a function's footprint. It's the content search tool. Nothing else in the toolbelt does content search.
-->

---

<CodeBlockSlide
  title="Glob — path match"
  lang="bash"
  :code="glob_code"
  annotation="Finds files by name pattern. Doesn't open them. Uses Grep for this? You pay to read every file."
/>

<!--
Glob next. It matches file paths, not contents. Use it for "find me every test file" — **/*.test.tsx. Or "find every Terraform module" — infra/**/*.tf. It answers the question "which files match this naming pattern?" Doesn't look inside them. Doesn't care what's in them. Just returns paths. If you want to find files by name or extension, Glob is the right tool. If you use Grep for this, you pay for reading every file when all you wanted was a name match.
-->

---

<CalloutBox variant="warn" title="When Edit fails — Read/Write fallback">

Edit needs unique anchor text. If the snippet appears three times, Edit fails — can't tell which occurrence.
<br/><br/>
<strong>Right move:</strong> Read the full file, make your change in memory, Write the file back. One pass. Done. Don't loop on failed edits with slightly longer anchors.

</CalloutBox>

<!--
Edit needs unique anchor text. If you tell Edit to replace a snippet and that snippet appears three times in the file, Edit fails — it can't tell which occurrence you meant. The right move when Edit fails: Read the full file, make your change in memory, Write the file back. That's the fallback. Don't loop on failed edits with slightly longer anchors — that wastes context and rarely converges. Read, modify, Write. One pass. Done. Task 2.5 calls this fallback out explicitly, and the exam will test whether you reach for it or whether you get stuck retrying Edit.
-->

---

<AntiPatternSlide
  title="Don't read the whole codebase"
  :badExample="antipattern_bad"
  whyItFails="Context wall. No understanding. You load everything and still don't know where the bug is."
  :fixExample="antipattern_fix"
  lang="text"
/>

<!--
Here's the anti-pattern. Reading every file upfront "so you understand the codebase." You hit the context wall before you understand anything. The right move: Grep for entry points — function names, key identifiers — and then Read only the files the Grep surfaces. Each Read is motivated by what the last Grep told you. You never touch files irrelevant to the question. That's incremental exploration, which is the next lecture in detail.
-->

---

<CalloutBox variant="tip" title="Next lecture preview">

Build codebase understanding incrementally. <strong>Grep → Read → follow imports with another Grep → Read what surfaces.</strong>
<br/><br/>
Never read-everything-upfront. The pattern that works on one file also works on one million. That's 4.14.

</CalloutBox>

<!--
Speaking of which — quick preview. Build codebase understanding incrementally. Grep, then Read, then follow imports with another Grep, then Read what that surfaces. Never read-everything-upfront. The pattern that works on one file also works on one million. That's 4.14. This lecture is the toolkit; the next one is the workflow.
-->

---

<CalloutBox variant="tip" title="On the exam — classic distractors">

<strong>"Find all .test.tsx files"</strong> → Glob. Not Grep.<br/>
<strong>"Find all callers of process_refund"</strong> → Grep. Not Glob.
<br/><br/>
Check the verb and the target. <em>Path names</em> or <em>file contents</em>? Ten seconds, not ten minutes.

</CalloutBox>

<!--
Here's the exam move. "Find all .test.tsx files" — Glob. Not Grep. If the question is about a filename pattern, and an answer reaches for Grep, that answer is wrong. "Find all callers of process_refund" — Grep. Not Glob. Glob can't see inside files. Treating Grep as a file finder or Glob as a content search is the classic Task 2.5 distractor. Know the four jobs, check the verb and the target in the question — is it about path names or about file contents? — and match it to the right tool. Ten seconds. Not ten minutes. That's how fast this decision should be on exam day.
-->

---

<ConceptHero
  leadLine="Scenario 4 — developer productivity"
  concept="Built on this tool selection."
  supportLine="Grep-for-content, Glob-for-paths, Read-for-whole, Edit-for-surgical, Edit-fallback-to-Write. That's most of Scenario 4's Domain 2."
/>

<!--
Scenario 4 — developer productivity — is built on this tool selection. Every Scenario 4 question about exploring or modifying a codebase is testing whether you pick the right built-in for the job. If you walk in with Grep-for-content, Glob-for-paths, Read-for-whole, Edit-for-surgical, Edit-fallback-to-Write — that's most of what you need for the Domain 2 questions Scenario 4 throws at you.
-->

---

<div class="di-close">
  <div class="di-close__inner">
    <div class="di-close__eyebrow">Next up</div>
    <h1 class="di-close__title">4.14 — <span class="di-close__accent">Incremental Codebase Exploration</span></h1>
    <div class="di-close__subtitle">Grep → Read → follow imports. The pattern that scales.</div>
  </div>
</div>

<style scoped>
.di-close { position: absolute; inset: 0; background: var(--mint-100); color: var(--forest-800); }
.di-close__inner { padding: 110px 120px 96px; height: 100%; display: flex; flex-direction: column; justify-content: center; }
.di-close__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.14em; text-transform: uppercase; color: var(--teal-500); margin-bottom: 36px; }
.di-close__title { font-family: var(--font-display); font-weight: 500; font-size: 84px; line-height: 1.05; letter-spacing: -0.02em; color: var(--forest-900); margin: 0; max-width: 1600px; }
.di-close__accent { color: var(--sprout-600); }
.di-close__subtitle { font-family: var(--font-display); font-size: 38px; color: var(--forest-500); margin-top: 32px; font-weight: 400; }
</style>

<!--
Next up, Lecture 4.14 — the incremental exploration pattern that ties all four built-ins together. Grep, Read, follow imports. See you there.
-->
