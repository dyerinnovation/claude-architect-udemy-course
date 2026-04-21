---
theme: default
title: "Lecture 7.3: Trim Verbose Tool Outputs"
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
const trimLocations = [
  { label: 'MCP tool response', cells: [{ text: 'Clean from the start — best', highlight: 'good' }] },
  { label: 'Hook layer (PostToolUse)', cells: [{ text: 'Normalizes across tools', highlight: 'neutral' }] },
  { label: 'Agent prompt post-hoc', cells: [{ text: 'Too late — tokens already spent', highlight: 'bad' }] },
]

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
  detail="A 12-turn session hitting lookup_order 6× has 240 operational fields cluttering working context."
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

<CodeBlockSlide
  title="lookup_order — trimmed response"
  lang="json"
  :code="trimmedCode"
  annotation="Same function, same data source, ~90% less context footprint."
/>

<!--
Concretely, imagine lookup_order returns forty fields. The raw response has order_id, customer_id, items, shipping_address, billing_address, payment_method, tax_breakdown by jurisdiction, fulfillment_partner_id, warehouse_routing_codes, carrier_handoff_timestamps, regional_compliance_flags, and so on for thirty-five fields the agent will never touch.

The trimmed response keeps the first four fields — order_id, customer_id, items, shipping_address — and drops the rest. Same function, same data source, ninety percent less context footprint. And the agent doesn't miss what it never needed. If a downstream case ever requires the billing address, you add it back deliberately. You don't ship everything-by-default.
-->

---

<CalloutBox variant="tip" title="PostToolUse — cross-tool normalization">

One hook trims all order-adjacent tools in a normalized way. lookup_order, update_order, cancel_order all pipe through the same trimming logic. Covered in Domain 1 Task 1.5.

The right layer when you own the agent runtime but don't own the tools themselves. Enterprise settings — where MCP servers come from a platform team — are the classic case.

</CalloutBox>

<!--
The hook option is worth knowing. One PostToolUse hook can trim all order-adjacent tools in a normalized way — lookup_order, update_order, cancel_order all pipe through the same trimming logic. That's the pattern we covered in Domain 1 Task 1.5 — cross-tool normalization through hooks. Single responsibility: read the tool's output, return a projected version. One hook, many tools, consistent trimming.

This is the right layer when you own the agent runtime but don't own the tools themselves. Enterprise settings — where MCP servers come from a platform team — are the classic case.
-->

---

<CalloutBox variant="tip" title="Scenario 1 — customer support">

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

"Context filling with irrelevant tool data" → trim at the tool response (or hook).

The distractor — "use a larger context window" — is the same trap as 7.1. Larger windows don't fix the structural problem. Reliability comes from discipline at the edges, not capacity in the middle.

</CalloutBox>

<!--
On the exam, the shape is: "Context is filling with irrelevant tool data across long sessions." The right answer is trim at the tool response — or at a hook layer. The distractor is "use a larger context window." Same trap as 7.1. Larger windows don't fix the structural problem — they just give you more room to waste, and more middle to lose things in. This is a Domain 5 question, and the exam is testing whether you understand that reliability comes from discipline at the edges, not from more capacity in the middle.
-->

---

<Frame bg="var(--mint-100)">
  <Eyebrow>Closing</Eyebrow>
  <SlideTitle>Next up: 7.4 — The Persistent Case Facts Block Pattern.</SlideTitle>

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
