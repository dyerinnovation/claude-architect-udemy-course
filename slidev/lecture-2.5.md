---
theme: default
title: "Lecture 2.5: Stop Sequences: Teaching Claude Exactly When to Stop"
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
  <div class="di-cover-title">Stop Sequences:<br>Teaching Claude Exactly<br>When to Stop</div>
  <div class="di-cover-subtitle">Lecture 2.5 · Claude Certified Architect – Foundations</div>
</div>

<img src="/logo.png" class="di-logo-centered" />

<!--
You asked Claude a direct question and got exactly the right answer.

Then Claude kept going.

It added context, caveats, follow-up suggestions, and a closing summary.

In a chat interface, that feels helpful.

In a production system, it's noise your parser has to fight through.

Stop sequences let you draw a hard line in the output stream.

When Claude hits that line, it stops — immediately, cleanly, every time.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 2 — The Overgeneration Problem
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">The Overgeneration Problem</div>

<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem; margin-top: 0.5rem;">

  <v-click>
  <div>
    <div class="di-col-left-label">✓ What You Asked For</div>
    <div class="di-col-body">
      <div style="background: white; border-left: 3px solid #3CAF50; padding: 0.6rem 0.8rem; border-radius: 4px; font-family: 'Courier New', monospace; font-size: 0.88rem;">
        &lt;answer&gt;Tokyo&lt;/answer&gt;
      </div>
      <p style="margin-top: 0.4rem;">Clean. Parseable. Done.</p>
    </div>
  </div>
  </v-click>

  <v-click>
  <div>
    <div class="di-col-right-label" style="color: #E53E3E; border-color: #E53E3E;">✗ What Claude Gave You</div>
    <div class="di-col-body">
      <div style="background: #FFF0F0; border-left: 3px solid #E53E3E; padding: 0.6rem 0.8rem; border-radius: 4px; font-size: 0.85rem; color: #7a2020;">
        &lt;answer&gt;Tokyo&lt;/answer&gt;<br>
        <em>Tokyo has been the capital since 1868. It's also the most populous metropolitan area in the world. Would you like me to tell you more about its districts?</em>
      </div>
      <p style="margin-top: 0.4rem; color: #E53E3E; font-weight: 600;">Your parser has to fight through this.</p>
    </div>
  </div>
  </v-click>

</div>

<v-click>
<div style="margin-top: 0.9rem; text-align: center; font-size: 1.05rem; font-weight: 600; color: #1A3A4A;">
  Stop sequences draw a hard line in the output stream.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
You asked Claude a direct question and got exactly the right answer. Then Claude kept going.

In a chat interface, the extra context feels helpful. In a production system, it's noise your parser has to fight through.

Stop sequences let you draw a hard line in the output stream. When Claude hits that line, generation halts immediately, cleanly, every time.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 3 — How Stop Sequences Work
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">How Stop Sequences Work</div>

<div style="display: flex; align-items: stretch; gap: 1.5rem; margin-top: 0.5rem;">

  <!-- Flow diagram column -->
  <div style="flex: 0 0 48%; display: flex; flex-direction: column; gap: 0.4rem;">
    <v-click>
    <div class="di-flow-box">Claude generates tokens →</div>
    </v-click>
    <v-click>
    <div style="display: flex; align-items: stretch; gap: 0.4rem;">
      <div class="di-flow-stop" style="flex: 1; font-size: 0.8rem;">Included<br>in response</div>
      <div style="background: #E53E3E; color: white; border-radius: 6px; padding: 0.5rem 0.6rem; font-weight: 700; font-size: 0.85rem; text-align: center; writing-mode: horizontal-tb;">
        WALL:<br><code style="background: transparent; color: white;">"&lt;/answer&gt;"</code>
      </div>
      <div style="background: #6b7280; color: white; border-radius: 6px; padding: 0.5rem 0.6rem; flex: 1; font-size: 0.8rem; text-align: center;">
        Never<br>generated
      </div>
    </div>
    </v-click>
    <v-click>
    <div style="margin-top: 0.4rem; display: flex; flex-direction: column; gap: 0.3rem; font-size: 0.82rem;">
      <div style="background: white; border-left: 3px solid #3CAF50; padding: 0.4rem 0.6rem; border-radius: 4px;">
        <code>stop_reason: "stop_sequence"</code>
      </div>
      <div style="background: white; border-left: 3px solid #3CAF50; padding: 0.4rem 0.6rem; border-radius: 4px;">
        <code>stop_sequence: "&lt;/answer&gt;"</code>
      </div>
    </div>
    </v-click>
  </div>

  <!-- Explanation column -->
  <div style="flex: 1; font-size: 0.92rem; color: #111928; line-height: 1.6;">
    <v-click>
    <div class="di-step-card">
      <span class="di-step-num">Array</span>
      Pass up to <strong>8,191</strong> strings via <code class="di-code-inline">stop_sequences</code>
    </div>
    </v-click>
    <v-click>
    <div class="di-step-card">
      <span class="di-step-num">Match</span>
      The API watches output — any exact match halts generation
    </div>
    </v-click>
    <v-click>
    <div class="di-step-card" style="border-left-color: #E3A008;">
      <span class="di-step-num" style="color: #E3A008;">Omit</span>
      The matched string is <strong>NOT</strong> in the response body
    </div>
    </v-click>
    <v-click>
    <div class="di-step-card" style="border-left-color: #0D7377;">
      <span class="di-step-num" style="color: #0D7377;">Verify</span>
      Check <code class="di-code-inline">stop_reason</code> + <code class="di-code-inline">stop_sequence</code> to confirm
    </div>
    </v-click>
  </div>

</div>

<img src="/logo.png" class="di-logo" />

<!--
The stop_sequences parameter takes an array of strings.

While Claude generates tokens, the API watches the output for exact matches. The moment Claude produces one of your strings, generation halts.

The matched string itself is NOT included in the response body.

You can pass up to 8,191 stop sequences in a single request. In practice you'll rarely use more than one or two.

When a stop sequence fires, response.stop_reason is "stop_sequence" — not "end_turn". And response.stop_sequence contains the exact string that matched. Those two fields are your confirmation that the stop worked.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 4 — When Stop Sequences Are the Right Tool
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">When Stop Sequences Are the Right Tool</div>

<div class="di-body" style="margin-top: 0.75rem;">
  <v-click>
  <div class="di-step-card">
    <span class="di-step-num">1 · Structured extraction</span>
    Stop at <code class="di-code-inline">&lt;/answer&gt;</code> to get clean content inside a tag
  </div>
  </v-click>
  <v-click>
  <div class="di-step-card">
    <span class="di-step-num">2 · Delimited output</span>
    Stop at <code class="di-code-inline">###END###</code> with no trailing content
  </div>
  </v-click>
  <v-click>
  <div class="di-step-card">
    <span class="di-step-num">3 · Multi-turn dialogue</span>
    Stop at turn boundaries like <code class="di-code-inline">\nHuman:</code>
  </div>
  </v-click>
  <v-click>
  <div class="di-step-card">
    <span class="di-step-num">4 · Code generation</span>
    Stop after the closing fence to get one clean block
  </div>
  </v-click>
</div>

<v-click>
<div style="margin-top: 0.9rem; background: white; border: 1px solid #c8e6d0; border-left: 4px solid #0D7377; border-radius: 6px; padding: 0.7rem 1rem; font-size: 0.92rem; color: #111928;">
  <strong style="color: #0D7377;">Common thread:</strong> you control the prompt, so you know what strings to expect. Design the prompt to include a predictable marker, then tell the API what it is.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Stop sequences shine in four common scenarios.

First: structured extraction — stop at a closing XML tag to get just the content inside.

Second: delimited output — use a custom marker to signal the end of relevant content.

Third: multi-turn structured dialogue — stop when you detect the next speaker's turn boundary.

Fourth: code generation — stop after the closing fence so you get one clean block.

The common thread is that you control the prompt, so you know what strings to expect. You design the prompt to include a predictable stop marker. Then you tell the API exactly what that marker is.
-->

---
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 5 — The Code: Stop Sequences in Practice
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">Stop Sequences in Practice</div>

<v-click>

```python {all|6|14|16|18|all}
import anthropic

client = anthropic.Anthropic()

response = client.messages.create(
    model="claude-opus-4-5",
    max_tokens=512,
    stop_sequences=["</answer>"],  # halt on this exact string
    messages=[{
        "role": "user",
        "content": "What is the capital of Japan? Wrap your answer in <answer> tags."
    }]
)

if response.stop_reason == "stop_sequence":
    matched = response.stop_sequence        # "</answer>"
    answer = response.content[0].text.strip()
    print(f"Extracted: {answer}")
else:
    # "end_turn" — Claude finished before hitting the sequence
    print(f"Unexpected stop reason: {response.stop_reason}")
```

</v-click>

<v-click>
<div style="display: flex; gap: 1rem; margin-top: 0.5rem; font-size: 0.82rem; color: #1A3A4A;">
  <div style="flex: 1; background: white; border-radius: 4px; padding: 0.4rem 0.6rem; border-left: 2px solid #3CAF50;">
    <strong style="color: #1B8A5A;">stop_reason</strong> tells you WHY it stopped
  </div>
  <div style="flex: 1; background: white; border-radius: 4px; padding: 0.4rem 0.6rem; border-left: 2px solid #0D7377;">
    <strong style="color: #0D7377;">stop_sequence</strong> tells you WHAT matched
  </div>
  <div style="flex: 1; background: white; border-radius: 4px; padding: 0.4rem 0.6rem; border-left: 2px solid #E3A008;">
    <strong style="color: #E3A008;">Always handle</strong> the <code>end_turn</code> fallthrough
  </div>
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
The response body contains everything Claude generated before the stop string. The stop string itself was never appended — it's reported in stop_sequence, not the text.

The else branch matters in production. If stop_reason is "end_turn", Claude ran out of content before hitting your marker. That usually means the prompt didn't produce the expected format. Always handle both cases.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 6 — Case Sensitivity & Whitespace Traps
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Case Sensitivity & Whitespace Traps</div>

<v-click>
<p style="color: #1A3A4A; font-weight: 600; font-size: 1rem; margin-top: 0.3rem;">
  Stop sequences are <em>exact</em> string literals. Not regex. Not fuzzy. Not case-insensitive.
</p>
</v-click>

<div style="margin-top: 0.6rem;">
<v-click>
<table style="width: 100%; border-collapse: collapse; background: white; border-radius: 6px; overflow: hidden; font-size: 0.9rem;">
  <thead>
    <tr style="background: #1A3A4A; color: white;">
      <th style="padding: 0.5rem 0.8rem; text-align: left;">What You Wrote</th>
      <th style="padding: 0.5rem 0.8rem; text-align: left;">What Claude Generated</th>
      <th style="padding: 0.5rem 0.8rem; text-align: center;">Did It Stop?</th>
    </tr>
  </thead>
  <tbody>
    <tr style="border-bottom: 1px solid #e0e0e0;">
      <td style="padding: 0.45rem 0.8rem;"><code>"END"</code></td>
      <td style="padding: 0.45rem 0.8rem;"><code>"end"</code></td>
      <td style="padding: 0.45rem 0.8rem; text-align: center; color: #E53E3E; font-weight: 700;">✗</td>
    </tr>
    <tr style="border-bottom: 1px solid #e0e0e0; background: #F0FFF4;">
      <td style="padding: 0.45rem 0.8rem;"><code>"END"</code></td>
      <td style="padding: 0.45rem 0.8rem;"><code>"END"</code></td>
      <td style="padding: 0.45rem 0.8rem; text-align: center; color: #1B8A5A; font-weight: 700;">✓</td>
    </tr>
    <tr style="border-bottom: 1px solid #e0e0e0;">
      <td style="padding: 0.45rem 0.8rem;"><code>" END"</code> (leading space)</td>
      <td style="padding: 0.45rem 0.8rem;"><code>"END"</code></td>
      <td style="padding: 0.45rem 0.8rem; text-align: center; color: #E53E3E; font-weight: 700;">✗</td>
    </tr>
    <tr>
      <td style="padding: 0.45rem 0.8rem;"><code>"&lt;/Answer&gt;"</code></td>
      <td style="padding: 0.45rem 0.8rem;"><code>"&lt;/answer&gt;"</code></td>
      <td style="padding: 0.45rem 0.8rem; text-align: center; color: #E53E3E; font-weight: 700;">✗</td>
    </tr>
  </tbody>
</table>
</v-click>
</div>

<v-click>
<div style="margin-top: 0.8rem; background: #FFF8E6; border-left: 4px solid #E3A008; border-radius: 4px; padding: 0.6rem 0.9rem; font-size: 0.9rem;">
  <strong style="color: #E3A008;">Fix:</strong> Use stop sequences you control in the prompt. XML closing tags are safest — you define the casing when you write the prompt.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Stop sequences are exact string matches. Not regex. Not fuzzy. Not case-insensitive. Every character must match exactly — including capitalization and whitespace.

Here are the traps candidates hit most often.

"END" will not catch "end" — different case, no match.
" END" with a leading space will not catch "END" — different bytes, no match.
"</Answer>" will not catch "</answer>" — again, case mismatch.

The fix is simple: use stop sequences where you control the casing in the prompt. XML tags are ideal because you write them in the prompt and you define the casing.
-->

---
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 7 — Combining Stop Sequences with Prefills
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">Combining Stop Sequences with Prefills</div>

<v-click>
<div style="display: flex; gap: 0.5rem; margin-bottom: 0.7rem; font-size: 0.82rem;">
  <div style="flex: 1; background: #F0FFF4; border: 1px solid #3CAF50; border-radius: 6px; padding: 0.5rem 0.7rem; text-align: center;">
    <strong style="color: #1B8A5A;">Prefill <code>&lt;answer&gt;</code></strong><br>
    <span style="color: #1A3A4A;">Controls START</span>
  </div>
  <div style="flex: 1; background: #f3f4f6; border: 1px solid #6b7280; border-radius: 6px; padding: 0.5rem 0.7rem; text-align: center; color: #1A3A4A;">
    Claude generates content
  </div>
  <div style="flex: 1; background: #FFF0F0; border: 1px solid #E53E3E; border-radius: 6px; padding: 0.5rem 0.7rem; text-align: center;">
    <strong style="color: #E53E3E;">Stop <code>&lt;/answer&gt;</code></strong><br>
    <span style="color: #1A3A4A;">Controls END</span>
  </div>
</div>
</v-click>

<v-click>

```python
response = client.messages.create(
    model="claude-opus-4-5",
    max_tokens=256,
    stop_sequences=["</answer>"],   # stop at closing tag
    messages=[
        {"role": "user", "content": "What is 144 divided by 12?"},
        {"role": "assistant", "content": "<answer>"}   # prefill opening tag
    ]
)
# response.content[0].text is the raw answer, no tags, no commentary
```

</v-click>

<v-click>
<div style="margin-top: 0.6rem; background: white; border-left: 4px solid #0D7377; border-radius: 4px; padding: 0.55rem 0.9rem; font-size: 0.9rem; color: #111928;">
  <strong style="color: #0D7377;">Result:</strong> exactly the content between the tags. No opening tag (that was the prefill). No closing tag (that was the stop). Just the answer.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Prefills and stop sequences are designed to work together.

The prefill forces Claude to open the format you expect. The stop sequence forces Claude to close it exactly where you want.

The response is exactly the content between the tags. No opening tag — that was the prefill, not in the response body. No closing tag — that was the stop sequence, never generated. Just the answer.
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
<div class="di-exam-subtitle">Stop Sequences Are Exact Literals</div>

<div class="di-exam-body">
  <code class="di-code-inline">"END"</code> and <code class="di-code-inline">"end"</code> are <strong>different</strong> stop sequences. Whitespace counts. Regex does not apply.
</div>
</v-click>

<v-click>
<div class="di-trap-box">
  <div class="di-trap-label">❌ Trap</div>
  Assuming stop sequences behave like regex or case-insensitive pattern matching — then wondering why an uppercase sequence fires inconsistently when Claude generates a lowercase variant.
</div>
</v-click>

<v-click>
<div class="di-correct-box">
  <div class="di-correct-label">✓ Correct Approach</div>
  Stop sequences are exact, case-sensitive string literals applied to the raw output stream. To guarantee a match, use sequences you control in the prompt — XML closing tags are safest. Always verify with <code class="di-code-inline">response.stop_reason == "stop_sequence"</code>.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Stop sequences are exact, case-sensitive string literals applied to the raw output stream before any post-processing. Whitespace is significant.

To guarantee a match, use stop sequences that you also control in the prompt — XML closing tags are the safest choice because you define their exact casing when you write the prompt.

Always verify the stop fired by checking response.stop_reason == "stop_sequence" and reading response.stop_sequence.
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
  <v-click><li><code style="color: #3CAF50;">stop_sequences</code> is an array of up to 8,191 exact string literals — when any matches, generation halts and the string is not in the response body</li></v-click>
  <v-click><li>Check <code style="color: #3CAF50;">response.stop_reason</code>: <code>"stop_sequence"</code> means it worked, <code>"end_turn"</code> means Claude finished first — handle both</li></v-click>
  <v-click><li>Stop sequences are <strong>case-sensitive exact matches</strong> — whitespace counts, regex does not apply</li></v-click>
  <v-click><li>Pair with prefills for clean bounded extraction: prefill opens, stop sequence closes, response contains exactly what you need</li></v-click>
</ul>

<img src="/logo.png" class="di-logo" style="opacity: 0.75;" />

<!--
Four things to remember:

stop_sequences is an array of up to 8,191 exact string literals. When any one matches Claude's output, generation halts immediately and the string is not included in the response body.

Check response.stop_reason: "stop_sequence" means it worked; "end_turn" means Claude finished without hitting your marker. Always handle both.

Stop sequences are case-sensitive exact matches. Whitespace counts. Regex does not apply.

Pair with prefills for clean bounded extraction: prefill opens the format, stop sequence closes it, and the response contains exactly what you need.
-->
