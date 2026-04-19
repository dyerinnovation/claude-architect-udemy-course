---
theme: default
title: "Lecture 2.4: Prefilled Assistant Messages — Shaping Output from the Start"
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
  <div class="di-cover-title">Prefilled Assistant Messages:<br>Shaping Output <span style="color: #3CAF50;">from the Start</span></div>
  <div class="di-cover-subtitle">Lecture 2.4 · Claude Certified Architect – Foundations</div>
</div>

<img src="/logo.png" class="di-logo-centered" />

<!--
You've asked Claude to extract structured data and return JSON. Instead you get: "Sure! Here's the JSON you asked for..." then the JSON.

That preamble is harmless in a chat app. But in a production pipeline, it breaks your JSON parser immediately.

The fix is a technique called prefilling, and it's one of the most useful tools in your API toolkit.

Let's look at exactly how it works.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 2 — What Is a Prefill?
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">What Is a Prefill?</div>

<div style="display: grid; grid-template-columns: 0.85fr 1.15fr; gap: 1.2rem; margin-top: 0.5rem; align-items: start;">

  <v-click>
  <div style="display: flex; flex-direction: column; gap: 0.3rem;">
    <div class="di-flow-box">user</div>
    <div class="di-arrow">↓</div>
    <div class="di-flow-stop">assistant</div>
    <div class="di-arrow">↓</div>
    <div class="di-flow-box">user</div>
    <div class="di-arrow">↓</div>
    <div class="di-flow-tool">assistant — PREFILL</div>
    <div style="font-size: 0.72rem; text-align: center; color: #6B7280; font-style: italic;">Claude continues from here ↓</div>
  </div>
  </v-click>

  <div style="font-size: 0.95rem; color: #111928; line-height: 1.65;">
    <v-click>
    <div class="di-step-card">
      <span class="di-step-num">Normally</span>
      you end with a <code class="di-code-inline">user</code> turn, and Claude writes the next <code>assistant</code> turn
    </div>
    </v-click>
    <v-click>
    <div class="di-step-card" style="border-left-color: #E3A008;">
      <span class="di-step-num" style="color: #E3A008;">Prefill</span>
      end the array with an <code>assistant</code> turn — Claude continues from that exact character
    </div>
    </v-click>
    <v-click>
    <div class="di-step-card" style="border-left-color: #0D7377;">
      <span class="di-step-num" style="color: #0D7377;">Effect</span>
      Claude cannot add anything before your text — you control the <strong>first token</strong>
    </div>
    </v-click>
  </div>

</div>

<img src="/logo.png" class="di-logo" />

<!--
The messages parameter in the API is just an array of turns. Each turn has a role — either "user" or "assistant".

Normally you end with a user turn, and Claude writes the next assistant turn.

A prefill means you end the array with an assistant turn instead.

You're essentially handing Claude a partial sentence and saying: finish this. Claude will continue from that exact character, word for word. It cannot add anything before the text you provided.

That's the power — you control the very first token of the response.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 3 — When Prefilling Is the Right Tool
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">When Prefilling Is the Right Tool</div>

<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.6rem; margin-top: 0.5rem;">

  <v-click>
  <div class="di-step-card">
    <span class="di-step-num">1 · { }</span>
    Force structured output to start correctly — JSON beginning with <code class="di-code-inline">{</code>
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card" style="border-left-color: #0D7377;">
    <span class="di-step-num" style="color: #0D7377;">2 · 🚫 filler</span>
    Eliminate preamble like "Certainly!" or "Great question!"
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card" style="border-left-color: #E3A008;">
    <span class="di-step-num" style="color: #E3A008;">3 · ``` </span>
    Force a code block to open immediately with the right language tag
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card" style="border-left-color: #1A3A4A;">
    <span class="di-step-num" style="color: #1A3A4A;">4 · persona</span>
    Lock in a character voice mid-conversation without breaking immersion
  </div>
  </v-click>

</div>

<v-click>
<div style="background: #F0FFF4; border-left: 3px solid #3CAF50; padding: 0.5rem 0.8rem; border-radius: 4px; font-size: 0.9rem; margin-top: 0.8rem;">
  All four share the same mechanic. <strong>There is no special parameter</strong> — you're just using the structure of the <code>messages</code> array itself.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Prefilling is useful in four common situations.

First: forcing structured output to start correctly, like JSON beginning with {.

Second: eliminating filler like "Certainly!" or "Great question!" from the response.

Third: forcing a code block to open immediately with the right language tag.

Fourth: locking in a character voice mid-conversation without breaking immersion.

All four of these share the same underlying mechanic. You're not adding a special parameter. You're using the structure of the messages array itself.
-->

---
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 4 — The Code — JSON Extraction Prefill
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">JSON Extraction Prefill</div>

<v-click>

```python
import anthropic, json
client = anthropic.Anthropic()

user_data = "Name: Alice Chen, Role: Staff Engineer, Team: Platform"

response = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=256,
    messages=[
        {
            "role": "user",
            "content": f"Extract the following into JSON with keys name, role, team:\n\n{user_data}"
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
result = json.loads(raw)
```

</v-click>

<v-click>
<div class="di-trap-box" style="margin-top: 0.5rem;">
  <div class="di-trap-label">⚠ Critical detail</div>
  The prefill text is <strong>NOT</strong> included in the response body. Claude returns only what it generated <em>after</em> the prefill — prepend it yourself when reconstructing the full value.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Notice that the last message in the array has role: "assistant". That single opening brace is the prefill. Claude continues from that character — it cannot add a preamble before it.

One important detail: the prefill text is NOT included in the response body. Claude returns only what it generated after the prefill.

So when you reconstruct the full value, you prepend the prefill yourself — that "{" on the last line.
-->

---
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 5 — Code Generation and Format Prefills
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">Code Generation &amp; Format Prefills</div>

<v-click>

<div style="font-size: 0.85rem; color: #1A3A4A; font-weight: 600; margin-bottom: 0.25rem;">Force a Python code block to open:</div>

````python
{
    "role": "assistant",
    "content": "```python\n"
}
````

</v-click>

<v-click>

<div style="font-size: 0.85rem; color: #1A3A4A; font-weight: 600; margin: 0.6rem 0 0.25rem 0;">Force specific phrasing at the start:</div>

```python
{
    "role": "assistant",
    "content": "The answer is:"
}
```

</v-click>

<v-click>
<div style="background: #F0FFF4; border-left: 3px solid #3CAF50; padding: 0.5rem 0.8rem; border-radius: 4px; font-size: 0.88rem; margin-top: 0.6rem;">
  Prefilling with a code fence eliminates introductions before the code. Prefilling with a fixed phrase eliminates variation in how Claude opens its response — especially useful when parsing downstream with string operations.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
The same technique works for any output format you need to lock in.

For code generation, prefill with the opening fence and language tag. Claude will now write Python code directly — no introduction, no explanation first.

For format control, prefill with the exact phrase you want to start the response. This eliminates any variation in how Claude opens its response. It's especially useful when you're parsing outputs downstream with string operations.
-->

---
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 6 — Prefills and Stop Sequences — The Power Pair
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">Prefills + Stop Sequences — The Power Pair</div>

<v-click>
<div style="display: flex; gap: 0.5rem; align-items: center; margin-bottom: 0.6rem;">
  <div class="di-flow-stop" style="flex: 1;">Prefill<br><span style="font-size: 0.72rem; opacity: 0.85;">controls the START</span></div>
  <div style="color: #0D7377; font-size: 1.1rem;">→</div>
  <div class="di-flow-box" style="flex: 1;">Claude generates</div>
  <div style="color: #0D7377; font-size: 1.1rem;">→</div>
  <div style="background: #E53E3E; color: white; border-radius: 6px; padding: 0.5rem 1rem; font-weight: 600; font-size: 0.9rem; text-align: center; flex: 1;">
    Stop Sequence<br><span style="font-size: 0.72rem; opacity: 0.85;">controls the END</span>
  </div>
</div>
</v-click>

<v-click>

```python
response = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=512,
    stop_sequences=["</answer>"],
    messages=[
        {"role": "user", "content": "What is 12 * 8? Respond inside <answer> tags."},
        {"role": "assistant", "content": "<answer>"}   # prefill
    ]
)
# response.content[0].text contains only what's between the tags
```

</v-click>

<v-click>
<div style="background: #F0FFF4; border-left: 3px solid #3CAF50; padding: 0.5rem 0.8rem; border-radius: 4px; font-size: 0.88rem; margin-top: 0.5rem;">
  The response contains <strong>only what's between the tags</strong> — nothing before, nothing after. Clean extraction with zero post-processing regex.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Prefills and stop sequences solve opposite halves of the same problem. A prefill controls where Claude starts. A stop sequence controls where Claude stops. Together, they let you extract exactly what you want from a response.

Here's the pattern: prefill with an opening XML tag, stop at the closing tag.

The response will be the content between the tags — nothing before, nothing after. That's a clean extraction with zero post-processing regex.
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
<div class="di-exam-subtitle">There Is No <code>prefill</code> Parameter</div>

<div class="di-exam-body">
  Prefilling works purely through the structure of the <code class="di-code-inline">messages</code> array. There is no special flag or dedicated parameter to enable this behavior.
</div>
</v-click>

<v-click>
<div class="di-trap-box">
  <div class="di-trap-label">❌ Distractor Pattern</div>
  Candidates look for a dedicated <code>prefill</code> parameter in the API or believe you need a special flag to enable prefilling.
</div>
</v-click>

<v-click>
<div class="di-correct-box">
  <div class="di-correct-label">✓ The Entire Mechanic</div>
  Last message is <code>role: "user"</code> → Claude starts a fresh response.<br>
  Last message is <code>role: "assistant"</code> → Claude continues from exactly where you left off.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Here's the exam trap: candidates look for a dedicated prefill parameter in the API or believe you need a special flag to enable this behavior.

There is no such parameter. Prefilling works purely through the structure of the messages array. You add a message with role: "assistant" as the final entry, and Claude continues from its content.

If the last message has role: "user", Claude starts a fresh response. If it has role: "assistant", Claude continues from exactly where you left off. That's the entire mechanic — know it cold.
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
  <v-click><li>A prefill is an <code>"assistant"</code> role message placed <strong>last</strong> in the <code>messages</code> array — Claude continues from its content, adding nothing before it</li></v-click>
  <v-click><li>The prefill text is <strong>not included</strong> in the response body — prepend it yourself when reconstructing the full output</li></v-click>
  <v-click><li>Common uses: force JSON to open with <code>{</code>, eliminate preamble, start code fences, lock in a persona</li></v-click>
  <v-click><li>Pair prefills with <code>stop_sequences</code> to bound output on both ends — the cleanest way to extract structured content</li></v-click>
</ul>

<img src="/logo.png" class="di-logo" style="opacity: 0.75;" />

<!--
Four things to hold onto.

A prefill is an "assistant" role message placed last in the messages array — Claude continues from its content, adding nothing before it.

The prefill text is not included in the response body — prepend it yourself when reconstructing the full output.

Common uses: force JSON to open with {, eliminate preamble, start code fences, lock in a persona.

Pair prefills with stop_sequences to bound output on both ends — the cleanest way to extract structured content.
-->
