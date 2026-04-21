---
theme: default
title: "Lecture 4.6: Transient vs Validation vs Business vs Permission Errors"
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
