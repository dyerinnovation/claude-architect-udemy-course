---
theme: default
title: "Lecture 2.9: Multimodal Inputs — Images in the Messages API"
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
  <div class="di-cover-title">Multimodal Inputs:<br><span style="color: #3CAF50;">Images</span> in the Messages API</div>
  <div class="di-cover-subtitle">Lecture 2.9 · Can Claude actually see?</div>
</div>

<img src="/logo.png" class="di-logo-centered" />

<!--
What happens when your users need to reason about images, not just text?

Maybe it's a screenshot, a chart, a scanned document, or a product photo.

Claude can process all of those — but the way you send images might surprise you.

It's not a separate parameter or a special endpoint. Images go right inside the messages array, alongside your text.

Let's look at exactly how that works.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 2 — The Content Block Model
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">The Content Block Model</div>

<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1.25rem; margin-top: 0.5rem; align-items: start;">

  <v-click>
  <div>
    <div class="di-col-left-label">String form</div>

```json
{
  "role": "user",
  "content": "Hello"
}
```

  </div>
  </v-click>

  <v-click>
  <div>
    <div class="di-col-right-label">Content-block form</div>

```json
{
  "role": "user",
  "content": [
    { "type": "text", "text": "Hello" }
  ]
}
```

  </div>
  </v-click>

</div>

<v-click>
<div style="margin-top: 0.8rem; font-size: 0.92rem; color: #111928; line-height: 1.6;">
  Both are valid. The array form unlocks <strong>mixed content</strong> — text <em>and</em> images in one message.
  <div style="display: flex; gap: 0.5rem; margin-top: 0.5rem; flex-wrap: wrap;">
    <div style="background: #E8F5EB; border-radius: 5px; padding: 0.3rem 0.6rem; font-size: 0.82rem;"><code>"type": "text"</code> → <code>text</code> field</div>
    <div style="background: #E8F5EB; border-radius: 5px; padding: 0.3rem 0.6rem; font-size: 0.82rem;"><code>"type": "image"</code> → <code>source</code> field</div>
  </div>
</div>
</v-click>

<v-click>
<div style="margin-top: 0.6rem; font-size: 0.88rem; color: #1A3A4A;">
  Order matters. Claude reads blocks top to bottom.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
You already know that content in the Messages API can be a plain string.

But content can also be an array of objects called content blocks.

Each block has a type field that tells Claude what kind of content it is.

Text content uses "type": "text" with a "text" field.

[click] Image content uses "type": "image" with a "source" field. That source object is where you tell Claude how to find the image.

Think of content blocks as slots — you can put text in one slot and an image in another. The order matters: Claude reads them in sequence, top to bottom.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 3 — Two Ways to Provide an Image
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Two Ways to Provide an Image</div>

<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-top: 0.5rem; align-items: start;">

  <v-click>
  <div>
    <div class="di-col-left-label">base64</div>

```json
{
  "type": "image",
  "source": {
    "type": "base64",
    "media_type": "image/jpeg",
    "data": "<base64 bytes>"
  }
}
```

<div class="di-col-body" style="font-size: 0.85rem;">
  Use when the image is <strong>private</strong> or <strong>local</strong>.
</div>
  </div>
  </v-click>

  <v-click>
  <div>
    <div class="di-col-right-label">url</div>

```json
{
  "type": "image",
  "source": {
    "type": "url",
    "url": "https://example.com/img.jpg"
  }
}
```

<div class="di-col-body" style="font-size: 0.85rem;">
  Use when the image is <strong>publicly accessible</strong> and stable. Claude fetches at inference time.
</div>
  </div>
  </v-click>

</div>

<v-click>
<div style="margin-top: 0.7rem; background: white; border-left: 3px solid #3CAF50; border-radius: 4px; padding: 0.5rem 0.75rem; font-size: 0.88rem;">
  Valid <code class="di-code-inline">media_type</code> values: <code>image/jpeg</code>, <code>image/png</code>, <code>image/gif</code>, <code>image/webp</code>
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
There are two source types for image content blocks.

The first is "type": "base64" — you encode the image bytes as a base64 string. You also provide media_type to tell Claude the image format. The valid media types are image/jpeg, image/png, image/gif, and image/webp.

[click] The second is "type": "url" — you provide a public HTTPS URL. Claude fetches the image at inference time.

Use base64 when the image is private or stored locally. Use URL when the image is already publicly accessible and stable.
-->

---
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 4 — Sending an Image (Python)
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">Sending an Image — Python</div>

<v-click>

```python {all|7-9|12-25|all}
import anthropic
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
)
```

</v-click>

<v-click>
<div style="display: flex; gap: 1rem; margin-top: 0.5rem; font-size: 0.82rem; color: #1A3A4A;">
  <div style="flex: 1; background: white; border-radius: 4px; padding: 0.4rem 0.6rem; border-left: 2px solid #3CAF50;">
    <strong style="color: #1B8A5A;">Image first, text after</strong> — Claude reads them in order
  </div>
  <div style="flex: 1; background: white; border-radius: 4px; padding: 0.4rem 0.6rem; border-left: 2px solid #E3A008;">
    <strong style="color: #E3A008;">All three required</strong> on a base64 source: <code>type</code>, <code>media_type</code>, <code>data</code>
  </div>
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Here is a complete example that encodes a local image as base64 and sends it with a question.

Notice the content field is an array — image block first, then text block.

The source object has type, media_type, and data — all three are required.

The text block with your question comes after the image block. Claude sees both together and reasons about them in context.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 5 — What Claude Can Do With Images
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">What Claude Can Do With Images</div>

<div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 0.75rem; margin-top: 0.75rem;">

  <v-click>
  <div class="di-step-card">
    <span class="di-step-num">Describe</span>
    Scene summary, object identification, general captioning
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card" style="border-left-color: #0D7377;">
    <span class="di-step-num" style="color: #0D7377;">Extract</span>
    OCR for screenshots, scanned forms, handwritten notes
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card" style="border-left-color: #E3A008;">
    <span class="di-step-num" style="color: #E3A008;">Analyze</span>
    Charts, graphs, diagrams — axes, trends, data labels
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card" style="border-left-color: #1B8A5A;">
    <span class="di-step-num" style="color: #1B8A5A;">Compare</span>
    Multiple images in one message — spot differences
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card">
    <span class="di-step-num">Answer</span>
    Targeted Qs: "what color is this?" "does this look right?"
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card" style="border-left-color: #0D7377;">
    <span class="di-step-num" style="color: #0D7377;">Identify</span>
    Objects, UI elements, defects in a visual QA pipeline
  </div>
  </v-click>

</div>

<v-click>
<div style="margin-top: 0.8rem; font-size: 0.9rem; color: #1A3A4A; background: #E8F5EB; border-radius: 6px; padding: 0.6rem 0.8rem;">
  <strong>For architects:</strong> document processing, UI testing, data extraction, visual QA — all unlock with the same content-block pattern.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Let's be specific about the vision capabilities that matter for your applications.

Claude can describe what's in an image and summarize the scene.

It can extract text from images — think screenshots, scanned forms, handwritten notes.

It can analyze charts, graphs, and diagrams — reading axes, trends, and data labels.

[click] You can send multiple images in a single message to compare them.

It answers targeted questions about visual content — "what color is the button?" or "does this circuit look correct?"

For architects: this makes Claude useful in document processing, UI testing, data extraction, and visual QA pipelines.
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
<div class="di-exam-subtitle">Images Are Content Blocks — Not a Separate Parameter</div>

<div class="di-exam-body">
  The exam will show candidates passing images as a standalone <code class="di-code-inline">image=</code> argument or a top-level key outside <code class="di-code-inline">messages</code>. That is <strong>not</strong> how the API works.
</div>
</v-click>

<v-click>
<div class="di-trap-box">
  <div class="di-trap-label">❌ Distractor Patterns</div>
  <ul style="margin: 0; padding-left: 1.2rem; font-size: 0.9rem;">
    <li>Passing images via a top-level <code>image=</code> parameter</li>
    <li>Putting the image URL in the <code>system</code> prompt</li>
    <li>Omitting <code>media_type</code> on a base64 source</li>
  </ul>
</div>
</v-click>

<v-click>
<div class="di-correct-box">
  <div class="di-correct-label">✓ The Only Correct Pattern</div>
  Images live inside the <code class="di-code-inline">content</code> array as a block with <code>"type": "image"</code> and a <code>source</code> object containing <code>type</code>, <code>media_type</code>, and either <code>data</code> or <code>url</code>.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
The exam trap: candidates pass images as a standalone parameter like image= or as a top-level key outside messages. This is not how the API works.

The correct approach: images go inside the content array of a message as a content block with "type": "image" and a "source" object. The source must include type ("base64" or "url"), media_type (e.g. "image/jpeg"), and either data or url.

A missing media_type on a base64 source is another common trap — it is required, not optional.
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
  <v-click><li>Message <code style="color: #3CAF50;">content</code> is an array of blocks — <code>"type": "text"</code> for text, <code>"type": "image"</code> for images</li></v-click>
  <v-click><li>Image sources are either <code style="color: #3CAF50;">"base64"</code> (with <code>media_type</code> and <code>data</code>) or <code style="color: #3CAF50;">"url"</code> (with <code>url</code>)</li></v-click>
  <v-click><li>Valid <code style="color: #3CAF50;">media_type</code> values: <code>image/jpeg</code>, <code>image/png</code>, <code>image/gif</code>, <code>image/webp</code></li></v-click>
  <v-click><li>Images and text can coexist in one message — order the blocks the way you want Claude to read them</li></v-click>
</ul>

<img src="/logo.png" class="di-logo" style="opacity: 0.75;" />

<!--
Four things to remember:

Message content is an array of blocks — text blocks use "type": "text", image blocks use "type": "image".

Image sources are either base64 (with media_type and data) or url (with url).

The valid media_type values are image/jpeg, image/png, image/gif, and image/webp.

Images and text can coexist in the same message — order them to match how Claude should read them.
-->
