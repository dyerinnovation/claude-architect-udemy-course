---
theme: default
title: "Lecture 3.10: Programmatic Enforcement vs Prompt-Based Guidance"
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
const progContent = "Your code prevents it — unconditionally. The model never gets the opportunity to make a different choice. Reliability: deterministic. Example: block any refund > $500 in the tool execution layer."
const promptContent = "You instruct the model in the system prompt to follow a rule. The model generally will — but it's a statistical outcome, not a guarantee. Reliability: probabilistic. Example: 'Always use a professional tone when responding to customers.'"

const enforceBullets = [
  { label: 'Financial operations', detail: 'Refund limits, transfer caps, transaction thresholds — enforce in the tool execution layer, NOT the prompt.' },
  { label: 'Identity and authorization', detail: 'Only allow actions on resources the authenticated user owns — verified by your code against your DB.' },
  { label: 'Compliance boundaries', detail: 'Data residency, PII handling, regulated data access — legal consequences if violated.' },
  { label: 'Irreversible actions', detail: 'Deletions, sends, deployments — require a confirmation gate in code, regardless of prompt.' },
]

const guideBullets = [
  { label: 'Tone and style', detail: "'Always respond professionally.' 'Avoid jargon.' Deviation is awkward, not catastrophic." },
  { label: 'Output format preferences', detail: "'Bullet points.' 'Markdown tables when comparing.' The model can exercise judgment." },
  { label: 'Scope guidance', detail: "'Focus on topics relevant to our product.' Violations are annoying, not harmful." },
  { label: 'UX preferences', detail: "'Ask clarifying questions when ambiguous.' Shape behavior without guarantees." },
]

const progLeft = [
  'Irreversible actions (delete, send, deploy)',
  'Financial thresholds and limits',
  'Identity and authorization checks',
  'Compliance and regulatory requirements',
  'Security controls (rate limits, input validation)',
  "Anything where 'almost always' is not good enough",
]
const promptRight = [
  'Tone, voice, and style',
  'Output format preferences',
  'Domain focus and scope',
  'Conversational behavior patterns',
  'Persona and branding guidelines',
  'Anything where judgment/flexibility is acceptable',
]

const takeaways = [
  { label: 'Programmatic enforcement = deterministic', detail: 'Code prevents violations unconditionally; the model never gets the chance to make a different call.' },
  { label: 'Prompt-based guidance = probabilistic', detail: 'The model generally follows instructions — a statistical outcome, not a guarantee.' },
  { label: 'Use code for hard constraints', detail: 'Financial limits, authorization, compliance, irreversible actions, security controls.' },
  { label: 'Use prompts for soft preferences', detail: 'Tone, style, format preferences, domain scope, conversational behavior.' },
  { label: 'Diagnostic test', detail: "Ask: 'Would a violation require incident response?' Yes → code. No → prompt." },
  { label: 'Emphasis does not promote probabilistic to deterministic', detail: 'ALL CAPS, repetition, or strong wording in a system prompt does not change the statistical nature of the instruction.' },
]

const enforceCode = `# Programmatic enforcement — the $500 limit is NOT in the system prompt.
def process_refund(order_id: str, amount_cents: int, user_id: str) -> dict:
    order = db.orders.get(order_id)

    # Authorization: only act on resources the user owns.
    if order.customer_id != user_id:
        return {
            "status": "error",
            "errorCategory": "authorization",
            "isRetryable": False,
            "description": f"User {user_id} not authorized for order {order_id}.",
        }

    # Financial limit — enforced in code, not prompt.
    MAX_REFUND_CENTS = 50_000  # $500
    if amount_cents > MAX_REFUND_CENTS:
        return {
            "status": "error",
            "errorCategory": "limit_exceeded",
            "isRetryable": False,
            "description": (
                f"Refund of \${amount_cents/100:.2f} exceeds "
                f"auto-approval limit of $500. Escalate to human agent."
            ),
        }

    return db.process_refund(order_id, amount_cents)


# System prompt — describes behavior but does NOT state the $500 limit.
SYSTEM_PROMPT = """
You are a customer support agent. Use the process_refund tool when
customers have a legitimate refund claim. Always respond empathetically
and professionally. Explain next steps clearly.
"""`
</script>

<Frame bg="var(--forest-900)" color="var(--mint-100)" :pad="false">
  <div style="position:absolute; inset:0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%);"></div>
  <div style="position:relative; z-index:1; padding:110px 120px 96px; width:100%; height:100%; display:flex; flex-direction:column; justify-content:space-between;">
    <div style="display:flex; align-items:center; gap:24px;">
      <img src="/assets/logo-mark.png" alt="" style="width:72px; height:auto;" />
      <div style="font-family: var(--font-body); font-size:26px; font-weight:500; letter-spacing:0.14em; text-transform:uppercase; color: var(--mint-200);">Dyer Innovation</div>
    </div>
    <div>
      <div style="font-family: var(--font-body); font-size:26px; font-weight:600; letter-spacing:0.16em; text-transform:uppercase; color: var(--sprout-500); margin-bottom:40px;">Lecture 3.10 &middot; Domain 1</div>
      <h1 style="font-family: var(--font-display); font-weight:500; font-size:128px; line-height:1.02; letter-spacing:-0.025em; color: var(--paper-0); margin:0; max-width:1600px;">Programmatic <span style="color: var(--sprout-500);">Enforcement</span><br />vs Prompt Guidance</h1>
      <div style="font-family: var(--font-display); font-size:44px; color: var(--mint-200); margin-top:40px; font-weight:400; max-width:1300px; line-height:1.3;">Deterministic code versus probabilistic prompts.</div>
    </div>
    <div style="display:flex; align-items:center; gap:48px; font-family: var(--font-body); font-size:26px; color: var(--mint-200); letter-spacing:0.06em;">
      <span>Domain 1 · 27%</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>Scenarios 1 &amp; 4</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>Sets up 3.11 hooks</span>
    </div>
  </div>
</Frame>

<!--
Welcome to Lecture 3.10 — Programmatic Enforcement vs Prompt-Based Guidance. This is one of the most frequently tested distinctions in Domain 1, and it's a distinction you have to internalize before the rest of the domain makes sense. Every rule in your agent system has a home: either your code enforces it, or your prompt requests it. Get the home wrong and you get production incidents. This lecture gives you the diagnostic test — and Lecture 3.11 will show you the mechanism.
-->

---

<TwoColSlide
  variant="compare"
  title="The Fundamental Fork: Deterministic vs Probabilistic"
  eyebrow="Two reliability models"
  leftLabel="Programmatic Enforcement"
  rightLabel="Prompt-Based Guidance"
  :footerNum="2"
  :footerTotal="8"
>
  <template #left>
    <p>{{ progContent }}</p>
  </template>
  <template #right>
    <p>{{ promptContent }}</p>
  </template>
</TwoColSlide>

<!--
Here's the fundamental fork. Programmatic enforcement means your code prevents a violation, unconditionally. The model never gets the opportunity to make a different choice — the guarantee lives in the tool execution layer, not in the prompt. Reliability is deterministic. If you block any refund over $500 in the refund tool, the refund is blocked — always. Prompt-based guidance is the opposite: you instruct the model in the system prompt, and the model generally follows the instruction — but "generally" is statistical, not guaranteed. Reliability is probabilistic. Asking the model to "always use a professional tone" is guidance. Blocking a tool call above a threshold is enforcement. These are not two flavors of the same thing; they're two different reliability models, and you choose between them based on the consequence of a violation.
-->

---

<BulletReveal
  eyebrow="Enforce in code"
  title="When Programmatic Enforcement Is Required"
  :bullets="enforceBullets"
  :footerNum="3"
  :footerTotal="8"
/>

<!--
Four categories where programmatic enforcement is required. Financial operations: refund limits, transfer caps, transaction thresholds — enforce these in the tool execution layer, never in the prompt. A prompt instruction to "never refund more than $500" will work most of the time, and then one day it won't. Identity and authorization: only allow actions on resources the authenticated user actually owns. This is a correctness and security requirement that must be verified in code against your database, not described in a prompt. Compliance boundaries: data residency rules, PII handling, regulated data access — legal consequences if you violate them. Irreversible actions: deletions, emails, deployments — anything where "oops" is not recoverable needs a confirmation gate in code. The common thread: whenever the consequence of a violation is irreversible, financially material, legally significant, or a security risk, the rule belongs in code.
-->

---

<BulletReveal
  eyebrow="Prompt is enough"
  title="When Prompt-Based Guidance Is Appropriate"
  :bullets="guideBullets"
  :footerNum="4"
  :footerTotal="8"
/>

<!--
On the other side of the fork, four categories where prompt-based guidance is not only appropriate but preferable. Tone and style: "always respond professionally," "avoid jargon" — deviation here is awkward, not catastrophic. Output format preferences: bullets, tables, Markdown — the model can exercise judgment based on context. Scope guidance: "focus on topics relevant to our product" — violations are annoying, not harmful. UX preferences: "ask clarifying questions when ambiguous" — shapes behavior without requiring guarantees. The common thread: when "generally follows" is good enough, a prompt is the right tool. These are stylistic and behavioral, not financial or legal or safety-critical. A probabilistic instruction is exactly the right instrument for a probabilistic goal.
-->

---

<CodeBlockSlide
  eyebrow="Code pattern"
  title="Programmatic Enforcement in Code"
  lang="python"
  :code="enforceCode"
  annotation="The $500 limit is in the code, not the prompt. Claude never gets the chance to bypass it. Structured error response tells Claude exactly how to recover."
  :footerNum="5"
  :footerTotal="8"
/>

<!--
Here's enforcement in practice. The process_refund function does two things before any refund executes. First, authorization: it checks that the authenticated user actually owns the order — if not, it returns a structured error with errorCategory, isRetryable, and a human-readable description. Second, the financial limit: $500 enforced in code. If the amount exceeds the cap, the tool returns a structured limit_exceeded error. Critically, the $500 figure appears only in the code — not in the system prompt. The system prompt describes tone and behavior: "respond empathetically, explain next steps clearly." It does NOT say "never refund more than $500." That limit does not belong in prose where it can be overridden or reasoned around. It belongs in the tool where Claude is physically incapable of exceeding it.
-->

---

<TwoColSlide
  variant="compare"
  title="Decision Matrix: Which Mechanism to Use"
  eyebrow="Use this checklist"
  leftLabel="Use Programmatic Enforcement"
  rightLabel="Use Prompt-Based Guidance"
  :footerNum="6"
  :footerTotal="8"
>
  <template #left>
    <ul>
      <li v-for="(b, i) in progLeft" :key="i">{{ b }}</li>
    </ul>
  </template>
  <template #right>
    <ul>
      <li v-for="(b, i) in promptRight" :key="i">{{ b }}</li>
    </ul>
  </template>
</TwoColSlide>

<!--
A decision matrix you can apply on exam day and in production. On the left — programmatic enforcement — you get: irreversible actions, financial thresholds and limits, identity and authorization checks, compliance and regulatory requirements, security controls like rate limits and input validation, and anything where "almost always" is not good enough. On the right — prompt-based guidance — you get: tone and voice, output format preferences, domain focus and scope, conversational behavior patterns, persona and branding, and anything where judgment and flexibility are acceptable. The diagnostic test is simple: if a violation would require an incident response, it belongs in code. If a violation would just require a prompt update, it belongs in the prompt. That test answers almost every exam question in this category.
-->

---

<Frame>
  <Eyebrow>⚡ Exam tip</Eyebrow>
  <SlideTitle>The Probabilistic / Deterministic Distinction</SlideTitle>
  <div style="margin-top: 40px; display: grid; grid-template-columns: 1fr 1fr; gap: 32px; flex: 1; min-height: 0;">
    <CalloutBox variant="dont" title="Common wrong answer">
      <p>"Include the rule in the system prompt with emphasis — use ALL CAPS or multiple repetitions to ensure the model follows it."</p>
      <p>This is <strong>always wrong</strong> for financial, legal, safety, or irreversible constraints. Emphasis does not change the probabilistic nature of a prompt instruction.</p>
    </CalloutBox>
    <CalloutBox variant="do" title="Pattern to apply">
      <p>Ask: <em>is the consequence of violation a production incident?</em></p>
      <p>Yes → enforce in code: tool layer, middleware, pre-execution check. No → prompt instruction.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Domain 1 · Enforcement distinction" :num="7" :total="8" />
</Frame>

<!--
The exam trap. A question describes a scenario with a hard constraint — a financial limit, an authorization rule, something irreversible — and one of the distractor answers is "put it in the system prompt with emphasis, or repeat the rule multiple times." This answer is designed to look right because the rule IS about the model's behavior. But emphasis does not change the probabilistic nature of a prompt instruction. A system prompt that says "NEVER refund over $500" in all caps is still statistical — the model will usually follow it, and the one time it doesn't is a production incident. The decision rule: ask whether a violation would require incident response. If yes, enforce in code. If no, a prompt is fine. That's the whole exam-grade heuristic for this category.
-->

---

<BulletReveal
  eyebrow="Takeaways"
  title="Programmatic Enforcement vs Prompt Guidance"
  :bullets="takeaways"
  :footerNum="8"
  :footerTotal="8"
/>

<!--
Six takeaways. One — programmatic enforcement is deterministic: your code prevents violations unconditionally. Two — prompt-based guidance is probabilistic: the model generally follows instructions, but it's a statistical outcome. Three — use code for financial limits, authorization, compliance, irreversible actions, and security controls. Four — use prompts for tone, style, format preferences, domain scope, and conversational behavior. Five — the diagnostic test: "would a violation require incident response?" Yes means code. No means prompt. And six — emphasis in a system prompt, even ALL CAPS or repetition, does NOT promote a probabilistic constraint to a deterministic one. In the next lecture, 3.11, we'll look at hooks — the specific Agent SDK mechanism that implements programmatic enforcement cleanly and centrally.
-->
