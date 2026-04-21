---
theme: default
title: "Lecture 2.9: Multimodal Inputs — Images in the Messages API"
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
const capabilities = [
  { label: 'Describe', detail: 'Scene summary, object ID, general captioning' },
  { label: 'Extract', detail: 'OCR — screenshots, scanned forms, handwritten notes' },
  { label: 'Analyze', detail: 'Charts, graphs, diagrams — axes, trends, labels' },
  { label: 'Compare', detail: 'Multiple images in one message — spot differences' },
  { label: 'Answer', detail: 'Targeted Qs: "what color?" "does this look right?"' },
  { label: 'Identify', detail: 'Objects, UI elements, defects (visual QA)' },
]

const takeaways = [
  { label: 'content is an array of blocks', detail: "'type':'text' for text, 'type':'image' for images" },
  { label: 'Two source types', detail: "'base64' (with media_type + data) or 'url' (with url)" },
  { label: 'Valid media_type', detail: 'image/jpeg, image/png, image/gif, image/webp' },
  { label: 'Order matters', detail: 'Images + text coexist in one message — order blocks the way Claude should read them' },
]

const imageCode = `import anthropic
import base64

client = anthropic.Anthropic()

# Read the image file and encode it as base64
with open("diagram.png", "rb") as image_file:
    image_data = base64.standard_b64encode(image_file.read()).decode("utf-8")

response = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=1024,
    messages=[
        {
            "role": "user",
            "content": [
                {
                    "type": "image",
                    "source": {
                        "type": "base64",
                        "media_type": "image/png",  # Must match actual file type
                        "data": image_data,          # Base64-encoded bytes
                    },
                },
                {
                    "type": "text",
                    "text": "What does this diagram show?",
                },
            ],
        }
    ],
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
      <div class="lec-cover__section">Section 2 · Lecture 2.9 · Domain 2</div>
      <h1 class="lec-cover__title">Multimodal Inputs</h1>
      <div class="lec-cover__subtitle">Images in the Messages API</div>
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
You've used Claude for text. Now you need it to see.

A customer sends you a screenshot of an error. An insurance claim shows up as a photo of a damaged car. A chart in a PDF needs its data extracted.

Claude can handle all of this — but not through a separate "vision" API. Images plug into the same Messages API you already know, as a new kind of content block.

In this lecture, I'll show you exactly how that works, and the distractors the exam will throw at you.
-->

---

<!-- SLIDE 2 — Content block model -->

<TwoColSlide
  variant="compare"
  title="The Content Block Model"
  leftLabel="String form"
  rightLabel="Content-block form"
>
  <template #left>
    <pre><code>{"role": "user",
 "content": "Hello"}</code></pre>
  </template>
  <template #right>
    <pre><code>{"role": "user",
 "content": [
   {"type": "text",
    "text": "Hello"}
 ]}</code></pre>
    <p style="margin-top: 18px;">Array form unlocks mixed content (text + images). Order matters — Claude reads top to bottom.</p>
  </template>
</TwoColSlide>

<!--
You already know that content in the Messages API can be a plain string.

But content can also be an array of objects called content blocks.

Each block has a type field that tells Claude what kind of content it is.

Text content uses "type": "text" with a "text" field.

Image content uses "type": "image" with a "source" field. That source object is where you tell Claude how to find the image.

Think of content blocks as slots — you can put text in one slot and an image in another. The order matters: Claude reads them in sequence, top to bottom.
-->

---

<!-- SLIDE 3 — Two ways to provide an image -->

<TwoColSlide
  variant="compare"
  title="Two Ways to Provide an Image"
  leftLabel="base64"
  rightLabel="url"
>
  <template #left>
    <pre><code>{"type": "image",
 "source": {
   "type": "base64",
   "media_type": "image/jpeg",
   "data": "&lt;base64 bytes&gt;"
 }}</code></pre>
    <p>Use when private or local.</p>
  </template>
  <template #right>
    <pre><code>{"type": "image",
 "source": {
   "type": "url",
   "url": "https://example.com/img.jpg"
 }}</code></pre>
    <p>Use when publicly accessible and stable. Claude fetches at inference time.</p>
    <p style="margin-top: 12px;">Valid <code>media_type</code>: <code>image/jpeg</code>, <code>image/png</code>, <code>image/gif</code>, <code>image/webp</code></p>
  </template>
</TwoColSlide>

<!--
There are two source types for image content blocks.

The first is "type": "base64" — you encode the image bytes as a base64 string. You also provide media_type to tell Claude the image format. The valid media types are image/jpeg, image/png, image/gif, and image/webp.

The second is "type": "url" — you provide a public HTTPS URL. Claude fetches the image at inference time.

Use base64 when the image is private or stored locally. Use URL when the image is already publicly accessible and stable.
-->

---

<!-- SLIDE 4 — Sending an image in Python -->

<CodeBlockSlide
  eyebrow="Example"
  title="Sending an Image — Python"
  lang="python"
  :code="imageCode"
  annotation="Image first, text after — Claude reads blocks in order · All three required on base64: type, media_type, data."
/>

<!--
Here is a complete example that encodes a local image as base64 and sends it with a question.

Notice the content field is an array — image block first, then text block.

The source object has type, media_type, and data — all three are required.

The text block with your question comes after the image block. Claude sees both together and reasons about them in context.
-->

---

<!-- SLIDE 5 — What Claude can do with images -->

<BulletReveal
  eyebrow="Capabilities"
  title="What Claude Can Do With Images"
  :bullets="capabilities"
/>

<!--
Claude's image capabilities cover six major use cases.

Describe — scene summary, object identification, general captioning.

Extract — OCR for screenshots, scanned forms, handwritten notes.

Analyze — read charts, graphs, and diagrams with specific data extraction.

Compare — include multiple images in one message and ask about differences.

Answer — targeted questions like "what color is this?" or "does this look right?"

Identify — objects, UI elements, defects in a visual QA pipeline.

For architects, this unlocks document processing, UI testing, data extraction, and visual QA without a separate vision model.
-->

---

<!-- SLIDE 6 — Exam Tip -->

<Frame>
  <Eyebrow>⚡ Exam Tip</Eyebrow>
  <SlideTitle>Images Are Content Blocks — Not a Separate Parameter</SlideTitle>
  <div class="exam-stack">
    <CalloutBox variant="dont" title="Distractor patterns">
      <p>Passing images via a top-level <code>image=</code> parameter · putting the image URL in the system prompt · omitting <code>media_type</code> on a base64 source.</p>
    </CalloutBox>
    <CalloutBox variant="do" title="Only correct pattern">
      <p>Images live inside the <code>content</code> array as a block with <code>'type':'image'</code> and a source object containing <code>type</code>, <code>media_type</code>, and either <code>data</code> or <code>url</code>.</p>
    </CalloutBox>
  </div>
</Frame>

<!--
The exam distractors for multimodal inputs all share a pattern: they invent a mechanism that doesn't exist.

Passing images via a top-level image= parameter — not a thing.
Putting the image URL in the system prompt — not a thing.
Omitting media_type on a base64 source — will be rejected.

The only correct pattern: images live inside the content array as a block with "type":"image" and a source object containing type, media_type, and either data or url.
-->

---

<!-- SLIDE 7 — Takeaways -->

<BulletReveal
  eyebrow="Takeaway"
  title="What to Remember"
  :bullets="takeaways"
/>

<!--
Four things to hold onto.

Message content is an array of blocks — "type":"text" for text, "type":"image" for images.

Image sources: "base64" with media_type + data, or "url" with url.

Valid media_types: image/jpeg, image/png, image/gif, image/webp.

Images and text coexist in one message — order the blocks the way Claude should read them.
-->
