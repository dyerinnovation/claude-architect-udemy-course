---
theme: default
title: "Section 7: Domain 5 - Context Management & Reliability"
info: |
  Claude Certified Architect – Foundations
  Section 7: Domain 5 - Context Management & Reliability (15%)
highlighter: shiki
transition: slide-left
mdc: true
canvasWidth: 1920
aspectRatio: 16/9
---

<style>
@import './design-system.css';
</style>

<!-- LECTURE 7.1 — The Lost in the Middle Effect -->

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div class="di-cover">
    <div class="di-cover__eyebrow">Domain 5 · Lecture 7.1</div>
    <div class="di-cover__title">The "Lost in the Middle" Effect</div>
    <div class="di-cover__subtitle">What it means and how to counter it</div>
  </div>
</Frame>

<style scoped>
.di-cover { flex: 1; display: flex; flex-direction: column; justify-content: center; gap: 32px; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 28px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); }
.di-cover__title { font-family: var(--font-display); font-size: 132px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); max-width: 1500px; }
.di-cover__subtitle { font-family: var(--font-display); font-size: 44px; color: var(--mint-200); font-style: italic; }
</style>

<!--
Welcome to Domain 5. This is the smallest domain on the exam at fifteen percent — and I want to call that out directly because it's tempting to skip. Don't. Remember what I told you in lecture 1.1: Domain 5 has a higher value-per-study-hour than its weight suggests, and it shows up across Scenarios one, three, and six. Three of your six scenarios. So even though you'll be studying these seventeen lectures with less total screen time than Domain 1, the material you're about to learn will touch half the exam.

We're starting with the "lost in the middle" effect. If you only take one thing from this first lecture, take this: position inside a long input is not neutral. Where you put information changes whether the model actually uses it. That sentence is the entire lecture compressed into one line. The next eight minutes are about why it's true, what it looks like in practice, and how you counter it on the exam and in production.
-->

---

<ConceptHero
  leadLine="Position matters in long inputs"
  concept="Beginning and end win."
  supportLine="A 20-doc aggregation buries doc 10's findings under attention noise."
/>

<!--
Here's the effect in one sentence. Models reliably process the beginning and end of long inputs. The middle drops. That's not a bug you can configure away. It's a property of how attention distributes over long sequences, and it gets worse the longer the input is. It gets worse with larger context windows, not better — more space to lose things in.

Concretely: if a coordinator aggregates twenty subagent outputs into a single prompt, the findings buried in document ten are the ones most likely to get omitted from the final answer. Not because they're less important. Not because the information is worse. Because they're in the middle. The exam tests whether you know to counter this with structure, not with a bigger model. That's the distinction that lives in every version of this question.
-->

---

<script setup>
const positionSteps = [
  { label: 'Beginning', sublabel: 'Reliable -- model orients here' },
  { label: 'Middle', sublabel: 'The trough -- drops out of output' },
  { label: 'End', sublabel: 'Reliable again -- recent & weighted' },
]
</script>

<FlowDiagram
  title="Attention by position"
  :steps="positionSteps"
/>

<!--
Picture attention across a long input as a U-curve. The beginning is reliable — that's where the model orients, where it establishes what it's reading, what the task is, what the structure looks like. The end is reliable too — that's what the model was just processing when it started generating, so it's recent and weighted. The middle? That's the trough. Findings that sit in the middle get acknowledged at read time but not integrated into the output.

The exam sometimes describes this as "the agent summarized the input but omitted mid-document findings." That phrasing is a tell — it's a Domain 5 question about lost-in-the-middle. Recognize the keyword and you've already narrowed the answer space.
-->

---

<CalloutBox variant="tip" title="Lead with findings">

Put the key synthesis at the start. Details below.

This inverts the default. Most people paste sources chronologically and put their synthesis at the bottom as a "conclusion." That's backwards for how the model reads a long prompt. The findings summary goes first, because the first position is where attention is strongest.

</CalloutBox>

<!--
Mitigation one: lead with findings. Put the key synthesis at the top of your aggregated input. Details below.

This sounds obvious, but it inverts the default. Most people paste sources chronologically — source one, source two, source three — and put their synthesis at the bottom as a "conclusion." That's backwards for how the model reads a long prompt. The findings summary goes first, because the first position is where attention is strongest. The sources that support the findings go below. The reader doesn't mind — humans read the same way, eyes drifting to the top of a page before the details. The model's attention behaves similarly at scale.
-->

---

<script setup>
const structuredCode = `# Synthesis: findings at top

The three strongest signals across 20 sources:
1. [lead finding]
2. [lead finding]
3. [lead finding]

## Source 1 -- [name]
[full source content]

## Source 2 -- [name]
[full source content]

## Source 3 -- [name]
[full source content]

## ... (headers every source)`
</script>

<CodeBlockSlide
  title="Structured aggregated input"
  lang="markdown"
  :code="structuredCode"
  annotation="Every named chunk is an anchor the model can hold onto."
/>

<!--
Mitigation two: explicit section headers. "Source one." "Source two." "Source three." Headers act as attention anchors. They give the model a scaffolding it can reorient to when it's generating. No headers, and a twenty-document input becomes a wall of text the model glides over at constant attention — which is to say, it glides over the middle. With headers, each section gets its own beginning, its own local top-of-context — and that's exactly the position the model reads reliably.

Use Markdown headers, use XML tags, use whatever your pipeline supports. The specific syntax matters less than the fact that you're breaking the input into named chunks. Every named chunk is a little anchor the model can hold onto.
-->

---

<CalloutBox variant="tip" title="Not chronological -- important first">

Put highest-signal content where attention is strongest -- top or bottom.

If you know document seven is the critical one, don't leave it in position seven. Move it to position one, or position twenty. Order is a tool, not a neutral property.

</CalloutBox>

<!--
Mitigation three: reorder by importance, not by chronology. Highest-signal content goes where attention is strongest — which means top or bottom of the input. If you know document seven is the critical one — maybe it's the most recent, the most authoritative, the one that contradicts the rest — don't leave it in position seven. Move it to position one, or position twenty. Order is a tool, not a neutral property.

In multi-agent pipelines, this means the coordinator decides ordering before dispatching the synthesis prompt. In customer support, this means the case-facts block goes at the top of every turn, not at the bottom. Same principle, different surface.
-->

---

<CalloutBox variant="tip" title="Scenario 3 -- multi-agent research">

Coordinator aggregating subagent outputs must put the synthesis at the top. Covered again in 7.10 when we talk about coverage annotations.

Ten subagents, ten findings, all piled into one synthesis prompt. Without structure -- summary top, explicit headers, importance-ordered -- half the research silently falls off the floor and the final report reads clean but incomplete.

</CalloutBox>

<!--
This matters most in Scenario 3 — the multi-agent research system. A coordinator that aggregates subagent outputs is the classic lost-in-the-middle victim. Ten subagents, ten findings, all piled into one synthesis prompt. If the coordinator doesn't structure that input — summary top, explicit source headers, importance-ordered — half the research silently falls off the floor and the final report reads clean but incomplete.

We're going to come back to this in 7.10 when we talk about coverage annotations, which is the other half of the fix. Lost-in-the-middle tells you HOW to structure the input. Coverage annotations tell you HOW to surface what didn't make it. Together they cover the full reliability story for Scenario 3 synthesis.
-->

---

<CalloutBox variant="tip" title="On the exam">

"Middle-section findings omitted" -> structure input by position. Summary top + headers.

Easy distractor to rule out: "use a larger context window" or "switch to a larger model." Larger windows make the problem worse, not better -- more middle to lose.

</CalloutBox>

<!--
On the exam, here's the shape. The question describes a long aggregated input where middle-section findings are omitted from the final answer. The right answer is structural — summary at top, explicit headers, reorder by importance. The distractor to watch for is "use a larger context window" or "switch to a larger model." Almost-right. Larger windows make the problem worse, not better — more middle to lose. This is the exam's thesis, back again: almost-right is the whole trap.

Notice that the exam will not always use the words "lost in the middle" directly. It'll describe a pipeline where twenty inputs went in and the ninth one disappeared. You have to recognize the pattern from the symptom.
-->

---

<BigQuote
  lead="Continuity"
  quote="Domain 5 is fifteen percent -- but 1.1 told you, <em>don't skip it because it's small.</em>"
  attribution="When you see 'long input' and 'mid-document findings missed' -> think structure, not size"
/>

<!--
Hold onto this. Domain 5 is fifteen percent — but 1.1 told you, don't skip it because it's small. Lost-in-the-middle is one of the most reliable trap questions on this exam, and the fix is structural, not model-scale. The mental move is: when you see "long input" and "mid-document findings missed," think structure, not size. Summary on top. Headers. Reorder.
-->

---

<Frame bg="var(--mint-100)">
  <Eyebrow>Closing</Eyebrow>
  <SlideTitle>Next up: 7.2 -- Progressive Summarization Risks.</SlideTitle>

  <div class="closing-body">
    <p>If lost-in-the-middle is what happens <em>within</em> a single prompt, progressive summarization is what happens <em>across</em> a long conversation. Different failure mode, related discipline.</p>
  </div>
</Frame>

<style scoped>
.closing-body { margin-top: 56px; font-family: var(--font-body); font-size: 30px; line-height: 1.5; color: var(--forest-500); max-width: 1400px; }
.closing-body p em { color: var(--forest-800); font-style: italic; }
</style>

<!--
Next up: 7.2, progressive summarization risks. Summarization erases specific numbers and dates — and that's another reliability failure the exam tests hard, especially in Scenario 1. If lost-in-the-middle is what happens within a single prompt, progressive summarization is what happens across a long conversation. Different failure mode, related discipline. See you there.
-->

---

<!-- LECTURE 7.2 — Progressive Summarization Risks -->

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div class="di-cover">
    <div class="di-cover__eyebrow">Domain 5 · Lecture 7.2</div>
    <div class="di-cover__title">Progressive Summarization Risks</div>
    <div class="di-cover__subtitle">What gets lost when memory compresses</div>
  </div>
</Frame>

<style scoped>
.di-cover { flex: 1; display: flex; flex-direction: column; justify-content: center; gap: 32px; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 28px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); }
.di-cover__title { font-family: var(--font-display); font-size: 132px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); max-width: 1500px; }
.di-cover__subtitle { font-family: var(--font-display); font-size: 44px; color: var(--mint-200); font-style: italic; }
</style>

<!--
Lecture 7.2. Progressive summarization risks. If 7.1 was about where information lives inside a single prompt, this one is about what happens to information as a conversation keeps going — turn after turn, summary after summary.

Progressive summarization is the default memory strategy for most long-running agents. It sounds right. You keep recent turns verbatim, and every few turns you compress the older history into a natural-language recap. That's how most memory libraries ship by default. And it has a specific failure mode the exam tests directly.
-->

---

<BigQuote
  lead="The failure mode"
  quote="The customer said they wanted <em>$47.82</em>. Two summary rounds later, the agent remembers they 'requested a refund.'"
  attribution="First-contact resolution fails -- and nobody can trace why"
/>

<!--
Here's the scenario that opens this lecture. The customer said they wanted a refund of forty-seven dollars and eighty-two cents. Two summary rounds later, the agent remembers they "requested a refund." That's the failure. The dollar amount — the exact number the customer stated — is gone. And the agent is now operating on a summary of a summary, confident that it knows what the customer wants. It doesn't.

If the agent closes the ticket by offering a standard thirty-dollar credit, it's missed the stated expectation by eighteen dollars. The customer re-opens. First-contact resolution fails. And nobody — neither the agent nor the downstream analytics — can trace why, because the summary looks plausible on inspection.
-->

---

<script setup>
const erasedBullets = [
  { label: 'Specific dollar amounts', detail: '"$47.82" -> "a refund"' },
  { label: 'Dates', detail: '"by Friday the 15th" -> "soon"' },
  { label: 'Order numbers', detail: '"739421" -> "the order"' },
  { label: 'Stated customer expectations', detail: '"replaced, not refunded" -> "return options discussed"' },
  { label: 'Numerical thresholds', detail: 'Specifics softened into prose' },
]
</script>

<BulletReveal
  title="Summarization losses"
  :bullets="erasedBullets"
/>

<!--
When you summarize a conversation progressively — meaning every few turns you compress prior history into a shorter natural-language recap — you reliably erase a specific class of information. Specific dollar amounts. Dates. Order numbers. Stated customer expectations. Numerical thresholds. Anything with a precise numeric or transactional value gets softened into a phrase.

"Forty-seven dollars and eighty-two cents" becomes "a refund." "By Friday the fifteenth" becomes "soon." "Order number seven-three-nine-four-two-one" becomes "the order." "I want it replaced, not refunded" becomes "discussed return options." These are not equivalent. They were the specifics the customer cared about, and now they're prose — softer, friendlier, wrong.

This isn't a tuning problem. It's inherent to how natural-language summarization works — it compresses distinctiveness out of text. The fix isn't "summarize better." It's "don't summarize this class of information at all."
-->

---

<CalloutBox variant="warn" title="Why it's dangerous in Scenario 1">

Customer support lives or dies on honoring what the customer said -- not a vague paraphrase of it.

The summarization that makes the conversation fit the context window is the same summarization that quietly rewrites what the customer asked for. Same mechanism. Two opposite consequences -- one helpful, one damaging.

</CalloutBox>

<!--
Scenario 1 is customer support. Customer support lives or dies on honoring what the customer said — not a vague paraphrase of it. If your agent loses the dollar amount, it might offer the wrong refund. If it loses the stated expectation, it might close a ticket the customer considered unresolved. If it loses the deadline, the customer calls back asking where their replacement is.

The summarization that makes the conversation fit the context window is the same summarization that quietly rewrites what the customer asked for. Same mechanism. Two opposite consequences — one helpful, one damaging. You can't adjust one without affecting the other, because they're the same operation.
-->

---

<CalloutBox variant="tip" title="The fix -- preview of 7.4">

Extract transactional facts into a persistent "case facts" block. Don't summarize those.

<p>Two layers of memory: prose summary for narrative (tone, escalation history, options discussed). Structured block for numeric precision. Don't try to make one layer do both jobs.</p>

</CalloutBox>

<!--
The fix is coming in 7.4 — the persistent case-facts block. The short version: transactional facts don't belong in prose. Extract them into structured storage. Reference the structured block every turn. Summarize the conversational flow all you want — tone, escalation history, what options were discussed — but the numbers live outside the summary, in a place where compression can't touch them.

Two layers of memory. The prose summary is fine for narrative. The structured block is the only safe place for numeric precision. Don't try to make one layer do both jobs.
-->

---

<script setup>
const antiPatternBad72 = `Every turn: compress prior turns into natural language.

"The customer requested a refund and discussed options."

-> Specific amounts, dates, and verbatim expectations erased.`

const antiPatternFix72 = `Summarize conversational flow AND
persist facts in a structured block.

Prose memory   -> tone, escalation, what was discussed
Facts block    -> refund_amount: 47.82
                 stated_outcome: "replacement, not refund"`
</script>

<AntiPatternSlide
  title="Don't summarize everything at each turn"
  lang="text"
  :badExample="antiPatternBad72"
  whyItFails="Compression is lossy in exactly the ways that matter for transactional domains."
  :fixExample="antiPatternFix72"
/>

<!--
The anti-pattern: every turn, compress prior turns into natural language. That's how most naive memory systems work, and it's how specifics quietly die. The system looks clever — "the agent has memory!" — but the memory it has is lossy in exactly the ways that matter for a transactional domain.

The better pattern: summarize conversational flow AND persist facts in a structured block. You keep the prose memory for tone and context — "the customer is frustrated because this is their second call" — and you keep the facts in a schema for correctness — "refund_amount: 47.82." Two layers, two responsibilities, no contamination.
-->

---

<CalloutBox variant="tip" title="On the exam">

"Agent forgets specific amounts/dates" -> progressive summarization risk.

The right answer is <strong>structured persistent facts</strong>, not longer summaries. The distractor -- "use a larger model" or "longer summaries" -- is almost-right. Longer summaries still summarize; larger models still lose precision under compression.

</CalloutBox>

<!--
On the exam, the shape is: "The agent forgets specific amounts and dates across a long session." That's the progressive-summarization tell. The right answer is structured persistent facts — a case-facts block, or whatever the question labels it. The distractor is "use longer summaries" or "add a larger model." Almost-right — longer summaries still summarize, and larger models still lose precision under compression. This is another case where almost-right is the whole trap of this exam.

The exam sometimes writes this as "the agent lost track of what the customer asked for over the course of a fifteen-turn conversation." Same tell. Different words.
-->

---

<BigQuote
  lead="Continuity"
  quote="Scenario 1 -- customer support -- this is where <em>judgment questions</em> live."
  attribution="Progressive summarization is one of the top trap concepts"
/>

<!--
Scenario 1 — customer support — is where judgment questions on Domain 5 live. Remember the six-pick-four: you don't know which four scenarios show up on your exam, so skipping Scenario 1 isn't an option. And on Scenario 1, progressive summarization is one of the top trap concepts. Get this lecture, get 7.4, and you've locked in a cluster of questions that commonly appears together.
-->

---

<Frame bg="var(--mint-100)">
  <Eyebrow>Closing</Eyebrow>
  <SlideTitle>Next up: 7.3 -- Trimming Verbose Tool Outputs.</SlideTitle>

  <div class="closing-body">
    <p>If summarization is one way context degrades, verbose tool results are the other -- and the fix is just as structural.</p>
  </div>
</Frame>

<style scoped>
.closing-body { margin-top: 56px; font-family: var(--font-body); font-size: 30px; line-height: 1.5; color: var(--forest-500); max-width: 1400px; }
</style>

<!--
Next up: 7.3, trimming verbose tool outputs. If summarization is one way context degrades, verbose tool results are the other — and the fix is just as structural. See you there.
-->

---

<!-- LECTURE 7.3 — Trim Verbose Tool Outputs -->

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div class="di-cover">
    <div class="di-cover__eyebrow">Domain 5 · Lecture 7.3</div>
    <div class="di-cover__title">Trim Verbose Tool Outputs</div>
    <div class="di-cover__subtitle">Project before append</div>
  </div>
</Frame>

<style scoped>
.di-cover { flex: 1; display: flex; flex-direction: column; justify-content: center; gap: 32px; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 28px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); }
.di-cover__title { font-family: var(--font-display); font-size: 132px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); max-width: 1500px; }
.di-cover__subtitle { font-family: var(--font-display); font-size: 44px; color: var(--mint-200); font-style: italic; }
</style>

<!--
Lecture 7.3. Trimming verbose tool outputs. This is defensive context management — and it's one of the easiest patterns to get wrong if you don't build it in from the start. It's also an easy pattern to recognize on the exam once you've studied it, because the symptoms and the fix are both very specific.
-->

---

<BigNumber
  number="40+"
  unit=" fields"
  caption="Per order lookup. Agent uses 5. Other 35 accumulate in context."
  detail="A 12-turn session hitting lookup_order 6x has 240 operational fields cluttering working context."
/>

<!--
Forty-plus fields per order lookup. That's the number I want you to hold. A typical order-lookup tool call returns forty or more fields — internal IDs, warehouse codes, carrier handoff timestamps, tax breakdowns, fulfillment metadata, partner billing references, regional compliance flags, and so on. The agent uses five of them — order number, status, items, ship date, customer ID. The other thirty-five accumulate in context. Turn after turn.

They never get cleaned up. They just sit there, spending tokens, crowding out the actual conversation. A twelve-turn support session that hits `lookup_order` six times has two hundred and forty operational fields cluttering the agent's working context. Most of them the agent never references. All of them cost tokens every subsequent turn.
-->

---

<ConceptHero
  leadLine="Project before append"
  concept="Trim before it enters history."
  supportLine="Tool results get projected down to the fields the agent needs, before they cross into conversation history."
/>

<!--
Project before append. That's the pattern. Trim tool results to only the fields the agent needs, and do it before the result enters conversation history. Not after. After is too late — the tokens are already spent, and once something lands in conversation history, you're paying for it every subsequent turn until the conversation ends or gets summarized.

"Project" is borrowed from SQL — SELECT specific columns, not SELECT star. Same principle. Pick what matters, drop what doesn't, before the data crosses into your working set.
-->

---

<script setup>
const trimLocations = [
  { label: 'MCP tool response', cells: [{ text: 'Clean from the start -- best', highlight: 'good' }] },
  { label: 'Hook layer (PostToolUse)', cells: [{ text: 'Normalizes across tools', highlight: 'neutral' }] },
  { label: 'Agent prompt post-hoc', cells: [{ text: 'Too late -- tokens already spent', highlight: 'bad' }] },
]
</script>

<ComparisonTable
  title="Where to trim"
  :columns="['Effect']"
  :rows="trimLocations"
/>

<!--
Three places you can trim, ranked by how clean the result is. Best: at the MCP tool response itself. The tool defines what it returns, so returning only the fields the agent needs means the problem never enters the system. You own the tool, you control the projection, done.

Second best: a PostToolUse hook. One hook that normalizes across multiple tools in a family, so you don't have to modify every tool individually. Useful when you don't own the underlying tools — they might be third-party MCP servers or legacy APIs — but you own the runtime they plug into.

Worst: post-hoc in the agent prompt. "Please ignore these fields." That's too late. The tokens are already in the conversation history. Instructing the model to ignore content that's already loaded doesn't save you tokens and doesn't reliably prevent attention cost either.
-->

---

<script setup>
const trimmedCode = `// RAW: lookup_order returns 40+ fields
{
  "order_id": "O-739421",
  "customer_id": "C-9921",
  "items": [...],
  "shipping_address": {...},
  "billing_address": {...},
  "payment_method": {...},
  "tax_breakdown_by_jurisdiction": {...},
  "fulfillment_partner_id": "FP-33",
  "warehouse_routing_codes": [...],
  "carrier_handoff_timestamps": {...},
  "regional_compliance_flags": {...},
  // ... 30 more fields the agent never references
}

// TRIMMED: project to what the agent needs
{
  "order_id": "O-739421",
  "customer_id": "C-9921",
  "items": [...],
  "shipping_address": {...}
}`
</script>

<CodeBlockSlide
  title="lookup_order -- trimmed response"
  lang="json"
  :code="trimmedCode"
  annotation="Same function, same data source, ~90% less context footprint."
/>

<!--
Concretely, imagine lookup_order returns forty fields. The raw response has order_id, customer_id, items, shipping_address, billing_address, payment_method, tax_breakdown by jurisdiction, fulfillment_partner_id, warehouse_routing_codes, carrier_handoff_timestamps, regional_compliance_flags, and so on for thirty-five fields the agent will never touch.

The trimmed response keeps the first four fields — order_id, customer_id, items, shipping_address — and drops the rest. Same function, same data source, ninety percent less context footprint. And the agent doesn't miss what it never needed. If a downstream case ever requires the billing address, you add it back deliberately. You don't ship everything-by-default.
-->

---

<CalloutBox variant="tip" title="PostToolUse -- cross-tool normalization">

One hook trims all order-adjacent tools in a normalized way. lookup_order, update_order, cancel_order all pipe through the same trimming logic. Covered in Domain 1 Task 1.5.

The right layer when you own the agent runtime but don't own the tools themselves. Enterprise settings -- where MCP servers come from a platform team -- are the classic case.

</CalloutBox>

<!--
The hook option is worth knowing. One PostToolUse hook can trim all order-adjacent tools in a normalized way — lookup_order, update_order, cancel_order all pipe through the same trimming logic. That's the pattern we covered in Domain 1 Task 1.5 — cross-tool normalization through hooks. Single responsibility: read the tool's output, return a projected version. One hook, many tools, consistent trimming.

This is the right layer when you own the agent runtime but don't own the tools themselves. Enterprise settings — where MCP servers come from a platform team — are the classic case.
-->

---

<CalloutBox variant="tip" title="Scenario 1 -- customer support">

Long multi-issue sessions fill with order data. Trim aggressively.

Untrimmed, a session with six lookup_order calls carries 240 fields of operational metadata. Trim, and progressive-summarization machinery from 7.2 has a reasonable-sized input to work on.

Every Domain 5 pattern composes with the others. Trimming is table stakes.

</CalloutBox>

<!--
Scenario 1 — customer support — is where this bites hardest. Long multi-issue sessions fill with order data. A single support session might call lookup_order six times for different orders the customer is asking about. Untrimmed, that's two hundred forty fields of operational metadata accumulating in context. Trim aggressively, and the same session stays clean enough for the agent to actually track what the customer wants, and for the progressive-summarization machinery from 7.2 to work on a reasonable-sized input rather than a bloated one.

Every Domain 5 pattern in this section composes with the others. Trimming tool outputs is table stakes for everything downstream.
-->

---

<CalloutBox variant="tip" title="On the exam">

"Context filling with irrelevant tool data" -> trim at the tool response (or hook).

The distractor -- "use a larger context window" -- is the same trap as 7.1. Larger windows don't fix the structural problem. Reliability comes from discipline at the edges, not capacity in the middle.

</CalloutBox>

<!--
On the exam, the shape is: "Context is filling with irrelevant tool data across long sessions." The right answer is trim at the tool response — or at a hook layer. The distractor is "use a larger context window." Same trap as 7.1. Larger windows don't fix the structural problem — they just give you more room to waste, and more middle to lose things in. This is a Domain 5 question, and the exam is testing whether you understand that reliability comes from discipline at the edges, not from more capacity in the middle.
-->

---

<Frame bg="var(--mint-100)">
  <Eyebrow>Closing</Eyebrow>
  <SlideTitle>Next up: 7.4 -- The Persistent Case Facts Block Pattern.</SlideTitle>

  <div class="closing-body">
    <p>We previewed it in 7.2 as the fix for progressive summarization. Now we build it out into the exam-critical pattern it is.</p>
  </div>
</Frame>

<style scoped>
.closing-body { margin-top: 56px; font-family: var(--font-body); font-size: 30px; line-height: 1.5; color: var(--forest-500); max-width: 1400px; }
</style>

<!--
Next up: 7.4, the persistent case-facts block pattern. We previewed it in 7.2 as the fix for progressive summarization — now we're going to build it out into the exam-critical pattern it is. See you there.
-->

---

<!-- LECTURE 7.4 — The Case Facts Block -->

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div class="di-cover">
    <div class="di-cover__eyebrow">Domain 5 · Lecture 7.4</div>
    <div class="di-cover__title">The Case Facts Block</div>
    <div class="di-cover__subtitle">Structured persistence for transactional facts</div>
  </div>
</Frame>

<style scoped>
.di-cover { flex: 1; display: flex; flex-direction: column; justify-content: center; gap: 32px; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 28px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); }
.di-cover__title { font-family: var(--font-display); font-size: 132px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); max-width: 1500px; }
.di-cover__subtitle { font-family: var(--font-display); font-size: 44px; color: var(--mint-200); font-style: italic; }
</style>

<!--
Lecture 7.4. The persistent case-facts block pattern. This is the single most exam-critical pattern in Domain 5 for Scenario 1 — customer support. Memorize the shape, memorize why it works, and you've locked in a question that shows up in almost every practice pool and in the official sample questions.

Everything in 7.2 and 7.3 was setup for this lecture. Progressive summarization erases numbers; verbose tool outputs clutter context. The case-facts block is the structural pattern that solves both problems at once for transactional conversations.
-->

---

<ConceptHero
  leadLine="Facts don't belong in prose"
  concept="Structure beats narrative."
  supportLine="Transactional facts live in structured storage, not conversation history. That's how they survive summarization."
/>

<!--
Here's the claim. Facts don't belong in prose. Transactional facts — dollar amounts, dates, order numbers, stated expectations — live in structured storage, not in conversation history. That's how they survive summarization. That's how they survive session restarts. That's how they stop silently drifting across long conversations.

The mental move is: stop thinking about conversation memory as one unified thing. There are two memory surfaces. One is narrative — the flow of the conversation, the tone, the escalation history. That one can be summarized. The other is structured — the transactional facts that must remain precise. That one doesn't get summarized, ever.
-->

---

<script setup>
const caseFactsCode = `{
  "customer_id": "C-9921",
  "order_ids": ["O-739421"],
  "amounts": {
    "refund_requested": 47.82,
    "currency": "USD"
  },
  "stated_expectations": [
    "Replacement, not refund -- stated on turn 3"
  ],
  "policy_constraints": [
    "Within 30-day return window",
    "Electronics: manager approval required >$50"
  ],
  "timestamps": {
    "refund_requested_at": "2026-04-12T14:22:00Z"
  }
}`
</script>

<CodeBlockSlide
  title="Case facts block"
  lang="json"
  :code="caseFactsCode"
  annotation="A schema, not a paragraph. Every field has a type."
/>

<!--
The structure is a JSON block. Customer_id. Order_id, or order_ids if the session touches multiple orders. Amounts — including the specific cents, not rounded. Stated_expectations — the exact phrasing the customer used, pulled verbatim where it matters. Policy_constraints that apply to this case. Timestamps for each fact.

It's a schema, not a paragraph. Every field has a type, and every value either exists or is null — no "the customer mentioned something about forty dollars" fuzziness. If the customer said forty-seven eighty-two, the field is 47.82, not "about forty dollars." If the customer said "by Friday," the field is the specific Friday date with timezone, not "soon."
-->

---

<CalloutBox variant="tip" title="Where it lives -- every prompt">

Prepend the block to each turn. Outside summarized conversation history. Part of the context contract.

When you summarize prior turns, you're summarizing narrative. When you reference the case-facts block, you're reading a data structure. Two separate channels. Neither erases the other.

</CalloutBox>

<!--
The block lives outside summarized conversation history. Every prompt — every single turn — prepends the case-facts block. It's not part of the conversation that gets compressed. It's part of the context contract. When you summarize prior turns, you're summarizing narrative. When you reference the case-facts block, you're reading a data structure. Two separate channels. Neither erases the other.

In practice, this means the system prompt or the turn-construction code always inserts the block above the compressed history. Tooling matters here — if your memory library doesn't let you inject a separate structured block, you'll have to build that layer. Don't skip it.
-->

---

<script setup>
const locationRows = [
  { label: 'Casual conversation', cells: [{ text: 'Summarized history', highlight: 'neutral' }] },
  { label: 'Dollar amounts, dates', cells: [{ text: 'Case-facts block', highlight: 'good' }] },
  { label: 'Stated customer requests', cells: [{ text: 'Case-facts block', highlight: 'good' }] },
  { label: 'Explored options', cells: [{ text: 'Summarized history', highlight: 'neutral' }] },
]
</script>

<ComparisonTable
  title="Where facts go"
  :columns="['Location']"
  :rows="locationRows"
/>

<!--
Compare the two locations directly. Casual conversation — "the customer is frustrated about a late delivery" — goes in summarized history. That's fine to paraphrase. Dollar amounts, dates, stated customer requests go in the case-facts block. Never paraphrased. Explored options — "we discussed a refund or a replacement" — go back in summarized history.

The rule: if it's transactional or if the customer said it verbatim, it's a fact. If it's context or tone, it's prose. The split is simple once you internalize it, but it requires discipline — the temptation is to "just summarize everything" for simplicity, and that's what breaks.
-->

---

<CalloutBox variant="tip" title="Multi-issue sessions -- structured entry per issue">

Order + billing + return? Each gets its own structured entry in the case-facts block.

Structured: <code>order_issue, billing_issue, return_issue</code> each as its own object -- stays actionable. A single prose blob that blends them loses all three.

</CalloutBox>

<!--
Real customer sessions often touch multiple issues. An order problem, then a billing question, then a return. Each issue gets its own structured entry in the case-facts block — not a single prose blob that blends them. Order issue has its own order_id, its own amounts, its own stated outcome. Billing issue has its own. Return has its own.

Keep them separate or you'll summarize them together, and once you do, you can't untangle them. "The customer had questions about an order, a bill, and a return" is useless when the agent needs to act on any one of them. "order_issue: {...}, billing_issue: {...}, return_issue: {...}" stays actionable.
-->

---

<CalloutBox variant="note" title="Why this matters in Scenario 1">

Customer-support agents regularly lose track of amounts across summaries (7.2 -- progressive summarization risk). The case-facts block is the structural fix.

You don't tell the model to "remember harder." You externalize the memory into a place where forgetting isn't possible -- it's a schema field, not a sentence that can be rewritten.

</CalloutBox>

<!--
This is why it matters in Scenario 1. Customer support agents regularly lose track of amounts across summaries — we covered that in 7.2 as progressive summarization risk. The case-facts block is the structural fix. You don't tell the model to "remember harder." You externalize the memory into a place where forgetting isn't possible, because it's a schema field, not a sentence that can be rewritten.

The exam treats this as table-stakes knowledge for Scenario 1. If you see a question about preserving transactional data across long support conversations, the answer is this pattern.
-->

---

<script setup>
const antiPatternBad74 = `Trust prior summaries to preserve amounts.

"The summary says the customer wanted a refund."
 -- for how much?
"Uh, it doesn't say."

Also avoid: inflating the block with non-facts.
("customer_mood: frustrated" -- that's narrative.)`

const antiPatternFix74 = `Extract amounts at the moment the
customer states them. Reference the
block every turn.

Keep the block tight -- transactional data only.
Narrative belongs in the summary. Facts
belong in the block. Don't mix.`
</script>

<AntiPatternSlide
  title="Don't rely on conversation history"
  lang="text"
  :badExample="antiPatternBad74"
  whyItFails="Summarization softens amounts into prose. Non-facts bloat the schema and go stale."
  :fixExample="antiPatternFix74"
/>

<!--
The anti-pattern: trust prior summaries to preserve amounts. "The summary says the customer wanted a refund." Great — for how much? "Uh, it doesn't say." That's the failure mode. The better pattern: extract amounts to the facts block at the moment the customer states them, and reference the block every turn. The summary is for tone. The block is for correctness.

There's a second anti-pattern worth flagging — inflating the block with non-facts. "customer_mood: frustrated" does not belong in a facts block. That's narrative, it's paraphrased, and it'll go stale. Keep the block tight. Transactional data only.
-->

---

<CalloutBox variant="tip" title="On the exam">

"Preserve transactional facts across long customer conversations" -> persistent structured facts block.

The distractor -- "use a larger model" or "longer summaries" -- is the same trap from 7.2 and 7.3. Larger models still lose specifics to summarization. Structural fix wins every time.

</CalloutBox>

<!--
On the exam, the shape is: "Preserve transactional facts across long customer conversations." The right answer is a persistent structured facts block. The distractor, again, is "use a larger model" or "longer summaries." Same trap pattern from 7.2 and 7.3 — almost-right. Larger models still lose specifics to summarization. The structural fix is the correct answer every time. This is a Domain 5 pattern that maps directly to Scenario 1 and also informs Scenario 3 — the same "structured persistence beats unstructured memory" principle.
-->

---

<Frame bg="var(--mint-100)">
  <Eyebrow>Closing</Eyebrow>
  <SlideTitle>Next up: 7.5 -- Escalation Decision Framework.</SlideTitle>

  <div class="closing-body">
    <p>When does the agent resolve, and when does it hand off to a human? Very specific triggers -- and two very specific wrong ones. Remember the shape of 7.5 when you get to 7.14.</p>
  </div>
</Frame>

<style scoped>
.closing-body { margin-top: 56px; font-family: var(--font-body); font-size: 30px; line-height: 1.5; color: var(--forest-500); max-width: 1400px; }
</style>

<!--
Next up: 7.5, the escalation decision framework. When does the agent resolve, and when does it hand off to a human? This one has a very specific set of triggers — and two very specific wrong ones. It's also a lecture that pairs tightly with 7.14, so remember the shape of 7.5 when you get to 7.14. See you there.
-->

---

<!-- LECTURE 7.5 — Escalation Decision Framework -->

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div class="di-cover">
    <div class="di-cover__eyebrow">Domain 5 · Lecture 7.5</div>
    <div class="di-cover__title">Escalation Decision Framework</div>
    <div class="di-cover__subtitle">When to escalate vs resolve</div>
  </div>
</Frame>

<style scoped>
.di-cover { flex: 1; display: flex; flex-direction: column; justify-content: center; gap: 32px; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 28px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); }
.di-cover__title { font-family: var(--font-display); font-size: 124px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); max-width: 1500px; }
.di-cover__subtitle { font-family: var(--font-display); font-size: 44px; color: var(--mint-200); font-style: italic; }
</style>

<!--
Lecture 7.5. The escalation decision framework. This is where Scenario 1 lives or dies. The exam tests this with Sample Question 3, and the wrong answers are specifically designed to look empathetic while being exam-wrong. Let's walk through it carefully.

Heads-up: this lecture pairs directly with 7.14. Something I tell you in 7.5 is "always wrong" — self-reported confidence for routing. Something I tell you in 7.14 is "actually right, in a different context" — calibrated confidence for routing. The two lectures look contradictory unless you hold them together. I'll flag the reconciliation again in 7.14. For now, focus on the escalation case — Scenario 1, customer support.
-->

---

<script setup>
const triggerBullets = [
  { label: 'Customer explicitly asks', detail: 'Immediate hand-off. No investigation first.' },
  { label: 'Policy is ambiguous or silent', detail: 'Rulebook doesn\'t cover it -> a human decides.' },
  { label: 'Agent cannot make meaningful progress', detail: 'Actually blocked -- not just "this is taking a while."' },
]
</script>

<BulletReveal
  title="Escalate when..."
  :bullets="triggerBullets"
/>

<!--
Three valid escalation triggers. One: the customer explicitly asks for a human. That's an immediate hand-off — no investigation, no "let me try to help first." Two: the policy is ambiguous or silent on this case. If the rulebook doesn't cover it, a human decides. Three: the agent cannot make meaningful progress. Not "this is taking a while" — actual blocked, actual no next step.

Three triggers. Memorize them in that order. They're the only three that are exam-correct. Every other proposed trigger is a distractor.
-->

---

<script setup>
const nonTriggerBullets = [
  { label: 'Sentiment / tone', detail: 'Frustration != complexity.' },
  { label: 'Self-reported confidence score', detail: 'Uncalibrated -- agent is blind to its own miss.' },
  { label: 'Long conversation length', detail: 'Length is not complexity.' },
  { label: 'Case complexity alone', detail: 'Only when the agent can\'t progress.' },
]
</script>

<BulletReveal
  title="Do NOT use"
  :bullets="nonTriggerBullets"
/>

<!--
What's not a trigger? Sentiment and tone. Self-reported confidence score. Long conversation length. Case complexity alone. Write those down as the wrong-answers-to-recognize list. Every one of them will appear as a distractor on this exam, and every one of them looks reasonable in isolation. That's the trap.

Sentiment looks like care. Confidence looks like self-awareness. Conversation length looks like evidence of struggle. Complexity looks like a legitimate reason. None of them are the right trigger.
-->

---

<ConceptHero
  leadLine="Frustration != complexity"
  concept="Tone is not signal."
  supportLine="Acknowledge frustration; offer resolution; escalate only if they reiterate."
/>

<!--
Frustration does not equal complexity. A frustrated customer may have a perfectly simple issue — they're just having a bad day, or they got bounced between systems before reaching the agent, or their expectation mismatched reality in a simple way you can still resolve.

Routing on sentiment sends simple cases to human queues that are meant for genuinely hard problems. That's bad service AND bad architecture — the human reviewer is suddenly fielding "I'm mad about my order" cases that the agent could have fixed in two turns, while genuine edge cases wait in the same queue.

The right move: acknowledge the frustration, offer to resolve, and only escalate if the customer reiterates a preference for a human. Sentiment goes into tone. Escalation goes on the three triggers. We'll sharpen this further in 7.7.
-->

---

<CalloutBox variant="warn" title="Self-reported confidence is uncalibrated (Sample Q3)">

Agents are already wrongly confident on hard cases. Self-report can't detect its own miss.

<p>Hold onto this. <strong>We'll revisit in 7.14 for a very different context</strong> -- extraction pipelines with a labeled validation set -- where calibrated confidence DOES work. But for escalation in Scenario 1, without calibration data, self-report is a distractor. Same phrase, two contexts, two opposite exam answers. The reconciliation is in 7.14.</p>

</CalloutBox>

<!--
Self-reported confidence is uncalibrated. This is Sample Question 3 territory. Agents are already wrongly confident on the cases they get wrong — that's literally how miscalibration works. "Let the model escalate when confidence is low" assumes the model can detect its own failure mode. It can't. The low-confidence cases are sometimes easy; the high-confidence wrong cases are the scary ones. Self-report is blind to its own misses.

Hold onto this. We're going to revisit it in 7.14 for a very different context — extraction pipelines with a labeled validation set — where calibrated confidence DOES work. But for escalation in Scenario 1, without calibration data, self-report is a distractor. Full stop. Same phrase, two contexts, two opposite exam answers. The reconciliation is in 7.14.
-->

---

<script setup>
const promptCode = `# System prompt -- escalation criteria

Escalate when:
1. Customer uses phrases like "let me speak to a human,"
   "this is unacceptable, give me a manager."
2. The policy page referenced doesn't cover this scenario.
3. You have attempted resolution but cannot progress.

DO NOT escalate on:
- Frustrated tone alone.
- Long conversation length.
- Your own uncertainty about the answer.

# Few-shot examples

User: "This is frustrating -- my order is still not here."
Correct: Acknowledge + attempt resolution. Do NOT escalate.

User: "Is there someone else I can talk to?"
Correct: Escalate. This is a human request.

User: "The policy page says nothing about expired warranties."
Correct: Escalate. Policy ambiguity.`
</script>

<CodeBlockSlide
  title="Escalation criteria in the system prompt"
  lang="text"
  :code="promptCode"
  annotation="Explicit criteria + 2-3 few-shot examples = calibrated router. No confidence score needed."
/>

<!--
The right pattern in the system prompt: explicit criteria, written out, plus two or three few-shot examples of edge cases. "Escalate when the customer uses phrases like 'let me speak to a human,' 'this is unacceptable — give me a manager,' or when the policy page referenced doesn't cover this scenario." Explicit. In writing. Visible to the model every turn.

The criteria do the heavy lifting for clear cases. The few-shots handle the ambiguity. Between them, you get a calibrated router without needing any model-reported confidence number at all.
-->

---

<CalloutBox variant="tip" title="Few-shots for edge cases -- callback to 6.4">

Same pattern from 6.4 -- ambiguous scenarios get example-driven training. Here the ambiguity is "escalate or not?"

Pairs that work well:
<ul>
<li>"This is frustrating" (no human ask) -> do NOT escalate; acknowledge + offer resolution.</li>
<li>"Is there someone else I can talk to?" -> escalate; that's a human request.</li>
</ul>

</CalloutBox>

<!--
Few-shot examples handle the ambiguous cases. This is the same pattern we covered in 6.4 — ambiguous scenarios get example-driven training. Here the ambiguity is specifically "escalate or not?" — so your few-shots are pairs: customer phrasing, correct decision. Two or three is enough. The model learns the edge cases from the examples; it learns the bright-line cases from the criteria.

Real pairs that work well: "customer says 'this is frustrating' without asking for a human" paired with "do NOT escalate; acknowledge and offer resolution." "Customer asks 'is there someone else I can talk to'" paired with "escalate; this is a human request." The few-shots force the model to pattern-match against concrete examples rather than interpret ambiguous phrases on its own.
-->

---

<CalloutBox variant="tip" title="Sample Q3">

Explicit criteria + few-shots wins. Sentiment analysis and confidence scoring are both distractors -- known-wrong on this exam.

<p>Recognize by ingredients: multi-turn customer support, first-contact resolution target, agent deciding when to hand off. Explicit-criteria-plus-few-shots is the answer. Every time.</p>

</CalloutBox>

<!--
Sample Question 3 is the canonical form. The right answer combines explicit criteria plus few-shots. The distractors are: sentiment analysis for automatic escalation (known-wrong on this exam), confidence-score routing (known-wrong for this use case), and "escalate all long conversations" (length is not complexity). Explicit criteria plus few-shots wins. Every time.

Recognize the question by its symptoms — multi-turn customer support, first-contact resolution target, agent deciding when to hand off. If those ingredients are in the prompt, the answer is the explicit-criteria-plus-few-shots pattern.
-->

---

<BigQuote
  lead="Continuity"
  quote="This is where Scenario 1 lives or dies. <em>80% first-contact resolution</em> depends on this calibration."
  attribution="Escalate too aggressively -> overwhelm the queue. Too conservatively -> frustrated customers stuck."
/>

<!--
This is where Scenario 1 lives or dies. Eighty-percent first-contact resolution — a common target in customer support architectures — depends on this calibration. Escalate too aggressively and you overwhelm the human queue. Escalate too conservatively and frustrated customers stay stuck with the bot. The three triggers give you the discipline to land in the middle.
-->

---

<Frame bg="var(--mint-100)">
  <Eyebrow>Closing</Eyebrow>
  <SlideTitle>Next up: 7.6 -- Honoring Explicit Customer Requests for Human Agents.</SlideTitle>

  <div class="closing-body">
    <p>The first of the three triggers, zoomed in -- because the exam has a very specific position on what "honor" means in practice, and the distractor is particularly slippery.</p>
  </div>
</Frame>

<style scoped>
.closing-body { margin-top: 56px; font-family: var(--font-body); font-size: 30px; line-height: 1.5; color: var(--forest-500); max-width: 1400px; }
</style>

<!--
Next up: 7.6, honoring explicit customer requests for human agents. This is the first of the three triggers, zoomed in — because the exam has a very specific position on what "honor" means in practice, and the distractor there is particularly slippery. See you there.
-->

---

<!-- LECTURE 7.6 — Honoring Explicit Human Requests -->

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div class="di-cover">
    <div class="di-cover__eyebrow">Domain 5 · Lecture 7.6</div>
    <div class="di-cover__title">Honoring Explicit<br/>Human Requests</div>
    <div class="di-cover__subtitle">The short lecture that gets missed</div>
  </div>
</Frame>

<style scoped>
.di-cover { flex: 1; display: flex; flex-direction: column; justify-content: center; gap: 32px; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 28px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); }
.di-cover__title { font-family: var(--font-display); font-size: 112px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); max-width: 1500px; }
.di-cover__subtitle { font-family: var(--font-display); font-size: 44px; color: var(--mint-200); font-style: italic; }
</style>

<!--
Lecture 7.6. Honoring explicit customer requests for human agents. This is the shortest lecture in Section 7, and also one of the most commonly missed questions on the exam — because the distractor reads like good customer service, and the "right answer" reads almost abrupt by comparison.
-->

---

<BigQuote
  lead="The rule"
  quote="The customer asked for a human. <em>Escalate.</em> Don't open the investigation first."
  attribution="No 'let me try to help first.' No reframe. Route it."
/>

<!--
Here's the rule in one sentence. The customer asked for a human. Escalate. Don't open the investigation first.

That's it. There is no "let me try to help first," no "can you tell me a bit more about the issue before I connect you," no gentle reframe. The customer's explicit ask is the trigger. The agent's job is to route it, confirm the hand-off, and stay out of the customer's way.
-->

---

<ConceptHero
  leadLine="Respect the explicit ask"
  concept="Customer decided. Route."
  supportLine="The exam treats this as a hard requirement, not a judgment call."
/>

<!--
Why is the rule so strict? Because investigating first ignores the customer's stated preference. The customer already made the decision — they want a human. The agent running a diagnostic loop on top of that is overriding a customer decision with its own judgment about whether the human-routing is necessary.

The exam treats this as a hard requirement, not a judgment call. Respect the explicit ask. In production, some teams will argue that "trying to resolve first" saves human-agent time, and sometimes that's fine policy. But on this exam, with this scenario framing, the right answer is to honor the ask immediately.
-->

---

<CalloutBox variant="tip" title="The nuance -- frustration without ask">

If the customer is frustrated but has NOT asked for a human: acknowledge the frustration AND offer to resolve.

<p>If they reiterate under pushback -- "no, I want a human" -- then yes, escalate. <strong>One explicit ask plus reiteration = same signal as a clean first-turn request.</strong> The agent's willingness to try once doesn't entitle it to try three times.</p>

</CalloutBox>

<!--
Here's the nuance that tripped me up the first time through the study guide. Frustration is not the same signal as an explicit request. If the customer is frustrated but has NOT asked for a human, the right move is to acknowledge the frustration AND offer to resolve. You don't escalate on frustration alone — we covered that in 7.5 and we'll sharpen it in 7.7.

But if they reiterate, if they say "no, I want a human," then yes, escalate. The distinction: one explicit ask plus a reiteration under pushback is functionally the same signal as a clean first-turn request. Honor it. The agent's willingness to try once doesn't entitle it to try three times — one attempt, one re-ask, hand-off.
-->

---

<script setup>
const treeSteps = [
  { label: 'Explicit ask?', sublabel: 'Did the customer say "human"?' },
  { label: 'YES -> escalate now', sublabel: 'Route, confirm, stay out of the way' },
  { label: 'NO -> acknowledge + resolve', sublabel: 'Attempt once. Politely.' },
  { label: 'Reiterated? -> escalate', sublabel: 'One retry earns one re-ask -> hand off' },
]
</script>

<FlowDiagram
  title="Escalation trigger"
  :steps="treeSteps"
/>

<!--
Decision tree. Did the customer explicitly ask for a human? If yes — escalate now. If no — acknowledge and attempt to resolve. After the attempt, did the customer reiterate the preference for a human? If yes — escalate. If no — keep resolving.

Notice the tree doesn't branch on sentiment. It branches on explicit ask. That's the discipline. A calm customer who asks for a human still gets escalated — sentiment isn't required. A frustrated customer who doesn't ask for a human doesn't get escalated — frustration isn't enough.
-->

---

<script setup>
const antiPatternBad76 = `Customer: "I want to talk to a human."
Agent: "Let me try to help you first --
can you tell me what's going on?"

-> Sounds polite. Is exam-wrong.
-> Overrides the customer's stated decision.`

const antiPatternFix76 = `Customer: "I want to talk to a human."
Agent: "Connecting you now --
one moment while I hand this off."

-> Respect the stated preference.
-> Polite by honoring the ask, not by overriding it.`
</script>

<AntiPatternSlide
  title="Don't resolve over an explicit ask"
  lang="text"
  :badExample="antiPatternBad76"
  whyItFails="Politeness is the whole distractor. 'Let me try first' reads as service but overrides a customer choice."
  :fixExample="antiPatternFix76"
/>

<!--
The anti-pattern: customer asks for a human, agent says "let me try to help first." That's the almost-right distractor — it sounds like attentive service. It reads as polite. It is exam-wrong.

The better pattern: customer asks for a human, agent escalates immediately and confirms the hand-off. Polite in a different way — polite by respecting the stated preference rather than overriding it. The customer wanted a human and the system gave them one, quickly. That's the service.
-->

---

<CalloutBox variant="tip" title="On the exam -- two phrasings, two answers">

<p><strong>"Customer explicitly requests a human"</strong> -> escalate immediately, no investigation.</p>
<p><strong>"Customer sounds frustrated"</strong> -> acknowledge and offer resolution.</p>

Two different signals. The exam tests whether you can tell them apart under scenario pressure. If the question describes both -- frustration AND an explicit ask -- the <em>explicit ask wins</em>. Always.

</CalloutBox>

<!--
On the exam, two phrasings map to two different answers. "Customer explicitly requests a human" — escalate immediately, no investigation. "Customer sounds frustrated" — acknowledge and offer resolution. These are two different signals, and the exam tests whether you can tell them apart under scenario pressure. Almost-right is the whole trap of this exam — and this is a clean example of it.

If the question describes both — "the customer sounds frustrated and says 'I want to talk to a human'" — the explicit ask wins. Always. Escalation now.
-->

---

<Frame bg="var(--mint-100)">
  <Eyebrow>Closing</Eyebrow>
  <SlideTitle>Next up: 7.7 -- Sentiment vs Complexity.</SlideTitle>

  <div class="closing-body">
    <p>We just talked about why frustration isn't the escalation trigger. Next lecture zooms in on WHY -- and on why the exam specifically rules out sentiment-based routing as an entire category of wrong answer.</p>
  </div>
</Frame>

<style scoped>
.closing-body { margin-top: 56px; font-family: var(--font-body); font-size: 30px; line-height: 1.5; color: var(--forest-500); max-width: 1400px; }
</style>

<!--
One last mental note before we move on. This lecture looks tiny compared to the cluster around it — 7.5 on the framework, 7.7 on sentiment-versus-complexity, 7.14 on the calibration nuance. But the "explicit ask means immediate escalate" rule is its own testable item. The exam has been seen to isolate this specific trigger in a question and ask for the correct agent behavior. If you've studied only the 7.5 framework and not this zoomed-in version, you might pick the "try to help first" distractor — because it sounds like the compassionate move. Resist that. Explicit ask equals escalate.

Next up: 7.7, sentiment versus complexity. We just talked about why frustration isn't the escalation trigger. Next lecture zooms in on why — and on why the exam specifically rules out sentiment-based routing as an entire category of wrong answer. See you there.
-->

---

<!-- LECTURE 7.7 — Sentiment vs Complexity -->

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div class="di-cover">
    <div class="di-cover__eyebrow">Domain 5 · Lecture 7.7</div>
    <div class="di-cover__title">Sentiment vs Complexity</div>
    <div class="di-cover__subtitle">Why they're not the same</div>
  </div>
</Frame>

<style scoped>
.di-cover { flex: 1; display: flex; flex-direction: column; justify-content: center; gap: 32px; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 28px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); }
.di-cover__title { font-family: var(--font-display); font-size: 132px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); max-width: 1500px; }
.di-cover__subtitle { font-family: var(--font-display); font-size: 44px; color: var(--mint-200); font-style: italic; }
</style>

<!--
Lecture 7.7. Sentiment versus complexity. This is one of the cleanest "almost-right" traps on the entire exam. If you get this one, you're going to pick up points other candidates miss — and more importantly, you're going to understand a distinction that shows up in multiple question variants.
-->

---

<script setup>
const matrixRows = [
  {
    label: 'Calm',
    cells: [
      { text: 'Resolve', highlight: 'good' },
      { text: 'Escalate (complexity)', highlight: 'neutral' },
    ],
  },
  {
    label: 'Frustrated',
    cells: [
      { text: 'Acknowledge + resolve', highlight: 'good' },
      { text: 'Acknowledge + escalate', highlight: 'neutral' },
    ],
  },
]
</script>

<ComparisonTable
  title="Sentiment x Complexity"
  :columns="['Simple', 'Complex']"
  :rows="matrixRows"
/>

<!--
Picture a two-by-two grid. One axis is sentiment — calm or frustrated. The other axis is case complexity — simple or complex. That gives you four cells.

Calm and simple: resolve. The agent handles it, no drama. Calm and complex: escalate, because the case needs it — calm isn't a signal to keep pushing. Frustrated and simple: acknowledge the frustration AND resolve — the simple case is still simple, the frustration just changes the tone. Frustrated and complex: acknowledge AND escalate — the complexity drives the escalation, not the frustration.

Notice what's consistent across the grid: escalation branches on complexity, not sentiment. Sentiment only changes whether you acknowledge. The same case complexity always produces the same routing decision, regardless of how the customer feels.
-->

---

<ConceptHero
  leadLine="Orthogonal signals"
  concept="Feel != Need."
  supportLine="Sentiment = how they feel. Complexity = what the case needs. Using one as a proxy for the other routes simple cases away from resolution."
/>

<!--
Here's the principle. Sentiment is how the customer feels. Complexity is what the case needs. Those are orthogonal signals — they measure different things entirely. A customer can be calm about a case that's legitimately unsolvable by the agent; a customer can be furious about a case that's a two-click fix.

Using sentiment as a proxy for complexity conflates the two, and it routes simple cases away from resolution just because the customer sounds upset. That's bad service AND bad architecture — the human queue fills with simple-but-frustrating cases while genuinely hard problems wait their turn behind them.
-->

---

<CalloutBox variant="warn" title="Sample Q3 -- distractor D">

"Sentiment analysis for automatic escalation" -- wrong. Sentiment doesn't correlate with complexity.

<p>Once you recognize the 2x2, this is a one-line distractor rule-out. <strong>The correct answer is always explicit criteria plus few-shot examples</strong> -- the pattern from 7.5.</p>

</CalloutBox>

<!--
This ties directly to Sample Question 3. One of the distractors is "use sentiment analysis for automatic escalation." Wrong. Sentiment doesn't correlate with complexity — we just walked through the 2x2 that proves the two axes are independent. The exam specifically lists sentiment-based routing as an incorrect answer, and the correct answer is always explicit criteria plus few-shot examples — the pattern from 7.5.

This is one of the "known-wrong" distractors on this exam. Once you recognize it, you can rule it out on sight.
-->

---

<CalloutBox variant="tip" title="Acknowledge, don't route">

Sentiment still has a role -- it's just not the escalation trigger.

<p>Right use: "I can hear this has been frustrating -- let me see what I can do." That's the job sentiment does. It sets the <em>tone</em> of the response. Not the routing decision.</p>

<p>Acknowledgment costs nothing. Routing costs a human-agent slot.</p>

</CalloutBox>

<!--
Sentiment still has a role — it's just not the escalation trigger. The right use: acknowledge the feeling. "I can hear this has been frustrating — let me see what I can do." That's the job sentiment does. It doesn't set the routing decision; it sets the tone of the response.

Acknowledge, don't route. That's the phrase to hold. Acknowledgment costs nothing and preserves the customer experience. Routing costs a human-agent slot and should be reserved for cases that actually need one.
-->

---

<BigQuote
  lead="Continuity -- 1.1's frame"
  quote="<em>Almost-right is the whole trap.</em> Sentiment-based escalation <em>looks</em> empathetic. It's not the right mechanism."
  attribution="Right in a different context -- wrong for the complexity-routing question the exam is asking"
/>

<!--
Remember 1.1's frame — almost-right is the whole trap of this exam. Sentiment-based escalation LOOKS empathetic. It reads like the right answer if you're thinking about customer experience and not about case routing. But it conflates two different signals, and the exam penalizes the conflation every time. This is the kind of distractor that shows up because it'd be right in a different context — routing to a human-tone-specialist, maybe, or prioritizing a de-escalation workflow — but it's wrong for the complexity-routing question the exam is asking.
-->

---

<CalloutBox variant="tip" title="On the exam -- pattern rule-out">

"Automate escalation via sentiment" is always a distractor in Scenario 1 questions.

<p>The right answer is explicit criteria, written into the system prompt, with few-shot examples for edge cases.</p>

<p>If you see "sentiment" in an answer choice for a Scenario 1 escalation question -> eliminate without re-reading. That's the shortcut this lecture earns you.</p>

</CalloutBox>

<!--
On the exam, the shape: "Automate escalation via sentiment analysis" is always a distractor in Scenario 1 questions. The right answer is explicit criteria, written into the system prompt, with few-shot examples for the edge cases. Memorize the pattern — sentiment is out, explicit criteria plus few-shots is in.

If you see sentiment in the answer choices for a Scenario 1 escalation question, you can eliminate that choice without re-reading the question. That's the shortcut this lecture earns you.
-->

---

<Frame bg="var(--mint-100)">
  <Eyebrow>Closing</Eyebrow>
  <SlideTitle>Next up: 7.8 -- Structured Error Propagation.</SlideTitle>

  <div class="closing-body">
    <p>The sentiment-vs-complexity shape shows up elsewhere: self-reported confidence as a proxy for accuracy, conversation length as a proxy for difficulty. <em>One signal as a proxy for another when the two are orthogonal.</em> Rule it out across multiple lecture topics.</p>
    <p>Now we shift from Scenario 1 customer support into Scenario 3 multi-agent research -- and the error patterns over there are a whole different discipline.</p>
  </div>
</Frame>

<style scoped>
.closing-body { margin-top: 56px; font-family: var(--font-body); font-size: 28px; line-height: 1.5; color: var(--forest-500); max-width: 1400px; }
.closing-body p + p { margin-top: 24px; }
.closing-body p em { color: var(--forest-800); font-style: italic; }
</style>

<!--
One more thing to carry forward before we leave this lecture. The sentiment-versus-complexity distinction isn't just for the escalation question. The same conflation pattern shows up elsewhere on the exam — using one signal as a proxy for another when the two are orthogonal. Self-reported confidence as a proxy for accuracy — same conflation, different domain, covered in 7.5 and 7.14. Conversation length as a proxy for difficulty — same conflation, different axis. Once you recognize the shape, you can rule out distractors across multiple lecture topics. That's the leverage Domain 5 gives you when you study it carefully — the patterns compose.

Next up: 7.8, structured error propagation across multi-agent systems. We're shifting from Scenario 1 customer support into Scenario 3 multi-agent research — and the error patterns over there are a whole different discipline. See you there.
-->

---

<!-- LECTURE 7.8 — Structured Error Propagation -->

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div class="di-cover">
    <div class="di-cover__eyebrow">Domain 5 · Lecture 7.8</div>
    <div class="di-cover__title">Structured Error Propagation</div>
    <div class="di-cover__subtitle">The four fields that enable coordinator recovery</div>
  </div>
</Frame>

<style scoped>
.di-cover { flex: 1; display: flex; flex-direction: column; justify-content: center; gap: 32px; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 28px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); }
.di-cover__title { font-family: var(--font-display); font-size: 120px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); max-width: 1500px; }
.di-cover__subtitle { font-family: var(--font-display); font-size: 44px; color: var(--mint-200); font-style: italic; }
</style>

<!--
Lecture 7.8. Structured error propagation across multi-agent systems. We're now firmly in Scenario 3 territory — the multi-agent research system — and the reliability backbone of that scenario is how subagents report failure back to the coordinator. If you understand this pattern, a whole cluster of Scenario 3 questions become straightforward.
-->

---

<Frame>
  <Eyebrow>Structured subagent error</Eyebrow>
  <SlideTitle>Four fields. Memorize all of them.</SlideTitle>

  <div class="schema-grid">
    <v-clicks>
      <SchemaField name="failure_type" type="enum" :required="true" description="timeout | validation | permission | rate_limit | ..." example="&quot;timeout&quot;" />
      <SchemaField name="attempted_query" type="string" :required="true" description="What the subagent tried -- so the coordinator doesn't re-issue the same thing." example="&quot;Q3 analyst reports on cloud infra&quot;" />
      <SchemaField name="partial_results" type="any" :required="false" description="Whatever the subagent did retrieve before failing. Downstream can still use it." example="[{...}, {...}]" />
      <SchemaField name="alternatives" type="list" :required="false" description="Subagent-proposed next approaches -- it knows its own domain best." example="[&quot;narrower query&quot;, &quot;archive source&quot;]" />
    </v-clicks>
  </div>
</Frame>

<style scoped>
.schema-grid { margin-top: 40px; display: grid; grid-template-columns: 1fr 1fr; gap: 24px; }
</style>

<!--
When a subagent fails, the error it propagates needs four fields. Failure_type — an enum: timeout, validation, permission, rate_limit, and so on. Attempted_query — the specific thing the subagent tried to do. Partial_results — whatever it did manage to retrieve before the failure. Alternatives — suggested next approaches, because the subagent knows its own domain better than the coordinator does.

Four fields. Hold them. This is the canonical shape, and it's the shape Sample Question 8 tests directly. Memorizing the four field names is worth the five minutes it takes — they appear almost verbatim in exam answer choices.
-->

---

<script setup>
const fieldBullets = [
  { label: 'failure_type -> which recovery path', detail: 'timeout retries; validation reformulates; permission routes elsewhere' },
  { label: 'attempted_query -> don\'t re-try the same', detail: 'Coordinator knows the exact thing that failed' },
  { label: 'partial_results -> don\'t waste what worked', detail: 'If 3 of 5 docs returned, use those' },
  { label: 'alternatives -> subagent knows its domain', detail: 'Suggests broader query, different source, different tool' },
]
</script>

<BulletReveal
  title="Each field answers..."
  :bullets="fieldBullets"
/>

<!--
Each field answers a specific coordinator question. Failure_type answers "which recovery path do I take?" — timeout gets retried, validation gets reformulated, permission gets routed to a different subagent or escalated. Attempted_query answers "don't re-try the same thing" — the coordinator has the exact query that already failed and can avoid re-issuing it. Partial_results answers "don't waste what worked" — if three of five documents came back before the timeout, those three are still useful to downstream subagents. Alternatives answers "the subagent knows its own domain" — it can suggest a broader query, a different source, a different tool.

Drop any one of these and the coordinator is guessing. Keep all four and recovery becomes deterministic.
-->

---

<script setup>
const errorCode = `// BAD -- generic status, lost information
{
  "error": "search unavailable"
}

// GOOD -- structured error for coordinator recovery
{
  "failure_type": "timeout",
  "attempted_query": "Q3 2025 analyst reports on cloud infra",
  "partial_results": [
    { "doc_id": "D-201", "title": "...", "excerpt": "..." },
    { "doc_id": "D-214", "title": "...", "excerpt": "..." }
  ],
  "alternatives": [
    "Retry with narrower query: 'Q3 2025 AWS revenue'",
    "Try the archive source instead of live web"
  ]
}`
</script>

<CodeBlockSlide
  title="Web search timeout -> coordinator"
  lang="json"
  :code="errorCode"
  annotation="Bad: 'search unavailable.' Good: structured context with partials and alternatives."
/>

<!--
The canonical example: web search times out. Bad error propagation: "search unavailable." That string tells the coordinator nothing. Was it a transient network issue? A rate limit? A bad query? Should the coordinator retry, reformulate, or skip this subagent? No way to know.

Good error propagation: failure_type is "timeout," attempted_query is the full search string the subagent tried, partial_results contains the two or three documents that returned before the timeout window closed, alternatives is a list — "retry with a narrower query" or "try the archive source instead of live web." That's actionable. The coordinator picks a recovery path by reading the structured fields. No guesswork.
-->

---

<script setup>
const antiPatternBad78 = `Generic status
  -> "search unavailable"
  -> coordinator has nothing to act on.

Silent suppression
  -> catch timeout, return [], success: true
  -> coordinator thinks research finished.`

const antiPatternFix78 = `Structured context with partials:
  failure_type   ->  "timeout"
  attempted_query -> the exact query
  partial_results -> whatever returned
  alternatives   -> subagent suggestions

Coordinator reads -> picks recovery.`
</script>

<AntiPatternSlide
  title="Two ways to propagate wrong"
  lang="text"
  :badExample="antiPatternBad78"
  whyItFails="Both make the happy path simpler while actively harming the recovery path. Generic loses info; silent loses the fact that anything went wrong."
  :fixExample="antiPatternFix78"
/>

<!--
Two ways to propagate errors wrong. Generic status — "search unavailable" — which I just walked through. And silent suppression — catching the timeout and returning an empty result with a success flag. Both are wrong. Generic loses information. Silent loses the fact that anything went wrong at all. The good shape: structured context with partials, explicit failure type, and alternatives.

Both anti-patterns are tempting because they make the happy path simpler. "Just return something the coordinator can process" feels like good engineering. In a reliability-critical pipeline, it's actively harmful.
-->

---

<CalloutBox variant="warn" title="Silent suppression -- the worst anti-pattern">

Catch timeout -> return empty result marked success. Coordinator thinks research finished. Synthesizes a report as if the search was complete.

The user receives a clean-looking report that silently lost entire research branches.

<p>Covered again in 7.9 -- access failure vs valid empty result. Same failure mode, zoomed in.</p>

</CalloutBox>

<!--
Silent suppression is the worst of the two. If the subagent catches a timeout and returns `[]` with `success: true`, the coordinator thinks the research finished and found nothing. It proceeds to synthesize a report as if the search was complete. And the user receives a clean-looking report that silently lost entire research branches.

We're going to come back to this exact failure in 7.9, where we separate access failure from valid empty results. Those two look identical in the data structure — and collapsing them is the worst error you can make in a multi-agent system. Silent suppression is how the collapse happens.
-->

---

<CalloutBox variant="tip" title="Same pattern, different layer -- callback to 4.7">

This is the Domain 5 counterpart to Domain 2's local-recovery-vs-propagate question from 4.7.

<p>Domain 2: <em>when</em> a tool handles an error itself versus kicks it up.<br/>Domain 5: <em>what</em> the kick-up looks like when it happens.</p>

One pattern, two layers -- both tested on this exam.

</CalloutBox>

<!--
This is the Domain 5 counterpart to Domain 2's local-recovery-versus-propagate question from 4.7. Same pattern, different angle. Domain 2 is about when a tool handles an error itself versus kicks it up to the agent. Domain 5 is about what the kick-up looks like when it happens — the structured shape the coordinator needs in order to act.

One pattern, two layers — both tested on this exam. If you've already internalized 4.7, this lecture is reinforcement, not new material. The discipline is the same: structured errors, explicit categories, no silent swallows.
-->

---

<CalloutBox variant="tip" title="Sample Q8">

Structured error context -- failure_type, attempted_query, partial_results, alternatives. Know all four.

<p>Exam phrasings: "best way for a subagent to report a timeout" -- same pattern. The answer is always the four-field structure. Distractors: generic string error; silent-suppression empty result.</p>

</CalloutBox>

<!--
Sample Question 8 is the canonical form. The right answer names structured error context — failure_type, attempted_query, partial_results, alternatives. Know all four field names. The distractor is generic error propagation ("return a string") or silent suppression ("catch and return empty"). Both are exam-wrong. The four-field structured shape is exam-right.

The exam also tests this as "which of the following is the best way for a subagent to report a timeout" — same pattern, different phrasing. The answer is always the four-field structure.
-->

---

<BigQuote
  lead="Continuity"
  quote="Scenario 3 -- multi-agent research -- this is the <em>reliability backbone</em>."
  attribution="Don't skip it because Domain 5 is only 15%. The four fields are the kind of memorizable structure the exam rewards directly."
/>

<!--
Scenario 3 — multi-agent research — is where this is the reliability backbone. If you're preparing for Scenario 3 and you don't know the four fields cold, you will miss the question. Don't skip it because it's Domain 5 and Domain 5 is only fifteen percent. This particular pattern is worth the study time — it's the kind of concrete, memorizable structure that the exam rewards directly.
-->

---

<Frame bg="var(--mint-100)">
  <Eyebrow>Closing</Eyebrow>
  <SlideTitle>Next up: 7.9 -- Access Failure vs Valid Empty Result.</SlideTitle>

  <div class="closing-body">
    <p>We just previewed it -- now we're going to separate the two clearly. Single-concept lecture. One of the highest-leverage distinctions on the exam.</p>
  </div>
</Frame>

<style scoped>
.closing-body { margin-top: 56px; font-family: var(--font-body); font-size: 30px; line-height: 1.5; color: var(--forest-500); max-width: 1400px; }
</style>

<!--
Next up: 7.9, access failure versus valid empty result. We just previewed it — now we're going to separate the two clearly. This is a single-concept lecture and one of the highest-leverage distinctions on the exam. See you there.
-->

---

<!-- LECTURE 7.9 — Access Failure vs Valid Empty Result -->

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div class="di-cover">
    <div class="di-cover__eyebrow">Domain 5 · Lecture 7.9</div>
    <div class="di-cover__title">Access Failure vs<br/>Valid Empty Result</div>
    <div class="di-cover__subtitle">Two shapes of empty. One is the answer. One is silence.</div>
  </div>
</Frame>

<style scoped>
.di-cover { flex: 1; display: flex; flex-direction: column; justify-content: center; gap: 32px; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 28px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); }
.di-cover__title { font-family: var(--font-display); font-size: 108px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); max-width: 1500px; }
.di-cover__subtitle { font-family: var(--font-display); font-size: 40px; color: var(--mint-200); font-style: italic; }
</style>

<!--
Lecture 7.9. Access failure versus valid empty result. This is a single-concept lecture, and the concept is: two very different things can produce the same empty data structure, and collapsing them is the worst error you can make in a reliability system.

This is a short lecture, but it's high-leverage. The exam tests this distinction across Scenarios 1, 3, and 6 — anywhere a tool or subagent can return nothing. If you internalize this one distinction, you pick up points in three scenarios from a single pattern.
-->

---

<script setup>
const distinctionRows = [
  {
    label: 'Empty because access failed',
    cells: [
      { text: 'Answer unknown -- try again or alternative', highlight: 'bad' },
      { text: 'Retry / route / escalate', highlight: 'neutral' },
    ],
  },
  {
    label: 'Empty because no matches',
    cells: [
      { text: 'THAT is the answer', highlight: 'good' },
      { text: 'Proceed with null result', highlight: 'neutral' },
    ],
  },
]
</script>

<ComparisonTable
  title="Two empty shapes"
  :columns="['Meaning', 'Recovery']"
  :rows="distinctionRows"
/>

<!--
Two shapes of empty. The first: empty because the query failed to execute. Timeout, permission denied, service unavailable, rate limit. The answer is unknown. Recovery is retry or route to an alternative.

The second: empty because the query succeeded but found no matches. "No customer with that email." "No documents mentioning that topic." "No orders in the date range." That IS the answer. Recovery is proceed with the null result — the search ran, and the answer is none.

Same data structure in the naive implementation. Totally different meanings. Totally different next actions. The exam asks about this collapse directly.
-->

---

<ConceptHero
  leadLine="Collapsing is worse than failing loudly"
  concept="Silent != safe."
  supportLine="Treating access failure as empty is a false negative. Coordinator proceeds as if the search ran and found nothing."
/>

<!--
Collapsing is worse than failing loudly. If you treat access failure as empty, you've produced a false negative — you're asserting "we checked and there's nothing" when actually you never checked. The coordinator proceeds as if the search ran successfully and found nothing. The report ships. The decision gets made on non-data.

Failing loudly — propagating the failure explicitly — is recoverable. The coordinator knows to retry, to route, to flag. Collapsing silently is not recoverable. Nobody knows anything went wrong, because everything looks like it worked. The report is produced; the user reads it; the error surfaces days later when someone notices the research missed a whole branch.
-->

---

<script setup>
const statusCode = `// CLEAN MISS -- the search ran, answer is none
{
  "status": "empty_result",
  "success": true,
  "results": []
}

// ACCESS FAILURE -- the search didn't complete
{
  "status": "access_failure",
  "success": false,
  "failure_type": "timeout",
  "attempted_query": "customer@example.com",
  "partial_results": [],
  "alternatives": [
    "Retry in 5s",
    "Check replica database"
  ]
}`
</script>

<CodeBlockSlide
  title="Distinct statuses in the schema"
  lang="json"
  :code="statusCode"
  annotation="Two statuses, two recovery branches. Never the same [] for both."
/>

<!--
The fix is distinct statuses in the response schema. On a clean miss: status "empty_result," success true. On a failure: status "access_failure," success false, plus the failure fields we covered in 7.8 — failure_type, attempted_query, partial_results, alternatives.

Two statuses, two branches in the coordinator's recovery logic. Never the same `[]` for both cases. The schema itself enforces the distinction — it's not a convention, it's a contract.
-->

---

<CalloutBox variant="tip" title="Scenario 1 -- customer support angle">

"Customer not found" vs "customer database timed out" -- two completely different user experiences.

<p>If the agent says "we don't have a record of you" when actually the database timed out, you've insulted the customer AND lost the transaction. Distinguish the two, or apologize twice.</p>

</CalloutBox>

<!--
This isn't just a Scenario 3 problem. Customer support — Scenario 1 — hits it too. "Customer not found" and "customer database timed out" are completely different user experiences. If the agent says "we don't have a record of you" when actually the database timed out, you've insulted the customer AND lost the transaction. The customer leaves angry; the ticket closes wrong; the business sees "resolved" in the metrics and can't diagnose the underlying outage.

Distinguish the two, or apologize twice. Once for the outage, once for calling them a non-customer.
-->

---

<script setup>
const antiPatternBad79 = `On timeout: return empty list, log success.

{
  "results": []
}

-> Indistinguishable from a real miss.
-> Coordinator can't tell the two apart.`

const antiPatternFix79 = `On timeout: return structured error.
On no match: return empty + success flag.

{ "status": "empty_result", "success": true }
  vs.
{ "status": "access_failure",
  "success": false, ... }`
</script>

<AntiPatternSlide
  title="Don't return [] for both"
  lang="text"
  :badExample="antiPatternBad79"
  whyItFails="The schema allows both cases to return the same shape. That's an interface bug, not a convention you can follow carefully."
  :fixExample="antiPatternFix79"
/>

<!--
The anti-pattern: on timeout, return an empty list and log success. That's the silent-suppression shape we warned about in 7.8 — same failure mode, zoomed in. The better pattern: on timeout, return a structured error; on no match, return an empty result with a success flag. Two distinct shapes. Two distinct statuses. No ambiguity at the coordinator layer.

If your subagent interface allows both cases to return `{"results": []}` with no status field, that's a bug in the interface, not a convention you can follow carefully. Fix the interface.
-->

---

<CalloutBox variant="tip" title="On the exam">

Sample questions test this collapse. The right answer always distinguishes the two.

<p>Distractors: "treat empty as empty" or "retry all empty results." Both collapse -- one wastes tokens, the other silently loses data. Almost-right again.</p>

</CalloutBox>

<!--
On the exam, the shape is: the question describes a subagent returning empty results under two different conditions — timeout and genuine no-match — and asks how to handle them. The right answer always distinguishes the two in the response. The distractor is "treat empty as empty" or "retry all empty results" — both collapse the two cases and lose the distinction. Almost-right again. Retrying a valid empty result is a waste of tokens; not retrying an access failure is a silent loss.
-->

---

<Frame bg="var(--mint-100)">
  <Eyebrow>Closing</Eyebrow>
  <SlideTitle>Next up: 7.10 -- Coverage Annotations in Synthesis Output.</SlideTitle>

  <div class="closing-body">
    <p>The generic name for today's distinction: <em>"distinguishing failure from null."</em> It shows up everywhere an empty response can happen. Ask: does the schema let me tell failure from null? If not, you're one flaky connection away from a silent data-loss bug.</p>
    <p>Now we zoom back out from the subagent layer to the coordinator layer -- how synthesis surfaces what DIDN'T get covered.</p>
  </div>
</Frame>

<style scoped>
.closing-body { margin-top: 56px; font-family: var(--font-body); font-size: 28px; line-height: 1.5; color: var(--forest-500); max-width: 1400px; }
.closing-body p + p { margin-top: 20px; }
.closing-body p em { color: var(--forest-800); font-style: italic; }
</style>

<!--
One more framing note. This distinction has a generic name worth knowing — "distinguishing failure from null." It shows up across every subagent interface, every tool response, every database query the agent touches. Wherever an empty response can happen, ask: does the schema let me tell failure from null? If not, you're one flaky network connection away from a silent data-loss bug. Fix it in the interface before you need it in production.

Next up: 7.10, coverage annotations in synthesis output. We're zooming back out from the subagent layer to the coordinator layer — and asking how the coordinator surfaces what DIDN'T get covered in its final synthesis. Same honesty principle, one layer up. See you there.
-->

---

<!-- LECTURE 7.10 — Coverage Annotations in Synthesis -->

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
    "music": "subagent returned partial -- archive source rate-limited",
    "writing": "subagent timed out; no results retrieved",
    "film": "no subagent dispatched -- coordinator decomposition gap"
  }
}`
</script>

<CodeBlockSlide
  title="Synthesis output with coverage"
  lang="json"
  :code="coverageCode"
  annotation="Three buckets -- covered, partial, gaps. Every requested topic lands in exactly one."
/>

<!--
The synthesis output gets an extra field. Alongside the findings themselves, there's a coverage object with three lists. Covered — the topics where subagents returned solid results. Gaps — the topics where nothing came back, or the subagent hit access failures. Partial — the topics where some evidence exists but coverage was incomplete.

Three buckets. Every topic the original query implied should land in exactly one of them. No silent drops. The schema shape forces the coordinator to account for everything.
-->

---

<CalloutBox variant="tip" title="Sample Q7 echo -- visual-arts-only report">

Research pipeline produces a report on "recent cultural trends." Report covers visual arts in detail. Silently drops music, writing, film.

<p>Coverage annotations would have flagged the missing topics before the report shipped. Synthesis would have read: <code>"covered: visual_arts; gaps: music, writing, film."</code> Totally different user experience.</p>

</CalloutBox>

<!--
Sample Question 7 is the canonical example. The scenario: a multi-agent research system produces a report on recent cultural trends. The report covers visual arts in detail. It doesn't cover music, writing, or film — even though the original query implied all four. The subagents themselves ran fine — no errors to propagate. The coordinator's synthesis just... lost the other three topics somewhere in the pipeline.

Coverage annotations would have flagged the missing topics before the report shipped. The synthesis would have read: "covered — visual arts; gaps — music, writing, film." That's a totally different user experience. The user knows to ask for the gaps or to accept the partial report. The report itself is honest about what it is.
-->

---

<CalloutBox variant="tip" title="Subagents self-report; coordinator aggregates">

Each subagent self-reports what it covered and what it couldn't. Coordinator aggregates those reports.

<p>Example: a music subagent returns <code>"covered: jazz, classical; partial: electronic, experimental; gaps: country."</code> Coordinator rolls that into the top-level coverage object as-is -- no summarization, no inference. <strong>Trust the source.</strong></p>

</CalloutBox>

<!--
Each subagent self-reports what it covered and what it couldn't. The coordinator aggregates those self-reports into the coverage object. This is not the coordinator guessing — it's the subagents telling the coordinator, and the coordinator propagating. That's what makes the annotations trustworthy: they come from the layer that did the work.

A music subagent returns "covered: jazz, classical; partial: electronic, experimental; gaps: country." The coordinator takes that input as-is and rolls it into the top-level coverage object. No summarization, no inference. Trust the source.
-->

---

<CalloutBox variant="warn" title="Don't lose it at synthesis">

Synthesis MUST preserve coverage info. Collapsing findings into one prose paragraph erases gaps -- the prose reads as complete; the annotations evaporate.

<p>Treat coverage as a <strong>first-class field</strong> in the output schema, not a footnote or preface. Same principle as 7.1 (structural discipline preserves what prose compresses away) and 7.16 (claim-source mappings).</p>

</CalloutBox>

<!--
Here's the discipline. Synthesis MUST preserve coverage info. If you collapse all the subagent findings into a single prose paragraph, the coverage object gets lost — the prose reads as complete, and the annotations evaporate. The fix: treat coverage as a first-class field in the output schema, not a footnote or a preface. Propagate it alongside the findings, all the way to the user-facing output.

This is the same principle we covered in 7.1 with lost-in-the-middle — structural discipline preserves information that prose compresses away. It's also directly related to 7.16's claim-source mappings. The whole multi-agent synthesis pipeline needs structural fields to survive, because prose is where information goes to die.
-->

---

<script setup>
const antiPatternBad710 = `Report reads as complete:
  "Our research into recent
   cultural trends shows..."

-> Gaps invisible.
-> Downstream reader treats everything as covered.
-> Visual-arts-only ships as 'cultural trends.'`

const antiPatternFix710 = `Report explicitly lists what wasn't covered:
  "We covered 3 of the 4 requested
   domains. Music was unavailable due
   to a source outage."

-> Honest. Strictly better deliverable.`
</script>

<AntiPatternSlide
  title="Don't produce confident-looking reports with gaps"
  lang="text"
  :badExample="antiPatternBad710"
  whyItFails="Clean prose hides the gaps. There's no signal to the reader that music, writing, and film never made it in."
  :fixExample="antiPatternFix710"
/>

<!--
The anti-pattern: produce a confident-looking report where gaps are invisible. The report reads as complete. The downstream reader has no way to know what wasn't covered, so they treat everything as covered. That's how visual-arts-only reports get shipped as "recent cultural trends."

The better pattern: explicitly list what wasn't covered and why. Honesty in the schema beats confidence in the prose. A report that says "we covered three of the four domains requested; music was unavailable due to a source outage" is a strictly better deliverable than one that silently covers three and lets the reader guess.
-->

---

<CalloutBox variant="tip" title="On the exam -- two angles, both correct">

Sample Q7 can be answered from two angles:

<p><strong>Domain 1 / Task 1.2 angle:</strong> "coordinator didn't decompose the query properly."</p>
<p><strong>Domain 5 / Task 5.3 angle:</strong> "synthesis didn't include coverage annotations."</p>

Know both. The correct answer depends on which failure the question is describing -- decomposition up front, or annotation at the end.

</CalloutBox>

<!--
On the exam, the Sample Question 7 pattern can be answered from two angles, both correct. One: "coordinator didn't decompose the query properly" — that's a Domain 1 / Task 1.2 angle. Two: "synthesis didn't include coverage annotations" — that's the Domain 5 / Task 5.3 angle. Know both. The exam may frame the fix from either side, and the correct answer depends on which failure the question is describing — decomposition up front, or annotation at the end.
-->

---

<Frame bg="var(--mint-100)">
  <Eyebrow>Closing</Eyebrow>
  <SlideTitle>Next up: 7.11 -- Context Degradation in Long Sessions.</SlideTitle>

  <div class="closing-body">
    <p>We've been focused on multi-agent failures. Now we shift to a very different failure mode -- what happens when a SINGLE long session starts losing track of its own early exploration.</p>
  </div>
</Frame>

<style scoped>
.closing-body { margin-top: 56px; font-family: var(--font-body); font-size: 30px; line-height: 1.5; color: var(--forest-500); max-width: 1400px; }
</style>

<!--
Next up: 7.11, context degradation in long sessions. We've been focused on multi-agent failures. Now we shift to a very different failure mode — what happens when a SINGLE long session starts losing track of its own early exploration. See you there.
-->

---

<!-- LECTURE 7.11 — Context Degradation in Long Sessions -->

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div class="di-cover">
    <div class="di-cover__eyebrow">Domain 5 · Lecture 7.11</div>
    <div class="di-cover__title">Context Degradation<br/>in Long Sessions</div>
    <div class="di-cover__subtitle">When sessions start referencing "typical patterns"</div>
  </div>
</Frame>

<style scoped>
.di-cover { flex: 1; display: flex; flex-direction: column; justify-content: center; gap: 32px; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 28px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); }
.di-cover__title { font-family: var(--font-display); font-size: 112px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); max-width: 1500px; }
.di-cover__subtitle { font-family: var(--font-display); font-size: 40px; color: var(--mint-200); font-style: italic; }
</style>

<!--
Lecture 7.11. Context degradation in long sessions. This is a Scenario 2 and Scenario 4 problem — the code-generation and developer-productivity scenarios — where a single long session starts producing inconsistent answers because it's forgotten its own early exploration.

If 7.2's progressive summarization is what happens to customer-support transactions across turns, this lecture is what happens to code-exploration findings across turns. Different symptom, same underlying cause: specifics dilute as conversation grows.
-->

---

<BigQuote
  lead="The exam's keyword"
  quote="Models start giving inconsistent answers and referencing <em>'typical patterns'</em> rather than specific classes discovered earlier."
  attribution="When 'typically' shows up in answers -> you've lost specifics to degradation"
/>

<!--
Here's the quote I want you to memorize as the exam's keyword. "Models start giving inconsistent answers and referencing 'typical patterns' rather than specific classes discovered earlier." That's the tell. When the model drops from "the OrderProcessor class at /src/services/orders.py line forty-two" back to "typically, in code like this, there's usually a service class..." — you've lost specifics to degradation.

The agent isn't lying. It isn't getting worse at the task. It's just operating on a diluted version of its own earlier findings, and generic knowledge is filling the space where specifics used to live.
-->

---

<ConceptHero
  leadLine="Specifics dilute"
  concept="Generic fills the gap."
  supportLine="Early facts get buried under intervening conversation. The model falls back to training data -- 'typical,' 'usually,' 'in code like this.'"
/>

<!--
Specifics dilute. In an early turn, the model read the actual code, extracted the actual class names, and referenced them. Ten turns later, those specifics are buried under intervening conversation. The model's attention — limited by the same lost-in-the-middle dynamic we covered in 7.1 — can't reliably surface the early findings. So it falls back to generic knowledge. "Typically." "Usually." "In code like this."

Generic answers are the degraded state. Specifics are what got lost. Once you recognize the pattern, you stop wondering why the session suddenly got dumber — it didn't; it just lost its own notes.
-->

---

<script setup>
const detectionBullets = [
  { label: '"Typically" appears in answers', detail: '"Usually," "in code like this" -- generic filler replacing specifics.' },
  { label: 'Earlier specifics no longer quoted', detail: 'Class names, file paths, line numbers absent from later turns.' },
  { label: 'Answers feel generic', detail: 'Pattern-matching from training data, not from what was read earlier.' },
]
</script>

<BulletReveal
  title="How to spot it"
  :bullets="detectionBullets"
/>

<!--
How do you spot it in practice? Three signs. One: the word "typically" starts showing up in answers. Two: earlier specifics stop getting quoted — the class names, file paths, and line numbers the model knew in turn three are absent in turn thirteen. Three: answers feel generic, pattern-matching, text-book — like the model is reasoning from its training data rather than from the code it read earlier in the session.

That triangle is degradation. Once you see it, you stop trusting the session and do one of the fixes below.
-->

---

<script setup>
const countermeasureRows = [
  { label: 'Scratchpads', cells: [{ text: '7.12', highlight: 'good' }] },
  { label: 'State manifests (crash recovery)', cells: [{ text: '7.13', highlight: 'good' }] },
  { label: 'Subagent delegation + /compact', cells: [{ text: '5.11 + 5.15', highlight: 'good' }] },
]
</script>

<ComparisonTable
  title="Three countermeasures"
  :columns="['Covered in']"
  :rows="countermeasureRows"
/>

<!--
Three countermeasures, all covered elsewhere in the course. Scratchpad files — next lecture, 7.12. State manifests for crash recovery — 7.13, which also helps with long-session state. And subagent delegation with /compact — we covered those in Section 5, lectures 5.11 and 5.15. Three tools. Same goal: keep the specifics accessible even as the raw conversation grows too long for the model to track.

The mental move is: you don't fight degradation by telling the model to "remember harder." You externalize the memory into mechanisms where forgetting isn't possible — files, state manifests, fresh subagent contexts.
-->

---

<CalloutBox variant="tip" title="Fresh beats resumed">

When prior tool results are stale, a fresh session with an injected summary often beats resume. Callback to Domain 1 Task 1.7.

<p>The math: degraded context costs you every turn; fresh context with a clean summary costs one turn of injection, then runs clean. The conversation is disposable once a scratchpad or state manifest exists -- the work is already captured there.</p>

</CalloutBox>

<!--
There's a fourth option — restart the session. When prior tool results are stale, a fresh session with an injected summary often beats trying to resume. That's a callback to Domain 1 Task 1.7. The math: degraded context costs you every turn; fresh context with a clean summary costs you one turn of injection, then runs clean. For exploration-heavy sessions, fresh beats resumed more often than you'd think.

The instinct is to preserve the session "because we've done so much work." But the work is already captured in the scratchpad, the state manifest, or the compacted summary. The conversation itself is disposable once those exist.
-->

---

<CalloutBox variant="tip" title="On the exam">

"Model referencing typical patterns" -- that phrase is the exam's flag for context degradation.

<p>Right answer: <strong>scratchpads + fresh sessions</strong> (structural fixes). Distractor: "switch to a larger context window." Larger windows give you more middle to lose.</p>

<p>Same trap as 7.1 and 7.2 -- "use a bigger model." Different symptom, same wrong answer. Same correct-answer family: externalize state.</p>

</CalloutBox>

<!--
On the exam, the keyword is "model referencing typical patterns." That phrase is the exam's flag for context degradation. The right answer is scratchpads plus fresh sessions — structural fixes. The distractor, as usual, is "switch to a larger context window." Larger windows give you more middle to lose. The fix is discipline, not capacity.

Same pattern as 7.1 and 7.2 — the "use a bigger model" distractor. Different symptom, same wrong answer. Same correct answer family: externalize state.
-->

---

<BigQuote
  lead="Continuity"
  quote="Domain 2 taught you <em>WHAT</em> to do. Domain 5 teaches you <em>WHY your context dies</em> if you skip the discipline."
  attribution="Either framing -> same answer: scratchpads, fresh sessions, externalized state"
/>

<!--
This is where the code-exploration patterns from Section 4 matter most — Domain 2 taught you WHAT to do with tools; Domain 5 teaches you WHY your context dies if you skip the discipline. The exam will sometimes frame this as a Domain 2 question and sometimes as a Domain 5 question — the answer is the same pattern either way. Scratchpads. Fresh sessions. Externalized state.
-->

---

<Frame bg="var(--mint-100)">
  <Eyebrow>Closing</Eyebrow>
  <SlideTitle>Next up: 7.12 -- Scratchpad Files for Cross-Context Persistence.</SlideTitle>

  <div class="closing-body">
    <p>We just previewed scratchpads as the main fix. Now we build them out in detail, and learn the pattern name the exam uses directly.</p>
  </div>
</Frame>

<style scoped>
.closing-body { margin-top: 56px; font-family: var(--font-body); font-size: 30px; line-height: 1.5; color: var(--forest-500); max-width: 1400px; }
</style>

<!--
Next up: 7.12, scratchpad files for cross-context persistence. We just previewed scratchpads as the main fix. Now we'll build them out in detail, and learn the pattern name the exam uses directly. See you there.
-->

---

<!-- LECTURE 7.12 — Scratchpad Files -->

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div class="di-cover">
    <div class="di-cover__eyebrow">Domain 5 · Lecture 7.12</div>
    <div class="di-cover__title">Scratchpad Files</div>
    <div class="di-cover__subtitle">Cross-context persistence -- the pattern name the exam uses</div>
  </div>
</Frame>

<style scoped>
.di-cover { flex: 1; display: flex; flex-direction: column; justify-content: center; gap: 32px; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 28px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); }
.di-cover__title { font-family: var(--font-display); font-size: 132px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); max-width: 1500px; }
.di-cover__subtitle { font-family: var(--font-display); font-size: 40px; color: var(--mint-200); font-style: italic; }
</style>

<!--
Lecture 7.12. Scratchpad files for cross-context persistence. We previewed this in 7.11 as the main fix for context degradation. Now let's build it out — and memorize the pattern name, because the exam uses it directly.

"Scratchpad file" is one of those exam phrases where the words themselves matter. If you see "scratchpad" in an answer choice for a long-session-memory question, that's almost always the correct answer.
-->

---

<ConceptHero
  leadLine="Externalize key findings"
  concept="Files don't forget."
  supportLine="Write important facts to a file. Reference it explicitly. It survives summarization and session restarts."
/>

<!--
Externalize key findings. Write important facts to a file. Reference that file explicitly in future turns. The file survives summarization, survives session restarts, and survives the lost-in-the-middle dilution we covered in 7.1. Conversation memory is fragile. Filesystem memory is durable. Use the durable one for anything you need to keep.

This is the same principle as the case-facts block from 7.4, but for a different domain. Case-facts is for customer-support transactions; scratchpads are for exploration findings. Same externalization move. Different surface.
-->

---

<script setup>
const scratchpadCode = `# scratchpad.md

## Entry points
- \`src/services/orders.py\` -- OrderProcessor class, line 42
- \`src/api/checkout.ts\` -- POST /v2/checkout handler

## Traced flows
- Checkout -> OrderProcessor.submit() -> OrderRepo.persist()
- Cancellation path bypasses OrderProcessor (see bug below)

## Known gotchas
- OrderRepo.persist() retries silently on 500s -- may double-write
- TaxCalculator caches per-request; stale during replay tests

## Open questions
- Does the cancellation path trigger inventory release?
- What happens when currency code is null?

## Current hypotheses
- Bug #431 likely in OrderRepo.persist retry logic (needs verification)`
</script>

<CodeBlockSlide
  title="scratchpad.md -- example structure"
  lang="markdown"
  :code="scratchpadCode"
  annotation="Free-form Markdown, structured enough to skim in one pass."
/>

<!--
A scratchpad file — typically scratchpad.md in the project root — is free-form Markdown. But it's not prose. Useful sections: discovered entry points with file paths and line numbers. Traced flows from handler to service to repository. Known gotchas — the "this looks like it should work but doesn't because X" notes. Open questions the agent is still resolving. Current hypotheses about unclear behavior.

Each section gets a header, each fact gets a bullet. Structured enough to read fast, free-form enough to grow naturally as exploration continues. The goal is a file the agent can skim in one pass and extract the key state from.
-->

---

<script setup>
const whenBullets = [
  { label: 'Multi-phase exploration', detail: 'Discovery spans several steps; each depends on prior findings.' },
  { label: 'Context degradation risk', detail: 'Session long enough that early findings will dilute.' },
  { label: 'Session may restart', detail: 'Crash, or /compact, or intentional fresh start.' },
  { label: 'Multiple agents share findings', detail: 'One explores, another implements, a third reviews.' },
]
</script>

<BulletReveal
  title="Use when..."
  :bullets="whenBullets"
/>

<!--
Use scratchpads when one or more of these holds. The work is multi-phase exploration — you're discovering something over several steps and the steps depend on each other. Context degradation risk is real — the session is long enough that you'll forget your own earlier findings. The session may restart — either because of a crash or a /compact operation that drops the specifics. Multiple agents need to share the findings — one explores, another implements, a third reviews.

Any one of those conditions is enough to justify a scratchpad. Two or three makes the scratchpad non-optional.
-->

---

<CalloutBox variant="tip" title="Explicit reference -- the non-obvious part">

Claude does NOT implicitly remember a file just because you wrote to it. Reference it explicitly.

<p>Prompt pattern: <code>"Read scratchpad.md for prior findings before proceeding."</code> Literally that sentence, or something close.</p>

<p>Externalizing memory doesn't help if you forget to retrieve it. Pair every scratchpad with a system-prompt instruction or workflow step that always references it -- never "maybe the model will check."</p>

</CalloutBox>

<!--
Here's the non-obvious part. Claude does NOT implicitly remember a file just because you wrote to it. You have to reference it explicitly. The prompt pattern: "Read scratchpad.md for prior findings before proceeding." Literally that sentence, or something close to it.

If you don't tell the model to read the file, it doesn't read the file. Externalizing memory doesn't help if you forget to retrieve it. This is why scratchpad files live in conjunction with a system-prompt instruction or a workflow step that always references them — never "maybe the model will check."
-->

---

<script setup>
const scopeRows = [
  { label: 'Case-facts block', cells: [{ text: 'Customer-session transactional data', highlight: 'neutral' }] },
  { label: 'Scratchpad', cells: [{ text: 'Exploration findings / notes', highlight: 'neutral' }] },
]
</script>

<ComparisonTable
  title="Scratchpad vs case-facts"
  :columns="['Scope']"
  :rows="scopeRows"
/>

<!--
Scratchpad versus case-facts block — two related patterns, different scopes. The case-facts block from 7.4 is for transactional data in a customer-support session — amounts, dates, order IDs. Narrow scope, strict schema, customer-facing. The scratchpad is for exploration findings and notes — code discoveries, research trails, working hypotheses. Broader scope, free-form Markdown, developer-facing.

Same externalization principle; two different expressions of it. The exam may label either pattern by name — recognize both.
-->

---

<script setup>
const antiPatternBad712 = `Explore for 30 minutes. Hope the model
remembers the class names it discovered
in turn four.

By turn 25 -> "typical patterns" answers.
-> Specifics gone. Degradation in full effect.`

const antiPatternFix712 = `Write findings to the scratchpad as you
discover them. Reference it explicitly
before any synthesis step.

Trust the FILE -- not the conversation --
as the source of truth for what you've
learned.`
</script>

<AntiPatternSlide
  title="Don't trust conversation memory"
  lang="text"
  :badExample="antiPatternBad712"
  whyItFails="Conversation memory is lossy in exactly the ways that matter. The specifics that drove early turns dilute turn by turn."
  :fixExample="antiPatternFix712"
/>

<!--
The anti-pattern: explore for thirty minutes, hope the model remembers the class names it discovered in turn four. It won't. By turn twenty-five, the specifics are gone and the model is back to "typical patterns" answers — the degradation tell from 7.11.

The better pattern: write findings to the scratchpad as you discover them, reference the scratchpad explicitly before any synthesis step, and trust the file — not the conversation — as the source of truth for what you've learned. Same discipline that separates teams that ship production agents from teams that demo agents that fall apart in week two.
-->

---

<CalloutBox variant="tip" title="On the exam">

"Persist findings across context boundaries" -> scratchpad files.

<p>Memorize the pattern name -- <strong>"scratchpad files"</strong> -- because the exam uses it directly. The distractor is often a fuzzy "use memory" or "reference prior turns" that doesn't commit to a durable external mechanism.</p>

<p>For Scenario 2 or Scenario 4 long sessions with lost specifics -> scratchpad is the answer.</p>

</CalloutBox>

<!--
On the exam, the shape is: "Persist findings across context boundaries." The right answer is scratchpad files. Memorize the pattern name — "scratchpad files" — because the exam uses it directly, and the distractor is often a fuzzy "use memory" or "reference prior turns" that doesn't commit to a durable external mechanism.

If the question is about Scenario 2 or Scenario 4 long sessions with lost specifics, the scratchpad pattern is the answer.
-->

---

<Frame bg="var(--mint-100)">
  <Eyebrow>Closing</Eyebrow>
  <SlideTitle>Next up: 7.13 -- Crash Recovery with Structured Agent State Manifests.</SlideTitle>

  <div class="closing-body">
    <p>Scratchpads persist findings <em>inside</em> a single session. State manifests persist agent state <em>across</em> a whole pipeline -- and let you recover from crashes without restarting everything from scratch.</p>
  </div>
</Frame>

<style scoped>
.closing-body { margin-top: 56px; font-family: var(--font-body); font-size: 30px; line-height: 1.5; color: var(--forest-500); max-width: 1400px; }
.closing-body p em { color: var(--forest-800); font-style: italic; }
</style>

<!--
Next up: 7.13, crash recovery with structured agent state manifests. Scratchpads persist findings inside a single session. State manifests persist agent state across a whole pipeline — and let you recover from crashes without restarting everything from scratch. See you there.
-->

---

<!-- LECTURE 7.13 — Crash Recovery with State Manifests -->

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div class="di-cover">
    <div class="di-cover__eyebrow">Domain 5 · Lecture 7.13</div>
    <div class="di-cover__title">Crash Recovery with<br/>State Manifests</div>
    <div class="di-cover__subtitle">Filesystem discipline, not magic</div>
  </div>
</Frame>

<style scoped>
.di-cover { flex: 1; display: flex; flex-direction: column; justify-content: center; gap: 32px; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 28px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); }
.di-cover__title { font-family: var(--font-display); font-size: 108px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); max-width: 1500px; }
.di-cover__subtitle { font-family: var(--font-display); font-size: 40px; color: var(--mint-200); font-style: italic; }
</style>

<!--
Lecture 7.13. Crash recovery with structured agent state manifests. This is Scenario 3 territory — multi-agent pipelines — and it's one of those lectures where the pattern sounds like plumbing, but the exam tests it directly. If you've ever worked on production batch jobs, the shape will feel familiar. If you haven't, memorize it from this lecture.
-->

---

<BigQuote
  lead="The problem"
  quote="Multi-agent pipeline crashes at agent 4 of 6. <em>Do you restart all six? Or resume?</em>"
  attribution="Restart wastes work. Resume requires knowing what finished and where outputs live."
/>

<!--
Here's the scenario. A multi-agent pipeline runs six subagents — document retrieval, extraction, analysis, cross-referencing, synthesis, quality review. Agent four crashes on an out-of-memory error. Do you restart all six? Or do you resume from agent four?

If you restart all six, you've thrown away the work of agents one through three — potentially hours of web search, document download, and extraction that you now have to pay for again. If you resume from agent four, you need to know what one through three produced, because agent four's input depends on them. The question is how the coordinator knows what finished and where the outputs live.
-->

---

<ConceptHero
  leadLine="Each agent exports state"
  concept="Every success leaves a trace."
  supportLine="State goes to a known location on completion. Coordinator reads the manifest on resume. Only unfinished agents re-run."
/>

<!--
Each agent exports state. When an agent completes, it writes its output plus a small metadata manifest to a known location — typically a shared filesystem or object store. The coordinator, on resume, reads the manifest first. It sees which agents finished, where their outputs live, and which agents haven't run yet. It pulls the completed outputs into the input of the next agent, and it only re-runs the unfinished ones.

Crash recovery isn't magic. It's filesystem discipline. Every successful agent leaves a durable trace. The coordinator uses those traces as its source of truth on resume.
-->

---

<script setup>
const manifestCode = `{
  "agents": [
    {
      "agent_id": "doc-retrieval",
      "completion_status": "completed",
      "output_location": "s3://pipeline/run-42/doc-retrieval.json",
      "timestamp": "2026-04-12T14:22:03Z"
    },
    {
      "agent_id": "extraction",
      "completion_status": "completed",
      "output_location": "s3://pipeline/run-42/extraction.json",
      "timestamp": "2026-04-12T14:28:10Z"
    },
    {
      "agent_id": "analysis",
      "completion_status": "completed",
      "output_location": "s3://pipeline/run-42/analysis.json",
      "timestamp": "2026-04-12T14:34:22Z"
    },
    {
      "agent_id": "cross-referencing",
      "completion_status": "failed",
      "failure_type": "out_of_memory",
      "timestamp": "2026-04-12T14:36:14Z"
    },
    {
      "agent_id": "synthesis",
      "completion_status": "not_started"
    },
    {
      "agent_id": "quality-review",
      "completion_status": "not_started"
    }
  ]
}`
</script>

<CodeBlockSlide
  title="Agent state manifest"
  lang="json"
  :code="manifestCode"
  annotation="Four fields per agent: id, status, location, timestamp. Written atomically after output persists."
/>

<!--
The manifest is a small JSON structure per agent. Agent_id — which subagent this entry is for. Completion_status — "completed," "failed," "running," "not_started." Output_location — the path or URL where the agent's output lives. Timestamp — when the manifest was written. Optionally: failure details if the status is "failed," so the coordinator knows whether to retry or escalate.

Four fields. Known location. Written atomically on completion — meaning, the manifest only flips to "completed" after the output is fully persisted, so there's no partial-state ambiguity. That's the contract.
-->

---

<script setup>
const recoverySteps = [
  { label: 'Coordinator loads manifest', sublabel: 'Source of truth on resume' },
  { label: 'Reads per-agent status', sublabel: 'completed / failed / not_started' },
  { label: 'Skips completed', sublabel: 'Pulls outputs from output_location' },
  { label: 'Reruns incomplete agents', sublabel: 'Starting from first failure' },
]
</script>

<FlowDiagram
  title="Resume after crash"
  :steps="recoverySteps"
/>

<!--
The resume flow. Coordinator starts. Coordinator loads the manifest. Coordinator reads per-agent status. For each agent marked "completed," coordinator pulls the output from the output_location and injects it into downstream inputs. For each agent not completed, coordinator re-runs — starting from the first incomplete agent and continuing through the pipeline.

Four steps. Deterministic. Testable. You can resume the same crashed pipeline ten times in a row and get the same outcome — either it finishes or it fails at the same step, but it never silently skips or silently re-does.
-->

---

<CalloutBox variant="tip" title="Discipline required -- not free, worth it">

Each agent must write state. Coordinator must know where. Overhead is real -- but crash cost is worse.

<p>In a six-agent chain with even a small per-agent failure rate, the probability of a clean full run drops quickly. Manifests amortize the discipline cost across every successful resume.</p>

</CalloutBox>

<!--
This isn't free. Each agent has to write state on completion — that's disk I/O, serialization, extra error handling. The coordinator has to know where to look and how to parse. The overhead is real.

But crash cost is worse. A pipeline that can't resume loses everything on every failure, and in a six-agent chain with even a small per-agent failure rate, the probability of a full clean run drops quickly. You end up re-doing the early work constantly. Manifests amortize the discipline cost across every successful resume — you pay the overhead once per run and save the re-work cost on every failure.
-->

---

<script setup>
const useWhenBullets = [
  { label: 'Long-running multi-agent pipelines', detail: 'Tens of minutes, many handoffs.' },
  { label: 'Expensive subagent work', detail: 'Web searches, doc analysis, large retrieval -- re-run cost is meaningful.' },
  { label: 'External failure modes', detail: 'Network flakes, rate limits, OOM kills, upstream API outages.' },
]
</script>

<BulletReveal
  title="Use for..."
  :bullets="useWhenBullets"
/>

<!--
Use state manifests for long-running multi-agent pipelines. Use them when subagent work is expensive — web searches, document analysis, large retrieval jobs where the cost of re-running is meaningful. Use them when external failure modes exist — network flakes, rate limits, out-of-memory kills, upstream API outages.

If your pipeline is two short subagents running in-process and finishing in thirty seconds, skip it — the overhead isn't worth it. If it's six agents touching external systems over tens of minutes, build it in from day one. The break-even point for adding manifests is lower than most teams expect.
-->

---

<script setup>
const antiPatternBad713 = `Coordinator holds all subagent state
in conversation memory.

-> One crash and everything's gone.
-> Coordinator's plan lost.
-> Subagent outputs lost.
-> Starting from scratch on every failure.`

const antiPatternFix713 = `Each agent persists to filesystem /
object store. Coordinator reconstructs
from manifest on resume.

-> Durable beats in-memory whenever
  the cost of loss is non-trivial.
-> Same externalization principle as
  case-facts (7.4), scratchpads (7.12).`
</script>

<AntiPatternSlide
  title="Don't rely on in-memory state"
  lang="text"
  :badExample="antiPatternBad713"
  whyItFails="Conversation memory can't survive a process crash. There's no durable trace to reconstruct from."
  :fixExample="antiPatternFix713"
/>

<!--
The anti-pattern: coordinator holds all subagent state in conversation memory. One crash and everything's gone — both the coordinator's plan and the subagents' outputs. You're starting from scratch on every failure.

The better pattern: each agent persists to the filesystem, coordinator reconstructs from the manifest on resume. Durable beats in-memory whenever the cost of loss is non-trivial. This is the same externalization principle we've been tracking since 7.4 — case-facts blocks, scratchpads, state manifests. Different surfaces, one discipline.
-->

---

<CalloutBox variant="tip" title="On the exam">

"Recover multi-agent pipeline after crash" -> state manifests (or equivalent durable-state language).

<p>Distractors: "restart the pipeline from scratch" or "increase coordinator context window." Both ignore the point. Restart is wasteful; larger windows don't solve the crash problem at all.</p>

<p>Ingredients to recognize: multi-agent, long-running, crash recovery -> manifest answer follows.</p>

</CalloutBox>

<!--
On the exam, the shape is: "Recover multi-agent pipeline after crash." The right answer is state manifests — or equivalent durable-state language. The distractor is "restart the pipeline from scratch" or "increase coordinator context window." Both ignore the point. Restart is wasteful; larger windows don't solve the crash problem at all.

Recognize the question by its ingredients — multi-agent, long-running, crash recovery — and the manifest answer follows.
-->

---

<Frame bg="var(--mint-100)">
  <Eyebrow>Closing</Eyebrow>
  <SlideTitle>Next up: 7.14 -- Human Review Workflows and Confidence Calibration.</SlideTitle>

  <div class="closing-body">
    <p><strong>Heads-up:</strong> this one has a nuance that directly contradicts something you learned in 7.5. The two lectures disagree intentionally -- and the exam tests whether you understand WHY. I'll call out the reconciliation explicitly when we get there.</p>
  </div>
</Frame>

<style scoped>
.closing-body { margin-top: 56px; font-family: var(--font-body); font-size: 30px; line-height: 1.5; color: var(--forest-500); max-width: 1400px; }
.closing-body p strong { color: var(--clay-600); }
</style>

<!--
Next up: 7.14, human review workflows and confidence calibration. Heads-up: this one has a nuance that directly contradicts something you learned in 7.5. The two lectures disagree intentionally — and the exam tests whether you understand WHY. I'll call out the reconciliation explicitly when we get there. See you there.
-->

---

<!-- LECTURE 7.14 — Human Review & Confidence Calibration -->

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div class="di-cover">
    <div class="di-cover__eyebrow">Domain 5 · Lecture 7.14</div>
    <div class="di-cover__title">Human Review &amp;<br/>Confidence Calibration</div>
    <div class="di-cover__subtitle">Scenario 6 -- with a direct 7.5 reconciliation on slide 6</div>
  </div>
</Frame>

<style scoped>
.di-cover { flex: 1; display: flex; flex-direction: column; justify-content: center; gap: 32px; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 28px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); }
.di-cover__title { font-family: var(--font-display); font-size: 108px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); max-width: 1500px; }
.di-cover__subtitle { font-family: var(--font-display); font-size: 40px; color: var(--mint-200); font-style: italic; }
</style>

<!--
Lecture 7.14. Human review workflows and confidence calibration. This is a Scenario 6 lecture — structured data extraction — and I flagged at the end of 7.13 that it contains a nuance that directly contradicts something you learned in 7.5. That's intentional. The exam tests whether you understand the difference. Pay attention to the reconciliation — slide 6 is the load-bearing slide of this lecture.
-->

---

<BigQuote
  lead="The aggregate accuracy trap"
  quote="<em>97% overall accuracy</em> can mask <em>40% accuracy</em> on one document type."
  attribution="A good-looking average hiding a disaster bucket"
/>

<!--
Here's the hook. Ninety-seven percent overall accuracy can mask forty percent accuracy on one document type. That's the trap. A pipeline that reads ninety-seven percent overall looks like it's done — ready to automate, ready to reduce human review, ready to ship. But if that ninety-seven is an average across five document types where four are at ninety-nine and one is at forty, the forty-percent bucket is a disaster hiding inside a good-looking average.

Aggregate metrics hide per-segment failures. Full stop. If you reduce human review on the basis of aggregate accuracy alone, the forty-percent bucket starts shipping bad extractions downstream — and nobody knows until the damage shows up in production data.
-->

---

<ConceptHero
  leadLine="Measure by segment"
  concept="Stratify. Always."
  supportLine="Accuracy per document type, per field, per source. Aggregate hides the worst segments. Stratified surfaces them."
/>

<!--
The fix is to measure by segment. Accuracy per document type. Accuracy per field. Accuracy per source. You don't get one number — you get a matrix. And the matrix is what tells you whether the pipeline is safe to automate.

Aggregate hides the worst segments. Stratified surfaces them. Always measure by segment when the segments behave differently. We'll cover the sampling mechanics in 7.15.
-->

---

<CalloutBox variant="tip" title="Calibrated, not self-reported">

The model can output a confidence score per field. Useful -- but only if CALIBRATED.

<p>Calibration means: on a labeled validation set, fields with confidence 0.9 really are correct 90% of the time. Fields with confidence 0.5 really are correct 50% of the time. The number maps to reality because you measured it against ground truth.</p>

<p>Self-reported confidence without calibration is just a number the model picked. <strong>Calibrated confidence is data-driven. The routing threshold is calibrated against labeled data, not a gut call.</strong></p>

</CalloutBox>

<!--
The model can output a confidence score per field it extracts. That's useful — but only if the confidence is CALIBRATED, not self-reported. Calibration means: on a labeled validation set, fields with confidence 0.9 really are correct ninety percent of the time. Fields with confidence 0.5 really are correct fifty percent of the time. The number maps to reality because you measured it against ground truth.

Self-reported confidence without calibration is just a number the model picked. Calibrated confidence is data-driven. The routing threshold — "send below X to humans" — is calibrated against labeled data, not a gut call.
-->

---

<script setup>
const routingSteps = [
  { label: 'Model outputs field + confidence', sublabel: 'Confidence per field -- calibrated, not self-reported' },
  { label: 'Below threshold -> human queue', sublabel: 'Threshold set from labeled validation set' },
  { label: 'Above -> auto-accept', sublabel: 'Pipeline keeps flowing' },
  { label: 'Periodic sample above threshold', sublabel: 'Drift detection -- 7.15' },
]
</script>

<FlowDiagram
  title="Review routing"
  :steps="routingSteps"
/>

<!--
The routing flow. Model extracts a field and emits a confidence. If confidence is below threshold, route to a human review queue. If above, auto-accept. Periodically, sample a subset of above-threshold extractions for drift detection — to catch the case where novel error patterns start slipping through high-confidence outputs.

Four-step loop. Model, compare, route, sample. Every piece of the loop has to be present for the system to stay reliable — you can't skip the sampling and trust the routing forever, because input distributions drift over time.
-->

---

<TwoColSlide
  title="Why self-reported confidence is OK here -- but NOT for escalation"
  variant="compare"
  leftLabel="Scenario 6 (correct)"
  rightLabel="Scenario 1 (distractor)"
>
  <template #left>
    <p><strong>Extraction pipeline.</strong> Confidence-based routing is <em>CORRECT</em>.</p>
    <ul>
      <li>You have a labeled validation set.</li>
      <li>You calibrate confidence scores against that ground truth.</li>
      <li>Scores become real probabilities -- "90% confidence" really does mean "90% correct" in aggregate.</li>
    </ul>
    <p><strong>Calibrated confidence works.</strong></p>
  </template>
  <template #right>
    <p><strong>Customer-support escalation.</strong> Self-reported confidence is a <em>DISTRACTOR</em>. That's what 7.5 told you, and it's still true.</p>
    <ul>
      <li>Agent's self-confidence is uncalibrated against case complexity.</li>
      <li>Nobody measured it against labeled outcomes.</li>
      <li>The agent is already wrongly confident on cases it gets wrong.</li>
    </ul>
    <p><strong>Self-report can't detect its own miss.</strong></p>
  </template>
</TwoColSlide>

<!--
Here's the reconciliation with 7.5. This is the single most important callout in Section 7 — do not skim it.

For escalation in Scenario 1 — customer support — self-reported confidence is a DISTRACTOR. Wrong answer. That's what 7.5 told you, and that's still true. Why? Because the agent's self-confidence is uncalibrated against case complexity. Nobody measured it against labeled outcomes. The agent is already wrongly confident on the cases it gets wrong. Self-report can't detect its own miss.

For extraction in Scenario 6 — this lecture — confidence-based routing is CORRECT. Why? Because in an extraction pipeline, you have a labeled validation set. You calibrate the confidence scores against that ground truth. The scores become real probabilities — "ninety percent confidence" really does mean "ninety percent correct" in aggregate.

Same mechanism, two very different contexts. Uncalibrated self-report fails. Calibrated confidence works. The exam tests whether you know the difference — and the wrong answer on Scenario 1 is the right answer on Scenario 6. Hold onto that. If you forget this distinction, you'll learn contradictory rules and miss both questions. If you remember it, you pick up both.

The callback rule: before you pick "confidence-based routing" on any exam question, ask yourself — is there a labeled validation set in this scenario? If yes, it's likely correct. If no, it's likely a distractor. Scenario 1 has no validation set for escalation decisions. Scenario 6 does. Go back and re-read 7.5 after this lecture if you need to. The two lectures are meant to be held together.
-->

---

<CalloutBox variant="tip" title="Stratified sampling preview -- 7.15">

For ongoing accuracy measurement, stratified random sampling of above-threshold extractions catches novel error patterns that random sampling would miss.

<p>That's the drift-detection piece of the routing loop. Preview now; we build it out next lecture.</p>

</CalloutBox>

<!--
We're going to cover this in 7.15. For ongoing accuracy measurement, stratified random sampling of above-threshold extractions catches novel error patterns that random sampling would miss. That's the drift-detection piece of the routing loop. Preview now; build out next lecture.
-->

---

<script setup>
const antiPatternBad714 = `Overall accuracy is 97%. Team reduces
human review without validating
per-segment accuracy.

-> 40%-accuracy bucket starts shipping
  bad extractions downstream.
-> Nobody's sampling stratified.
-> Errors compound. Unnoticed.`

const antiPatternFix714 = `Validate per document type AND per
field BEFORE reducing review.

Automation earns its reduction in
oversight -- it doesn't get it just
because the average looks good.`
</script>

<AntiPatternSlide
  title="Don't reduce human review without segment validation"
  lang="text"
  :badExample="antiPatternBad714"
  whyItFails="Aggregate hides the bad bucket. Reducing oversight on aggregate evidence ships errors into production."
  :fixExample="antiPatternFix714"
/>

<!--
The anti-pattern: overall accuracy is high, so the team reduces human review without validating per-segment accuracy. Then the forty-percent bucket starts shipping bad extractions downstream — and because nobody's sampling stratified, nobody notices until the errors compound.

The better pattern: validate per document type AND per field before reducing review. Automation earns its reduction in oversight. It doesn't get it just because the average looks good.
-->

---

<CalloutBox variant="tip" title="On the exam -- memorize both halves">

"Route low-confidence extractions to human review" -- correct WHEN confidence is calibrated.

<p>Route <strong>AND</strong> calibrate. Memorize both halves.</p>

<p>Scenario 6 + labeled validation set mentioned -> confidence-based routing is right. Scenario 1 escalation without calibration data -> confidence-based routing is wrong. <strong>Context is the whole test.</strong></p>

</CalloutBox>

<!--
On the exam, the shape is: "Route low-confidence extractions to human review." That's correct — WHEN confidence is calibrated. Memorize both halves. Route AND calibrate. If the question is about Scenario 6 and mentions a labeled validation set, confidence-based routing is right. If the question is about Scenario 1 escalation without calibration data, confidence-based routing is wrong. Context is the whole test.
-->

---

<Frame bg="var(--mint-100)">
  <Eyebrow>Closing</Eyebrow>
  <SlideTitle>Next up: 7.15 -- Stratified Sampling for Accuracy Measurement.</SlideTitle>

  <div class="closing-body">
    <p>We previewed it -- now we build it out. Together with 7.14 it forms the full Scenario 6 reliability toolkit.</p>
  </div>
</Frame>

<style scoped>
.closing-body { margin-top: 56px; font-family: var(--font-body); font-size: 30px; line-height: 1.5; color: var(--forest-500); max-width: 1400px; }
</style>

<!--
Next up: 7.15, stratified sampling for accuracy measurement. We previewed it — now we build it out. Together with 7.14 it forms the full Scenario 6 reliability toolkit. See you there.
-->

---

<!-- LECTURE 7.15 — Stratified Sampling for Accuracy -->

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div class="di-cover">
    <div class="di-cover__eyebrow">Domain 5 · Lecture 7.15</div>
    <div class="di-cover__title">Stratified Sampling<br/>for Accuracy</div>
    <div class="di-cover__subtitle">Catch novel error patterns before aggregate slides</div>
  </div>
</Frame>

<style scoped>
.di-cover { flex: 1; display: flex; flex-direction: column; justify-content: center; gap: 32px; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 28px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); }
.di-cover__title { font-family: var(--font-display); font-size: 112px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); max-width: 1500px; }
.di-cover__subtitle { font-family: var(--font-display); font-size: 40px; color: var(--mint-200); font-style: italic; }
</style>

<!--
Lecture 7.15. Stratified sampling for accuracy measurement. This is Scenario 6 — structured data extraction — and it's the follow-up to 7.14's routing loop. We're now zoomed in on the drift-detection step, which is where most production extraction pipelines silently fail when they're not set up correctly.
-->

---

<ConceptHero
  leadLine="Random misses rare patterns"
  concept="Stratify to guarantee coverage."
  supportLine="Pure random sampling under-represents small segments. Stratified sampling ensures rare-but-important segments get measurement coverage."
/>

<!--
Random sampling misses rare patterns. If ninety-five percent of your extractions are one document type and five percent are a second type, a thousand-sample random pull gives you about fifty examples of the rare type — not enough to catch a failure mode concentrated there. The rare type might be failing at thirty percent, but you only see fifteen errors and they get drowned in the overall noise.

Stratified sampling fixes this by sampling proportionally — or deliberately over-sampling small segments — within each stratum, so rare-but-important segments get the same measurement coverage as common ones. You guarantee coverage of segments that pure random sampling would under-represent.
-->

---

<script setup>
const strataBullets = [
  { label: 'Document type', detail: 'The obvious one -- different formats, different error profiles.' },
  { label: 'Field', detail: 'Individual fields may fail at different rates inside the same doc type.' },
  { label: 'Source', detail: 'Different input pipelines, different error profiles.' },
  { label: 'Time window', detail: 'Recent extractions may drift from historical baselines.' },
  { label: 'Confidence band', detail: 'High / medium / low -- each at a different risk level.' },
]
</script>

<BulletReveal
  title="Sample by..."
  :bullets="strataBullets"
/>

<!--
What to stratify by. Document type — the obvious one. Field — individual fields may fail at different rates even within a single document type. Source — different input pipelines may have different error profiles. Time window — recent extractions may drift from historical baselines. Confidence band — high-confidence, medium, and low each deserve their own sampling because they're each at different risk levels.

Five strata. You don't need all five on every run — pick the ones that matter for your pipeline. At minimum, stratify by document type and confidence band. Those two cover most of the exam's framing and most of the production risk.
-->

---

<CalloutBox variant="tip" title="Two purposes for stratified sampling">

<p><strong>1. Ongoing error-rate measurement</strong> across high-confidence extractions -- the auto-accepted pipeline. You need to know if those accept decisions remain safe over time.</p>
<p><strong>2. Novel pattern detection</strong> as inputs drift -- new document formats, new vendor templates, new input sources that your model wasn't validated on.</p>
<p>Both purposes need stratification. Aggregate measurement misses both.</p>

</CalloutBox>

<!--
Two purposes for stratified sampling. One: ongoing error-rate measurement across high-confidence extractions — the automated pipeline you're auto-accepting. You need to know if those accept decisions remain safe over time. Two: novel pattern detection as inputs drift — new document formats, new vendor templates, new input sources that your model wasn't validated on.

Both purposes need stratification. Aggregate measurement misses both.
-->

---

<script setup>
const processSteps = [
  { title: 'Stratify population', body: 'Segment by doc type, field, source, time window, confidence band.' },
  { title: 'Sample within each stratum', body: 'Enough for the segment estimate to be statistically meaningful.' },
  { title: 'Human-label the sample', body: 'Ground truth per item in the sample.' },
  { title: 'Compute per-stratum accuracy', body: 'Not just one aggregate number.' },
  { title: 'Flag strata below threshold', body: 'Targeted remediation -- route review investment there.' },
]
</script>

<StepSequence
  title="Measurement loop"
  :steps="processSteps"
/>

<!--
The measurement loop. Stratify the population into segments. Sample within each stratum — enough that the segment estimate is statistically meaningful. Human-label the sample. Compute per-stratum accuracy. Flag any stratum that drops below its threshold.

Five steps. Repeat on a cadence that matches your input volume — daily for high-volume pipelines, weekly for lower-volume ones. The cadence matters because drift is faster than most teams assume — a vendor template change that lands on a Tuesday can corrupt a week's worth of extractions by Friday if you're not sampling frequently.
-->

---

<CalloutBox variant="tip" title="Drift detection -- catch novel patterns early">

New document format arrives -- vendor template change, new source sending data.

<p>Aggregate accuracy may not move meaningfully -- the new format is 5% of volume, the 95% is still fine. <strong>Stratified sampling catches the drift early because the new format shows up as its own stratum with its own accuracy number.</strong> You see divergence before the aggregate starts to slide.</p>

<p>Early detection beats late cleanup. That's why stratified sampling is in the exam objectives.</p>

</CalloutBox>

<!--
This is the novel-patterns piece. A new document format shows up — a vendor changes their invoice template, or a new source starts sending data. Aggregate accuracy may not move meaningfully — the new format is five percent of volume, and ninety-five percent of old volume is still fine. Stratified sampling catches the drift early because the new format shows up as its own stratum with its own accuracy number. You see the divergence before the aggregate starts to slide.

Early detection beats late cleanup. That's the whole reason stratified sampling is in the exam objectives. The pipeline that detects drift in week one recovers gracefully. The pipeline that notices in week four has already shipped thousands of bad extractions downstream.
-->

---

<script setup>
const antiPatternBad715 = `1000 random samples. Compute one
overall accuracy number. Ship it.

-> When the number drops, you can't
  tell where the failures concentrate.
-> Might be one stratum. Might be spread
  across many. You can only panic,
  not act.`

const antiPatternFix715 = `Stratified sampling. Per-stratum accuracy
surfaces weak areas.

-> Route human review investment to
  the strata that need it.
-> Targeted effort beats uniform effort.
-> Fix what's actually broken.`
</script>

<AntiPatternSlide
  title="Don't use random sampling alone"
  lang="text"
  :badExample="antiPatternBad715"
  whyItFails="Random under-represents rare strata. The aggregate number loses the location of the problem."
  :fixExample="antiPatternFix715"
/>

<!--
The anti-pattern: take a thousand random samples, compute one overall accuracy number, ship it. When the number drops, you can't tell where the failures are concentrated — they might be in one stratum, they might be spread across all of them. You can't act on a single aggregate number; you can only panic on it.

The better pattern: stratified sampling, per-stratum accuracy surfaces weak areas, and you route human review investment to the strata that need it. Targeted effort beats uniform effort. You fix what's actually broken.
-->

---

<CalloutBox variant="tip" title="On the exam -- the exact phrase">

"Detect novel error patterns in high-confidence extractions" -> stratified random sampling.

<p>Memorize the phrase. <strong>"Stratified random sampling"</strong> -- the exam uses it directly.</p>

<p>Distractor: "increase overall sample size." Doesn't fix the segment-coverage problem. 10,000 random samples still under-represent the 5% stratum.</p>

</CalloutBox>

<!--
On the exam, the exact phrase is "detect novel error patterns in high-confidence extractions." That's the exam's keyword. The right answer is stratified random sampling. Memorize the phrase — stratified random sampling — because the exam uses it directly, and the distractor is often "increase overall sample size," which doesn't fix the segment-coverage problem. Ten thousand random samples still under-represent the five-percent stratum.
-->

---

<Frame bg="var(--mint-100)">
  <Eyebrow>Closing</Eyebrow>
  <SlideTitle>Next up: 7.16 -- Information Provenance: Claim-Source Mappings.</SlideTitle>

  <div class="closing-body">
    <p>Aggregate accuracy is a <em>lagging</em> indicator. Stratified per-segment accuracy is a <em>leading</em> indicator. You want the leading signal -- the lagging one tells you the damage already shipped.</p>
    <p>Now we pivot back to Scenario 3 for the final stretch of Section 7 -- keeping attribution alive through synthesis. Another "structured beats prose" lesson.</p>
  </div>
</Frame>

<style scoped>
.closing-body { margin-top: 56px; font-family: var(--font-body); font-size: 28px; line-height: 1.5; color: var(--forest-500); max-width: 1400px; }
.closing-body p + p { margin-top: 20px; }
.closing-body p em { color: var(--forest-800); font-style: italic; }
</style>

<!--
Before we move on, hold onto the mental frame. Aggregate accuracy is a lagging indicator. Stratified per-segment accuracy is a leading indicator. On any production pipeline, you want the leading signal, because the lagging signal tells you the damage has already shipped. This is the same principle as case-facts blocks and state manifests — externalize the discipline so that forgetting or averaging isn't possible. The exam's Scenario 6 questions consistently reward the leading-indicator answer over the lagging one.

Next up: 7.16, information provenance — claim-source mappings. We're pivoting back to Scenario 3 for the final stretch of Section 7. The discipline there is about keeping attribution alive through synthesis — another "structured beats prose" lesson. See you there.
-->

---

<!-- LECTURE 7.16 — Information Provenance -->

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div class="di-cover">
    <div class="di-cover__eyebrow">Domain 5 · Lecture 7.16</div>
    <div class="di-cover__title">Information Provenance</div>
    <div class="di-cover__subtitle">Claim-source mappings -- structured, not footnoted</div>
  </div>
</Frame>

<style scoped>
.di-cover { flex: 1; display: flex; flex-direction: column; justify-content: center; gap: 32px; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 28px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); }
.di-cover__title { font-family: var(--font-display); font-size: 132px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); max-width: 1500px; }
.di-cover__subtitle { font-family: var(--font-display); font-size: 44px; color: var(--mint-200); font-style: italic; }
</style>

<!--
Lecture 7.16. Information provenance and claim-source mappings. Back to Scenario 3 — multi-agent research — and this lecture plus 7.17 close out Section 7. The pattern here is one of the most overlooked on the exam, and one of the most exam-testable.

If you've built research pipelines before, you've seen this failure mode firsthand — a polished report that no one can fact-check. This lecture is the pattern that prevents it.
-->

---

<BigQuote
  lead="The loss"
  quote="Summarization compresses findings without preserving which source said what. <em>You end up with claims you can't trace.</em>"
  attribution="Same pattern as progressive summarization (7.2) -- here the specifics are the source attribution"
/>

<!--
Summarization compresses findings without preserving which source said what. You end up with claims you can't trace. That's the failure mode. A research report reads: "industry revenue grew twelve percent." Which source? When was that published? Was it the Q1 analyst report or the Q3 trade-association release? Was it the primary data or a secondary citation? Those could be saying very different things, and once the synthesis collapses them into a single claim, you've lost the ability to tell.

Same pattern as progressive summarization from 7.2 — compression erases specifics. Here the specifics are the source attribution.
-->

---

<ConceptHero
  leadLine="Structured claim-source mappings"
  concept="Each claim carries its source."
  supportLine="Claim, URL, excerpt, date -- preserved through every synthesis step. Structured mappings, not footnotes."
/>

<!--
Structured claim-source mappings. Every claim carries its source with it. The shape: claim text, source URL, a direct excerpt from the source, and the publication date. That structure is preserved through every synthesis step — not collapsed into prose. Structured mappings, not footnotes.

Footnotes get stripped. Structured fields don't — if the synthesis agent is built to propagate them. The difference between a report you can trust and a report you can't is usually this structural choice.
-->

---

<script setup>
const mappingCode = `{
  "claims": [
    {
      "claim": "Industry revenue grew 12% in Q3 2025",
      "source_url": "https://example.org/analysts/Q3-2025-cloud.pdf",
      "document_name": "Q3 2025 Cloud Infrastructure Analyst Report",
      "excerpt": "Total market revenue grew 12.0% year-over-year to $87B in Q3 2025.",
      "publication_date": "2025-10-15"
    },
    {
      "claim": "Customer satisfaction rose to 87%",
      "source_url": "https://example.org/surveys/2025-h2.pdf",
      "document_name": "2025 H2 Customer Satisfaction Survey",
      "excerpt": "87% of respondents reported positive or very positive experiences.",
      "publication_date": "2025-11-02"
    }
  ]
}`
</script>

<CodeBlockSlide
  title="Claim-source mapping"
  lang="json"
  :code="mappingCode"
  annotation="Five fields per claim. Unbackable claims get flagged, not included."
/>

<!--
The schema, per claim. Claim — the statement itself. Source_url — the canonical URL. Document_name — for human readability. Excerpt — the actual text from the source that supports the claim. Publication_date — when the source was published.

Five fields. Every claim in the final report is backed by one of these. Claims without backing are flagged, not included. This is a first-class output structure, not an afterthought. The pipeline should refuse to emit unbackable claims, not shrug and ship them.
-->

---

<CalloutBox variant="tip" title="Why dates matter -- temporal context">

Dates matter for more than credit.

<p>"Source A says 12%; source B says 18%" might not be a conflict at all -- source A might be Q1 and source B Q3, and growth accelerated over two quarters. Without dates, those two numbers read as contradictory. With dates, they read as a <em>time series</em>.</p>

<p>This feeds 7.17's conflict handling -- dates are the discriminator between true disagreement and temporal drift.</p>

</CalloutBox>

<!--
Publication dates matter for more than credit. They disambiguate what looks like a contradiction but isn't. "Source A says twelve percent; source B says eighteen percent" might not be a conflict at all — source A might be from Q1 and source B from Q3, and growth accelerated over two quarters. Without dates, those two numbers read as contradictory. With dates, they read as a time series. Provenance includes temporal context.

This matters for 7.17 too — conflict handling depends on distinguishing true disagreement from temporal drift. Dates are the discriminator.
-->

---

<CalloutBox variant="warn" title="Don't collapse in synthesis">

Synthesis agent MUST preserve and merge mappings -- not rewrite claims into fresh prose that drops the structured backing.

<p>If synthesis reads findings and produces a paragraph -> you've lost provenance.</p>
<p>If synthesis reads findings and produces claims-with-attribution -> you've kept it.</p>

<p>The choice is in the synthesis prompt and output schema, not in any downstream formatting step.</p>

</CalloutBox>

<!--
Here's where most implementations fail. The synthesis agent collapses all findings into prose. Mappings evaporate. The final report is polished, readable, and untraceable. The fix is discipline: the synthesis agent MUST preserve and merge the mappings — not rewrite claims into fresh prose that drops the structured backing.

If your synthesis step reads findings and produces a paragraph, you've lost provenance. If your synthesis step reads findings and produces claims-with-attribution, you've kept it. The choice is in the synthesis prompt and the output schema, not in any downstream formatting step.
-->

---

<CalloutBox variant="tip" title="Right format for content">

Different content types want different rendering. The <em>underlying mappings stay the same through the pipeline</em>.

<ul>
<li>Financial data -> tables with source columns.</li>
<li>News and narrative -> prose with inline citations.</li>
<li>Technical findings -> structured lists with source anchors.</li>
</ul>

<p>Pick format at the <strong>output layer</strong>, not by losing mappings at the synthesis layer. Same principle as 7.10's coverage annotations.</p>

</CalloutBox>

<!--
Different content types want different rendering. Financial data — tables, with source columns. News and narrative — prose, with inline citations. Technical findings — structured lists with source anchors. The rendering is a presentation choice, but the underlying data structure — the mappings — stays the same through the pipeline. You pick the format at the output layer, not by losing the mappings at the synthesis layer.

This is the same principle as 7.10's coverage annotations — keep the structured field alive through the pipeline, then render at the end. Structural discipline all the way through; presentation only at the boundary.
-->

---

<script setup>
const antiPatternBad716 = `Combine findings into one prose paragraph:

"Our research indicates that industry
 revenue grew 12% and customer
 satisfaction is trending upward."

-> Clean prose. Zero traceability.
-> Reader has no way to verify any claim.`

const antiPatternFix716 = `Each claim retains source through synthesis.

Report surfaces attribution inline or as
a footer table -- but the data is always
there. A reader who wants to double-check
can always find the source.`
</script>

<AntiPatternSlide
  title="Don't aggregate claims without sources"
  lang="text"
  :badExample="antiPatternBad716"
  whyItFails="Prose aggregation silently drops the attribution layer. Synthesis looks cleaner, deliverable is weaker."
  :fixExample="antiPatternFix716"
/>

<!--
The anti-pattern: aggregate claims into one prose paragraph, drop the sources. "Our research indicates that industry revenue grew twelve percent and customer satisfaction is trending upward." Clean prose. Zero traceability. The downstream reader has no way to verify any claim.

The better pattern: each claim retains its source through synthesis, and the report either surfaces attribution inline or renders it as a footer table — but the data is always there. A reader who wants to double-check a claim can always find the underlying source.
-->

---

<CalloutBox variant="tip" title="On the exam">

"Preserve attribution through synthesis" -> claim-source mappings (structured pattern).

<p>"Include publication dates" is part of the same pattern and may appear as an "also correct" option.</p>

<p>Wrong answer: "rely on the model to include sources in its output" -- models drop attribution under compression unless it's a structured field the pipeline enforces.</p>

</CalloutBox>

<!--
On the exam, the shape is: "Preserve attribution through synthesis." The right answer is claim-source mappings — the structured pattern. "Include publication dates" is part of the same pattern and may appear in a related distractor as an "also correct" option. The wrong answer is "rely on the model to include sources in its output" — models drop attribution under compression unless it's a structured field that the pipeline enforces.
-->

---

<Frame bg="var(--mint-100)">
  <Eyebrow>Closing</Eyebrow>
  <SlideTitle>Next up: 7.17 -- Handling Conflicting Sources.</SlideTitle>

  <div class="closing-body">
    <p>We've now set up attribution. Next lecture is what happens when two attributed sources say different things -- and how to surface that instead of arbitrating it away.</p>
  </div>
</Frame>

<style scoped>
.closing-body { margin-top: 56px; font-family: var(--font-body); font-size: 30px; line-height: 1.5; color: var(--forest-500); max-width: 1400px; }
</style>

<!--
Next up: 7.17, handling conflicting sources. We've now set up attribution. The next lecture is what happens when two attributed sources say different things — and how to surface that instead of arbitrating it away. See you there.
-->

---

<!-- LECTURE 7.17 — Handling Conflicting Sources -->

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div class="di-cover">
    <div class="di-cover__eyebrow">Domain 5 · Lecture 7.17</div>
    <div class="di-cover__title">Handling Conflicting Sources</div>
    <div class="di-cover__subtitle">Annotate -- don't arbitrarily choose</div>
  </div>
</Frame>

<style scoped>
.di-cover { flex: 1; display: flex; flex-direction: column; justify-content: center; gap: 32px; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 28px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); }
.di-cover__title { font-family: var(--font-display); font-size: 112px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); max-width: 1500px; }
.di-cover__subtitle { font-family: var(--font-display); font-size: 44px; color: var(--mint-200); font-style: italic; }
</style>

<!--
Lecture 7.17. Handling conflicting sources. Last lecture of Section 7 — and the last lecture covering the five exam domains before we move to the preparation-exercise demos. This is a Scenario 3 question, and it's a frequent "almost-right" trap.

If you've made it this far through Domain 5, you already know what's coming. The exam-wrong answer will be the one that looks clean and decisive. The exam-right answer will be the one that surfaces complexity honestly. Let's walk through it.
-->

---

<BigQuote
  lead="The trap"
  quote="Source A says 12%. Source B says 18%. <em>The agent picks 12% silently.</em> The report looks clean -- and is wrong."
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
  supportLine="The agent surfaces the disagreement. Downstream reader -- or coordinator -- decides. The agent does not silently pick."
/>

<!--
Annotate, don't arbitrate. Both values, both sources, explicit conflict. The agent surfaces the disagreement; the downstream reader — or a coordinator, or a human reviewer — decides how to reconcile. The agent does not silently pick. Silent arbitration is the failure mode.

This is the same honesty principle as coverage annotations in 7.10 — surface the gap, don't hide it. Different gap; same discipline.
-->

---

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
  "notes": "Sources may disagree OR may reflect time-series drift. Methodologies differ -- treat with caution."
}`
</script>

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

<CalloutBox variant="tip" title="Well-established vs contested -- explicit sections">

Reports should separate sections structurally.

<ul>
<li><strong>Well-established findings</strong> -- sources agree; high-confidence; merge cleanly; firm conclusions.</li>
<li><strong>Contested findings</strong> -- sources disagree; each conflict explicitly surfaced with attribution.</li>
</ul>

<p>Two sections, two epistemic levels. The reader knows what to trust and what to treat with caution. The structure communicates confidence -- rather than forcing it into vague prose qualifiers.</p>

</CalloutBox>

<!--
One more structuring move. Research reports should separate "well-established findings" from "contested findings" as distinct sections. The well-established section holds claims where sources agree — high-confidence, merge cleanly, present as firm conclusions. The contested section holds claims where sources disagree — each conflict explicitly surfaced with attribution.

Two sections, two epistemic levels. The reader knows what to trust and what to treat with caution. The structure does the work of communicating confidence, rather than forcing it into vague prose qualifiers.
-->

---

<CalloutBox variant="tip" title="Temporal vs true conflict -- callback to 7.16">

Sometimes "conflict" is actually temporal -- source A was Q1, source B was Q3, the metric moved.

<p>Publication dates let you distinguish. Two sources with different dates reporting different numbers may not be in conflict -- they may be two points on a time series.</p>

<p>Without dates -> indistinguishable from true disagreement. With dates -> the story is clear. <strong>Provenance feeds conflict resolution.</strong></p>

</CalloutBox>

<!--
Callback to 7.16. Sometimes what looks like a conflict is actually a temporal difference — source A was Q1, source B was Q3, the underlying metric moved. Publication dates let you distinguish. Two sources with different dates reporting different numbers may not be in conflict — they may be two points on a time series. Without dates, they're indistinguishable from a true disagreement. With dates, the story is clear.

This is why 7.16's insistence on publication dates matters here. Provenance feeds conflict resolution. Without dates in your claim-source mappings, you can't tell "the metric grew over time" from "two sources contradict each other." Keep the dates.
-->

---

<CalloutBox variant="tip" title="Where to detect -- document-analysis layer">

Conflict detection happens at the document-analysis layer, BEFORE synthesis.

<p>Document-analysis agent reports values with methodology. Coordinator, seeing multiple values for the same claim, decides how to reconcile -- flag as contested, merge as temporal, escalate for human review.</p>

<p>By the time synthesis runs, the reconciliation is done. <strong>Synthesis doesn't get to silently pick.</strong> Push conflict detection upstream -- once synthesis starts writing paragraphs, the opportunity to preserve the conflict is gone.</p>

</CalloutBox>

<!--
Where should conflict detection happen? At the document analysis layer, before synthesis. The document-analysis agent reports values along with methodology. The coordinator, seeing multiple values for the same claim, decides how to reconcile — flag as contested, merge as temporal, escalate for human review. By the time synthesis runs, the reconciliation is done. Synthesis doesn't get to silently pick.

Push conflict detection upstream. Don't let it die in the final prose pass. Once synthesis starts writing paragraphs, the opportunity to preserve the conflict is gone.
-->

---

<script setup>
const antiPatternBad717 = `Three silent-arbitration shapes:

1. Average two values.
2. Pick the "more recent."
3. Preserve whichever was read first.

-> All strip information the reader needs.
-> "Pick the more recent" looks defensible --
  still silent arbitration, still exam-wrong.`

const antiPatternFix717 = `Surface both with attribution. Let the
reader or coordinator choose.

"Analysts disagree; source A reports 12%
 in Q1, source B reports 18% in Q3."

-> Strictly better than picking 12 and shipping.
-> Visible beats polished.`
</script>

<AntiPatternSlide
  title="Don't silently pick one"
  lang="text"
  :badExample="antiPatternBad717"
  whyItFails="Recency is often correlated with accuracy -- but silent choice strips the reader's ability to verify. Explicit beats clean."
  :fixExample="antiPatternFix717"
/>

<!--
The anti-pattern: agent averages two values, picks the more recent, or silently preserves whichever it read first. All three are silent arbitration. All three strip information the reader needs. The "pick the more recent" version looks especially defensible — recency is often correlated with accuracy — but it's still silent arbitration, and the exam treats it as such.

The better pattern: surface both with attribution, let the reader or coordinator choose. Explicit beats clean. Visible beats polished. A report that says "analysts disagree; source A reports twelve percent in Q1, source B reports eighteen percent in Q3" is strictly better than one that picks twelve and ships.
-->

---

<CalloutBox variant="tip" title="On the exam">

"Conflicting statistics from credible sources" -> annotate both with attribution.

<p>Distractor -- always -- is "pick the more recent" or "average the values" or "select the authoritative source." All almost-right. All silent arbitration. All exam-wrong.</p>

<p>Ingredients: multiple credible sources, same metric, different values -> answer is always <strong>preserve the disagreement</strong>, never silently pick a winner.</p>

</CalloutBox>

<!--
On the exam, the shape is: "Conflicting statistics from credible sources." The right answer is annotate both with attribution. The distractor — always — is "pick the more recent" or "average the values" or "select the authoritative source." All almost-right. All silent arbitration. All exam-wrong. The exam rewards the pattern where the conflict is preserved, not resolved.

Recognize the question by its ingredients — multiple credible sources, same metric, different values. The answer is always to preserve the disagreement, never to silently pick a winner.
-->

---

<Frame bg="var(--mint-100)">
  <Eyebrow>Section 7 closer</Eyebrow>
  <SlideTitle>Domain 5 -- 15% -- is closed. You've now covered all five exam domains.</SlideTitle>

  <div class="closing-body">
    <p><strong>Every section from here is hands-on demos.</strong> Scenario by scenario. Domains 1-5 all get reinforced in the demos -- the work isn't done, but the conceptual ground is covered.</p>
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
