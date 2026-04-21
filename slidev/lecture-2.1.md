---
theme: default
title: "Lecture 2.1: The Messages API — Anatomy of a Request and Response"
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
const coreParams = [
  { label: 'model', detail: 'Which Claude to use — e.g. claude-sonnet-4-6' },
  { label: 'max_tokens', detail: 'Hard ceiling on generated tokens' },
  { label: 'messages', detail: 'Conversation history — array of turns' },
  { label: 'system', detail: 'Persistent top-level instructions' },
  { label: 'temperature', detail: 'How creative vs deterministic' },
]

const stopReasons = [
  { label: 'end_turn', detail: 'Claude finished naturally' },
  { label: 'max_tokens', detail: 'Hit the ceiling — response may be truncated' },
  { label: 'stop_sequence', detail: 'A custom stop string was triggered' },
  { label: 'tool_use', detail: "Claude wants to call a tool — loop continues" },
]

const takeaways = [
  { label: 'Three required fields', detail: 'Every messages.create() call needs model, max_tokens, messages — system is a separate top-level parameter' },
  { label: 'Two roles only', detail: "messages array accepts only 'user' and 'assistant' — 'system' is NOT a valid role" },
  { label: 'Content is a list', detail: "Responses return a content list of typed blocks — 'text' for plain output, 'tool_use' when tools fire" },
  { label: 'Always check stop_reason', detail: 'It tells you WHY Claude stopped — critical for handling truncation and tool loops' },
]

const requestCode = `import anthropic

client = anthropic.Anthropic()  # Uses ANTHROPIC_API_KEY from environment

response = client.messages.create(
    model="claude-sonnet-4-6",              # Which Claude model to use
    max_tokens=1024,                        # Max tokens in the response
    system="You are a helpful assistant.",  # Top-level system prompt
    messages=[
        {"role": "user",      "content": "What is the capital of France?"},
        {"role": "assistant", "content": "The capital of France is Paris."},
        {"role": "user",      "content": "What is its population?"}
    ]
)`

const responseCode = `{
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
}`

const readCode = `# Most common case: access the first text block directly
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
print(f"Output: {response.usage.output_tokens}")`
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
      <div class="lec-cover__section">Section 2 · Lecture 2.1 · Domain 2</div>
      <h1 class="lec-cover__title">The Messages API</h1>
      <div class="lec-cover__subtitle">Anatomy of a Request &amp; Response</div>
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
</style>

<!--
You've probably called the Claude API before.

But do you actually know what every field does?

Most developers — and most exam candidates — learn just enough to make it work.

That's not enough to pass the CCA-F exam.

Today we're going to dissect every part of a request and response. By the end of this lecture, you'll know what each field is, what it does, and why it exists.
-->

---

<!-- SLIDE 2 — The Five Core Request Parameters -->

<BulletReveal
  eyebrow="The primitives"
  title="The Five Core Request Parameters"
  :bullets="coreParams"
/>

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

<!-- SLIDE 3 — A Complete Request, Annotated -->

<CodeBlockSlide
  eyebrow="Anatomy"
  title="A Complete Request, Annotated"
  lang="python"
  :code="requestCode"
  annotation="system is top-level — never inside messages. Roles alternate: only 'user' and 'assistant'. Claude has no memory — you pass history every call."
/>

<!--
Let's look at a real, complete request.

Notice a few things here. system is at the top level of the call — not inside the messages array.

The messages array alternates between "user" and "assistant" roles.

The conversation history is your responsibility to maintain and pass each time.

Claude has no memory between calls — everything it knows about the conversation is in this array.
-->

---

<!-- SLIDE 4 — The Response Object, Dissected -->

<CodeBlockSlide
  eyebrow="Response"
  title="The Response Object, Dissected"
  lang="json"
  :code="responseCode"
  annotation="content is a list of typed blocks, not a string. stop_reason tells you why Claude stopped. usage = exactly what you're billed for."
/>

<!--
Now let's look at what comes back.

The content field is a list, not a string. Even a simple text response is wrapped in a content block with "type": "text".

That list structure matters — when tool use is involved, you'll see "type": "tool_use" blocks instead.

stop_reason tells you why Claude stopped generating. end_turn means Claude finished naturally. max_tokens means it hit the ceiling you set. stop_sequence means a custom stop string was triggered.

usage tells you exactly what you're being billed for.
-->

---

<!-- SLIDE 5 — stop_reason Values -->

<BulletReveal
  eyebrow="stop_reason"
  title="The Four Values You'll See"
  :bullets="stopReasons"
/>

<!--
stop_reason is the field you'll return to again and again throughout this course.

end_turn means Claude finished naturally. max_tokens means it hit the ceiling you set — which means the response may be cut off. stop_sequence means a custom stop string was triggered. tool_use means Claude wants to call a tool — the loop must continue.

The production rule: always check stop_reason. If it's "max_tokens", you may need to continue the response with another call.
-->

---

<!-- SLIDE 6 — Reading the Response in Code -->

<CodeBlockSlide
  eyebrow="Reading the response"
  title="Access Text, Stop Reason, and Usage"
  lang="python"
  :code="readCode"
  annotation="Quick: content[0].text works for simple text. Production: iterate content blocks — especially with tools."
/>

<!--
Knowing the structure matters when you go to read the response.

The shortcut response.content[0].text works for simple cases. But in production — especially with tools — you should always iterate over response.content.

Checking stop_reason is important for robustness. If stop_reason is "max_tokens", the response was cut off and you may need to continue it.
-->

---

<!-- SLIDE 7 — Exam Tip: System Is NOT a Role -->

<Frame>
  <Eyebrow>⚡ Exam Tip</Eyebrow>
  <SlideTitle>System Is NOT a Role</SlideTitle>
  <div class="exam-stack">
    <CalloutBox variant="dont" title="Distractor pattern">
      <p><code>{"role": "system", "content": "..."}</code> inside the <code>messages</code> array. That's OpenAI's API — not Claude's.</p>
    </CalloutBox>
    <CalloutBox variant="do" title="Correct pattern">
      <p><code>system="..."</code> at the top level of <code>client.messages.create()</code>, alongside <code>model</code> and <code>max_tokens</code>. The only valid roles inside <code>messages</code> are <code>"user"</code> and <code>"assistant"</code>.</p>
    </CalloutBox>
  </div>
</Frame>

<style>
.exam-stack { margin-top: 48px; display: flex; flex-direction: column; gap: 28px; flex: 1; min-height: 0; }
</style>

<!--
Here's the exam trap you need to watch for: passing the system prompt as a message in the messages array using role: "system". This is not valid in the Claude API.

The system parameter is always top-level in client.messages.create(), never inside the messages array. The only valid roles in messages are "user" and "assistant".

If you see a question showing {"role": "system", "content": "..."} inside the messages array, that is the wrong answer. That pattern comes from OpenAI's API and does not work here.
-->

---

<!-- SLIDE 8 — Takeaways -->

<BulletReveal
  eyebrow="Takeaway"
  title="What to Remember"
  :bullets="takeaways"
/>

<!--
Four things to hold onto from this lecture.

Every messages.create() call requires model, max_tokens, and messages — the system parameter is separate from the array.

The messages array only accepts two roles: "user" and "assistant" — "system" is not a valid role.

Responses return a content list of typed blocks — always "text" for plain responses, "tool_use" when tools are involved.

stop_reason tells you why generation ended — always check it in production code to handle truncated responses.
-->
