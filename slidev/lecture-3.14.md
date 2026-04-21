---
theme: default
title: "Lecture 3.14: Structured Handoff Summaries for Human Escalation"
info: |
  Claude Certified Architect – Foundations
  Section 3 — Agentic Architecture & Orchestration (Domain 1, 27%)
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
const withoutBullets = [
  'Human reads from the top — wasting 3–5 minutes on context',
  'May miss a critical detail buried in tool output #7',
  'May re-run steps the agent already tried',
  'Has to guess at the recommended action',
]
const withBullets = [
  'Human reads one concise summary — 30 seconds',
  'Knows exactly what was found, tried, and recommended',
  'Starts from where the agent stopped — no duplicated work',
  'Can make a decision immediately',
]

const requiredFields = [
  { label: 'Who is this about?', detail: 'Customer ID, account number, case identifier. The human must pull up the right record instantly.' },
  { label: 'What happened?', detail: 'Root cause the agent determined — with relevant amounts, dates, identifiers.' },
  { label: 'What was already tried?', detail: 'Every action attempted — succeeded, failed, and why. The human must not retry failed approaches.' },
  { label: 'What is recommended?', detail: 'Specific action + the reason the agent cannot execute it autonomously (limit exceeded, authorization, ambiguity).' },
  { label: 'What is the urgency?', detail: 'Priority level + time constraints — for triage across multiple escalations.' },
]

const takeaways = [
  { label: "Human agents don't have the transcript", detail: 'Everything the AI learned must be explicitly communicated in the handoff.' },
  { label: 'A complete handoff answers five questions', detail: 'Who, what happened, what was tried, what is recommended, urgency.' },
  { label: 'Always include verified identifiers', detail: 'Customer/case ID, root cause with specifics, actions attempted with outcomes, the recommended action, and the reason for escalation.' },
  { label: 'Structured data model FIRST', detail: 'Extract verified fields from the session, then generate the handoff FROM those fields.' },
  { label: 'Never ask Claude to "summarize the conversation"', detail: 'The agent may omit critical details or include irrelevant history if left unconstrained.' },
  { label: 'Handoffs without "what was tried" cause duplicated work', detail: 'The human re-runs steps the agent already completed — wasted time, degraded UX.' },
]

const handoffCode = `from dataclasses import dataclass

@dataclass
class HandoffSummary:
    customer_id: str
    case_id: str
    order_id: str
    urgency: str            # 'routine' | 'elevated' | 'urgent'
    situation: str          # root cause with specifics
    actions_tried: list[dict]   # each: {action, outcome, reason}
    recommendation: str     # specific action + why agent cannot execute
    escalation_reason: str  # limit exceeded / authorization / ambiguity


def generate_handoff_summary(session_state) -> HandoffSummary:
    """Build the structured summary from verified fields — NOT the transcript."""

    prompt = (
        "Produce a HandoffSummary JSON object. Use only these VERIFIED fields:\\n"
        f"customer_id: {session_state.customer_id}\\n"
        f"case_id: {session_state.case_id}\\n"
        f"order_id: {session_state.order_id}\\n"
        f"verified_actions: {session_state.action_log}\\n"
        f"limit_check_result: {session_state.limit_check}\\n"
        f"auth_check_result: {session_state.auth_check}\\n\\n"
        "Rules:\\n"
        "  - Do NOT invent details not in the verified fields.\\n"
        "  - Every action in actions_tried must appear in verified_actions.\\n"
        "  - If a field is missing, return null — do not fabricate."
    )

    return _parse_summary(
        client.messages.create(
            model="claude-opus-4-7",
            messages=[{"role": "user", "content": prompt}],
            tool_choice={"type": "tool", "name": "emit_handoff_summary"},
            tools=[HANDOFF_TOOL_SCHEMA],
        )
    )`
</script>

<Frame bg="var(--forest-900)" color="var(--mint-100)" :pad="false">
  <div style="position:absolute; inset:0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%);"></div>
  <div style="position:relative; z-index:1; padding:110px 120px 96px; width:100%; height:100%; display:flex; flex-direction:column; justify-content:space-between;">
    <div style="display:flex; align-items:center; gap:24px;">
      <img src="/assets/logo-mark.png" alt="" style="width:72px; height:auto;" />
      <div style="font-family: var(--font-body); font-size:26px; font-weight:500; letter-spacing:0.14em; text-transform:uppercase; color: var(--mint-200);">Dyer Innovation</div>
    </div>
    <div>
      <div style="font-family: var(--font-body); font-size:26px; font-weight:600; letter-spacing:0.16em; text-transform:uppercase; color: var(--sprout-500); margin-bottom:40px;">Lecture 3.14 &middot; Domain 1</div>
      <h1 style="font-family: var(--font-display); font-weight:500; font-size:128px; line-height:1.02; letter-spacing:-0.025em; color: var(--paper-0); margin:0; max-width:1600px;">Structured <span style="color: var(--sprout-500);">Handoff</span> Summaries</h1>
      <div style="font-family: var(--font-display); font-size:44px; color: var(--mint-200); margin-top:40px; font-weight:400; max-width:1300px; line-height:1.3;">For human escalation in customer support and beyond.</div>
    </div>
    <div style="display:flex; align-items:center; gap:48px; font-family: var(--font-body); font-size:26px; color: var(--mint-200); letter-spacing:0.06em;">
      <span>Domain 1 · 27%</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>Scenario 1 — Customer Support</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>Sets up Trust &amp; Safety</span>
    </div>
  </div>
</Frame>

<!--
Welcome to Lecture 3.14 — Structured Handoff Summaries for Human Escalation. This is the closer for Section 3, and the capstone of the human-in-the-loop story inside Domain 1. Every production agent eventually hits a situation it cannot resolve autonomously — a refund above a limit, an authorization edge case, an ambiguous request. When that happens, the agent hands off to a human. Whether the human experience is thirty seconds of reading or five minutes of spelunking depends on the structure of that handoff. This lecture shows you the five required fields and the code pattern that enforces them.
-->

---

<TwoColSlide
  variant="antipattern-fix"
  title="Humans Don't Have the Transcript"
  eyebrow="Why structure matters"
  leftLabel="❌ Without structured handoff"
  rightLabel="✓ With structured handoff"
  :footerNum="2"
  :footerTotal="7"
>
  <template #left>
    <ul>
      <li v-for="(b, i) in withoutBullets" :key="i">{{ b }}</li>
    </ul>
  </template>
  <template #right>
    <ul>
      <li v-for="(b, i) in withBullets" :key="i">{{ b }}</li>
    </ul>
  </template>
</TwoColSlide>

<!--
Here's the reality you have to design for. Human agents do not have the transcript. They do not see the tool calls the agent made. They do not see the reasoning the agent went through. Without a structured handoff, the human reads from the top, wastes three to five minutes piecing context together, may miss a critical detail buried in tool output number seven, may re-run steps the agent already tried, and ultimately has to guess at the recommended action. With a structured handoff, the human reads one concise summary in thirty seconds, knows exactly what was found and tried and recommended, starts from where the agent stopped with no duplicated work, and can make a decision immediately. That delta — five minutes of scavenger hunt versus thirty seconds of reading — is what this lecture designs for.
-->

---

<BulletReveal
  eyebrow="The five required fields"
  title="What a Handoff Summary Must Include"
  :bullets="requiredFields"
  :footerNum="3"
  :footerTotal="7"
/>

<!--
The five required fields of any complete handoff. One — who is this about? Customer ID, account number, case identifier. The human needs to pull up the right record instantly. Two — what happened? The root cause the agent determined, with relevant amounts, dates, and identifiers. Not prose — specifics. Three — what was already tried? Every action the agent attempted, including the ones that failed and why. The human must not retry an approach the agent already ruled out. Four — what is recommended? A specific action, plus the reason the agent cannot execute it autonomously — limit exceeded, authorization required, ambiguity in the request. And five — what is the urgency? A priority level plus any time constraints, so the human team can triage across multiple escalations. Five fields. Not four. Not six. Miss one and the handoff leaks value.
-->

---

<CodeBlockSlide
  eyebrow="Code pattern"
  title="Generating a Structured Handoff Summary"
  lang="python"
  :code="handoffCode"
  annotation="Structured data model FIRST — never ask Claude to 'summarize the conversation.' Extract verified fields, then generate the handoff from those fields."
  :footerNum="4"
  :footerTotal="7"
/>

<!--
Here's the implementation pattern. We define a HandoffSummary dataclass with the five required fields as concrete attributes — customer, case, order IDs; urgency; situation; actions tried; recommendation; escalation reason. Then generate_handoff_summary builds the handoff FROM a structured session_state, not from a transcript. The prompt feeds Claude only verified fields — action log, limit-check result, auth-check result — and explicitly tells it: do not invent details, every action in actions_tried must appear in verified_actions, and return null for missing fields rather than fabricate. We use tool_choice to force structured output. The key design principle: extract the verified fields first, then generate the handoff from those fields. Never ask Claude to "summarize the conversation" — that prompt is open-ended enough that critical details get dropped or irrelevant history gets included.
-->

---

<!-- TODO: consider dedicated EscalationDocument component for layout fidelity -->
<ConceptHero
  eyebrow="Example output · URGENT"
  concept="Customer: CUST-48291 · Case: CASE-20241104-007"
  leadLine="$750 refund for damaged order — verified. Exceeds $500 auto-approval. Four-year customer requesting full refund after declining the $500 partial."
  supportLine="WHAT WAS TRIED: account lookup ✓ · damage verified ✓ · auto-refund blocked (limit exceeded) ✗ · partial $500 offered, declined by customer ✗. RECOMMENDATION: approve full $750 refund — legitimate claim, long-standing customer. Suggested response: apologise, issue refund, add $25 goodwill credit."
  footerLabel="Every element maps to one of the five required fields — nothing missing, nothing filler"
  :footerNum="5"
  :footerTotal="7"
/>

<!--
Here's what a handoff looks like when the pattern is working. Notice how every element maps to one of the five required fields. Who: customer CUST-48291, case CASE-20241104-007, order ORD-88401. What happened: $750 refund for damaged order, verified, which exceeds the $500 auto-approval limit — customer is four years long, declined the partial $500. What was tried: four concrete actions with outcomes — account lookup succeeded, damage verified, auto-refund blocked by the limit check, partial $500 offered and declined. What is recommended: approve the full $750, because the claim is legitimate and the customer is long-standing — plus a suggested response that apologises, issues the refund, and adds a $25 goodwill credit. Urgency: URGENT. Nothing missing. Nothing filler. The human reads that in thirty seconds and decides.
-->

---

<Frame>
  <Eyebrow>⚡ Exam tip</Eyebrow>
  <SlideTitle>What a Handoff Must Include — and the Missing Field Trap</SlideTitle>
  <div style="margin-top: 40px; display: grid; grid-template-columns: 1fr 1fr; gap: 32px; flex: 1; min-height: 0;">
    <CalloutBox variant="dont" title="Incomplete handoff">
      <p>"Customer is unhappy about a damaged order. Please help them."</p>
      <p>Missing: customer ID, order ID, damage verification, amounts, what was tried, recommendation. The human must start from scratch — the handoff provided zero value.</p>
    </CalloutBox>
    <CalloutBox variant="do" title="Five required fields">
      <p>1. <strong>Who</strong> — customer, case, order identifiers.</p>
      <p>2. <strong>What happened</strong> — root cause with specifics.</p>
      <p>3. <strong>What was tried</strong> — actions with outcomes.</p>
      <p>4. <strong>What is recommended</strong> — specific action + reason agent cannot proceed.</p>
      <p>5. <strong>Urgency</strong> — priority for triage.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Domain 1 · Handoff traps" :num="6" :total="7" />
</Frame>

<!--
The exam trap. A question shows an incomplete handoff — something like "customer is unhappy about a damaged order, please help them" — and asks what's wrong with it. Wrong answers will point at tone or format issues. The right answer: missing fields. No customer ID, no order ID, no damage verification, no amount, no record of what was tried, no recommendation. The human agent has to start from scratch — the handoff provided zero value. The five-field checklist is the answer. Who, what happened, what was tried, what is recommended, urgency. If any one of those is missing, the handoff is incomplete by design, and the downstream human experience degrades correspondingly.
-->

---

<BulletReveal
  eyebrow="Takeaways"
  title="Structured Handoff Summaries — What to Remember"
  :bullets="takeaways"
  :footerNum="7"
  :footerTotal="7"
/>

<!--
Six takeaways to close Section 3. One — human agents do not have the transcript, so everything the AI learned must be explicitly communicated in the handoff. Two — a complete handoff answers five questions: who, what happened, what was tried, what is recommended, and urgency. Three — always include verified identifiers, root cause with specifics, actions attempted with outcomes, the recommended action, and the reason for escalation. Four — build the structured data model FIRST, extract the verified fields, and generate the handoff FROM those fields. Five — never ask Claude to "summarize the conversation" without constraints; the agent may omit critical details or include irrelevant history. And six — handoffs without a "what was tried" field cause the human to duplicate work, which is the single biggest UX failure in AI-assisted support. That wraps Section 3. Everything you've learned here — the loop, the subagents, the context passing, the enforcement, the hooks, the decomposition, the sessions, and now the escalation — these are the primitives Domain 1 tests. Onward to Domain 3.
-->
