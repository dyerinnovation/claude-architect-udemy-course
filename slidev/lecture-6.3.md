---
theme: default
title: "Lecture 6.3: Few-Shot Prompting — When and How"
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
const whenToUse = [
  { label: 'Ambiguous cases', detail: 'Same input could go two ways — judgment is the discriminator.' },
  { label: 'Consistent format required', detail: 'Field names, order, structure must match across outputs.' },
  { label: 'Reducing hallucination in extraction', detail: 'The model keeps inventing fields that aren\u2019t in the source.' },
  { label: 'Teaching judgment, not rules', detail: 'Cases you\u2019d explain by example to a junior engineer.' },
]

const whenNot = [
  { label: 'Prose is already clear and consistent', detail: 'Don\u2019t add examples where the instruction already lands.' },
  { label: 'tool_use with a schema enforces structure', detail: 'The schema is stricter than examples. Use it.' },
  { label: 'Examples would overfit to incidental features', detail: 'Same customer name in every example = model latches onto it.' },
]

const reasoningExample = `Input:  timestamp="2025-01-03T09:30:00Z", customer_tz="America/Los_Angeles"

Reasoning: timestamp is UTC; customer context is PST; convert before presenting.

Output: "January 3, 2025 at 1:30 AM PST"`

const badFewShot = `# Five examples of well-formed JSON
# crammed into the prompt to "teach" JSON output
# — probabilistic; malformed JSON still possible.`

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

<CoverSlide
  title="Few-Shot Prompting: When and How"
  subtitle="When prose produces drift, examples produce consistency. Know the 2–4 rule."
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
  supportLine="Claude generalizes from 2–4 examples better than it follows a paragraph of rules. When prose produces inconsistent output, examples produce consistent output."
/>

<!--
Here's the core claim. When prose produces inconsistent output, examples produce consistent output. Claude generalizes from two-to-four examples better than it follows a paragraph of rules. That's not a trick — it's how the model is trained. You write a three-paragraph instruction trying to cover every edge case, and you still get inconsistent output. You show two examples of what the output should look like, and suddenly the model locks on. The mental move is: stop explaining, start showing.
-->

---

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
  number="2–4"
  unit=" examples"
  caption="Too few doesn't generalize. Too many overfits and bloats tokens."
  detail="Memorize &ldquo;two to four&rdquo; the way you memorized 720 for the passing score. It's a named parameter the exam tests directly."
  accent="var(--sprout-500)"
/>

<!--
The sweet spot is two to four examples. Too few — one — and the model doesn't generalize; it matches the surface pattern of the single example. Too many — eight, twelve — and you get token bloat plus overfitting to incidental features. The exam guide calls this out by the exact number: two to four. Memorize "two to four" the way you memorized "seven twenty" for the passing score. It's a named parameter the exam tests directly.
-->

---

<CodeBlockSlide
  eyebrow="Show reasoning, not just labels"
  title="Each example shows the &ldquo;why&rdquo; — not just input → output"
  lang="text"
  :code="reasoningExample"
  annotation="Q/A pairs aren't few-shot — they're labeled pairs. The reasoning trace is what teaches. Consistent output requires consistent reasoning."
/>

<!--
Here's what most people get wrong. They write examples as Q-colon, A-colon. "Input: X. Output: Y." That's not a few-shot example; that's a labeled pair. The move is to include the reasoning. "Input: X. Because the timestamp is UTC but the customer context is PST, we need to convert. Output: Y." Now the model has a reasoning trace to imitate, not just an input-output mapping. Consistent output requires consistent reasoning, and reasoning has to be shown, not stated.
-->

---

<CalloutBox variant="tip" title="Few-shots lock the output shape">
  <p>Few-shots do a second job beyond teaching judgment: they <strong>lock the output format</strong>.</p>
  <p>If your three examples all output a JSON object with fields in the same order, Claude produces that exact format on the fourth input. Field names, ordering, structure — all contracted. The examples are the specification.</p>
  <p>That's why few-shots and <code>tool_use</code> schemas are both in Domain 4 — two tools for the same output-consistency problem.</p>
</CalloutBox>

<!--
Few-shots do a second job beyond teaching judgment: they lock the output format. If your three examples all output a JSON object with fields in the same order, Claude will produce that exact format on the fourth input. Field names, ordering, structure — all contracted. This is how you get consistent structure without writing a prose specification of the format. The examples are the specification. That's why few-shots and tool_use schemas are both in Domain 4 — they're two tools for the same output-consistency problem.
-->

---

<BulletReveal
  eyebrow="When NOT to few-shot"
  title="The other half — where examples muddy the water"
  :bullets="whenNot"
/>

<!--
Here's the other half. Don't few-shot when prose is already clear and consistent. Don't few-shot when tool_use with a JSON schema already enforces structure — the schema is stricter than examples. And don't few-shot when adding examples would teach overfitting instead of generalization — for instance, if all your examples happen to use the same customer name, the model might latch onto that. Know when examples help and when they muddy the water.
-->

---

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

<CalloutBox variant="tip" title="On the exam — three matches to know cold">
  <p><strong>&ldquo;Inconsistent format&rdquo;</strong> in the stem → few-shots.</p>
  <p><strong>&ldquo;Need JSON guarantees&rdquo;</strong> → tool_use.</p>
  <p><strong>&ldquo;Ambiguous cases&rdquo;</strong> or <strong>&ldquo;teach judgment&rdquo;</strong> → few-shots.</p>
  <p>Read the stem carefully for the word <em>guarantees</em> versus <em>ambiguous</em>. Almost-right: tool_use is plausible whenever structure is mentioned — but judgment ambiguity means few-shots.</p>
</CalloutBox>

<!--
On the exam, know the three matches cold. "Inconsistent format" in the stem — few-shots. "Need JSON guarantees" in the stem — tool_use. "Ambiguous cases" or "teach judgment" in the stem — few-shots. Almost-right is the trap here: tool_use is plausible whenever structure is mentioned, but if the problem is judgment ambiguity rather than format guarantees, few-shots is the right answer. Read the stem carefully for the word "guarantees" versus "ambiguous."
-->

---

<ClosingSlide nextLecture="6.4 — Crafting Few-Shot Examples for Ambiguous Scenarios" />

<!--
Carry this forward: few-shots produce consistency where prose produces drift, two to four examples is the named sweet spot, and each example must show reasoning — not just input and output. Next lecture, 6.4, we go deeper on crafting the examples themselves — how to pick edge cases instead of easy ones, how to handle null and "information absent," and why Scenario 6 extraction work depends on this. See you there.
-->
