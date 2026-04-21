---
theme: default
title: "Lecture 4.4: Splitting Generic Tools vs Consolidating"
info: |
  Claude Certified Architect – Foundations
  Section 4 — Tool Design & MCP Integration (Domain 2, 18%)
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
const decision_steps = [
  { label: 'Different inputs?', sublabel: 'Schema differs across calls' },
  { label: 'Different outputs?', sublabel: 'Return shape differs' },
  { label: 'Different agents?', sublabel: 'Used by separate roles' },
  { label: 'Any YES → split', sublabel: 'All NO → consolidate' },
]

const split_code = `# Before — generic
analyze_document(doc, mode)

# After — three tools, three contracts
extract_data_points(doc, schema)         # returns structured object
summarize_content(doc, length_target)    # returns prose
verify_claim_against_source(doc, claim)  # returns verdict + evidence

# Each tool gets its own boundary clause:
#   "Use for structured extraction, not summarization;
#    for a prose summary, use summarize_content."`
</script>

<div class="di-cover">
  <div class="di-cover__inner">
    <div class="di-cover__eyebrow">Domain 2 · Lecture 4.4</div>
    <h1 class="di-cover__title">Splitting Generic Tools vs<br/><span class="di-cover__accent">Consolidating</span></h1>
    <div class="di-cover__subtitle">One question. One decision rule.</div>
  </div>
</div>

<style scoped>
.di-cover { position: absolute; inset: 0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%); color: var(--mint-100); }
.di-cover__inner { padding: 110px 120px 96px; height: 100%; display: flex; flex-direction: column; justify-content: center; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px; }
.di-cover__title { font-family: var(--font-display); font-weight: 500; font-size: 108px; line-height: 1.05; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1600px; }
.di-cover__accent { color: var(--sprout-500); }
.di-cover__subtitle { font-family: var(--font-display); font-size: 40px; color: var(--mint-200); margin-top: 40px; font-weight: 400; }
</style>

<!--
Two failure modes sit on opposite ends of the same spectrum. One tool doing three jobs. Three tools doing one job. Both break selection. This lecture gives you the one-question decision rule that tells you which side you're on, and what to do about it.
-->

---

<TwoColSlide
  title="Two failure modes"
  leftLabel="Too generic"
  rightLabel="Too fragmented"
>
  <template #left>
    <div style="font-family: var(--font-body); font-size: 24px; line-height: 1.5;">
      <code>analyze_document</code> quietly does three different things: extracts fields, summarizes prose, checks claims.
      <br/><br/>
      Description tries to cover all three — covers none clearly.
    </div>
  </template>
  <template #right>
    <div style="font-family: var(--font-body); font-size: 24px; line-height: 1.5;">
      <code>summarize_doc</code>, <code>document_summary</code>, <code>summary_from_document</code> — three tools, near-identical prose.
      <br/><br/>
      Claude picks between them randomly.
    </div>
  </template>
</TwoColSlide>

<!--
Here they are, side by side. On the left — too generic. You've got analyze_document and it quietly does three different things depending on how Claude calls it. Extracts fields. Summarizes prose. Checks claims. The description tries to cover all three and ends up covering none clearly. On the right — too fragmented. You split too aggressively and now you have summarize_doc, document_summary, and summary_from_document — three tools with near-identical prose. Claude picks between them randomly. Either failure shows up as selection unreliability.
-->

---

<ConceptHero
  leadLine="When to split"
  concept="Different I/O → different tools."
  supportLine="If the schema or output differs, the description can't disambiguate — split."
/>

<!--
Here's the split rule. Different input/output contracts means different tools. If the schema differs — if one tool takes a document plus a claim and returns a boolean, and another takes a document and returns prose — the description can't disambiguate them cleanly. That's the signal to split. When the shape of the work changes, the tool should change too. One tool, one contract.
-->

---

<CodeBlockSlide
  title="analyze_document → three tools"
  lang="python"
  :code="split_code"
/>

<!--
Here's the canonical example straight from the exam guide. analyze_document, generic, doing three jobs. Split it. One — extract_data_points: takes a document and a target schema, returns a structured object. Two — summarize_content: takes a document plus a length target, returns prose. Three — verify_claim_against_source: takes a document plus a claim, returns a verdict and evidence. Three tools, three contracts, three clear descriptions. And each one gets boundaries — "use this for structured extraction, not summarization; for a prose summary, use summarize_content" — the versus clauses from 4.3 doing their work. Claude picks correctly not because the descriptions are longer but because each tool's shape is clearly distinct from the others.
-->

---

<ConceptHero
  leadLine="When to consolidate"
  concept="Same contract → one tool."
  supportLine="Avoid cosmetic splits. Each extra tool is another 'not this one' Claude has to rule out."
/>

<!--
The other direction. Same contract, same use case — that's one tool, not three. If the inputs and outputs are the same and the only thing that differs is a cosmetic word in the name, you're splitting for the sake of splitting. That's tool-count inflation, and it's worse than it looks. Because each extra tool is another item Claude has to rule out at selection time. Cosmetic splits pad the count without adding capability. Three tools called summarize_doc, document_summary, and summary_from_document — all taking the same input, all returning the same shape — get consolidated into one summarize_content. One clear description beats three near-duplicates every time.
-->

---

<BigNumber
  number="4–5"
  unit=" tools / agent"
  caption="Selection reliability degrades sharply past this ceiling."
  detail="Domain 2 Task 2.3 — covered in depth in Lecture 4.8."
/>

<!--
Tool count isn't free. Four to five tools per agent is the ceiling where selection reliability stays high. Past that, degradation is steep. We'll dig into this in 4.8, but the number to hold onto right now is four to five. If your split produces a sixth, seventh, eighth tool — stop and check. The right answer might be a narrower scope per agent, not more tools on the same agent. Domain 2 Task 2.3 is explicit about this. Splitting and scoping go hand-in-hand: when a tool genuinely splits into three, those three often belong on different agents rather than all three living together.
-->

---

<CalloutBox variant="tip" title="On the exam">

<strong>Split</strong> when descriptions overlap AND use cases differ (different contracts hiding under one name).<br/>
<strong>Consolidate</strong> when you're papering over a description problem with tool count. Fix the description first — then restructure.

</CalloutBox>

<!--
Here's the exam move. Splitting is the right answer when the descriptions overlap and the use cases differ — that means different contracts hiding under one name. Consolidation is the right answer when you're papering over a description problem by inventing more tools. Both of those are testable. If the question gives you a tool whose description tries to cover three unrelated jobs, split. If it gives you three tools whose descriptions sound the same, consolidate — or rewrite them so they stop sounding the same. Remember 4.1 — fix the description first before you restructure.
-->

---

<FlowDiagram
  title="Split or consolidate?"
  :steps="decision_steps"
/>

<!--
Here's the decision tree. Four questions. Different inputs? Different outputs? Used by different agents? Would the descriptions need contradictory boundary clauses to disambiguate them? Any yes, split. All no, consolidate. That's the whole framework. Run it on any tool pair you're unsure about and you'll have your answer in about ten seconds. Scenario 6 — structured extraction — uses this pattern constantly: extract_invoice versus extract_receipt split because the schemas differ, not because the descriptions differ. And Scenario 3 — multi-agent research — uses it whenever a subagent's tool spans what should be two distinct workflows.
-->

---

<div class="di-close">
  <div class="di-close__inner">
    <div class="di-close__eyebrow">Next up</div>
    <h1 class="di-close__title">4.5 — <span class="di-close__accent">MCP Error Response Design</span></h1>
    <div class="di-close__subtitle">Three fields. Memorize them.</div>
  </div>
</div>

<style scoped>
.di-close { position: absolute; inset: 0; background: var(--mint-100); color: var(--forest-800); }
.di-close__inner { padding: 110px 120px 96px; height: 100%; display: flex; flex-direction: column; justify-content: center; }
.di-close__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.14em; text-transform: uppercase; color: var(--teal-500); margin-bottom: 36px; }
.di-close__title { font-family: var(--font-display); font-weight: 500; font-size: 96px; line-height: 1.05; letter-spacing: -0.02em; color: var(--forest-900); margin: 0; max-width: 1600px; }
.di-close__accent { color: var(--sprout-600); }
.di-close__subtitle { font-family: var(--font-display); font-size: 38px; color: var(--forest-500); margin-top: 32px; font-weight: 400; }
</style>

<!--
Next up, Lecture 4.5 — MCP error response design. Three fields. Memorize them. See you there.
-->
