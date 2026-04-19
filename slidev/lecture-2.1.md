---
theme: default
title: "Lecture 2.1: The Messages API — Anatomy of a Request and Response"
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
  <div class="di-cover-title">The Messages API:<br>Anatomy of a <span style="color: #3CAF50;">Request &amp; Response</span></div>
  <div class="di-cover-subtitle">Lecture 2.1 · Claude Certified Architect – Foundations</div>
</div>

<img src="/logo.png" class="di-logo-centered" />

<!--
You've probably called the Claude API before.

But do you actually know what every field does?

Most developers — and most exam candidates — learn just enough to make it work.

That's not enough to pass the CCA-F exam.

Today we're going to dissect every part of a request and response. By the end of this lecture, you'll know what each field is, what it does, and why it exists.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 2 — The Five Core Request Parameters
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">The Five Core Request Parameters</div>

<div class="di-body" style="margin-top: 0.5rem;">

<p>Every call to <code class="di-code-inline">client.messages.create()</code> shares the same skeleton. Five parameters to know cold:</p>

<div style="display: flex; flex-direction: column; gap: 0.35rem; margin-top: 0.5rem;">
  <v-click>
  <div class="di-step-card">
    <span class="di-step-num">model</span>
    Which Claude to use — e.g. <code class="di-code-inline">claude-sonnet-4-6</code>
  </div>
  </v-click>
  <v-click>
  <div class="di-step-card">
    <span class="di-step-num">max_tokens</span>
    Hard ceiling on how many tokens Claude can generate in the response
  </div>
  </v-click>
  <v-click>
  <div class="di-step-card">
    <span class="di-step-num">messages</span>
    Conversation history — an array of turns with roles and content
  </div>
  </v-click>
  <v-click>
  <div class="di-step-card">
    <span class="di-step-num">system</span>
    Persistent instructions that apply to the entire conversation
  </div>
  </v-click>
  <v-click>
  <div class="di-step-card" style="border-left-color: #E3A008;">
    <span class="di-step-num" style="color: #E3A008;">temperature</span>
    Controls how creative or deterministic the output is
  </div>
  </v-click>
</div>

</div>

<img src="/logo.png" class="di-logo" />

<!--
Every call to client.messages.create() shares the same skeleton.

There are five parameters you need to know cold.

model tells the API which Claude to use — claude-sonnet-4-6, for example.

max_tokens sets the hard ceiling on how many tokens Claude can generate in the response.

messages is the conversation history — an array of turns with roles and content.

system is where you put persistent instructions that apply to the whole conversation.

temperature controls how creative or deterministic the output is.

These five parameters are the foundation of everything else in this section.
-->

---
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 3 — A Complete Request, Annotated
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">A Complete Request, Annotated</div>

<v-click>

```python
import anthropic

client = anthropic.Anthropic()  # Uses ANTHROPIC_API_KEY from environment

response = client.messages.create(
    model="claude-sonnet-4-6",    # Which Claude model to use
    max_tokens=1024,                        # Max tokens in the response
    system="You are a helpful assistant.",  # Top-level system prompt
    messages=[
        {"role": "user",      "content": "What is the capital of France?"},
        {"role": "assistant", "content": "The capital of France is Paris."},
        {"role": "user",      "content": "What is its population?"}
    ]
)
```

</v-click>

<v-click>
<div style="display: flex; gap: 0.75rem; margin-top: 0.6rem; font-size: 0.82rem; color: #1A3A4A;">
  <div style="flex: 1; background: white; border-radius: 4px; padding: 0.4rem 0.6rem; border-left: 3px solid #3CAF50;">
    <strong style="color: #1B8A5A;">system is top-level</strong> — never inside the <code>messages</code> array
  </div>
  <div style="flex: 1; background: white; border-radius: 4px; padding: 0.4rem 0.6rem; border-left: 3px solid #0D7377;">
    <strong style="color: #0D7377;">Roles alternate</strong> — only <code>"user"</code> and <code>"assistant"</code>
  </div>
  <div style="flex: 1; background: white; border-radius: 4px; padding: 0.4rem 0.6rem; border-left: 3px solid #E3A008;">
    <strong style="color: #E3A008;">No memory</strong> — you pass history every call
  </div>
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Let's look at a real, complete request.

Notice a few things here. system is at the top level of the call — not inside the messages array.

The messages array alternates between "user" and "assistant" roles.

The conversation history is your responsibility to maintain and pass each time.

Claude has no memory between calls — everything it knows about the conversation is in this array.
-->

---
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 4 — The Response Object, Dissected
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">The Response Object, Dissected</div>

<v-click>

```json
{
  "id": "msg_01XFDUDYJgAACzvnptvVoYEL",
  "type": "message",
  "role": "assistant",
  "content": [
    { "type": "text", "text": "The population of Paris..." }
  ],
  "model": "claude-sonnet-4-6",
  "stop_reason": "end_turn",
  "stop_sequence": null,
  "usage": { "input_tokens": 42, "output_tokens": 31 }
}
```

</v-click>

<v-click>
<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.5rem; margin-top: 0.6rem; font-size: 0.82rem; color: #1A3A4A;">
  <div style="background: white; border-radius: 4px; padding: 0.4rem 0.6rem; border-left: 3px solid #3CAF50;">
    <strong style="color: #1B8A5A;">content is a list</strong> of typed blocks — not a string
  </div>
  <div style="background: white; border-radius: 4px; padding: 0.4rem 0.6rem; border-left: 3px solid #0D7377;">
    <strong style="color: #0D7377;">stop_reason</strong> tells you <em>why</em> Claude stopped
  </div>
  <div style="background: white; border-radius: 4px; padding: 0.4rem 0.6rem; border-left: 3px solid #E3A008;">
    <code>"type": "text"</code> for plain output; <code>"tool_use"</code> when tools fire
  </div>
  <div style="background: white; border-radius: 4px; padding: 0.4rem 0.6rem; border-left: 3px solid #1A3A4A;">
    <strong>usage</strong> is exactly what you're billed for
  </div>
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Now let's look at what comes back.

The content field is a list, not a string. Even a simple text response is wrapped in a content block with "type": "text".

That list structure matters — when tool use is involved, you'll see "type": "tool_use" blocks instead.

stop_reason tells you why Claude stopped generating. end_turn means Claude finished naturally. max_tokens means it hit the ceiling you set. stop_sequence means a custom stop string was triggered.

usage tells you exactly what you're being billed for.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 5 — stop_reason Values You'll See
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">stop_reason — The Four Values You'll See</div>

<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.6rem; margin-top: 0.5rem;">
  <v-click>
  <div class="di-step-card">
    <span class="di-step-num">end_turn</span>
    Claude finished naturally
  </div>
  </v-click>
  <v-click>
  <div class="di-step-card" style="border-left-color: #E3A008;">
    <span class="di-step-num" style="color: #E3A008;">max_tokens</span>
    Hit the ceiling you set — response may be cut off
  </div>
  </v-click>
  <v-click>
  <div class="di-step-card" style="border-left-color: #0D7377;">
    <span class="di-step-num" style="color: #0D7377;">stop_sequence</span>
    A custom stop string triggered
  </div>
  </v-click>
  <v-click>
  <div class="di-step-card" style="border-left-color: #1A3A4A;">
    <span class="di-step-num" style="color: #1A3A4A;">tool_use</span>
    Claude wants to call a tool — loop continues
  </div>
  </v-click>
</div>

<v-click>
<div style="background: #FFF8E6; border-left: 3px solid #E3A008; padding: 0.5rem 0.8rem; border-radius: 4px; font-size: 0.9rem; margin-top: 0.8rem;">
  <strong>Production rule:</strong> always check <code class="di-code-inline">stop_reason</code>. If it's <code>"max_tokens"</code>, the response was cut off — you may need to continue it.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
stop_reason is the field you'll return to again and again throughout this course.

end_turn means Claude finished naturally. max_tokens means it hit the ceiling you set — which means the response may be cut off. stop_sequence means a custom stop string was triggered. tool_use means Claude wants to call a tool — the loop must continue.

The production rule: always check stop_reason. If it's "max_tokens", you may need to continue the response with another call.
-->

---
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 6 — Reading the Response in Code
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">Reading the Response in Code</div>

<v-click>

```python
# Most common case: access the first text block directly
answer = response.content[0].text
print(answer)

# Safer: iterate over all content blocks
for block in response.content:
    if block.type == "text":
        print(block.text)

# Check why Claude stopped
print(response.stop_reason)  # "end_turn", "max_tokens", "stop_sequence", "tool_use"

# Check token usage
print(f"Input: {response.usage.input_tokens}")
print(f"Output: {response.usage.output_tokens}")
```

</v-click>

<v-click>
<div style="display: flex; gap: 0.75rem; margin-top: 0.6rem; font-size: 0.82rem; color: #1A3A4A;">
  <div style="flex: 1; background: white; border-radius: 4px; padding: 0.4rem 0.6rem; border-left: 3px solid #3CAF50;">
    <strong style="color: #1B8A5A;">Quick &amp; dirty</strong> — <code>content[0].text</code> works for simple text replies
  </div>
  <div style="flex: 1; background: white; border-radius: 4px; padding: 0.4rem 0.6rem; border-left: 3px solid #E3A008;">
    <strong style="color: #E3A008;">Production</strong> — iterate content blocks, especially with tools
  </div>
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Knowing the structure matters when you go to read the response.

The shortcut response.content[0].text works for simple cases. But in production — especially with tools — you should always iterate over response.content.

Checking stop_reason is important for robustness. If stop_reason is "max_tokens", the response was cut off and you may need to continue it.
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
<div class="di-exam-subtitle">System Is NOT a Role</div>

<div class="di-exam-body">
  The <code class="di-code-inline">system</code> parameter is always a <strong>top-level</strong> field in <code class="di-code-inline">client.messages.create()</code> — never inside the <code>messages</code> array. The only valid roles in <code>messages</code> are <code>"user"</code> and <code>"assistant"</code>.
</div>
</v-click>

<v-click>
<div class="di-trap-box">
  <div class="di-trap-label">❌ Distractor Pattern</div>
  <code>{"role": "system", "content": "..."}</code> inside the <code>messages</code> array — that's OpenAI's API, not Claude's.
</div>
</v-click>

<v-click>
<div class="di-correct-box">
  <div class="di-correct-label">✓ Correct Pattern</div>
  <code>system="..."</code> sits alongside <code>model</code> and <code>max_tokens</code> at the top of the call.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Here's the exam trap you need to watch for: passing the system prompt as a message in the messages array using role: "system". This is not valid in the Claude API.

The system parameter is always top-level in client.messages.create(), never inside the messages array. The only valid roles in messages are "user" and "assistant".

If you see a question showing {"role": "system", "content": "..."} inside the messages array, that is the wrong answer. That pattern comes from OpenAI's API and does not work here.
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
  <v-click><li>Every <code>messages.create()</code> call needs <code>model</code>, <code>max_tokens</code>, and <code>messages</code> — <code>system</code> is a separate top-level parameter</li></v-click>
  <v-click><li>The <code>messages</code> array only accepts two roles: <code>"user"</code> and <code>"assistant"</code> — <code>"system"</code> is <strong>not</strong> a valid role</li></v-click>
  <v-click><li>Responses return a <code>content</code> list of typed blocks — <code>"text"</code> for plain output, <code>"tool_use"</code> when tools are involved</li></v-click>
  <v-click><li><code>stop_reason</code> tells you why generation ended — always check it in production to handle truncated responses</li></v-click>
</ul>

<img src="/logo.png" class="di-logo" style="opacity: 0.75;" />

<!--
Four things to hold onto from this lecture.

Every messages.create() call requires model, max_tokens, and messages — the system parameter is separate from the array.

The messages array only accepts two roles: "user" and "assistant" — "system" is not a valid role.

Responses return a content list of typed blocks — always "text" for plain responses, "tool_use" when tools are involved.

stop_reason tells you why generation ended — always check it in production code to handle truncated responses.
-->
