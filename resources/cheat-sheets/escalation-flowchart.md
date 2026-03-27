# Escalation Decision Flowchart

## The Core Rule

**Escalate if the situation requires human judgment. Don't escalate just because the customer is unhappy.**

---

## Decision Flowchart (Text-Based)

```
┌─────────────────────────────────────────────────────┐
│ Customer Request Arrives                             │
└─────────────────────┬───────────────────────────────┘
                      │
        ┌─────────────▼──────────────┐
        │ Does customer explicitly    │
        │ ask for a human?            │
        │ ("I want to speak to...")   │
        └──────┬──────────────┬───────┘
               │ YES          │ NO
         ┌─────▼────────┐     │
         │ ESCALATE     │     │
         │ IMMEDIATELY  │     │
         └──────────────┘     │
               │ (Stop here)  │
               │              │
        ┌──────▼──────────────────────────┐
        │ Is there a POLICY GAP?           │
        │ (No rule covers this situation)  │
        │ Silent on the issue?             │
        └──────┬─────────────────┬────────┘
               │ YES             │ NO
         ┌─────▼────────┐        │
         │ ESCALATE     │        │
         │ (Policy gap) │        │
         └──────────────┘        │
               │ (Stop)          │
               │                 │
        ┌──────▼───────────────────────────┐
        │ Can Claude make PROGRESS         │
        │ toward resolution?                │
        │ (Despite missing info, tools,    │
        │  or constraints)                  │
        └──────┬──────────────────┬────────┘
               │ YES              │ NO (stuck)
               │                  │
         ┌─────▼────────┐   ┌─────▼────────┐
         │ CONTINUE     │   │ ESCALATE     │
         │ helping      │   │ (No progress)│
         └──────────────┘   └──────────────┘
               │                  │ (Stop)
               │                  │
        ┌──────▼────────────────────────────┐
        │ Handle request appropriately      │
        └───────────────────────────────────┘
```

---

## Valid Escalation Triggers

### ✓ Trigger 1: Explicit Request
```
Customer: "I need to speak to a supervisor"
Action: ESCALATE IMMEDIATELY
Reasoning: Customer explicitly demands human involvement
```

### ✓ Trigger 2: Policy Silence
```
Customer: "Can I return items without a receipt?"
System: Policy doesn't address this
Action: ESCALATE
Reasoning: No rule to apply; human judgment needed
```

### ✓ Trigger 3: Unable to Progress
```
Customer: "I need access to account ABC123"
System: Lacks permission to grant; no restore tool available
Action: ESCALATE
Reasoning: Blocked at architectural/permission level
```

---

## NOT Valid Escalation Triggers

### ❌ Trigger: Customer Sentiment (Frustration)
```
Customer: "I'm FURIOUS about this!"
Action: DO NOT ESCALATE
Instead:
  1. Acknowledge frustration
  2. Explain what you can help with
  3. Offer concrete next steps
  4. ASK if they'd like to escalate (their choice)
```

**Why?** Escalation on emotion wastes human resources and frustrates support teams.

### ❌ Trigger: Customer Confidence Claim
```
Customer: "I'm 95% sure this is your fault"
Action: DO NOT ESCALATE
Instead: Investigate objectively; help with evidence
```

**Why?** Self-reported confidence ≠ actual need for escalation.

### ❌ Trigger: Long Conversation
```
Customer: [5 messages back-and-forth]
Action: DO NOT ESCALATE (just because it's long)
Instead: Continue if making progress
```

**Why?** Escalation should be need-based, not length-based.

---

## The Frustrated Customer Pattern

```
Customer appears angry/frustrated
       │
       ├─ Do they ask for a human? → YES → ESCALATE
       │
       ├─ Can I help resolve their issue? → YES → Help + Empathize
       │                                       (Don't escalate)
       │
       └─ Can't help + no explicit request → OFFER escalation
                                              (Let them choose)
```

**Key:** Acknowledge frustration without escalating. Example:

```
Customer: "This is ridiculous! Your system is broken!"

Response:
"I understand you're frustrated — this is clearly important.
I can help you [SPECIFIC ACTION]. If you'd prefer to work
with a specialist, I can escalate you."

→ Offer choice, don't force escalation
```

---

## Policy Gap Example

```
Customer: "Can I change my billing address after payment?"

System Rules:
- Address changes allowed before payment ✓
- Address changes allowed 14 days after delivery ✓
- Address changes within 2-14 days of delivery ??? (GAP)

Action: ESCALATE
```

---

## Unable to Progress Example

```
Customer: "I forgot my 2FA device"

System:
- Need 2FA to disable 2FA ✗ (circular)
- No backup codes set up ✗
- No recovery email verified ✗

Action: ESCALATE (human can verify identity another way)
```

---

## Quick Checklist

- [ ] Customer explicitly asks for human? → Escalate
- [ ] Policy is silent on this situation? → Escalate
- [ ] You're blocked (no tool, no permission, no authority)? → Escalate
- [ ] Customer is frustrated but resolvable? → Empathize + continue
- [ ] You're making progress? → Continue
- [ ] Customer seems confident but unverified? → Investigate, don't escalate

---

## Key Insight

**Escalation is not a reward for emotional expression.** It's a tool for situations that genuinely need human judgment. Use it for:
- Policy gaps
- Blocked progress
- Explicit requests
- Permission/authority limits

Don't use it for frustration, confusion, or length of conversation.
