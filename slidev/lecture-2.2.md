---
theme: default
title: "Lecture 2.2: System Prompts — Where Instructions Live"
info: |
  Claude Certified Architect – Foundations
  Section 2: Claude API Fundamentals Bootcamp
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
  <div class="di-course-label">Section 2 · Claude API Fundamentals Bootcamp</div>
  <div class="di-cover-title">System Prompts:<br>Where <span style="color: #3CAF50;">Instructions</span> Live</div>
  <div class="di-cover-subtitle">Lecture 2.2 · Claude Certified Architect – Foundations</div>
</div>

<img src="/logo.png" class="di-logo-centered" />

<!--
Here's a scenario you'll see on the exam.

A developer builds a customer support bot for an airline. They put the bot's persona instructions in the first user message. Three turns in, the bot starts answering like a general assistant — no persona, no constraints.

What went wrong? The instructions were in the wrong place.

Understanding the system parameter is one of the most high-value things you can learn today.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 2 — What the System Parameter Actually Is
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">What the <code>system</code> Parameter Actually Is</div>

<div style="display: grid; grid-template-columns: 0.9fr 1.1fr; gap: 1.2rem; margin-top: 0.5rem; align-items: start;">

  <v-click>
  <div>
    <div style="background: #E3A008; color: white; border-radius: 6px; padding: 0.55rem 0.9rem; font-weight: 700; font-size: 0.92rem; text-align: center;">
      system = "You are Aria, airline support..."
    </div>
    <div style="font-size: 0.75rem; color: #1B8A5A; text-align: center; margin-top: 0.2rem; font-style: italic;">applies to all turns</div>
    <div class="di-arrow">↓</div>
    <div style="background: white; border: 1px solid #c8e6d0; border-radius: 6px; padding: 0.5rem 0.8rem;">
      <div style="font-size: 0.8rem; color: #0D7377; font-weight: 600;">messages array</div>
      <div style="font-size: 0.78rem; color: #111928; margin-top: 0.3rem; line-height: 1.4;">
        user → assistant → user → assistant → ...
      </div>
      <div style="font-size: 0.72rem; color: #6B7280; margin-top: 0.25rem; font-style: italic;">(no instructions repeated)</div>
    </div>
  </div>
  </v-click>

  <div style="font-size: 0.95rem; color: #111928; line-height: 1.65;">
    <v-click>
    <div class="di-step-card">
      <span class="di-step-num">Top-level</span>
      a field in <code class="di-code-inline">messages.create()</code> — <em>outside</em> the <code>messages</code> array
    </div>
    </v-click>
    <v-click>
    <div class="di-step-card">
      <span class="di-step-num">Standing brief</span>
      Claude reads it before the conversation begins
    </div>
    </v-click>
    <v-click>
    <div class="di-step-card">
      <span class="di-step-num">Persistent</span>
      applies automatically across every turn — write once, apply everywhere
    </div>
    </v-click>
  </div>

</div>

<img src="/logo.png" class="di-logo" />

<!--
The system parameter is a top-level field in every messages.create() call. It lives outside the messages array — above it, conceptually.

Think of it as a standing brief that Claude reads before the conversation begins. It persists automatically across every turn in the conversation. You write it once. It applies everywhere.

The messages array holds the conversation itself — the back-and-forth dialogue. The system parameter holds the rules, persona, and constraints for that dialogue.

These are fundamentally different things and they belong in different places.
-->

---
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 3 — The Right Way — System Parameter in Action
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">✓ Correct: <code>system</code> as a Top-Level Parameter</div>

<v-click>

```python
import anthropic
client = anthropic.Anthropic()

# System prompt defined once — applies to every turn
SYSTEM_PROMPT = """You are Aria, a friendly customer support agent for SkyLine Airlines.
You only answer questions about flights, baggage, and reservations.
If asked about anything else, politely redirect the customer."""

response = client.messages.create(
    model="claude-3-5-sonnet-20241022",
    max_tokens=1024,
    system=SYSTEM_PROMPT,       # Top-level parameter — NOT in messages array
    messages=[
        {"role": "user", "content": "Hi, I need to change my seat on flight SK442."}
    ]
)

print(response.content[0].text)
```

</v-click>

<v-click>
<div style="background: #F0FFF4; border-left: 3px solid #3CAF50; padding: 0.5rem 0.8rem; border-radius: 4px; font-size: 0.88rem; margin-top: 0.6rem;">
  <strong>system</strong> sits alongside <code>model</code> and <code>max_tokens</code> — Aria's persona is established before the first user message. You never repeat the system prompt inside <code>messages</code>.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Here's what correct usage looks like.

Notice the system parameter sits alongside model and max_tokens — not inside messages.

Aria's persona and constraints are established before the first user message. Every subsequent turn in this conversation will operate under those rules.

You never repeat the system prompt in the messages array.
-->

---
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 4 — The Wrong Way — Instructions in the User Message
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">✗ Wrong: Instructions Buried in a User Message</div>

<v-click>

```python
# WRONG: Embedding instructions inside the first user message
response = client.messages.create(
    model="claude-3-5-sonnet-20241022",
    max_tokens=1024,
    # No system parameter
    messages=[
        {
            "role": "user",
            # Instructions mixed into a user turn — this is the mistake
            "content": """You are Aria, a customer support agent for SkyLine Airlines.
Only answer questions about flights, baggage, and reservations.

Hi, I need to change my seat on flight SK442."""
        }
    ]
)
```

</v-click>

<v-click>
<div class="di-trap-box" style="margin-top: 0.6rem;">
  <div class="di-trap-label">❌ Why this breaks</div>
  Works for one turn. After that, instructions are buried in history as a user message — they may not influence later turns. <strong>If you truncate history to save tokens, the instructions disappear entirely.</strong> A system prompt is never truncated from history.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Now let's look at the pattern that breaks things.

This works for exactly one turn. When the conversation continues, you have a problem.

The instructions are now buried in the history as a user message. They're not guaranteed to influence future turns the same way a real system prompt would.

And here's the critical difference: you're responsible for replaying the full messages array on every API call. If you truncate the history to save tokens, you lose the instructions entirely.

A system prompt, by contrast, always comes through — it's never truncated from the history.
-->

---
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 5 — Multi-Turn Behavior
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">Multi-Turn: Why <code>system</code> Persists</div>

<v-click>

```python
# YOU maintain conversation history across turns
conversation_history = []

def chat(user_message):
    conversation_history.append({"role": "user", "content": user_message})

    response = client.messages.create(
        model="claude-3-5-sonnet-20241022",
        max_tokens=1024,
        system="You are Aria, SkyLine Airlines support. Only discuss flights.",
        messages=conversation_history   # Full history sent every call
    )

    reply = response.content[0].text
    conversation_history.append({"role": "assistant", "content": reply})
    return reply

chat("Can I change my seat?")           # Turn 1 — persona active
chat("What about baggage fees?")        # Turn 2 — persona STILL active
chat("Can you help me book a hotel?")   # Turn 3 — Aria redirects, correctly
```

</v-click>

<v-click>
<div style="background: #F0FFF4; border-left: 3px solid #3CAF50; padding: 0.5rem 0.8rem; border-radius: 4px; font-size: 0.88rem; margin-top: 0.6rem;">
  The <code>system</code> prompt is re-sent on every call — but because it's a separate parameter, it's never confused with the conversation itself. Even if you trim <code>messages</code> history, the system prompt stays intact.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Let's see this play out across multiple turns.

The system prompt is re-sent on every API call — you pass it every time. But because it's a separate parameter, it's never confused with the conversation itself.

Even if you trim your messages history to save tokens, the system prompt stays intact.

This is exactly why the system parameter exists as a distinct field.
-->

---
layout: two-cols
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 6 — When to Use System vs. User-Level
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header" style="margin: -1.5rem -1rem 1rem -2rem; padding-right: 1rem;">When to Use <code>system</code> vs. User-Level Instructions</div>

<v-click>
<div style="padding-right: 1rem;">
  <div class="di-col-left-label">Use <code>system</code> parameter</div>
  <div class="di-col-body">
    <p><em>Anything that must be true for every turn.</em></p>
    <ul>
      <li>Persona and role definitions</li>
      <li>Output format constraints ("always respond in JSON")</li>
      <li>Safety guardrails and topic restrictions</li>
      <li>Tool usage policies</li>
    </ul>
  </div>
</div>
</v-click>

::right::

<div style="padding-left: 1rem; padding-top: 5rem;">
  <v-click>
  <div class="di-col-right-label">Use <code>messages</code> content</div>
  <div class="di-col-body">
    <p><em>Anything specific to a single turn.</em></p>
    <ul>
      <li>Dynamic data (customer account details)</li>
      <li>One-off instructions for the current question</li>
      <li>Turn-specific context</li>
    </ul>
    <div style="margin-top: 0.75rem; text-align: center; font-size: 1.0rem; font-weight: 700; color: #1A3A4A;">
      Rule of thumb: if it must be true for every exchange → <code>system</code>.
    </div>
  </div>
  </v-click>
</div>

<img src="/logo.png" class="di-logo" />

<!--
Not every instruction belongs in the system prompt.

Use system for things that apply to the entire conversation from the start. Persona and role definitions go here. Output format constraints — like "always respond in JSON" — go here. Safety guardrails and topic restrictions go here.

Use the messages array for things that are specific to a single turn. If you need to inject dynamic data — like a customer's account details — that can go in the user message for that turn. One-off instructions that only apply to the current question belong in messages, not system.

The rule of thumb: if it needs to be true for every single exchange, it belongs in system.
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
<div class="di-exam-subtitle">System Prompts Persist. First User Messages Don't.</div>

<div class="di-exam-body">
  The <code class="di-code-inline">system</code> parameter is the <strong>only</strong> mechanism that guarantees instructions apply across all turns. User messages are conversation history — they can be truncated, and their influence on later turns is not guaranteed the same way.
</div>
</v-click>

<v-click>
<div class="di-trap-box">
  <div class="di-trap-label">❌ Distractor Pattern</div>
  Putting persona or role instructions in the first user message and assuming they'll persist through the conversation.
</div>
</v-click>

<v-click>
<div class="di-correct-box">
  <div class="di-correct-label">✓ Exam Signal</div>
  A scenario where a bot "forgets" its persona or breaks its rules after several turns → the root cause is almost always instructions placed in a user message rather than the <code>system</code> parameter.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Here's the exam trap: putting persistent role or persona instructions in the first user message instead of the system parameter, assuming they'll apply throughout the conversation.

The system parameter is the only mechanism that guarantees instructions apply across all turns. User messages are conversation history — they can be truncated, and their influence on later turns is not guaranteed the same way.

Watch for exam scenarios where a bot "forgets" its persona or breaks its rules after several turns — the root cause is almost always instructions placed in a user message rather than the system parameter.
-->

---
layout: default
class: di-takeaway-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 8 — Key Takeaways
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-takeaway-title">What to Remember</div>

<ul class="di-takeaway-list">
  <v-click><li>The <code>system</code> parameter is a <strong>top-level field</strong> alongside <code>model</code> and <code>max_tokens</code> — never inside the <code>messages</code> array</li></v-click>
  <v-click><li>System prompts apply to every turn automatically — same <code>system</code> value passed each call, never confused with conversation history</li></v-click>
  <v-click><li>Instructions in the first user message are part of history — they can be lost if history is truncated and don't behave like true system-level constraints</li></v-click>
  <v-click><li>Use <code>system</code> for persona, output format, safety rules — use <code>messages</code> for turn-specific context and dynamic data</li></v-click>
</ul>

<img src="/logo.png" class="di-logo" style="opacity: 0.75;" />

<!--
Four things to hold onto.

The system parameter is a top-level field alongside model and max_tokens — it is never inside the messages array.

System prompts apply to every turn automatically — you pass the same system value on every API call, and it's never confused with conversation history.

Instructions placed in the first user message are part of the conversation history — they can be lost if history is truncated and don't behave like true system-level constraints.

Use system for persona, output format, safety rules, and anything that must be true for the entire conversation — use messages for turn-specific context and dynamic data.
-->
