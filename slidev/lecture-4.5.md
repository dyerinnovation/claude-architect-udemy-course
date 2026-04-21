---
theme: default
title: "Lecture 4.5: MCP Error Response Design"
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
const field_questions = [
  { label: 'errorCategory → which recovery path?', detail: 'Retry, reformat, escalate, run prereq?' },
  { label: 'isRetryable → try again right now, or not?', detail: 'The fast-path decision.' },
  { label: 'description → what do I tell the user?', detail: 'Customer-facing string. Shown to the user or used in escalation.' },
]

const good_error = `{
  "isError": true,
  "errorCategory": "business",
  "isRetryable": false,
  "description": "Refund amount of $750 exceeds the
    $500 per-transaction limit. Escalation to a
    human agent is required."
}`
</script>

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

<BulletReveal
  title="Each field answers one question"
  :bullets="field_questions"
/>

<!--
Each field answers one question the agent has to answer. errorCategory answers "which recovery path do I take?" — retry, reformat, escalate, or run a prerequisite. isRetryable answers "try again right now, or not?" — it's the fast-path decision. Description answers "what do I tell the user?" — and that matters because on a customer-facing agent, the user sees that string. Skip any one field and the agent is guessing at one of those three questions.
-->

---

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
