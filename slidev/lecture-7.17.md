---
theme: default
title: "Lecture 7.17: Handling Conflicting Sources"
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
const conflictCode = `{
  "claim_topic": "Cloud infrastructure growth rate",
  "conflict_detected": true,
  "values": [
    {
      "value": "12%",
      "source_url": "https://example.org/analysts/Q1-2025-cloud.pdf",
      "excerpt": "Market grew 12% YoY in Q1 2025.",
      "publication_date": "2025-04-15",
      "methodology": "Survey-based, 200 enterprise buyers"
    },
    {
      "value": "18%",
      "source_url": "https://example.org/trade-assoc/Q3-2025.pdf",
      "excerpt": "Total revenue grew 18% YoY in Q3 2025.",
      "publication_date": "2025-10-20",
      "methodology": "Vendor-reported revenue aggregation"
    }
  ],
  "notes": "Sources may disagree OR may reflect time-series drift. Methodologies differ — treat with caution."
}`

const antiPatternBad = `Three silent-arbitration shapes:

1. Average two values.
2. Pick the "more recent."
3. Preserve whichever was read first.

→ All strip information the reader needs.
→ "Pick the more recent" looks defensible —
  still silent arbitration, still exam-wrong.`

const antiPatternFix = `Surface both with attribution. Let the
reader or coordinator choose.

"Analysts disagree; source A reports 12%
 in Q1, source B reports 18% in Q3."

→ Strictly better than picking 12 and shipping.
→ Visible beats polished.`
</script>

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div class="di-cover">
    <div class="di-cover__eyebrow">Domain 5 · Lecture 7.17</div>
    <div class="di-cover__title">Handling Conflicting Sources</div>
    <div class="di-cover__subtitle">Annotate — don't arbitrarily choose</div>
  </div>
</Frame>

<style scoped>
.di-cover { flex: 1; display: flex; flex-direction: column; justify-content: center; gap: 32px; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 28px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); }
.di-cover__title { font-family: var(--font-display); font-size: 112px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); max-width: 1500px; }
.di-cover__subtitle { font-family: var(--font-display); font-size: 40px; color: var(--mint-200); font-style: italic; }
</style>

<!--
Lecture 7.17. Handling conflicting sources. Last lecture of Section 7 — and the last lecture covering the five exam domains before we move to the preparation-exercise demos. This is a Scenario 3 question, and it's a frequent "almost-right" trap.

If you've made it this far through Domain 5, you already know what's coming. The exam-wrong answer will be the one that looks clean and decisive. The exam-right answer will be the one that surfaces complexity honestly. Let's walk through it.
-->

---

<BigQuote
  lead="The trap"
  quote="Source A says 12%. Source B says 18%. <em>The agent picks 12% silently.</em> The report looks clean — and is wrong."
  attribution="A polished report that hides a disagreement between credible sources"
/>

<!--
Here's the trap in one scenario. Source A says twelve percent. Source B says eighteen percent. The agent picks twelve percent silently, because it's the first one it processed or the more recent one or the one from the more "authoritative" domain. The final report reads clean — one number, one claim. It is also wrong, or at best oversimplified. The downstream reader has no idea there was a conflict at all.

This is a clean polished report that silently hides a disagreement between credible sources. It's the kind of output that looks professional on a first read and falls apart the moment anyone tries to verify.
-->

---

<ConceptHero
  leadLine="Annotate, don't arbitrate"
  concept="Both values. Both sources."
  supportLine="The agent surfaces the disagreement. Downstream reader — or coordinator — decides. The agent does not silently pick."
/>

<!--
Annotate, don't arbitrate. Both values, both sources, explicit conflict. The agent surfaces the disagreement; the downstream reader — or a coordinator, or a human reviewer — decides how to reconcile. The agent does not silently pick. Silent arbitration is the failure mode.

This is the same honesty principle as coverage annotations in 7.10 — surface the gap, don't hide it. Different gap; same discipline.
-->

---

<CodeBlockSlide
  title="Conflict-preserved output"
  lang="json"
  :code="conflictCode"
  annotation="conflict_detected + both values with full mapping + methodological notes."
/>

<!--
The output structure, when conflict is detected. A conflict_detected flag set to true. Both values, each with its full claim-source mapping from 7.16 — source URL, excerpt, publication date. Methodological notes if the sources differ in how they measured. And explicit language in the surrounding prose that there IS a disagreement and the reader should treat the number with appropriate caution.

The structure makes the conflict visible. It doesn't force the reader to spot it buried in footnotes or infer it from a vague hedge. Explicit. Schema-level.
-->

---

<CalloutBox variant="tip" title="Well-established vs contested — explicit sections">

Reports should separate sections structurally.

<ul>
<li><strong>Well-established findings</strong> — sources agree; high-confidence; merge cleanly; firm conclusions.</li>
<li><strong>Contested findings</strong> — sources disagree; each conflict explicitly surfaced with attribution.</li>
</ul>

<p>Two sections, two epistemic levels. The reader knows what to trust and what to treat with caution. The structure communicates confidence — rather than forcing it into vague prose qualifiers.</p>

</CalloutBox>

<!--
One more structuring move. Research reports should separate "well-established findings" from "contested findings" as distinct sections. The well-established section holds claims where sources agree — high-confidence, merge cleanly, present as firm conclusions. The contested section holds claims where sources disagree — each conflict explicitly surfaced with attribution.

Two sections, two epistemic levels. The reader knows what to trust and what to treat with caution. The structure does the work of communicating confidence, rather than forcing it into vague prose qualifiers.
-->

---

<CalloutBox variant="tip" title="Temporal vs true conflict — callback to 7.16">

Sometimes "conflict" is actually temporal — source A was Q1, source B was Q3, the metric moved.

<p>Publication dates let you distinguish. Two sources with different dates reporting different numbers may not be in conflict — they may be two points on a time series.</p>

<p>Without dates → indistinguishable from true disagreement. With dates → the story is clear. <strong>Provenance feeds conflict resolution.</strong></p>

</CalloutBox>

<!--
Callback to 7.16. Sometimes what looks like a conflict is actually a temporal difference — source A was Q1, source B was Q3, the underlying metric moved. Publication dates let you distinguish. Two sources with different dates reporting different numbers may not be in conflict — they may be two points on a time series. Without dates, they're indistinguishable from a true disagreement. With dates, the story is clear.

This is why 7.16's insistence on publication dates matters here. Provenance feeds conflict resolution. Without dates in your claim-source mappings, you can't tell "the metric grew over time" from "two sources contradict each other." Keep the dates.
-->

---

<CalloutBox variant="tip" title="Where to detect — document-analysis layer">

Conflict detection happens at the document-analysis layer, BEFORE synthesis.

<p>Document-analysis agent reports values with methodology. Coordinator, seeing multiple values for the same claim, decides how to reconcile — flag as contested, merge as temporal, escalate for human review.</p>

<p>By the time synthesis runs, the reconciliation is done. <strong>Synthesis doesn't get to silently pick.</strong> Push conflict detection upstream — once synthesis starts writing paragraphs, the opportunity to preserve the conflict is gone.</p>

</CalloutBox>

<!--
Where should conflict detection happen? At the document analysis layer, before synthesis. The document-analysis agent reports values along with methodology. The coordinator, seeing multiple values for the same claim, decides how to reconcile — flag as contested, merge as temporal, escalate for human review. By the time synthesis runs, the reconciliation is done. Synthesis doesn't get to silently pick.

Push conflict detection upstream. Don't let it die in the final prose pass. Once synthesis starts writing paragraphs, the opportunity to preserve the conflict is gone.
-->

---

<AntiPatternSlide
  title="Don't silently pick one"
  lang="text"
  :badExample="antiPatternBad"
  whyItFails="Recency is often correlated with accuracy — but silent choice strips the reader's ability to verify. Explicit beats clean."
  :fixExample="antiPatternFix"
/>

<!--
The anti-pattern: agent averages two values, picks the more recent, or silently preserves whichever it read first. All three are silent arbitration. All three strip information the reader needs. The "pick the more recent" version looks especially defensible — recency is often correlated with accuracy — but it's still silent arbitration, and the exam treats it as such.

The better pattern: surface both with attribution, let the reader or coordinator choose. Explicit beats clean. Visible beats polished. A report that says "analysts disagree; source A reports twelve percent in Q1, source B reports eighteen percent in Q3" is strictly better than one that picks twelve and ships.
-->

---

<CalloutBox variant="tip" title="On the exam">

"Conflicting statistics from credible sources" → annotate both with attribution.

<p>Distractor — always — is "pick the more recent" or "average the values" or "select the authoritative source." All almost-right. All silent arbitration. All exam-wrong.</p>

<p>Ingredients: multiple credible sources, same metric, different values → answer is always <strong>preserve the disagreement</strong>, never silently pick a winner.</p>

</CalloutBox>

<!--
On the exam, the shape is: "Conflicting statistics from credible sources." The right answer is annotate both with attribution. The distractor — always — is "pick the more recent" or "average the values" or "select the authoritative source." All almost-right. All silent arbitration. All exam-wrong. The exam rewards the pattern where the conflict is preserved, not resolved.

Recognize the question by its ingredients — multiple credible sources, same metric, different values. The answer is always to preserve the disagreement, never to silently pick a winner.
-->

---

<Frame bg="var(--mint-100)">
  <Eyebrow>Section 7 closer</Eyebrow>
  <SlideTitle>Domain 5 — 15% — is closed. You've now covered all five exam domains.</SlideTitle>

  <div class="closing-body">
    <p><strong>Every section from here is hands-on demos.</strong> Scenario by scenario. Domains 1–5 all get reinforced in the demos — the work isn't done, but the conceptual ground is covered.</p>
    <p><em>Reliability comes from structured patterns, not from hope.</em> Case-facts blocks. Claim-source mappings. State manifests. Coverage annotations. Stratified sampling. Every pattern names itself; every pattern solves a specific failure mode; every pattern composes with the others.</p>
    <p>Next up: Section 8 and the first of the four preparation exercises from the official exam guide.</p>
  </div>
</Frame>

<style scoped>
.closing-body { margin-top: 48px; font-family: var(--font-body); font-size: 26px; line-height: 1.5; color: var(--forest-500); max-width: 1500px; }
.closing-body p + p { margin-top: 20px; }
.closing-body p em { color: var(--forest-800); font-style: italic; }
.closing-body p strong { color: var(--sprout-700); }
</style>

<!--
That's Section 7 — Domain 5, fifteen percent of the exam. You've now covered all five exam domains. Every section from here on is hands-on demos, Scenario by Scenario. Domains one through five all get reinforced in the demos — so the work isn't done, but the conceptual ground is covered.

Remember the Domain 5 theme: reliability comes from structured patterns, not from hope. Case-facts blocks. Claim-source mappings. State manifests. Coverage annotations. Stratified sampling. Every pattern names itself; every pattern solves a specific failure mode; every pattern composes with the others.

Next up: Section 8 and the first of the four preparation exercises from the official exam guide. See you there.
-->
