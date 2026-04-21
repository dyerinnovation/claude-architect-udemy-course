---
theme: default
title: "Lecture 2.2: System Prompts — Where Instructions Live"
info: |
  Claude Certified Architect – Foundations
  Section 2: Claude API Fundamentals Bootcamp (Domain 2 · 18%)
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
const takeaways = [
  { label: 'Top-level field', detail: 'system is a top-level parameter alongside model and max_tokens — never inside the messages array' },
  { label: 'Auto-persists', detail: 'System prompts apply to every turn automatically — never confused with conversation history' },
  { label: 'User messages can be lost', detail: 'Instructions placed in the first user message are part of history — they can be truncated' },
  { label: 'Rule of thumb', detail: 'Use system for persona/format/safety; use messages for turn-specific data' },
]

const correctCode = `import anthropic
client = anthropic.Anthropic()

# System prompt defined once — applies to every turn
SYSTEM_PROMPT = """You are Aria, a friendly customer support agent for SkyLine Airlines.
You only answer questions about flights, baggage, and reservations.
If asked about anything else, politely redirect the customer."""

response = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    system=SYSTEM_PROMPT,       # Top-level parameter — NOT in messages array
    messages=[
        {"role": "user", "content": "Hi, I need to change my seat on flight SK442."}
    ]
)

print(response.content[0].text)`

const wrongCode = `# WRONG: Embedding instructions inside the first user message
response = client.messages.create(
    model="claude-sonnet-4-6",
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
)`

const chatCode = `# YOU maintain conversation history across turns
conversation_history = []

def chat(user_message):
    conversation_history.append({"role": "user", "content": user_message})

    response = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=1024,
        system="You are Aria, SkyLine Airlines support. Only discuss flights.",
        messages=conversation_history   # Full history sent every call
    )

    reply = response.content[0].text
    conversation_history.append({"role": "assistant", "content": reply})
    return reply

chat("Can I change my seat?")           # Turn 1 — persona active
chat("What about baggage fees?")        # Turn 2 — persona STILL active
chat("Can you help me book a hotel?")   # Turn 3 — Aria redirects, correctly`
</script>

---

<!-- SLIDE 1 — Cover -->

<Frame bg="var(--forest-900)" color="var(--mint-100)" :pad="false">
  <div class="lec-cover">
    <div class="lec-cover__brand">
      <img src="/assets/logo-mark.png" alt="" class="lec-cover__logo" />
      <div class="lec-cover__brand-text">Dyer Innovation</div>
    </div>
    <div>
      <div class="lec-cover__section">Section 2 · Lecture 2.2 · Domain 2</div>
      <h1 class="lec-cover__title">System Prompts</h1>
      <div class="lec-cover__subtitle">Where Instructions Live</div>
    </div>
    <div class="lec-cover__stats">
      <span>API Fundamentals Bootcamp</span>
      <span class="lec-cover__dot">&middot;</span>
      <span>Domain 2 · 18% weight</span>
    </div>
  </div>
</Frame>

<style>
.lec-cover { position: relative; z-index: 1; padding: 110px 120px 96px; width: 100%; height: 100%; display: flex; flex-direction: column; justify-content: space-between; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%); }
.lec-cover__brand { display: flex; align-items: center; gap: 24px; }
.lec-cover__logo { width: 72px; height: auto; }
.lec-cover__brand-text { font-family: var(--font-body); font-size: 26px; font-weight: 500; letter-spacing: 0.14em; text-transform: uppercase; color: var(--mint-200); }
.lec-cover__section { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px; }
.lec-cover__title { font-family: var(--font-display); font-weight: 500; font-size: 128px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1500px; }
.lec-cover__subtitle { font-family: var(--font-display); font-size: 48px; color: var(--mint-200); margin-top: 32px; font-weight: 400; max-width: 1400px; line-height: 1.3; }
.lec-cover__stats { display: flex; align-items: center; gap: 36px; font-family: var(--font-body); font-size: 24px; color: var(--mint-200); letter-spacing: 0.06em; }
.lec-cover__dot { opacity: 0.4; }
.exam-stack { margin-top: 48px; display: flex; flex-direction: column; gap: 28px; flex: 1; min-height: 0; }
</style>

<!--
Here's a scenario you'll see on the exam.

A developer builds a customer support bot for an airline. They put the bot's persona instructions in the first user message. Three turns in, the bot starts answering like a general assistant — no persona, no constraints.

What went wrong? The instructions were in the wrong place.

Understanding the system parameter is one of the most high-value things you can learn today.
-->

---

<!-- SLIDE 2 — What the System Parameter Actually Is -->

<TwoColSlide
  variant="compare"
  eyebrow="What it is"
  title="What the system Parameter Actually Is"
  leftLabel="Visualized"
  rightLabel="Three properties"
>
  <template #left>
    <p><strong>system =</strong> "You are Aria, airline support..."</p>
    <p style="color: var(--sprout-600); font-style: italic;">applies to all turns</p>
    <p>↓</p>
    <p><strong>messages array</strong></p>
    <p>user → assistant → user → assistant → ...</p>
    <p style="color: var(--forest-500); font-style: italic; font-size: 20px;">(no instructions repeated)</p>
  </template>
  <template #right>
    <ul>
      <li><strong>Top-level</strong> — a field in <code>messages.create()</code>, outside the <code>messages</code> array</li>
      <li><strong>Standing brief</strong> — Claude reads it before the conversation begins</li>
      <li><strong>Persistent</strong> — applies automatically across every turn</li>
    </ul>
  </template>
</TwoColSlide>

<!--
The system parameter is a top-level field in every messages.create() call. It lives outside the messages array — above it, conceptually.

Think of it as a standing brief that Claude reads before the conversation begins. It persists automatically across every turn in the conversation. You write it once. It applies everywhere.

The messages array holds the conversation itself — the back-and-forth dialogue. The system parameter holds the rules, persona, and constraints for that dialogue.

These are fundamentally different things and they belong in different places.
-->

---

<!-- SLIDE 3 — Correct usage -->

<CodeBlockSlide
  eyebrow="✓ Correct"
  title="system as a Top-Level Parameter"
  lang="python"
  :code="correctCode"
  annotation="system sits alongside model and max_tokens. Aria's persona is established before the first user message. Never repeat the system prompt inside messages."
/>

<!--
Here's what correct usage looks like.

Notice the system parameter sits alongside model and max_tokens — not inside messages.

Aria's persona and constraints are established before the first user message. Every subsequent turn in this conversation will operate under those rules.

You never repeat the system prompt in the messages array.
-->

---

<!-- SLIDE 4 — Wrong way -->

<CodeBlockSlide
  eyebrow="✗ Wrong"
  title="Instructions Buried in a User Message"
  lang="python"
  :code="wrongCode"
  annotation="Works for one turn. After that, instructions are conversation history — truncate history, instructions disappear. System prompts are never truncated."
/>

<!--
Now let's look at the pattern that breaks things.

This works for exactly one turn. When the conversation continues, you have a problem.

The instructions are now buried in the history as a user message. They're not guaranteed to influence future turns the same way a real system prompt would.

And here's the critical difference: you're responsible for replaying the full messages array on every API call. If you truncate the history to save tokens, you lose the instructions entirely.

A system prompt, by contrast, always comes through — it's never truncated from the history.
-->

---

<!-- SLIDE 5 — Multi-turn -->

<CodeBlockSlide
  eyebrow="Persistence"
  title="Multi-Turn: Why system Persists"
  lang="python"
  :code="chatCode"
  annotation="system is re-sent every call as a separate parameter — even if you trim messages history, system stays intact."
/>

<!--
Let's see this play out across multiple turns.

The system prompt is re-sent on every API call — you pass it every time. But because it's a separate parameter, it's never confused with the conversation itself.

Even if you trim your messages history to save tokens, the system prompt stays intact.

This is exactly why the system parameter exists as a distinct field.
-->

---

<!-- SLIDE 6 — When to use system vs messages -->

<TwoColSlide
  variant="compare"
  title="When to Use system vs. User-Level"
  leftLabel="Use system parameter"
  rightLabel="Use messages content"
>
  <template #left>
    <p><em>Anything that must be true for every turn.</em></p>
    <ul>
      <li>Persona and role definitions</li>
      <li>Output format constraints ("always respond in JSON")</li>
      <li>Safety guardrails and topic restrictions</li>
      <li>Tool usage policies</li>
    </ul>
  </template>
  <template #right>
    <p><em>Anything specific to a single turn.</em></p>
    <ul>
      <li>Dynamic data (customer account details)</li>
      <li>One-off instructions for the current question</li>
      <li>Turn-specific context</li>
    </ul>
    <p style="margin-top: 18px;"><strong>Rule of thumb:</strong> if it must be true for every exchange → <code>system</code>.</p>
  </template>
</TwoColSlide>

<!--
Not every instruction belongs in the system prompt.

Use system for things that apply to the entire conversation from the start. Persona and role definitions go here. Output format constraints — like "always respond in JSON" — go here. Safety guardrails and topic restrictions go here.

Use the messages array for things that are specific to a single turn. If you need to inject dynamic data — like a customer's account details — that can go in the user message for that turn. One-off instructions that only apply to the current question belong in messages, not system.

The rule of thumb: if it needs to be true for every single exchange, it belongs in system.
-->

---

<!-- SLIDE 7 — Exam Tip -->

<Frame>
  <Eyebrow>⚡ Exam Tip</Eyebrow>
  <SlideTitle>System Prompts Persist. First User Messages Don't.</SlideTitle>
  <div class="exam-stack">
    <CalloutBox variant="dont" title="Distractor pattern">
      <p>Putting persona or role instructions in the first user message and assuming they'll persist through the conversation.</p>
    </CalloutBox>
    <CalloutBox variant="do" title="Exam signal">
      <p>A scenario where a bot "forgets" its persona or breaks its rules after several turns → the root cause is almost always instructions placed in a user message rather than the <code>system</code> parameter.</p>
    </CalloutBox>
  </div>
</Frame>

<!--
Here's the exam trap: putting persistent role or persona instructions in the first user message instead of the system parameter, assuming they'll apply throughout the conversation.

The system parameter is the only mechanism that guarantees instructions apply across all turns. User messages are conversation history — they can be truncated, and their influence on later turns is not guaranteed the same way.

Watch for exam scenarios where a bot "forgets" its persona or breaks its rules after several turns — the root cause is almost always instructions placed in a user message rather than the system parameter.
-->

---

<!-- SLIDE 8 — Takeaways -->

<BulletReveal
  eyebrow="Takeaway"
  title="What to Remember"
  :bullets="takeaways"
/>

<!--
Four things to hold onto.

The system parameter is a top-level field alongside model and max_tokens — it is never inside the messages array.

System prompts apply to every turn automatically — you pass the same system value on every API call, and it's never confused with conversation history.

Instructions placed in the first user message are part of the conversation history — they can be lost if history is truncated and don't behave like true system-level constraints.

Use system for persona, output format, safety rules, and anything that must be true for the entire conversation — use messages for turn-specific context and dynamic data.
-->
