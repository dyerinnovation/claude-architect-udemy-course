---
theme: default
title: "Lecture 7.6: Honoring Explicit Human Requests"
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
const treeSteps = [
  { label: 'Explicit ask?', sublabel: 'Did the customer say "human"?' },
  { label: 'YES → escalate now', sublabel: 'Route, confirm, stay out of the way' },
  { label: 'NO → acknowledge + resolve', sublabel: 'Attempt once. Politely.' },
  { label: 'Reiterated? → escalate', sublabel: 'One retry earns one re-ask → hand off' },
]

const antiPatternBad = `Customer: "I want to talk to a human."
Agent: "Let me try to help you first —
can you tell me what's going on?"

→ Sounds polite. Is exam-wrong.
→ Overrides the customer's stated decision.`

const antiPatternFix = `Customer: "I want to talk to a human."
Agent: "Connecting you now —
one moment while I hand this off."

→ Respect the stated preference.
→ Polite by honoring the ask, not by overriding it.`
</script>

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

<CalloutBox variant="tip" title="The nuance — frustration without ask">

If the customer is frustrated but has NOT asked for a human: acknowledge the frustration AND offer to resolve.

<p>If they reiterate under pushback — "no, I want a human" — then yes, escalate. <strong>One explicit ask plus reiteration = same signal as a clean first-turn request.</strong> The agent's willingness to try once doesn't entitle it to try three times.</p>

</CalloutBox>

<!--
Here's the nuance that tripped me up the first time through the study guide. Frustration is not the same signal as an explicit request. If the customer is frustrated but has NOT asked for a human, the right move is to acknowledge the frustration AND offer to resolve. You don't escalate on frustration alone — we covered that in 7.5 and we'll sharpen it in 7.7.

But if they reiterate, if they say "no, I want a human," then yes, escalate. The distinction: one explicit ask plus a reiteration under pushback is functionally the same signal as a clean first-turn request. Honor it. The agent's willingness to try once doesn't entitle it to try three times — one attempt, one re-ask, hand-off.
-->

---

<FlowDiagram
  title="Escalation trigger"
  :steps="treeSteps"
/>

<!--
Decision tree. Did the customer explicitly ask for a human? If yes — escalate now. If no — acknowledge and attempt to resolve. After the attempt, did the customer reiterate the preference for a human? If yes — escalate. If no — keep resolving.

Notice the tree doesn't branch on sentiment. It branches on explicit ask. That's the discipline. A calm customer who asks for a human still gets escalated — sentiment isn't required. A frustrated customer who doesn't ask for a human doesn't get escalated — frustration isn't enough.
-->

---

<AntiPatternSlide
  title="Don't resolve over an explicit ask"
  lang="text"
  :badExample="antiPatternBad"
  whyItFails="Politeness is the whole distractor. 'Let me try first' reads as service but overrides a customer choice."
  :fixExample="antiPatternFix"
/>

<!--
The anti-pattern: customer asks for a human, agent says "let me try to help first." That's the almost-right distractor — it sounds like attentive service. It reads as polite. It is exam-wrong.

The better pattern: customer asks for a human, agent escalates immediately and confirms the hand-off. Polite in a different way — polite by respecting the stated preference rather than overriding it. The customer wanted a human and the system gave them one, quickly. That's the service.
-->

---

<CalloutBox variant="tip" title="On the exam — two phrasings, two answers">

<p><strong>"Customer explicitly requests a human"</strong> → escalate immediately, no investigation.</p>
<p><strong>"Customer sounds frustrated"</strong> → acknowledge and offer resolution.</p>

Two different signals. The exam tests whether you can tell them apart under scenario pressure. If the question describes both — frustration AND an explicit ask — the <em>explicit ask wins</em>. Always.

</CalloutBox>

<!--
On the exam, two phrasings map to two different answers. "Customer explicitly requests a human" — escalate immediately, no investigation. "Customer sounds frustrated" — acknowledge and offer resolution. These are two different signals, and the exam tests whether you can tell them apart under scenario pressure. Almost-right is the whole trap of this exam — and this is a clean example of it.

If the question describes both — "the customer sounds frustrated and says 'I want to talk to a human'" — the explicit ask wins. Always. Escalation now.
-->

---

<Frame bg="var(--mint-100)">
  <Eyebrow>Closing</Eyebrow>
  <SlideTitle>Next up: 7.7 — Sentiment vs Complexity.</SlideTitle>

  <div class="closing-body">
    <p>We just talked about why frustration isn't the escalation trigger. Next lecture zooms in on WHY — and on why the exam specifically rules out sentiment-based routing as an entire category of wrong answer.</p>
  </div>
</Frame>

<style scoped>
.closing-body { margin-top: 56px; font-family: var(--font-body); font-size: 30px; line-height: 1.5; color: var(--forest-500); max-width: 1400px; }
</style>

<!--
One last mental note before we move on. This lecture looks tiny compared to the cluster around it — 7.5 on the framework, 7.7 on sentiment-versus-complexity, 7.14 on the calibration nuance. But the "explicit ask means immediate escalate" rule is its own testable item. The exam has been seen to isolate this specific trigger in a question and ask for the correct agent behavior. If you've studied only the 7.5 framework and not this zoomed-in version, you might pick the "try to help first" distractor — because it sounds like the compassionate move. Resist that. Explicit ask equals escalate.

Next up: 7.7, sentiment versus complexity. We just talked about why frustration isn't the escalation trigger. Next lecture zooms in on why — and on why the exam specifically rules out sentiment-based routing as an entire category of wrong answer. See you there.
-->
