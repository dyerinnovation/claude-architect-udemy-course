---
theme: default
title: "Section 6: Domain 4 - Prompt Engineering & Structured Output"
info: |
  Claude Certified Architect – Foundations
  Section 6: Domain 4 - Prompt Engineering & Structured Output (20%)
highlighter: shiki
transition: slide-left
mdc: true
canvasWidth: 1920
aspectRatio: 16/9
---

<style>
@import './design-system.css';
</style>

<!-- LECTURE 6.1 — Explicit Criteria vs Vague Instructions -->

<CoverSlide
  title="Explicit Criteria vs Vague Instructions"
  subtitle="Why calibration happens at the category level -- not the adjective level."
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
  attribution="The vague-instruction trap -- named and defused"
/>

<!--
Here's the thesis, stated once, clearly. "Be conservative" doesn't move precision. It's an adjective, not a rule. If you tell Claude to "only report high-confidence findings," you haven't changed what counts as high-confidence in the model's head. You've added a vibe, not a threshold. Almost-right is the whole trap of this exam, and this is one of its favorite flavors — the distractor that looks like a precision tuning knob but is actually just a mood setting.
-->

---

<TwoColSlide
  eyebrow="Side-by-side"
  title="Vague vs Explicit -- the same job, different results"
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
  supportLine="&ldquo;Only high-confidence&rdquo; doesn't change what counts as high confidence. The model keeps its own calibration -- you haven't changed it."
/>

<!--
The mental move is to stop thinking about adjectives and start thinking about categories. When you write "only high-confidence," Claude keeps its own internal calibration — you haven't changed it. You've asked a model that was already doing its best to do its best a little more. That's not a signal. The thing that matters is naming the category. What counts as a finding? What disqualifies something from being a finding? Those are questions prose can answer. "Be conservative" can't.
-->

---

<script setup>
const categoricalPattern = [
  { label: 'Name the category', detail: 'Not "serious" -- "auth bypass", "SQL injection", a specific class of issue.' },
  { label: 'Name what qualifies', detail: 'The exact behavior that makes a finding in this category real.' },
  { label: 'Name what disqualifies', detail: 'The configurations or annotations that make it a non-issue.' },
  { label: 'Anchor with examples', detail: 'One qualifying example and one disqualifying example, in code.' },
]
</script>

<BulletReveal
  eyebrow="The replacement pattern"
  title="Categorical criteria, in four steps"
  :bullets="categoricalPattern"
/>

<!--
Here's the replacement pattern. Four steps. Name the category. Name what qualifies. Name what disqualifies. Anchor with examples. So instead of "be conservative on security," you write: "Flag findings in the category 'auth bypass' when a request path bypasses the auth middleware and accesses user data. Do not flag when the route is explicitly marked public in the router config. Qualifying example: a new GET handler under /api/admin that doesn't call requireAdmin. Disqualifying example: a new handler under /public/ that doesn't call requireAdmin." That is an instruction Claude can execute consistently.
-->

---

<script setup>
const reviewPromptCode = `Flag findings in these categories:

- Bugs that cause incorrect behavior
- Security vulnerabilities that allow unauthorized access

Skip:

- Minor style preferences
- Local-pattern deviations that match the surrounding file
- Subjective naming choices`
</script>

<CodeBlockSlide
  eyebrow="From principle to prompt"
  title="Explicit review criteria in practice"
  lang="text"
  :code="reviewPromptCode"
  annotation="Three explicit categorical rules. A vague version would have said 'review this code carefully.' The difference is not tone -- it's whether the model has decision criteria."
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
  detail="Developers don't mentally compartmentalize -- they mute the whole bot. Fix or temporarily disable the noisy category; don't let it poison the rest."
  accent="var(--clay-500)"
/>

<!--
Now the cost side. A single bad category erodes trust in the good ones. If one review category throws false positives at eighty percent, developers don't mentally compartmentalize. They mute the whole bot. You lose the signal from the accurate categories too. This is a real production failure mode, and the exam tests it. The move is to fix or temporarily disable the noisy category — don't leave it running and let it poison the rest.
-->

---

<script setup>
const badConfidence = `# Bad -- filters a fog
findings = [f for f in all_findings if f.confidence > 0.8]`

const goodCategorical = `# Good -- define what qualifies, specifically
# prompt:
# Flag 'auth bypass' only when a request path bypasses
# auth middleware AND accesses user data. Do not flag
# routes explicitly marked public in router config.`
</script>

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
  <v-clicks>
    <p>Scenario 5 -- Claude Code for CI/CD -- is where this lecture lives or dies. The stem usually frames it as <em>&ldquo;how do we reduce false positives in automated review?&rdquo;</em></p>
    <p>The distractor is almost always confidence-based filtering with appealing numbers. The correct answer is <strong>explicit categorical criteria with examples</strong>. Remember the six-pick-four: you don't know whether Scenario 5 lands in your four, so skipping it isn't an option.</p>
  </v-clicks>
</CalloutBox>

<!--
On the exam, Scenario 5 — Claude Code for CI/CD — is where this lecture lives or dies. The question usually frames it as "how do we reduce false positives in automated review?" The distractor is almost always confidence-based filtering with appealing numbers. The correct answer is explicit categorical criteria with examples. Remember the six-pick-four: you don't know whether Scenario 5 will appear in your four, so skipping it isn't an option.
-->

---

<ClosingSlide nextLecture="6.2 -- Designing Review Prompts That Reduce False Positives" />

<!--
One sentence to carry forward. Categorical criteria beat confidence adjectives every time — name the category, name what qualifies, name what disqualifies, anchor with examples. Next lecture, 6.2, we take this principle into a full review prompt with severity tiers — CRITICAL, HIGH, MEDIUM, LOW — and I'll show you the trust-recovery pattern when a category has already gone noisy in production. See you there.
-->

---

<!-- LECTURE 6.2 — Review Prompts That Reduce False Positives -->

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
  leadLine="Trust economics -- one noisy category poisons the rest"
  concept="One bad category kills the bot"
  supportLine="Developers ignore reviews that cry wolf. One noisy pattern firing three times a day erases the goodwill from twenty accurate findings a week."
  accent="var(--clay-500)"
/>

<!--
Here's the economics. Developers ignore reviews that cry wolf. One bad category can poison the whole review. And the damage isn't proportional — one noisy pattern that fires three times a day erases the goodwill from twenty accurate findings a week. Once the bot is muted, your good categories are invisible too. That's the asymmetric cost you're designing against. The thing that matters here is building a review your developers don't resent.
-->

---

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
</script>

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
  <v-clicks>
    <p>Claude has no relative frame for your codebase. &ldquo;Serious&rdquo; to you might be &ldquo;routine&rdquo; elsewhere.</p>
    <p>When you write <em>&ldquo;SQL-injection via unparameterized query is the CRITICAL reference,&rdquo;</em> you give the model a <strong>yardstick</strong>. Anything worse than SQL-injection is CRITICAL. Anything less bad than SQL-injection but worse than a missing null-check is HIGH. That's a working definition.</p>
  </v-clicks>
</CalloutBox>

<!--
The reason examples work where adjectives fail: Claude has no relative frame for your codebase. "Serious" to you might be "routine" somewhere else. When you write "SQL-injection via unparameterized query is the CRITICAL reference," you give the model a yardstick. Anything you'd explain to a junior developer as "this is worse than SQL-injection" is CRITICAL. Anything you'd explain as "this is less bad than SQL-injection but worse than a missing null-check" is HIGH. That's a working definition.
-->

---

<CalloutBox variant="warn" title="Trust recovery -- the pause-and-fix pattern">
  <v-clicks>
    <p>If a category is already noisy in production -- say 70% false positive -- <strong>disable it temporarily</strong>.</p>
    <p>Don't leave it running while you iterate. Rebuild trust on the accurate categories first. Ship the fixed prompt behind a flag, validate on historical PRs, then reinstate the category.</p>
    <p>Sequence: <strong>disable -> fix offline -> validate -> reinstate</strong>. The exam guide calls this out under Task 4.1 -- memorize the word &ldquo;temporarily.&rdquo;</p>
  </v-clicks>
</CalloutBox>

<!--
Now the recovery pattern. If a category is already noisy in production — say it's throwing false positives at seventy percent — disable it temporarily. Don't leave it running while you iterate on the prompt. Rebuild trust on the categories that are accurate. Ship the fixed prompt behind a flag, validate on historical PRs, then reinstate the category. This is the sequence: disable, fix offline, validate, reinstate. The exam guide calls this out explicitly under Task 4.1 — memorize the word "temporarily."
-->

---

<script setup>
const promptSkeleton = `Review the diff. Flag findings ONLY in these severity tiers:

CRITICAL -- reference: SQL-injection via unparameterized query
HIGH     -- reference: off-by-one in pagination (wrong page)
MEDIUM   -- reference: unhandled JSON parse error on user input
LOW      -- disabled

Skip rules:
- Do not flag minor style preferences
- Do not flag pattern deviations that match the surrounding file
- Do not flag naming choices

Output each finding with: severity, file path, line, one-sentence explanation.`
</script>

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

<script setup>
const skipList = [
  { label: 'Minor style preferences', detail: 'Tabs vs spaces, brace placement, trailing commas -- not review findings.' },
  { label: 'Local-pattern deviations that match the surrounding file', detail: "If the file uses snake_case and the new code uses snake_case, don't flag it even if the rest of the repo is camelCase." },
  { label: 'Subjective naming', detail: 'getThing vs fetchThing vs loadThing -- opinion, not finding.' },
]
</script>

<BulletReveal
  eyebrow="What to skip"
  title="The three canonical skips -- state them in the prompt"
  :bullets="skipList"
/>

<!--
The skip list deserves its own slide because most teams forget it. Three canonical skips: minor style preferences, local-pattern deviations when the deviation matches the surrounding file, and subjective naming. If the file already uses snake_case and the new code uses snake_case too, that's not a finding — even if the rest of the repo uses camelCase. Local consistency wins. Tell Claude this explicitly in the skip list, or it will keep finding "issues" that aren't.
-->

---

<CalloutBox variant="tip" title="On the exam -- confidence filtering is the trap">
  <v-clicks>
    <p>The distractor is almost always confidence-based filtering. <code>Filter findings where confidence &gt; 0.8</code>. Looks rigorous. Wrong.</p>
    <p>If the stem says <em>&ldquo;developers are dismissing too many findings&rdquo;</em> or <em>&ldquo;the bot is getting muted,&rdquo;</em> the answer is <strong>categorical severity with examples</strong> -- not a confidence knob. Almost-right is plausible in a different context -- not this one.</p>
  </v-clicks>
</CalloutBox>

<!--
On the exam, the distractor here is almost always confidence-based filtering. "Filter findings where confidence > 0.8." Looks rigorous. Wrong. The right answer is explicit severity criteria with concrete examples per tier. If the scenario stem mentions "developers are dismissing too many findings" or "the bot is getting muted," the answer is categorical severity — not a confidence knob. This is one of the almost-right traps — confidence filtering is plausible in a different context, but not this one.
-->

---

<CalloutBox variant="tip" title="Continuity -- Scenario 5's whole reliability story">
  <p>A fast review is useless if developers mute it. You'll see this framing again in <strong>6.10</strong> -- the <code>detected_pattern</code> field for systematic dismissal analysis -- and again in <strong>6.14</strong> for multi-instance review. This lecture is the bedrock for both.</p>
</CalloutBox>

<!--
Scenario 5 — Claude Code for CI/CD — lives and dies on this. A fast review is useless if developers mute it. You'll see this framing again in 6.10 when we add the detected_pattern field for systematic dismissal analysis, and again in 6.14 when we talk about multi-instance review — which is how you catch the findings your single-pass review misses. This lecture is the bedrock for all of those.
-->

---

<ClosingSlide nextLecture="6.3 -- Few-Shot Prompting: When and How to Use It" />

<!--
Carry this forward: severity tiers with concrete code examples beat confidence filtering every time, and if a category is already noisy, disable it while you fix it — don't let it poison the rest. Next lecture, 6.3, we move to few-shot prompting: when prose alone produces inconsistent output, examples fix it. I'll cover the two-to-four rule, when to reach for few-shots, and — just as important — when not to. See you there.
-->

---

<!-- LECTURE 6.3 — Few-Shot Prompting: When and How -->

<CoverSlide
  title="Few-Shot Prompting: When and How"
  subtitle="When prose produces drift, examples produce consistency. Know the 2-4 rule."
  eyebrow="Domain 4 · Lecture 6.3"
  :stats="['Section 6', 'Scenarios 1, 5, 6', 'Domain 4 · 20%', '8 min']"
/>

<!--
This lecture is about one of the highest-leverage techniques in Domain 4: few-shot prompting. When prose alone produces inconsistent output, examples fix it. We'll cover when to reach for few-shots, the sweet spot for example count, what each example needs to contain, and — just as important — when not to use them. If you only take one technique from this domain into production, this is the one.
-->

---

<ConceptHero
  leadLine="Stop explaining. Start showing."
  concept="Examples > detailed instructions"
  supportLine="Claude generalizes from 2-4 examples better than it follows a paragraph of rules. When prose produces inconsistent output, examples produce consistent output."
/>

<!--
Here's the core claim. When prose produces inconsistent output, examples produce consistent output. Claude generalizes from two-to-four examples better than it follows a paragraph of rules. That's not a trick — it's how the model is trained. You write a three-paragraph instruction trying to cover every edge case, and you still get inconsistent output. You show two examples of what the output should look like, and suddenly the model locks on. The mental move is: stop explaining, start showing.
-->

---

<script setup>
const whenToUse = [
  { label: 'Ambiguous cases', detail: 'Same input could go two ways -- judgment is the discriminator.' },
  { label: 'Consistent format required', detail: 'Field names, order, structure must match across outputs.' },
  { label: 'Reducing hallucination in extraction', detail: "The model keeps inventing fields that aren't in the source." },
  { label: 'Teaching judgment, not rules', detail: "Cases you'd explain by example to a junior engineer." },
]
</script>

<BulletReveal
  eyebrow="When to reach for few-shots"
  title="Four moments that signal examples over prose"
  :bullets="whenToUse"
/>

<!--
Four moments to reach for few-shots. One: ambiguous cases where the same input could go two ways. Two: consistent format required — field names, order, structure. Three: reducing hallucination in extraction when the model keeps inventing fields. Four: teaching judgment rather than rules — cases where you yourself would explain by example to a junior engineer. If any of those describe your prompt today, few-shots are the right tool.
-->

---

<BigNumber
  eyebrow="The sweet spot"
  number="2-4"
  unit=" examples"
  caption="Too few doesn't generalize. Too many overfits and bloats tokens."
  detail="Memorize &ldquo;two to four&rdquo; the way you memorized 720 for the passing score. It's a named parameter the exam tests directly."
  accent="var(--sprout-500)"
/>

<!--
The sweet spot is two to four examples. Too few — one — and the model doesn't generalize; it matches the surface pattern of the single example. Too many — eight, twelve — and you get token bloat plus overfitting to incidental features. The exam guide calls this out by the exact number: two to four. Memorize "two to four" the way you memorized "seven twenty" for the passing score. It's a named parameter the exam tests directly.
-->

---

<script setup>
const reasoningExample = `Input:  timestamp="2025-01-03T09:30:00Z", customer_tz="America/Los_Angeles"

Reasoning: timestamp is UTC; customer context is PST; convert before presenting.

Output: "January 3, 2025 at 1:30 AM PST"`
</script>

<CodeBlockSlide
  eyebrow="Show reasoning, not just labels"
  title="Each example shows the &ldquo;why&rdquo; -- not just input -> output"
  lang="text"
  :code="reasoningExample"
  annotation="Q/A pairs aren't few-shot -- they're labeled pairs. The reasoning trace is what teaches. Consistent output requires consistent reasoning."
/>

<!--
Here's what most people get wrong. They write examples as Q-colon, A-colon. "Input: X. Output: Y." That's not a few-shot example; that's a labeled pair. The move is to include the reasoning. "Input: X. Because the timestamp is UTC but the customer context is PST, we need to convert. Output: Y." Now the model has a reasoning trace to imitate, not just an input-output mapping. Consistent output requires consistent reasoning, and reasoning has to be shown, not stated.
-->

---

<CalloutBox variant="tip" title="Few-shots lock the output shape">
  <v-clicks>
    <p>Few-shots do a second job beyond teaching judgment: they <strong>lock the output format</strong>.</p>
    <p>If your three examples all output a JSON object with fields in the same order, Claude produces that exact format on the fourth input. Field names, ordering, structure -- all contracted. The examples are the specification.</p>
    <p>That's why few-shots and <code>tool_use</code> schemas are both in Domain 4 -- two tools for the same output-consistency problem.</p>
  </v-clicks>
</CalloutBox>

<!--
Few-shots do a second job beyond teaching judgment: they lock the output format. If your three examples all output a JSON object with fields in the same order, Claude will produce that exact format on the fourth input. Field names, ordering, structure — all contracted. This is how you get consistent structure without writing a prose specification of the format. The examples are the specification. That's why few-shots and tool_use schemas are both in Domain 4 — they're two tools for the same output-consistency problem.
-->

---

<script setup>
const whenNot = [
  { label: 'Prose is already clear and consistent', detail: "Don't add examples where the instruction already lands." },
  { label: 'tool_use with a schema enforces structure', detail: 'The schema is stricter than examples. Use it.' },
  { label: 'Examples would overfit to incidental features', detail: 'Same customer name in every example = model latches onto it.' },
]
</script>

<BulletReveal
  eyebrow="When NOT to few-shot"
  title="The other half -- where examples muddy the water"
  :bullets="whenNot"
/>

<!--
Here's the other half. Don't few-shot when prose is already clear and consistent. Don't few-shot when tool_use with a JSON schema already enforces structure — the schema is stricter than examples. And don't few-shot when adding examples would teach overfitting instead of generalization — for instance, if all your examples happen to use the same customer name, the model might latch onto that. Know when examples help and when they muddy the water.
-->

---

<script setup>
const badFewShot = `# Five examples of well-formed JSON
# crammed into the prompt to "teach" JSON output
# -- probabilistic; malformed JSON still possible.`

const goodToolUse = `# Define a tool_use schema
tools = [{
  "name": "extract_invoice",
  "input_schema": {
    "type": "object",
    "required": ["invoice_number", "total_amount"],
    "properties": {...}
  }
}]`
</script>

<AntiPatternSlide
  title="Don't few-shot what should be a tool schema"
  lang="text"
  :badExample="badFewShot"
  whyItFails="Tool_use with a JSON schema eliminates syntax errors by construction. Few-shots are probabilistic."
  :fixExample="goodToolUse"
/>

<!--
The anti-pattern that shows up on the exam: using five examples of well-formed JSON in prose to enforce JSON output. That's what tool_use with a schema is for. Tool_use eliminates syntax errors by construction — covered in 6.5 — and few-shots are probabilistic. If the requirement is "JSON guarantees," define the tool_use schema. If the requirement is "ambiguous judgment about what to extract," use few-shots. Match the tool to the problem.
-->

---

<CalloutBox variant="tip" title="On the exam -- three matches to know cold">
  <v-clicks>
    <p><strong>&ldquo;Inconsistent format&rdquo;</strong> in the stem -> few-shots.</p>
    <p><strong>&ldquo;Need JSON guarantees&rdquo;</strong> -> tool_use.</p>
    <p><strong>&ldquo;Ambiguous cases&rdquo;</strong> or <strong>&ldquo;teach judgment&rdquo;</strong> -> few-shots.</p>
    <p>Read the stem carefully for the word <em>guarantees</em> versus <em>ambiguous</em>. Almost-right: tool_use is plausible whenever structure is mentioned -- but judgment ambiguity means few-shots.</p>
  </v-clicks>
</CalloutBox>

<!--
On the exam, know the three matches cold. "Inconsistent format" in the stem — few-shots. "Need JSON guarantees" in the stem — tool_use. "Ambiguous cases" or "teach judgment" in the stem — few-shots. Almost-right is the trap here: tool_use is plausible whenever structure is mentioned, but if the problem is judgment ambiguity rather than format guarantees, few-shots is the right answer. Read the stem carefully for the word "guarantees" versus "ambiguous."
-->

---

<ClosingSlide nextLecture="6.4 -- Crafting Few-Shot Examples for Ambiguous Scenarios" />

<!--
Carry this forward: few-shots produce consistency where prose produces drift, two to four examples is the named sweet spot, and each example must show reasoning — not just input and output. Next lecture, 6.4, we go deeper on crafting the examples themselves — how to pick edge cases instead of easy ones, how to handle null and "information absent," and why Scenario 6 extraction work depends on this. See you there.
-->

---

<!-- LECTURE 6.4 — Crafting Few-Shot Examples for Ambiguous Cases -->

<CoverSlide
  title="Crafting Few-Shot Examples for Ambiguous Cases"
  subtitle="Pick the edges, show the reasoning, include the null case."
  eyebrow="Domain 4 · Lecture 6.4"
  :stats="['Section 6', 'Scenarios 1 & 6', 'Domain 4 · 20%', '8 min']"
/>

<!--
In 6.3 we covered when and why to use few-shots. This lecture is how — specifically, how to pick the examples. The mistake most people make is picking easy cases. Easy cases teach the model nothing it couldn't already do. The leverage is in the edges: ambiguous scenarios, acceptable patterns that look suspicious, and the null case. If Scenario 6 — structured extraction — is in your four on exam day, this lecture is one of the ones you'll lean on.
-->

---

<ConceptHero
  leadLine="Easy examples teach nothing -- the model already gets the easy cases right."
  concept="Choose the edges, not the middle"
  supportLine="The ambiguous cases are what need the examples. Three examples of obvious refund requests wastes your token budget."
/>

<!--
Here's the rule. Choose the edges, not the middle. Easy examples teach nothing — the model already gets the easy cases right. The ambiguous cases are what need the examples. If you're building a support-agent prompt and your few-shots are three examples of obvious refund requests, you've wasted your token budget. The example that moves the needle is the one where the customer's request could go two ways. That's where judgment needs to be shown.
-->

---

<script setup>
const reasoningTrace = `Customer message:
"I've been charged twice for the same order and
 nobody's getting back to me."

Reasoning: customer hasn't explicitly asked for a human,
but the compound issue (double-charge + unresponsive
support) is policy-ambiguous.

Action: escalate with summary.`
</script>

<CodeBlockSlide
  eyebrow="Example with reasoning trace"
  title="Input -> reasoning -> output (not Q/A)"
  lang="text"
  :code="reasoningTrace"
  annotation="Not just input-output. Input, reasoning, output. The reasoning is what teaches."
/>

<!--
Every example gets a reasoning trace. Here's the shape. "Customer message: 'I've been charged twice for the same order and nobody's getting back to me.' Reasoning: the customer hasn't explicitly asked for a human, but the compound issue — double-charge plus unresponsive support — is policy-ambiguous. This is escalate. Action: escalate with summary." That's what a few-shot for Scenario 1 looks like. Not just input-output. Input, reasoning, output. The reasoning is what teaches.
-->

---

<TwoColSlide
  eyebrow="Code review discrimination"
  title="Acceptable pattern vs genuine issue -- teach the distinction"
  leftLabel="Acceptable pattern"
  rightLabel="Genuine issue"
>
  <template #left>
    <p><strong>Commented-out line of old logic</strong></p>
    <p>Reasoning: team uses commented-out references during migration; documented in project <code>CLAUDE.md</code>.</p>
    <p><em>Don't flag.</em></p>
  </template>
  <template #right>
    <p><strong>SQL query via string concatenation from user input</strong></p>
    <p>Reasoning: SQL-injection vulnerability regardless of project patterns.</p>
    <p><em>Flag as CRITICAL.</em></p>
  </template>
</TwoColSlide>

<!--
For code review — Scenario 5 — the high-leverage few-shots distinguish acceptable patterns from genuine issues. Example one: a function with a commented-out line of old logic. Reasoning: this is a local pattern; the team uses commented-out references during migration, documented in the project CLAUDE.md. Acceptable. Don't flag. Example two: a function with a SQL query built via string concatenation from user input. Reasoning: SQL-injection vulnerability regardless of project patterns. Flag as CRITICAL. Now the model has the discrimination. It can tell these apart on a new case.
-->

---

<CalloutBox variant="tip" title="Varied document format -- Scenario 6 extraction">
  <v-clicks>
    <p>Few-shots earn their keep when document formats vary.</p>
    <p>One example from a doc with <strong>inline citations</strong>. One from a doc with a <strong>bibliography section</strong>. One from a <strong>narrative-only</strong> doc with no explicit citations.</p>
    <p>Exam guide phrasing (Task 4.2): <em>&ldquo;varied document structures: inline citations vs bibliographies, methodology sections vs embedded details.&rdquo;</em></p>
  </v-clicks>
</CalloutBox>

<!--
For Scenario 6 — structured extraction — few-shots earn their keep when document formats vary. One example from a doc with inline citations. One from a doc with a bibliography section. One from a narrative-only doc with no explicit citations. The few-shots teach the model to extract from all three formats. This is the exam guide's exact phrasing — "varied document structures: inline citations vs bibliographies, methodology sections vs embedded details." Task 4.2 tests this directly.
-->

---

<script setup>
const scenarioMap = [
  { label: 'Scenario 1 -- customer support', detail: "Borderline escalation cases where the customer hasn't asked for a human but the compound situation requires one." },
  { label: 'Scenario 5 -- CI/CD review', detail: 'Severity borderlines where CRITICAL blurs into HIGH -- SQL-injection-adjacent cases.' },
  { label: 'Scenario 6 -- extraction', detail: 'Document format variants -- inline citations vs bibliographies, narrative vs tables.' },
]
</script>

<BulletReveal
  eyebrow="Per-scenario ambiguity surface"
  title="Map few-shot needs to the exam scenarios"
  :bullets="scenarioMap"
/>

<!--
Here's how the exam scenarios map to few-shot needs. Scenario 1 — customer support — borderline escalation cases. Scenario 5 — CI/CD review — severity borderlines where CRITICAL blurs into HIGH. Scenario 6 — extraction — document format variants. Each scenario has its own ambiguity surface, and each needs its own two-to-four examples. If you're prepping for the six-pick-four and Scenario 6 is weak for you, this is the exact drill — pick three document-format variants and write the few-shot examples.
-->

---

<script setup>
const badObvious = `# Three examples of clearly CRITICAL bugs
# -- SQL-injection, hardcoded secret, unencrypted API call
# (the model already recognizes these)`

const goodBorderline = `# Two examples of BORDERLINE cases
# Example A: sanitized-looking UI input where the regex
#   misses unicode corner cases.
# Example B: an ORM call that looks safe but builds raw
#   SQL via a helper you shipped last month.`
</script>

<AntiPatternSlide
  title="Don't few-shot the obvious"
  lang="text"
  :badExample="badObvious"
  whyItFails="Burns context on reinforcement the model doesn't need."
  :fixExample="goodBorderline"
/>

<!--
The anti-pattern that wastes tokens and teaches nothing: three examples of clearly CRITICAL bugs. The model already recognizes SQL-injection. You're burning context on reinforcement the model doesn't need. The replacement: two examples of borderline cases where reasoning matters — say, a UI input that looks sanitized but relies on a regex that misses unicode corner cases. That's the case where the model needs help, and that's what earns a slot in your few-shot set.
-->

---

<script setup>
const nullExample = `Document: "Invoice #1847 -- ACME Corp -- $2,400.00"

Reasoning: document does not mention customer_email.
No email appears in the body or metadata.

Output:
  invoice_number: "1847"
  total_amount: 2400.00
  customer_email: null`
</script>

<CodeBlockSlide
  eyebrow="Teach null to prevent fabrication"
  title="Empty-field pattern -- include a null example"
  lang="text"
  :code="nullExample"
  annotation="Without a null example, the model feels pressure to fill the field and invents a value. Exam guide, Task 4.2."
/>

<!--
This one shows up on the exam explicitly. For extraction tasks, include an example where the answer is null. "Document does not mention customer_email. Reasoning: no email appears in the body or metadata. Output: customer_email: null." Teaching null prevents fabrication. Without a null example, the model feels pressure to fill the field and invents a value. The exam guide calls this out under Task 4.2 — "adding few-shot examples showing correct extraction from documents with varied formats to address empty/null extraction of required fields." That phrasing will show up in a stem.
-->

---

<CalloutBox variant="tip" title="On the exam -- when few-shots is the answer">
  <v-clicks>
    <p>Stem phrasing -> few-shots:</p>
    <ul>
      <li><strong>&ldquo;consistent handling of varied formats&rdquo;</strong></li>
      <li><strong>&ldquo;reducing fabrication in extraction&rdquo;</strong></li>
    </ul>
    <p>Distractors: confidence thresholds, longer instructions, bigger models. Plausible elsewhere, wrong here.</p>
    <p>The right move: examples that show reasoning for ambiguous cases, <strong>including at least one null case</strong>.</p>
  </v-clicks>
</CalloutBox>

<!--
On the exam, few-shot examples are the right answer when the stem mentions "consistent handling of varied formats" or "reducing fabrication in extraction." Both phrases point at few-shots. Confidence thresholds sound appealing. Longer instructions sound appealing. They're distractors. The right move is examples that show the reasoning for ambiguous cases and that include at least one null case. Hold onto that — it catches a specific class of Scenario 6 questions.
-->

---

<ClosingSlide nextLecture="6.5 -- tool_use with JSON Schemas -- The Most Reliable Structured Output" />

<!--
Carry this forward: pick edge cases, include reasoning traces, vary the document format if you're extracting, and always include a null example to prevent fabrication. Next lecture, 6.5, we move from prompt-level techniques to API-level structure: tool_use with JSON schemas — the most reliable structured-output mechanism Claude offers. If you care about zero syntax errors, that's the lecture. See you there.
-->

---

<!-- LECTURE 6.5 — tool_use + JSON Schemas -->

<CoverSlide
  title="tool_use + JSON Schemas"
  subtitle="Zero syntax errors. The most reliable structured-output mechanism Claude offers."
  eyebrow="Domain 4 · Lecture 6.5"
  :stats="['Section 6', 'Scenario 6', 'Domain 4 · 20%', '8 min']"
/>

<!--
This lecture is the anchor concept for Scenario 6 — structured data extraction. Everything in the next four lectures plugs into what I'm about to tell you. If you take one sentence from this entire section into the exam, let it be this one: tool_use with a strict JSON schema is the most reliable structured-output mechanism Claude offers. Those exact words — "most reliable structured-output mechanism" — show up in exam stems and in correct answers. Hold onto that.
-->

---

<ConceptHero
  leadLine="Not &ldquo;fewer.&rdquo; Not &ldquo;rare.&rdquo; Zero."
  concept="Zero syntax errors"
  supportLine="tool_use with a strict JSON schema eliminates JSON syntax errors by construction -- the API validates the model's output against the schema before returning it to you. It's the most reliable structured-output mechanism Claude offers."
/>

<!--
The core claim is zero syntax errors. Not "fewer." Not "rare." Zero. Tool_use with a strict JSON schema eliminates JSON syntax errors by construction, because the API validates the model's output against the schema before returning it to you. Malformed braces, truncated strings, missing required fields — impossible. This is the most reliable structured-output mechanism Claude offers. Repeat that phrasing as you study. It's the one correct answer shape on multiple exam questions.
-->

---

<script setup>
const flowSteps65 = [
  { label: 'Define tool', sublabel: 'Extraction tool + JSON schema for input params' },
  { label: 'Claude returns tool_use', sublabel: 'Not free-form text -- a tool_use call' },
  { label: 'API validates against schema', sublabel: 'Malformed output never reaches your code' },
  { label: 'Read structured data', sublabel: 'Dict, not a string -- no JSON.loads()' },
]
</script>

<FlowDiagram
  eyebrow="How it works"
  title="tool_use flow -- four steps"
  :steps="flowSteps65"
/>

<!--
Here's the flow. Step one: you define an extraction tool — say, `extract_invoice` — with a JSON schema as its input parameters. Step two: Claude returns a tool_use call, not free-form text. Step three: the input to that call is already validated against your schema by the API. Step four: you read structured data directly from the tool_use.input block. No parsing. No try/except around JSON.loads. The data is already a dict when you receive it.
-->

---

<script setup>
const extractionTool = `tools = [{
  "name": "extract_invoice",
  "description": "Extract invoice data from a document.",
  "input_schema": {
    "type": "object",
    "required": ["invoice_number", "total_amount"],
    "properties": {
      "invoice_number": {"type": "string"},
      "total_amount":   {"type": "number"},
      "line_items": {
        "type": "array",
        "items": {
          "type": "object",
          "properties": {
            "description": {"type": "string"},
            "amount":      {"type": "number"}
          }
        }
      },
      "customer_email": {"type": ["string", "null"]}
    }
  }
}]`
</script>

<CodeBlockSlide
  eyebrow="Example"
  title="An extraction tool with a strict schema"
  lang="python"
  :code="extractionTool"
  annotation="When Claude processes an invoice, it responds with a tool_use block whose input is a dict matching this schema exactly. No intermediate string parsing."
/>

<!--
Concretely, you define a tool named `extract_invoice` with input_schema containing fields like invoice_number as a required string, total_amount as a required number, line_items as an array of objects, and customer_email as an optional nullable string. When Claude processes an invoice document, it responds with a tool_use block whose input is a dict matching that schema exactly. You pull invoice_number, total_amount, and so on directly. No intermediate string parsing.
-->

---

<script setup>
const eliminated = [
  { label: 'Malformed JSON', detail: 'The API rejects the output before you see it.' },
  { label: 'Missing braces / truncated strings', detail: 'Schema validation catches structural damage.' },
  { label: 'Wrong field names', detail: 'Schema names are the contract -- mismatches fail validation.' },
  { label: 'Wrong types', detail: 'If you declared a number, you get a number -- not a numeric string.' },
]
</script>

<BulletReveal
  eyebrow="What tool_use kills"
  title="A whole class of bugs, eliminated by construction"
  :bullets="eliminated"
/>

<!--
Here's what tool_use kills. Malformed JSON — eliminated. Missing braces — eliminated. Truncated strings from token limits — the API rejects the output before you see it. Wrong field names — eliminated, because the schema names are the contract. That's a class of bugs that ate hours of developer time before tool_use existed. You can delete your JSON-repair library. The schema does the work.
-->

---

<CalloutBox variant="warn" title="Semantic errors remain">
  <v-clicks>
    <p>tool_use eliminates syntax errors. It does <strong>not</strong> eliminate semantic errors.</p>
    <p>Schema-valid JSON can still be wrong. Line items that don't sum to the stated total. Values in the wrong fields. Dates in the future for a past event. The schema only enforces types and shape -- not meaning.</p>
    <p>Covered in depth in <strong>6.8</strong>. For now: <em>&ldquo;schema-valid&rdquo; is not &ldquo;correct.&rdquo;</em></p>
  </v-clicks>
</CalloutBox>

<!--
And now the warning. Tool_use eliminates syntax errors. It does not eliminate semantic errors. Schema-valid JSON can still be wrong. Line items that don't sum to the stated total. Values in the wrong fields. Dates in the future for a past event. The schema can't see those — it only enforces types and shape, not meaning. We cover this in depth in 6.8. For now, know that "schema-valid" is not "correct." The model can produce a schema-valid invoice that has a total of one thousand dollars and line items summing to nine hundred fifty.
-->

---

<script setup>
const comparisonRows = [
  {
    label: 'Prompt: &ldquo;return JSON&rdquo;',
    cells: [
      { text: 'None', highlight: 'bad' },
      { text: 'Zero effort, unreliable' },
    ],
  },
  {
    label: 'tool_use + strict schema',
    cells: [
      { text: 'Syntax-valid, schema-compliant', highlight: 'good' },
      { text: 'Schema design work up front' },
    ],
  },
]
</script>

<ComparisonTable
  eyebrow="Structured-output approaches"
  title="Prompt &ldquo;return JSON&rdquo; vs tool_use + schema"
  :columns="['Guarantees', 'Trade']"
  :rows="comparisonRows"
/>

<!--
Compare the two approaches. Approach one: prompt Claude "return JSON." Guarantees: none. The model might return JSON with a preamble, or JSON wrapped in prose, or — worst — almost-JSON that doesn't parse. Zero effort, unreliable output. Approach two: define a tool with a JSON schema and use tool_use. Guarantees: syntax-valid, schema-compliant. The trade is schema design work up front. The schema is the specification. That's the trade the exam wants you to recognize.
-->

---

<CalloutBox variant="tip" title="On the exam -- the exact phrase">
  <v-clicks>
    <p>Any stem asking for <em>&ldquo;the most reliable way to get structured output&rdquo;</em> or <em>&ldquo;guaranteed schema-compliant output&rdquo;</em> is testing <strong>tool_use with a schema</strong>. Every time.</p>
    <p>Distractors: &ldquo;prompt the model to return JSON,&rdquo; &ldquo;parse with a repair library,&rdquo; &ldquo;use a larger model.&rdquo; All wrong when the stem says <strong>reliable</strong>.</p>
  </v-clicks>
</CalloutBox>

<!--
On the exam, any stem that asks for "the most reliable way to get structured output" or "guaranteed schema-compliant output" is testing tool_use with a schema. Every time. Distractors will include "prompt the model to return JSON," "parse JSON from the response text with a repair library," and "use a larger model." All wrong. The correct phrasing is tool_use with a JSON schema. Almost-right is the trap — the distractors are plausible in a different context, but when the exam says "reliable," it means tool_use.
-->

---

<CalloutBox variant="tip" title="Continuity -- Scenario 6's foundation">
  <v-clicks>
    <p>Structured data extraction from unstructured docs -- invoices, contracts, medical records -- all of it lives on tool_use with a schema.</p>
    <p><strong>6.6</strong> covers <code>tool_choice</code>, which controls whether Claude can skip the tool call.</p>
    <p><strong>6.7</strong> covers schema design patterns that prevent the model from fabricating values to fill required fields.</p>
  </v-clicks>
</CalloutBox>

<!--
This is Scenario 6's foundation. Structured data extraction from unstructured docs — invoices, contracts, medical records — all of it lives on tool_use with a schema. The next two lectures build on this. 6.6 covers tool_choice — which controls whether Claude can skip the tool call, which matters a lot for guaranteed output. 6.7 covers schema design patterns that prevent the model from fabricating values to fill required fields. This lecture is the base. Those lectures are the superstructure.
-->

---

<ClosingSlide nextLecture="6.6 -- tool_choice for Guaranteed Structured Output" />

<!--
Carry this forward: tool_use with a strict JSON schema is the most reliable structured-output mechanism Claude offers — zero syntax errors, schema validation by construction. But schema-valid is not correct; semantic errors still exist. Next lecture, 6.6, we cover tool_choice — auto, any, and forced — and why "auto" is the trap that lets the model skip your tool call entirely. See you there.
-->

---

<!-- LECTURE 6.6 — tool_choice — Guaranteed Structured Output -->

<CoverSlide
  title="tool_choice -- Guaranteed Structured Output"
  subtitle="auto lets the model return text. any and forced do not. Know the difference."
  eyebrow="Domain 4 · Lecture 6.6"
  :stats="['Section 6', 'Scenario 6', 'Domain 4 · 20%', '7 min']"
/>

<!--
If you saw Section 4, lecture 4.9, tool_choice is a parameter you've already met. Here we're reusing it — same three modes, different angle. There, we used tool_choice to control tool selection. Here, we're using it to guarantee structured output. Two sides of the same parameter, both testable on the exam. This lecture takes eight minutes, closes with a single decision rule, and flags the one trap that catches people who skim: tool_choice: auto is not a structured-output guarantee.
-->

---

<script setup>
const modesRows = [
  {
    label: 'auto',
    cells: [
      { text: 'Nothing -- model may return text', highlight: 'bad' },
    ],
  },
  {
    label: 'any',
    cells: [
      { text: 'Some tool WILL be called', highlight: 'good' },
    ],
  },
  {
    label: '{type: "tool", name: X}',
    cells: [
      { text: 'THIS specific tool WILL be called', highlight: 'good' },
    ],
  },
]
</script>

<ComparisonTable
  eyebrow="The three modes"
  title="tool_choice -- what each mode guarantees"
  :columns="['Guarantees']"
  :rows="modesRows"
/>

<!--
Three modes. Auto — the default — guarantees nothing. The model may return free-form text instead of calling a tool. Any — the model must call a tool, but picks which one from your tool list. Forced — specified as `{"type": "tool", "name": "extract_invoice"}` — the model must call that specific tool by name. Read those again. Auto: no guarantee. Any: some tool will be called. Forced: this tool will be called. That's the entire API surface for this parameter, and the exam tests all three.
-->

---

<script setup>
const multiSchemaCode = `tools = [extract_invoice, extract_contract, extract_medical_record]

response = client.messages.create(
    model="claude-opus-4-7",
    tools=tools,
    tool_choice={"type": "any"},   # structured output guaranteed
    messages=[{"role": "user", "content": [doc_block]}]
)
# Claude sees the doc, picks the right schema,
# and ALWAYS returns a tool_use block.`
</script>

<CodeBlockSlide
  eyebrow="any -- multi-schema extraction"
  title='tool_choice: &ldquo;any&rdquo; with three schemas'
  lang="python"
  :code="multiSchemaCode"
  annotation="Without any, the model could return prose like 'this looks like a contract' and skip the tool call. With any, structured output is guaranteed on every request."
/>

<!--
Here's the pattern where `any` shines. You're processing documents of unknown type — invoices, contracts, and medical records all arrive in the same pipeline. You define three tools: extract_invoice, extract_contract, extract_medical_record. You set tool_choice to any. Claude sees the document, picks the right schema, and always returns structured output. Without `any`, the model could return prose like "this looks like a contract" and skip the tool call. With `any`, structured output is guaranteed on every request.
-->

---

<script setup>
const forcedCode = `# Step 1: force metadata extraction first
tool_choice = {"type": "tool", "name": "extract_metadata"}

# Step 2 (next request): force enrichment
tool_choice = {"type": "tool", "name": "extract_enrichment"}

# tool_choice is a workflow-ordering primitive here.`
</script>

<CodeBlockSlide
  eyebrow="Forced -- ordering by name"
  title="Pipeline sequencing via tool_choice"
  lang="python"
  :code="forcedCode"
  annotation="Step one guaranteed first, step two guaranteed second. tool_choice as a workflow-ordering primitive."
/>

<!--
The forced mode is for pipeline ordering. Say your flow is: extract metadata first, then enrich the record. You set tool_choice to `{"type": "tool", "name": "extract_metadata"}` on the first call. Claude must call extract_metadata, not any other tool. Then on the next request, you switch to extract_enrichment. This lets you orchestrate a fixed sequence of structured extractions — step one guaranteed first, step two guaranteed second. You're using tool_choice as a workflow-ordering primitive.
-->

---

<ConceptHero
  leadLine="The whole decision tree in one sentence."
  concept="Never auto for structured output"
  supportLine="Need structured output? Never auto. Know which tool you want? Force it. Don't know which? Use any. Three lines; catches most exam questions on tool_choice in under five seconds."
/>

<!--
Here's the whole decision tree in one sentence. Need structured output? Never auto. Know which tool you want? Force it. Don't know which? Use any. That's it. Three lines, catches most exam questions on tool_choice. The mental move is: structured output and auto are incompatible by design. Every time you see auto in the context of "guaranteed structure," that's the distractor. Simple rule, catches most exam questions on tool_choice in under five seconds of scanning the options.
-->

---

<CalloutBox variant="warn" title="The auto trap">
  <v-clicks>
    <p>Distractors will say something like <em>&ldquo;use tool_choice: auto with a well-named tool and clear description -- the model will naturally pick the tool.&rdquo;</em> Nope.</p>
    <p>Auto still allows the model to return text. A well-named tool makes the model <em>more likely</em> to call it. &ldquo;More likely&rdquo; is not &ldquo;guaranteed.&rdquo;</p>
    <p>If the question asks for guarantees, <strong>auto is always wrong</strong>. Almost-right is the trap -- auto is plausible for general agentic work, fails for structured-output guarantees.</p>
  </v-clicks>
</CalloutBox>

<!--
Here's the trap. Distractors will say something like "use tool_choice: auto with a well-named tool and clear description — the model will naturally pick the tool." Nope. Auto still allows the model to return text. A well-named tool makes the model more likely to call it, but "more likely" is not "guaranteed." If the question asks for guarantees, auto is always wrong. Almost-right is the trap: the auto answer sounds reasonable in a different context — like general agentic work — but for structured output guarantees, it fails.
-->

---

<CalloutBox variant="tip" title="Scenario 6 -- batch-processing varied docs">
  <v-clicks>
    <p>Multiple schemas + <code>tool_choice: any</code> = Claude picks the right schema per document and <strong>always</strong> returns structured output. No &ldquo;this document is ambiguous, here's some prose&rdquo; escape hatches.</p>
    <p>Revisited in <strong>6.11</strong>: batch + guaranteed structure is how you run a thousand-document extraction overnight and wake up to clean data.</p>
    <p>The architecture: <strong>tool_use + schema</strong> (reliability) · <strong>tool_choice: any</strong> (guarantee) · <strong>batch API</strong> (cost). Three primitives composed into one production pipeline.</p>
  </v-clicks>
</CalloutBox>

<!--
Scenario 6 uses this pattern heavily. Batch-processing a queue of varied documents — multiple schemas plus tool_choice any — means Claude picks the right schema per document and always returns structured output. No "this document is ambiguous, here's some prose" escape hatches. We come back to this in 6.11 when we cover the Message Batches API, because batch plus guaranteed structure is how you run a thousand-document extraction job overnight and wake up to clean data. The combination is the architecture: tool_use + schema for reliability, tool_choice: any for guarantee, batch API for cost. Three primitives composed into one production pipeline.
-->

---

<CalloutBox variant="tip" title="Callback to 4.9 -- same param, different angle">
  <v-clicks>
    <p>In <strong>Section 4.9</strong> we used <code>tool_choice</code> to control which tool Claude selects among many -- a <em>selection</em> primitive.</p>
    <p>Here we're using the same parameter for <em>structured output</em> guarantees -- a format primitive.</p>
    <p>If the stem says <em>&ldquo;the model returned text when I needed a tool call,&rdquo;</em> the answer is <code>tool_choice: any</code> or forced. If it says <em>&ldquo;the model picked the wrong tool,&rdquo;</em> re-read 4.9.</p>
  </v-clicks>
</CalloutBox>

<!--
Callback to 4.9 for anyone who took Section 4 recently. Same three modes of tool_choice, different angle. In 4.9 we talked about tool_choice for controlling which tool Claude selects among many — a selection primitive. Here we're using the same parameter for structured output guarantees — a format primitive. The exam can test either angle. If the stem talks about "the model returned text when I needed a tool call," the answer is tool_choice: any or forced. If it talks about "the model picked the wrong tool," re-read 4.9.
-->

---

<ClosingSlide nextLecture="6.7 -- Schema Design: Required, Optional, Nullable, Enum + 'other'" />

<!--
Carry this forward: auto guarantees nothing, any guarantees some tool runs, forced guarantees a specific tool runs. For structured output, never auto. Next lecture, 6.7, we design the schemas themselves — required vs optional, nullable patterns, enum with "other," and the "unclear" value that gives ambiguity a home so the model stops inventing to fill required fields. See you there.
-->

---

<!-- LECTURE 6.7 — Schema Design for Honest Output -->

<CoverSlide
  title="Schema Design for Honest Output"
  subtitle="Required, optional, nullable, enum + &lsquo;other&rsquo;, &lsquo;unclear.&rsquo; Give the model an honest way out."
  eyebrow="Domain 4 · Lecture 6.7"
  :stats="['Section 6', 'Scenario 6', 'Domain 4 · 20%', '9 min']"
/>

<!--
This lecture is the longest in Domain 4 because it has the most patterns to memorize — and because every distractor you see on Scenario 6 is a schema that forces the model to invent. Nine minutes, five schema patterns: required, optional, nullable, enum with "other," and the "unclear" enum value. If you nail these five patterns, you'll recognize the right answer on every Scenario 6 schema question.
-->

---

<BigQuote
  lead="Domain 4 · Lecture 6.7"
  quote="Required fields + absent data = the model invents a value to satisfy the schema."
  attribution="The fabrication problem, named"
/>

<!--
Here's the thesis, stated as a single line. Required fields plus absent data equals the model inventing a value to satisfy the schema. That's the fabrication problem. You marked customer_email as required. The document doesn't have an email. The model has no escape — the schema demands a string — so it fabricates one. "customer@example.com." Your downstream system ingests the fake email. The failure is silent and downstream. This is the most important sentence in the lecture: schema design is about giving the model an honest way out when the data isn't there.
-->

---

<ConceptHero
  leadLine="If the document might not have the field, mark it optional."
  concept="Required means required"
  supportLine="Only mark required when you can guarantee presence in the source. Over-marking required is the #1 schema bug -- it forces fabrication."
/>

<!--
Required means required. If the document might not have the field, mark it optional. If you force it, you force fabrication. The mental move is: only mark a field required when you can guarantee its presence in the source. Invoice_number on an invoice — probably safe. Customer_email on an arbitrary contract — never safe, because contracts often omit it. Most first-time schema designers over-mark required, and then they wonder why the model is inventing fields. The fix is optional.
-->

---

<script setup>
const nullableCode = `{
  "customer_email": {
    "type": ["string", "null"]
  }
}

# Absent data -> the model returns JSON null.
# Without the "null" alternative, the model would
# fabricate a string-shaped value.`
</script>

<CodeBlockSlide
  eyebrow="Nullable pattern"
  title='type: ["string", "null"] -- the honest way out'
  lang="json"
  :code="nullableCode"
  annotation="If you forget the 'null' alternative, the model has to produce something string-shaped -- and something string-shaped is a lie."
/>

<!--
Here's the JSON Schema pattern for nullable. You write the type as an array: `{"type": ["string", "null"]}`. That tells the model: this field can be a string, or it can be explicit null. Now when the data is absent, the model returns null — not a fabricated string, not an empty string, but the explicit JSON null. Your downstream code branches on null cleanly. If you forget the "null" alternative, the model has to produce something string-shaped, and something string-shaped is a lie.
-->

---

<script setup>
const enumOtherCode = `{
  "doc_category": {
    "enum": ["invoice", "contract", "receipt", "other"]
  },
  "other_detail": {
    "type": "string"
  }
}

# Statement of work? category = "other",
# other_detail = "statement of work".
# Taxonomy extended without a schema change.`
</script>

<CodeBlockSlide
  eyebrow="Enum with &ldquo;other&rdquo;"
  title="Extensible enum -- handle the unanticipated"
  lang="json"
  :code="enumOtherCode"
  annotation="You extended the taxonomy without a schema change. No inventing new enum values, no jamming SOWs into 'invoice.'"
/>

<!--
The extensible-enum pattern. Your schema has a category field: `{"enum": ["invoice", "contract", "receipt", "other"], ...}` — note the "other" value — plus a second field, `other_detail: {"type": "string"}`. When the document is a category you didn't anticipate — say, a statement of work — the model outputs category "other" and other_detail "statement of work." You extended the taxonomy without a schema change. This is how you handle open-ended categorization without the model inventing new enum values or jamming SOW into "invoice."
-->

---

<CalloutBox variant="tip" title="Enum + &ldquo;unclear&rdquo; -- give ambiguity a home">
  <v-clicks>
    <p>Add <code>&quot;unclear&quot;</code> as a valid enum value.</p>
    <p>When the document is genuinely ambiguous -- sentiment could be neutral or slightly negative -- the model reaches for <code>unclear</code> instead of picking wrong.</p>
    <p>Exam guide phrasing (Task 4.3): <em>&ldquo;adding enum values like &lsquo;unclear&rsquo; for ambiguous cases.&rdquo;</em> One line of schema that prevents a whole class of wrong answers.</p>
  </v-clicks>
</CalloutBox>

<!--
A close cousin. Add "unclear" as a valid enum value. If the document is genuinely ambiguous — the sentiment could be neutral or slightly negative — the model reaches for "unclear" instead of picking wrong. This is the exam guide's exact phrasing under Task 4.3: "adding enum values like 'unclear' for ambiguous cases." Without "unclear," the model has to pick one of your categories — and it picks confidently, even when the data doesn't support confidence. Adding "unclear" to your enum is one line of schema that prevents a whole class of wrong answers.
-->

---

<script setup>
const fullSchemaCode = `{
  "type": "object",
  "required": ["invoice_number", "total_amount"],
  "properties": {
    "invoice_number":  {"type": "string"},
    "total_amount":    {"type": "number"},
    "customer_email":  {"type": ["string", "null"]},
    "doc_category": {
      "enum": ["invoice", "contract", "receipt", "other"]
    },
    "other_detail":    {"type": "string"},
    "sentiment": {
      "enum": ["positive", "negative", "neutral", "unclear"]
    }
  }
}`
</script>

<CodeBlockSlide
  eyebrow="All patterns combined"
  title="A full extraction schema using every pattern"
  lang="json"
  :code="fullSchemaCode"
  annotation="Every Scenario 6 correct answer looks something like this. Study the shape."
/>

<!--
Here's the combined pattern in a schema. invoice_number required string. total_amount required number. customer_email type `["string", "null"]` — nullable. doc_category enum including "other." other_detail optional string. sentiment enum of positive, negative, neutral, unclear. That one schema uses every pattern we just covered. Study the shape. Every Scenario 6 correct answer looks something like this.
-->

---

<CalloutBox variant="tip" title="Format normalization -- in the prompt, not the schema">
  <v-clicks>
    <p>Mixed date formats in the source -- <code>&quot;Jan 3, 2025&quot;</code>, <code>&quot;2025-01-03&quot;</code>, <code>&quot;3/1/25&quot;</code>?</p>
    <p>Don't enforce format in the JSON schema. Normalize in the <strong>prompt instructions</strong> alongside the strict schema.</p>
    <ul>
      <li><strong>Prompt:</strong> &ldquo;Return all dates in ISO-8601 format.&rdquo;</li>
      <li><strong>Schema:</strong> <code>{"type": "string"}</code></li>
    </ul>
    <p>Schema constrains type and shape. Prompt handles normalization. Don't cross the streams.</p>
  </v-clicks>
</CalloutBox>

<!--
One more pattern that catches people. When the source document has mixed date formats — "Jan 3, 2025" and "2025-01-03" and "3/1/25" — you don't enforce the format in the JSON schema. You normalize in the prompt instructions alongside the strict schema. Prompt: "Return all dates in ISO-8601 format." Schema: `{"type": "string"}`. The schema constrains type and shape. The prompt handles normalization. Don't cross the streams.
-->

---

<CalloutBox variant="tip" title="On the exam -- two exact mappings">
  <v-clicks>
    <p><strong>&ldquo;The model fabricates values for fields not present in the source&rdquo;</strong> -> make those fields nullable or optional.</p>
    <p><strong>&ldquo;The source documents contain categories not anticipated in the schema&rdquo;</strong> -> enum + &ldquo;other&rdquo; + detail string.</p>
    <p>Almost-right traps will offer <em>&ldquo;use a more capable model&rdquo;</em> or <em>&ldquo;increase temperature.&rdquo;</em> Both wrong. The fix is schema design.</p>
  </v-clicks>
</CalloutBox>

<!--
On the exam, two exact phrasings show up. One: "the model fabricates values for fields not present in the source." The correct answer is making those fields nullable or optional. Two: "the source documents contain categories not anticipated in the schema." The correct answer is enum plus "other" plus a detail string. Memorize both mappings. Almost-right traps will offer "use a more capable model" or "increase temperature" — both wrong. The fix is schema design.
-->

---

<CalloutBox variant="tip" title="Scenario 6 lives on these patterns">
  <v-clicks>
    <p>Every distractor in Scenario 6 schema questions is a schema that forces the model to invent -- a required field where data is absent, an enum without &ldquo;other,&rdquo; a type without null.</p>
    <p>The correct answer is always the schema that gives the model <strong>an honest way out</strong>. Remember the six-pick-four -- you don't know whether Scenario 6 shows up, so prepare as if it will.</p>
  </v-clicks>
</CalloutBox>

<!--
Scenario 6 lives on these patterns. Every distractor in Scenario 6 schema questions is a schema that forces the model to invent — a required field where the data is absent, an enum without "other," a type without null. The correct answer is always the schema that gives the model an honest way out. Remember the six-pick-four — you don't know whether Scenario 6 shows up, so you prepare as if it will.
-->

---

<ClosingSlide nextLecture="6.8 -- Syntax Errors vs Semantic Errors" />

<!--
Carry this forward: mark optional when the data might be absent, make types nullable when absence is real, use enum plus "other" for extensible categories, add "unclear" to give ambiguity a home, and normalize formats in the prompt — not the schema. Next lecture, 6.8, we hit the other limit of tool_use: semantic errors. Schema-valid does not mean correct. That distinction is testable, and it's the setup for the validation-retry loops in 6.9. See you there.
-->

---

<!-- LECTURE 6.8 — Syntax vs Semantic Errors -->

<CoverSlide
  title="Syntax vs Semantic Errors"
  subtitle="tool_use eliminates syntax errors. It doesn't eliminate semantic ones."
  eyebrow="Domain 4 · Lecture 6.8"
  :stats="['Section 6', 'Scenario 6', 'Domain 4 · 20%', '7 min']"
/>

<!--
Short lecture. One distinction. Seven minutes. The distinction is: tool_use eliminates syntax errors — it doesn't eliminate semantic errors. That sentence is the whole lecture, and it's also one of the most tested single claims in Domain 4. The exam will give you a scenario where a schema-valid extraction is still wrong, and the right answer requires knowing exactly what tool_use can and can't guarantee.
-->

---

<script setup>
const errorRows = [
  {
    label: 'Syntax',
    cells: [
      { text: 'Malformed JSON, missing fields, wrong types, truncation', highlight: 'neutral' },
      { text: 'YES -- eliminated by construction', highlight: 'good' },
    ],
  },
  {
    label: 'Semantic',
    cells: [
      { text: "Wrong values, line items don't sum, cross-field inconsistency", highlight: 'neutral' },
      { text: "NO -- the schema can't see meaning", highlight: 'bad' },
    ],
  },
]
</script>

<ComparisonTable
  eyebrow="Two error classes"
  title="What tool_use solves -- and what it doesn't"
  :columns="['Example', 'tool_use solves?']"
  :rows="errorRows"
/>

<!--
Two classes of error. Syntax errors — the output is malformed. Invalid JSON, missing braces, wrong types. tool_use solves these — yes, completely. Semantic errors — the output is well-formed but factually wrong. Line items don't sum to the stated total. Dates are inconsistent. Values are in the wrong fields. tool_use does not solve these. At all. The schema can't see meaning — only shape and type.
-->

---

<script setup>
const syntaxKilled = [
  { label: 'Invalid JSON', detail: "API rejects the model's output before you see it." },
  { label: 'Missing required fields', detail: 'Schema validation catches the gap.' },
  { label: 'Wrong types', detail: 'Declared number -> you get a number, not a numeric string.' },
  { label: 'Truncated output from token limits', detail: 'API enforces completion.' },
]
</script>

<BulletReveal
  eyebrow="What tool_use kills by construction"
  title="Syntax errors -- eliminated"
  :bullets="syntaxKilled"
/>

<!--
Here's what tool_use eliminates by construction. Invalid JSON. Missing required fields — the API rejects the model's output before you see it. Wrong types — if you said number, you get a number, not a numeric string. Truncated output from token limits — the API enforces completion. That entire category of problems is gone. You can delete the JSON-repair code you wrote in 2023. Tool_use made it redundant.
-->

---

<script setup>
const semanticUnseen = [
  { label: 'Values in the wrong fields', detail: 'Invoice number in customer_id slot -- schema happy, data wrong.' },
  { label: "Math doesn't add up", detail: 'Line items sum to $950, stated_total is $1,000.' },
  { label: 'Logical contradictions', detail: 'Contract signed 2025, expires 2020.' },
  { label: 'Dates in the future for a past event', detail: 'Schema valid, reality inverted.' },
]
</script>

<BulletReveal
  eyebrow="What tool_use can't see"
  title="Semantic errors -- still there"
  :bullets="semanticUnseen"
/>

<!--
And here's what tool_use can't see. Values in the wrong fields — the model puts the invoice number in the customer_id slot. The schema accepts a string in each, so the schema is happy. The data is wrong. Math doesn't add up — line items sum to nine hundred fifty, stated total is one thousand. Schema-valid, semantically broken. Logical contradictions — a contract signed in 2025 with an expiration in 2020. Schema passes, reality fails. Dates in the future for a past event. Schema happy, data lies. Each of these is a different flavor of the same failure: the shape is right, the meaning is wrong.
-->

---

<script setup>
const canonicalExample = `{
  "invoice_number": "INV-1847",
  "line_items": [
    {"description": "Widget A", "amount": 400},
    {"description": "Widget B", "amount": 300},
    {"description": "Widget C", "amount": 250}
  ],
  "stated_total": 1000.00
}

// Line items sum to 950. stated_total is 1000.
// Schema-valid. Semantically broken. You've been
// short-changed by 50 -- and the schema never flagged it.`
</script>

<CodeBlockSlide
  eyebrow="The canonical example"
  title="Schema-valid. Semantically wrong."
  lang="json"
  :code="canonicalExample"
  annotation="This is the difference between syntax-valid and correct. The API returns success. Your downstream code pays $1,000. You've been short-changed by $50 and the schema never knew."
/>

<!--
Here's the canonical example that shows up in exam stems. Invoice extraction: line_items is an array of three items totaling nine hundred fifty dollars, stated_total is one thousand dollars. The schema accepts both — line_items is a valid array of valid objects, stated_total is a valid number. The API returns success. Your downstream code reads stated_total and pays one thousand. You've been short-changed by fifty, and the schema never flagged it. This is the difference between syntax-valid and correct.
-->

---

<CalloutBox variant="tip" title="Next lecture preview -- validation-retry">
  <v-clicks>
    <p>The fix is in <strong>6.9</strong>. Preview: extract <code>calculated_total</code> (computed from line_items) alongside <code>stated_total</code>, compare in post-processing.</p>
    <p>If they don't match, flag the extraction or retry with feedback. The schema can't enforce the equality -- your validation layer can. Exam guide Task 4.4.</p>
  </v-clicks>
</CalloutBox>

<!--
The fix for this is in 6.9. Quick preview: you add a computed invariant to the extraction — extract calculated_total (computed from line_items) alongside stated_total, and compare them in post-processing. If they don't match, you flag the extraction or retry with feedback. The schema can't enforce the equality, but your validation layer can. This is the pattern the exam guide names explicitly under Task 4.4. We go deep on it next lecture.
-->

---

<script setup>
const badShipSchema = `if validate_schema(extracted_json):
    ship_to_downstream(extracted_json)
# Schema-valid != correct. Wrong values go through.`

const goodInvariants = `if validate_schema(extracted_json):
    invariants_ok = (
        sum_of_line_items_matches_stated_total(extracted_json)
        and dates_are_consistent(extracted_json)
    )
    if invariants_ok:
        ship_to_downstream(extracted_json)
    else:
        flag_for_review(extracted_json)`
</script>

<AntiPatternSlide
  title="Don't ship on &ldquo;schema passed&rdquo;"
  lang="python"
  :badExample="badShipSchema"
  whyItFails="Schema passed means syntactically valid -- nothing about meaning."
  :fixExample="goodInvariants"
/>

<!--
The anti-pattern is shipping on "schema passed." Schema passed means syntactically valid — nothing about the meaning. The fix is computing invariants after extraction: sum checks, cross-field consistency, date ordering, any relationship your domain has. Then catch semantic errors before the data hits downstream systems. This is where validation-retry earns its keep — and where many production extraction pipelines silently fail for months before someone notices the numbers. The mental move is: treat the schema as the input contract, not the correctness guarantee. Your validation layer is what enforces correctness, and it has to know the domain invariants the schema can't express.
-->

---

<CalloutBox variant="tip" title="On the exam -- what &ldquo;X&rdquo; is in &ldquo;tool_use eliminates X&rdquo;">
  <v-clicks>
    <p>X = <strong>syntax errors</strong>. Not all errors.</p>
    <p>If the question hints at wrong values, mismatched numbers, or cross-field inconsistencies -> <strong>semantic validation</strong> is the answer, not tool_use alone.</p>
    <p>Almost-right trap: a distractor might say <em>&ldquo;tool_use guarantees the extraction is correct.&rdquo;</em> It doesn't. It guarantees the extraction is <strong>well-formed</strong>. Two different claims.</p>
    <p>Tell in the stem: <em>correct, wrong values, doesn't match, sum mismatch</em> -- all point at semantic validation.</p>
  </v-clicks>
</CalloutBox>

<!--
On the exam, this distinction is sharp. "Tool_use eliminates X" — X is syntax errors. Not all errors. If the question hints at wrong values, mismatched numbers, or cross-field inconsistencies, semantic validation is the answer — not tool_use alone. Almost-right is the trap: a distractor might say "tool_use guarantees the extraction is correct." It doesn't. It guarantees the extraction is well-formed. Two different claims. Scenario 6 — structured extraction — tests this distinction directly, and remember the six-pick-four, you don't know whether Scenario 6 lands in your four, so you prepare for it. The tell in the stem is words like "correct," "wrong values," "doesn't match," or "sum mismatch" — all point at semantic validation, not tool_use.
-->

---

<ClosingSlide nextLecture="6.9 -- Validation-Retry Loops: When They Work and When They Don't" />

<!--
Carry this forward as one sentence: tool_use eliminates syntax errors — not semantic errors. Schema-valid is not correct. Next lecture, 6.9, we build the validation-retry loop: when retries work (format and structural errors), when they don't (information absent from the source), and the prompt shape that makes retry effective. See you there.
-->

---

<!-- LECTURE 6.9 — Validation-Retry Loops -->

<CoverSlide
  title="When Validation-Retry Works -- and When It Doesn't"
  subtitle="Retries fix format and structure. They can't fix absence."
  eyebrow="Domain 4 · Lecture 6.9"
  :stats="['Section 6', 'Scenario 6', 'Domain 4 · 20%', '8 min']"
/>

<!--
Continuing from 6.8, where we drew the line between syntax errors — which tool_use eliminates — and semantic errors — which it doesn't. This lecture is about the pattern that catches the semantic ones: the validation-retry loop. Eight minutes. We cover what the loop looks like, what it fixes, and — critically — what it can't fix no matter how many times you retry. That last part is the exam question.
-->

---

<script setup>
const loopSteps = [
  { label: 'Extract', sublabel: 'tool_use with your schema' },
  { label: 'Validate', sublabel: 'Run computed invariants -- sum checks, cross-field consistency' },
  { label: 'Retry with feedback', sublabel: 'Send: original doc + failed extraction + specific errors' },
  { label: 'Claude retries', sublabel: 'Re-extract with the error context in view' },
  { label: 'Validate again', sublabel: 'Commit or escalate to human review' },
]
</script>

<FlowDiagram
  eyebrow="The loop"
  title="Retry with feedback -- five steps"
  :steps="loopSteps"
/>

<!--
Here's the loop in five steps. One: extract using tool_use with your schema. Two: validate — run your computed invariants, like sum checks or cross-field consistency. Three: if validation fails, send Claude a second request with the original document, the failed extraction, and the specific validation errors. Four: Claude retries with the error context. Five: validate again. That's the whole pattern — retry with error feedback, not blind retry. The feedback is what makes it work.
-->

---

<CalloutBox variant="tip" title="Works for -- fixable errors">
  <v-clicks>
    <p><strong>Format mismatches</strong> -- <em>&ldquo;you returned the date as MM/DD/YYYY; return it as ISO-8601.&rdquo;</em> Claude re-reads and corrects.</p>
    <p><strong>Structural output errors</strong> -- <em>&ldquo;you returned line_items as an object instead of an array.&rdquo;</em> Retry fixes that.</p>
    <p><strong>Semantic errors the document can resolve</strong> -- <em>&ldquo;line items sum to $950 but stated_total is $1,000; check your extraction.&rdquo;</em></p>
    <p>If the correct answer exists in the source, retry-with-feedback usually finds it on pass two.</p>
  </v-clicks>
</CalloutBox>

<!--
Here's what retry fixes. Format mismatches — "you returned the date as MM/DD/YYYY, return it as ISO-8601." Claude re-reads and corrects. Structural output errors — "you returned line_items as an object instead of an array." Retry fixes that too. Semantic errors the document can resolve — "line items sum to nine fifty but stated total is one thousand; check your extraction." If the correct answer exists in the source, retry-with-feedback usually finds it on pass two.
-->

---

<CalloutBox variant="warn" title="Doesn't work for -- unfixable errors">
  <v-clicks>
    <p>If the information isn't there, <strong>it isn't there</strong>. Retrying won't summon data that never existed in the source.</p>
    <p>Customer ID required but the document doesn't contain one -> retry a hundred times; the model still can't produce what isn't there. Only outcomes: null (if schema allows) or fabrication (if field is required).</p>
    <p>Exam guide, Task 4.4: retries are ineffective when the required information is simply absent from the source.</p>
  </v-clicks>
</CalloutBox>

<!--
Here's what retry cannot fix. If the information isn't there, it isn't there. Retrying won't summon data that never existed in the source. Customer ID required but the document doesn't contain one — retry a hundred times and the model still can't produce what isn't there. The only outcomes are null (if your schema allows it) or fabrication (if the field is required). The exam guide is explicit about this under Task 4.4: retries are ineffective when the required information is simply absent from the source.
-->

---

<script setup>
const effectivenessRows = [
  {
    label: 'Date format wrong',
    cells: [
      { text: 'YES -- information exists, just needs reformatting', highlight: 'good' },
    ],
  },
  {
    label: "Total doesn't sum",
    cells: [
      { text: 'YES -- model can re-extract line items and get it right', highlight: 'good' },
    ],
  },
  {
    label: 'Required field absent from document',
    cells: [
      { text: 'NO -- no amount of retrying conjures missing data', highlight: 'bad' },
    ],
  },
  {
    label: 'Customer ID in an external system not provided',
    cells: [
      { text: "NO -- external data isn't in the source", highlight: 'bad' },
    ],
  },
]
</script>

<ComparisonTable
  eyebrow="Retry effectiveness"
  title="Four concrete cases -- know the split by stem wording"
  :columns="['Retry effective?']"
  :rows="effectivenessRows"
/>

<!--
Let me make the distinction concrete. Date format wrong? Retry works — the information exists, it just needs reformatting. Total doesn't sum? Retry usually works — the model can re-extract the line items and get it right. Required field absent from the document? Retry fails — no amount of retrying conjures missing data. Customer ID referenced in an external system not provided? Retry fails — external data isn't in the source. Four cases, and you need to know which is which by the wording of the stem.
-->

---

<script setup>
const retryPrompt = `Original document:
<doc>{...}</doc>

Your prior extraction:
{
  "line_items": [...],
  "stated_total": 1000
}

Specific validation errors:
- line_items sum to 950 but stated_total is 1000;
  they must match.

Please re-extract, correcting the above errors.`
</script>

<CodeBlockSlide
  eyebrow="The retry prompt shape"
  title="Original doc + failed extraction + specific errors"
  lang="text"
  :code="retryPrompt"
  annotation="Vague retries don't work. Specific validation errors guide the model to the exact field that needs correction. Exam guide Task 4.4."
/>

<!--
The effective retry prompt has three components. One: the original document. Two: the failed extraction — what Claude returned that didn't validate. Three: the specific validation errors — not "this is wrong," but "line_items sum to 950 but stated_total is 1000; they must match." Vague retries don't work. Specific validation errors guide the model to the exact field that needs correction. This is the exam guide's wording under Task 4.4 — "appending specific validation errors to the prompt on retry."
-->

---

<CalloutBox variant="tip" title="When to stop -- cap retries">
  <v-clicks>
    <p>Detect <strong>information-absent</strong> cases before the loop runs forever. If retry two can't produce the required field, the data isn't there -- it's not going to appear on retry five.</p>
    <p>Cap retries at <strong>two or three</strong>. On failure: null-out the field (if schema permits) or route to human review.</p>
    <p>Mental move: retry is a tactic for fixable errors, not a universal hammer.</p>
  </v-clicks>
</CalloutBox>

<!--
When to stop looping. Before the retry loop runs forever, detect "information absent" cases. If your second retry still can't produce the required field, the data isn't there — it's not going to appear on retry five. Cap retries at two or three. On failure, either null-out the field (if your schema permits) or route the document to human review. Don't burn tokens in a loop that cannot succeed. The mental move is: retry is a tactic for fixable errors, not a universal hammer.
-->

---

<script setup>
const badRetry = `for attempt in range(5):
    result = claude.extract(doc)
    if validate(result):
        break
# Same answer five times for absent-data docs.`

const goodRetry = `for attempt in range(2):
    result = claude.extract(doc, prior_errors=errors)
    if validate(result):
        return result
    errors = diff(result)

if data_absent_from_source(result):
    return null_out_or_route_to_human(result)`
</script>

<AntiPatternSlide
  title="Don't retry indefinitely"
  lang="python"
  :badExample="badRetry"
  whyItFails="Expensive, slow, and produces the same wrong answer for unfixable cases."
  :fixExample="goodRetry"
/>

<!--
The anti-pattern is the five-retry "hope for the best" loop. It's expensive, it's slow, and for the unfixable cases, it produces the same answer five times in a row. The replacement: detect when the document lacks the required field, null it out if allowed, route to human review if the field is genuinely required. Build the "can this be fixed by retry?" check into your validation layer, not after it.
-->

---

<CalloutBox variant="tip" title="On the exam -- the absent-info question">
  <v-clicks>
    <p>Stem: <em>&ldquo;When is a validation-retry loop ineffective?&rdquo;</em></p>
    <p>Answer: <strong>when the required information exists only in an external document or system not provided to the model.</strong></p>
    <p>That exact phrasing shows up in correct answers. Distractors -- &ldquo;when the prompt is too long,&rdquo; &ldquo;when the temperature is high&rdquo; -- are wrong.</p>
  </v-clicks>
</CalloutBox>

<!--
On the exam, the stem often reads like: "when is a validation-retry loop ineffective?" The answer is almost always: when the required information exists only in an external document or system not provided to the model. That exact phrasing shows up in correct answers. Distractors will say "when the prompt is too long" or "when the temperature is high" — both wrong. The right answer is information-absence. Memorize that mapping. It's a specific Scenario 6 question type.
-->

---

<ClosingSlide nextLecture="6.10 -- The detected_pattern Field for False Positive Analysis" />

<!--
Carry this forward: retry works for fixable errors — format, structure, resolvable semantic mismatches — and fails when the data isn't in the source. Cap retries, route absent-data cases to human review, and always include specific validation errors in the retry prompt. Next lecture, 6.10, we cover the detected_pattern field — a systematic way to analyze which prompts are generating false positives, so you can fix at the pattern layer instead of case-by-case. See you there.
-->

---

<!-- LECTURE 6.10 — The detected_pattern Field -->

<CoverSlide
  title="detected_pattern -- Systematic FP Analysis"
  subtitle="One schema field turns dismissal noise into a measurable iteration loop."
  eyebrow="Domain 4 · Lecture 6.10"
  :stats="['Section 6', 'Scenario 5', 'Domain 4 · 20%', '7 min']"
/>

<!--
Short, sharp lecture. Seven minutes. One field added to your review schema — `detected_pattern` — unlocks systematic false-positive analysis. Without it, you're flying blind when developers dismiss findings. With it, you see exactly which prompts are generating noise and you fix at the pattern layer instead of case-by-case. The exam guide calls this out by name under Task 4.4, so know the field name cold.
-->

---

<BigQuote
  lead="Domain 4 · Lecture 6.10"
  quote="Developers dismiss 60% of findings. Which ones? You don't know. You can't fix what you can't measure."
  attribution="The unmeasured-dismissal problem"
/>

<!--
Here's the problem. Developers dismiss sixty percent of your findings. Which ones? You don't know. You can't fix what you can't measure. If every finding is a snowflake, your false-positive rate is an undifferentiated mass — you can't iterate on the prompt because you don't know which parts of the prompt are producing the bad findings. This is where most CI/CD review pipelines stall out. Back to the trust-economics thread from 6.2: if you can't measure what's noisy, you can't disable what's noisy, and the whole bot gets muted.
-->

---

<ConceptHero
  leadLine="One schema field, one new lens on your review output."
  concept="Tag every finding"
  supportLine="Add a detected_pattern field identifying what triggered the finding. When developers dismiss, you see the pattern -- not the one-off."
/>

<!--
The fix is one schema field. Add a `detected_pattern` field to every finding. Values are named patterns like "unchecked_return_value," "missing_null_check," "hardcoded_credential," "sql_injection." Every finding Claude emits carries its pattern label. Now when developers dismiss findings, the dismissal data is tagged — you see the pattern, not the one-off. "We dismissed eighty percent of missing_null_check findings last week" is actionable. "We dismissed a bunch of stuff" is not.
-->

---

<script setup>
const findingSchema = `{
  "type": "object",
  "required": ["file_path", "line_number", "severity",
               "description", "detected_pattern"],
  "properties": {
    "file_path":     {"type": "string"},
    "line_number":   {"type": "integer"},
    "severity":      {"enum": ["CRITICAL", "HIGH", "MEDIUM", "LOW"]},
    "description":   {"type": "string"},
    "detected_pattern": {
      "enum": [
        "unchecked_return_value",
        "missing_null_check",
        "hardcoded_credential",
        "sql_injection"
      ]
    }
  }
}`
</script>

<CodeBlockSlide
  eyebrow="Schema field"
  title="The review finding schema -- with detected_pattern"
  lang="json"
  :code="findingSchema"
  annotation="Without detected_pattern, you're analyzing strings. With it, you're analyzing categories."
/>

<!--
Here's what your finding schema looks like. Object fields: file_path string, line_number integer, severity enum of CRITICAL/HIGH/MEDIUM/LOW, description string, and detected_pattern enum of your named patterns. The detected_pattern is the key addition. It's how every downstream dashboard, alerting system, and prompt-tuning iteration groups findings. Without it, you're analyzing strings; with it, you're analyzing categories.
-->

---

<script setup>
const analysisLoop = [
  { label: 'Tag every finding', sublabel: 'detected_pattern on every emission' },
  { label: 'Accept/dismiss signal', sublabel: 'Developer feedback flows into telemetry' },
  { label: 'Aggregate by pattern', sublabel: 'Dismissal rates grouped by detected_pattern' },
  { label: 'Refine or disable', sublabel: 'Patterns above dismissal threshold get tightened -- or paused' },
]
</script>

<FlowDiagram
  eyebrow="Analysis loop"
  title="Pattern-level iteration"
  :steps="analysisLoop"
/>

<!--
The loop this enables. Step one: findings tagged with detected_pattern. Step two: developers accept or dismiss each finding — that signal goes into your telemetry. Step three: aggregate dismissals by pattern. Step four: patterns with high dismissal rates get prompt refinement — or, per 6.2, get temporarily disabled while you refine. This is the iteration loop that moves precision over time. Without the pattern field, the loop has nothing to aggregate over.
-->

---

<CalloutBox variant="tip" title="Concrete win">
  <v-clicks>
    <p>You notice <code>missing_null_check</code> findings are being dismissed 80% of the time.</p>
    <p><strong>Move 1:</strong> tighten the criteria -- <em>&ldquo;only flag missing_null_check when the value originates from user input or an external API, not when it comes from an ORM with non-null constraints.&rdquo;</em></p>
    <p><strong>Move 2:</strong> if you can't tighten fast enough, disable the pattern temporarily while you iterate.</p>
    <p>Same telemetry tells you when to reinstate -- dismissal rate drops, turn it back on with confidence.</p>
  </v-clicks>
</CalloutBox>

<!--
Concrete scenario. You notice missing_null_check findings are being dismissed eighty percent of the time. Two moves. One: tighten the criteria — "only flag missing_null_check when the value originates from user input or an external API, not when it comes from an ORM with non-null constraints." Two: if you can't tighten it fast enough, disable the pattern temporarily while you iterate. The pattern data tells you where to focus. Without it, you might have been tuning the sql_injection prompt — which was already accurate — while missing_null_check kept wrecking developer trust. And once you've fixed the pattern, the same telemetry tells you when to reinstate it — dismissal rate drops, you turn it back on with confidence.
-->

---

<script setup>
const badAggregate = `overall_fp_rate = dismissed_findings / all_findings
# "Our FP rate is 40%." Tells you nothing about what to fix.`

const goodPattern = `fp_by_pattern = group_dismissals_by(detected_pattern)
# sql_injection:       2% dismissed  [OK]
# missing_null_check: 80% dismissed  [FIX]
# hardcoded_credential: 5% dismissed [OK]
# Now you know exactly where to iterate.`
</script>

<AntiPatternSlide
  title="Don't aggregate FPs without patterns"
  lang="python"
  :badExample="badAggregate"
  whyItFails="A single aggregate number can't tell you which prompt is failing."
  :fixExample="goodPattern"
/>

<!--
The anti-pattern is tracking overall false-positive rate as a single number. It's almost useless. "Our FP rate is forty percent" tells you nothing about what to fix. The replacement is tracking FP rate by detected_pattern — which patterns are in good shape, which are noisy, which are drifting over time. You fix at the pattern layer, not the aggregate layer. Every serious CI/CD review product does this; your extraction pipeline should too.
-->

---

<CalloutBox variant="tip" title="On the exam -- the named field">
  <v-clicks>
    <p>Stem: <em>&ldquo;systematic analysis of dismissal patterns&rdquo;</em> or <em>&ldquo;tracking which code constructs trigger false positives.&rdquo;</em> -> add a <code>detected_pattern</code> field.</p>
    <p>Exam guide lists it by exact name under Task 4.4.</p>
    <p>Distractors: &ldquo;increase the model size,&rdquo; &ldquo;add more few-shot examples&rdquo; -- plausible elsewhere, wrong here.</p>
    <p>Related cousins: <code>calculated_total</code> vs <code>stated_total</code>, <code>conflict_detected</code> boolean. Same principle -- <strong>make invisible signal visible.</strong></p>
  </v-clicks>
</CalloutBox>

<!--
On the exam, the field name matters. If the stem asks about "systematic analysis of dismissal patterns" or "tracking which code constructs trigger false positives," the answer includes adding a detected_pattern field to the structured findings. The exam guide lists it by exact name under Task 4.4. Distractors will suggest "increase the model size" or "add more few-shot examples" — both plausible elsewhere, wrong here. The right answer is the named field. And a related exam-guide pattern worth knowing: self-correction fields like `calculated_total` alongside `stated_total`, or a `conflict_detected` boolean for inconsistent source data. These are cousins of detected_pattern — fields you add to the schema specifically to enable downstream validation or analysis. Same principle: make invisible signal visible.
-->

---

<ClosingSlide nextLecture="6.11 -- The Message Batches API: 50% Savings, 24-Hour Window, Limitations" />

<!--
Carry this forward: add a detected_pattern field to every review finding so you can measure dismissal patterns, aggregate by pattern, and fix at the pattern layer. This is Scenario 5's iteration primitive. Next lecture, 6.11, we change gears completely — the Message Batches API. Fifty percent cost savings, a 24-hour processing window, and the limitations that make it right for some workloads and wrong for others. See you there.
-->

---

<!-- LECTURE 6.11 — The Message Batches API -->

<CoverSlide
  title="The Message Batches API"
  subtitle="50% savings. 24-hour window. No multi-turn tool calling."
  eyebrow="Domain 4 · Lecture 6.11"
  :stats="['Section 6', 'Scenarios 5 & 6', 'Domain 4 · 20%', '8 min']"
/>

<!--
Gears shift. We've been in prompt engineering and structured output; the next three lectures are the batch-processing triplet. This one covers the Message Batches API — the offer, the trade, and the limitations. Eight minutes. Three facts to memorize cold, because this API is tested directly on Scenario 5 and Scenario 6 sample questions — including Sample Q11, which we'll quote later in this lecture.
-->

---

<BigNumber
  eyebrow="The offer"
  number="50%"
  unit=" cost savings"
  caption="Trade: up to 24-hour processing, no guaranteed latency SLA."
  detail="Real, flat -- not &ldquo;up to 50%,&rdquo; not &ldquo;in some cases.&rdquo; Half off. The request might come back in 20 minutes or in 23 hours. You don't know, and you can't rely on faster."
  accent="var(--sprout-500)"
/>

<!--
Here's the offer in one number: fifty percent. Fifty percent cost savings compared to synchronous API calls. That's the hook, and it's real — not "up to fifty percent," not "in some cases." Half off. The trade: up to a 24-hour processing window, with no guaranteed latency SLA. The request might come back in twenty minutes. It might come back in twenty-three hours. You don't know, and you can't rely on it completing faster than 24 hours.
-->

---

<script setup>
const threeFacts = [
  { label: '50% cheaper than synchronous', detail: 'Real, flat -- not "up to," not "in some cases." Half off.' },
  { label: 'Up to 24-hour completion', detail: "Could come back in 20 minutes. Could come back in 23 hours. You can't rely on faster." },
  { label: 'No guaranteed latency SLA', detail: 'Plan against the 24-hour upper bound, not the average case.' },
]
</script>

<BulletReveal
  eyebrow="Memorize these cold"
  title="Three facts about the Batches API"
  :bullets="threeFacts"
/>

<!--
Three facts, memorized cold. One: fifty percent cheaper than synchronous. Two: up to 24-hour completion. Three: no guaranteed latency SLA. Those three show up in correct answers verbatim. If a distractor says "ninety percent cheaper" or "guaranteed 2-hour turnaround," that's the tell — it's wrong on the facts. The exam is precise about the numbers on this one, same way it's precise about seven hundred twenty for the passing score.
-->

---

<CalloutBox variant="tip" title="Good fit -- use batch for...">
  <v-clicks>
    <p><strong>Overnight reports</strong> -- submit at 6pm, results by morning standup.</p>
    <p><strong>Weekly audits</strong> -- submit Friday night, results by Monday.</p>
    <p><strong>Nightly test generation</strong> -- submit after CI finishes, new tests by daybreak.</p>
    <p>Pattern: no human is waiting, job has hours or days of runway. Those are the workloads where 50% savings cost you nothing.</p>
  </v-clicks>
</CalloutBox>

<!--
Where batch shines. Overnight reports — submit at 6pm, results by morning standup. Weekly audits — submit Friday night, results by Monday. Nightly test generation — submit after CI finishes, have new tests ready at daybreak. Any non-blocking, latency-tolerant workload. The pattern is: no human is waiting, and the job has hours or days of runway. Those are the workloads where fifty percent savings cost you nothing.
-->

---

<CalloutBox variant="warn" title="Bad fit -- don't batch...">
  <v-clicks>
    <p><strong>Pre-merge checks</strong> -- developers can't wait 24 hours for CI.</p>
    <p><strong>Interactive UIs</strong> -- users close the tab.</p>
    <p><strong>Anything a human is watching in real time.</strong></p>
    <p>Hard rule: if a person is blocked on the result, batch is the wrong API. The 50%-savings number is a strong pull toward &ldquo;batch everything&rdquo; -- that pull is the exam's favorite trap.</p>
  </v-clicks>
</CalloutBox>

<!--
Where batch fails. Pre-merge checks — developers can't wait 24 hours for CI. Interactive UIs — users close the tab. Anything a human is watching in real time. The hard rule: if a person is blocked on the result, batch is the wrong API. This sounds obvious, but the fifty-percent-savings number is a strong pull toward "batch everything." That pull is the exam's favorite trap — more on that two slides down.
-->

---

<CalloutBox variant="warn" title="Hard constraint -- no multi-turn tool calling">
  <v-clicks>
    <p>Batch does <strong>not</strong> support multi-turn tool calling within a single request.</p>
    <p>You cannot execute tools mid-request and feed results back. Any agentic workflow that depends on the <code>tool_use -> tool_result -> continuation</code> loop -- which is <strong>most</strong> agentic workflows -- cannot run on the batch API.</p>
    <p>Batch is for single-shot requests. If your prompt requires tool execution and continuation, synchronous is mandatory. Task 4.5.</p>
  </v-clicks>
</CalloutBox>

<!--
Here's a limitation most people don't know, and the exam tests it. Batch does not support multi-turn tool calling within a single request. You cannot execute tools mid-request and feed results back. That means any agentic workflow that depends on the tool_use → tool_result → continuation loop — which is most agentic workflows — cannot run on the batch API. Batch is for single-shot requests. If your prompt requires tool execution and continuation, synchronous is mandatory. This is Task 4.5 in the exam guide.
-->

---

<script setup>
const customIdCode = `{
  "requests": [
    {
      "custom_id": "doc-S3-key-abc123",
      "params": {
        "model": "claude-opus-4-7",
        "max_tokens": 1024,
        "messages": [...]
      }
    },
    {
      "custom_id": "doc-S3-key-def456",
      "params": {...}
    }
  ]
}

// After the batch completes, responses are keyed by
// custom_id. You match response <-> doc without ambiguity.`
</script>

<CodeBlockSlide
  eyebrow="custom_id -- correlation key"
  title="Each batch request carries a custom_id"
  lang="json"
  :code="customIdCode"
  annotation="Without custom_id, you'd match by order -- which breaks if anything is dropped. With it, you have a stable primary key. Deep dive in 6.13."
/>

<!--
Each batch request carries a custom_id — a string you assign that lets you match response to request after the batch completes. If you submit a thousand documents in a batch, you tag each with a custom_id — say, the document's S3 key or database row ID — and when results come back, you correlate. Without custom_id, you'd have to match by order, which breaks if anything is dropped. We go deep on this in 6.13 — for now, know the field exists and it's your primary correlation key.
-->

---

<CalloutBox variant="warn" title="Sample Q11 -- the both-workflows distractor">
  <v-clicks>
    <p>Team has two workflows: <strong>a blocking pre-merge check</strong> and <strong>an overnight technical-debt report</strong>. Manager proposes switching both to batch for the 50% savings.</p>
    <p><strong>Correct answer:</strong> batch the overnight report only. Keep sync for pre-merge.</p>
    <p>Distractors are variants of &ldquo;batch everything with a fallback&rdquo; or &ldquo;batch everything with status polling.&rdquo; All wrong -- they paper over the fact that batch can't serve a blocking workflow with any SLA.</p>
    <p>Almost-right is the whole trap of this exam, and Q11 is a clean example.</p>
  </v-clicks>
</CalloutBox>

<!--
Sample Q11 from the official exam guide. Team has two workflows: a blocking pre-merge check and an overnight technical-debt report. Manager proposes switching both to batch for the fifty-percent savings. Correct answer: batch the overnight report only, keep sync for pre-merge. The distractors are variants of "batch everything with a fallback" or "batch everything with status polling." All wrong — they try to paper over the fact that batch can't serve a blocking workflow with any SLA. Almost-right is the whole trap of this exam, and Q11 is a clean example.
-->

---

<CalloutBox variant="tip" title="Continuity -- two scenarios, same API">
  <v-clicks>
    <p><strong>Scenario 5 (CI/CD):</strong> batch on overnight technical-debt reports vs blocking pre-merge checks.</p>
    <p><strong>Scenario 6 (extraction):</strong> batch on document processing pipelines.</p>
    <p>Six-pick-four: either could show up, both could show up. The batch API is the shared hinge. That's why this lecture is pinned in the middle of Domain 4.</p>
  </v-clicks>
</CalloutBox>

<!--
Scenario 5 — Claude Code for CI/CD — tests batch on overnight technical-debt reports versus blocking pre-merge checks. Scenario 6 — structured data extraction — tests batch on document processing pipelines. Two scenarios, same API, different framings. Remember the six-pick-four: either could show up, both could show up, and the batch API is the shared hinge. That's why this lecture is pinned in the middle of Domain 4.
-->

---

<ClosingSlide nextLecture="6.12 -- Matching API Choice to Latency Requirements" />

<!--
Carry this forward as three facts: fifty percent cheaper, up to 24 hours, no latency SLA. Plus one hard constraint: no multi-turn tool calling within a batch request. Next lecture, 6.12, we turn this into a decision framework — matching API choice to workflow latency requirements. You'll walk out with a matrix you can apply directly to exam stems. See you there.
-->

---

<!-- LECTURE 6.12 — Matching API Choice to Latency -->

<CoverSlide
  title="Matching API Choice to Latency"
  subtitle="Latency drives the API. Cost savings live on the batch row."
  eyebrow="Domain 4 · Lecture 6.12"
  :stats="['Section 6', 'Scenarios 5 & 6', 'Domain 4 · 20%', '7 min']"
/>

<!--
From 6.11 you know the facts about the batch API. This lecture makes them operational. Seven minutes. The single decision rule, a matrix of workflows to API choices, the SLA math for batch cadence, and the answer to the Sample Q11 trap restated plainly. If the exam asks "which API for this workflow?", this lecture is the one that gets you to the right pick in five seconds.
-->

---

<ConceptHero
  leadLine="Latency drives the API, not cost savings."
  concept="How long can the caller wait?"
  supportLine="Seconds -> sync. Milliseconds -> sync. Hours -> batch. Days -> batch. The 50% savings is a reward for tolerating the 24-hour window -- not a reason to push a workflow into batch when it doesn't tolerate it."
/>

<!--
Here's the decision rule. Latency drives the API, not cost savings. How long can the caller wait? Seconds — sync. Milliseconds — sync. Hours — batch. Days — batch. That's the entire framework. The fifty-percent savings is a reward you get when the workflow tolerates the 24-hour window — not a reason to push a workflow into batch when it doesn't. The mental move: match each workflow to its latency budget, then optimize cost within that constraint.
-->

---

<script setup>
const matrixRows = [
  {
    label: 'Pre-merge PR check',
    cells: [
      { text: 'Seconds', highlight: 'neutral' },
      { text: 'Sync', highlight: 'good' },
    ],
  },
  {
    label: 'IDE autocomplete',
    cells: [
      { text: 'Milliseconds', highlight: 'neutral' },
      { text: 'Sync', highlight: 'good' },
    ],
  },
  {
    label: 'Interactive chat',
    cells: [
      { text: 'Seconds', highlight: 'neutral' },
      { text: 'Sync', highlight: 'good' },
    ],
  },
  {
    label: 'Overnight tech-debt report',
    cells: [
      { text: 'Hours', highlight: 'neutral' },
      { text: 'Batch', highlight: 'good' },
    ],
  },
  {
    label: 'Weekly audit',
    cells: [
      { text: 'Days', highlight: 'neutral' },
      { text: 'Batch', highlight: 'good' },
    ],
  },
  {
    label: 'Monthly compliance scan',
    cells: [
      { text: 'Days', highlight: 'neutral' },
      { text: 'Batch', highlight: 'good' },
    ],
  },
]
</script>

<ComparisonTable
  eyebrow="API by workflow"
  title="Draw this matrix from memory"
  :columns="['Latency tolerance', 'API']"
  :rows="matrixRows"
/>

<!--
Here's the matrix you should be able to draw from memory. Pre-merge PR check: tolerance seconds, API sync. IDE autocomplete: tolerance milliseconds, API sync. Interactive chat: tolerance seconds, API sync. Overnight tech-debt report: tolerance hours, API batch. Weekly audit: tolerance days, API batch. Monthly compliance scan: tolerance days, API batch. The pattern is clean — short tolerance means sync, long tolerance means batch. Cost savings live on the batch row, which is why we pick it when we can.
-->

---

<CalloutBox variant="tip" title="SLA math -- batch cadence">
  <v-clicks>
    <p>You have a <strong>30-hour</strong> delivery SLA on a report. Batch takes up to <strong>24 hours</strong>.</p>
    <p>Submit once at the last minute -> you'd need 6-hour completion, which isn't guaranteed. Risk the SLA.</p>
    <p><strong>Submit every 4 hours</strong> -- any given batch has up to 24 hours to complete; worst-case delivery from job submission is <strong>4 + 24 = 28 hours</strong>, under your 30-hour SLA.</p>
    <p>Task 4.5 in the exam guide. Memorize the cadence calculation.</p>
  </v-clicks>
</CalloutBox>

<!--
Practical math that the exam tests. You have a 30-hour delivery SLA on a report. Batch takes up to 24 hours. If you submit once at the last minute, you risk missing the SLA — you'd need completion in six hours, which isn't guaranteed. The move: submit every 4 hours. That way any given batch has up to 24 hours to complete, and your worst-case delivery from job submission is 4 hours plus 24, which is 28 — under your 30-hour SLA. This is Task 4.5 in the exam guide. Memorize the cadence calculation.
-->

---

<CalloutBox variant="tip" title="Hybrid workflows -- split the workload">
  <v-clicks>
    <p>Same team often uses <strong>both APIs</strong>: pre-merge sync, overnight tech-debt batch.</p>
    <p>Not a contradiction -- it is the right architecture. Different workflows, different latency budgets, different API choices, same team, same codebase.</p>
    <p>Mature engineering orgs run three or four distinct workflows across both APIs, each matched to its own latency budget. You pick <strong>per workflow</strong>, not per team.</p>
  </v-clicks>
</CalloutBox>

<!--
The same team may use both APIs. Pre-merge sync, overnight tech-debt batch. That is not a contradiction — it is the right architecture. Different workflows, different latency budgets, different API choices, same team, same codebase. The instinct to pick one API for the whole team is wrong. You pick per workflow. This is exactly the Sample Q11 framing, which we cover next. And this pattern scales — a mature engineering org often runs three or four distinct workflows across both APIs, each matched to its own latency budget.
-->

---

<CalloutBox variant="warn" title="Sample Q11 restated -- the fork">
  <v-clicks>
    <p>Two workflows: blocking pre-merge and overnight tech-debt. Manager wants 50% savings, proposes batch for both.</p>
    <p><strong>Right answer:</strong> batch for the tech-debt report, sync for pre-merge. &ldquo;Both&rdquo; -- running each on its appropriate API -- is the only correct answer.</p>
    <ul>
      <li>Options B and D: batch everything with fallback logic -> wrong (paper over a hard constraint).</li>
      <li>Option C: keep both on sync -> wastes money.</li>
      <li>Option A: sync for blocking, batch for overnight -> clean fork.</li>
    </ul>
  </v-clicks>
</CalloutBox>

<!--
Sample Q11 restated. Two workflows: blocking pre-merge and overnight tech-debt. Manager wants fifty-percent savings, proposes batch for both. The right answer is: batch for the tech-debt report, sync for pre-merge. "Both" — running each on its appropriate API — is the only correct answer. Options B and D in the sample try to batch everything with fallback logic; they're wrong because they paper over a hard constraint. Option C keeps both on sync; it wastes money. Option A — sync for blocking, batch for overnight — is the clean fork.
-->

---

<script setup>
const badBatchAll = `# "Batch everything for 50% savings."
#   - Pre-merge: batch
#   - Interactive chat: batch
#   - Nightly tests: batch
# Ignores the latency budget of the blocking workflows.`

const goodMixed = `# Match each workflow to its latency budget first,
# then apply cost optimization within that.
#   - Pre-merge: sync (seconds budget)
#   - Interactive chat: sync (seconds budget)
#   - Nightly tests: batch (hours budget) -> 50% savings`
</script>

<AntiPatternSlide
  title="Don't chase savings into a blocking workflow"
  lang="text"
  :badExample="badBatchAll"
  whyItFails="Looks like good engineering. Ignores the latency budget of the blocking workflow."
  :fixExample="goodMixed"
/>

<!--
The anti-pattern is the "batch everything for fifty percent savings" move. It looks like good engineering — lower costs, simpler architecture, one API to learn. It's wrong because it ignores the latency budget of the blocking workflow. The replacement: match each workflow to its latency budget first, then apply cost optimization within that. You will see this anti-pattern in multiple exam distractors. Almost-right is the trap — batch for cost savings is plausible in a different context, but not over a blocking workflow.
-->

---

<CalloutBox variant="tip" title="On the exam -- blocking + batch = distractor">
  <v-clicks>
    <p>Any question that pairs <strong>&ldquo;blocking&rdquo;</strong> with <strong>&ldquo;batch&rdquo;</strong> in the correct-answer framing is a distractor. Batch doesn't fit blocking. Period.</p>
    <p>Stem mentions <em>pre-merge</em>, <em>developers waiting</em>, <em>interactive UI</em> -> <strong>sync</strong>.</p>
    <p>Stem mentions <em>overnight</em>, <em>weekly</em>, <em>nightly generation</em> -> <strong>batch</strong>.</p>
    <p>Read the stem for the latency word, not the cost word. Scenarios 5 and 6 both touch this.</p>
  </v-clicks>
</CalloutBox>

<!--
On the exam, any question that pairs "blocking" with "batch" in the correct-answer framing is a distractor. Batch doesn't fit blocking workflows. Period. If the stem mentions "pre-merge check" or "developers waiting" or "interactive UI," sync wins. If the stem mentions "overnight" or "weekly" or "nightly generation," batch wins. Read the stem for the latency word, not the cost word. Scenarios 5 and 6 both touch this — Scenario 5 on CI/CD workflows, Scenario 6 on document extraction pipelines — so the question of matching API to latency can land from two directions. Same rule applies either way.
-->

---

<ClosingSlide nextLecture="6.13 -- Batch Failure Handling with custom_id" />

<!--
Carry this forward: latency drives the API, same team often uses both, and the SLA math for batch cadence is simple — submit at an interval that covers your worst case. Next lecture, 6.13, we go into batch failure handling — what goes wrong mid-batch, how custom_id saves you, and why resubmitting the whole batch is an expensive distractor. See you there.
-->

---

<!-- LECTURE 6.13 — Batch Failure Handling with custom_id -->

<CoverSlide
  title="Batch Failure Handling with custom_id"
  subtitle="Your resubmission primary key. Resubmit the five, not the thousand."
  eyebrow="Domain 4 · Lecture 6.13"
  :stats="['Section 6', 'Scenario 6', 'Domain 4 · 20%', '7 min']"
/>

<!--
Third and final lecture in the batch-processing triplet. Seven minutes. We covered what batch is (6.11) and when to pick it (6.12). Now we handle what goes wrong mid-batch and how to recover cleanly. The unifying primitive is custom_id — your resubmission primary key. Without it, failures force you to resubmit the entire batch; with it, you resubmit only the failures. That's the exam question, and it's also how you don't blow through your token budget in production.
-->

---

<ConceptHero
  leadLine="A stable ID tied to each request -- your primary key across the whole lifecycle."
  concept="Your correlation key"
  supportLine="custom_id ties request to response -- and to retries. Without it, you can't tell which response belongs to which input document."
/>

<!--
Here's what custom_id is. A string you assign to each request in the batch — typically a stable identifier like a document ID, an S3 key, or a database primary key. It ties the request to the response, and — just as important — it ties the request to retries. Without a custom_id, you can't tell which response belongs to which input document. With it, you have a stable primary key across the whole lifecycle of a document through batch processing.
-->

---

<script setup>
const customIdSchema = `{
  "requests": [
    {
      "custom_id": "doc-row-1847",      // <- your stable ID
      "params": {
        "model": "claude-opus-4-7",
        "max_tokens": 1024,
        "tools": [...],
        "tool_choice": {"type": "any"},
        "messages": [...]
      }
    },
    {
      "custom_id": "doc-row-1848",
      "params": {...}
    }
  ]
}`
</script>

<CodeBlockSlide
  eyebrow="Schema"
  title="A batch request carries custom_id + params"
  lang="json"
  :code="customIdSchema"
  annotation="For a 1,000-document extraction job, your custom_ids might be the document's row ID -- so downstream processing writes back to the same row without ambiguity."
/>

<!--
Every batch request carries a custom_id field. Each request object in your batch has a custom_id and a params block — the params is your actual Messages API call, and the custom_id is your label. After the batch completes, responses come back keyed by custom_id. You join responses to inputs by that key. For a thousand-document extraction job, your custom_ids might be the document's row ID in your database, so downstream processing writes back to the same row without ambiguity.
-->

---

<script setup>
const failureModes = [
  { label: 'Document exceeded context limit', detail: 'Token count too high for the model -- needs chunking.' },
  { label: 'Rate limits mid-batch', detail: 'A burst partway through the job hits a rate ceiling.' },
  { label: 'Schema validation rejected', detail: 'Specific document produced output that failed schema validation.' },
  { label: 'Transient model errors', detail: 'Individual requests flake -- retry typically resolves.' },
]
</script>

<BulletReveal
  eyebrow="Failure modes"
  title="What fails mid-batch -- individual requests, not the whole batch"
  :bullets="failureModes"
/>

<!--
Here's what fails mid-batch. One: a document exceeded the context limit — token count too high for the model. Two: rate limits hit partway through. Three: a specific document produced output that failed schema validation. Four: transient model errors on individual requests. The batch as a whole doesn't fail — individual requests within it do. Your job is to identify which requests failed, fix the root cause for those, and resubmit only them. Not the thousand, the five.
-->

---

<script setup>
const resubmitSteps = [
  { title: 'Batch completes', body: "Mix of successes and failures -- the batch as a whole didn't fail." },
  { title: 'Identify failures by custom_id', body: 'Iterate results, find the five out of one thousand that failed.' },
  { title: 'Apply the fix per failure type', body: 'Chunk oversized docs, adjust prompts for schema-validation failures.' },
  { title: 'Resubmit only the failed docs', body: 'Reuse the original custom_ids. Downstream waits for the second batch.' },
]
</script>

<StepSequence
  eyebrow="Resubmission pattern"
  title="Selective resubmit by custom_id"
  :steps="resubmitSteps"
/>

<!--
Here's the pattern. Step one: batch completes — mix of successes and failures. Step two: iterate the results, identify failures by custom_id. Step three: apply the fix for each failure type — chunk the oversized documents, adjust prompts for the schema-validation failures. Step four: resubmit only the failed documents, reusing their original custom_ids. Your downstream system just waits for the second batch — the successful results from batch one are already written, the failed ones get re-attempted. Clean, idempotent, token-efficient.
-->

---

<script setup>
const chunkingCode = `# Doc X exceeded context -- chunk and resubmit
original_id = "doc-X"

chunks = split_doc(doc_X, max_tokens=80_000)
# -> ["doc-X-chunk-A", "doc-X-chunk-B", "doc-X-chunk-C"]

resubmit_batch([
  {"custom_id": f"{original_id}-chunk-{c.label}", "params": c.params}
  for c in chunks
])

# Merge the three extractions back under original_id
# in post-processing. custom_id lineage preserves traceability.`
</script>

<CodeBlockSlide
  eyebrow="Chunking example"
  title="Chunk oversize docs and resubmit"
  lang="python"
  :code="chunkingCode"
  annotation="Exam guide Task 4.5 -- 'chunking documents that exceeded context limits.' Memorize 'chunking' as the move for oversize failures."
/>

<!--
Concrete example. Document X exceeded the context limit. You chunk it into three sections — say, sections A, B, and C. You derive new custom_ids by extending the original: doc-X-chunk-A, doc-X-chunk-B, doc-X-chunk-C. You resubmit these three in the next batch. When they complete, you merge the three extractions in post-processing back under the original doc-X identifier. The custom_id lineage preserves traceability. You didn't lose the document — you just processed it in chunks that fit. This is the exam guide's exact phrasing under Task 4.5 — "chunking documents that exceeded context limits." Memorize "chunking" as the move for oversize failures.
-->

---

<CalloutBox variant="tip" title="Scale discipline -- refine before you scale">
  <v-clicks>
    <p>Before batch-processing <strong>10,000</strong> documents, refine your prompt on a sample of <strong>50</strong>.</p>
    <p>If your prompt has a subtle bug, you want to find it at document 50 -- not at document 6,000, after 20 hours of batch runtime.</p>
    <p>Exam guide Task 4.5: <em>&ldquo;using prompt refinement on a sample set before batch-processing large volumes to maximize first-pass success rates.&rdquo;</em></p>
    <p>The alternative is burning $100 of batch before you notice the error.</p>
  </v-clicks>
</CalloutBox>

<!--
Scale discipline. Before batch-processing ten thousand documents, refine your prompt on a sample of fifty. If your prompt has a subtle bug, you want to find it at document fifty — not at document six thousand, after twenty hours of batch runtime. This is the exam guide's exact phrasing under Task 4.5 — "using prompt refinement on a sample set before batch-processing large volumes to maximize first-pass success rates." The alternative is burning through a hundred dollars' worth of batch before you notice the error.
-->

---

<CalloutBox variant="tip" title="On the exam -- resubmit only the failed docs">
  <v-clicks>
    <p>Stem: <em>&ldquo;how do you handle batch failures?&rdquo;</em></p>
    <p>Right answer: <strong>resubmit only the failed documents, identified by custom_id, with appropriate modifications.</strong></p>
    <p>Distractor: <em>&ldquo;resubmit the whole batch.&rdquo;</em> Sounds safer and simpler. Doubles your costs for no reason.</p>
    <p>Almost-right trap: whole-batch resubmission is wasteful and wrong. The exam rewards per-request recovery.</p>
  </v-clicks>
</CalloutBox>

<!--
On the exam, the right answer to "how do you handle batch failures?" is: resubmit only the failed documents, identified by custom_id, with appropriate modifications. "Resubmit the whole batch" is the distractor — it's wasteful and wrong. Almost-right is the trap: whole-batch resubmission sounds safer and simpler, but it doubles your costs for no reason. The exam rewards per-request recovery, not all-or-nothing. And remember the thread from 6.11 and 6.12 — the batch API has constraints you're architecting around, not hoping will go away. custom_id is one of the primitives that makes batch usable at scale.
-->

---

<ClosingSlide nextLecture="6.14 -- Multi-Instance Review Architecture" />

<!--
Carry this forward: custom_id is your correlation and resubmission key — use stable IDs, identify failures by custom_id, chunk oversized docs with derived IDs, and resubmit only the failures. Next lecture, 6.14, we shift from batch to review architecture — why a second independent Claude instance catches what self-review misses, and why "extended thinking" doesn't fix the underlying bias. See you there.
-->

---

<!-- LECTURE 6.14 — Multi-Instance Review Architecture -->

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
  attribution="Reasoning-context bias -- the phrase to memorize"
/>

<!--
Here's the thesis. The model retains reasoning context from generation. It is less likely to question decisions it already justified. That's the bias. When you ask the same session to "now review your work," it's reviewing with the justifications already in context — and models, like humans, don't readily contradict their own recent reasoning. The self-review produces thumbs-up on bad code because the model already talked itself into the code being okay.
-->

---

<ConceptHero
  leadLine="The fix is architectural, not prompt-level."
  concept="Two instances, two contexts"
  supportLine="Instance A generates. Instance B is a fresh session -- zero knowledge of how the code got written. B reviews cold, with no self-justification bias."
/>

<!--
The fix is architectural, not prompt-level. Two instances. Two separate contexts. Instance A generates the code — runs the whole generation session with all its reasoning, drafts, and revisions. Instance B is a fresh session — zero knowledge of how the code got written. Instance B reviews the code cold. Fresh context, no self-justification bias, willing to disagree with decisions it wasn't part of making. This is the anchor concept for multi-instance review.
-->

---

<script setup>
const architectureSteps = [
  { label: 'Instance A generates code', sublabel: 'Full generation session -- drafts, reasoning, revisions' },
  { label: 'Output committed', sublabel: 'Written to a file, a PR, a shared artifact' },
  { label: 'Instance B (fresh session)', sublabel: "Receives code + CLAUDE.md + criteria -- not A's reasoning" },
  { label: 'B reviews without bias', sublabel: 'No generator context to defer to. Willing to disagree.' },
]
</script>

<FlowDiagram
  eyebrow="Architecture"
  title="Independent review -- four steps"
  :steps="architectureSteps"
/>

<!--
Here's the architecture in four steps. One: Instance A generates the code. Two: the output is committed — written to a file, a PR, a shared artifact. Three: Instance B, a fresh Claude session, receives the code plus the project's CLAUDE.md and review criteria — but not Instance A's reasoning chain. Four: Instance B reviews without the generator's context. The separation is physical — two API calls in two different sessions — not just a prompt instruction to "pretend you didn't write this."
-->

---

<CalloutBox variant="warn" title="vs extended thinking -- different tool, different problem">
  <v-clicks>
    <p>Extended thinking -- where the model produces a longer reasoning trace before its final output -- <strong>does not</strong> address self-justification bias.</p>
    <p>Extended thinking still shares context with the generation. Same session, longer internal monologue. More reasoning <em>inside</em> the same context <strong>reinforces</strong> existing conclusions -- it doesn't question them.</p>
    <p>If the bias is self-justification, more thinking in the same session makes it worse. Multi-instance is the right fix. Extended thinking is a different tool for a different problem.</p>
  </v-clicks>
</CalloutBox>

<!--
Here's the trap. Extended thinking — where the model produces a longer reasoning trace before its final output — does not address self-justification bias. Extended thinking still shares context with the generation. It's the same session, just with a longer internal monologue. More reasoning inside the same context reinforces existing conclusions; it doesn't question them. If the bias is self-justification, more thinking in the same session makes it worse, not better. Multi-instance is the right fix. Extended thinking is a different tool for a different problem.
-->

---

<CalloutBox variant="tip" title="Confidence self-report -- optional overlay">
  <v-clicks>
    <p>Have reviewer <strong>Instance B</strong> output per-finding confidence alongside each finding.</p>
    <p>High confidence -> developer directly. Low confidence -> human review.</p>
    <p>Exam guide Task 4.6: <em>&ldquo;running verification passes where the model self-reports confidence alongside each finding.&rdquo;</em></p>
    <p>One schema field, dramatic improvement in routing quality. Deeper in Section 7.</p>
  </v-clicks>
</CalloutBox>

<!--
An optional overlay for more calibrated routing. Have the reviewer Instance B output per-finding confidence alongside each finding. High-confidence findings go to the developer directly. Low-confidence findings route to human review. This is Task 4.6 in the exam guide — "running verification passes where the model self-reports confidence alongside each finding." It adds one field to the output schema and it dramatically improves routing quality. We'll see a deeper version of confidence-based routing in Section 7.
-->

---

<CalloutBox variant="tip" title="Callback to 5.14 -- same principle, different layer">
  <v-clicks>
    <p>Section <strong>5.14</strong> covered <em>session context isolation for independent code review</em> -- the fresh-session-in-CI pattern for Claude Code.</p>
    <p>This lecture is the <strong>architectural generalization</strong> of that same principle.</p>
    <p>Domain 3 applies it inside the Claude Code workflow. Domain 4 applies it at the API layer with two Claude instances. The exam can test either.</p>
    <p>Underlying concept -- <em>reasoning-context bias</em> -- is the same.</p>
  </v-clicks>
</CalloutBox>

<!--
Callback to Section 5. Lecture 5.14 covered "session context isolation for independent code review" — the fresh-session-in-CI pattern for Claude Code. This lecture is the architectural generalization of that same principle. Domain 3 applied it inside the Claude Code workflow; Domain 4 applies it at the API layer with two Claude instances. Same principle, different layer. The exam can test either, and the underlying concept is reasoning-context bias.
-->

---

<script setup>
const badSelfReview = `# Single session prompt:
Write the function.
Then review your work and flag issues.

# Feels clever -- cheap, in-session, no extra infrastructure.
# Doesn't work.`

const goodSelfReview = `# Two API calls, two sessions:

# Session A: generate code
code = claude.generate(task, context)
commit(code)

# Session B: fresh -- no A context
review = claude.review(code, claude_md, criteria)`
</script>

<AntiPatternSlide
  title="Don't append 'now critique yourself'"
  lang="text"
  :badExample="badSelfReview"
  whyItFails="The generator's reasoning context is still loaded -- the 'review' rubber-stamps the decisions the model already made."
  :fixExample="goodSelfReview"
/>

<!--
The anti-pattern is appending "now review your work" to the generation prompt. It feels clever — cheap, in-session, no extra infrastructure. It doesn't work. The generator's reasoning context is still loaded, so the "review" just rubber-stamps the decisions the model already made. The replacement is a separate API call in a separate session with no generator reasoning context. Two calls, two contexts, actual independence.
-->

---

<CalloutBox variant="tip" title="On the exam -- the exact phrase">
  <v-clicks>
    <p>Stem: <em>&ldquo;why is an independent review instance more effective than self-review?&rdquo;</em></p>
    <p>Correct answer uses the phrase <strong>reasoning context bias</strong> (or equivalent) -- the generator retains context from its own reasoning and is less likely to question prior decisions.</p>
    <p>Distractors: <em>&ldquo;the independent instance is a different model,&rdquo;</em> <em>&ldquo;extended thinking achieves the same result.&rdquo;</em> Both wrong. The right answer is about <strong>context separation</strong>.</p>
  </v-clicks>
</CalloutBox>

<!--
On the exam, the question often reads: "why is an independent review instance more effective than self-review?" The correct answer uses the phrase "reasoning context bias" or equivalent — the generator retains context from its own reasoning and is less likely to question prior decisions. Memorize that phrasing. Distractors will suggest "the independent instance is a different model" or "extended thinking achieves the same result" — both wrong. The right answer is about context separation.
-->

---

<ClosingSlide nextLecture="6.15 -- Multi-Pass Review: Per-File + Cross-File Integration Pass" />

<!--
Carry this forward: self-review fails because of reasoning-context bias, and the fix is architectural — two instances, two contexts, separated by a clean API boundary. Extended thinking doesn't address this. Next lecture, 6.15, we close Domain 4 with the other half of review architecture: multi-pass review. Per-file for local issues, plus one cross-file integration pass. See you there.
-->

---

<!-- LECTURE 6.15 — Per-File + Cross-File Review -->

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
  attribution="Attention dilution -- the core failure"
/>

<!--
Here's the failure mode in one sentence. One prompt reviewing forty files finds nothing useful in any file. Tokens spread too thin across too many files, and the model ends up with superficial comments on some, obvious bugs missed on others, and — worst — contradictory findings where the same pattern is flagged in one file and approved in another within the same review. This is attention dilution. It's not a model-size problem. It's a prompt-shape problem.
-->

---

<ConceptHero
  leadLine="Each pass is focused on one kind of problem. Findings compose cleanly."
  concept="Two passes, two jobs"
  supportLine="Per-file pass for local issues. Cross-file pass for integration. Same decomposition principle as subagent delegation from Domain 1 -- focused steps, each with its own context budget."
/>

<!--
The fix. Two passes, two jobs. Per-file pass for local issues. Cross-file pass for integration. Each pass is focused on one kind of problem, and the findings compose cleanly. You're not asking the model to hold forty files' worth of context and reason across all of them at once — you're asking it to do one well-scoped task per pass. Same principle as subagent delegation from Domain 1: decompose into focused steps, each with its own context budget.
-->

---

<CalloutBox variant="tip" title="Per-file pass -- local issues">
  <v-clicks>
    <p>Bugs in <em>one</em> file. Style within <em>one</em> file. Function-scope logic -- off-by-one, missing null-check, unhandled exception inside a single function.</p>
    <p>The pass sees <strong>one file at a time</strong>, with whatever surrounding <code>CLAUDE.md</code> rules apply. Does not reason about how this file interacts with another.</p>
    <p>One file in, findings out. Run in <strong>parallel</strong> across every file in the changeset -- they're independent.</p>
  </v-clicks>
</CalloutBox>

<!--
The per-file pass handles local issues. Bugs in one file. Style within one file. Function-scope logic — off-by-one, missing null-check, unhandled exception inside a single function. The pass sees one file at a time, with whatever surrounding CLAUDE.md rules apply. It does not try to reason about how this file interacts with another. One file in, findings out. Do this for every file in the changeset in parallel — they're independent.
-->

---

<CalloutBox variant="tip" title="Cross-file pass -- integration">
  <v-clicks>
    <p><strong>Data flow</strong> across modules -- does this new field in File A get read correctly in File B?</p>
    <p><strong>Interface contracts</strong> -- did someone change a function signature in File C without updating callers in Files D and E?</p>
    <p><strong>Import/export mismatches.</strong></p>
    <p>Sees the relevant files together -- not necessarily all forty, but the files that interact. Looking for <em>seams</em>, not local logic.</p>
  </v-clicks>
</CalloutBox>

<!--
The cross-file pass handles integration concerns. Data flow across modules — does this new field in File A get read correctly in File B? Interface contracts — did someone change a function signature in File C without updating the callers in Files D and E? Import/export mismatches. This pass sees the relevant files together — not necessarily all forty, but the files that interact. It's looking for seams, not local logic.
-->

---

<script setup>
const flowSteps615 = [
  { label: 'Split changeset by file', sublabel: '40 files in -> 40 independent reviews + 1 integration pass' },
  { label: 'Per-file pass (parallel)', sublabel: 'One file per prompt. Local issues only.' },
  { label: 'Aggregate local findings', sublabel: 'Collect the output of the per-file passes.' },
  { label: 'Cross-file pass', sublabel: 'Integration-facing files sent together. Data flow + contracts.' },
  { label: 'Combine findings', sublabel: 'Per-file + cross-file merged into the final review.' },
]
</script>

<FlowDiagram
  eyebrow="Architecture"
  title="Two-pass review -- five steps"
  :steps="flowSteps615"
/>

<!--
Here's the flow. Step one: split the changeset into individual files. Step two: per-file pass — one file per prompt, local issues only. These can run in parallel. Step three: aggregate all local findings. Step four: cross-file pass — the integration-facing files sent together, one prompt, looking for data flow and contract issues. Step five: combine the per-file and cross-file findings into the final review output. Clean decomposition, clear responsibilities, no attention dilution.
-->

---

<CalloutBox variant="tip" title="Callback to Domain 1 -- prompt chaining">
  <v-clicks>
    <p>This is <strong>prompt chaining</strong> -- fixed, sequential decomposition where each step has a defined input and output.</p>
    <p>Domain 1 Task 1.6 covers this as the general pattern; multi-pass review is the specific application of that pattern to code review.</p>
    <p>Anchor concept across both domains: <strong>focus the context, compose the outputs</strong>.</p>
  </v-clicks>
</CalloutBox>

<!--
Callback to Domain 1. This is prompt chaining — fixed, sequential decomposition where each step has a defined input and a defined output. Domain 1 Task 1.6 covers this as the general pattern; multi-pass review is the specific application of that pattern to code review. The reason the exam tests this in Domain 4 is that the review use case is the cleanest example of prompt chaining paying off. The anchor concept is the same across both domains: focus the context, compose the outputs.
-->

---

<script setup>
const badReview = `# One prompt:
# "Review this PR: 40 files attached. Flag bugs,
# integration issues, style issues. Be thorough."
# -> superficial comments, missed bugs, contradictory findings`

const goodReview = `# Per-file pass (parallel): 40 focused reviews
for f in changeset.files:
    local_findings += claude.review_file(f, claude_md)

# One cross-file pass on the interacting files
integration_findings = claude.review_integration(
    interacting_files, claude_md
)`
</script>

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

<CalloutBox variant="tip" title="On the exam -- both passes, not just one">
  <v-clicks>
    <p>Stem: <em>&ldquo;large reviews miss issues&rdquo;</em> or <em>&ldquo;inconsistent results across files&rdquo;</em> -> <strong>multi-pass</strong>.</p>
    <p>Critically -- <strong>both passes</strong>, not just one.</p>
    <p>If a distractor says <em>&ldquo;only per-file review&rdquo;</em> or <em>&ldquo;only cross-file review,&rdquo;</em> that's the trap. Per-file misses integration. Cross-file misses local.</p>
    <p>Sample Q12's correct answer lists both passes explicitly.</p>
  </v-clicks>
</CalloutBox>

<!--
On the exam, when the stem says "large reviews miss issues" or "inconsistent results across files," the right answer is multi-pass. And critically — both passes, not just one. If a distractor says "only per-file review" or "only cross-file review," that's the trap. Per-file misses integration issues. Cross-file misses local issues. You need both. Sample Q12's correct answer lists both passes explicitly. Almost-right is the whole trap — one pass is plausible in a different context but not here.
-->

---

<ClosingSlide nextLecture="Section 7 -- Domain 5 -- Context Management & Reliability (15%)" />

<!--
That closes Domain 4. Carry this forward: split large reviews into per-file for local and one cross-file for integration — both passes, not just one. And remember the thread that ran through Domain 4 — categorical criteria over confidence adjectives, few-shots for ambiguity, tool_use for reliable structure, batch API for non-blocking workloads, multi-instance for bias-free review. Twenty percent of the exam, high-value-per-study-hour. Next up is Section 7 — Domain 5, Context Management and Reliability. It's the smallest domain at fifteen percent, but it has a higher value-per-study-hour than its weight suggests. Don't skip it because it's small. See you there.
-->
