---
theme: default
title: "Lecture 7.10: Coverage Annotations in Synthesis"
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
const coverageCode = `{
  "findings": [
    { "topic": "visual_arts", "summary": "..." }
  ],
  "coverage": {
    "covered": ["visual_arts"],
    "partial": ["music"],
    "gaps": ["writing", "film"]
  },
  "notes": {
    "music": "subagent returned partial — archive source rate-limited",
    "writing": "subagent timed out; no results retrieved",
    "film": "no subagent dispatched — coordinator decomposition gap"
  }
}`

const antiPatternBad = `Report reads as complete:
  "Our research into recent
   cultural trends shows..."

→ Gaps invisible.
→ Downstream reader treats everything as covered.
→ Visual-arts-only ships as 'cultural trends.'`

const antiPatternFix = `Report explicitly lists what wasn't covered:
  "We covered 3 of the 4 requested
   domains. Music was unavailable due
   to a source outage."

→ Honest. Strictly better deliverable.`
</script>

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div class="di-cover">
    <div class="di-cover__eyebrow">Domain 5 · Lecture 7.10</div>
    <div class="di-cover__title">Coverage Annotations<br/>in Synthesis</div>
    <div class="di-cover__subtitle">Gaps are information. Don't hide them.</div>
  </div>
</Frame>

<style scoped>
.di-cover { flex: 1; display: flex; flex-direction: column; justify-content: center; gap: 32px; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 28px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); }
.di-cover__title { font-family: var(--font-display); font-size: 112px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); max-width: 1500px; }
.di-cover__subtitle { font-family: var(--font-display); font-size: 40px; color: var(--mint-200); font-style: italic; }
</style>

<!--
Lecture 7.10. Coverage annotations in synthesis output. If 7.9 was about distinguishing access failures from empty results at the subagent layer, this is the same principle one layer up — at the coordinator's synthesis step.

The theme across 7.8, 7.9, and 7.10 is consistent: honesty in the schema. Don't let failures, gaps, or partial coverage silently disappear as data moves up the multi-agent stack. Surface them in a structured way. This lecture is specifically about the final synthesis step — the last place the coverage information can survive before the user sees the report.
-->

---

<ConceptHero
  leadLine="Annotate coverage gaps"
  concept="Honest beats polished."
  supportLine="If a subagent couldn't cover a topic, say so in the output. Better than a report that LOOKS complete."
/>

<!--
Annotate coverage gaps. If a subagent couldn't cover a topic, say so in the synthesis output. That's better than silently producing a report that LOOKS complete. Gaps are information — they tell the downstream reader where the findings are solid and where they're partial or missing. Hiding gaps creates the appearance of coverage without the substance.

This is counterintuitive for people used to polished deliverables. The instinct is to produce the cleanest-looking report possible. The reliability discipline is to produce a report that honestly reflects what was covered and what wasn't.
-->

---

<CodeBlockSlide
  title="Synthesis output with coverage"
  lang="json"
  :code="coverageCode"
  annotation="Three buckets — covered, partial, gaps. Every requested topic lands in exactly one."
/>

<!--
The synthesis output gets an extra field. Alongside the findings themselves, there's a coverage object with three lists. Covered — the topics where subagents returned solid results. Gaps — the topics where nothing came back, or the subagent hit access failures. Partial — the topics where some evidence exists but coverage was incomplete.

Three buckets. Every topic the original query implied should land in exactly one of them. No silent drops. The schema shape forces the coordinator to account for everything.
-->

---

<CalloutBox variant="tip" title="Sample Q7 echo — visual-arts-only report">

Research pipeline produces a report on "recent cultural trends." Report covers visual arts in detail. Silently drops music, writing, film.

<p>Coverage annotations would have flagged the missing topics before the report shipped. Synthesis would have read: <code>"covered: visual_arts; gaps: music, writing, film."</code> Totally different user experience.</p>

</CalloutBox>

<!--
Sample Question 7 is the canonical example. The scenario: a multi-agent research system produces a report on recent cultural trends. The report covers visual arts in detail. It doesn't cover music, writing, or film — even though the original query implied all four. The subagents themselves ran fine — no errors to propagate. The coordinator's synthesis just… lost the other three topics somewhere in the pipeline.

Coverage annotations would have flagged the missing topics before the report shipped. The synthesis would have read: "covered — visual arts; gaps — music, writing, film." That's a totally different user experience. The user knows to ask for the gaps or to accept the partial report. The report itself is honest about what it is.
-->

---

<CalloutBox variant="tip" title="Subagents self-report; coordinator aggregates">

Each subagent self-reports what it covered and what it couldn't. Coordinator aggregates those reports.

<p>Example: a music subagent returns <code>"covered: jazz, classical; partial: electronic, experimental; gaps: country."</code> Coordinator rolls that into the top-level coverage object as-is — no summarization, no inference. <strong>Trust the source.</strong></p>

</CalloutBox>

<!--
Each subagent self-reports what it covered and what it couldn't. The coordinator aggregates those self-reports into the coverage object. This is not the coordinator guessing — it's the subagents telling the coordinator, and the coordinator propagating. That's what makes the annotations trustworthy: they come from the layer that did the work.

A music subagent returns "covered: jazz, classical; partial: electronic, experimental; gaps: country." The coordinator takes that input as-is and rolls it into the top-level coverage object. No summarization, no inference. Trust the source.
-->

---

<CalloutBox variant="warn" title="Don't lose it at synthesis">

Synthesis MUST preserve coverage info. Collapsing findings into one prose paragraph erases gaps — the prose reads as complete; the annotations evaporate.

<p>Treat coverage as a <strong>first-class field</strong> in the output schema, not a footnote or preface. Same principle as 7.1 (structural discipline preserves what prose compresses away) and 7.16 (claim-source mappings).</p>

</CalloutBox>

<!--
Here's the discipline. Synthesis MUST preserve coverage info. If you collapse all the subagent findings into a single prose paragraph, the coverage object gets lost — the prose reads as complete, and the annotations evaporate. The fix: treat coverage as a first-class field in the output schema, not a footnote or a preface. Propagate it alongside the findings, all the way to the user-facing output.

This is the same principle we covered in 7.1 with lost-in-the-middle — structural discipline preserves information that prose compresses away. It's also directly related to 7.16's claim-source mappings. The whole multi-agent synthesis pipeline needs structural fields to survive, because prose is where information goes to die.
-->

---

<AntiPatternSlide
  title="Don't produce confident-looking reports with gaps"
  lang="text"
  :badExample="antiPatternBad"
  whyItFails="Clean prose hides the gaps. There's no signal to the reader that music, writing, and film never made it in."
  :fixExample="antiPatternFix"
/>

<!--
The anti-pattern: produce a confident-looking report where gaps are invisible. The report reads as complete. The downstream reader has no way to know what wasn't covered, so they treat everything as covered. That's how visual-arts-only reports get shipped as "recent cultural trends."

The better pattern: explicitly list what wasn't covered and why. Honesty in the schema beats confidence in the prose. A report that says "we covered three of the four domains requested; music was unavailable due to a source outage" is a strictly better deliverable than one that silently covers three and lets the reader guess.
-->

---

<CalloutBox variant="tip" title="On the exam — two angles, both correct">

Sample Q7 can be answered from two angles:

<p><strong>Domain 1 / Task 1.2 angle:</strong> "coordinator didn't decompose the query properly."</p>
<p><strong>Domain 5 / Task 5.3 angle:</strong> "synthesis didn't include coverage annotations."</p>

Know both. The correct answer depends on which failure the question is describing — decomposition up front, or annotation at the end.

</CalloutBox>

<!--
On the exam, the Sample Question 7 pattern can be answered from two angles, both correct. One: "coordinator didn't decompose the query properly" — that's a Domain 1 / Task 1.2 angle. Two: "synthesis didn't include coverage annotations" — that's the Domain 5 / Task 5.3 angle. Know both. The exam may frame the fix from either side, and the correct answer depends on which failure the question is describing — decomposition up front, or annotation at the end.
-->

---

<Frame bg="var(--mint-100)">
  <Eyebrow>Closing</Eyebrow>
  <SlideTitle>Next up: 7.11 — Context Degradation in Long Sessions.</SlideTitle>

  <div class="closing-body">
    <p>We've been focused on multi-agent failures. Now we shift to a very different failure mode — what happens when a SINGLE long session starts losing track of its own early exploration.</p>
  </div>
</Frame>

<style scoped>
.closing-body { margin-top: 56px; font-family: var(--font-body); font-size: 30px; line-height: 1.5; color: var(--forest-500); max-width: 1400px; }
</style>

<!--
Next up: 7.11, context degradation in long sessions. We've been focused on multi-agent failures. Now we shift to a very different failure mode — what happens when a SINGLE long session starts losing track of its own early exploration. See you there.
-->
