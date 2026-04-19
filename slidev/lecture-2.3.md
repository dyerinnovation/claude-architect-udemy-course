---
theme: default
title: "Lecture 2.3: Temperature, top_p, and top_k — Controlling Randomness"
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
  <div class="di-cover-title"><code style="color: #3CAF50;">temperature</code>, <code style="color: #3CAF50;">top_p</code>, <code style="color: #3CAF50;">top_k</code><br>Controlling Randomness</div>
  <div class="di-cover-subtitle">Lecture 2.3 · Claude Certified Architect – Foundations</div>
</div>

<img src="/logo.png" class="di-logo-centered" />

<!--
Ask Claude the same question twice. Sometimes you get the same answer. Sometimes you don't.

That's not a bug — it's a feature you control.

Three parameters govern how creative or predictable Claude's outputs are: temperature, top_p, and top_k.

Most developers only learn enough to set temperature and move on. But the exam will test whether you know when to use each setting — and why.

Let's build a clear mental model.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 2 — Temperature — The Main Dial
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Temperature — The Main Dial</div>

<div class="di-body" style="margin-top: 0.5rem;">

<p>At every step, Claude has a ranked list of possible next tokens. <strong>Temperature reshapes that distribution before sampling.</strong></p>

<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.75rem; margin-top: 0.6rem;">

  <v-click>
  <div class="di-step-card">
    <span class="di-step-num">temperature = 0</span>
    Distribution collapsed to a spike → Claude almost always picks the top token → <strong>deterministic</strong>
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card" style="border-left-color: #E3A008;">
    <span class="di-step-num" style="color: #E3A008;">temperature = 1.0</span>
    Distribution flat and spread out → low-probability tokens get a real chance → <strong>varied, creative</strong>
  </div>
  </v-click>

</div>

<v-click>
<div style="background: #FFF8E6; border-left: 3px solid #E3A008; padding: 0.5rem 0.8rem; border-radius: 4px; font-size: 0.9rem; margin-top: 0.8rem;">
  Default is typically around <code class="di-code-inline">1.0</code> for most Claude models — for production, almost always set it explicitly.
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
Temperature controls how Claude samples from its probability distribution. At every step, Claude has a ranked list of possible next tokens. Temperature reshapes that distribution before sampling.

At temperature=0, the distribution is collapsed to a spike. Claude almost always picks the highest-probability token. The output is highly deterministic — you'll get the same answer most of the time.

At temperature=1.0, the distribution is flat and spread out. Lower-probability tokens get a real chance to be selected. The output is varied, surprising, and creative.

The default is typically around 1.0 for most Claude models. For production use, you almost always want to set it explicitly.
-->

---
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 3 — Temperature in Practice
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">Temperature in Practice — Memorize This Pattern</div>

<v-click>

```python
# LOW temperature — accuracy and consistency
code_review = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    temperature=0,        # Deterministic: same input → same output
    messages=[{
        "role": "user",
        "content": "Review this Python function for bugs: def add(a, b): return a - b"
    }]
)

# HIGH temperature — creativity and variation
creative = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    temperature=1.0,      # Creative: varied, unexpected output
    messages=[{
        "role": "user",
        "content": "Write three different taglines for an artisan coffee shop."
    }]
)
```

</v-click>

<v-click>
<div style="display: flex; gap: 0.75rem; margin-top: 0.6rem; font-size: 0.82rem; color: #1A3A4A;">
  <div style="flex: 1; background: white; border-radius: 4px; padding: 0.4rem 0.6rem; border-left: 3px solid #3CAF50;">
    <strong style="color: #1B8A5A;">temperature = 0</strong> — code review, extraction, classification, factual Q&amp;A
  </div>
  <div style="flex: 1; background: white; border-radius: 4px; padding: 0.4rem 0.6rem; border-left: 3px solid #E3A008;">
    <strong style="color: #E3A008;">temperature = 0.7–1.0</strong> — brainstorming, creative writing, marketing copy
  </div>
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Here's the pattern you need to memorize for the exam.

For code review, extraction, and classification — use temperature=0. You want the same correct answer every time.

For brainstorming, creative writing, and marketing copy — use 0.7 to 1.0. You want variety and originality.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 4 — top_p — Nucleus Sampling
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header"><code>top_p</code> — Nucleus Sampling</div>

<div class="di-body" style="margin-top: 0.5rem;">

<v-click>
<p>Instead of reshaping the full distribution, <code class="di-code-inline">top_p</code> <strong>trims</strong> it. Only tokens whose cumulative probability totals the threshold are eligible — the long tail is excluded.</p>
</v-click>

<div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 0.5rem; margin-top: 0.6rem;">
  <v-click>
  <div class="di-step-card">
    <span class="di-step-num">top_p = 1.0</span>
    No trimming — all tokens eligible
  </div>
  </v-click>
  <v-click>
  <div class="di-step-card" style="border-left-color: #0D7377;">
    <span class="di-step-num" style="color: #0D7377;">top_p = 0.9</span>
    Excludes the long tail of unlikely tokens
  </div>
  </v-click>
  <v-click>
  <div class="di-step-card" style="border-left-color: #E3A008;">
    <span class="di-step-num" style="color: #E3A008;">top_p = 0.5</span>
    Aggressively focuses on the most likely candidates
  </div>
  </v-click>
</div>

<v-click>
<div style="background: #F0FFF4; border-left: 3px solid #3CAF50; padding: 0.5rem 0.8rem; border-radius: 4px; font-size: 0.9rem; margin-top: 0.8rem;">
  <strong>The practical difference vs. temperature:</strong> <code>top_p</code> controls the <em>size of the candidate pool</em>; <code>temperature</code> controls the <em>shape of probabilities within that pool</em>.
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
top_p is a different approach to controlling randomness. Instead of reshaping the full distribution, it trims it.

top_p=0.9 means Claude only considers tokens whose cumulative probability totals 90%. All other tokens are excluded from sampling entirely — no matter what temperature says.

This is called nucleus sampling. It keeps the "reasonable" token candidates and throws away the long tail of unlikely options.

top_p=1.0 means no trimming — all tokens are eligible. top_p=0.5 aggressively focuses the pool to only the most likely candidates.

The practical difference from temperature: top_p controls the size of the candidate pool, while temperature controls the shape of probabilities within that pool.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 5 — top_k — Hard Limit on Candidates
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header"><code>top_k</code> — Hard Limit on Candidates</div>

<div class="di-body" style="margin-top: 0.5rem;">

<v-click>
<p><code class="di-code-inline">top_k</code> is the simplest of the three. Set <code>top_k=5</code> and Claude only considers the <strong>five highest-probability tokens</strong> at each step. It doesn't care about cumulative probability — it's a hard count.</p>
</v-click>

<v-click>
<div class="di-step-card" style="border-left-color: #E3A008; margin-top: 0.3rem;">
  <span class="di-step-num" style="color: #E3A008;">top_k = 1</span>
  Equivalent to greedy decoding — always pick the single most likely token
</div>
</v-click>

<v-click>
<div style="background: white; border: 1px solid #c8e6d0; border-radius: 6px; padding: 0.6rem 1rem; margin-top: 0.6rem;">
  <div style="font-weight: 700; color: #1A3A4A; font-size: 0.95rem; margin-bottom: 0.4rem;">How to think about all three together:</div>
  <ul style="margin: 0; padding-left: 1.2rem; font-size: 0.9rem; line-height: 1.55;">
    <li><code>temperature</code> → reshapes the probabilities</li>
    <li><code>top_p</code> → trims the candidate pool by cumulative probability</li>
    <li><code>top_k</code> → trims the candidate pool by count</li>
  </ul>
</div>
</v-click>

<v-click>
<div style="background: #FFF8E6; border-left: 3px solid #E3A008; padding: 0.5rem 0.8rem; border-radius: 4px; font-size: 0.9rem; margin-top: 0.6rem;">
  Anthropic recommends adjusting <strong>only one at a time</strong>. For most use cases, <code>temperature</code> alone is sufficient. Stacking all three without intent produces unpredictable results.
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
top_k is the simplest of the three. Set top_k=5 and Claude only considers the five highest-probability tokens at each step. It doesn't care about cumulative probability — it's a hard count.

top_k=1 is equivalent to greedy decoding — always pick the single most likely token.

Here's how to think about all three together. Temperature reshapes the probabilities. top_p trims the candidate pool by cumulative probability. top_k trims the candidate pool by count.

In practice, Anthropic recommends adjusting only one of these at a time. Stacking all three without a good reason usually produces unpredictable results. For most use cases, temperature alone is sufficient.
-->

---
layout: default
class: di-exam-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 6 — Exam Tip
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-exam-banner">⚡ EXAM TIP</div>

<v-click>
<div class="di-exam-subtitle">Low Temperature Is Not Always "Better"</div>

<div class="di-exam-body">
  Match the parameter to the task. <code class="di-code-inline">temperature=0</code> is correct for deterministic tasks — code generation, data extraction, classification, factual Q&amp;A. <code class="di-code-inline">temperature=0.7–1.0</code> is correct for creative tasks — brainstorming, marketing copy, story generation.
</div>
</v-click>

<v-click>
<div class="di-trap-box">
  <div class="di-trap-label">❌ Distractor Pattern</div>
  Assuming <code>temperature=0</code> produces the highest-quality output for <em>all</em> tasks — and selecting it as the default recommendation in every scenario.
</div>
</v-click>

<v-click>
<div class="di-correct-box">
  <div class="di-correct-label">✓ Exam Signal</div>
  A scenario that says "generate ten different product name ideas" is asking for creative output — <code>temperature=0</code> would produce ten nearly identical suggestions, which defeats the purpose.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Here's the exam trap: assuming that temperature=0 produces the highest-quality output for all tasks, and selecting it as the default recommendation in every scenario.

Temperature 0 is correct for deterministic tasks — code generation, data extraction, classification, factual Q&A. Temperature 0.7 to 1.0 is correct for creative tasks — brainstorming, marketing copy, story generation. The right temperature depends entirely on whether you want consistency or variety.

A scenario that says "generate ten different product name ideas" is asking for creative output — temperature=0 would produce ten nearly identical suggestions, which defeats the purpose.
-->

---
layout: default
class: di-takeaway-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 7 — Key Takeaways
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-takeaway-title">What to Remember</div>

<ul class="di-takeaway-list">
  <v-click><li><code>temperature</code> reshapes the probability distribution — <code>0</code> is near-deterministic, <code>1.0</code> is highly varied; match to task type (code/extraction = low, creative = high)</li></v-click>
  <v-click><li><code>top_p</code> (nucleus sampling) limits the candidate pool to tokens whose cumulative probability hits the threshold — excludes the long tail of unlikely tokens</li></v-click>
  <v-click><li><code>top_k</code> is a hard count limit on candidate tokens — <code>top_k=1</code> is greedy decoding, always picking the most likely token</li></v-click>
  <v-click><li>Adjust <strong>only one at a time</strong> — Anthropic recommends <code>temperature</code> for most use cases; stacking all three without intent produces unpredictable results</li></v-click>
</ul>

<img src="/logo.png" class="di-logo" style="opacity: 0.75;" />

<!--
Four things to remember.

temperature reshapes the probability distribution at each token step — 0 is near-deterministic, 1.0 is highly varied; for the exam, match to task type (code/extraction = low, creative = high).

top_p (nucleus sampling) limits the candidate pool to tokens whose cumulative probability hits the threshold — top_p=0.9 excludes the long tail of unlikely tokens.

top_k is a hard count limit on candidate tokens — top_k=1 is greedy decoding, always picking the most likely token.

In practice, adjust only one of these at a time; Anthropic recommends temperature for most use cases, and stacking all three without intent produces unpredictable results.
-->
