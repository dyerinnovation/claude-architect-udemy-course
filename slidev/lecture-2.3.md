---
theme: default
title: "Lecture 2.3: Temperature, top_p, and top_k — Controlling Randomness"
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
const topP = [
  { label: 'top_p = 1.0', detail: 'No trimming — all tokens eligible' },
  { label: 'top_p = 0.9', detail: 'Excludes the long tail of unlikely tokens' },
  { label: 'top_p = 0.5', detail: 'Aggressively focuses on the most likely candidates' },
]

const topK = [
  { label: 'top_k = N', detail: 'Only the N highest-probability tokens eligible' },
  { label: 'top_k = 1', detail: 'Greedy decoding — always the single most likely token' },
  { label: 'How they differ', detail: 'temperature reshapes · top_p trims by cumulative probability · top_k trims by count' },
]

const takeaways = [
  { label: 'temperature', detail: 'Reshapes the distribution — 0 near-deterministic, 1.0 highly varied; match to task' },
  { label: 'top_p (nucleus)', detail: 'Excludes long-tail tokens by cumulative probability' },
  { label: 'top_k', detail: 'A hard count — top_k=1 is greedy decoding' },
  { label: 'Adjust one at a time', detail: 'Anthropic recommends temperature alone for most cases' },
]

const tempCode = `# LOW temperature — accuracy and consistency
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
)`
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
      <div class="lec-cover__section">Section 2 · Lecture 2.3 · Domain 2</div>
      <h1 class="lec-cover__title">temperature, top_p, top_k</h1>
      <div class="lec-cover__subtitle">Controlling Randomness</div>
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
.lec-cover__title { font-family: var(--font-display); font-weight: 500; font-size: 112px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1500px; font-family: var(--font-mono); }
.lec-cover__subtitle { font-family: var(--font-display); font-size: 48px; color: var(--mint-200); margin-top: 32px; font-weight: 400; max-width: 1400px; line-height: 1.3; }
.lec-cover__stats { display: flex; align-items: center; gap: 36px; font-family: var(--font-body); font-size: 24px; color: var(--mint-200); letter-spacing: 0.06em; }
.lec-cover__dot { opacity: 0.4; }
.exam-stack { margin-top: 48px; display: flex; flex-direction: column; gap: 28px; flex: 1; min-height: 0; }
</style>

<!--
Ask Claude the same question twice. Sometimes you get the same answer. Sometimes you don't.

That's not a bug — it's a feature you control.

Three parameters govern how creative or predictable Claude's outputs are: temperature, top_p, and top_k.

Most developers only learn enough to set temperature and move on. But the exam will test whether you know when to use each setting — and why.

Let's build a clear mental model.
-->

---

<!-- SLIDE 2 — Temperature: The main dial -->

<ConceptHero
  eyebrow="The main dial"
  leadLine="Temperature reshapes the probability distribution before sampling."
  concept="0 → spike · 1.0 → flat"
  supportLine="Default ~1.0 for most Claude models — always set it explicitly in production."
/>

<!--
Temperature controls how Claude samples from its probability distribution. At every step, Claude has a ranked list of possible next tokens. Temperature reshapes that distribution before sampling.

At temperature=0, the distribution is collapsed to a spike. Claude almost always picks the highest-probability token. The output is highly deterministic — you'll get the same answer most of the time.

At temperature=1.0, the distribution is flat and spread out. Lower-probability tokens get a real chance to be selected. The output is varied, surprising, and creative.

The default is typically around 1.0 for most Claude models. For production use, you almost always want to set it explicitly.
-->

---

<!-- SLIDE 3 — Temperature in practice -->

<CodeBlockSlide
  eyebrow="Memorize this"
  title="Temperature in Practice"
  lang="python"
  :code="tempCode"
  annotation="temp=0 → code review, extraction, classification, factual Q&A · temp=0.7–1.0 → brainstorming, creative writing, marketing"
/>

<!--
Here's the pattern you need to memorize for the exam.

For code review, extraction, and classification — use temperature=0. You want the same correct answer every time.

For brainstorming, creative writing, and marketing copy — use 0.7 to 1.0. You want variety and originality.
-->

---

<!-- SLIDE 4 — top_p -->

<BulletReveal
  eyebrow="Nucleus sampling"
  title="top_p — Trim the Candidate Pool"
  :bullets="topP"
/>

<!--
top_p is a different approach to controlling randomness. Instead of reshaping the full distribution, it trims it.

top_p=0.9 means Claude only considers tokens whose cumulative probability totals 90%. All other tokens are excluded from sampling entirely — no matter what temperature says.

This is called nucleus sampling. It keeps the "reasonable" token candidates and throws away the long tail of unlikely options.

top_p=1.0 means no trimming — all tokens are eligible. top_p=0.5 aggressively focuses the pool to only the most likely candidates.

The practical difference from temperature: top_p controls the size of the candidate pool, while temperature controls the shape of probabilities within that pool.
-->

---

<!-- SLIDE 5 — top_k -->

<BulletReveal
  eyebrow="Hard count"
  title="top_k — Limit Candidates by Count"
  :bullets="topK"
/>

<!--
top_k is the simplest of the three. Set top_k=5 and Claude only considers the five highest-probability tokens at each step. It doesn't care about cumulative probability — it's a hard count.

top_k=1 is equivalent to greedy decoding — always pick the single most likely token.

Here's how to think about all three together. Temperature reshapes the probabilities. top_p trims the candidate pool by cumulative probability. top_k trims the candidate pool by count.

In practice, Anthropic recommends adjusting only one of these at a time. Stacking all three without a good reason usually produces unpredictable results. For most use cases, temperature alone is sufficient.
-->

---

<!-- SLIDE 6 — Exam Tip -->

<Frame>
  <Eyebrow>⚡ Exam Tip</Eyebrow>
  <SlideTitle>Low Temperature Is Not Always "Better"</SlideTitle>
  <div class="exam-stack">
    <CalloutBox variant="dont" title="Distractor pattern">
      <p>Assuming <code>temperature=0</code> produces the highest-quality output for <em>all</em> tasks — selecting it as the default in every scenario.</p>
    </CalloutBox>
    <CalloutBox variant="do" title="Exam signal">
      <p>A scenario that says "generate ten different product name ideas" is asking for creative output — <code>temperature=0</code> would produce ten nearly identical suggestions, which defeats the purpose.</p>
    </CalloutBox>
  </div>
</Frame>

<!--
Here's the exam trap: assuming that temperature=0 produces the highest-quality output for all tasks, and selecting it as the default recommendation in every scenario.

Temperature 0 is correct for deterministic tasks — code generation, data extraction, classification, factual Q&A. Temperature 0.7 to 1.0 is correct for creative tasks — brainstorming, marketing copy, story generation. The right temperature depends entirely on whether you want consistency or variety.

A scenario that says "generate ten different product name ideas" is asking for creative output — temperature=0 would produce ten nearly identical suggestions, which defeats the purpose.
-->

---

<!-- SLIDE 7 — Takeaways -->

<BulletReveal
  eyebrow="Takeaway"
  title="What to Remember"
  :bullets="takeaways"
/>

<!--
Four things to remember.

temperature reshapes the probability distribution at each token step — 0 is near-deterministic, 1.0 is highly varied; for the exam, match to task type (code/extraction = low, creative = high).

top_p (nucleus sampling) limits the candidate pool to tokens whose cumulative probability hits the threshold — top_p=0.9 excludes the long tail of unlikely tokens.

top_k is a hard count limit on candidate tokens — top_k=1 is greedy decoding, always picking the most likely token.

In practice, adjust only one of these at a time; Anthropic recommends temperature for most use cases, and stacking all three without intent produces unpredictable results.
-->
