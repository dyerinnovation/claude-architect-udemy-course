---
theme: default
title: "Lecture 6.14: Multi-Instance Review Architecture"
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
const architectureSteps = [
  { label: 'Instance A generates code', sublabel: 'Full generation session — drafts, reasoning, revisions' },
  { label: 'Output committed', sublabel: 'Written to a file, a PR, a shared artifact' },
  { label: 'Instance B (fresh session)', sublabel: 'Receives code + CLAUDE.md + criteria — not A\u2019s reasoning' },
  { label: 'B reviews without bias', sublabel: 'No generator context to defer to. Willing to disagree.' },
]

const badSelfReview = `# Single session prompt:
Write the function.
Then review your work and flag issues.

# Feels clever — cheap, in-session, no extra infrastructure.
# Doesn't work.`

const goodSelfReview = `# Two API calls, two sessions:

# Session A: generate code
code = claude.generate(task, context)
commit(code)

# Session B: fresh — no A context
review = claude.review(code, claude_md, criteria)`
</script>

<CoverSlide
  title="Multi-Instance Review"
  subtitle="Two instances, two contexts. Fresh-session Claude catches what self-review can't."
  eyebrow="Domain 4 · Lecture 6.14"
  :stats="['Section 6', 'Scenario 5', 'Domain 4 · 20%', '8 min']"
/>

<!--
Penultimate lecture in Domain 4. Eight minutes. This one covers a review architecture pattern that the exam tests directly — a second, independent Claude instance reviewing what the first one generated. The phrase to memorize is "reasoning context bias," and the correct answer across multiple exam questions is that a fresh instance catches what a self-review can't.
-->

---

<BigQuote
  lead="Domain 4 · Lecture 6.14"
  quote="The model retains reasoning context from generation. It is less likely to question decisions it already justified."
  attribution="Reasoning-context bias — the phrase to memorize"
/>

<!--
Here's the thesis. The model retains reasoning context from generation. It is less likely to question decisions it already justified. That's the bias. When you ask the same session to "now review your work," it's reviewing with the justifications already in context — and models, like humans, don't readily contradict their own recent reasoning. The self-review produces thumbs-up on bad code because the model already talked itself into the code being okay.
-->

---

<ConceptHero
  leadLine="The fix is architectural, not prompt-level."
  concept="Two instances, two contexts"
  supportLine="Instance A generates. Instance B is a fresh session — zero knowledge of how the code got written. B reviews cold, with no self-justification bias."
/>

<!--
The fix is architectural, not prompt-level. Two instances. Two separate contexts. Instance A generates the code — runs the whole generation session with all its reasoning, drafts, and revisions. Instance B is a fresh session — zero knowledge of how the code got written. Instance B reviews the code cold. Fresh context, no self-justification bias, willing to disagree with decisions it wasn't part of making. This is the anchor concept for multi-instance review.
-->

---

<FlowDiagram
  eyebrow="Architecture"
  title="Independent review — four steps"
  :steps="architectureSteps"
/>

<!--
Here's the architecture in four steps. One: Instance A generates the code. Two: the output is committed — written to a file, a PR, a shared artifact. Three: Instance B, a fresh Claude session, receives the code plus the project's CLAUDE.md and review criteria — but not Instance A's reasoning chain. Four: Instance B reviews without the generator's context. The separation is physical — two API calls in two different sessions — not just a prompt instruction to "pretend you didn't write this."
-->

---

<CalloutBox variant="warn" title="vs extended thinking — different tool, different problem">
  <p>Extended thinking — where the model produces a longer reasoning trace before its final output — <strong>does not</strong> address self-justification bias.</p>
  <p>Extended thinking still shares context with the generation. Same session, longer internal monologue. More reasoning <em>inside</em> the same context <strong>reinforces</strong> existing conclusions — it doesn't question them.</p>
  <p>If the bias is self-justification, more thinking in the same session makes it worse. Multi-instance is the right fix. Extended thinking is a different tool for a different problem.</p>
</CalloutBox>

<!--
Here's the trap. Extended thinking — where the model produces a longer reasoning trace before its final output — does not address self-justification bias. Extended thinking still shares context with the generation. It's the same session, just with a longer internal monologue. More reasoning inside the same context reinforces existing conclusions; it doesn't question them. If the bias is self-justification, more thinking in the same session makes it worse, not better. Multi-instance is the right fix. Extended thinking is a different tool for a different problem.
-->

---

<CalloutBox variant="tip" title="Confidence self-report — optional overlay">
  <p>Have reviewer <strong>Instance B</strong> output per-finding confidence alongside each finding.</p>
  <p>High confidence → developer directly. Low confidence → human review.</p>
  <p>Exam guide Task 4.6: <em>&ldquo;running verification passes where the model self-reports confidence alongside each finding.&rdquo;</em></p>
  <p>One schema field, dramatic improvement in routing quality. Deeper in Section 7.</p>
</CalloutBox>

<!--
An optional overlay for more calibrated routing. Have the reviewer Instance B output per-finding confidence alongside each finding. High-confidence findings go to the developer directly. Low-confidence findings route to human review. This is Task 4.6 in the exam guide — "running verification passes where the model self-reports confidence alongside each finding." It adds one field to the output schema and it dramatically improves routing quality. We'll see a deeper version of confidence-based routing in Section 7.
-->

---

<CalloutBox variant="tip" title="Callback to 5.14 — same principle, different layer">
  <p>Section <strong>5.14</strong> covered <em>session context isolation for independent code review</em> — the fresh-session-in-CI pattern for Claude Code.</p>
  <p>This lecture is the <strong>architectural generalization</strong> of that same principle.</p>
  <p>Domain 3 applies it inside the Claude Code workflow. Domain 4 applies it at the API layer with two Claude instances. The exam can test either.</p>
  <p>Underlying concept — <em>reasoning-context bias</em> — is the same.</p>
</CalloutBox>

<!--
Callback to Section 5. Lecture 5.14 covered "session context isolation for independent code review" — the fresh-session-in-CI pattern for Claude Code. This lecture is the architectural generalization of that same principle. Domain 3 applied it inside the Claude Code workflow; Domain 4 applies it at the API layer with two Claude instances. Same principle, different layer. The exam can test either, and the underlying concept is reasoning-context bias.
-->

---

<AntiPatternSlide
  title="Don't append 'now critique yourself'"
  lang="text"
  :badExample="badSelfReview"
  whyItFails="The generator's reasoning context is still loaded — the 'review' rubber-stamps the decisions the model already made."
  :fixExample="goodSelfReview"
/>

<!--
The anti-pattern is appending "now review your work" to the generation prompt. It feels clever — cheap, in-session, no extra infrastructure. It doesn't work. The generator's reasoning context is still loaded, so the "review" just rubber-stamps the decisions the model already made. The replacement is a separate API call in a separate session with no generator reasoning context. Two calls, two contexts, actual independence.
-->

---

<CalloutBox variant="tip" title="On the exam — the exact phrase">
  <p>Stem: <em>&ldquo;why is an independent review instance more effective than self-review?&rdquo;</em></p>
  <p>Correct answer uses the phrase <strong>reasoning context bias</strong> (or equivalent) — the generator retains context from its own reasoning and is less likely to question prior decisions.</p>
  <p>Distractors: <em>&ldquo;the independent instance is a different model,&rdquo;</em> <em>&ldquo;extended thinking achieves the same result.&rdquo;</em> Both wrong. The right answer is about <strong>context separation</strong>.</p>
</CalloutBox>

<!--
On the exam, the question often reads: "why is an independent review instance more effective than self-review?" The correct answer uses the phrase "reasoning context bias" or equivalent — the generator retains context from its own reasoning and is less likely to question prior decisions. Memorize that phrasing. Distractors will suggest "the independent instance is a different model" or "extended thinking achieves the same result" — both wrong. The right answer is about context separation.
-->

---

<ClosingSlide nextLecture="6.15 — Multi-Pass Review: Per-File + Cross-File Integration Pass" />

<!--
Carry this forward: self-review fails because of reasoning-context bias, and the fix is architectural — two instances, two contexts, separated by a clean API boundary. Extended thinking doesn't address this. Next lecture, 6.15, we close Domain 4 with the other half of review architecture: multi-pass review. Per-file for local issues, plus one cross-file integration pass. See you there.
-->
