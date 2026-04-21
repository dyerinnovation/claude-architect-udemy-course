---
theme: default
title: "Lecture 6.1: Explicit Criteria vs Vague Instructions"
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
const categoricalPattern = [
  { label: 'Name the category', detail: 'Not "serious" — "auth bypass", "SQL injection", a specific class of issue.' },
  { label: 'Name what qualifies', detail: 'The exact behavior that makes a finding in this category real.' },
  { label: 'Name what disqualifies', detail: 'The configurations or annotations that make it a non-issue.' },
  { label: 'Anchor with examples', detail: 'One qualifying example and one disqualifying example, in code.' },
]

const reviewPromptCode = `Flag findings in these categories:

- Bugs that cause incorrect behavior
- Security vulnerabilities that allow unauthorized access

Skip:

- Minor style preferences
- Local-pattern deviations that match the surrounding file
- Subjective naming choices`

const badConfidence = `# Bad — filters a fog
findings = [f for f in all_findings if f.confidence > 0.8]`

const goodCategorical = `# Good — define what qualifies, specifically
# prompt:
# Flag 'auth bypass' only when a request path bypasses
# auth middleware AND accesses user data. Do not flag
# routes explicitly marked public in router config.`
</script>

<CoverSlide
  title="Explicit Criteria vs Vague Instructions"
  subtitle="Why calibration happens at the category level — not the adjective level."
  eyebrow="Domain 4 · Lecture 6.1"
  :stats="['Section 6', '15 lectures', 'Domain 4 · 20%', 'Scenarios 5 & 6']"
/>

<!--
Welcome to Domain 4. This is your twenty-percent domain — tied for second by weight with Domain 3, and over the next fifteen lectures we cover prompt engineering, structured output, batch processing, and multi-instance review. This lecture is the foundation for all of it. We start with the difference between vague prompts and explicit prompts, because that single distinction decides whether your precision metric moves.
-->

---

<BigQuote
  lead="Domain 4 · Lecture 6.1"
  quote="&ldquo;Be conservative&rdquo; doesn't move precision. It's an adjective, not a rule."
  attribution="The vague-instruction trap — named and defused"
/>

<!--
Here's the thesis, stated once, clearly. "Be conservative" doesn't move precision. It's an adjective, not a rule. If you tell Claude to "only report high-confidence findings," you haven't changed what counts as high-confidence in the model's head. You've added a vibe, not a threshold. Almost-right is the whole trap of this exam, and this is one of its favorite flavors — the distractor that looks like a precision tuning knob but is actually just a mood setting.
-->

---

<TwoColSlide
  eyebrow="Side-by-side"
  title="Vague vs Explicit — the same job, different results"
  leftLabel="Vague"
  rightLabel="Explicit"
>
  <template #left>
    <p><strong>"Check that comments are accurate."</strong></p>
    <p>Tells Claude to check. Doesn't tell Claude what counts as a finding.</p>
    <p>Produces inconsistent output you can't ship to developers.</p>
  </template>
  <template #right>
    <p><strong>"Flag comments only when the claimed behavior contradicts the actual code behavior."</strong></p>
    <p>Tells Claude exactly what qualifies as a finding.</p>
    <p>Produces a review you <em>can</em> ship.</p>
  </template>
</TwoColSlide>

<!--
Let me put the two side by side. Vague: "Check that comments are accurate." Explicit: "Flag comments only when the claimed behavior contradicts the actual code behavior." Read those again. The first tells Claude to check. The second tells Claude exactly what qualifies as a finding. One produces inconsistent output, the other produces a review you can ship to developers. The exam guide calls this out by name under Task 4.1 — memorize the contrast.
-->

---

<ConceptHero
  leadLine="The mental move: stop thinking in adjectives, start thinking in categories."
  concept="Adjectives aren't categories"
  supportLine="&ldquo;Only high-confidence&rdquo; doesn't change what counts as high confidence. The model keeps its own calibration — you haven't changed it."
/>

<!--
The mental move is to stop thinking about adjectives and start thinking about categories. When you write "only high-confidence," Claude keeps its own internal calibration — you haven't changed it. You've asked a model that was already doing its best to do its best a little more. That's not a signal. The thing that matters is naming the category. What counts as a finding? What disqualifies something from being a finding? Those are questions prose can answer. "Be conservative" can't.
-->

---

<BulletReveal
  eyebrow="The replacement pattern"
  title="Categorical criteria, in four steps"
  :bullets="categoricalPattern"
/>

<!--
Here's the replacement pattern. Four steps. Name the category. Name what qualifies. Name what disqualifies. Anchor with examples. So instead of "be conservative on security," you write: "Flag findings in the category 'auth bypass' when a request path bypasses the auth middleware and accesses user data. Do not flag when the route is explicitly marked public in the router config. Qualifying example: a new GET handler under /api/admin that doesn't call requireAdmin. Disqualifying example: a new handler under /public/ that doesn't call requireAdmin." That is an instruction Claude can execute consistently.
-->

---

<CodeBlockSlide
  eyebrow="From principle to prompt"
  title="Explicit review criteria in practice"
  lang="text"
  :code="reviewPromptCode"
  annotation="Three explicit categorical rules. A vague version would have said 'review this code carefully.' The difference is not tone — it's whether the model has decision criteria."
/>

<!--
At the prompt level, your system prompt reads: "Flag bugs that cause incorrect behavior or security vulnerabilities that allow unauthorized access. Skip minor style preferences, local-pattern deviations that match the surrounding file, and subjective naming choices." Three explicit categorical rules. A vague version would have said "review this code carefully." The difference is not tone. The difference is whether the model has decision criteria.
-->

---

<BigNumber
  eyebrow="False-positive cost"
  number="1"
  unit=" high-FP category"
  caption="A single bad category erodes trust in the good ones."
  detail="Developers don't mentally compartmentalize — they mute the whole bot. Fix or temporarily disable the noisy category; don't let it poison the rest."
  accent="var(--clay-500)"
/>

<!--
Now the cost side. A single bad category erodes trust in the good ones. If one review category throws false positives at eighty percent, developers don't mentally compartmentalize. They mute the whole bot. You lose the signal from the accurate categories too. This is a real production failure mode, and the exam tests it. The move is to fix or temporarily disable the noisy category — don't leave it running and let it poison the rest.
-->

---

<AntiPatternSlide
  title="Don't add confidence thresholds over vague criteria"
  lang="text"
  :badExample="badConfidence"
  whyItFails="Numeric thresholds sound rigorous, but if the underlying criteria are vague, the confidence score is vague too."
  :fixExample="goodCategorical"
/>

<!--
Here's the anti-pattern you'll see on the exam. The bad answer reads: "Filter findings to confidence greater than zero-point-eight." The good answer reads: "Define what qualifies as a finding, specifically, with examples per category." The anti-pattern looks technical. Numeric thresholds sound rigorous. But if the underlying criteria are vague, the confidence score is vague too — you're filtering a fog. Categorical criteria change what the model considers a finding in the first place. That's the real lever.
-->

---

<CalloutBox variant="tip" title="On the exam">
  <p>Scenario 5 — Claude Code for CI/CD — is where this lecture lives or dies. The stem usually frames it as <em>&ldquo;how do we reduce false positives in automated review?&rdquo;</em></p>
  <p>The distractor is almost always confidence-based filtering with appealing numbers. The correct answer is <strong>explicit categorical criteria with examples</strong>. Remember the six-pick-four: you don't know whether Scenario 5 lands in your four, so skipping it isn't an option.</p>
</CalloutBox>

<!--
On the exam, Scenario 5 — Claude Code for CI/CD — is where this lecture lives or dies. The question usually frames it as "how do we reduce false positives in automated review?" The distractor is almost always confidence-based filtering with appealing numbers. The correct answer is explicit categorical criteria with examples. Remember the six-pick-four: you don't know whether Scenario 5 will appear in your four, so skipping it isn't an option.
-->

---

<ClosingSlide nextLecture="6.2 — Designing Review Prompts That Reduce False Positives" />

<!--
One sentence to carry forward. Categorical criteria beat confidence adjectives every time — name the category, name what qualifies, name what disqualifies, anchor with examples. Next lecture, 6.2, we take this principle into a full review prompt with severity tiers — CRITICAL, HIGH, MEDIUM, LOW — and I'll show you the trust-recovery pattern when a category has already gone noisy in production. See you there.
-->
