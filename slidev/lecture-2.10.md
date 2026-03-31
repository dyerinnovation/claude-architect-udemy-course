---
theme: default
title: "Lecture 2.10: Programmatic Enforcement vs Prompt-Based Guidance"
info: |
  Claude Certified Architect – Foundations
  Section 2: Domain 1 — Agentic Architecture & Orchestration (27%)
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
  <div class="di-cover-title">Programmatic Enforcement<br>vs Prompt-Based Guidance</div>
  <div class="di-cover-subtitle">Lecture 2.10 · Domain 1 — Agentic Architecture & Orchestration (27%)</div>
</div>

<img src="/logo.png" class="di-logo-centered" />

<!--
Here is the most consequential architectural decision you will make in any agentic system:

When something must not happen — ever — do you trust a prompt to prevent it, or do you enforce it in code?

These are not equivalent. They have fundamentally different reliability guarantees. And the exam tests this distinction repeatedly — because getting it wrong in production has serious consequences.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 2 — The Fundamental Fork
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">The Fundamental Fork: Deterministic vs Probabilistic</div>

<div class="di-body" style="margin-top: 0.75rem;">

<v-click>
<p>Every constraint in an agentic system falls into one of two categories:</p>
</v-click>

<div style="display: flex; gap: 1.2rem; margin-top: 0.75rem;">

  <v-click>
  <div style="flex: 1; background: white; border: 1px solid #c8e6d0; border-top: 4px solid #3CAF50; border-radius: 8px; padding: 0.75rem 1rem; font-size: 0.92rem;">
    <div style="font-weight: 700; color: #1B8A5A; font-size: 1rem; margin-bottom: 0.4rem;">Programmatic Enforcement</div>
    <div style="color: #111928; line-height: 1.6;">Your code prevents it — unconditionally. The model never gets the opportunity to make a different choice.</div>
    <div style="margin-top: 0.5rem; font-size: 0.85rem; color: #1A3A4A; font-style: italic; border-top: 1px solid #c8e6d0; padding-top: 0.4rem;">
      Reliability: <strong>deterministic</strong><br>
      Example: block any refund &gt; $500 in the tool execution layer
    </div>
  </div>
  </v-click>

  <v-click>
  <div style="flex: 1; background: white; border: 1px solid #ffd5a0; border-top: 4px solid #E3A008; border-radius: 8px; padding: 0.75rem 1rem; font-size: 0.92rem;">
    <div style="font-weight: 700; color: #E3A008; font-size: 1rem; margin-bottom: 0.4rem;">Prompt-Based Guidance</div>
    <div style="color: #111928; line-height: 1.6;">You instruct the model in the system prompt to follow a rule. The model generally will — but it is a statistical outcome, not a guarantee.</div>
    <div style="margin-top: 0.5rem; font-size: 0.85rem; color: #1A3A4A; font-style: italic; border-top: 1px solid #ffd5a0; padding-top: 0.4rem;">
      Reliability: <strong>probabilistic</strong><br>
      Example: "Always use a professional tone when responding to customers"
    </div>
  </div>
  </v-click>

</div>

</div>

<img src="/logo.png" class="di-logo" />

<!--
The fundamental fork in agentic system design.

[click] Programmatic enforcement means your code prevents something — unconditionally. The model never gets the opportunity to do otherwise. It's deterministic. If the rule says "no refund over five hundred dollars," your code blocks the tool call before it executes. Full stop.

[click] Prompt-based guidance means you instruct the model in the system prompt. "Be professional." "Don't discuss competitors." "Only recommend products in the user's region." These are probabilistic. The model generally follows them — Claude is well-trained and instruction-following. But "generally" is not a guarantee. Under adversarial input, edge cases, or novel contexts, prompt-based guidance can fail.

The architectural decision is: which category does each constraint fall into?
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 3 — When to Enforce Programmatically
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">When Programmatic Enforcement Is Required</div>

<div class="di-body" style="margin-top: 0.75rem;">

<v-click>
<p>Use programmatic enforcement whenever the consequence of a constraint violation is <strong>irreversible, financially material, legally significant, or a security risk</strong>.</p>
</v-click>

<div style="display: flex; flex-direction: column; gap: 0.45rem; margin-top: 0.6rem;">

  <v-click>
  <div class="di-step-card">
    <span class="di-step-num">Financial operations</span> Refund limits, transfer caps, transaction thresholds — enforce in the tool execution layer, not in the prompt
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card" style="border-left-color: #0D7377;">
    <span class="di-step-num" style="color: #0D7377;">Identity and authorization</span> Only allow actions on resources the authenticated user owns — verified by your code against your database, not by the model's understanding of the request
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card" style="border-left-color: #E3A008;">
    <span class="di-step-num" style="color: #E3A008;">Compliance boundaries</span> Data residency, PII handling, regulated data access — these have legal consequences if violated. Your code must enforce them.
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card" style="border-left-color: #E53E3E;">
    <span class="di-step-num" style="color: #E53E3E;">Irreversible actions</span> Deletions, sends, deployments — require a confirmation gate in code before the action executes, regardless of what the prompt says
  </div>
  </v-click>

</div>

</div>

<img src="/logo.png" class="di-logo" />

<!--
When do you enforce programmatically rather than trusting a prompt?

The rule is clear: whenever the consequence of a violation is irreversible, financially material, legally significant, or a security risk.

[click] Financial operations. If your agent can process refunds, you do not rely on the prompt to enforce a $500 limit. You check the amount in your tool execution layer. If it exceeds the threshold, the tool returns an error before any refund is issued.

[click] Identity and authorization. If an agent is acting on behalf of a user, the authorization check must happen in your code — against your database. The model's understanding of "the user's account" is not an authorization control.

[click] Compliance boundaries. Data residency requirements, PII access restrictions, regulated data handling — all of these have legal consequences if violated. Your code enforces them, not your prompt.

[click] Irreversible actions. Any action that cannot be undone — a delete, a financial send, a deployment — needs a confirmation gate in your code. Prompt-based caution is not enough.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 4 — When Prompt-Based Guidance Is Appropriate
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">When Prompt-Based Guidance Is Appropriate</div>

<div class="di-body" style="margin-top: 0.75rem;">

<v-click>
<p>Prompt-based guidance is the right choice when you want <strong>consistent behavior</strong> in areas where some flexibility and judgment are acceptable — and where violations are correctable.</p>
</v-click>

<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.75rem; margin-top: 0.6rem;">

  <v-click>
  <div style="background: white; border: 1px solid #c8e6d0; border-radius: 6px; padding: 0.6rem 0.8rem; font-size: 0.9rem;">
    <div style="font-weight: 700; color: #1B8A5A; margin-bottom: 0.25rem;">Tone and style</div>
    "Always respond professionally." "Avoid jargon." A deviation is awkward, not catastrophic.
  </div>
  </v-click>

  <v-click>
  <div style="background: white; border: 1px solid #c8e6d0; border-radius: 6px; padding: 0.6rem 0.8rem; font-size: 0.9rem;">
    <div style="font-weight: 700; color: #1B8A5A; margin-bottom: 0.25rem;">Output format preferences</div>
    "Always reply in bullet points." "Use markdown tables when comparing options." The model can exercise judgment.
  </div>
  </v-click>

  <v-click>
  <div style="background: white; border: 1px solid #c8e6d0; border-radius: 6px; padding: 0.6rem 0.8rem; font-size: 0.9rem;">
    <div style="font-weight: 700; color: #1B8A5A; margin-bottom: 0.25rem;">Scope guidance</div>
    "Focus on topics relevant to our product." "Decline off-topic requests politely." Violations are annoying, not harmful.
  </div>
  </v-click>

  <v-click>
  <div style="background: white; border: 1px solid #c8e6d0; border-radius: 6px; padding: 0.6rem 0.8rem; font-size: 0.9rem;">
    <div style="font-weight: 700; color: #1B8A5A; margin-bottom: 0.25rem;">User experience preferences</div>
    "Ask clarifying questions when the request is ambiguous." These shape behavior without requiring guarantees.
  </div>
  </v-click>

</div>

</div>

<img src="/logo.png" class="di-logo" />

<!--
Prompt-based guidance isn't wrong — it's the right tool for a different category of constraints.

Use it when you want consistent behavior in areas where some flexibility is acceptable and where violations are correctable.

[click] Tone and style guidelines. "Always respond professionally." A violation produces an awkward response — not a financial loss.

[click] Output format preferences. "Use bullet points." "Use markdown tables when comparing options." These shape how the model presents information. The model can exercise judgment about when to deviate.

[click] Scope guidance. "Focus on topics relevant to our product." If the model goes slightly off-topic in an edge case, you review and adjust the prompt.

[click] UX behavior preferences. Asking clarifying questions, providing caveats, acknowledging limitations. These are behaviors you want, not constraints you must enforce.

The common thread: these are all areas where "generally follows the rule" is good enough. They are stylistic and behavioral, not financial, legal, or security-critical.
-->

---
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 5 — Programmatic Enforcement in Code
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">Programmatic Enforcement — The Code Pattern</div>

<v-click>

```python {all|3-11|14-25|all}
# The refund tool — programmatic limit enforced in the execution layer
def process_refund(order_id: str, amount: float, user_id: str) -> dict:

    # Step 1: Programmatic authorization — verify ownership in your system
    order = db.get_order(order_id)
    if order.customer_id != user_id:
        return {"error": "Unauthorized: order does not belong to this user"}

    # Step 2: Programmatic financial limit — not in the prompt, in the code
    if amount > 500.00:
        return {"error": f"Refund amount ${amount:.2f} exceeds the $500 limit. Requires supervisor approval."}

    # Step 3: Execute the action — only reached if all gates pass
    result = payment_gateway.issue_refund(order_id, amount)
    return {"success": True, "refund_id": result.id, "amount": amount}


# The system prompt uses guidance for behavior, not for financial limits
SYSTEM_PROMPT = """
You are a customer support agent. Help customers resolve issues professionally.

When a customer requests a refund:
- Look up their order first using get_order
- Then call process_refund with the order ID and requested amount
- If the refund tool returns an error, explain the situation to the customer politely
"""
# Notice: the $500 limit is NOT in the system prompt. It's in the tool.
```

</v-click>

<v-click>
<div style="display: flex; gap: 0.75rem; margin-top: 0.4rem; font-size: 0.82rem; color: #1A3A4A;">
  <div style="flex: 1; background: white; padding: 0.4rem 0.6rem; border-radius: 4px; border-left: 2px solid #E53E3E;">
    <strong style="color: #E53E3E;">Wrong:</strong> "Never issue refunds over $500" in the system prompt
  </div>
  <div style="flex: 1; background: white; padding: 0.4rem 0.6rem; border-radius: 4px; border-left: 2px solid #3CAF50;">
    <strong style="color: #1B8A5A;">Right:</strong> reject in the tool function — Claude never bypasses it
  </div>
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Here's the canonical pattern for programmatic enforcement.

The process_refund tool function enforces two hard constraints in code, before the action executes.

First, authorization: verify that the order belongs to the requesting user. This check happens against your database. The model's interpretation of who owns what is irrelevant.

[click] Second, the financial limit: if the refund amount exceeds $500, return an error before issuing anything. Not "usually block it." Block it. Always.

Notice the system prompt. It contains behavioral guidance — look up the order first, explain errors politely, be professional. But the $500 limit does not appear there. It's in the code.

[click] This is the architectural principle: constraints with financial, legal, or safety consequences live in the code. Behavioral preferences live in the prompt. Never conflate them.
-->

---
layout: two-cols
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 6 — Decision Matrix
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header" style="margin: -1.5rem -1rem 1rem -2rem; padding-right: 1rem;">Decision Matrix: Which Mechanism to Use</div>

<v-click>
<div style="padding-right: 1.2rem;">
  <div class="di-col-left-label">Use Programmatic Enforcement</div>
  <div class="di-col-body">
    <ul>
      <li>Irreversible actions (delete, send, deploy)</li>
      <li>Financial thresholds and limits</li>
      <li>Identity and authorization checks</li>
      <li>Compliance and regulatory requirements</li>
      <li>Security controls (rate limits, input validation)</li>
      <li>Anything where "almost always" is not good enough</li>
    </ul>
    <div class="di-col-warning">
      <strong>Signal:</strong> if a violation would require incident response, use code
    </div>
  </div>
</div>
</v-click>

::right::

<v-click>
<div style="padding-left: 1.2rem; padding-top: 5rem;">
  <div class="di-col-right-label">Use Prompt-Based Guidance</div>
  <div class="di-col-body">
    <ul>
      <li>Tone, voice, and style</li>
      <li>Output format preferences</li>
      <li>Domain focus and scope</li>
      <li>Conversational behavior patterns</li>
      <li>Persona and branding guidelines</li>
      <li>Anything where judgment and flexibility are acceptable</li>
    </ul>
    <div style="margin-top: 0.5rem; background: #E8F5EB; padding: 0.5rem 0.7rem; border-radius: 5px; font-size: 0.88rem;">
      <strong>Signal:</strong> if a violation would require a prompt update, use the prompt
    </div>
  </div>
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Here's a practical decision matrix.

Use programmatic enforcement for anything where a violation would require incident response: irreversible actions, financial thresholds, authorization checks, compliance requirements, security controls. If "almost always" is not good enough — if you need a guarantee — use code.

[click] Use prompt-based guidance for anything where a violation would require a prompt update: tone, format, domain scope, conversational behavior, persona. These are areas where the model's judgment and flexibility are acceptable, and where you can monitor and adjust.

The diagnostic question is simple: if this constraint is violated, is it a production incident or a prompt revision? That answer tells you which mechanism to use.
-->

---
layout: default
class: di-exam-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 7 — Exam Tip
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-exam-banner">⚡ EXAM TIP</div>

<v-click>
<div class="di-exam-subtitle">The Probabilistic / Deterministic Distinction</div>

<div class="di-exam-body">
  This is one of the most-tested distinctions in Domain 1. The exam presents a constraint and asks whether it should be enforced programmatically or via prompt. The correct answer always follows the same logic.
</div>
</v-click>

<v-click>
<div class="di-trap-box">
  <div class="di-trap-label">❌ Common Wrong Answer</div>
  "Include the rule in the system prompt with emphasis — use ALL CAPS or multiple repetitions to ensure the model follows it."<br><br>
  <em>This is always wrong for financial, legal, safety, or irreversible constraints.</em> Emphasis does not change the probabilistic nature of prompt-based guidance.
</div>
</v-click>

<v-click>
<div class="di-correct-box">
  <div class="di-correct-label">✓ The Pattern to Apply</div>
  Ask: <strong>Is the consequence of violation a production incident?</strong><br>
  Yes → enforce in code (tool layer, middleware, pre-execution check).<br>
  No → use a prompt instruction.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
This is one of the most-tested distinctions in Domain 1.

The exam presents a constraint — a financial limit, a tone requirement, a compliance rule — and asks whether it should be enforced programmatically or via the system prompt.

[click] The trap answer is always some variation of: "Put it in the system prompt with strong language — use emphasis, repeat it, make it clear." Candidates choose this because it seems sufficient for well-behaved models.

But emphasis does not change the probabilistic nature of prompt-based guidance. No amount of emphasis makes a system prompt instruction deterministic.

[click] The pattern to apply: ask whether a violation would be a production incident. Financial loss? Legal exposure? Security breach? Irreversible action? That's a code enforcement problem. A tone mismatch or a format deviation? That's a prompt guidance problem.

Apply this test and you'll answer correctly on every scenario the exam presents.
-->

---
layout: default
class: di-takeaway-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 8 — Key Takeaways
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-takeaway-title">Programmatic Enforcement vs Prompt Guidance</div>

<ul class="di-takeaway-list">
  <v-click><li><strong>Programmatic enforcement = deterministic.</strong> Your code prevents violations unconditionally — the model never gets the opportunity to choose differently.</li></v-click>
  <v-click><li><strong>Prompt-based guidance = probabilistic.</strong> The model generally follows instructions, but this is a statistical outcome — not a guarantee.</li></v-click>
  <v-click><li>Use code for: financial limits, authorization, compliance, irreversible actions, security controls</li></v-click>
  <v-click><li>Use prompts for: tone, style, format preferences, domain scope, conversational behavior</li></v-click>
  <v-click><li>Diagnostic test: <em>"Would a violation require incident response?"</em> Yes = enforce in code. No = prompt guidance.</li></v-click>
  <v-click><li>Emphasis in a system prompt does <strong>not</strong> make a probabilistic constraint deterministic</li></v-click>
</ul>

<img src="/logo.png" class="di-logo" style="opacity: 0.75;" />

<!--
To summarize what you need to take from this lecture:

Programmatic enforcement is deterministic. Your code prevents violations unconditionally. The model never gets the choice.

Prompt-based guidance is probabilistic. The model generally follows instructions — but generally is not always.

Use code for financial limits, authorization, compliance requirements, irreversible actions, and security controls.

Use prompts for tone, style, format, scope, and conversational behavior.

The diagnostic test: would a violation require incident response? Yes — enforce in code. No — prompt guidance.

And the most important exam point: putting a constraint in the system prompt with emphasis does not make it deterministic. It's still probabilistic. The only way to make a constraint deterministic is to enforce it in your code.
-->
