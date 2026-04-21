---
theme: default
title: "Lecture 7.12: Scratchpad Files"
info: |
  Claude Certified Architect – Foundations
  Section 7 — Context & Reliability (Domain 5, 15%)
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
const scratchpadCode = `# scratchpad.md

## Entry points
- \`src/services/orders.py\` — OrderProcessor class, line 42
- \`src/api/checkout.ts\` — POST /v2/checkout handler

## Traced flows
- Checkout → OrderProcessor.submit() → OrderRepo.persist()
- Cancellation path bypasses OrderProcessor (see bug below)

## Known gotchas
- OrderRepo.persist() retries silently on 500s — may double-write
- TaxCalculator caches per-request; stale during replay tests

## Open questions
- Does the cancellation path trigger inventory release?
- What happens when currency code is null?

## Current hypotheses
- Bug #431 likely in OrderRepo.persist retry logic (needs verification)`

const whenBullets = [
  { label: 'Multi-phase exploration', detail: 'Discovery spans several steps; each depends on prior findings.' },
  { label: 'Context degradation risk', detail: 'Session long enough that early findings will dilute.' },
  { label: 'Session may restart', detail: 'Crash, or /compact, or intentional fresh start.' },
  { label: 'Multiple agents share findings', detail: 'One explores, another implements, a third reviews.' },
]

const scopeRows = [
  { label: 'Case-facts block', cells: [{ text: 'Customer-session transactional data', highlight: 'neutral' }] },
  { label: 'Scratchpad', cells: [{ text: 'Exploration findings / notes', highlight: 'neutral' }] },
]

const antiPatternBad = `Explore for 30 minutes. Hope the model
remembers the class names it discovered
in turn four.

By turn 25 → "typical patterns" answers.
→ Specifics gone. Degradation in full effect.`

const antiPatternFix = `Write findings to the scratchpad as you
discover them. Reference it explicitly
before any synthesis step.

Trust the FILE — not the conversation —
as the source of truth for what you've
learned.`
</script>

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div class="di-cover">
    <div class="di-cover__eyebrow">Domain 5 · Lecture 7.12</div>
    <div class="di-cover__title">Scratchpad Files</div>
    <div class="di-cover__subtitle">Cross-context persistence — the pattern name the exam uses</div>
  </div>
</Frame>

<style scoped>
.di-cover { flex: 1; display: flex; flex-direction: column; justify-content: center; gap: 32px; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 28px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); }
.di-cover__title { font-family: var(--font-display); font-size: 132px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); max-width: 1500px; }
.di-cover__subtitle { font-family: var(--font-display); font-size: 40px; color: var(--mint-200); font-style: italic; }
</style>

<!--
Lecture 7.12. Scratchpad files for cross-context persistence. We previewed this in 7.11 as the main fix for context degradation. Now let's build it out — and memorize the pattern name, because the exam uses it directly.

"Scratchpad file" is one of those exam phrases where the words themselves matter. If you see "scratchpad" in an answer choice for a long-session-memory question, that's almost always the correct answer.
-->

---

<ConceptHero
  leadLine="Externalize key findings"
  concept="Files don't forget."
  supportLine="Write important facts to a file. Reference it explicitly. It survives summarization and session restarts."
/>

<!--
Externalize key findings. Write important facts to a file. Reference that file explicitly in future turns. The file survives summarization, survives session restarts, and survives the lost-in-the-middle dilution we covered in 7.1. Conversation memory is fragile. Filesystem memory is durable. Use the durable one for anything you need to keep.

This is the same principle as the case-facts block from 7.4, but for a different domain. Case-facts is for customer-support transactions; scratchpads are for exploration findings. Same externalization move. Different surface.
-->

---

<CodeBlockSlide
  title="scratchpad.md — example structure"
  lang="markdown"
  :code="scratchpadCode"
  annotation="Free-form Markdown, structured enough to skim in one pass."
/>

<!--
A scratchpad file — typically scratchpad.md in the project root — is free-form Markdown. But it's not prose. Useful sections: discovered entry points with file paths and line numbers. Traced flows from handler to service to repository. Known gotchas — the "this looks like it should work but doesn't because X" notes. Open questions the agent is still resolving. Current hypotheses about unclear behavior.

Each section gets a header, each fact gets a bullet. Structured enough to read fast, free-form enough to grow naturally as exploration continues. The goal is a file the agent can skim in one pass and extract the key state from.
-->

---

<BulletReveal
  title="Use when..."
  :bullets="whenBullets"
/>

<!--
Use scratchpads when one or more of these holds. The work is multi-phase exploration — you're discovering something over several steps and the steps depend on each other. Context degradation risk is real — the session is long enough that you'll forget your own earlier findings. The session may restart — either because of a crash or a /compact operation that drops the specifics. Multiple agents need to share the findings — one explores, another implements, a third reviews.

Any one of those conditions is enough to justify a scratchpad. Two or three makes the scratchpad non-optional.
-->

---

<CalloutBox variant="tip" title="Explicit reference — the non-obvious part">

Claude does NOT implicitly remember a file just because you wrote to it. Reference it explicitly.

<p>Prompt pattern: <code>"Read scratchpad.md for prior findings before proceeding."</code> Literally that sentence, or something close.</p>

<p>Externalizing memory doesn't help if you forget to retrieve it. Pair every scratchpad with a system-prompt instruction or workflow step that always references it — never "maybe the model will check."</p>

</CalloutBox>

<!--
Here's the non-obvious part. Claude does NOT implicitly remember a file just because you wrote to it. You have to reference it explicitly. The prompt pattern: "Read scratchpad.md for prior findings before proceeding." Literally that sentence, or something close to it.

If you don't tell the model to read the file, it doesn't read the file. Externalizing memory doesn't help if you forget to retrieve it. This is why scratchpad files live in conjunction with a system-prompt instruction or a workflow step that always references them — never "maybe the model will check."
-->

---

<ComparisonTable
  title="Scratchpad vs case-facts"
  :columns="['Scope']"
  :rows="scopeRows"
/>

<!--
Scratchpad versus case-facts block — two related patterns, different scopes. The case-facts block from 7.4 is for transactional data in a customer-support session — amounts, dates, order IDs. Narrow scope, strict schema, customer-facing. The scratchpad is for exploration findings and notes — code discoveries, research trails, working hypotheses. Broader scope, free-form Markdown, developer-facing.

Same externalization principle; two different expressions of it. The exam may label either pattern by name — recognize both.
-->

---

<AntiPatternSlide
  title="Don't trust conversation memory"
  lang="text"
  :badExample="antiPatternBad"
  whyItFails="Conversation memory is lossy in exactly the ways that matter. The specifics that drove early turns dilute turn by turn."
  :fixExample="antiPatternFix"
/>

<!--
The anti-pattern: explore for thirty minutes, hope the model remembers the class names it discovered in turn four. It won't. By turn twenty-five, the specifics are gone and the model is back to "typical patterns" answers — the degradation tell from 7.11.

The better pattern: write findings to the scratchpad as you discover them, reference the scratchpad explicitly before any synthesis step, and trust the file — not the conversation — as the source of truth for what you've learned. Same discipline that separates teams that ship production agents from teams that demo agents that fall apart in week two.
-->

---

<CalloutBox variant="tip" title="On the exam">

"Persist findings across context boundaries" → scratchpad files.

<p>Memorize the pattern name — <strong>"scratchpad files"</strong> — because the exam uses it directly. The distractor is often a fuzzy "use memory" or "reference prior turns" that doesn't commit to a durable external mechanism.</p>

<p>For Scenario 2 or Scenario 4 long sessions with lost specifics → scratchpad is the answer.</p>

</CalloutBox>

<!--
On the exam, the shape is: "Persist findings across context boundaries." The right answer is scratchpad files. Memorize the pattern name — "scratchpad files" — because the exam uses it directly, and the distractor is often a fuzzy "use memory" or "reference prior turns" that doesn't commit to a durable external mechanism.

If the question is about Scenario 2 or Scenario 4 long sessions with lost specifics, the scratchpad pattern is the answer.
-->

---

<Frame bg="var(--mint-100)">
  <Eyebrow>Closing</Eyebrow>
  <SlideTitle>Next up: 7.13 — Crash Recovery with Structured Agent State Manifests.</SlideTitle>

  <div class="closing-body">
    <p>Scratchpads persist findings <em>inside</em> a single session. State manifests persist agent state <em>across</em> a whole pipeline — and let you recover from crashes without restarting everything from scratch.</p>
  </div>
</Frame>

<style scoped>
.closing-body { margin-top: 56px; font-family: var(--font-body); font-size: 30px; line-height: 1.5; color: var(--forest-500); max-width: 1400px; }
.closing-body p em { color: var(--forest-800); font-style: italic; }
</style>

<!--
Next up: 7.13, crash recovery with structured agent state manifests. Scratchpads persist findings inside a single session. State manifests persist agent state across a whole pipeline — and let you recover from crashes without restarting everything from scratch. See you there.
-->
