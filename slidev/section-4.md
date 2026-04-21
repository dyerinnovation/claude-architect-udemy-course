---
theme: default
title: "Section 4: Domain 2 - Tool Design & MCP Integration"
info: |
  Claude Certified Architect – Foundations
  Section 4: Domain 2 - Tool Design & MCP Integration (18%)
highlighter: shiki
transition: slide-left
mdc: true
canvasWidth: 1920
aspectRatio: 16/9
---

<style>
@import './design-system.css';
</style>

<!-- LECTURE 4.1 — Why Tool Descriptions Are the Most Important Thing You Write -->

<div class="di-cover">
  <div class="di-cover__inner">
    <div class="di-cover__eyebrow">Domain 2 · Lecture 4.1</div>
    <h1 class="di-cover__title">Why Tool Descriptions Are the Most<br/><span class="di-cover__accent">Important Thing You Write</span></h1>
    <div class="di-cover__subtitle">Section 4 — Tool Design &amp; MCP Integration · 18%</div>
  </div>
</div>

<style scoped>
.di-cover { position: absolute; inset: 0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%); color: var(--mint-100); }
.di-cover__inner { padding: 110px 120px 96px; height: 100%; display: flex; flex-direction: column; justify-content: center; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px; }
.di-cover__title { font-family: var(--font-display); font-weight: 500; font-size: 104px; line-height: 1.05; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1600px; }
.di-cover__accent { color: var(--sprout-500); }
.di-cover__subtitle { font-family: var(--font-display); font-size: 40px; color: var(--mint-200); margin-top: 40px; font-weight: 400; }
</style>

<!--
Welcome to Domain 2. Eighteen percent of your exam. And if you only take one thing from this entire section, take this: the single most important piece of code you'll write for an agent isn't the agent loop, the system prompt, or the tool implementation. It's the tool description. This lecture is about why.
-->

---

<BigQuote
  lead="Production logs · 12% of cases"
  quote="Agent skipped <em>get_customer</em> entirely and called <em>lookup_order</em> using only the customer's stated name."
  attribution="Sample Question 1, exam guide"
/>

<!--
Here's what the exam is actually testing. Production logs, Scenario 1 — customer support. Twelve percent of cases, the agent skips get_customer entirely and calls lookup_order using only the customer's stated name. That's real money on the line. Misidentified accounts. Wrong refunds. Sample Question 1 from the exam guide opens with exactly this failure. The agent isn't broken. The loop isn't broken. Claude is picking the wrong tool — and picking it confidently — one time out of eight. That's where this domain lives.
-->

---

<ConceptHero
  leadLine="Tool selection happens in the description, not the code."
  concept="The description IS the prompt."
  supportLine="Minimal descriptions produce unreliable selection among similar tools. Reliably unreliable."
/>

<!--
So here's the core claim. Tool selection happens in the description, not the code. The description Claude reads is a prompt — the exact same prompt it uses for everything else. Minimal descriptions produce unreliable selection among similar tools. Not sometimes. Reliably unreliable. The description isn't metadata. It's not documentation. It's the single piece of text Claude uses, at every turn, to decide which tool to call. If that text is weak, selection is weak. Everything flows from understanding that.
-->

---

<TwoColSlide
  title="Same tool, same schema. Only prose changed."
  leftLabel="Minimal (wrong 12%)"
  rightLabel="Differentiated (right)"
>
  <template #left>
    <div style="font-family: var(--font-mono); font-size: 22px; line-height: 1.5;">
      <strong>get_customer</strong><br/>
      "Retrieves customer information."<br/><br/>
      <strong>lookup_order</strong><br/>
      "Retrieves order details."
    </div>
  </template>
  <template #right>
    <div style="font-family: var(--font-mono); font-size: 20px; line-height: 1.5;">
      <strong>get_customer</strong><br/>
      "Retrieves customer identity and verification status. Use BEFORE any order operation. Input: customer_id or email. Do NOT use for order lookups — use <code>lookup_order</code> instead."
    </div>
  </template>
</TwoColSlide>

<!--
Look at the difference. On the left, the minimal version — the one that produces the twelve-percent failure rate. get_customer: "Retrieves customer information." That's it. Seven words. And then lookup_order: "Retrieves order details." Another six words. Two tools with near-identical shapes, near-identical prose. Claude has nothing to choose between them. On the right, the differentiated version. get_customer: "Retrieves customer identity and verification status. Use BEFORE any order operation. Input: customer_id or email. Do NOT use for order lookups — use lookup_order instead." That's the fix. Same tool, same backend, same schema. The only thing that changed is the prose. Misroutes drop to near zero.
-->

---

<script setup>
const s5_bullets = [
  { label: 'Name', detail: 'The identifier Claude sees first -- semantic weight.' },
  { label: 'One-line summary', detail: 'Short hint, usually insufficient on its own.' },
  { label: 'Input schema', detail: 'Argument shapes -- matters for calling, not routing.' },
  { label: 'Your prose', detail: 'The lever. This is what drives the selection decision.' },
]
</script>

<BulletReveal
  title="The description is a context-window line item"
  :bullets="s5_bullets"
/>

<!--
Hold that in mind while I show you what Claude actually sees at selection time. It's four things. The tool name. A one-line summary. The input schema. And your prose. That prose is the lever. The name matters — we'll come back to that in 4.3. The schema matters for arguments, not routing. But for the question of "which tool do I call right now?", Claude is reading your prose. If the prose is vague, the decision is a coin flip between plausible options. If the prose is differentiated, the decision is easy.
-->

---

<BigNumber
  number="12%"
  unit=" misroute rate"
  caption="Minimal descriptions → wrong tool picked in one out of eight production cases"
  detail="Sample Question 1 cites this directly. 88% looks fine — until you realize what one-in-eight means in customer support."
/>

<!--
Twelve percent. One in eight calls. That's the misroute rate that the exam puts in front of you with minimal descriptions. And that's not theoretical — the exam guide cites it directly in Sample Question 1. Eighty-eight percent success looks almost okay on a dashboard, until you realize what it means in customer support: one in eight refunds goes to the wrong account. That number is the reason Domain 2 carries eighteen percent of the exam weight. Selection reliability is the production problem.
-->

---

<CalloutBox variant="tip" title="Exam move">

Domain 2 distractors look correct at the system-prompt layer — routing classifiers, consolidation, few-shot examples. The root cause is almost always the description. Remember from 1.1: "almost-right is the whole trap of this exam." This is the canonical example.

</CalloutBox>

<!--
Here's the exam move. Domain 2 questions will hand you a distractor that looks reasonable. Few-shot examples showing the agent calling the right tool. A routing classifier that parses user input before each turn. Consolidating two tools into one lookup_entity. These aren't wrong everywhere — they're wrong as the first move when the root cause is the description. And the root cause is almost always the description. Remember that phrase from Lecture 1.1 — "almost-right is the whole trap of this exam." This is the canonical example.
-->

---

<AntiPatternSlide
  title="Don't fix this with a routing classifier"
  badExample="Pre-parse user input. Enable only tool subset per turn.
Build a keyword router in front of the agent."
  whyItFails="Infrastructure answering a prose problem."
  fixExample="Rewrite the description first.
Confirm with an eval set.
Escalate to routing only if prose doesn't solve it."
  lang="text"
/>

<!--
Don't reach for the routing classifier. That's the anti-pattern. Pre-parsing user input, enabling only a subset of tools per turn — it's infrastructure answering a prose problem. The proportionate fix rewrites the description first, confirms with an eval set, and only escalates to routing or consolidation if differentiated prose doesn't solve it. If you see a distractor proposing a classifier, treat it as the almost-right trap. The exam is testing whether you jump to infrastructure or stay on the proportionate lever.
-->

---

<ConceptHero
  leadLine="One line to hold onto"
  concept="Descriptions are the #1 lever."
  supportLine="Every other fix — few-shots, routers, consolidation — is downstream of this. Scenario 1 lives or dies on this."
/>

<!--
One line to hold onto. Descriptions are the number-one lever for tool-selection reliability. Every other fix — few-shots, routers, consolidation, splitting — is downstream of this. Scenario 1 lives or dies on this. If you can name the tool-selection root cause in under ten seconds on exam day, you've banked points on multiple Domain 2 questions.
-->

---

<div class="di-close">
  <div class="di-close__inner">
    <div class="di-close__eyebrow">Next up</div>
    <h1 class="di-close__title">4.2 — <span class="di-close__accent">What Makes a Great Tool Description</span></h1>
    <div class="di-close__subtitle">Four parts. Every great description has all four.</div>
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
Next up, Lecture 4.2 — what actually goes into a great tool description. Four parts. Every great description has all four. See you there.
-->

---

<!-- LECTURE 4.2 — What Makes a Great Tool Description -->

<div class="di-cover">
  <div class="di-cover__inner">
    <div class="di-cover__eyebrow">Domain 2 · Lecture 4.2</div>
    <h1 class="di-cover__title">What Makes a <span class="di-cover__accent">Great Tool Description</span></h1>
    <div class="di-cover__subtitle">Four parts. Applied to a real tool.</div>
  </div>
</div>

<style scoped>
.di-cover { position: absolute; inset: 0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%); color: var(--mint-100); }
.di-cover__inner { padding: 110px 120px 96px; height: 100%; display: flex; flex-direction: column; justify-content: center; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px; }
.di-cover__title { font-family: var(--font-display); font-weight: 500; font-size: 116px; line-height: 1.05; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1600px; }
.di-cover__accent { color: var(--sprout-500); }
.di-cover__subtitle { font-family: var(--font-display); font-size: 40px; color: var(--mint-200); margin-top: 40px; font-weight: 400; }
</style>

<!--
Last lecture I told you descriptions are the lever. This one is about what a great description actually looks like. Not best practices in the abstract — four concrete parts, applied to a real tool. By the end of these eight minutes you'll be able to write a description that Claude picks correctly on the first try.
-->

---

<ConceptHero
  leadLine="Last lecture: descriptions are the lever."
  concept="This lecture: what goes in one."
  supportLine="Four parts. Every great tool description has all four. Miss one — you're back to the 12% misroute rate."
/>

<!--
Quick recap. Last lecture: tool descriptions are the number-one lever for selection reliability, and the evidence is that twelve-percent misroute rate the exam guide puts in front of you on Sample Question 1. This lecture: what goes into a great one. Four parts. Every great tool description has all four. Miss one and you're back to the twelve-percent misroute rate from 4.1. Get all four and the routing problem mostly disappears. That's the simple framing. Now let's actually put it together.
-->

---

<script setup>
const anatomy_bullets = [
  { label: 'Purpose', detail: 'One sentence, unambiguous. What does this tool do?' },
  { label: 'Input formats', detail: 'What identifiers this tool actually accepts.' },
  { label: 'Example queries', detail: 'Two or three concrete examples of valid calls.' },
  { label: 'Boundaries', detail: 'When to use vs when NOT -- the heaviest lifter.' },
]
</script>

<BulletReveal
  title="Anatomy of a useful description"
  :bullets="anatomy_bullets"
/>

<!--
Here are the four. Purpose — one sentence, unambiguous. Input formats — what identifiers this tool actually accepts. Example queries — two or three concrete examples of what a valid call looks like. Boundaries — when to use this versus when NOT to. That last one is the one most descriptions skip, and it's the one that does the heaviest lifting. These four are the anchor concept for this domain. Get the anchor concept first — the same move 1.1 told you to make at the domain level, now at the tool level.
-->

---

<script setup>
const process_refund_code = `{
  "name": "process_refund",
  "description": "Issues a refund against a verified customer order.

  Input formats: Requires a confirmed order_id from lookup_order and
  a refund amount in USD cents.

  Example queries:
    - 'Refund the $49 charge on order 7821'
    - 'Cancel and refund order 9003 for damaged item'

  Boundaries: Use for refunds up to $500. For amounts above,
  use escalate_to_human. Do NOT call without a prior get_customer
  verification."
}`
</script>

<CodeBlockSlide
  title="Applied: process_refund"
  lang="json"
  :code="process_refund_code"
/>

<!--
Let me show you this applied. Here's process_refund with all four parts. Purpose: "Issues a refund against a verified customer order." Input formats: "Requires a confirmed order_id from lookup_order and a refund amount in USD cents." Example queries: "Refund the $49 charge on order 7821," and "Cancel and refund order 9003 for damaged item." Boundaries: "Use for refunds up to five hundred dollars. For amounts above, use escalate_to_human. Do NOT call without a prior get_customer verification." That's it. One description. Claude knows exactly when to call this tool and when not to.
-->

---

<CalloutBox variant="warn" title="The 'versus' clause">

"Use for refunds up to $500. For amounts above, use <code>escalate_to_human</code>." That one sentence eliminates ~80% of misroutes. Semantically it adds nothing — the limit is in business logic anyway. But for the model choosing between two plausible tools, this is what breaks the tie.

</CalloutBox>

<!--
That last line is the one to pay attention to. "Use for refunds up to five hundred dollars. For amounts above, use escalate_to_human." The versus clause. It's the single sentence that eliminates most misroutes. Semantically it adds nothing — the dollar limit exists in your business logic anyway. But for the model, staring at two tools that both look plausible, the versus clause is what breaks the tie. This is the line that converts a forty-percent confidence call into a ninety-percent confidence call.
-->

---

<script setup>
const edge_bullets = [
  { label: 'Weird formats', detail: 'Pound signs, "order" prefixes, extra whitespace -- say so.' },
  { label: 'Empty / null handling', detail: 'Return an error? Ask for one? Spell it out.' },
  { label: 'Collision case', detail: 'When two tools could apply -- which wins and why.' },
]
</script>

<BulletReveal
  title="Include the weird inputs"
  :bullets="edge_bullets"
/>

<!--
Part of a great description is telling Claude what the weird inputs look like. Formats the model might actually see — customers paste order numbers with pound signs, with "order" prefixed, with extra whitespace. Say so. What to do with empty or null — if the user asks to refund an order with no order ID, does the tool return an error or ask for one? Say so. And the collision case — when two tools could apply, which one wins and why. Spell it out in prose. These edge cases aren't comprehensive — they're targeted. Two or three lines that cover the failure modes you've actually seen.
-->

---

<TwoColSlide
  title="Generic vs Complete"
  leftLabel="Generic (5 words)"
  rightLabel="Complete (~60 words)"
>
  <template #left>
    <div style="font-family: var(--font-mono); font-size: 24px; line-height: 1.6;">
      "Processes customer refunds."
      <br/><br/>
      <span style="font-family: var(--font-body); font-size: 22px; color: var(--clay-500);">No input shape. No example. No boundary. 12% misroute rate in production.</span>
    </div>
  </template>
  <template #right>
    <div style="font-family: var(--font-mono); font-size: 18px; line-height: 1.5;">
      Purpose + Input formats + Example queries + Boundaries
      <br/><br/>
      <span style="font-family: var(--font-body); font-size: 22px; color: var(--sprout-600);">Written once. Every subsequent call benefits. Highest ROI prompt-engineering move.</span>
    </div>
  </template>
</TwoColSlide>

<!--
Side by side. On the left, generic: "Processes customer refunds." Five words. Model has nothing to work with — no input shape, no example, no boundary. On the right, complete: the full process_refund description from slide 4 — purpose, inputs, examples, boundaries. Maybe sixty words. That's the investment. Sixty words, written once, versus a twelve-percent misroute rate in production. There is no other prompt-engineering move with a higher return on effort. You write the description once, every subsequent call benefits, and you never have to touch the agent loop or the system prompt to fix selection.
-->

---

<CalloutBox variant="tip" title="On the exam">

Sample Question 2, answer B: <strong>"Expand each tool's description to include input formats, example queries, edge cases, and boundaries."</strong> Memorize those four words. Few-shots, routing, consolidation — those are the distractors.

</CalloutBox>

<!--
Here's the direct exam connection. Sample Question 2 from the exam guide asks what's the most effective first step when descriptions are minimal and two tools — get_customer and lookup_order again — are getting confused. The correct answer is B — and the wording is almost verbatim what I just gave you: "Expand each tool's description to include input formats, example queries, edge cases, and boundaries." Memorize those four words. If you see them in an answer choice on exam day, that's your signal. Few-shot examples, routing layers, consolidating into one lookup_entity — those are the distractors. Each one is plausible in a different context. None of them is the proportionate first move. The description rewrite is.
-->

---

<div class="di-close">
  <div class="di-close__inner">
    <div class="di-close__eyebrow">Next up</div>
    <h1 class="di-close__title">4.3 — <span class="di-close__accent">Diagnosing and Fixing Tool Selection Failures</span></h1>
    <div class="di-close__subtitle">From log to fix — the diagnostic workflow.</div>
  </div>
</div>

<style scoped>
.di-close { position: absolute; inset: 0; background: var(--mint-100); color: var(--forest-800); }
.di-close__inner { padding: 110px 120px 96px; height: 100%; display: flex; flex-direction: column; justify-content: center; }
.di-close__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.14em; text-transform: uppercase; color: var(--teal-500); margin-bottom: 36px; }
.di-close__title { font-family: var(--font-display); font-weight: 500; font-size: 88px; line-height: 1.05; letter-spacing: -0.02em; color: var(--forest-900); margin: 0; max-width: 1600px; }
.di-close__accent { color: var(--sprout-600); }
.di-close__subtitle { font-family: var(--font-display); font-size: 38px; color: var(--forest-500); margin-top: 32px; font-weight: 400; }
</style>

<!--
Next up, Lecture 4.3 — diagnosing tool selection failures. We'll take a concrete bad case and walk the workflow from log to fix. See you there.
-->

---

<!-- LECTURE 4.3 — Diagnosing and Fixing Tool Selection Failures -->

<div class="di-cover">
  <div class="di-cover__inner">
    <div class="di-cover__eyebrow">Domain 2 · Lecture 4.3</div>
    <h1 class="di-cover__title">Diagnosing and Fixing<br/><span class="di-cover__accent">Tool Selection Failures</span></h1>
    <div class="di-cover__subtitle">Logs first. Hypothesis second. Fix third.</div>
  </div>
</div>

<style scoped>
.di-cover { position: absolute; inset: 0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%); color: var(--mint-100); }
.di-cover__inner { padding: 110px 120px 96px; height: 100%; display: flex; flex-direction: column; justify-content: center; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px; }
.di-cover__title { font-family: var(--font-display); font-weight: 500; font-size: 104px; line-height: 1.05; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1600px; }
.di-cover__accent { color: var(--sprout-500); }
.di-cover__subtitle { font-family: var(--font-display); font-size: 40px; color: var(--mint-200); margin-top: 40px; font-weight: 400; }
</style>

<!--
You've written the description. You've included all four parts. And the agent is still picking the wrong tool. What now? That's this lecture. Diagnostic workflow. Logs first, hypothesis second, fix third. Because the fix is almost always the description — but you have to confirm the cause before you rewrite.
-->

---

<BigQuote
  quote="The agent keeps calling <em>analyze_content</em> when it should call <em>analyze_document</em>. Both tools work. Why is it picking wrong?"
/>

<!--
Here's the setup. Scenario from the exam: "The agent keeps calling analyze_content when it should call analyze_document. Both tools work. Why is it picking wrong?" Both descriptions look reasonable in isolation. Both tools return useful output. The agent is confidently wrong. This is the Domain 2 trap in its purest form — almost-right at every layer.
-->

---

<script setup>
const failure_modes = [
  { label: 'Overlap', detail: 'Two descriptions that look near-identical to the model.' },
  { label: 'Keyword hijack', detail: 'A word in the system prompt steers the pick.' },
  { label: 'Missing boundary', detail: "Neither description rules itself out when the other applies." },
]
</script>

<BulletReveal
  title="What 'wrong tool' actually means"
  :bullets="failure_modes"
/>

<!--
When we say "wrong tool," we actually mean one of three things, and they look similar at first glance. One — overlap. Two descriptions that look near-identical to the model. Two — keyword hijack. A word in the system prompt that steers the pick regardless of description. Three — missing boundary. Neither tool's description rules itself out when the other would apply. Each one has a different fix. If you skip straight to rewriting without diagnosing which of the three is in play, you'll rewrite the wrong thing and the failure will persist under new words.
-->

---

<script setup>
const diagnostic_steps = [
  { label: 'Observe wrong pick', sublabel: 'In logs -- confirm it\'s a pattern' },
  { label: 'Read descriptions', sublabel: 'Side-by-side on one screen' },
  { label: 'Audit system prompt', sublabel: 'Keyword collisions with tool names' },
  { label: 'Rewrite / rename', sublabel: 'Or both -- the diagnosis tells you' },
]
</script>

<FlowDiagram
  title="From log to fix"
  :steps="diagnostic_steps"
/>

<!--
Here's the flow. Step one — observe the wrong pick in logs. Not once, a handful of times, so you know it's a pattern and not a one-off. Step two — read both descriptions side by side, on the same screen. You're looking for overlap, for lines that could apply to either tool, for missing boundary clauses. Step three — read the system prompt with those tool names in mind. You're looking for keyword collisions — the word "analyze" steering toward the analyze_* family, the word "lookup" steering toward lookup_*. Step four — rewrite the description, rename the tool, or both. The diagnosis tells you which. Skip any step and you're guessing.
-->

---

<TwoColSlide
  title="Fix 1 — Rename and rescope"
  leftLabel="Before"
  rightLabel="After"
>
  <template #left>
    <div style="font-family: var(--font-mono); font-size: 32px;">
      <strong>analyze_content</strong>
      <br/><br/>
      <span style="font-family: var(--font-body); font-size: 22px;">Competes with every other <code>analyze_*</code> tool in the agent. Name does no disambiguation work.</span>
    </div>
  </template>
  <template #right>
    <div style="font-family: var(--font-mono); font-size: 32px;">
      <strong>extract_web_results</strong>
      <br/><br/>
      <span style="font-family: var(--font-body); font-size: 22px;">Specific to the web-search output it handles. The rename does half the disambiguation work before the description even loads.</span>
    </div>
  </template>
</TwoColSlide>

<!--
First fix. Rename and rescope. Left column — the before: analyze_content. Right column — the after: extract_web_results. This is the exact fix cited in the exam guide Task 2.1. The name carries semantic weight, not just the description. analyze_content competes with every other analyze_* tool in the agent. extract_web_results doesn't compete with anything — it's specific to the web-search output it handles. The rename does half the disambiguation work before the description even loads.
-->

---

<script setup>
const keyword_collision = `System prompt:
  "Analyze the user's request carefully before acting."

Tools available:
  analyze_content   <- model gravitates here
  analyze_document
  extract_summary

Fix: swap the word ("evaluate"), rename the tool, or both.`
</script>

<CodeBlockSlide
  title="Fix 2 — System prompt audit"
  lang="text"
  :code="keyword_collision"
/>

<!--
Second fix. Audit the system prompt. This is the one people miss. If your system prompt says "analyze the user's request carefully before acting," that word "analyze" is steering the model toward any analyze_* tool. The description can be perfect and still get overridden by a keyword collision in the surrounding prompt. The exam guide calls this out explicitly — keyword-sensitive instructions can override well-written tool descriptions. Read your system prompt with the tool names loaded. Swap the word, rename the tool, or both.
-->

---

<CalloutBox variant="tip" title="Fix 3 — the one-line versus clause">

<strong>"Use for X. Do NOT use for Y — use <code>tool_Y</code> instead."</strong>
<br/><br/>
Adds nothing semantically. Disambiguates completely in the prose Claude actually reads. The cheapest high-leverage fix in this entire section. Every pair of tools that could collide should have this line in at least one description.

</CalloutBox>

<!--
Third fix. Add the versus clause. "Use for X. Do NOT use for Y — use tool_Y instead." Adds nothing semantically — the tools already only handle their respective cases. But it disambiguates completely in the prose Claude actually reads. If overlap is the diagnosis and rename isn't possible — maybe the name is already exposed in an external API contract — the versus clause does the work in prose. One line. Every pair of tools that could collide should have this line in at least one of their descriptions. It's the cheapest high-leverage fix in this entire section.
-->

---

<AntiPatternSlide
  title="Don't jump to a routing layer"
  badExample="Pre-parse user input.
Force tool selection based on keyword match.
Ship infrastructure to fix prose."
  whyItFails="Same anti-pattern from 4.1. Infrastructure answering a prose problem."
  fixExample="Rewrite description.
Confirm against eval set.
Escalate to routing ONLY if fix didn't take."
  lang="text"
/>

<!--
Don't jump to a routing layer. Same anti-pattern from 4.1, showing up again because it's that tempting. Pre-parsing the input, forcing tool selection based on keywords — it's infrastructure for a prose problem. The right escalation path: rewrite the description, confirm against an eval set, and then escalate to routing or consolidation if the fix didn't take. Routing is not the first move. Scenario 3 — multi-agent research — leans on this: the synthesis agent's tool confusion is almost always a description fix, not a router.
-->

---

<CalloutBox variant="tip" title="On the exam">

On Domain 2 tool-selection questions, the correct answer is <em>almost always</em> the one that rewrites the description, renames the tool, or adds the versus clause. Few-shots and routing classifiers are the distractor classics — plausible in a different context, not the proportionate first fix.

</CalloutBox>

<!--
Here's the exam move. On Domain 2 tool-selection questions, the correct answer is almost always the one that rewrites the description, renames the tool, or adds the versus clause. Few-shot examples and routing classifiers are the distractor classics — they're plausible in a different context, but they're not the proportionate first fix. Remember "almost-right is the whole trap of this exam." The proportionate answer is the one that matches the cost of the problem.
-->

---

<div class="di-close">
  <div class="di-close__inner">
    <div class="di-close__eyebrow">Next up</div>
    <h1 class="di-close__title">4.4 — <span class="di-close__accent">Splitting Generic Tools vs Consolidating</span></h1>
    <div class="di-close__subtitle">When one tool becomes three. When three become one.</div>
  </div>
</div>

<style scoped>
.di-close { position: absolute; inset: 0; background: var(--mint-100); color: var(--forest-800); }
.di-close__inner { padding: 110px 120px 96px; height: 100%; display: flex; flex-direction: column; justify-content: center; }
.di-close__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.14em; text-transform: uppercase; color: var(--teal-500); margin-bottom: 36px; }
.di-close__title { font-family: var(--font-display); font-weight: 500; font-size: 88px; line-height: 1.05; letter-spacing: -0.02em; color: var(--forest-900); margin: 0; max-width: 1600px; }
.di-close__accent { color: var(--sprout-600); }
.di-close__subtitle { font-family: var(--font-display); font-size: 38px; color: var(--forest-500); margin-top: 32px; font-weight: 400; }
</style>

<!--
Next up, Lecture 4.4 — splitting generic tools versus consolidating. When does one tool become three, and when do three tools become one? See you there.
-->

---

<!-- LECTURE 4.4 — Splitting Generic Tools vs Consolidating -->

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

<script setup>
const split_code = `# Before -- generic
analyze_document(doc, mode)

# After -- three tools, three contracts
extract_data_points(doc, schema)         # returns structured object
summarize_content(doc, length_target)    # returns prose
verify_claim_against_source(doc, claim)  # returns verdict + evidence

# Each tool gets its own boundary clause:
#   "Use for structured extraction, not summarization;
#    for a prose summary, use summarize_content."`
</script>

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

<script setup>
const decision_steps = [
  { label: 'Different inputs?', sublabel: 'Schema differs across calls' },
  { label: 'Different outputs?', sublabel: 'Return shape differs' },
  { label: 'Different agents?', sublabel: 'Used by separate roles' },
  { label: 'Any YES -> split', sublabel: 'All NO -> consolidate' },
]
</script>

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

---

<!-- LECTURE 4.5 — MCP Error Response Design -->

<div class="di-cover">
  <div class="di-cover__inner">
    <div class="di-cover__eyebrow">Domain 2 · Lecture 4.5</div>
    <h1 class="di-cover__title">MCP <span class="di-cover__accent">Error Response Design</span></h1>
    <div class="di-cover__subtitle">Three fields. Memorize them. Miss one — pick a distractor.</div>
  </div>
</div>

<style scoped>
.di-cover { position: absolute; inset: 0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%); color: var(--mint-100); }
.di-cover__inner { padding: 110px 120px 96px; height: 100%; display: flex; flex-direction: column; justify-content: center; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px; }
.di-cover__title { font-family: var(--font-display); font-weight: 500; font-size: 128px; line-height: 1.05; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1600px; }
.di-cover__accent { color: var(--sprout-500); }
.di-cover__subtitle { font-family: var(--font-display); font-size: 38px; color: var(--mint-200); margin-top: 40px; font-weight: 400; }
</style>

<!--
Three fields. Memorize them. errorCategory. isRetryable. Human-readable description. Miss one and you'll pick a distractor that looks almost right but isn't. This lecture is the most exam-critical thing in Domain 2. Nine minutes. Pay attention.
-->

---

<BigQuote
  quote="Generic 'Operation failed' prevents the agent from making appropriate recovery decisions."
  attribution="Task 2.2, exam guide"
/>

<!--
Here's the line from the exam guide. "Generic 'Operation failed' prevents the agent from making appropriate recovery decisions." Task 2.2, verbatim. That one sentence is why this lecture exists. Returning {"error": "Operation failed"} looks like you handled the error. You didn't. You returned a message the agent cannot act on. The agent either retries blindly, escalates blindly, or gives up blindly — and each of those is wrong in a different situation. Structure is the fix.
-->

---

<div class="di-schema-slide">
  <div class="di-schema-slide__eyebrow">Structured MCP error response</div>
  <h1 class="di-schema-slide__title">Three fields. All three required.</h1>
  <div class="di-schema-slide__fields">
    <SchemaField
      name="errorCategory"
      type="enum"
      required
      description="transient | validation | business | permission"
      example='"business"'
    />
    <SchemaField
      name="isRetryable"
      type="boolean"
      required
      description="Tells the agent whether retry is worth attempting now."
      example="false"
    />
    <SchemaField
      name="description"
      type="string"
      required
      description="Human-readable. Shown to the user or used in escalation."
      example='"Refund exceeds $500 limit; escalation required."'
    />
  </div>
</div>

<style scoped>
.di-schema-slide { position: absolute; inset: 0; padding: 110px 120px 96px; background: var(--paper-50); display: flex; flex-direction: column; }
.di-schema-slide__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.14em; text-transform: uppercase; color: var(--teal-500); margin-bottom: 36px; }
.di-schema-slide__title { font-family: var(--font-display); font-weight: 500; font-size: 76px; line-height: 1.08; letter-spacing: -0.02em; color: var(--forest-800); margin: 0 0 56px; }
.di-schema-slide__fields { display: flex; flex-direction: column; gap: 22px; }
</style>

<!--
Here's the shape of a structured MCP error response. Three fields. First: errorCategory — an enum with four values. Transient, validation, business, permission. Second: isRetryable — a boolean. True or false. Tells the agent whether trying again now is worth attempting. Third: a human-readable description — a string, shown to the user or used in escalation context. That's the full shape. Say those three out loud once: errorCategory, isRetryable, description. Those are the words.
-->

---

<script setup>
const field_questions = [
  { label: 'errorCategory -> which recovery path?', detail: 'Retry, reformat, escalate, run prereq?' },
  { label: 'isRetryable -> try again right now, or not?', detail: 'The fast-path decision.' },
  { label: 'description -> what do I tell the user?', detail: 'Customer-facing string. Shown to the user or used in escalation.' },
]
</script>

<BulletReveal
  title="Each field answers one question"
  :bullets="field_questions"
/>

<!--
Each field answers one question the agent has to answer. errorCategory answers "which recovery path do I take?" — retry, reformat, escalate, or run a prerequisite. isRetryable answers "try again right now, or not?" — it's the fast-path decision. Description answers "what do I tell the user?" — and that matters because on a customer-facing agent, the user sees that string. Skip any one field and the agent is guessing at one of those three questions.
-->

---

<script setup>
const good_error = `{
  "isError": true,
  "errorCategory": "business",
  "isRetryable": false,
  "description": "Refund amount of $750 exceeds the
    $500 per-transaction limit. Escalation to a
    human agent is required."
}`
</script>

<CodeBlockSlide
  title="process_refund: business-rule violation"
  lang="json"
  :code="good_error"
  annotation="isError: true at the top — MCP's flag for 'this is a failure.' All three required fields present. description is customer-friendly."
/>

<!--
Here's what a good error looks like. process_refund, business-rule violation. The full JSON response. isError: true at the top — MCP's flag for "this is a failure." errorCategory: "business". isRetryable: false. description: "Refund amount of $750 exceeds the $500 per-transaction limit. Escalation to a human agent is required." That description is customer-friendly. It tells the agent what happened, tells the agent retry won't help, and gives it a string suitable for surfacing to the user. All three fields. One structured object.
-->

---

<AntiPatternSlide
  title="Uniform 'Operation failed' vs structured"
  badExample='{ "error": "Operation failed" }'
  whyItFails="No category. No retry signal. No customer-friendly description. Agent has no basis for any decision."
  fixExample='{
  "isError": true,
  "errorCategory": "business",
  "isRetryable": false,
  "description": "Refund exceeds $500 limit; escalation required."
}'
  lang="json"
/>

<!--
Compare that to the bad version. On the left: {"error": "Operation failed"}. Two words. No category. No retry signal. No customer-friendly description. The agent has no basis for any decision. On the right: the structured response we just wrote — isError: true, errorCategory: "business", isRetryable: false, description with the dollar amounts. Same backend outcome. Radically different agent behavior.
-->

---

<CalloutBox variant="warn" title="MCP-specific: isError: true">

<code>isError: true</code> is how MCP signals failure to the agent at the protocol level. Without it, the response looks successful — the agent reads the content and proceeds. That's the silent-failure trap. Not optional. Pairs with the three fields — think of it as the envelope.

</CalloutBox>

<!--
One MCP-specific thing worth calling out. The isError: true flag. That's how MCP signals failure back to the agent at the protocol level. Without it, the response looks successful — the agent reads the content and proceeds. That's the silent-failure trap. Your tool thinks it errored, the protocol thinks it succeeded, and the agent acts on garbage. isError: true is not optional. It pairs with the three fields. Think of it as the envelope that carries the structured error.
-->

---

<CalloutBox variant="tip" title="Domain 2 trap: 2-of-3 fields">

Distractors include responses with two of the three fields — category + retry, no description; description + category, no retry. Each looks reasonable. The correct answer names <strong>all three</strong>. Miss one → pick the almost-right answer.

</CalloutBox>

<!--
Here's the Domain 2 distractor pattern, and it's a mean one. Answer choices will include responses with two of the three fields. A category and a retry boolean, but no description. A description and a category, but no retry boolean. Each one looks reasonable in isolation. The correct answer names all three. Miss one and you pick the almost-right answer. Remember what 1.1 said — "every tool error needs three fields — errorCategory, isRetryable, and a human-readable description. Miss one of those and you'll pick a distractor that looks almost right but isn't." That was setup for this exact moment.
-->

---

<BigNumber
  number="3"
  unit=" fields"
  caption="Memorize them. This shows up across Scenarios 1 and 3."
  detail="Scenario 1 lives or dies on retry-vs-escalate. Scenario 3 lives or dies on partial-results propagation."
/>

<!--
Three. That's the number. Three fields, appearing across Scenarios 1 and 3 on the exam. Customer support and multi-agent research both depend on this structure. Scenario 1 lives or dies on the retry-versus-escalate decision — business errors must not retry. Scenario 3 lives or dies on partial-results propagation — transient errors from a subagent need to carry context the coordinator can act on. That's next lecture, but it all rides on these three fields being present.
-->

---

<CalloutBox variant="tip" title="Path A/B/C reminder — the almost-right trap">

Structured errors with 2-of-3 fields look almost identical to structured errors with 3-of-3 fields at a glance. <strong>Count the fields.</strong> Category, retry, description. All three, or it's the wrong answer.

</CalloutBox>

<!--
One more continuity hook before we close. This is the exact trap Lecture 1.1 warned you about. "Almost-right is the whole trap of this exam." Structured errors with 2-of-3 fields look almost identical to structured errors with 3-of-3 fields — at a glance, same vibe, same JSON-ness. The distractor is plausible in a different context. Your job on exam day is to count the fields. Category, retry, description. All three, or it's the wrong answer.
-->

---

<div class="di-close">
  <div class="di-close__inner">
    <div class="di-close__eyebrow">Next up</div>
    <h1 class="di-close__title">4.6 — <span class="di-close__accent">Four Error Categories, Four Recovery Paths</span></h1>
    <div class="di-close__subtitle">Transient, validation, business, permission.</div>
  </div>
</div>

<style scoped>
.di-close { position: absolute; inset: 0; background: var(--mint-100); color: var(--forest-800); }
.di-close__inner { padding: 110px 120px 96px; height: 100%; display: flex; flex-direction: column; justify-content: center; }
.di-close__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.14em; text-transform: uppercase; color: var(--teal-500); margin-bottom: 36px; }
.di-close__title { font-family: var(--font-display); font-weight: 500; font-size: 84px; line-height: 1.05; letter-spacing: -0.02em; color: var(--forest-900); margin: 0; max-width: 1600px; }
.di-close__accent { color: var(--sprout-600); }
.di-close__subtitle { font-family: var(--font-display); font-size: 38px; color: var(--forest-500); margin-top: 32px; font-weight: 400; }
</style>

<!--
Next up, Lecture 4.6 — the four error categories and the recovery path each one implies. Transient, validation, business, permission. See you there.
-->

---

<!-- LECTURE 4.6 — Transient vs Validation vs Business vs Permission Errors -->

<div class="di-cover">
  <div class="di-cover__inner">
    <div class="di-cover__eyebrow">Domain 2 · Lecture 4.6</div>
    <h1 class="di-cover__title">Four Error Categories,<br/><span class="di-cover__accent">Four Recovery Paths</span></h1>
    <div class="di-cover__subtitle">Transient · Validation · Business · Permission</div>
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
Four categories. Four recovery paths. One exam lecture. Last time I told you errorCategory was the first of the three fields. This lecture is what actually goes into it. Transient, validation, business, permission. Each one maps to a different move by the agent. Wrong category, wrong move. Let's go.
-->

---

<ConceptHero
  leadLine="Category drives recovery"
  concept="errorCategory → next action."
  supportLine="Wrong category → wrong recovery → wasted tokens or stuck user."
/>

<!--
Category drives recovery. That's the anchor concept for this lecture. The agent reads errorCategory, and from that one field it picks its next action — retry, reformat and retry, escalate, or run a prerequisite. If the category is wrong, the recovery is wrong. Wasted tokens on retries that can't succeed. Or worse — a user stuck on an error the agent could have fixed, because the agent thought it was permanent.
-->

---

<CalloutBox variant="tip" title="Transient · isRetryable: true">

Timeouts, 503s, rate-limits. Anything that failed for a reason that might not be true a moment later.
<br/><br/>
<strong>Example:</strong> <code>lookup_order</code> timed out against the orders backend. Retry with exponential backoff — three attempts, doubling delay. If they succeed, the user never sees the blip. The <em>only</em> category where blind retry is close to correct.

</CalloutBox>

<!--
Category one. Transient. Timeouts, 503 responses, rate-limits — anything that failed for a reason that might not be true a moment later. isRetryable: true. Example from Scenario 1: lookup_order timed out while hitting the orders backend. Category transient. Agent retries with backoff — three attempts, doubling delay, done. If the retries succeed, the user never sees the blip. This is the category where retry is the right move — the only category where blind retry is even close to correct. Anywhere else, retry is either wasted tokens or an infinite loop.
-->

---

<CalloutBox variant="warn" title="Validation · isRetryable: sometimes">

Bad input format. Backend says "I can't accept this." Retryable <em>only</em> if the agent can reformat.
<br/><br/>
<strong>Example:</strong> agent called <code>lookup_order</code> with <code>"7/3/26"</code>; tool expected ISO <code>"2026-07-03"</code>. Reformat and retry. If the agent can't — ambiguous user input — ask the user. Conditionally retryable. Description field says which.

</CalloutBox>

<!--
Category two. Validation. Bad input format. The backend says "I can't accept this." isRetryable: true — but only if the agent can reformat. Example: the agent called lookup_order with "7/3/26" and the tool expected ISO date format "2026-07-03". The tool returns a validation error. The agent reformats and retries. If the agent can't reformat — maybe the user gave ambiguous input — it needs to ask the user, not retry. So validation is conditionally retryable. Your description field should say which.
-->

---

<CalloutBox variant="dont" title="Business · isRetryable: false">

Policy violation. Request is syntactically fine — just not allowed by business rules.
<br/><br/>
<strong>Example:</strong> refund for $750, tool's limit is $500. No amount of retry changes the policy. Escalate or explain. Mark this transient and you get an infinite loop on a hard stop — five identical failing refund attempts. Bad bot.

</CalloutBox>

<!--
Category three. Business. Policy violation. The request is syntactically fine, the backend can handle it — it's just not allowed by business rules. isRetryable: false. Example from Scenario 1 again: the refund is for $750, but the tool's limit is $500. That's not going to fix itself. No amount of retry changes the policy. The right move is escalate or explain — route to escalate_to_human, or tell the user why the operation can't complete and what they can do instead. If you mark this as transient and retry, you get an infinite loop on a hard stop, five identical failing refund attempts, and a customer watching a bot fail in real time. Bad bot.
-->

---

<CalloutBox variant="dont" title="Permission · isRetryable: false (at this moment)">

Missing auth / scope / prerequisite. Sometimes retryable <em>after</em> running a prereq.
<br/><br/>
<strong>Example:</strong> agent tried <code>process_refund</code> without a prior <code>get_customer</code> verification. Next move: run the prereq, <em>then</em> try again. Conditional retry after the prereq clears — not a simple retry. Know the difference.

</CalloutBox>

<!--
Category four. Permission. Missing authentication, missing scope, missing prerequisite. isRetryable: false at this moment, but sometimes retryable after running a prereq. Example from Scenario 1 again: the agent tried to call process_refund without first running get_customer. The customer isn't verified yet. Category permission. The agent's next move is to run the prerequisite — get_customer — and then try again. Not a simple retry. A conditional retry after the prereq clears. Know the difference.
-->

---

<script setup>
const recovery_columns = ['isRetryable', 'Recovery path']
const recovery_rows = [
  {
    label: 'Transient',
    cells: [
      { text: 'true', highlight: 'good' },
      { text: 'Retry with backoff', highlight: 'good' },
    ],
  },
  {
    label: 'Validation',
    cells: [
      { text: 'sometimes', highlight: 'neutral' },
      { text: 'Reformat + retry, or ask the user', highlight: 'neutral' },
    ],
  },
  {
    label: 'Business',
    cells: [
      { text: 'false', highlight: 'bad' },
      { text: 'Escalate or explain', highlight: 'bad' },
    ],
  },
  {
    label: 'Permission',
    cells: [
      { text: 'false', highlight: 'bad' },
      { text: 'Run prerequisite or escalate', highlight: 'bad' },
    ],
  },
]
</script>

<ComparisonTable
  title="Category → recovery"
  :columns="recovery_columns"
  :rows="recovery_rows"
/>

<!--
Here's the whole map in one table. Category, isRetryable, recovery path. Transient — retryable true — retry with backoff. Validation — retryable sometimes — reformat and retry, or ask the user. Business — retryable false — escalate or explain. Permission — retryable false — run prerequisite or escalate. Four rows. Learn this table. On exam day, if you can recite these four recovery paths from memory, you've banked points on every Task 2.2 question.
-->

---

<CalloutBox variant="tip" title="On the exam — the collapse trap">

Distractors <em>collapse</em> categories. Business violation treated as transient → infinite retries. Validation treated as permanent → user stuck. Permission treated as business → agent escalates instead of running the prereq. Know the four, catch the distractor.

</CalloutBox>

<!--
Here's the Domain 2 distractor pattern for this lecture. Answer choices will collapse categories. Treating a business violation as transient — infinite retries on a refund that exceeds limits. Treating a validation error as permanent — user stuck when a reformat would have fixed it. Treating a permission issue as business — agent escalates when it should have run the prereq. Four categories, each with a wrong neighbor. Know the four and you catch the distractor every time.
-->

---

<ConceptHero
  leadLine="Scenario 1 lives or dies on this."
  concept="Same loop, same tools."
  supportLine="Different errorCategory values → radically different UX. A refund-over-limit that retries five times is a bad bot."
/>

<!--
Scenario 1 — customer support — lives or dies on this distinction. A refund-over-limit that retries five times is a bad bot. A timeout that escalates to a human on the first try is a bad bot. The difference is category. Same loop, same tools, same model — different errorCategory values produce radically different user experiences. Hold onto that phrase from 4.5: "Scenario 1 lives or dies on this."
-->

---

<div class="di-close">
  <div class="di-close__inner">
    <div class="di-close__eyebrow">Next up</div>
    <h1 class="di-close__title">4.7 — <span class="di-close__accent">Local Recovery vs Propagating to Coordinator</span></h1>
    <div class="di-close__subtitle">When the subagent handles it. When it kicks up.</div>
  </div>
</div>

<style scoped>
.di-close { position: absolute; inset: 0; background: var(--mint-100); color: var(--forest-800); }
.di-close__inner { padding: 110px 120px 96px; height: 100%; display: flex; flex-direction: column; justify-content: center; }
.di-close__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.14em; text-transform: uppercase; color: var(--teal-500); margin-bottom: 36px; }
.di-close__title { font-family: var(--font-display); font-weight: 500; font-size: 80px; line-height: 1.05; letter-spacing: -0.02em; color: var(--forest-900); margin: 0; max-width: 1600px; }
.di-close__accent { color: var(--sprout-600); }
.di-close__subtitle { font-family: var(--font-display); font-size: 38px; color: var(--forest-500); margin-top: 32px; font-weight: 400; }
</style>

<!--
Next up, Lecture 4.7 — when to heal locally inside a subagent, and when to propagate the error up to the coordinator. See you there.
-->

---

<!-- LECTURE 4.7 — Local Recovery vs Propagating to Coordinator -->

<div class="di-cover">
  <div class="di-cover__inner">
    <div class="di-cover__eyebrow">Domain 2 · Lecture 4.7</div>
    <h1 class="di-cover__title">Local Recovery vs<br/><span class="di-cover__accent">Propagating to Coordinator</span></h1>
    <div class="di-cover__subtitle">One rule. Partial results always travel with the error.</div>
  </div>
</div>

<style scoped>
.di-cover { position: absolute; inset: 0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%); color: var(--mint-100); }
.di-cover__inner { padding: 110px 120px 96px; height: 100%; display: flex; flex-direction: column; justify-content: center; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px; }
.di-cover__title { font-family: var(--font-display); font-weight: 500; font-size: 104px; line-height: 1.05; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1600px; }
.di-cover__accent { color: var(--sprout-500); }
.di-cover__subtitle { font-family: var(--font-display); font-size: 40px; color: var(--mint-200); margin-top: 40px; font-weight: 400; }
</style>

<!--
Something broke in a subagent. Should the subagent handle it, or kick it up? That's the whole question of this lecture. Seven minutes. One decision rule. And the exam's favorite example — the web-search timeout from Scenario 3.
-->

---

<BigQuote quote="Should this subagent handle it, or kick it up?" />

<!--
"Should this subagent handle it, or kick it up?" Every error in a multi-agent system forces that decision. Get it right and you get fast, cheap recovery. Get it wrong in either direction and you either blow up the coordinator's context with every transient blip, or you swallow real failures that the coordinator needed to see.
-->

---

<ConceptHero
  leadLine="Default: heal where you can."
  concept="Subagents recover transient + validation locally."
  supportLine="Business + permission always propagate — the coordinator decides."
/>

<!--
Here's the rule. Default: heal where you can. Subagents recover transient and validation errors locally. Business and permission errors always propagate — the coordinator decides. That's the cut line. Map it back to the four categories from 4.6 and the rule falls out naturally. Transient and validation are things a subagent can retry or reformat without coordinator approval — they're mechanical recoveries. Business and permission are decisions above the subagent's pay grade — policy calls, auth decisions. The coordinator needs to see those to pick the next move.
-->

---

<script setup>
const local_recovery_code = `# Inside the search subagent
for attempt in range(3):
    try:
        result = web_search(query)
        return result  # Success -- coordinator never knew
    except TransientError as e:
        time.sleep(2 ** attempt)  # exponential backoff

# Exhausted retries -- compose structured error for coordinator
return propagate_to_coordinator(
    failure_type="transient",
    attempted_query=query,
    partial_results=results_so_far,
    alternatives=["narrow the topic", "try different sources"],
)`
</script>

<CodeBlockSlide
  title="Retry with backoff inside the subagent"
  lang="python"
  :code="local_recovery_code"
  annotation="Transient blips absorbed locally. Sustained failures propagate with structured context."
/>

<!--
Here's what local recovery looks like inside a subagent. Pseudocode. You wrap the tool call in a retry loop with exponential backoff. Three attempts, doubling delay, cap at thirty seconds. On success, return the result — the coordinator never knew anything happened. On exhausted retries, you stop retrying and you start composing a structured error. Because now the coordinator does need to know. Local recovery isn't hiding the failure — it's absorbing the noise. Transient blips shouldn't reach the coordinator. Sustained failures absolutely should. That's the line.
-->

---

<script setup>
const propagation_code = `{
  "isError": true,
  "failure_type": "transient_timeout",
  "attempted_query": "effects of sleep deprivation on cognitive performance",
  "partial_results": [
    {"title": "Sleep and Memory Consolidation", "url": "..."},
    {"title": "Attention and Sleep Debt",    "url": "..."},
    {"title": "Decision-Making under Sleep Loss", "url": "..."}
  ],
  "alternatives": [
    "Narrow to 'short-term sleep deprivation'",
    "Try alternative source set: PubMed only"
  ]
}`
</script>

<CodeBlockSlide
  title="Structured error → coordinator"
  lang="json"
  :code="propagation_code"
  annotation="Four fields: failure_type, attempted_query, partial_results, alternatives. Sample Q8's correct answer, word-for-word."
/>

<!--
Here's the propagation pattern. Structured JSON going back to the coordinator. Four things in it. Failure type — what category of error, mapped to the categories from 4.6. Attempted query — what the subagent actually tried, so the coordinator knows what to retry differently. Partial results — whatever came back before the failure, because even partial data can feed downstream. And alternatives — suggested next moves the subagent can see from its position, like "consider narrowing the topic" or "try a different source set." That shape is the exact correct answer to Sample Question 8 from the exam guide. Memorize those four elements: failure type, attempted query, partial results, alternatives.
-->

---

<CalloutBox variant="tip" title="Always include what you got">

Even on failure, send the coordinator the partial data. If web-search found three articles before the fourth query timed out, those three go with the error. Difference between <em>"search unavailable"</em> — useless — and <em>actionable recovery context</em>.

</CalloutBox>

<!--
One thing worth its own slide — always include the partial results. Even on failure, send the coordinator what you managed to retrieve. If the web-search subagent found three articles before the fourth query timed out, those three articles go to the coordinator with the error. That's the difference between a generic "search unavailable" — useless — and actionable recovery context — "here's what I got, here's what I missed, here's why, here's what you could try instead." The coordinator can use that. It can re-invoke a narrowed search. It can proceed with partial findings if they're enough. It can decide this topic is too thin and escalate to the user. It can't do any of that on "search unavailable."
-->

---

<script setup>
const antipattern_bad_47 = `Propagate everything: coordinator context fills with noise, makes worse decisions.

Swallow everything: local try-catch, return empty, pretend success. Coordinator synthesizes a report with missing sections.`

const antipattern_fix_47 = `Heal transient + validation locally.
Propagate structured business + permission with partial results.
The middle path is the only one that works.`
</script>

<AntiPatternSlide
  title="Two ways to get this wrong"
  :badExample="antipattern_bad_47"
  whyItFails="Both ends of the spectrum fail for different reasons."
  :fixExample="antipattern_fix_47"
  lang="text"
/>

<!--
Two ways to get this wrong. On the left — propagate everything. Every transient blip, every 503, every brief timeout goes up to the coordinator. The coordinator's context fills with noise. It makes worse decisions because its window is full of noise. On the right — swallow everything. Local try-catch, return empty, pretend success. The coordinator never learns the search failed. It synthesizes a report with missing sections. Both are failures. The middle path — heal transient locally, propagate structured business and permission with partials — is the only one that works.
-->

---

<CalloutBox variant="tip" title="Sample Q8 echo">

Web-search subagent times out on a complex topic. Correct answer A:
<br/><br/>
<strong>"Return structured error context to the coordinator including the failure type, the attempted query, any partial results, and potential alternative approaches."</strong>
<br/><br/>
Distractors: generic "search unavailable", empty result marked as success, propagate-and-terminate. Each is one of the anti-patterns.

</CalloutBox>

<!--
Sample Question 8 from the exam guide. The web search subagent times out on a complex topic. The correct answer — A — is "return structured error context to the coordinator including the failure type, the attempted query, any partial results, and potential alternative approaches." That's the propagation pattern from slide 5, word for word. The distractors: generic "search unavailable," empty result marked as success, propagate to a top-level handler and terminate. Each distractor is one of the anti-patterns we just named. Scenario 3 relies on this exact pattern.
-->

---

<div class="di-close">
  <div class="di-close__inner">
    <div class="di-close__eyebrow">Next up</div>
    <h1 class="di-close__title">4.8 — <span class="di-close__accent">How Many Tools Per Agent?</span></h1>
    <div class="di-close__subtitle">Four to five. Eighteen breaks things.</div>
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
Next up, Lecture 4.8 — how many tools per agent. Four to five. Eighteen breaks things. See you there.
-->

---

<!-- LECTURE 4.8 — Tool Distribution: How Many Tools Per Agent? -->

<div class="di-cover">
  <div class="di-cover__inner">
    <div class="di-cover__eyebrow">Domain 2 · Lecture 4.8</div>
    <h1 class="di-cover__title">How Many <span class="di-cover__accent">Tools Per Agent?</span></h1>
    <div class="di-cover__subtitle">Four to five. Eighteen breaks things.</div>
  </div>
</div>

<style scoped>
.di-cover { position: absolute; inset: 0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%); color: var(--mint-100); }
.di-cover__inner { padding: 110px 120px 96px; height: 100%; display: flex; flex-direction: column; justify-content: center; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px; }
.di-cover__title { font-family: var(--font-display); font-weight: 500; font-size: 128px; line-height: 1.05; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1600px; }
.di-cover__accent { color: var(--sprout-500); }
.di-cover__subtitle { font-family: var(--font-display); font-size: 40px; color: var(--mint-200); margin-top: 40px; font-weight: 400; }
</style>

<!--
Four to five tools per agent. That's the ceiling. Past it, selection reliability degrades sharply. This lecture explains why, what scoped tool access looks like in practice, and the one exception the exam tests explicitly.
-->

---

<BigNumber
  number="4–5"
  unit=" tools per agent"
  caption="Selection reliability stays high in that range. Drops off fast past it."
  detail="18 tools on one agent — the number the exam guide cites — produces selection failures even with well-written descriptions."
/>

<!--
Four to five. That's the number. Selection reliability stays high in that range and drops off fast past it. Eighteen tools on one agent, the number the exam guide explicitly cites, produces selection failures even with well-written descriptions. The lever from 4.1 — prose differentiation — only goes so far. Past a handful of tools, you run out of room to differentiate them all against each other.
-->

---

<ConceptHero
  leadLine="Tool selection is a decision"
  concept="Each extra tool = another 'not this one.'"
  supportLine="18 tools ≠ 18× capability. It's 18× selection overhead. The math isn't linear — it compounds with weak descriptions."
/>

<!--
Here's why. Tool selection is a decision, and each extra tool adds another "not this one" the model has to reason through. Eighteen tools is not eighteen times the capability — it's eighteen times the selection overhead. Claude isn't picking the right tool from a menu; it's ruling out every wrong tool on the way to the right one. More tools, more wrong tools to rule out, more chances to get it wrong. The math isn't linear. It's worse. And it compounds with weak descriptions from Lecture 4.1 — add bad descriptions to a big tool set and the misroute rate doesn't just add, it multiplies.
-->

---

<script setup>
const antipattern_bad_48 = `Synthesis agent with web_search, load_document, and every other search tool attached.

Agent's job: combining findings. But now it runs web searches on its own. Uses tools outside its role.`

const antipattern_fix_48 = `Scope tools to role.
Cross-role work routes through the coordinator.
Synthesis gets one narrow tool (verify_fact) for the common case.`
</script>

<AntiPatternSlide
  title="Dump every tool onto one agent"
  :badExample="antipattern_bad_48"
  whyItFails="Agent uses tools outside its role, because they're right there in the toolbelt."
  :fixExample="antipattern_fix_48"
  lang="text"
/>

<!--
Anti-pattern. Dump every tool onto one agent. The exam's canonical example: a synthesis agent that has web-search tools attached to it. Now the synthesis agent — whose job is combining findings — starts running web searches on its own. It's using tools outside its role, because they're right there in its toolbelt. The right pattern: scope tools to role. If synthesis needs web data, it routes through the coordinator, which delegates to the search subagent. Cross-role work runs through the coordinator.
-->

---

<script setup>
const distribution_bullets = [
  { label: 'Coordinator', detail: 'Task + a few policy/routing tools. Three, maybe four.' },
  { label: 'Search subagent', detail: 'web_search, load_document. Two tools, tightly scoped.' },
  { label: 'Synthesis subagent', detail: 'verify_fact only -- narrow cross-role for the 85% case.' },
  { label: 'Everything else', detail: 'Routes through the coordinator.' },
]
</script>

<BulletReveal
  title="The right distribution"
  :bullets="distribution_bullets"
/>

<!--
Here's what scoped distribution looks like. Coordinator — gets the Task tool for spawning subagents, plus a few policy or routing tools. Three, maybe four. Search subagent — web_search, load_document. That's it. Two tools, tightly scoped. Synthesis subagent — verify_fact only, and we'll come back to why it has even that. Everything else routes through the coordinator. Each agent has a small, purpose-fit toolbelt. Nothing it can misuse. Nothing extraneous that dilutes its selection decisions. Each subagent is effectively specialized by its tool set.
-->

---

<CalloutBox variant="tip" title="Sample Q9 — scoped cross-role exception">

Synthesis verifies claims — dates, names, stats — in 85% of cases on simple lookups. Round-tripping through the coordinator adds 40% latency.
<br/><br/>
<strong>Correct answer:</strong> narrow <code>verify_fact</code> on synthesis for the 85% common case. Route the 15% complex cases through the coordinator. Principle of least privilege with a targeted exception.

</CalloutBox>

<!--
Now the exception, and this is Sample Question 9 from the exam guide, almost word-for-word. Synthesis needs to verify specific claims — dates, names, statistics — and the data says it does this eighty-five percent of the time on simple lookups. If every verification round-trips through the coordinator, latency climbs forty percent. The right answer isn't "give synthesis all the web search tools" — that's the anti-pattern from slide 4, the exact distractor the question tests. The right answer is a narrow, scoped verify_fact tool on synthesis for the eighty-five-percent common case, and route the fifteen-percent complex cases through the coordinator. Principle of least privilege with a targeted exception. Scope tightly. Exception narrowly. That's the pattern.
-->

---

<CalloutBox variant="tip" title="On the exam — 'more tools' is the distractor">

<strong>"Give the agent more tools"</strong> → almost always wrong.<br/>
<strong>"Consolidate into one mega-tool"</strong> → almost always wrong.<br/>
<strong>"Scope tools + narrow cross-role tool for the frequent need"</strong> → almost always correct.

</CalloutBox>

<!--
Here's the exam move. "Give the agent more tools" is almost always a distractor. "Give the agent access to every search tool" — wrong. "Consolidate into one mega-tool" — wrong. Both options miss the principle of least privilege that the exam rewards. The correct answer usually scopes the tools to the role and, when latency or round-trip cost demands it, adds a narrow cross-role tool for the frequent need. Scoped plus a narrow exception. That's the pattern. Remember the scoping pattern cold — Scenario 3 leans on it hard, and remember the six-pick-four from 1.1: you don't know which four scenarios will appear, so skipping Scenario 3's tool distribution isn't an option.
-->

---

<ConceptHero
  leadLine="Six-pick-four reminder"
  concept="Low effort. High payoff. Bank it."
  supportLine="Know 4–5 as the ceiling. Know scoped-plus-narrow-exception. Know 'more tools' is a distractor. That's a real share of your exam."
/>

<!--
One more framing before we close. Domain 2 is eighteen percent. Task 2.3 — tool distribution — is a chunk of that. And Scenario 3's questions almost always touch distribution in some way. If you walk in knowing four-to-five is the ceiling, knowing the scoped-plus-narrow-exception pattern, and knowing that "give the agent more tools" is a distractor signal — you've covered a real share of your exam. Low effort, high payoff. Bank it.
-->

---

<div class="di-close">
  <div class="di-close__inner">
    <div class="di-close__eyebrow">Next up</div>
    <h1 class="di-close__title">4.9 — <span class="di-close__accent">tool_choice: auto, any, Forced</span></h1>
    <div class="di-close__subtitle">Three modes. Three guarantees.</div>
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
Next up, Lecture 4.9 — tool_choice. Three modes. Each guarantees something different. See you there.
-->

---

<!-- LECTURE 4.9 — tool_choice: auto, any, Forced Selection -->

<div class="di-cover">
  <div class="di-cover__inner">
    <div class="di-cover__eyebrow">Domain 2 · Lecture 4.9</div>
    <h1 class="di-cover__title"><span class="di-cover__mono">tool_choice</span> —<br/><span class="di-cover__accent">auto, any, Forced</span></h1>
    <div class="di-cover__subtitle">Three modes. Three guarantees.</div>
  </div>
</div>

<style scoped>
.di-cover { position: absolute; inset: 0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%); color: var(--mint-100); }
.di-cover__inner { padding: 110px 120px 96px; height: 100%; display: flex; flex-direction: column; justify-content: center; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px; }
.di-cover__title { font-family: var(--font-display); font-weight: 500; font-size: 110px; line-height: 1.05; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1600px; }
.di-cover__mono { font-family: var(--font-mono); color: var(--sprout-500); }
.di-cover__accent { color: var(--sprout-500); }
.di-cover__subtitle { font-family: var(--font-display); font-size: 40px; color: var(--mint-200); margin-top: 40px; font-weight: 400; }
</style>

<!--
Three modes. Three guarantees. auto guarantees nothing. any guarantees a tool is called. Forced guarantees a specific tool is called. This lecture is about knowing which guarantee you need, and reaching for the matching mode.
-->

---

<script setup>
const mode_columns = ['Guarantees', 'Use when']
const mode_rows = [
  {
    label: 'auto',
    cells: [
      { text: 'Claude decides text or tool', highlight: 'neutral' },
      { text: 'Default; conversational agents', highlight: 'neutral' },
    ],
  },
  {
    label: 'any',
    cells: [
      { text: 'A tool IS called', highlight: 'good' },
      { text: 'Structured output; multiple schemas', highlight: 'good' },
    ],
  },
  {
    label: '{type:"tool",name:X}',
    cells: [
      { text: 'Specific tool X is called', highlight: 'good' },
      { text: 'Force ordering -- metadata before enrichment', highlight: 'good' },
    ],
  },
]
</script>

<ComparisonTable
  title="tool_choice options"
  :columns="mode_columns"
  :rows="mode_rows"
/>

<!--
Here's the table. Three rows. auto — Claude decides whether to call a tool or return text. That's the default. Use it for conversational agents where sometimes a reply is the right move and sometimes a tool call is. any — a tool is called. Claude picks which one from your set. Use it for structured output or when you're choosing among multiple schemas. Forced — {type: "tool", name: "X"} — specific tool X is called. Use it to force ordering. Those three modes cover every real case.
-->

---

<script setup>
const auto_code = `{
  "tool_choice": { "type": "auto" }
}
// Claude may return text.
// Claude may return a tool_use block.
// It decides based on the conversation.`
</script>

<CodeBlockSlide
  title="auto — the default"
  lang="json"
  :code="auto_code"
  annotation="Conversational agents. Half the turns are text, half are tool calls — Claude decides."
/>

<!--
Mode one. auto. This is what you get if you don't pass tool_choice at all. Claude may return text, Claude may call a tool — it decides based on the conversation and what the user actually needs. Perfect for a conversational agent where half the time the answer is "here's your refund status, processing now" — text — and half the time it's a tool call to look the order up. The trade-off: auto gives you no guarantee of any particular output shape. That matters when you're downstream of structured output, or when your pipeline assumes a tool call on every turn. For those cases, auto is the wrong mode.
-->

---

<script setup>
const any_code = `{
  "tool_choice": { "type": "any" },
  "tools": [extract_invoice, extract_receipt, extract_po]
}
// Claude MUST call a tool.
// Picks the matching schema per document.`
</script>

<CodeBlockSlide
  title="any — guaranteed tool use"
  lang="json"
  :code="any_code"
  annotation="Scenario 6 pattern — extract from varied documents. Claude picks the right schema per doc."
/>

<!--
Mode two. any. The model must call a tool. It picks which one from your set, but it can't skip straight to text. This is the mode you reach for when you need structured output and you have multiple schemas to choose between. Scenario 6 pattern — you're extracting from a hundred documents, and each doc might be an invoice or a receipt or a purchase order. You register three extraction tools, one per schema. Set tool_choice: any. Claude reads the doc, picks the right schema, returns a tool call. Always a tool call. Never conversational text.
-->

---

<script setup>
const forced_code = `{
  "tool_choice": { "type": "tool", "name": "extract_metadata" }
}
// Guarantees extract_metadata runs first, every time.
// Subsequent turns can use auto or any.`
</script>

<CodeBlockSlide
  title="Forced — exact tool"
  lang="json"
  :code="forced_code"
  annotation="Force-first, free after. Metadata runs every time, then auto/any for subsequent enrichment."
/>

<!--
Mode three. Forced. The JSON looks like {"type": "tool", "name": "extract_metadata"}. This guarantees that exact tool runs, every time, on the current turn. Use case: you want extract_metadata to run first on every document, before any enrichment or follow-up calls. Forced selection is how you order operations when the ordering matters. The exam guide calls this out explicitly in Task 2.3 — forcing a specific tool to guarantee ordering, then handling subsequent steps in follow-up turns with auto or any. Force first, free up the model after.
-->

---

<CalloutBox variant="warn" title="Domain 2 + Domain 4 overlap">

Most reliable way to get schema-compliant JSON: define your schema as a tool's input, set <code>tool_choice: any</code>, extract the arguments from the tool-use response.
<br/><br/>
No JSON parsing fragility. No "please output valid JSON" in the prompt. Schema enforcement comes from the tool-use protocol.

</CalloutBox>

<!--
Here's where Domain 2 and Domain 4 shake hands, and the exam tests it. Structured output via tool use. The most reliable way to get schema-compliant JSON from Claude is to define your schema as a tool's input, set tool_choice: any so Claude is forced to call it, and extract the arguments from the tool-use response. No JSON parsing fragility. No "please output valid JSON" in the system prompt. No regex wrangling on malformed output. Schema enforcement comes from the tool-use protocol, not from prompting. Task 4.3 tests this directly — we'll come back to it in Section 6, but the tool_choice: any lever is how Domain 2 contributes to reliable structured output. That's the cleanest way to do it.
-->

---

<CalloutBox variant="tip" title="Scenario 6 pattern — concrete">

Batch-processing 100 varied documents — invoices, receipts, purchase orders.
<br/><br/>
Define <code>extract_invoice</code>, <code>extract_receipt</code>, <code>extract_po</code> — three tools, three JSON schemas. Set <code>tool_choice: any</code>. Claude picks the right extraction tool per doc, always returns a tool call. Structured data every time.

</CalloutBox>

<!--
Concrete. Scenario 6. Batch-processing a hundred varied documents. Mixed types — some invoices, some receipts, some purchase orders. You define extract_invoice, extract_receipt, extract_po — three tools, three JSON schemas. You set tool_choice: any. For each document, Claude picks the right extraction tool per doc and always returns a tool call. You get structured data every time, matched to the doc type, no wasted calls on conversational filler. This is the structured-extraction pattern the exam tests.
-->

---

<script setup>
const antipattern_bad_49 = `tool_choice: { type: "tool", name: "extract_v1" }

Feed in a receipt: Claude still runs extract_v1 -- on a receipt, against an invoice schema. Garbage out.`

const antipattern_fix_49 = `Offer three schemas: extract_invoice, extract_receipt, extract_po.
Set tool_choice: { type: "any" }.
Let Claude pick per doc. Schema-compliant every time.`
</script>

<AntiPatternSlide
  title="Don't force a specific tool for multi-schema output"
  :badExample="antipattern_bad_49"
  whyItFails="Force is for ordering a single specific tool. Mismatched schema = garbage."
  :fixExample="antipattern_fix_49"
  lang="text"
/>

<!--
Anti-pattern. Forcing a specific tool when you want structured output across multiple schemas. If you set tool_choice: {type: "tool", name: "extract_v1"} and feed in a receipt, Claude still runs extract_v1 — on a receipt, against an invoice schema. Garbage out. The right move: offer the three schemas, set any, let Claude pick per doc. Force is for ordering a single specific tool. any is for guaranteeing something gets called when the choice depends on the input. Don't mix them up.
-->

---

<div class="di-close">
  <div class="di-close__inner">
    <div class="di-close__eyebrow">Next up</div>
    <h1 class="di-close__title">4.10 — <span class="di-close__accent">MCP Server Scopes</span></h1>
    <div class="di-close__subtitle">Project vs user. Two locations, two purposes.</div>
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
Next up, Lecture 4.10 — MCP server scoping. Project versus user. Two locations, two purposes. See you there.
-->

---

<!-- LECTURE 4.10 — MCP Server Configuration: Project vs User Scope -->

<div class="di-cover">
  <div class="di-cover__inner">
    <div class="di-cover__eyebrow">Domain 2 · Lecture 4.10</div>
    <h1 class="di-cover__title">MCP <span class="di-cover__accent">Server Scopes</span></h1>
    <div class="di-cover__subtitle">Two locations. Two purposes. One onboarding bug.</div>
  </div>
</div>

<style scoped>
.di-cover { position: absolute; inset: 0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%); color: var(--mint-100); }
.di-cover__inner { padding: 110px 120px 96px; height: 100%; display: flex; flex-direction: column; justify-content: center; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px; }
.di-cover__title { font-family: var(--font-display); font-weight: 500; font-size: 128px; line-height: 1.05; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1600px; }
.di-cover__accent { color: var(--sprout-500); }
.di-cover__subtitle { font-family: var(--font-display); font-size: 38px; color: var(--mint-200); margin-top: 40px; font-weight: 400; }
</style>

<!--
Two locations. Two purposes. Get them mixed up and a new team member silently has fewer tools than you do. This lecture is short, but the question it answers is one of the highest-frequency onboarding bugs in Claude Code. Know it cold.
-->

---

<TwoColSlide
  title="Two locations"
  leftLabel=".mcp.json (project)"
  rightLabel="~/.claude.json (user)"
>
  <template #left>
    <div style="font-family: var(--font-body); font-size: 24px; line-height: 1.55;">
      Shared via version control. Committed to the repo. Everyone who clones gets it automatically.
      <br/><br/>
      <strong>Team's Jira. Company's internal MCP. Shared GitHub.</strong>
    </div>
  </template>
  <template #right>
    <div style="font-family: var(--font-body); font-size: 24px; line-height: 1.55;">
      Personal. In your home directory. Not shared. Never ships to the repo or CI.
      <br/><br/>
      <strong>Experimental servers. Personal utilities. Local prototypes.</strong>
    </div>
  </template>
</TwoColSlide>

<!--
Here are the two. On the left — .mcp.json at your project root. Shared via version control. Committed to the repo. Everyone who clones gets it automatically the next time they launch Claude Code. On the right — ~/.claude.json in your home directory. Personal. Not shared. Only you see it. Never ships to the repo, never touches CI, never touches your teammates' machines. Two files, two scopes. The distinction looks trivial until it bites somebody three weeks into a new hire's onboarding.
-->

---

<ConceptHero
  leadLine="Where does this server belong?"
  concept="Team uses it? Project. You alone? User."
  supportLine="Get this wrong — new hires silently lack tools, CI silently fails, only your machine works."
/>

<!--
Here's the decision rule. Where does this server belong? If the team uses it, it goes in project scope — .mcp.json. If it's you alone, user scope — ~/.claude.json. That's the whole rule. One question to ask. The team's Jira server, the company's internal MCP, the shared GitHub integration — project. Your experimental local server, your personal productivity tool, your homegrown prototype — user. Get this wrong and new hires silently lack tools, CI silently fails, and you silently wonder why it only works on your machine. Classic scope-confusion bug.
-->

---

<script setup>
const project_code = `// .mcp.json at project root -- committed to repo
{
  "mcpServers": {
    "company-jira": {
      "command": "uvx",
      "args": ["mcp-server-jira", "--url", "https://company.atlassian.net"]
    },
    "internal-docs": {
      "command": "node",
      "args": ["./tools/internal-docs-mcp/server.js"]
    }
  }
}`
</script>

<CodeBlockSlide
  title=".mcp.json — checked into the repo"
  lang="json"
  :code="project_code"
  annotation="Version-controlled. Reviewable in PRs. Reproducible. Config travels with the codebase."
/>

<!--
Here's a project-scoped .mcp.json. Checked into the repo. Contains the team's Jira server, the company's internal-docs MCP, a shared GitHub server. Everyone on the team gets these automatically when they clone. This is how you make MCP servers part of the team's toolchain — not something each developer has to install and configure separately. Version-controlled. Reviewable in PRs. Reproducible. If someone adds a new shared server, it ships in the same commit as the code that depends on it. That's the whole point of project scope — config travels with the codebase.
-->

---

<script setup>
const user_code = `// ~/.claude.json -- personal, never committed
{
  "mcpServers": {
    "local-prototype": {
      "command": "python",
      "args": ["/Users/me/dev/experiments/my-server.py"]
    }
  }
}`
</script>

<CodeBlockSlide
  title="~/.claude.json — personal"
  lang="json"
  :code="user_code"
  annotation="Same format. Different scope. Discovered at the same time as project servers — both are available."
/>

<!--
Here's the user-scoped flavor. ~/.claude.json. Your experimental local-database MCP. A personal utility server you're prototyping. A server with your personal credentials that you don't want to foist on teammates. A server that only makes sense on your specific machine setup. These stay in your home directory. They don't ship to the repo. They don't affect the team. Same server config format — totally different scope. And critically — they're discovered and loaded at the same time project-scoped servers are, so both kinds of servers are available simultaneously to the agent. Scope determines where the config lives, not whether the tools are available.
-->

---

<script setup>
const symptom_bullets = [
  { label: 'New team member', detail: '"Tool not found" -- clones the repo, launches Claude Code, missing Jira MCP.' },
  { label: 'CI build', detail: 'Same story. CI doesn\'t have your home directory.' },
  { label: 'You', detail: 'Works fine -- because you have it locally in ~/.claude.json.' },
]
</script>

<BulletReveal
  title="How you find out you got this wrong"
  :bullets="symptom_bullets"
/>

<!--
Here's how you find out you got this wrong. New team member joins, clones the repo, opens Claude Code — "tool not found" when they try to use the company's Jira MCP. Because you put the server in your ~/.claude.json instead of the project's .mcp.json. CI build — same story, missing MCP server, because CI doesn't have your home directory. And on your machine, everything works fine, because you have it locally. Those three symptoms together mean scope is wrong. The fix is one move — relocate the server config from ~/.claude.json to .mcp.json at the project root, commit it, and every teammate and every CI job picks it up.
-->

---

<CalloutBox variant="tip" title="On the exam">

"Shared team MCP server goes in <code>.mcp.json</code>." Memorize it. That's the Task 2.4 nugget.
<br/><br/>
Watch for distractors: <strong>"user-scoped <code>.mcp.json</code>"</strong> is a nonsense phrase the exam uses to catch skimmers. <code>.mcp.json</code> is always project. <code>~/.claude.json</code> is always user. No cross-over.

</CalloutBox>

<!--
Here's the exam move. "Shared team MCP server goes in .mcp.json." Memorize it. That's the Task 2.4 knowledge nugget you need. And watch for distractors — "user-scoped .mcp.json" is a nonsense phrase the exam puts in answer choices to catch skimmers who are matching on keywords instead of reading carefully. .mcp.json is always project-scoped. ~/.claude.json is always user-scoped. There's no cross-over. If an answer choice implies otherwise, it's wrong, and you now have the domain knowledge to catch it cold. One more "almost-right" distractor defused.
-->

---

<ConceptHero
  leadLine="Where Domain 2 and Domain 3 shake hands"
  concept="Tool integration in team-configured environments."
  supportLine="Scenario 2, 4, and 5 all touch this. Path B/C from 1.1 — you've probably hit this in the wild."
/>

<!--
This is where Domain 2 and Domain 3 shake hands. Scenario 2, Scenario 4, and Scenario 5 all touch Claude Code configuration for teams. The .mcp.json question is a Domain 2 item living in Domain 3 territory — tool integration inside a team-configured environment. If you took Path B or C from 1.1 — some or lots of experience — you've probably run into this bug in the wild. Lock it in, because the same pattern shows up under several scenario framings on the exam.
-->

---

<div class="di-close">
  <div class="di-close__inner">
    <div class="di-close__eyebrow">Next up</div>
    <h1 class="di-close__title">4.11 — <span class="di-close__accent">.mcp.json with Env Var Expansion</span></h1>
    <div class="di-close__subtitle">Commit the config. Don't commit the secret.</div>
  </div>
</div>

<style scoped>
.di-close { position: absolute; inset: 0; background: var(--mint-100); color: var(--forest-800); }
.di-close__inner { padding: 110px 120px 96px; height: 100%; display: flex; flex-direction: column; justify-content: center; }
.di-close__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.14em; text-transform: uppercase; color: var(--teal-500); margin-bottom: 36px; }
.di-close__title { font-family: var(--font-display); font-weight: 500; font-size: 92px; line-height: 1.05; letter-spacing: -0.02em; color: var(--forest-900); margin: 0; max-width: 1600px; }
.di-close__accent { color: var(--sprout-600); }
.di-close__subtitle { font-family: var(--font-display); font-size: 38px; color: var(--forest-500); margin-top: 32px; font-weight: 400; }
</style>

<!--
Next up, Lecture 4.11 — how to put secrets in .mcp.json without committing secrets. Environment variable expansion. See you there.
-->

---

<!-- LECTURE 4.11 — .mcp.json with Environment Variable Expansion -->

<div class="di-cover">
  <div class="di-cover__inner">
    <div class="di-cover__eyebrow">Domain 2 · Lecture 4.11</div>
    <h1 class="di-cover__title"><span class="di-cover__mono">.mcp.json</span> with<br/><span class="di-cover__accent">Environment Variable Expansion</span></h1>
    <div class="di-cover__subtitle">Commit the config. Don't commit the secret.</div>
  </div>
</div>

<style scoped>
.di-cover { position: absolute; inset: 0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%); color: var(--mint-100); }
.di-cover__inner { padding: 110px 120px 96px; height: 100%; display: flex; flex-direction: column; justify-content: center; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px; }
.di-cover__title { font-family: var(--font-display); font-weight: 500; font-size: 100px; line-height: 1.05; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1600px; }
.di-cover__mono { font-family: var(--font-mono); color: var(--sprout-500); }
.di-cover__accent { color: var(--sprout-500); }
.di-cover__subtitle { font-family: var(--font-display); font-size: 38px; color: var(--mint-200); margin-top: 40px; font-weight: 400; }
</style>

<!--
Short lecture. Six minutes. One pattern. ${GITHUB_TOKEN}. Commit the config — don't commit the secret. This is one of those memorize-it-and-ship-it topics the exam likes to test. It sits right on top of Lecture 4.10's project-scope pattern, and together they answer every shared-MCP-with-auth question.
-->

---

<BigQuote quote="I need credentials in config, but I can't commit credentials." />

<!--
Here's the tension. You need credentials in your MCP config — GitHub tokens, Jira API keys, database URLs. But your config lives in .mcp.json, which is committed to the repo. You can't commit credentials. That's a security incident and a compliance problem, and every team-wide GitHub scanner will flag it in seconds. And you can't not have credentials — without them, the MCP server can't authenticate against whatever backend it talks to. So how do you commit the config without committing the secret? That's the question this lecture answers in one pattern. It's a pattern every mature repo already uses for other secrets — you're just applying it to .mcp.json specifically.
-->

---

<script setup>
const expansion_code = `// .mcp.json -- committed, with env placeholders
{
  "mcpServers": {
    "github": {
      "command": "uvx",
      "args": ["mcp-server-github"],
      "env": {
        "GITHUB_TOKEN": "\${GITHUB_TOKEN}",
        "GITHUB_ORG":   "\${GITHUB_ORG}"
      }
    }
  }
}`
</script>

<CodeBlockSlide
  title=".mcp.json with env expansion"
  lang="json"
  :code="expansion_code"
  annotation="At runtime, Claude Code substitutes the value of each env var from the shell launching the process."
/>

<!--
Environment variable expansion. Inside .mcp.json, you write "${GITHUB_TOKEN}" — literal dollar-sign-curly-brace-GITHUB_TOKEN-curly-brace — as the value for the token field, usually in an env block attached to a server definition. At runtime, Claude Code reads the file, sees the placeholder, and substitutes the value of the GITHUB_TOKEN environment variable from the shell launching the process. The committed file has the placeholder. The running process has the real value. Same mechanism you've used in docker-compose files and Kubernetes manifests. Same pattern. No magic.
-->

---

<TwoColSlide
  title="Commit vs don't commit"
  leftLabel="Commit"
  rightLabel="Don't commit"
>
  <template #left>
    <div style="font-family: var(--font-body); font-size: 22px; line-height: 1.5;">
      <code>.mcp.json</code> with <code>"${GITHUB_TOKEN}"</code> placeholders
      <br/><br/>
      <code>.env.example</code> — template showing which vars to set, fake values
      <br/><br/>
      Reviewable. Reproducible. No secrets in git history.
    </div>
  </template>
  <template #right>
    <div style="font-family: var(--font-body); font-size: 22px; line-height: 1.5;">
      <code>.env</code> with real token values
      <br/><br/>
      Listed in <code>.gitignore</code>. Each developer keeps their own.
      <br/><br/>
      Token rotates? Only the individual updates locally — no repo change.
    </div>
  </template>
</TwoColSlide>

<!--
Here's the split. On the left — commit. The .mcp.json with "${GITHUB_TOKEN}" placeholders. Reviewable, reproducible, no secrets. Anyone can read it in a PR without spilling credentials. Also commit a .env.example — a template showing which variables need to be set, with fake values. That's how you tell new teammates what to fill in. On the right — don't commit. The .env file with the actual token value ghp_abc123.... That stays in .gitignore. Each developer has their own. Same config, different secrets, no shared-credential problems. If that secret ever rotates, only the individual updates their .env — nobody needs a repo change.
-->

---

<script setup>
const onboard_steps = [
  { title: 'Clone the repo', body: 'New teammate pulls the project. The .mcp.json is already there, with placeholders.' },
  { title: 'cp .env.example .env', body: 'Template becomes their personal env file. Shows which variables to fill in.' },
  { title: 'Fill in personal tokens', body: 'Each developer uses their own credentials. Scales across the team.' },
  { title: 'Launch Claude Code', body: 'Env-var placeholders resolve at runtime. Server authenticates. Works.' },
]
</script>

<StepSequence
  title="Onboarding steps"
  :steps="onboard_steps"
/>

<!--
Here's the onboarding flow for a new teammate. One — clone the repo. Two — copy .env.example to .env. Three — fill in their personal tokens into the .env file. Four — launch Claude Code; the MCP server reads the config, Claude Code substitutes the env-var placeholders with real values from the environment, authenticates, and works. Four steps, zero committed secrets, every developer using their own credentials against the shared config. This is the pattern every reasonable repo ships. It scales to as many servers and as many teammates as you need, and it plays nicely with CI — CI sets the env vars from its secret store and runs the same config.
-->

---

<script setup>
const antipattern_bad_411 = `// .mcp.json -- DO NOT COMMIT THIS
{
  "env": {
    "GITHUB_TOKEN": "ghp_abc123XYZ..."
  }
}
// Literal secret. Pushed to git history forever.
// GitHub's scanners WILL find it.`

const antipattern_fix_411 = `// .mcp.json -- committed safely
{
  "env": {
    "GITHUB_TOKEN": "\${GITHUB_TOKEN}"
  }
}
// Placeholder only. Real value stays in .env (gitignored).`
</script>

<AntiPatternSlide
  title="Don't inline the token"
  :badExample="antipattern_bad_411"
  whyItFails="In git history forever. Rotating credentials and rewriting history before lunch."
  :fixExample="antipattern_fix_411"
  lang="json"
/>

<!--
Anti-pattern. Inline the token. The .mcp.json has "token": "ghp_abc123..." with the literal secret. Committed. Pushed. Now it's in your git history forever, even if you remove it in the next commit — GitHub's secret scanners will find it, security will find it, and you'll be rotating the token and rewriting git history before lunch. The right version uses "token": "${GITHUB_TOKEN}" and keeps the real value out of git entirely. Two different lines, two radically different security postures. This is a rotating-credentials incident waiting to happen, and the exam tests the distinction because the industry has seen this bug a thousand times. It's one of the easiest distractor traps to spot once you know to look for it — any answer choice that literally commits a token is wrong.
-->

---

<CalloutBox variant="tip" title="On the exam">

If the question mentions <strong>team sharing AND credentials</strong>, the answer includes <code>${VAR}</code> environment expansion.
<br/><br/>
Inline tokens → always wrong.<br/>
Committing credential files → always wrong.<br/>
Separate auth service → over-engineered.<br/>
<strong>Project-scoped <code>.mcp.json</code> + env-var expansion</strong> → correct shape.

</CalloutBox>

<!--
Here's the exam move. If the question mentions team sharing AND credentials, the answer includes ${VAR} environment expansion. Inline tokens is always wrong. Committing a credential file is always wrong. Creating a separate auth service just to dodge the question is over-engineered. The correct pattern is project-scoped .mcp.json — the project scope from Lecture 4.10 — plus env-var expansion for anything sensitive. That's the shape of the right answer for every shared-MCP-with-auth question on this exam. Two lectures, one combined pattern. Hold onto both.
-->

---

<div class="di-close">
  <div class="di-close__inner">
    <div class="di-close__eyebrow">Next up</div>
    <h1 class="di-close__title">4.12 — <span class="di-close__accent">MCP Resources vs Tools</span></h1>
    <div class="di-close__subtitle">Tools do. Resources expose.</div>
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
Next up, Lecture 4.12 — MCP resources versus MCP tools. When to use each. Tools do, resources expose. See you there.
-->

---

<!-- LECTURE 4.12 — MCP Resources vs MCP Tools -->

<div class="di-cover">
  <div class="di-cover__inner">
    <div class="di-cover__eyebrow">Domain 2 · Lecture 4.12</div>
    <h1 class="di-cover__title">MCP <span class="di-cover__accent">Resources vs Tools</span></h1>
    <div class="di-cover__subtitle">When to use each. Verbs vs nouns.</div>
  </div>
</div>

<style scoped>
.di-cover { position: absolute; inset: 0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%); color: var(--mint-100); }
.di-cover__inner { padding: 110px 120px 96px; height: 100%; display: flex; flex-direction: column; justify-content: center; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px; }
.di-cover__title { font-family: var(--font-display); font-weight: 500; font-size: 128px; line-height: 1.05; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1600px; }
.di-cover__accent { color: var(--sprout-500); }
.di-cover__subtitle { font-family: var(--font-display); font-size: 40px; color: var(--mint-200); margin-top: 40px; font-weight: 400; }
</style>

<!--
MCP gives you two primitives. Tools and resources. Not the same thing. Not interchangeable. And the exam tests whether you know which is which. Seven minutes to lock it down.
-->

---

<ConceptHero
  leadLine="Verbs vs nouns"
  concept="Tools DO. Resources EXPOSE."
  supportLine="A tool call changes state or fetches dynamically. A resource shows Claude what's available without a call."
/>

<!--
Here's the distinction. Verbs versus nouns. Tools do. Resources expose. A tool call changes state, or fetches something dynamically based on arguments. A resource exposes a catalog of what's available, and Claude can read it without making a tool call. One is an action. The other is a listing. Once you internalize "verbs versus nouns," the rest of this lecture is just application.
-->

---

<script setup>
const tool_bullets = [
  { label: 'Side effects', detail: 'Creates, modifies, or triggers something downstream.' },
  { label: 'Parameters drive the result', detail: 'Different inputs, different outputs.' },
  { label: 'Claude reasons about WHEN to call', detail: 'The decision to invoke is part of the agent\'s reasoning.' },
]
</script>

<BulletReveal
  title="Use a tool when..."
  :bullets="tool_bullets"
/>

<!--
Use a tool when three conditions hold. One — the action has side effects. It creates something, modifies something, triggers something downstream. Two — parameters drive the result. Different inputs, different outputs; the call is meaningful because of what you pass in. Three — you want Claude to reason about when to call it, not just that it exists — the decision to invoke is part of the agent's reasoning. Tools are for doing. Reach for a tool whenever the semantics include a verb and an effect.
-->

---

<script setup>
const resource_bullets = [
  { label: 'See the catalog upfront', detail: 'No call needed to discover what\'s there.' },
  { label: 'Browsable content', detail: 'Issues, schemas, docs, configs -- scan and pick.' },
  { label: 'Reduce exploratory tool calls', detail: 'If Claude knows what exists, it doesn\'t guess-and-search.' },
]
</script>

<BulletReveal
  title="Use a resource when..."
  :bullets="resource_bullets"
/>

<!--
Use a resource when three different conditions hold. One — you want Claude to see the catalog upfront, without having to call anything to discover what's there. Two — the content is browsable. Issues, schemas, docs, configs — stuff Claude can scan and pick from. Three — you want to reduce exploratory tool calls. If Claude knows what's available, it doesn't have to guess-and-search. Resources are for exposing. Think of them as the "here's what exists" layer, sitting alongside the "here's how you act on it" layer that tools provide.
-->

---

<TwoColSlide
  title="Concrete pair — same Jira backend"
  leftLabel="Tool: search_jira_issue"
  rightLabel="Resource: jira://issues/open"
>
  <template #left>
    <div style="font-family: var(--font-body); font-size: 22px; line-height: 1.5;">
      Takes a query, runs a search, returns matching issues dynamically.
      <br/><br/>
      Different query → different result set. <strong>Call it, run it, get results back.</strong>
      <br/><br/>
      Targeted follow-up search.
    </div>
  </template>
  <template #right>
    <div style="font-family: var(--font-body); font-size: 22px; line-height: 1.5;">
      Exposes the current list of open issues as browsable content.
      <br/><br/>
      <strong>No parameters. No execution.</strong> Claude reads it like a document.
      <br/><br/>
      Open-issue discovery — cheap.
    </div>
  </template>
</TwoColSlide>

<!--
Concrete. On the left — a tool: search_jira_issue. Takes a query, runs a search, returns matching issues dynamically. Call it, run it, get results back. Different query, different result set. On the right — a resource: jira://issues/open. Exposes the current list of all open issues as browsable content Claude can read without making a tool call at all. No parameters. No execution. Claude already knows what's there, just by reading the resource. Same backend — Jira — powering both. Different MCP primitive. Radically different agent behavior. The resource makes open-issue discovery cheap; the tool handles the targeted follow-up search.
-->

---

<CalloutBox variant="tip" title="Cost and reliability">

Resources cut exploratory tool calls. Fewer round-trips, less latency, less token cost — and Claude doesn't have to choose between a redundant list-the-catalog tool and the targeted-action tool.
<br/><br/>
Going back to 4.8 — tool count degrades selection reliability. <strong>Stuff readable as a resource is stuff you don't need as a tool.</strong>

</CalloutBox>

<!--
This matters for cost and reliability both. Resources cut exploratory tool calls. If Claude can see the open-issue list upfront as a resource, it doesn't call list_issues() to find out what exists — which means fewer tool-call round-trips, less latency, less token cost, and frankly less chance of the agent getting confused about which tool to call. Every tool you don't need is a selection decision Claude doesn't have to make. Which, going back to Lecture 4.8, matters — tool count degrades selection reliability, and "stuff I can read as a resource" is stuff I don't need as a tool. Exposing content as resources removes a class of selection decisions from the agent's plate entirely.
-->

---

<CalloutBox variant="tip" title="On the exam — keyword cues">

<strong>"Content catalog," "database schemas," "issue summaries," "documentation hierarchy"</strong> → resource.
<br/><br/>
<strong>"Action," "query," "execute," "process," "trigger"</strong> → tool.
<br/><br/>
Distractors swap the two primitives to catch inattentive readers.

</CalloutBox>

<!--
Here's the exam move. Keywords matter. If the question mentions "content catalog," "database schemas," "issue summaries," "documentation hierarchy" — anything that sounds like browsable listings — that's a resource. If the question mentions "action," "query with parameters," "execute," "process," "trigger" — anything that sounds like a verb with side effects — that's a tool. Task 2.4 tests this distinction directly, and the distractors often swap the two primitives in answer choices to catch candidates who aren't paying attention. Train your ear on those keywords, and when you see them, you'll know which primitive is correct before you've finished reading the answers.
-->

---

<script setup>
const antipattern_bad_412 = `search_all_docs()
// Tool Claude calls every turn to discover what docs exist.
// Token cost every call. Latency every call.
// Sometimes Claude skips it entirely and guesses.`

const antipattern_fix_412 = `docs://catalog
// Exposed as a resource. Claude sees it directly in context
// at the start of conversation. References it without calling.
// Uses targeted get_doc(id) only when it needs specific content.`
</script>

<AntiPatternSlide
  title="Don't force a catalog into a tool"
  :badExample="antipattern_bad_412"
  whyItFails="Token cost every call. Latency every call. Sometimes Claude skips it and guesses — worst of both worlds."
  :fixExample="antipattern_fix_412"
  lang="text"
/>

<!--
Anti-pattern. Forcing a catalog into a tool. Left side — search_all_docs() — a tool Claude calls every turn to discover what docs exist. Token cost every call. Round-trip latency every call. Worse, Claude sometimes skips the call entirely and guesses at what's available, which is the worst of both worlds. Right side — expose docs://catalog as a resource. Claude sees the catalog directly in context at the start of the conversation, references it without calling, and only uses a targeted tool call — like get_doc(id) — when it needs specific content. Better cost, better reliability, same underlying data. That's the cleanest pattern.
-->

---

<div class="di-close">
  <div class="di-close__inner">
    <div class="di-close__eyebrow">Next up</div>
    <h1 class="di-close__title">4.13 — <span class="di-close__accent">Grep, Glob, Read, Edit</span></h1>
    <div class="di-close__subtitle">Four built-ins. Four jobs. Pick wrong, waste context.</div>
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
Next up, Lecture 4.13 — built-in tool selection. Grep, Glob, Read, Edit. Each has one job. See you there.
-->

---

<!-- LECTURE 4.13 — Built-in Tool Selection: Grep, Glob, Read, Edit -->

<div class="di-cover">
  <div class="di-cover__inner">
    <div class="di-cover__eyebrow">Domain 2 · Lecture 4.13</div>
    <h1 class="di-cover__title">Grep, Glob, Read, Edit —<br/><span class="di-cover__accent">Pick the Right Built-in</span></h1>
    <div class="di-cover__subtitle">Four tools. Four jobs. Pick wrong, waste context.</div>
  </div>
</div>

<style scoped>
.di-cover { position: absolute; inset: 0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%); color: var(--mint-100); }
.di-cover__inner { padding: 110px 120px 96px; height: 100%; display: flex; flex-direction: column; justify-content: center; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px; }
.di-cover__title { font-family: var(--font-display); font-weight: 500; font-size: 102px; line-height: 1.05; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1600px; }
.di-cover__accent { color: var(--sprout-500); }
.di-cover__subtitle { font-family: var(--font-display); font-size: 40px; color: var(--mint-200); margin-top: 40px; font-weight: 400; }
</style>

<!--
Four tools. Four jobs. Pick wrong, waste context. Grep is content. Glob is paths. Read is the whole file. Edit is a surgical change with a unique anchor. This lecture makes sure you can distinguish the four cleanly — which is exactly what Task 2.5 tests.
-->

---

<script setup>
const tool_columns = ['Job', 'Use when']
const tool_rows = [
  {
    label: 'Grep',
    cells: [
      { text: 'Search file contents', highlight: 'good' },
      { text: 'Finding callers, error messages, imports', highlight: 'good' },
    ],
  },
  {
    label: 'Glob',
    cells: [
      { text: 'Match file paths', highlight: 'good' },
      { text: 'Finding **/*.test.tsx', highlight: 'good' },
    ],
  },
  {
    label: 'Read',
    cells: [
      { text: 'Load full file', highlight: 'neutral' },
      { text: 'Understanding a specific file', highlight: 'neutral' },
    ],
  },
  {
    label: 'Edit',
    cells: [
      { text: 'Targeted change', highlight: 'neutral' },
      { text: 'Unique anchor text exists', highlight: 'neutral' },
    ],
  },
]
</script>

<ComparisonTable
  title="Built-in tools"
  :columns="tool_columns"
  :rows="tool_rows"
/>

<!--
Here's the table. Grep — search file contents for a pattern. Use it for function callers, error message locations, import statements. Glob — match file paths. Use it for "find all **/*.test.tsx." Read — load a full file. Use it when you need the whole thing to understand one specific file. Edit — make a targeted change using unique anchor text. Use it when you want to modify a small slice without rewriting the file. Four rows. Memorize them. Treating one as the other is a distractor classic.
-->

---

<script setup>
const grep_code = `# Grep -- content search
grep "process_refund" **/*.py

# Returns files + line numbers for every caller.
# From there: Read the handler files that surfaced.`
</script>

<CodeBlockSlide
  title="Grep — content search"
  lang="bash"
  :code="grep_code"
  annotation="How you start understanding a function's footprint across the codebase."
/>

<!--
Grep first. It searches content, not paths. The canonical use: find every caller of process_refund across the codebase. You Grep for the string process_refund and you get a list of files and line numbers. From there you Read the relevant handlers. Grep is how you start understanding a function's footprint. It's the content search tool. Nothing else in the toolbelt does content search.
-->

---

<script setup>
const glob_code = `# Glob -- path match
**/*.test.tsx
infra/**/*.tf

# Returns file paths matching the pattern.
# Doesn't read file contents. Just names.`
</script>

<CodeBlockSlide
  title="Glob — path match"
  lang="bash"
  :code="glob_code"
  annotation="Finds files by name pattern. Doesn't open them. Uses Grep for this? You pay to read every file."
/>

<!--
Glob next. It matches file paths, not contents. Use it for "find me every test file" — **/*.test.tsx. Or "find every Terraform module" — infra/**/*.tf. It answers the question "which files match this naming pattern?" Doesn't look inside them. Doesn't care what's in them. Just returns paths. If you want to find files by name or extension, Glob is the right tool. If you use Grep for this, you pay for reading every file when all you wanted was a name match.
-->

---

<CalloutBox variant="warn" title="When Edit fails — Read/Write fallback">

Edit needs unique anchor text. If the snippet appears three times, Edit fails — can't tell which occurrence.
<br/><br/>
<strong>Right move:</strong> Read the full file, make your change in memory, Write the file back. One pass. Done. Don't loop on failed edits with slightly longer anchors.

</CalloutBox>

<!--
Edit needs unique anchor text. If you tell Edit to replace a snippet and that snippet appears three times in the file, Edit fails — it can't tell which occurrence you meant. The right move when Edit fails: Read the full file, make your change in memory, Write the file back. That's the fallback. Don't loop on failed edits with slightly longer anchors — that wastes context and rarely converges. Read, modify, Write. One pass. Done. Task 2.5 calls this fallback out explicitly, and the exam will test whether you reach for it or whether you get stuck retrying Edit.
-->

---

<script setup>
const antipattern_bad_413 = `Read every file upfront "so you understand the codebase."

You hit the context wall before you understand anything.`

const antipattern_fix_413 = `Grep for entry points -- function names, key identifiers.
Read only the files the Grep surfaces.
Each Read is motivated by what the last Grep told you.`
</script>

<AntiPatternSlide
  title="Don't read the whole codebase"
  :badExample="antipattern_bad_413"
  whyItFails="Context wall. No understanding. You load everything and still don't know where the bug is."
  :fixExample="antipattern_fix_413"
  lang="text"
/>

<!--
Here's the anti-pattern. Reading every file upfront "so you understand the codebase." You hit the context wall before you understand anything. The right move: Grep for entry points — function names, key identifiers — and then Read only the files the Grep surfaces. Each Read is motivated by what the last Grep told you. You never touch files irrelevant to the question. That's incremental exploration, which is the next lecture in detail.
-->

---

<CalloutBox variant="tip" title="Next lecture preview">

Build codebase understanding incrementally. <strong>Grep → Read → follow imports with another Grep → Read what surfaces.</strong>
<br/><br/>
Never read-everything-upfront. The pattern that works on one file also works on one million. That's 4.14.

</CalloutBox>

<!--
Speaking of which — quick preview. Build codebase understanding incrementally. Grep, then Read, then follow imports with another Grep, then Read what that surfaces. Never read-everything-upfront. The pattern that works on one file also works on one million. That's 4.14. This lecture is the toolkit; the next one is the workflow.
-->

---

<CalloutBox variant="tip" title="On the exam — classic distractors">

<strong>"Find all .test.tsx files"</strong> → Glob. Not Grep.<br/>
<strong>"Find all callers of process_refund"</strong> → Grep. Not Glob.
<br/><br/>
Check the verb and the target. <em>Path names</em> or <em>file contents</em>? Ten seconds, not ten minutes.

</CalloutBox>

<!--
Here's the exam move. "Find all .test.tsx files" — Glob. Not Grep. If the question is about a filename pattern, and an answer reaches for Grep, that answer is wrong. "Find all callers of process_refund" — Grep. Not Glob. Glob can't see inside files. Treating Grep as a file finder or Glob as a content search is the classic Task 2.5 distractor. Know the four jobs, check the verb and the target in the question — is it about path names or about file contents? — and match it to the right tool. Ten seconds. Not ten minutes. That's how fast this decision should be on exam day.
-->

---

<ConceptHero
  leadLine="Scenario 4 — developer productivity"
  concept="Built on this tool selection."
  supportLine="Grep-for-content, Glob-for-paths, Read-for-whole, Edit-for-surgical, Edit-fallback-to-Write. That's most of Scenario 4's Domain 2."
/>

<!--
Scenario 4 — developer productivity — is built on this tool selection. Every Scenario 4 question about exploring or modifying a codebase is testing whether you pick the right built-in for the job. If you walk in with Grep-for-content, Glob-for-paths, Read-for-whole, Edit-for-surgical, Edit-fallback-to-Write — that's most of what you need for the Domain 2 questions Scenario 4 throws at you.
-->

---

<div class="di-close">
  <div class="di-close__inner">
    <div class="di-close__eyebrow">Next up</div>
    <h1 class="di-close__title">4.14 — <span class="di-close__accent">Incremental Codebase Exploration</span></h1>
    <div class="di-close__subtitle">Grep → Read → follow imports. The pattern that scales.</div>
  </div>
</div>

<style scoped>
.di-close { position: absolute; inset: 0; background: var(--mint-100); color: var(--forest-800); }
.di-close__inner { padding: 110px 120px 96px; height: 100%; display: flex; flex-direction: column; justify-content: center; }
.di-close__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.14em; text-transform: uppercase; color: var(--teal-500); margin-bottom: 36px; }
.di-close__title { font-family: var(--font-display); font-weight: 500; font-size: 84px; line-height: 1.05; letter-spacing: -0.02em; color: var(--forest-900); margin: 0; max-width: 1600px; }
.di-close__accent { color: var(--sprout-600); }
.di-close__subtitle { font-family: var(--font-display); font-size: 38px; color: var(--forest-500); margin-top: 32px; font-weight: 400; }
</style>

<!--
Next up, Lecture 4.14 — the incremental exploration pattern that ties all four built-ins together. Grep, Read, follow imports. See you there.
-->

---

<!-- LECTURE 4.14 — Incremental Codebase Exploration Pattern -->

<div class="di-cover">
  <div class="di-cover__inner">
    <div class="di-cover__eyebrow">Domain 2 · Lecture 4.14</div>
    <h1 class="di-cover__title">Incremental <span class="di-cover__accent">Codebase Exploration</span></h1>
    <div class="di-cover__subtitle">Grep → Read → follow imports. Never read-everything-upfront.</div>
  </div>
</div>

<style scoped>
.di-cover { position: absolute; inset: 0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%); color: var(--mint-100); }
.di-cover__inner { padding: 110px 120px 96px; height: 100%; display: flex; flex-direction: column; justify-content: center; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px; }
.di-cover__title { font-family: var(--font-display); font-weight: 500; font-size: 108px; line-height: 1.05; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1600px; }
.di-cover__accent { color: var(--sprout-500); }
.di-cover__subtitle { font-family: var(--font-display); font-size: 36px; color: var(--mint-200); margin-top: 40px; font-weight: 400; }
</style>

<!--
Last lecture of Domain 2. The pattern that ties the built-in tools together into a workflow. Grep, Read, follow imports. Never read-everything-upfront. Eight minutes, and then we close the section.
-->

---

<BigQuote quote="Read every file upfront — you hit the context wall before you learn anything." />

<!--
Here's the trap. "Read every file upfront: you hit the context wall before you learn anything." That's the opening move that kills agents — loading the whole codebase into context in the hope of understanding it, and running out of tokens before you've traced a single call path. Doesn't work on ten files. Definitely doesn't work on ten thousand. The fix isn't a bigger context window. It's a better workflow.
-->

---

<script setup>
const flow_steps = [
  { label: 'Grep entry points', sublabel: 'Function names, identifiers, error strings' },
  { label: 'Read matching files', sublabel: 'Only what the Grep surfaced' },
  { label: 'Grep again', sublabel: 'For imports or calls found in the reads' },
  { label: 'Read + repeat', sublabel: 'Until the question is answered' },
]
</script>

<FlowDiagram
  title="The right flow"
  :steps="flow_steps"
/>

<!--
Here's the pattern. Four steps. Step one — Grep for entry points. Function names, identifiers, error strings — whatever anchors the question you're trying to answer. Step two — Read the files the Grep surfaced. Step three — Grep again, for imports or calls you found in those reads. Step four — Read what that second Grep surfaces. Repeat until the question is answered. Each Grep is motivated by the last Read. Each Read is motivated by the last Grep. You never touch files the trace doesn't implicate.
-->

---

<ConceptHero
  leadLine="Incrementality is a context strategy"
  concept="You never exhaust tokens on files irrelevant to the question."
  supportLine="The question drives the files you touch — not the filesystem. Pattern that works on one file works on a million."
/>

<!--
Incrementality isn't just a code convention — it's a context strategy. You never exhaust tokens on files irrelevant to the question. The question drives the files you touch, not the filesystem. That's the reframe. You're not exploring the codebase; you're answering a specific question, and the files you need are the ones your trace walks through. The pattern that works on one file works on a million. The shape is the same.
-->

---

<script setup>
const trace_steps = [
  { title: 'Grep process_refund', body: 'Returns three callers: HTTP handler, CLI command, MCP tool impl.' },
  { title: 'Read the HTTP handler', body: 'See it imports a refund function from a wrapper module.' },
  { title: 'Grep the wrapper module', body: 'Finds the refund function and one helper.' },
  { title: 'Read the MCP tool impl', body: 'See how it maps to the business logic. Four calls. Seventy files untouched.' },
]
</script>

<StepSequence
  title="Trace example: process_refund"
  :steps="trace_steps"
/>

<!--
Concrete walkthrough. Trace process_refund across a hypothetical codebase. Step one — Grep process_refund. Returns three callers: an HTTP handler, a CLI command, an MCP tool implementation. Step two — Read the HTTP handler. You see it imports a refund function from a wrapper module. Step three — Grep that wrapper module's exports. Finds the refund function and one helper. Step four — Read the MCP tool impl to see how it maps to the business logic. Now you understand the refund path — how the HTTP call flows to the wrapper to the business logic, and how the MCP tool uses the same underlying function. Four tool calls. You never touched the seventy other files in the project.
-->

---

<CalloutBox variant="tip" title="Domain 3 crossover — when to spawn an Explore subagent">

If exploration will be verbose — dozens of files, long trails — delegate to an Explore subagent. The subagent does the Grep-Read loop in its own context, returns a summary.
<br/><br/>
Preserves your main context from file-reading noise. Task 3.4, covered in depth in Section 5.

</CalloutBox>

<!--
One more tool in the toolkit. If the exploration is going to be verbose — dozens of files, long trails — delegate it to an Explore subagent. The subagent does the Grep-Read loop in its own context, then returns a summary to the main conversation. This preserves your main context from getting cluttered with file-reading noise. Task 3.4 covers Explore in depth, and we'll come back to it in Section 5 when we handle Domain 3. For now, know it exists as the escape hatch for big traces.
-->

---

<script setup>
const antipattern_bad_414 = `Read all files upfront: context wall, no understanding.

OR: blind Grep with no plan -- Grep random strings, read what pops out, Grep again without any thread. Burning calls without a trace.`

const antipattern_fix_414 = `Each Grep is motivated by the last Read.
Every step is connected to the previous one.
If you can't name WHY you're running the next Grep -- stop and think.`
</script>

<AntiPatternSlide
  title="Two exploration traps"
  :badExample="antipattern_bad_414"
  whyItFails="Either you load everything and learn nothing, or you Grep blindly with no thread."
  :fixExample="antipattern_fix_414"
  lang="text"
/>

<!--
Two anti-patterns. Left side — read all files upfront. Context wall, no understanding. Right side — blind Grep with no plan. You Grep random strings, read what pops out, Grep again without any thread — burning calls without a trace. The fix for both: each Grep is motivated by the last Read. Every step is connected to the previous one. If you can't name why you're running the next Grep, stop and think.
-->

---

<CalloutBox variant="tip" title="On the exam — Scenario 4 'trace this function'">

Scenario 4 often shows a developer asking "trace this function" or "understand this module." Correct pattern: <strong>incremental — Grep, Read, follow imports, repeat.</strong>
<br/><br/>
<em>"Load all files upfront"</em> and <em>"read the whole module"</em> are distractor classics. They sound thorough. Thorough isn't the same as right.

</CalloutBox>

<!--
Here's the exam move. Scenario 4 frequently asks "a developer wants to trace this function" or "how should Claude approach understanding this unfamiliar module?" The correct pattern is always incremental — Grep, Read, follow imports, repeat. "Load all files upfront" and "read the whole module" are the distractor classics. They sound thorough. They're the wrong answer. Remember 1.1's "almost-right is the whole trap" — loading everything looks thorough, but thorough isn't the same as right.
-->

---

<ConceptHero
  leadLine="Domain 2 in one sentence"
  concept="Descriptions. Errors. Scope. Exploration."
  supportLine="Four parts of a great description. Three error fields. Four error categories. 4–5 tools per agent. Three tool_choice modes. Grep-Read incremental pattern."
/>

<!--
Section recap. Domain 2 in one sentence — tool descriptions, structured errors, scoped tool access, and incremental exploration. Eighteen percent of your exam. If you can name the four parts of a great tool description — purpose, inputs, examples, boundaries — the three fields of an MCP error response — errorCategory, isRetryable, description — the four error categories — transient, validation, business, permission — the tool-count ceiling of four to five, the three tool_choice modes, and the Grep-Read incremental pattern — you've covered the section. Know those cold.
-->

---

<div class="di-close">
  <div class="di-close__inner">
    <div class="di-close__eyebrow">Section closes · Next section</div>
    <h1 class="di-close__title">Domain 3 — <span class="di-close__accent">Claude Code Configuration &amp; Workflows</span></h1>
    <div class="di-close__subtitle">Twenty percent of your exam. Next up.</div>
  </div>
</div>

<style scoped>
.di-close { position: absolute; inset: 0; background: var(--mint-100); color: var(--forest-800); }
.di-close__inner { padding: 110px 120px 96px; height: 100%; display: flex; flex-direction: column; justify-content: center; }
.di-close__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.14em; text-transform: uppercase; color: var(--teal-500); margin-bottom: 36px; }
.di-close__title { font-family: var(--font-display); font-weight: 500; font-size: 84px; line-height: 1.05; letter-spacing: -0.02em; color: var(--forest-900); margin: 0; max-width: 1600px; }
.di-close__accent { color: var(--sprout-600); }
.di-close__subtitle { font-family: var(--font-display); font-size: 38px; color: var(--forest-500); margin-top: 32px; font-weight: 400; }
</style>

<!--
That closes Section 4 and Domain 2. Next section — Domain 3 — Claude Code Configuration and Workflows. Twenty percent. See you there.
-->