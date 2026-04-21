---
theme: default
title: "Lecture 6.10: The detected_pattern Field"
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

const analysisLoop = [
  { label: 'Tag every finding', sublabel: 'detected_pattern on every emission' },
  { label: 'Accept/dismiss signal', sublabel: 'Developer feedback flows into telemetry' },
  { label: 'Aggregate by pattern', sublabel: 'Dismissal rates grouped by detected_pattern' },
  { label: 'Refine or disable', sublabel: 'Patterns above dismissal threshold get tightened — or paused' },
]

const badAggregate = `overall_fp_rate = dismissed_findings / all_findings
# "Our FP rate is 40%." Tells you nothing about what to fix.`

const goodPattern = `fp_by_pattern = group_dismissals_by(detected_pattern)
# sql_injection:       2% dismissed  ✓
# missing_null_check: 80% dismissed  ✗ — fix here
# hardcoded_credential: 5% dismissed ✓
# Now you know exactly where to iterate.`
</script>

<CoverSlide
  title="detected_pattern — Systematic FP Analysis"
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
  supportLine="Add a detected_pattern field identifying what triggered the finding. When developers dismiss, you see the pattern — not the one-off."
/>

<!--
The fix is one schema field. Add a `detected_pattern` field to every finding. Values are named patterns like "unchecked_return_value," "missing_null_check," "hardcoded_credential," "sql_injection." Every finding Claude emits carries its pattern label. Now when developers dismiss findings, the dismissal data is tagged — you see the pattern, not the one-off. "We dismissed eighty percent of missing_null_check findings last week" is actionable. "We dismissed a bunch of stuff" is not.
-->

---

<CodeBlockSlide
  eyebrow="Schema field"
  title="The review finding schema — with detected_pattern"
  lang="json"
  :code="findingSchema"
  annotation="Without detected_pattern, you're analyzing strings. With it, you're analyzing categories."
/>

<!--
Here's what your finding schema looks like. Object fields: file_path string, line_number integer, severity enum of CRITICAL/HIGH/MEDIUM/LOW, description string, and detected_pattern enum of your named patterns. The detected_pattern is the key addition. It's how every downstream dashboard, alerting system, and prompt-tuning iteration groups findings. Without it, you're analyzing strings; with it, you're analyzing categories.
-->

---

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
  <p>You notice <code>missing_null_check</code> findings are being dismissed 80% of the time.</p>
  <p><strong>Move 1:</strong> tighten the criteria — <em>&ldquo;only flag missing_null_check when the value originates from user input or an external API, not when it comes from an ORM with non-null constraints.&rdquo;</em></p>
  <p><strong>Move 2:</strong> if you can't tighten fast enough, disable the pattern temporarily while you iterate.</p>
  <p>Same telemetry tells you when to reinstate — dismissal rate drops, turn it back on with confidence.</p>
</CalloutBox>

<!--
Concrete scenario. You notice missing_null_check findings are being dismissed eighty percent of the time. Two moves. One: tighten the criteria — "only flag missing_null_check when the value originates from user input or an external API, not when it comes from an ORM with non-null constraints." Two: if you can't tighten it fast enough, disable the pattern temporarily while you iterate. The pattern data tells you where to focus. Without it, you might have been tuning the sql_injection prompt — which was already accurate — while missing_null_check kept wrecking developer trust. And once you've fixed the pattern, the same telemetry tells you when to reinstate it — dismissal rate drops, you turn it back on with confidence.
-->

---

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

<CalloutBox variant="tip" title="On the exam — the named field">
  <p>Stem: <em>&ldquo;systematic analysis of dismissal patterns&rdquo;</em> or <em>&ldquo;tracking which code constructs trigger false positives.&rdquo;</em> → add a <code>detected_pattern</code> field.</p>
  <p>Exam guide lists it by exact name under Task 4.4.</p>
  <p>Distractors: &ldquo;increase the model size,&rdquo; &ldquo;add more few-shot examples&rdquo; — plausible elsewhere, wrong here.</p>
  <p>Related cousins: <code>calculated_total</code> vs <code>stated_total</code>, <code>conflict_detected</code> boolean. Same principle — <strong>make invisible signal visible.</strong></p>
</CalloutBox>

<!--
On the exam, the field name matters. If the stem asks about "systematic analysis of dismissal patterns" or "tracking which code constructs trigger false positives," the answer includes adding a detected_pattern field to the structured findings. The exam guide lists it by exact name under Task 4.4. Distractors will suggest "increase the model size" or "add more few-shot examples" — both plausible elsewhere, wrong here. The right answer is the named field. And a related exam-guide pattern worth knowing: self-correction fields like `calculated_total` alongside `stated_total`, or a `conflict_detected` boolean for inconsistent source data. These are cousins of detected_pattern — fields you add to the schema specifically to enable downstream validation or analysis. Same principle: make invisible signal visible.
-->

---

<ClosingSlide nextLecture="6.11 — The Message Batches API: 50% Savings, 24-Hour Window, Limitations" />

<!--
Carry this forward: add a detected_pattern field to every review finding so you can measure dismissal patterns, aggregate by pattern, and fix at the pattern layer. This is Scenario 5's iteration primitive. Next lecture, 6.11, we change gears completely — the Message Batches API. Fifty percent cost savings, a 24-hour processing window, and the limitations that make it right for some workloads and wrong for others. See you there.
-->
