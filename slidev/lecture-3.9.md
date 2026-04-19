---
theme: default
title: "Lecture 3.9: Explicit Context Passing Between Agents"
info: |
  Claude Certified Architect – Foundations
  Section 3: Domain 1 — Agentic Architecture & Orchestration (27%)
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
  <div class="di-course-label">Claude Certified Architect – Foundations</div>
  <div class="di-cover-title">Explicit Context Passing<br>Between Agents</div>
  <div class="di-cover-subtitle">Lecture 3.9 · Domain 1 — Agentic Architecture & Orchestration (27%)</div>
</div>

<img src="/logo.png" class="di-logo-centered" />

<!--
When multiple agents collaborate on a task, they cannot read each other's minds.

Each agent starts with only what you give it. If you pass a vague summary, it gets vague context. If you pass structured, attributed, complete information — it can reason on it precisely.

This lecture is about the discipline of explicit context passing: what to include, how to structure it, and why attribution metadata is non-negotiable.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 2 — The Problem: Context Doesn't Flow Automatically
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">The Problem: Context Doesn't Flow Automatically</div>

<div class="di-body" style="margin-top: 0.75rem;">

<v-click>
<p>In a multi-agent system, each agent runs in its <strong>own conversation context</strong>. There is no shared memory, no ambient awareness — only what you explicitly put in each agent's messages.</p>
</v-click>

<v-click>
<div style="display: flex; align-items: stretch; gap: 1.2rem; margin-top: 0.75rem;">
  <div style="flex: 1; background: #FFF0F0; border-left: 4px solid #E53E3E; border-radius: 6px; padding: 0.65rem 1rem; font-size: 0.92rem;">
    <div style="font-weight: 700; color: #E53E3E; margin-bottom: 0.3rem;">Implicit Handoff (Anti-Pattern)</div>
    Agent A finds three claims from research. It passes: <em>"Here is a summary of findings."</em><br>
    Agent B has no idea where the claims came from, how recent they are, or whether they were primary sources.
  </div>
</div>
</v-click>

<v-click>
<div style="display: flex; align-items: stretch; gap: 1.2rem; margin-top: 0.5rem;">
  <div style="flex: 1; background: #E8F5EB; border-left: 4px solid #3CAF50; border-radius: 6px; padding: 0.65rem 1rem; font-size: 0.92rem;">
    <div style="font-weight: 700; color: #1B8A5A; margin-bottom: 0.3rem;">Explicit Handoff (Correct Pattern)</div>
    Agent A passes a structured payload: claim text, source URL, document name, page number, publication date, and confidence level. Agent B can reason about the claims <em>and their provenance</em>.
  </div>
</div>
</v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
Here's the core problem.

In a multi-agent system, each agent runs in its own isolated conversation context. There is no shared memory between them — not unless you create it explicitly.

[click] The anti-pattern is implicit handoff: Agent A finishes its work and passes "a summary of findings." That sounds reasonable, but Agent B now has no idea where anything came from. It can't evaluate credibility. It can't cite sources. It can't flag when a claim might be outdated.

[click] The correct pattern is explicit handoff: Agent A packages its work as a structured payload with all the metadata Agent B will need. Claim text, source URL, document name, page number, publication date. Agent B can now reason precisely — including about provenance, not just content.

The discipline of explicit context passing is what separates agentic systems that are reliable from ones that hallucinate or lose track of information.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 3 — What Must Be in a Context Payload
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">What Must Be in a Context Payload</div>

<div class="di-body" style="margin-top: 0.75rem;">

<v-click>
<p>A context payload is the structured block of information passed from one agent to the next. For research or claim-based workflows, it must include:</p>
</v-click>

<div style="display: flex; flex-direction: column; gap: 0.45rem; margin-top: 0.6rem;">

  <v-click>
  <div class="di-step-card">
    <span class="di-step-num">Claim text</span> The verbatim extracted statement — not a paraphrase. Paraphrases lose precision.
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card" style="border-left-color: #0D7377;">
    <span class="di-step-num" style="color: #0D7377;">Source URL / Document name</span> Where this claim came from. Required for downstream agents to retrieve context or verify.
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card" style="border-left-color: #E3A008;">
    <span class="di-step-num" style="color: #E3A008;">Page / Section</span> Granular location within the source. Without this, verification is impractical.
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card" style="border-left-color: #1B8A5A;">
    <span class="di-step-num" style="color: #1B8A5A;">Publication date</span> Required for freshness evaluation. A claim from 2019 may be outdated — the downstream agent must know to check.
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card" style="border-left-color: #E53E3E;">
    <span class="di-step-num" style="color: #E53E3E;">Confidence / Extraction quality</span> Was this directly stated or inferred? Agent B needs to know how much weight to give it.
  </div>
  </v-click>

</div>

</div>

<img src="/logo.png" class="di-logo" />

<!--
A context payload for a research workflow must carry five categories of information.

[click] The claim text should be verbatim — not paraphrased. Paraphrasing introduces the extractor's interpretation, which may be wrong.

[click] Source attribution — URL or document name — tells the downstream agent where to find this claim if it needs to verify or expand on it.

[click] Page or section gives granular location. "Document name" alone is not sufficient when documents are long.

[click] Publication date enables freshness evaluation. A regulatory claim from five years ago may be superseded. The downstream agent can only know this if you tell it when the source was published.

[click] Confidence level — whether the claim was directly stated, implied, or inferred — tells the downstream agent how much weight to give it. If you're not surfacing confidence, the agent has no way to be appropriately skeptical.
-->

---
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 4 — Structured Payload in Code
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">Structured Context Payload — Code Pattern</div>

<v-click>

```python {all|3-14|17-29|all}
# Agent A: research agent builds a structured claim payload
def build_claim_payload(extracted_claims):
    return [
        {
            "claim": claim["verbatim_text"],
            "source_url": claim["url"],
            "document_name": claim["doc_title"],
            "page": claim["page_number"],
            "publication_date": claim["pub_date"],   # ISO 8601
            "confidence": claim["confidence"],        # "direct" | "inferred"
            "extracted_at": datetime.utcnow().isoformat()
        }
        for claim in extracted_claims
    ]

# Agent B: synthesis agent receives structured payload
def synthesize_with_context(claims_payload):
    context_block = "\n".join([
        f"CLAIM: {c['claim']}\n"
        f"  Source: {c['document_name']} (p.{c['page']})\n"
        f"  URL: {c['source_url']}\n"
        f"  Published: {c['publication_date']}\n"
        f"  Confidence: {c['confidence']}\n"
        for c in claims_payload
    ])
    return client.messages.create(
        model="claude-opus-4-6",
        messages=[{"role": "user", "content": f"Synthesize the following verified claims:\n\n{context_block}"}]
    )
```

</v-click>

<v-click>
<div style="display: flex; gap: 0.75rem; margin-top: 0.5rem; font-size: 0.82rem; color: #1A3A4A;">
  <div style="flex: 1; background: white; padding: 0.4rem 0.6rem; border-radius: 4px; border-left: 2px solid #3CAF50;">
    <strong style="color: #1B8A5A;">Do:</strong> pass the full structured payload — Agent B should never have to ask "where did this come from?"
  </div>
  <div style="flex: 1; background: white; padding: 0.4rem 0.6rem; border-radius: 4px; border-left: 2px solid #E53E3E;">
    <strong style="color: #E53E3E;">Don't:</strong> pass narrative summaries — they discard provenance and introduce the first agent's interpretive bias
  </div>
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Here's what this looks like in code.

Agent A builds a structured claim payload — a list of dicts with every field the downstream agent will need. Verbatim claim text, source URL, document name, page number, publication date in ISO 8601, confidence level, and an extraction timestamp.

[click] Agent B receives that payload and formats it into a structured context block before passing it to Claude. Notice the prompt contains structured, labeled information — not a prose summary. Claude can reason on labeled data far more reliably than on prose.

The rule: Agent B should never have to ask "where did this come from?" If the payload is complete, it never will.
-->

---
layout: two-cols
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 5 — Summary vs Structured: The Tradeoff
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header" style="margin: -1.5rem -1rem 1rem -2rem; padding-right: 1rem;">Narrative Summary vs Structured Payload</div>

<v-click>
<div style="padding-right: 1.2rem;">
  <div class="di-col-left-label">Narrative Summary</div>
  <div class="di-col-body">
    <ul>
      <li>Fast to produce — just ask the first agent to summarize</li>
      <li>Easy to read — but easy to misinterpret</li>
      <li>Loses source attribution</li>
      <li>Loses publication dates and page references</li>
      <li>Embeds the first agent's paraphrase bias</li>
    </ul>
    <div class="di-col-warning">
      <strong>Consequence:</strong> downstream agents hallucinate citations or report wrong facts with false confidence
    </div>
  </div>
</div>
</v-click>

::right::

<v-click>
<div style="padding-left: 1.2rem; padding-top: 5rem;">
  <div class="di-col-right-label">Structured Payload</div>
  <div class="di-col-body">
    <ul>
      <li>More effort to design — but preserves all provenance</li>
      <li>Claim text is verbatim — no interpretation loss</li>
      <li>All metadata intact: URL, date, page, confidence</li>
      <li>Downstream agents can evaluate freshness and credibility</li>
      <li>Audit trail survives across the entire pipeline</li>
    </ul>
    <div style="margin-top: 0.5rem; background: #E8F5EB; padding: 0.5rem 0.7rem; border-radius: 5px; font-size: 0.88rem;">
      <strong>Use for:</strong> any multi-agent workflow where attribution, accuracy, or compliance matters
    </div>
  </div>
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Let's make the tradeoff explicit.

A narrative summary is easy to produce and easy to read. But it loses everything except the content. By the time Agent B gets it, there are no sources, no dates, no page numbers. If Agent B then produces a report that cites specific documents, it's manufacturing citations — because that information was discarded upstream.

[click] A structured payload takes more design effort — you have to decide what fields matter and make sure Agent A populates them. But all provenance is preserved. Downstream agents can evaluate freshness, verify credibility, and carry the audit trail all the way to the output.

The choice is clear: for any workflow where accuracy, attribution, or compliance matters, use structured payloads. Narrative summaries are only acceptable for informal internal routing where stakes are low.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 6 — Context Injection Patterns
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">How to Inject Context Into the Next Agent</div>

<div class="di-body" style="margin-top: 0.75rem;">

<v-click>
<p>There are three injection patterns. The choice depends on the volume of context and the agent's role.</p>
</v-click>

<div style="display: flex; flex-direction: column; gap: 0.45rem; margin-top: 0.5rem;">

  <v-click>
  <div class="di-step-card">
    <span class="di-step-num">System prompt injection</span> Stable, reusable context — the agent's role, domain rules, output schema. Put it in the system prompt. It doesn't change per-request.
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card" style="border-left-color: #0D7377;">
    <span class="di-step-num" style="color: #0D7377;">First user message injection</span> Per-request context — the structured claim payload, the task state, the prior agent's output. Format it clearly inside the first user turn.
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card" style="border-left-color: #1B8A5A;">
    <span class="di-step-num" style="color: #1B8A5A;">Tool result injection</span> Dynamic context fetched mid-task — retrieved documents, database lookups. This arrives via the tool result loop and is appended to the conversation history.
  </div>
  </v-click>

  <v-click>
  <div style="background: #FFF8E6; border-left: 3px solid #E3A008; padding: 0.55rem 0.8rem; border-radius: 4px; font-size: 0.88rem; margin-top: 0.25rem;">
    <strong>Rule of thumb:</strong> Context that is known before the agent call → inject via system prompt or first user message. Context that depends on tool execution → inject via tool results. Never conflate these.
  </div>
  </v-click>

</div>

</div>

<img src="/logo.png" class="di-logo" />

<!--
There are three places to inject context into an agent, and the choice matters.

[click] System prompt injection is for stable context: the agent's role, the domain rules it must follow, the output format it should produce. This doesn't change per request — put it in the system prompt once.

[click] First user message injection is for per-request context: the structured payload from the prior agent, the current task state, any inputs specific to this invocation.

[click] Tool result injection is for dynamic context: information the agent retrieves during execution. This arrives through the normal tool result loop and gets appended to the conversation history.

[click] The rule: if you know it before the agent call, inject it upfront. If it depends on what the agent does during execution, let it arrive as tool results. Mixing these up leads to context that's either stale or never seen.
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
<div class="di-exam-subtitle">Context Passing in Multi-Agent Pipelines</div>

<div class="di-exam-body">
  The exam will present a multi-agent scenario and ask what information must be included in the handoff. The trap is always that a "summary" seems sufficient — it never is when attribution matters.
</div>
</v-click>

<v-click>
<div class="di-trap-box">
  <div class="di-trap-label">❌ The Trap</div>
  A research agent finishes and passes a narrative summary to a synthesis agent. The synthesis agent produces a report with source citations.
  <br><br>
  <em>Question: Where do the citations come from?</em> They can't come from the summary — they were discarded. The synthesis agent will fabricate them. This is the anti-pattern.
</div>
</v-click>

<v-click>
<div class="di-correct-box">
  <div class="di-correct-label">✓ The Right Answer</div>
  Attribution metadata — source URL, document name, page number, publication date — must be included in the structured context payload. Summaries are acceptable only when downstream agents do <strong>not</strong> need to attribute, cite, or verify.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
The exam will test your understanding of what belongs in a multi-agent handoff.

The trap question goes like this: a research agent finishes and passes a summary to a synthesis agent. The synthesis agent is supposed to produce a cited report. Where do the citations come from?

The answer is: they can't come from the summary, because the summary discarded them. If the synthesis agent produces citations, it's fabricating them. This is the anti-pattern.

[click] The correct answer: attribution metadata must be included in the structured payload. Source URL, document name, page number, publication date — all of it. Summaries are acceptable only in workflows where the downstream agent has no need to cite, attribute, or verify the information it receives.

On the exam, if you see a multi-agent pipeline that requires accurate attribution and the handoff is described as a "summary," that is the wrong answer. The right answer involves structured, attributed context.
-->

---
layout: default
class: di-takeaway-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 8 — Key Takeaways
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-takeaway-title">Explicit Context Passing — What to Remember</div>

<ul class="di-takeaway-list">
  <v-click><li>Each agent has <strong>only what you give it</strong> — there is no ambient shared memory between agents</li></v-click>
  <v-click><li>Always pass <strong>structured payloads</strong>, not narrative summaries, when attribution or accuracy matters</li></v-click>
  <v-click><li>A claim payload must include: verbatim text, source URL, document name, page, publication date, and confidence level</li></v-click>
  <v-click><li><strong>Never paraphrase</strong> when passing claims — verbatim preserves precision; paraphrase embeds the first agent's interpretation</li></v-click>
  <v-click><li>Inject known context via system prompt or first user message; dynamic context arrives via tool results</li></v-click>
  <v-click><li>Summaries that discard provenance cause downstream agents to fabricate citations — this is a pipeline design failure, not a model failure</li></v-click>
</ul>

<img src="/logo.png" class="di-logo" style="opacity: 0.75;" />

<!--
To summarize what you must remember from this lecture:

Each agent has only what you give it. There is no shared memory, no ambient awareness between agents.

Always pass structured payloads when attribution or accuracy matters. Narrative summaries discard provenance.

A complete claim payload includes verbatim text, source URL, document name, page number, publication date, and confidence level.

Never paraphrase when passing claims. Verbatim text preserves precision. Paraphrase embeds the first agent's interpretation.

Known context goes in upfront — system prompt or first user message. Dynamic context arrives via tool results.

And the most important exam-facing rule: if a pipeline discards provenance through a summary handoff, any downstream citations are fabricated. That's a pipeline design failure. The fix is explicit, structured context passing.
-->
