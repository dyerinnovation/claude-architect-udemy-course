---
theme: default
title: "Lecture 6.15: Per-File + Cross-File Review"
info: |
  Claude Certified Architect – Foundations
  Section 6 — Prompt Engineering & Structured Output (Domain 4, 20%)
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
const flowSteps = [
  { label: 'Split changeset by file', sublabel: '40 files in → 40 independent reviews + 1 integration pass' },
  { label: 'Per-file pass (parallel)', sublabel: 'One file per prompt. Local issues only.' },
  { label: 'Aggregate local findings', sublabel: 'Collect the output of the per-file passes.' },
  { label: 'Cross-file pass', sublabel: 'Integration-facing files sent together. Data flow + contracts.' },
  { label: 'Combine findings', sublabel: 'Per-file + cross-file merged into the final review.' },
]

const badReview = `# One prompt:
# "Review this PR: 40 files attached. Flag bugs,
# integration issues, style issues. Be thorough."
# → superficial comments, missed bugs, contradictory findings`

const goodReview = `# Per-file pass (parallel): 40 focused reviews
for f in changeset.files:
    local_findings += claude.review_file(f, claude_md)

# One cross-file pass on the interacting files
integration_findings = claude.review_integration(
    interacting_files, claude_md
)`
</script>

<CoverSlide
  title="Per-File + Cross-File Review"
  subtitle="Split the review. Each pass has one job. Both passes, not just one."
  eyebrow="Domain 4 · Lecture 6.15"
  :stats="['Section 6', 'Scenario 5', 'Domain 4 · 20%', '8 min']"
/>

<!--
Final lecture in Domain 4. Eight minutes. This one covers the other half of review architecture: splitting a large review into per-file passes plus one cross-file integration pass. It's the answer to Sample Q12 on the official exam guide — the 14-file PR question — and it closes this section cleanly because it's a direct application of prompt chaining, which Domain 1 covers as the general case.
-->

---

<BigQuote
  lead="Domain 4 · Lecture 6.15"
  quote="One prompt reviewing 40 files finds nothing useful in any file. Tokens spread too thin."
  attribution="Attention dilution — the core failure"
/>

<!--
Here's the failure mode in one sentence. One prompt reviewing forty files finds nothing useful in any file. Tokens spread too thin across too many files, and the model ends up with superficial comments on some, obvious bugs missed on others, and — worst — contradictory findings where the same pattern is flagged in one file and approved in another within the same review. This is attention dilution. It's not a model-size problem. It's a prompt-shape problem.
-->

---

<ConceptHero
  leadLine="Each pass is focused on one kind of problem. Findings compose cleanly."
  concept="Two passes, two jobs"
  supportLine="Per-file pass for local issues. Cross-file pass for integration. Same decomposition principle as subagent delegation from Domain 1 — focused steps, each with its own context budget."
/>

<!--
The fix. Two passes, two jobs. Per-file pass for local issues. Cross-file pass for integration. Each pass is focused on one kind of problem, and the findings compose cleanly. You're not asking the model to hold forty files' worth of context and reason across all of them at once — you're asking it to do one well-scoped task per pass. Same principle as subagent delegation from Domain 1: decompose into focused steps, each with its own context budget.
-->

---

<CalloutBox variant="tip" title="Per-file pass — local issues">
  <p>Bugs in <em>one</em> file. Style within <em>one</em> file. Function-scope logic — off-by-one, missing null-check, unhandled exception inside a single function.</p>
  <p>The pass sees <strong>one file at a time</strong>, with whatever surrounding <code>CLAUDE.md</code> rules apply. Does not reason about how this file interacts with another.</p>
  <p>One file in, findings out. Run in <strong>parallel</strong> across every file in the changeset — they're independent.</p>
</CalloutBox>

<!--
The per-file pass handles local issues. Bugs in one file. Style within one file. Function-scope logic — off-by-one, missing null-check, unhandled exception inside a single function. The pass sees one file at a time, with whatever surrounding CLAUDE.md rules apply. It does not try to reason about how this file interacts with another. One file in, findings out. Do this for every file in the changeset in parallel — they're independent.
-->

---

<CalloutBox variant="tip" title="Cross-file pass — integration">
  <p><strong>Data flow</strong> across modules — does this new field in File A get read correctly in File B?</p>
  <p><strong>Interface contracts</strong> — did someone change a function signature in File C without updating callers in Files D and E?</p>
  <p><strong>Import/export mismatches.</strong></p>
  <p>Sees the relevant files together — not necessarily all forty, but the files that interact. Looking for <em>seams</em>, not local logic.</p>
</CalloutBox>

<!--
The cross-file pass handles integration concerns. Data flow across modules — does this new field in File A get read correctly in File B? Interface contracts — did someone change a function signature in File C without updating the callers in Files D and E? Import/export mismatches. This pass sees the relevant files together — not necessarily all forty, but the files that interact. It's looking for seams, not local logic.
-->

---

<FlowDiagram
  eyebrow="Architecture"
  title="Two-pass review — five steps"
  :steps="flowSteps"
/>

<!--
Here's the flow. Step one: split the changeset into individual files. Step two: per-file pass — one file per prompt, local issues only. These can run in parallel. Step three: aggregate all local findings. Step four: cross-file pass — the integration-facing files sent together, one prompt, looking for data flow and contract issues. Step five: combine the per-file and cross-file findings into the final review output. Clean decomposition, clear responsibilities, no attention dilution.
-->

---

<CalloutBox variant="tip" title="Callback to Domain 1 — prompt chaining">
  <p>This is <strong>prompt chaining</strong> — fixed, sequential decomposition where each step has a defined input and output.</p>
  <p>Domain 1 Task 1.6 covers this as the general pattern; multi-pass review is the specific application of that pattern to code review.</p>
  <p>Anchor concept across both domains: <strong>focus the context, compose the outputs</strong>.</p>
</CalloutBox>

<!--
Callback to Domain 1. This is prompt chaining — fixed, sequential decomposition where each step has a defined input and a defined output. Domain 1 Task 1.6 covers this as the general pattern; multi-pass review is the specific application of that pattern to code review. The reason the exam tests this in Domain 4 is that the review use case is the cleanest example of prompt chaining paying off. The anchor concept is the same across both domains: focus the context, compose the outputs.
-->

---

<AntiPatternSlide
  title="Don't one-shot the 40-file review"
  lang="text"
  :badExample="badReview"
  whyItFails="Tokens spread too thin across too many files. Classic attention dilution."
  :fixExample="goodReview"
/>

<!--
The anti-pattern is passing all forty files in a single prompt. It looks efficient — one call, one response, done. It produces the attention-dilution failure mode from slide two. The replacement is per-file locally plus one cross-file pass. Two or more API calls, but each call is well-scoped, the findings are higher quality, and the whole review actually ships. Sample Q12's distractors include "use a larger context window model" and "split the PR into smaller submissions" — both wrong, because they don't fix the underlying prompt-shape problem.
-->

---

<CalloutBox variant="tip" title="On the exam — both passes, not just one">
  <p>Stem: <em>&ldquo;large reviews miss issues&rdquo;</em> or <em>&ldquo;inconsistent results across files&rdquo;</em> → <strong>multi-pass</strong>.</p>
  <p>Critically — <strong>both passes</strong>, not just one.</p>
  <p>If a distractor says <em>&ldquo;only per-file review&rdquo;</em> or <em>&ldquo;only cross-file review,&rdquo;</em> that's the trap. Per-file misses integration. Cross-file misses local.</p>
  <p>Sample Q12's correct answer lists both passes explicitly.</p>
</CalloutBox>

<!--
On the exam, when the stem says "large reviews miss issues" or "inconsistent results across files," the right answer is multi-pass. And critically — both passes, not just one. If a distractor says "only per-file review" or "only cross-file review," that's the trap. Per-file misses integration issues. Cross-file misses local issues. You need both. Sample Q12's correct answer lists both passes explicitly. Almost-right is the whole trap — one pass is plausible in a different context but not here.
-->

---

<ClosingSlide nextLecture="Section 7 — Domain 5 — Context Management & Reliability (15%)" />

<!--
That closes Domain 4. Carry this forward: split large reviews into per-file for local and one cross-file for integration — both passes, not just one. And remember the thread that ran through Domain 4 — categorical criteria over confidence adjectives, few-shots for ambiguity, tool_use for reliable structure, batch API for non-blocking workloads, multi-instance for bias-free review. Twenty percent of the exam, high-value-per-study-hour. Next up is Section 7 — Domain 5, Context Management and Reliability. It's the smallest domain at fifteen percent, but it has a higher value-per-study-hour than its weight suggests. Don't skip it because it's small. See you there.
-->
