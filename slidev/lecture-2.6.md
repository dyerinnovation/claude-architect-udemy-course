---
theme: default
title: "Lecture 2.6: Response Streaming: Real-Time Output"
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
  <div class="di-cover-title">Response Streaming:<br>Real-Time Output</div>
  <div class="di-cover-subtitle">Lecture 2.6 · Claude Certified Architect – Foundations</div>
</div>

<img src="/logo.png" class="di-logo-centered" />

<!--
Have you ever watched a loading spinner for five seconds, then had a wall of text appear at once?

That's not a slow model — that's a slow delivery strategy.

Streaming is how you fix it.

Instead of waiting for Claude to finish the entire response, your app gets each word as it's generated.

Users see output immediately, and the experience feels completely different.

This lecture is about when to stream, when not to, and exactly what happens under the hood.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 2 — Why Does Your App Feel Slow?
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Why Does Your App Feel Slow?</div>

<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem; margin-top: 0.75rem;">

  <v-click>
  <div>
    <div class="di-col-right-label" style="color: #E53E3E; border-color: #E53E3E;">✗ No Streaming</div>
    <div class="di-col-body">
      <div style="background: #FFF0F0; border-left: 3px solid #E53E3E; border-radius: 4px; padding: 0.6rem 0.9rem; font-size: 0.9rem;">
        <div style="font-family: 'Courier New', monospace; color: #7a2020;">⟳ ⟳ ⟳ ⟳ ⟳ (5s of spinner)</div>
        <div style="margin-top: 0.4rem; color: #7a2020;">→ Wall of text appears at once</div>
      </div>
      <p style="margin-top: 0.4rem; font-size: 0.85rem;">Feels broken. Users close the tab.</p>
    </div>
  </div>
  </v-click>

  <v-click>
  <div>
    <div class="di-col-left-label">✓ Streaming</div>
    <div class="di-col-body">
      <div style="background: #F0FFF4; border-left: 3px solid #3CAF50; border-radius: 4px; padding: 0.6rem 0.9rem; font-size: 0.9rem;">
        <div style="font-family: 'Courier New', monospace; color: #1B8A5A;">Text appears word</div>
        <div style="font-family: 'Courier New', monospace; color: #1B8A5A;">by word, immediately...</div>
      </div>
      <p style="margin-top: 0.4rem; font-size: 0.85rem;">Feels alive. Users stay engaged.</p>
    </div>
  </div>
  </v-click>

</div>

<v-click>
<div style="margin-top: 1rem; text-align: center; font-size: 1.05rem; font-weight: 600; color: #1A3A4A;">
  Same model. Same response. Different delivery.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Have you ever watched a loading spinner for five seconds, then had a wall of text appear at once? That's not a slow model — that's a slow delivery strategy.

Streaming fixes it. Instead of waiting for Claude to finish the entire response, your app gets each word as it's generated. Users see output immediately, and the experience feels completely different.

This lecture is about when to stream, when not to, and exactly what happens under the hood.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 3 — What Is Streaming, Actually?
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">What Is Streaming, Actually?</div>

<div style="display: flex; align-items: stretch; gap: 1.5rem; margin-top: 0.5rem;">

  <!-- Diagram column -->
  <div style="flex: 0 0 45%; display: flex; flex-direction: column; gap: 0.5rem;">
    <v-click>
    <div style="background: #E53E3E; color: white; border-radius: 6px; padding: 0.6rem 1rem; font-weight: 600; text-align: center; font-size: 0.9rem;">
      Full Response (blocking)
    </div>
    </v-click>
    <div class="di-arrow">vs.</div>
    <v-click>
    <div style="display: flex; gap: 0.25rem; flex-wrap: wrap;">
      <div style="background: #3CAF50; color: white; border-radius: 4px; padding: 0.25rem 0.5rem; font-size: 0.75rem;">δ</div>
      <div style="background: #3CAF50; color: white; border-radius: 4px; padding: 0.25rem 0.5rem; font-size: 0.75rem;">δ</div>
      <div style="background: #3CAF50; color: white; border-radius: 4px; padding: 0.25rem 0.5rem; font-size: 0.75rem;">δ</div>
      <div style="background: #3CAF50; color: white; border-radius: 4px; padding: 0.25rem 0.5rem; font-size: 0.75rem;">δ</div>
      <div style="background: #3CAF50; color: white; border-radius: 4px; padding: 0.25rem 0.5rem; font-size: 0.75rem;">δ</div>
      <div style="background: #3CAF50; color: white; border-radius: 4px; padding: 0.25rem 0.5rem; font-size: 0.75rem;">δ</div>
      <div style="background: #3CAF50; color: white; border-radius: 4px; padding: 0.25rem 0.5rem; font-size: 0.75rem;">δ</div>
      <div style="background: #3CAF50; color: white; border-radius: 4px; padding: 0.25rem 0.5rem; font-size: 0.75rem;">δ</div>
    </div>
    <div style="margin-top: 0.3rem; font-size: 0.82rem; color: #1A3A4A; text-align: center;">
      stream of <code>text_delta</code> events via <strong>SSE</strong>
    </div>
    </v-click>
  </div>

  <!-- Explanation column -->
  <div style="flex: 1; font-size: 0.92rem; color: #111928; line-height: 1.6;">
    <v-click>
    <div class="di-step-card">
      <span class="di-step-num">Protocol</span>
      Server-Sent Events (<strong>SSE</strong>) — small events over one open connection
    </div>
    </v-click>
    <v-click>
    <div class="di-step-card">
      <span class="di-step-num">Payload</span>
      Each event carries a few tokens; your code renders as they arrive
    </div>
    </v-click>
    <v-click>
    <div class="di-step-card" style="border-left-color: #E3A008;">
      <span class="di-step-num" style="color: #E3A008;">Key insight</span>
      <strong>Total generation time doesn't change.</strong> What drops is <em>time-to-first-token</em> (TTFT)
    </div>
    </v-click>
  </div>

</div>

<img src="/logo.png" class="di-logo" />

<!--
Streaming uses a protocol called Server-Sent Events — SSE. Instead of one big HTTP response, the server sends a series of small events over an open connection.

Each event carries a tiny piece of the response — a few tokens at a time. Your code reads each event as it arrives and renders it immediately.

The total time for Claude to generate the full response is the same either way. What changes is when you see the first token — that's called time-to-first-token, or TTFT. Streaming dramatically reduces TTFT, which is why it feels faster even though it isn't.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 4 — The Streaming Event Sequence
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">The Streaming Event Sequence</div>

<div style="margin-top: 0.5rem; font-size: 0.9rem;">

  <v-click>
  <div style="display: flex; align-items: center; gap: 0.6rem; margin-bottom: 0.35rem;">
    <div style="background: #2a4a6a; color: white; border-radius: 4px; padding: 0.35rem 0.8rem; min-width: 180px; font-family: 'Courier New', monospace; font-size: 0.85rem;">message_start</div>
    <div style="color: #1A3A4A;">message metadata: model name, message ID</div>
  </div>
  </v-click>

  <v-click>
  <div style="display: flex; align-items: center; gap: 0.6rem; margin-bottom: 0.35rem;">
    <div style="background: #1B8A5A; color: white; border-radius: 4px; padding: 0.35rem 0.8rem; min-width: 180px; font-family: 'Courier New', monospace; font-size: 0.85rem;">content_block_start</div>
    <div style="color: #1A3A4A;">a new content block is beginning (e.g. text block)</div>
  </div>
  </v-click>

  <v-click>
  <div style="display: flex; align-items: center; gap: 0.6rem; margin-bottom: 0.35rem;">
    <div style="background: #1B8A5A; color: white; border-radius: 4px; padding: 0.35rem 0.8rem; min-width: 180px; font-family: 'Courier New', monospace; font-size: 0.85rem;">content_block_delta</div>
    <div style="color: #1A3A4A;">the workhorse — repeats dozens/hundreds of times, carries <code>text_delta</code></div>
  </div>
  </v-click>

  <v-click>
  <div style="display: flex; align-items: center; gap: 0.6rem; margin-bottom: 0.35rem;">
    <div style="background: #1B8A5A; color: white; border-radius: 4px; padding: 0.35rem 0.8rem; min-width: 180px; font-family: 'Courier New', monospace; font-size: 0.85rem;">content_block_stop</div>
    <div style="color: #1A3A4A;">closes the block when finished</div>
  </div>
  </v-click>

  <v-click>
  <div style="display: flex; align-items: center; gap: 0.6rem; margin-bottom: 0.35rem;">
    <div style="background: #E3A008; color: white; border-radius: 4px; padding: 0.35rem 0.8rem; min-width: 180px; font-family: 'Courier New', monospace; font-size: 0.85rem;">message_delta</div>
    <div style="color: #1A3A4A;"><strong>contains <code>stop_reason</code> + final usage stats</strong> ← exam tests this</div>
  </div>
  </v-click>

  <v-click>
  <div style="display: flex; align-items: center; gap: 0.6rem;">
    <div style="background: #E53E3E; color: white; border-radius: 4px; padding: 0.35rem 0.8rem; min-width: 180px; font-family: 'Courier New', monospace; font-size: 0.85rem;">message_stop</div>
    <div style="color: #1A3A4A;">stream is completely done</div>
  </div>
  </v-click>

</div>

<v-click>
<div style="margin-top: 0.75rem; background: #FFF8E6; border-left: 4px solid #E3A008; border-radius: 4px; padding: 0.55rem 0.9rem; font-size: 0.88rem;">
  <strong style="color: #E3A008;">Memorize this sequence.</strong> The exam tests it.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

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
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 5 — Streaming in Python — The SDK Way
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">Streaming in Python — The SDK Way</div>

<v-click>

```python {all|6-9|11-12|16-18|all}
import anthropic

client = anthropic.Anthropic()

# The SDK's stream() context manager handles SSE for you
with client.messages.stream(
    model="claude-opus-4-5",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Explain REST APIs in plain English."}]
) as stream:
    # text_stream yields each text chunk as a plain string
    for text in stream.text_stream:
        print(text, end="", flush=True)  # flush=True = immediate output

# After the context exits, the final message is available
final_message = stream.get_final_message()
print(f"\nStop reason: {final_message.stop_reason}")
print(f"Input tokens: {final_message.usage.input_tokens}")
```

</v-click>

<v-click>
<div style="display: flex; gap: 1rem; margin-top: 0.5rem; font-size: 0.82rem; color: #1A3A4A;">
  <div style="flex: 1; background: white; border-radius: 4px; padding: 0.4rem 0.6rem; border-left: 2px solid #3CAF50;">
    <strong style="color: #1B8A5A;">text_stream</strong> yields only the text deltas — no event parsing required
  </div>
  <div style="flex: 1; background: white; border-radius: 4px; padding: 0.4rem 0.6rem; border-left: 2px solid #0D7377;">
    <strong style="color: #0D7377;">get_final_message()</strong> gives you the complete assembled message with <code>stop_reason</code> + usage
  </div>
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
The SDK's stream() context manager abstracts the SSE protocol entirely.

text_stream is a convenience iterator — it yields only the text deltas, nothing else. You don't need to parse raw events just to display text.

After the with block exits, get_final_message() gives you the complete assembled message. This is where you read stop_reason and token counts.
-->

---
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 6 — Raw Event Streaming — When You Need Control
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">Raw Event Streaming — When You Need Control</div>

<v-click>

```python {all|11-15|16-18|19-21|all}
import anthropic

client = anthropic.Anthropic()

# Use raw event iteration when you need to handle every event type
with client.messages.stream(
    model="claude-opus-4-5",
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
            print(f"\nStop reason: {event.delta.stop_reason}")
```

</v-click>

<v-click>
<div style="margin-top: 0.5rem; background: #FFF8E6; border-left: 4px solid #E3A008; border-radius: 4px; padding: 0.6rem 0.9rem; font-size: 0.9rem;">
  <strong style="color: #E3A008;">⚠ Trips people up (including on the exam):</strong> <code>stop_reason</code> lives in <code>message_delta</code>, not <code>message_stop</code>. Tool arguments arrive as <code>input_json_delta</code> — partial JSON you accumulate.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
When you're streaming tool calls, you need the raw event loop.

Tool arguments arrive as input_json_delta events — partial JSON that you accumulate.

Notice that stop_reason lives in message_delta, not message_stop. This trips people up — including on the exam.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 7 — Stream vs. No-Stream: The Decision Framework
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Stream vs. No-Stream: The Decision Framework</div>

<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem; margin-top: 0.5rem;">

  <v-click>
  <div>
    <div class="di-col-left-label">✓ Use Streaming</div>
    <div class="di-col-body">
      <ul>
        <li>Chat interfaces, copilots, assistants</li>
        <li>Anywhere a <strong>human is waiting</strong></li>
        <li>Long responses (the wait without streaming is longest)</li>
        <li>Any UX where immediate feedback matters</li>
      </ul>
    </div>
  </div>
  </v-click>

  <v-click>
  <div>
    <div class="di-col-right-label" style="color: #E53E3E; border-color: #E53E3E;">✗ Don't Stream</div>
    <div class="di-col-body">
      <ul>
        <li>Batch pipelines & classification jobs</li>
        <li><strong>Code consumes the output</strong>, not humans</li>
        <li>Need the complete response before acting (e.g. full JSON parse)</li>
        <li>Automated extraction with no human in loop</li>
      </ul>
    </div>
  </div>
  </v-click>

</div>

<v-click>
<div style="margin-top: 0.9rem; background: white; border: 1px solid #c8e6d0; border-left: 4px solid #0D7377; border-radius: 6px; padding: 0.7rem 1rem; font-size: 0.95rem; color: #111928;">
  <strong style="color: #0D7377;">Rule of thumb:</strong> If a human sees output in real time, stream it. If a program consumes output after it's complete, don't bother.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Use streaming when your users are watching. Chat interfaces, copilots, and assistants — anywhere a human is waiting — streaming makes these feel alive. Long responses benefit most from streaming because the wait without it is the longest.

Don't stream when your code — not a human — is consuming the output. Batch pipelines, classification jobs, and automated extraction tasks don't benefit. You just need the final answer, not a token-by-token feed.

Don't stream when you need the complete response before you can do anything with it. If you're parsing a full JSON structure, partial JSON is useless until it's done.

The rule of thumb: if a human sees the output in real time, stream it. If a program consumes the output after it's complete, don't bother.
-->

---
layout: default
class: di-exam-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 8 — Exam Tip
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-exam-banner">⚡ EXAM TIP</div>

<v-click>
<div class="di-exam-subtitle">Streaming Changes Delivery, Not Content</div>

<div class="di-exam-body">
  The exam tests <strong>perceived latency</strong> vs. <strong>total latency</strong>, and the event where <code class="di-code-inline">stop_reason</code> actually lives.
</div>
</v-click>

<v-click>
<div class="di-trap-box">
  <div class="di-trap-label">❌ Trap</div>
  Thinking streaming makes Claude generate responses <em>faster</em>, or that it changes what Claude outputs. It does neither.
</div>
</v-click>

<v-click>
<div class="di-correct-box">
  <div class="di-correct-label">✓ Correct Approach</div>
  Streaming reduces <strong>time-to-first-token</strong> (perceived latency) — total generation time is unchanged. Choose streaming for user-facing UX, not batch pipelines. And remember: <code class="di-code-inline">stop_reason</code> arrives in <strong><code>message_delta</code></strong>, not <code>message_stop</code>.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Streaming does not change the content or total generation time — it changes when you receive the first token. Streaming reduces perceived latency (time-to-first-token) but does not reduce total latency.

The exam will present scenarios asking when streaming helps: the correct answer is always a user-facing interface where immediate feedback improves experience, not a batch pipeline.

Also watch for questions about where stop_reason lives — it's in the message_delta event, not message_stop.
-->

---
layout: default
class: di-takeaway-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 9 — Key Takeaways
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-takeaway-title">What to Remember</div>

<ul class="di-takeaway-list">
  <v-click><li>Streaming uses <strong>SSE</strong>; event order is <code>message_start</code> → <code>content_block_start</code> → <code>content_block_delta</code> (many) → <code>content_block_stop</code> → <code>message_delta</code> → <code>message_stop</code></li></v-click>
  <v-click><li><code style="color: #3CAF50;">stop_reason</code> and usage stats arrive in <code>message_delta</code> — <strong>not</strong> <code>message_stop</code></li></v-click>
  <v-click><li>Streaming reduces <strong>time-to-first-token</strong> (perceived latency); total generation time is unchanged</li></v-click>
  <v-click><li>Stream for user-facing interfaces; skip it for batch pipelines that need the full response before acting</li></v-click>
</ul>

<img src="/logo.png" class="di-logo" style="opacity: 0.75;" />

<!--
Four things to remember:

Streaming uses Server-Sent Events. The event order is always message_start, content_block_start, many content_block_deltas, content_block_stop, message_delta, and finally message_stop.

stop_reason and usage stats arrive in message_delta, not message_stop.

Streaming reduces time-to-first-token — perceived latency — but does not reduce total generation time.

Use streaming for user-facing interfaces. Skip it for batch processing and programmatic pipelines that need the full response before acting.
-->
