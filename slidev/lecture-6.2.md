---
theme: default
title: "Lecture 6.2: Review Prompts That Reduce False Positives"
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
const severityCode = `CRITICAL
  Reference: SQL-injection via unparameterized query.
  Also: auth bypass, data leakage.

HIGH
  Reference: off-by-one in pagination causing wrong page.
  Also: logic bugs with incorrect user-visible behavior.

MEDIUM
  Reference: unhandled JSON parse error on user input.
  Also: missing null-checks in realistic-null paths.

LOW
  Readability or maintainability issues.`

const promptSkeleton = `Review the diff. Flag findings ONLY in these severity tiers:

CRITICAL — reference: SQL-injection via unparameterized query
HIGH     — reference: off-by-one in pagination (wrong page)
MEDIUM   — reference: unhandled JSON parse error on user input
LOW      — disabled

Skip rules:
- Do not flag minor style preferences
- Do not flag pattern deviations that match the surrounding file
- Do not flag naming choices

Output each finding with: severity, file path, line, one-sentence explanation.`

const skipList = [
  { label: 'Minor style preferences', detail: 'Tabs vs spaces, brace placement, trailing commas — not review findings.' },
  { label: 'Local-pattern deviations that match the surrounding file', detail: 'If the file uses snake_case and the new code uses snake_case, don\u2019t flag it even if the rest of the repo is camelCase.' },
  { label: 'Subjective naming', detail: 'getThing vs fetchThing vs loadThing — opinion, not finding.' },
]
</script>

<CoverSlide
  title="Review Prompts That Reduce False Positives"
  subtitle="Severity tiers, concrete examples per tier, and the trust-recovery move."
  eyebrow="Domain 4 · Lecture 6.2"
  :stats="['Section 6', 'Scenario 5', 'Domain 4 · 20%', '8 min']"
/>

<!--
This lecture takes the categorical-criteria principle from 6.1 and operationalizes it into a full review prompt. Severity tiers with concrete examples, a skip list, and the trust-recovery move for when a category has already gone noisy. If your CI/CD review bot gets muted by developers, this is the lecture that teaches you how to prevent it — and how to rebuild from the rubble if it's already happened.
-->

---

<ConceptHero
  leadLine="Trust economics — one noisy category poisons the rest"
  concept="One bad category kills the bot"
  supportLine="Developers ignore reviews that cry wolf. One noisy pattern firing three times a day erases the goodwill from twenty accurate findings a week."
  accent="var(--clay-500)"
/>

<!--
Here's the economics. Developers ignore reviews that cry wolf. One bad category can poison the whole review. And the damage isn't proportional — one noisy pattern that fires three times a day erases the goodwill from twenty accurate findings a week. Once the bot is muted, your good categories are invisible too. That's the asymmetric cost you're designing against. The thing that matters here is building a review your developers don't resent.
-->

---

<CodeBlockSlide
  eyebrow="Severity tiers"
  title="Explicit severity with concrete examples per tier"
  lang="text"
  :code="severityCode"
  annotation="Each tier gets at least one concrete code example in your prompt. Not 'security issues are CRITICAL,' but 'SQL-injection is the CRITICAL reference.'"
/>

<!--
The replacement for vague reviews is explicit severity. Four tiers. CRITICAL — SQL injection, auth bypass, data leakage. HIGH — logic bugs that cause incorrect user-visible behavior. MEDIUM — unhandled error cases, missing null checks in paths that could realistically hit null. LOW — readability or maintainability issues. Each tier gets at least one concrete code example in your prompt. Not "security issues are CRITICAL," but "SQL-injection via unparameterized query is the reference severity-CRITICAL finding." Anchor the tier to real code.
-->

---

<CalloutBox variant="tip" title="Concrete beats relative">
  <p>Claude has no relative frame for your codebase. &ldquo;Serious&rdquo; to you might be &ldquo;routine&rdquo; elsewhere.</p>
  <p>When you write <em>&ldquo;SQL-injection via unparameterized query is the CRITICAL reference,&rdquo;</em> you give the model a <strong>yardstick</strong>. Anything worse than SQL-injection is CRITICAL. Anything less bad than SQL-injection but worse than a missing null-check is HIGH. That's a working definition.</p>
</CalloutBox>

<!--
The reason examples work where adjectives fail: Claude has no relative frame for your codebase. "Serious" to you might be "routine" somewhere else. When you write "SQL-injection via unparameterized query is the CRITICAL reference," you give the model a yardstick. Anything you'd explain to a junior developer as "this is worse than SQL-injection" is CRITICAL. Anything you'd explain as "this is less bad than SQL-injection but worse than a missing null-check" is HIGH. That's a working definition.
-->

---

<CalloutBox variant="warn" title="Trust recovery — the pause-and-fix pattern">
  <p>If a category is already noisy in production — say 70% false positive — <strong>disable it temporarily</strong>.</p>
  <p>Don't leave it running while you iterate. Rebuild trust on the accurate categories first. Ship the fixed prompt behind a flag, validate on historical PRs, then reinstate the category.</p>
  <p>Sequence: <strong>disable → fix offline → validate → reinstate</strong>. The exam guide calls this out under Task 4.1 — memorize the word &ldquo;temporarily.&rdquo;</p>
</CalloutBox>

<!--
Now the recovery pattern. If a category is already noisy in production — say it's throwing false positives at seventy percent — disable it temporarily. Don't leave it running while you iterate on the prompt. Rebuild trust on the categories that are accurate. Ship the fixed prompt behind a flag, validate on historical PRs, then reinstate the category. This is the sequence: disable, fix offline, validate, reinstate. The exam guide calls this out explicitly under Task 4.1 — memorize the word "temporarily."
-->

---

<CodeBlockSlide
  eyebrow="The shape of a working review prompt"
  title="Severity criteria + skip rules + output contract"
  lang="text"
  :code="promptSkeleton"
  annotation="That prompt has shape, examples, and guardrails. You can read its behavior from the prompt alone."
/>

<!--
Here's the shape of a prompt that works. "Review the diff. Flag findings only in these severity tiers: CRITICAL — reference example: SQL-injection via unparameterized query. HIGH — reference example: off-by-one in pagination causing wrong page. MEDIUM — reference example: unhandled JSON parse error on user input. LOW — disabled. Skip rules: do not flag minor style preferences, do not flag pattern deviations if they match the surrounding file, do not flag naming choices. Output each finding with severity, file path, line, and a one-sentence explanation." That prompt has shape, examples, and guardrails. You can read its behavior from the prompt alone.
-->

---

<BulletReveal
  eyebrow="What to skip"
  title="The three canonical skips — state them in the prompt"
  :bullets="skipList"
/>

<!--
The skip list deserves its own slide because most teams forget it. Three canonical skips: minor style preferences, local-pattern deviations when the deviation matches the surrounding file, and subjective naming. If the file already uses snake_case and the new code uses snake_case too, that's not a finding — even if the rest of the repo uses camelCase. Local consistency wins. Tell Claude this explicitly in the skip list, or it will keep finding "issues" that aren't.
-->

---

<CalloutBox variant="tip" title="On the exam — confidence filtering is the trap">
  <p>The distractor is almost always confidence-based filtering. <code>Filter findings where confidence &gt; 0.8</code>. Looks rigorous. Wrong.</p>
  <p>If the stem says <em>&ldquo;developers are dismissing too many findings&rdquo;</em> or <em>&ldquo;the bot is getting muted,&rdquo;</em> the answer is <strong>categorical severity with examples</strong> — not a confidence knob. Almost-right is plausible in a different context — not this one.</p>
</CalloutBox>

<!--
On the exam, the distractor here is almost always confidence-based filtering. "Filter findings where confidence > 0.8." Looks rigorous. Wrong. The right answer is explicit severity criteria with concrete examples per tier. If the scenario stem mentions "developers are dismissing too many findings" or "the bot is getting muted," the answer is categorical severity — not a confidence knob. This is one of the almost-right traps — confidence filtering is plausible in a different context, but not this one.
-->

---

<CalloutBox variant="tip" title="Continuity — Scenario 5's whole reliability story">
  <p>A fast review is useless if developers mute it. You'll see this framing again in <strong>6.10</strong> — the <code>detected_pattern</code> field for systematic dismissal analysis — and again in <strong>6.14</strong> for multi-instance review. This lecture is the bedrock for both.</p>
</CalloutBox>

<!--
Scenario 5 — Claude Code for CI/CD — lives and dies on this. A fast review is useless if developers mute it. You'll see this framing again in 6.10 when we add the detected_pattern field for systematic dismissal analysis, and again in 6.14 when we talk about multi-instance review — which is how you catch the findings your single-pass review misses. This lecture is the bedrock for all of those.
-->

---

<ClosingSlide nextLecture="6.3 — Few-Shot Prompting: When and How to Use It" />

<!--
Carry this forward: severity tiers with concrete code examples beat confidence filtering every time, and if a category is already noisy, disable it while you fix it — don't let it poison the rest. Next lecture, 6.3, we move to few-shot prompting: when prose alone produces inconsistent output, examples fix it. I'll cover the two-to-four rule, when to reach for few-shots, and — just as important — when not to. See you there.
-->
