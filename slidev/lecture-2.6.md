---
theme: default
title: "Lecture 2.6: Response Streaming — Real-Time Output"
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
const eventSteps = [
  { title: 'message_start', body: 'message metadata: model name, message ID' },
  { title: 'content_block_start', body: 'a new content block is beginning (e.g. text block)' },
  { title: 'content_block_delta', body: 'the workhorse — repeats many times, carries text_delta' },
  { title: 'content_block_stop', body: 'closes the block when finished' },
  { title: 'message_delta', body: 'contains stop_reason + final usage stats ← exam tests this' },
]

const takeaways = [
  { label: 'SSE + event order', detail: 'message_start → content_block_start → content_block_delta* → content_block_stop → message_delta → message_stop' },
  { label: 'stop_reason lives in message_delta', detail: 'NOT in message_stop — tool args arrive as input_json_delta' },
  { label: 'Reduces TTFT, not total time', detail: 'Streaming changes perceived latency; total generation time unchanged' },
  { label: 'Stream for users, not batch', detail: 'Humans watching → stream; code parsing full response → don\'t' },
]

const sdkCode = `import anthropic

client = anthropic.Anthropic()

# The SDK's stream() context manager handles SSE for you
with client.messages.stream(
    model="claude-opus-4-7",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Explain REST APIs in plain English."}]
) as stream:
    # text_stream yields each text chunk as a plain string
    for text in stream.text_stream:
        print(text, end="", flush=True)  # flush=True = immediate output

# After the context exits, the final message is available
final_message = stream.get_final_message()
print(f"\\nStop reason: {final_message.stop_reason}")
print(f"Input tokens: {final_message.usage.input_tokens}")`

const rawCode = `import anthropic

client = anthropic.Anthropic()

# Use raw event iteration when you need to handle every event type
with client.messages.stream(
    model="claude-opus-4-7",
    max_tokens=1024,
    messages=[{"role": "user", "content": "List three benefits of microservices."}]
) as stream:
    for event in stream:
        if event.type == "content_block_delta":
            if event.delta.type == "text_delta":
                print(event.delta.text, end="", flush=True)
            elif event.delta.type == "input_json_delta":
                # Partial JSON from a tool call — accumulate this
                print(event.delta.partial_json, end="")
        elif event.type == "message_delta":
            # stop_reason is HERE, not in message_stop
            print(f"\\nStop reason: {event.delta.stop_reason}")`
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
      <div class="lec-cover__section">Section 2 · Lecture 2.6 · Domain 2</div>
      <h1 class="lec-cover__title">Response Streaming</h1>
      <div class="lec-cover__subtitle">Real-Time Output</div>
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
You build a Claude-powered chat app. Feature-complete, looks great. You ship it.

First user feedback: "feels slow."

You check the logs. Claude's returning responses in three seconds. Your network is fast. What's the problem?

The problem is that for three seconds, the user sees nothing. A blank screen or a spinner. In chat UX, that gap is fatal.

Streaming is the fix, and it's one of the most important UX concepts in the Claude API.
-->

---

<!-- SLIDE 2 — Why slow? -->

<TwoColSlide
  variant="antipattern-fix"
  title="Why Does Your App Feel Slow?"
  leftLabel="✗ No Streaming"
  rightLabel="✓ Streaming"
>
  <template #left>
    <p>⟳ ⟳ ⟳ 5s of spinner → wall of text.</p>
    <p><strong>Feels broken.</strong> Users close the tab.</p>
  </template>
  <template #right>
    <p>Text appears word by word, immediately.</p>
    <p><strong>Feels alive.</strong> Users stay engaged.</p>
    <p style="font-size: 20px; color: var(--forest-500); font-style: italic;">Same model. Same response. Different delivery.</p>
  </template>
</TwoColSlide>

<!--
Without streaming, here's what your users see: five seconds of nothing, then a wall of text appears all at once. The app feels broken. People close the tab.

With streaming, text begins appearing almost instantly — word by word, like the AI is typing. The app feels alive. Users stay engaged through the full response.

Same model. Same total generation time. Same final response. The only difference is how the response is delivered from the server to your app.
-->

---

<!-- SLIDE 3 — What is streaming -->

<TwoColSlide
  variant="compare"
  title="What Is Streaming, Actually?"
  leftLabel="Visualized"
  rightLabel="Mechanics"
>
  <template #left>
    <p><strong>Full response (blocking):</strong></p>
    <p>─── ─── ─── ─── → one blob</p>
    <p>vs.</p>
    <p><strong>Stream of text_delta events:</strong></p>
    <p>δ δ δ δ δ δ δ δ (via SSE)</p>
  </template>
  <template #right>
    <ul>
      <li><strong>Protocol</strong> — Server-Sent Events (SSE): small events over one open connection</li>
      <li><strong>Payload</strong> — each event carries a few tokens; render as they arrive</li>
      <li><strong>Key insight</strong> — total generation time doesn't change. Time-to-first-token (TTFT) drops</li>
    </ul>
  </template>
</TwoColSlide>

<!--
Streaming uses a protocol called Server-Sent Events — SSE. Instead of one big HTTP response, the server sends a series of small events over an open connection.

Each event carries a tiny piece of the response — a few tokens at a time. Your code reads each event as it arrives and renders it immediately.

The total time for Claude to generate the full response is the same either way. What changes is when you see the first token — that's called time-to-first-token, or TTFT. Streaming dramatically reduces TTFT, which is why it feels faster even though it isn't.
-->

---

<!-- SLIDE 4 — The streaming event sequence -->

<StepSequence
  eyebrow="Memorize this"
  title="The Streaming Event Sequence"
  :steps="eventSteps"
/>

<!--
When you open a streaming request, you always see events in this exact order.

message_start comes first — it carries message metadata like the model name and message ID.

Then content_block_start signals that a new block of content is beginning. For a text response, this means a text block is opening.

content_block_delta is the workhorse — you'll receive dozens or hundreds of these. Each one carries a small chunk of text in a field called text_delta.

content_block_stop closes the block when it's finished.

Then message_delta arrives — this is important for the exam. It carries stop_reason and the final usage statistics.

Finally, message_stop signals the stream is completely done.

Memorize this sequence. The exam tests it.
-->

---

<!-- SLIDE 5 — SDK way -->

<CodeBlockSlide
  eyebrow="SDK helper"
  title="Streaming in Python — The SDK Way"
  lang="python"
  :code="sdkCode"
  annotation="text_stream yields text deltas only — no event parsing · get_final_message() returns stop_reason + usage."
/>

<!--
The SDK's stream() context manager abstracts the SSE protocol entirely.

text_stream is a convenience iterator — it yields only the text deltas, nothing else. You don't need to parse raw events just to display text.

After the with block exits, get_final_message() gives you the complete assembled message. This is where you read stop_reason and token counts.
-->

---

<!-- SLIDE 6 — Raw event streaming -->

<CodeBlockSlide
  eyebrow="Full control"
  title="Raw Event Streaming"
  lang="python"
  :code="rawCode"
  annotation="⚠ stop_reason lives in message_delta, not message_stop · tool args arrive as input_json_delta — partial JSON you accumulate."
/>

<!--
When you're streaming tool calls, you need the raw event loop.

Tool arguments arrive as input_json_delta events — partial JSON that you accumulate.

Notice that stop_reason lives in message_delta, not message_stop. This trips people up — including on the exam.
-->

---

<!-- SLIDE 7 — Decision framework -->

<TwoColSlide
  variant="compare"
  title="Stream vs. No-Stream: Decision Framework"
  leftLabel="✓ Use Streaming"
  rightLabel="✗ Don't Stream"
>
  <template #left>
    <ul>
      <li>Chat interfaces, copilots, assistants</li>
      <li>Anywhere a <strong>human is waiting</strong></li>
      <li>Long responses (the wait is longest)</li>
      <li>Any UX where immediate feedback matters</li>
    </ul>
  </template>
  <template #right>
    <ul>
      <li>Batch pipelines & classification jobs</li>
      <li><strong>Code consumes output</strong>, not humans</li>
      <li>Need complete response before acting (full JSON parse)</li>
      <li>Automated extraction with no human in loop</li>
    </ul>
    <p style="margin-top: 18px;"><strong>Rule of thumb:</strong> if a human sees output in real time, stream. If a program consumes it complete, don't.</p>
  </template>
</TwoColSlide>

<!--
Use streaming when your users are watching. Chat interfaces, copilots, and assistants — anywhere a human is waiting — streaming makes these feel alive. Long responses benefit most from streaming because the wait without it is the longest.

Don't stream when your code — not a human — is consuming the output. Batch pipelines, classification jobs, and automated extraction tasks don't benefit. You just need the final answer, not a token-by-token feed.

Don't stream when you need the complete response before you can do anything with it. If you're parsing a full JSON structure, partial JSON is useless until it's done.

The rule of thumb: if a human sees the output in real time, stream it. If a program consumes the output after it's complete, don't bother.
-->

---

<!-- SLIDE 8 — Exam Tip -->

<Frame>
  <Eyebrow>⚡ Exam Tip</Eyebrow>
  <SlideTitle>Streaming Changes Delivery, Not Content</SlideTitle>
  <div class="exam-stack">
    <CalloutBox variant="dont" title="Trap">
      <p>Thinking streaming makes Claude generate faster, or changes what Claude outputs. It does neither.</p>
    </CalloutBox>
    <CalloutBox variant="do" title="Correct pattern">
      <p>Streaming reduces time-to-first-token (perceived latency) — total generation time is unchanged. Choose streaming for user-facing UX, not batch. <code>stop_reason</code> arrives in <code>message_delta</code>, not <code>message_stop</code>.</p>
    </CalloutBox>
  </div>
</Frame>

<!--
Here's the exam trap: thinking streaming makes Claude generate faster or changes what Claude outputs. It does neither.

Streaming is strictly a delivery mechanism. The total generation time is identical — what changes is when you see the first token.

And the detail that trips candidates up: stop_reason lives in message_delta, not message_stop. When the exam asks where stop_reason arrives in the stream, the correct answer is message_delta.
-->

---

<!-- SLIDE 9 — Takeaways -->

<BulletReveal
  eyebrow="Takeaway"
  title="What to Remember"
  :bullets="takeaways"
/>

<!--
Four things to hold onto.

Streaming uses Server-Sent Events with a fixed event order: message_start → content_block_start → content_block_delta* → content_block_stop → message_delta → message_stop.

stop_reason and usage arrive in message_delta — NOT in message_stop.

Streaming reduces time-to-first-token (perceived latency); total generation time is unchanged.

Stream for user-facing interfaces; skip for batch that needs the full response first.
-->
