---
theme: default
title: "Lecture 2.5: Stop Sequences — Teaching Claude Exactly When to Stop"
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
const useCases = [
  { label: '1 · Structured extraction', detail: 'Stop at </answer> — clean content inside a tag' },
  { label: '2 · Delimited output', detail: 'Stop at ###END### with no trailing content' },
  { label: '3 · Multi-turn dialogue', detail: 'Stop at turn boundaries like \\nHuman:' },
  { label: '4 · Code generation', detail: 'Stop after closing fence — one clean block' },
]

const takeaways = [
  { label: 'Up to 8,191 literals', detail: 'stop_sequences — any match halts generation; the string itself is not in the body' },
  { label: 'Check stop_reason', detail: "'stop_sequence' worked, 'end_turn' finished first — handle both cases" },
  { label: 'Exact match', detail: 'Case-sensitive, whitespace counts, no regex' },
  { label: 'Pair with prefills', detail: 'Prefill opens, stop sequence closes — exactly what you need' },
]

const tableRows = [
  { label: '"END"', cells: [{ text: '"end"', highlight: 'neutral' }, { text: '✗ no match', highlight: 'bad' }] },
  { label: '"END"', cells: [{ text: '"END"', highlight: 'neutral' }, { text: '✓ stops', highlight: 'good' }] },
  { label: '" END" (leading space)', cells: [{ text: '"END"', highlight: 'neutral' }, { text: '✗ no match', highlight: 'bad' }] },
  { label: '"</Answer>"', cells: [{ text: '"</answer>"', highlight: 'neutral' }, { text: '✗ no match', highlight: 'bad' }] },
]

const practiceCode = `import anthropic

client = anthropic.Anthropic()

response = client.messages.create(
    model="claude-opus-4-7",
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
    print(f"Unexpected stop reason: {response.stop_reason}")`

const combinedCode = `response = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=256,
    stop_sequences=["</answer>"],   # stop at closing tag
    messages=[
        {"role": "user", "content": "What is 144 divided by 12?"},
        {"role": "assistant", "content": "<answer>"}   # prefill opening tag
    ]
)
# response.content[0].text is the raw answer — no tags, no commentary`
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
      <div class="lec-cover__section">Section 2 · Lecture 2.5 · Domain 2</div>
      <h1 class="lec-cover__title">Stop Sequences</h1>
      <div class="lec-cover__subtitle">Teaching Claude Exactly When to Stop</div>
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
You ask Claude for a clean extraction: "wrap the city name in <answer> tags." Sometimes you get a perfect answer. Other times you get the answer — plus three paragraphs of unsolicited follow-up prose.

That's the overgeneration problem. And there's one API parameter built specifically to solve it.

Stop sequences are how you tell Claude: "the moment you produce this exact string, halt." It's a precision tool for bounded, parseable output. Let me show you how.
-->

---

<!-- SLIDE 2 — Overgeneration problem -->

<TwoColSlide
  variant="antipattern-fix"
  title="The Overgeneration Problem"
  leftLabel="✓ What you asked for"
  rightLabel="✗ What Claude gave you"
>
  <template #left>
    <p><code>{{ '<answer>Tokyo</answer>' }}</code></p>
    <p>Clean. Parseable. Done.</p>
  </template>
  <template #right>
    <p><code>{{ '<answer>Tokyo</answer>' }}</code></p>
    <p>...followed by three unsolicited follow-up paragraphs about Tokyo's population, history, and geography.</p>
    <p>Your parser has to fight through this.</p>
  </template>
</TwoColSlide>

<!--
Here's the overgeneration problem. You designed your prompt to return a clean, bounded answer inside <answer> tags. The first version is exactly what you asked for — clean, parseable, done.

But this is what you often get instead: the answer you wanted, followed by unsolicited follow-up paragraphs. Now your parser has to fight through all of it just to pull out the piece you care about.

Stop sequences are the tool to draw a hard line — the moment Claude produces a specific string, generation halts.
-->

---

<!-- SLIDE 3 — How stop sequences work -->

<TwoColSlide
  variant="compare"
  title="How Stop Sequences Work"
  leftLabel="Flow"
  rightLabel="Mechanics"
>
  <template #left>
    <p><strong>Claude generates tokens →</strong></p>
    <p>↓</p>
    <p><strong>WALL:</strong> <code>{{ '"</answer>"' }}</code></p>
    <p>✓ Included text returned</p>
    <p>✗ Wall itself never generated</p>
    <p style="margin-top: 16px;">Confirm via <code>stop_reason: "stop_sequence"</code> and <code>stop_sequence: {{ '"</answer>"' }}</code>.</p>
  </template>
  <template #right>
    <ul>
      <li><strong>Array</strong> — pass up to 8,191 strings via <code>stop_sequences</code></li>
      <li><strong>Match</strong> — API watches output; any exact match halts generation</li>
      <li><strong>Omit</strong> — the matched string is NOT in the response body</li>
      <li><strong>Verify</strong> — check <code>stop_reason</code> and <code>stop_sequence</code> to confirm</li>
    </ul>
  </template>
</TwoColSlide>

<!--
The stop_sequences parameter takes an array of strings.

While Claude generates tokens, the API watches the output for exact matches. The moment Claude produces one of your strings, generation halts.

The matched string itself is NOT included in the response body.

You can pass up to 8,191 stop sequences in a single request. In practice you'll rarely use more than one or two.

When a stop sequence fires, response.stop_reason is "stop_sequence" — not "end_turn". And response.stop_sequence contains the exact string that matched. Those two fields are your confirmation that the stop worked.
-->

---

<!-- SLIDE 4 — When stop sequences are the right tool -->

<BulletReveal
  eyebrow="Use cases"
  title="When Stop Sequences Are the Right Tool"
  :bullets="useCases"
/>

<!--
Stop sequences shine in four common scenarios.

First: structured extraction — stop at a closing XML tag to get just the content inside.

Second: delimited output — use a custom marker to signal the end of relevant content.

Third: multi-turn structured dialogue — stop when you detect the next speaker's turn boundary.

Fourth: code generation — stop after the closing fence so you get one clean block.

The common thread is that you control the prompt, so you know what strings to expect. You design the prompt to include a predictable stop marker. Then you tell the API exactly what that marker is.
-->

---

<!-- SLIDE 5 — Stop sequences in practice -->

<CodeBlockSlide
  eyebrow="Example"
  title="Stop Sequences in Practice"
  lang="python"
  :code="practiceCode"
  annotation="stop_reason tells you WHY it stopped · stop_sequence tells you WHAT matched · always handle the end_turn fallthrough."
/>

<!--
The response body contains everything Claude generated before the stop string. The stop string itself was never appended — it's reported in stop_sequence, not the text.

The else branch matters in production. If stop_reason is "end_turn", Claude ran out of content before hitting your marker. That usually means the prompt didn't produce the expected format. Always handle both cases.
-->

---

<!-- SLIDE 6 — Case sensitivity & whitespace traps -->

<ComparisonTable
  eyebrow="Exact literals"
  title="Case Sensitivity & Whitespace Traps"
  :columns='["What Claude Generated", "Did It Stop?"]'
  :rows="tableRows"
/>

<!--
Stop sequences are exact string matches. Not regex. Not fuzzy. Not case-insensitive. Every character must match exactly — including capitalization and whitespace.

Here are the traps candidates hit most often.

"END" will not catch "end" — different case, no match.
" END" with a leading space will not catch "END" — different bytes, no match.
"</Answer>" will not catch "</answer>" — again, case mismatch.

The fix is simple: use stop sequences where you control the casing in the prompt. XML tags are ideal because you write them in the prompt and you define the casing.
-->

---

<!-- SLIDE 7 — Combining stop sequences with prefills -->

<CodeBlockSlide
  eyebrow="Combined"
  title="Combining Stop Sequences with Prefills"
  lang="python"
  :code="combinedCode"
  annotation="Response = exactly the content between the tags. No opening tag (prefill). No closing tag (stop). Just the answer."
/>

<!--
You've now seen two complementary tools. Prefills control the START of Claude's output. Stop sequences control the END. Combine them and you get bounded extraction with zero regex.

The pattern: prefill with the opening tag, stop at the closing tag. The response body is exactly what's between — just the answer, nothing else.

This is the cleanest extraction pattern in the Claude API. Memorize it.
-->

---

<!-- SLIDE 8 — Exam Tip -->

<Frame>
  <Eyebrow>⚡ Exam Tip</Eyebrow>
  <SlideTitle>Stop Sequences Are Exact Literals</SlideTitle>
  <div class="exam-stack">
    <CalloutBox variant="dont" title="Trap">
      <p>Assuming stop sequences behave like regex or case-insensitive matching — wondering why uppercase fires inconsistently against lowercase output.</p>
    </CalloutBox>
    <CalloutBox variant="do" title="Correct pattern">
      <p>Stop sequences are exact, case-sensitive literals applied to the raw output stream. Use XML closing tags you control in the prompt. Always verify <code>stop_reason == 'stop_sequence'</code>.</p>
    </CalloutBox>
  </div>
</Frame>

<!--
Here's the exam trap: assuming stop sequences behave like regex or case-insensitive matching.

They don't. Stop sequences are exact, case-sensitive literals applied to the raw output stream. If a single character differs, the sequence won't fire.

The fix is structural: use sequences you control in the prompt — XML closing tags are the safest choice because you write them in the prompt and define the casing. And always verify stop_reason is "stop_sequence" before assuming the stop worked.
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

stop_sequences takes up to 8,191 exact literals — when Claude produces a match, generation halts and the matched string is not in the body.

response.stop_reason tells you why: "stop_sequence" means it worked, "end_turn" means Claude finished before hitting your marker. Handle both.

Stop sequences are case-sensitive exact matches — whitespace counts, regex does not apply.

Pair prefills with stop sequences: prefill opens, stop closes — exactly what you need, no regex, no post-processing.
-->
