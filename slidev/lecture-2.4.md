---
theme: default
title: "Lecture 2.4: Prefilled Assistant Messages — Shaping Output from the Start"
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
const prefillUses = [
  { label: 'Force JSON to open with {', detail: 'Structured output that begins correctly' },
  { label: 'Eliminate preamble', detail: "No 'Certainly!' or 'Great question!'" },
  { label: 'Open a code block', detail: '```python — forces language tag immediately' },
  { label: 'Lock in persona', detail: "Character voice mid-conversation without breaking immersion" },
]

const takeaways = [
  { label: 'Assistant-role last', detail: "A prefill is an assistant-role message placed LAST in the messages array — Claude continues from its content" },
  { label: 'Not in response body', detail: 'Prefill text is NOT in the response body — prepend it yourself when reconstructing' },
  { label: 'Common uses', detail: 'Force JSON {, eliminate preamble, open code fences, lock in persona' },
  { label: 'Pair with stop_sequences', detail: 'Prefill opens, stop sequence closes — exactly what you need' },
]

const jsonCode = `import anthropic, json
client = anthropic.Anthropic()

user_data = "Name: Alice Chen, Role: Staff Engineer, Team: Platform"

response = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=256,
    messages=[
        {
            "role": "user",
            "content": f"Extract the following into JSON with keys name, role, team:\\n\\n{user_data}"
        },
        {
            # Prefill: Claude will continue from this exact character
            "role": "assistant",
            "content": "{"
        }
    ]
)

# Re-attach the opening brace Claude was given, then parse
raw = "{" + response.content[0].text
result = json.loads(raw)`

const codeFencePrefill = `# Force a Python code block to open:
{
    "role": "assistant",
    "content": "\\\`\\\`\\\`python\\n"
}

# Force specific phrasing at the start:
{
    "role": "assistant",
    "content": "The answer is:"
}`

const combinedCode = `response = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=512,
    stop_sequences=["</answer>"],
    messages=[
        {"role": "user", "content": "What is 12 * 8? Respond inside <answer> tags."},
        {"role": "assistant", "content": "<answer>"}   # prefill
    ]
)
# response.content[0].text contains only what's between the tags`
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
      <div class="lec-cover__section">Section 2 · Lecture 2.4 · Domain 2</div>
      <h1 class="lec-cover__title">Prefilled Assistant Messages</h1>
      <div class="lec-cover__subtitle">Shaping Output from the Start</div>
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
.lec-cover__title { font-family: var(--font-display); font-weight: 500; font-size: 112px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1500px; }
.lec-cover__subtitle { font-family: var(--font-display); font-size: 48px; color: var(--mint-200); margin-top: 32px; font-weight: 400; max-width: 1400px; line-height: 1.3; }
.lec-cover__stats { display: flex; align-items: center; gap: 36px; font-family: var(--font-body); font-size: 24px; color: var(--mint-200); letter-spacing: 0.06em; }
.lec-cover__dot { opacity: 0.4; }
.exam-stack { margin-top: 48px; display: flex; flex-direction: column; gap: 28px; flex: 1; min-height: 0; }
</style>

<!--
You've asked Claude to extract structured data and return JSON. Instead you get: "Sure! Here's the JSON you asked for..." then the JSON.

That preamble is harmless in a chat app. But in a production pipeline, it breaks your JSON parser immediately.

The fix is a technique called prefilling, and it's one of the most useful tools in your API toolkit.

Let's look at exactly how it works.
-->

---

<!-- SLIDE 2 — What is a prefill -->

<TwoColSlide
  variant="compare"
  title="What Is a Prefill?"
  leftLabel="Visualized"
  rightLabel="Mechanic"
>
  <template #left>
    <p><strong>user</strong></p>
    <p>↓</p>
    <p><strong>assistant</strong></p>
    <p>↓</p>
    <p><strong>user</strong></p>
    <p>↓</p>
    <p><strong>assistant — PREFILL</strong></p>
    <p style="font-style: italic; color: var(--forest-500); font-size: 20px;">Claude continues from here ↓</p>
  </template>
  <template #right>
    <ul>
      <li><strong>Normally</strong> — end with a <code>user</code> turn → Claude writes the next <code>assistant</code> turn</li>
      <li><strong>Prefill</strong> — end with an <code>assistant</code> turn → Claude continues from that exact character</li>
      <li><strong>Effect</strong> — Claude cannot add anything before your text; you control the first token</li>
    </ul>
  </template>
</TwoColSlide>

<!--
The messages parameter in the API is just an array of turns. Each turn has a role — either "user" or "assistant".

Normally you end with a user turn, and Claude writes the next assistant turn.

A prefill means you end the array with an assistant turn instead.

You're essentially handing Claude a partial sentence and saying: finish this. Claude will continue from that exact character, word for word. It cannot add anything before the text you provided.

That's the power — you control the very first token of the response.
-->

---

<!-- SLIDE 3 — Four common uses -->

<BulletReveal
  eyebrow="When to prefill"
  title="Four Common Prefill Use Cases"
  :bullets="prefillUses"
/>

<!--
Prefilling is useful in four common situations.

First: forcing structured output to start correctly, like JSON beginning with {.

Second: eliminating filler like "Certainly!" or "Great question!" from the response.

Third: forcing a code block to open immediately with the right language tag.

Fourth: locking in a character voice mid-conversation without breaking immersion.

All four of these share the same underlying mechanic. You're not adding a special parameter. You're using the structure of the messages array itself.
-->

---

<!-- SLIDE 4 — JSON Extraction Prefill -->

<CodeBlockSlide
  eyebrow="Example"
  title="JSON Extraction Prefill"
  lang="python"
  :code="jsonCode"
  annotation="⚠ Prefill text is NOT in the response body. Claude returns only what it generated AFTER the prefill — prepend it yourself."
/>

<!--
Notice that the last message in the array has role: "assistant". That single opening brace is the prefill. Claude continues from that character — it cannot add a preamble before it.

One important detail: the prefill text is NOT included in the response body. Claude returns only what it generated after the prefill.

So when you reconstruct the full value, you prepend the prefill yourself — that "{" on the last line.
-->

---

<!-- SLIDE 5 — Code fence and fixed phrase prefills -->

<CodeBlockSlide
  eyebrow="More prefill patterns"
  title="Code Generation & Format Prefills"
  lang="python"
  :code="codeFencePrefill"
  annotation="Code fence: eliminates intros before code. Fixed phrase: eliminates response-opening variation."
/>

<!--
The same technique works for any output format you need to lock in.

For code generation, prefill with the opening fence and language tag. Claude will now write Python code directly — no introduction, no explanation first.

For format control, prefill with the exact phrase you want to start the response. This eliminates any variation in how Claude opens its response. It's especially useful when you're parsing outputs downstream with string operations.
-->

---

<!-- SLIDE 6 — Prefills + Stop Sequences -->

<CodeBlockSlide
  eyebrow="Power pair"
  title="Prefills + Stop Sequences"
  lang="python"
  :code="combinedCode"
  annotation="Prefill controls START · Stop sequence controls END · Response = exactly what's between the tags, zero regex."
/>

<!--
Prefills and stop sequences solve opposite halves of the same problem. A prefill controls where Claude starts. A stop sequence controls where Claude stops. Together, they let you extract exactly what you want from a response.

Here's the pattern: prefill with an opening XML tag, stop at the closing tag.

The response will be the content between the tags — nothing before, nothing after. That's a clean extraction with zero post-processing regex.
-->

---

<!-- SLIDE 7 — Exam Tip -->

<Frame>
  <Eyebrow>⚡ Exam Tip</Eyebrow>
  <SlideTitle>There Is No prefill Parameter</SlideTitle>
  <div class="exam-stack">
    <CalloutBox variant="dont" title="Distractor pattern">
      <p>Candidates look for a dedicated <code>prefill</code> parameter in the API or believe you need a special flag to enable this behavior.</p>
    </CalloutBox>
    <CalloutBox variant="do" title="The entire mechanic">
      <p>Last message role: <code>"user"</code> → Claude starts a fresh response.<br/>Last message role: <code>"assistant"</code> → Claude continues from its content.</p>
    </CalloutBox>
  </div>
</Frame>

<!--
Here's the exam trap: candidates look for a dedicated prefill parameter in the API or believe you need a special flag to enable this behavior.

There is no such parameter. Prefilling works purely through the structure of the messages array. You add a message with role: "assistant" as the final entry, and Claude continues from its content.

If the last message has role: "user", Claude starts a fresh response. If it has role: "assistant", Claude continues from exactly where you left off. That's the entire mechanic — know it cold.
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

A prefill is an "assistant" role message placed last in the messages array — Claude continues from its content, adding nothing before it.

The prefill text is not included in the response body — prepend it yourself when reconstructing the full output.

Common uses: force JSON to open with {, eliminate preamble, start code fences, lock in a persona.

Pair prefills with stop_sequences to bound output on both ends — the cleanest way to extract structured content.
-->
