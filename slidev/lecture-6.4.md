---
theme: default
title: "Lecture 6.4: Crafting Few-Shot Examples for Ambiguous Cases"
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
const reasoningTrace = `Customer message:
"I've been charged twice for the same order and
 nobody's getting back to me."

Reasoning: customer hasn't explicitly asked for a human,
but the compound issue (double-charge + unresponsive
support) is policy-ambiguous.

Action: escalate with summary.`

const scenarioMap = [
  { label: 'Scenario 1 — customer support', detail: 'Borderline escalation cases where the customer hasn\u2019t asked for a human but the compound situation requires one.' },
  { label: 'Scenario 5 — CI/CD review', detail: 'Severity borderlines where CRITICAL blurs into HIGH — SQL-injection-adjacent cases.' },
  { label: 'Scenario 6 — extraction', detail: 'Document format variants — inline citations vs bibliographies, narrative vs tables.' },
]

const nullExample = `Document: "Invoice #1847 — ACME Corp — $2,400.00"

Reasoning: document does not mention customer_email.
No email appears in the body or metadata.

Output:
  invoice_number: "1847"
  total_amount: 2400.00
  customer_email: null`

const badObvious = `# Three examples of clearly CRITICAL bugs
# — SQL-injection, hardcoded secret, unencrypted API call
# (the model already recognizes these)`

const goodBorderline = `# Two examples of BORDERLINE cases
# Example A: sanitized-looking UI input where the regex
#   misses unicode corner cases.
# Example B: an ORM call that looks safe but builds raw
#   SQL via a helper you shipped last month.`
</script>

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
  leadLine="Easy examples teach nothing — the model already gets the easy cases right."
  concept="Choose the edges, not the middle"
  supportLine="The ambiguous cases are what need the examples. Three examples of obvious refund requests wastes your token budget."
/>

<!--
Here's the rule. Choose the edges, not the middle. Easy examples teach nothing — the model already gets the easy cases right. The ambiguous cases are what need the examples. If you're building a support-agent prompt and your few-shots are three examples of obvious refund requests, you've wasted your token budget. The example that moves the needle is the one where the customer's request could go two ways. That's where judgment needs to be shown.
-->

---

<CodeBlockSlide
  eyebrow="Example with reasoning trace"
  title="Input → reasoning → output (not Q/A)"
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
  title="Acceptable pattern vs genuine issue — teach the distinction"
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

<CalloutBox variant="tip" title="Varied document format — Scenario 6 extraction">
  <p>Few-shots earn their keep when document formats vary.</p>
  <p>One example from a doc with <strong>inline citations</strong>. One from a doc with a <strong>bibliography section</strong>. One from a <strong>narrative-only</strong> doc with no explicit citations.</p>
  <p>Exam guide phrasing (Task 4.2): <em>&ldquo;varied document structures: inline citations vs bibliographies, methodology sections vs embedded details.&rdquo;</em></p>
</CalloutBox>

<!--
For Scenario 6 — structured extraction — few-shots earn their keep when document formats vary. One example from a doc with inline citations. One from a doc with a bibliography section. One from a narrative-only doc with no explicit citations. The few-shots teach the model to extract from all three formats. This is the exam guide's exact phrasing — "varied document structures: inline citations vs bibliographies, methodology sections vs embedded details." Task 4.2 tests this directly.
-->

---

<BulletReveal
  eyebrow="Per-scenario ambiguity surface"
  title="Map few-shot needs to the exam scenarios"
  :bullets="scenarioMap"
/>

<!--
Here's how the exam scenarios map to few-shot needs. Scenario 1 — customer support — borderline escalation cases. Scenario 5 — CI/CD review — severity borderlines where CRITICAL blurs into HIGH. Scenario 6 — extraction — document format variants. Each scenario has its own ambiguity surface, and each needs its own two-to-four examples. If you're prepping for the six-pick-four and Scenario 6 is weak for you, this is the exact drill — pick three document-format variants and write the few-shot examples.
-->

---

<AntiPatternSlide
  title="Don't few-shot the obvious"
  lang="text"
  :badExample="badObvious"
  whyItFails="Burns context on reinforcement the model doesn\u2019t need."
  :fixExample="goodBorderline"
/>

<!--
The anti-pattern that wastes tokens and teaches nothing: three examples of clearly CRITICAL bugs. The model already recognizes SQL-injection. You're burning context on reinforcement the model doesn't need. The replacement: two examples of borderline cases where reasoning matters — say, a UI input that looks sanitized but relies on a regex that misses unicode corner cases. That's the case where the model needs help, and that's what earns a slot in your few-shot set.
-->

---

<CodeBlockSlide
  eyebrow="Teach null to prevent fabrication"
  title="Empty-field pattern — include a null example"
  lang="text"
  :code="nullExample"
  annotation="Without a null example, the model feels pressure to fill the field and invents a value. Exam guide, Task 4.2."
/>

<!--
This one shows up on the exam explicitly. For extraction tasks, include an example where the answer is null. "Document does not mention customer_email. Reasoning: no email appears in the body or metadata. Output: customer_email: null." Teaching null prevents fabrication. Without a null example, the model feels pressure to fill the field and invents a value. The exam guide calls this out under Task 4.2 — "adding few-shot examples showing correct extraction from documents with varied formats to address empty/null extraction of required fields." That phrasing will show up in a stem.
-->

---

<CalloutBox variant="tip" title="On the exam — when few-shots is the answer">
  <p>Stem phrasing → few-shots:</p>
  <ul>
    <li><strong>&ldquo;consistent handling of varied formats&rdquo;</strong></li>
    <li><strong>&ldquo;reducing fabrication in extraction&rdquo;</strong></li>
  </ul>
  <p>Distractors: confidence thresholds, longer instructions, bigger models. Plausible elsewhere, wrong here.</p>
  <p>The right move: examples that show reasoning for ambiguous cases, <strong>including at least one null case</strong>.</p>
</CalloutBox>

<!--
On the exam, few-shot examples are the right answer when the stem mentions "consistent handling of varied formats" or "reducing fabrication in extraction." Both phrases point at few-shots. Confidence thresholds sound appealing. Longer instructions sound appealing. They're distractors. The right move is examples that show the reasoning for ambiguous cases and that include at least one null case. Hold onto that — it catches a specific class of Scenario 6 questions.
-->

---

<ClosingSlide nextLecture="6.5 — tool_use with JSON Schemas — The Most Reliable Structured Output" />

<!--
Carry this forward: pick edge cases, include reasoning traces, vary the document format if you're extracting, and always include a null example to prevent fabrication. Next lecture, 6.5, we move from prompt-level techniques to API-level structure: tool_use with JSON schemas — the most reliable structured-output mechanism Claude offers. If you care about zero syntax errors, that's the lecture. See you there.
-->
