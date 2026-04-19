---
theme: default
title: "Lecture 3.14: Structured Handoff Summaries for Human Escalation"
info: |
  Claude Certified Architect – Foundations
  Section 3: Domain 1 — Agentic Architecture & Orchestration (27%)
highlighter: shiki
transition: fade-out
mdc: true
---

<style>
@import './style.css';
</style>

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 1 — TITLE
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-cover-accent"></div>

<div style="height: 100%; display: flex; flex-direction: column; justify-content: center; align-items: center; text-align: center;">
  <div class="di-course-label">Claude Certified Architect – Foundations</div>
  <div class="di-cover-title">Structured Handoff Summaries<br>for Human Escalation</div>
  <div class="di-cover-subtitle">Lecture 3.14 · Domain 1 — Agentic Architecture & Orchestration (27%)</div>
</div>

<img src="/logo.png" class="di-logo-centered" />

<!--
When an agentic system reaches the limits of what it can safely do autonomously, it escalates to a human.

But the human receiving that escalation doesn't have access to the conversation transcript. They don't know what the agent found, what it tried, or what it recommends. They're starting cold.

The structured handoff summary is how you bridge that gap. If it's missing, incomplete, or unstructured, you've handed the human a problem without the context they need to solve it. This lecture covers exactly what a handoff summary must contain, how to structure it, and what happens when you get it wrong.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 2 — The Escalation Problem
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">The Escalation Problem: Humans Don't Have the Transcript</div>

<div class="di-body" style="margin-top: 0.75rem;">

<v-click>
<p>When an agent escalates to a human, the human agent receives a task — not a conversation history. Everything the AI agent learned must be explicitly communicated.</p>
</v-click>

<v-click>
<div style="display: flex; gap: 1rem; margin-top: 0.75rem;">
  <div style="flex: 1; background: #FFF0F0; border: 1px solid #ffc8c8; border-top: 3px solid #E53E3E; border-radius: 6px; padding: 0.65rem 0.85rem; font-size: 0.9rem;">
    <div style="font-weight: 700; color: #E53E3E; margin-bottom: 0.25rem;">Without a structured handoff</div>
    <ul style="margin: 0; padding-left: 1.1rem; line-height: 1.6;">
      <li>Human reads from the top — wasting 3-5 minutes on context</li>
      <li>May miss the critical detail buried in tool output #7</li>
      <li>May re-run steps the agent already tried — duplicating work</li>
      <li>Has to guess the recommended action</li>
    </ul>
  </div>
</div>
</v-click>

<v-click>
<div style="display: flex; gap: 1rem; margin-top: 0.5rem;">
  <div style="flex: 1; background: #E8F5EB; border: 1px solid #c8e6d0; border-top: 3px solid #3CAF50; border-radius: 6px; padding: 0.65rem 0.85rem; font-size: 0.9rem;">
    <div style="font-weight: 700; color: #1B8A5A; margin-bottom: 0.25rem;">With a structured handoff</div>
    <ul style="margin: 0; padding-left: 1.1rem; line-height: 1.6;">
      <li>Human reads one concise summary — 30 seconds</li>
      <li>Knows exactly what was found, what was attempted, what's recommended</li>
      <li>Starts from where the agent stopped — no duplicated work</li>
      <li>Can make a decision immediately</li>
    </ul>
  </div>
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
When an agentic system escalates to a human, the human does not receive the conversation transcript. They receive a task.

Everything the agent learned, tried, and concluded is locked inside the session history — which the human agent cannot read, and should not have to read.

[click] Without a structured handoff, the human has to reconstruct context manually. They read from the top, searching for what went wrong, what was tried, and what the system recommends. This wastes time, risks missing critical details, and often results in duplicate work.

[click] With a structured handoff, the human can read one concise summary in thirty seconds, know exactly what was found and what is recommended, and start from where the agent stopped. The escalation is efficient and decisive rather than disorienting and slow.

The structured handoff summary is not a nice-to-have. It's the minimum viable output when an agent escalates.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 3 — What a Handoff Summary Must Include
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">What a Handoff Summary Must Include</div>

<div class="di-body" style="margin-top: 0.75rem;">

<v-click>
<p>A handoff summary for human escalation must answer five questions — immediately, without the human having to dig:</p>
</v-click>

<div style="display: flex; flex-direction: column; gap: 0.45rem; margin-top: 0.6rem;">

  <v-click>
  <div class="di-step-card">
    <span class="di-step-num">Who is this about?</span> Customer ID, account number, case identifier. The human must be able to pull up the right record instantly.
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card" style="border-left-color: #0D7377;">
    <span class="di-step-num" style="color: #0D7377;">What happened?</span> Root cause of the issue — what the agent determined is wrong, with relevant amounts, dates, and identifiers.
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card" style="border-left-color: #E3A008;">
    <span class="di-step-num" style="color: #E3A008;">What was already tried?</span> Every action the agent attempted — including what succeeded, what failed, and why. The human should not retry failed approaches.
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card" style="border-left-color: #1B8A5A;">
    <span class="di-step-num" style="color: #1B8A5A;">What is recommended?</span> The specific action the agent recommends — with the reason it cannot execute it autonomously (limit exceeded, authorization required, ambiguous situation).
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card" style="border-left-color: #E53E3E;">
    <span class="di-step-num" style="color: #E53E3E;">What is the urgency?</span> Priority level and any time constraints — so the human can triage correctly across multiple escalations.
  </div>
  </v-click>

</div>

</div>

<img src="/logo.png" class="di-logo" />

<!--
A handoff summary must answer five questions without the human having to dig for them.

[click] Who is this about? Customer ID, account number, case identifier. The human needs to pull up the right record. If they have to search for it, the handoff failed.

[click] What happened? The root cause the agent determined — what is wrong, with all relevant amounts, dates, and reference numbers.

[click] What was already tried? Every action attempted — what succeeded, what failed, and why it failed. This prevents the human from wasting time retrying approaches the agent already exhausted.

[click] What is recommended? The specific next action — and critically, why the agent cannot execute it autonomously. Was it a financial limit? An authorization requirement? An ambiguous situation requiring judgment? The human needs to know this to take the right action.

[click] What is the urgency? Priority level and any time constraints. If three escalations arrive simultaneously, the human must be able to triage. The handoff summary should surface urgency explicitly.
-->

---
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 4 — Handoff Summary Structure in Code
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">Generating a Structured Handoff Summary</div>

<v-click>

```python {all|3-25|28-45|all}
# The handoff data model — structured fields, not a narrative blob
@dataclass
class HandoffSummary:
    customer_id: str
    case_id: str
    root_cause: str
    financial_amounts: dict        # {"requested": 750.00, "limit": 500.00}
    order_ids: list[str]
    actions_attempted: list[dict]  # [{"action": "...", "result": "...", "timestamp": "..."}]
    recommended_action: str
    escalation_reason: str         # Why the agent cannot proceed autonomously
    urgency: str                   # "HIGH" | "MEDIUM" | "LOW"
    agent_confidence: str          # "HIGH" | "MEDIUM" — how confident in root cause


# Generate the human-readable handoff from structured data
def generate_handoff_summary(data: HandoffSummary) -> str:
    prompt = f"""
    Generate a structured escalation handoff summary for a human support agent.
    Use the following verified data — do not invent or infer additional information.

    Customer: {data.customer_id} | Case: {data.case_id}
    Root cause: {data.root_cause}
    Financial: {data.financial_amounts}
    Orders involved: {', '.join(data.order_ids)}
    Actions attempted: {data.actions_attempted}
    Recommended action: {data.recommended_action}
    Why escalating: {data.escalation_reason}
    Urgency: {data.urgency}

    Format as: SITUATION / WHAT WAS TRIED / RECOMMENDATION / URGENCY.
    Be concise. Every sentence must be actionable for the human agent.
    """
    response = client.messages.create(
        model="claude-opus-4-7",
        messages=[{"role": "user", "content": prompt}]
    )
    return response.content[0].text
```

</v-click>

<v-click>
<div style="background: white; padding: 0.4rem 0.75rem; border-radius: 4px; border-left: 2px solid #3CAF50; font-size: 0.82rem; margin-top: 0.4rem;">
  <strong style="color: #1B8A5A;">Key:</strong> structured data model first — never ask Claude to "summarize the conversation." Extract verified fields, then generate the handoff from those fields.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Here's the implementation pattern.

First: a structured data model for the handoff. Not a narrative blob — a dataclass with named fields. Customer ID, case ID, root cause, the specific financial amounts, order IDs, a list of actions attempted with their results, the recommended action, the reason for escalation, urgency, and the agent's confidence level.

[click] Second: generate the human-readable handoff from the structured data. The prompt gives Claude all the verified facts and a format instruction. Critically: the prompt says "do not invent or infer additional information." Claude generates well-written prose — but from structured fields, not from the raw conversation.

[click] The key architectural point: structured data model first, then handoff generation. Never ask Claude to "summarize the conversation" and hope it includes the right information. Extract the verified facts programmatically, then use Claude to format them clearly for the human reader.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 5 — Example Handoff Output
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Example: Customer Support Escalation Handoff</div>

<div style="margin-top: 0.6rem; background: white; border: 1px solid #c8e6d0; border-radius: 8px; padding: 0.75rem 1rem; font-size: 0.87rem; color: #111928; line-height: 1.65;">

<v-click>
<div style="border-bottom: 1px solid #e0e0e0; padding-bottom: 0.5rem; margin-bottom: 0.5rem;">
  <strong style="color: #1A3A4A; font-size: 0.9rem;">ESCALATION SUMMARY</strong>
  <span style="float: right; background: #E53E3E; color: white; font-size: 0.75rem; font-weight: 700; padding: 0.15rem 0.5rem; border-radius: 3px;">URGENT</span><br>
  <span style="color: #1B8A5A; font-size: 0.82rem;">Customer: CUST-48291 &nbsp;|&nbsp; Case: CASE-20241104-007 &nbsp;|&nbsp; Order: ORD-88401</span>
</div>
</v-click>

<v-click>
<div style="margin-bottom: 0.5rem;">
  <strong style="color: #E3A008;">SITUATION:</strong> Customer requesting refund of $750.00 for order ORD-88401 (delivered 2024-10-28, claimed damaged). Root cause confirmed: carrier damage photo verified. Refund justified but exceeds $500 auto-approval limit.
</div>
</v-click>

<v-click>
<div style="margin-bottom: 0.5rem;">
  <strong style="color: #0D7377;">WHAT WAS TRIED:</strong>
  <ul style="margin: 0.2rem 0 0 1rem; padding: 0; line-height: 1.5;">
    <li>Lookup customer account: ✓ Account in good standing, 4-year customer</li>
    <li>Verify order and damage claim: ✓ Damage photos confirmed by carrier API</li>
    <li>Attempt auto-refund $750.00: ✗ Blocked — exceeds $500 limit (requires supervisor)</li>
    <li>Offer partial $500 refund: Customer declined, requesting full amount</li>
  </ul>
</div>
</v-click>

<v-click>
<div>
  <strong style="color: #1B8A5A;">RECOMMENDATION:</strong> Approve full $750.00 refund. Claim is legitimate (verified), customer is long-standing (4 years, no prior refund abuse). Suggested response: apologize for carrier damage, issue full refund, add $25 store credit as goodwill.
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
Here's what a well-structured handoff looks like in practice.

The header gives the human the urgency level and all identifying information immediately — customer ID, case ID, order ID — so they can pull up the right records in one action.

[click] The situation block states the root cause in one sentence, with the specific amounts, and explains why the agent cannot proceed autonomously. The human knows exactly what they're dealing with before they take any action.

[click] The "what was tried" section is a chronological log with explicit success and failure markers. The human can see that the partial $500 refund was already offered and declined. They know not to offer it again.

[click] The recommendation is specific and actionable — a dollar amount, a reason, and a suggested response including the goodwill credit. The human can approve this in seconds rather than having to reason it through from scratch.

Notice: every element maps to one of the five required fields we identified. Customer ID, root cause, what was tried, recommendation, and urgency. Nothing is missing, nothing is filler.
-->

---
layout: default
class: di-exam-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 6 — Exam Tip
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-exam-banner">⚡ EXAM TIP</div>

<v-click>
<div class="di-exam-subtitle">What a Handoff Must Include — and the Missing Field Trap</div>

<div class="di-exam-body">
  The exam will present a handoff summary scenario and ask either what is missing from an incomplete handoff, or what the handoff must include for the human agent to take action.
</div>
</v-click>

<v-click>
<div class="di-trap-box">
  <div class="di-trap-label">❌ The Incomplete Handoff</div>
  A handoff that says: "Customer is unhappy about a damaged order. Please help them."<br><br>
  Missing: customer ID, order ID, damage verification status, specific amounts, what was already attempted, recommended action. The human agent must start from scratch — the handoff provided no value.
</div>
</v-click>

<v-click>
<div class="di-correct-box">
  <div class="di-correct-label">✓ The Five Required Fields</div>
  <strong>1.</strong> Who — customer/case/order identifiers<br>
  <strong>2.</strong> What happened — root cause with specific amounts and dates<br>
  <strong>3.</strong> What was tried — actions attempted, with outcomes<br>
  <strong>4.</strong> What is recommended — specific action + reason agent cannot proceed<br>
  <strong>5.</strong> Urgency — priority level for triage
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
The exam will test whether you know what a complete handoff summary includes.

[click] The trap: a handoff that says "Customer is unhappy about a damaged order. Please help them." This tells the human agent nothing actionable. No customer ID, no order ID, no damage verification, no amounts, no record of what was tried, no recommendation. The human has to start from scratch. This handoff provided zero value.

[click] The five required fields. Memorize these: who (identifiers), what happened (root cause with specifics), what was tried (with outcomes), what is recommended (including why the agent cannot proceed), and urgency.

If the exam presents a handoff and asks what's missing, look for which of these five fields is absent. If it asks what should be included, your answer should map to these five fields. Any answer option that describes a "narrative summary of the conversation" is wrong — the human needs structured fields, not a transcript.
-->

---
layout: default
class: di-takeaway-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 7 — Key Takeaways
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-takeaway-title">Structured Handoff Summaries — What to Remember</div>

<ul class="di-takeaway-list">
  <v-click><li>Human agents don't have the transcript — <strong>everything the AI agent learned must be explicitly communicated</strong></li></v-click>
  <v-click><li>A complete handoff answers five questions: who, what happened, what was tried, what is recommended, and urgency</li></v-click>
  <v-click><li>Always include: customer/case ID, root cause with specific amounts, actions attempted with outcomes, recommended action, and reason for escalation</li></v-click>
  <v-click><li>Build a <strong>structured data model</strong> first — extract verified fields — then generate the handoff summary from those fields</li></v-click>
  <v-click><li>Never ask Claude to "summarize the conversation" — the agent may omit critical details or include irrelevant history</li></v-click>
  <v-click><li>A handoff without "what was tried" causes the human to duplicate work the agent already did — wasting time and degrading the customer experience</li></v-click>
</ul>

<img src="/logo.png" class="di-logo" style="opacity: 0.75;" />

<!--
What to remember from this lecture:

Human agents don't have the transcript. Everything the AI agent learned must be explicitly communicated in the handoff.

A complete handoff answers five questions: who, what happened, what was tried, what is recommended, and urgency.

Always include customer and case identifiers, root cause with specific amounts and dates, actions attempted with their outcomes, the recommended action, and the reason the agent could not proceed autonomously.

Build a structured data model first — extract verified fields programmatically — then generate the handoff from those fields. Don't ask Claude to summarize the conversation.

And the most operationally important point: a handoff that omits "what was tried" causes the human to duplicate work. That's wasted time and a degraded customer experience — and it's entirely avoidable with a well-structured handoff summary.

That's the final lecture in this section. In the next section, we'll move from orchestration mechanics into trust, safety boundaries, and how to design systems that remain safe under adversarial conditions.
-->
