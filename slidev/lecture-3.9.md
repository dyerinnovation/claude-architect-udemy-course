---
theme: default
title: "Lecture 3.9: Explicit Context Passing Between Agents"
info: |
  Claude Certified Architect – Foundations
  Section 3 — Agentic Architecture & Orchestration (Domain 1, 27%)
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
const narrativeLeft = "Agent A finds three claims. Passes: 'Here is a summary of findings.' Agent B has no idea where the claims came from, how recent they are, or whether they were primary sources."
const explicitRight = 'Agent A passes a structured payload: claim text, source URL, document name, page number, publication date, confidence level. Agent B can reason about the claims AND their provenance.'

const narrativeBullets = [
  'Fast to produce — just ask the first agent to summarise',
  'Easy to read — easy to misinterpret',
  'Loses source attribution',
  'Loses publication dates and page references',
  "Embeds the first agent's paraphrase bias",
]
const structuredBullets = [
  'More design effort — preserves all provenance',
  'Claim text is verbatim — no interpretation loss',
  'All metadata intact: URL, date, page, confidence',
  'Downstream agents evaluate freshness and credibility',
  'Audit trail survives across the entire pipeline',
]

const injectionSteps = [
  { title: 'System prompt injection', body: "Stable, reusable context — agent's role, domain rules, output schema. Doesn't change per request." },
  { title: 'First user message injection', body: "Per-request context — structured claim payload, task state, prior agent's output. Format clearly inside the first user turn." },
  { title: 'Tool result injection', body: 'Dynamic context fetched mid-task — retrieved documents, DB lookups. Arrives via the tool result loop, appended to history.' },
]

const takeaways = [
  { label: 'Each agent has only what you give it', detail: 'No ambient shared memory — everything must be passed explicitly in system prompt, first user message, or tool result.' },
  { label: 'Structured payloads beat narrative summaries', detail: 'Always pass structured payloads whenever attribution or accuracy matters downstream.' },
  { label: 'Full claim payload has five fields', detail: 'Verbatim text, source URL, document name, page number, publication date, confidence level.' },
  { label: 'Never paraphrase when passing claims', detail: 'Verbatim preserves precision; paraphrase introduces drift the downstream agent cannot detect.' },
  { label: 'Match channel to context lifecycle', detail: 'Known context → system prompt or first user. Dynamic context → tool results. Never conflate.' },
  { label: 'Summaries without provenance cause citation fabrication', detail: 'Downstream will invent plausible-looking sources to fill the gap — a pipeline-design failure.' },
]

const payloadCode = `# Build a structured context payload — not a narrative summary.
def build_claim_payload(extracted_claims):
    return [
        {
            "claim": c["verbatim_text"],        # never paraphrase
            "source_url": c["url"],
            "document_name": c["doc"],
            "page": c["page"],
            "publication_date": c["date"],      # ISO 8601
            "confidence": c["confidence"],      # 'direct' | 'inferred'
        }
        for c in extracted_claims
    ]

# Inject that payload into the synthesis agent via the first user message.
def synthesize_with_context(claim_payload):
    context_block = "\\n".join(
        f"- [{c['confidence']}] {c['claim']}  "
        f"({c['document_name']}, p.{c['page']}, {c['publication_date']})  "
        f"<{c['source_url']}>"
        for c in claim_payload
    )
    return client.messages.create(
        model="claude-opus-4-7",
        system=SYNTHESIS_SYSTEM_PROMPT,
        messages=[{
            "role": "user",
            "content": (
                "Here are the verified claims with full provenance:\\n\\n"
                f"{context_block}\\n\\n"
                "Synthesize a report; cite each claim by source and page."
            ),
        }],
    )`
</script>

<Frame bg="var(--forest-900)" color="var(--mint-100)" :pad="false">
  <div style="position:absolute; inset:0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%);"></div>
  <div style="position:relative; z-index:1; padding:110px 120px 96px; width:100%; height:100%; display:flex; flex-direction:column; justify-content:space-between;">
    <div style="display:flex; align-items:center; gap:24px;">
      <img src="/assets/logo-mark.png" alt="" style="width:72px; height:auto;" />
      <div style="font-family: var(--font-body); font-size:26px; font-weight:500; letter-spacing:0.14em; text-transform:uppercase; color: var(--mint-200);">Dyer Innovation</div>
    </div>
    <div>
      <div style="font-family: var(--font-body); font-size:26px; font-weight:600; letter-spacing:0.16em; text-transform:uppercase; color: var(--sprout-500); margin-bottom:40px;">Lecture 3.9 &middot; Domain 1</div>
      <h1 style="font-family: var(--font-display); font-weight:500; font-size:128px; line-height:1.02; letter-spacing:-0.025em; color: var(--paper-0); margin:0; max-width:1600px;">Explicit Context<br /><span style="color: var(--sprout-500);">Passing</span> Between Agents</h1>
      <div style="font-family: var(--font-display); font-size:44px; color: var(--mint-200); margin-top:40px; font-weight:400; max-width:1300px; line-height:1.3;">Structured payloads, not narrative summaries.</div>
    </div>
    <div style="display:flex; align-items:center; gap:48px; font-family: var(--font-body); font-size:26px; color: var(--mint-200); letter-spacing:0.06em;">
      <span>Domain 1 · 27%</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>Scenario 3 — Multi-Agent Research</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>Provenance-preserving</span>
    </div>
  </div>
</Frame>

<!--
Welcome to Lecture 3.9 — Explicit Context Passing Between Agents. In the last lecture we saw how to spawn subagents in parallel. Now we tackle the question that trips up most multi-agent designs: how does information actually move from one agent to the next? Subagents share no ambient memory. Whatever downstream agents need to know, you have to pass in explicitly. And the way you pass it — narrative summary versus structured payload — decides whether your pipeline preserves truth or fabricates it.
-->

---

<TwoColSlide
  variant="antipattern-fix"
  title="Context Doesn't Flow Automatically"
  eyebrow="Implicit vs explicit handoff"
  leftLabel="❌ Implicit Handoff"
  rightLabel="✓ Explicit Handoff"
  :footerNum="2"
  :footerTotal="8"
>
  <template #left>
    <p>{{ narrativeLeft }}</p>
  </template>
  <template #right>
    <p>{{ explicitRight }}</p>
  </template>
</TwoColSlide>

<!--
The mental model is simple. Agent A runs, produces findings, and hands off to Agent B. Implicit handoff: Agent A writes a summary — "here is what I found" — and Agent B inherits only that. Explicit handoff: Agent A passes a structured payload that carries the findings AND every piece of metadata the downstream agent needs to reason about them. The implicit version looks more natural in English. The explicit version is what production systems require. Everything from here on in this lecture is about making that explicit version routine.
-->

---

<Frame>
  <Eyebrow>Required payload fields</Eyebrow>
  <SlideTitle>What Must Be in a Context Payload</SlideTitle>
  <div style="margin-top: 48px; display: grid; grid-template-columns: 1fr 1fr; gap: 18px;">
    <SchemaField name="claim" type="string (verbatim)" :required="true" description="The extracted statement — not a paraphrase. Paraphrases lose precision." />
    <SchemaField name="source_url / document_name" type="string" :required="true" description="Where the claim came from — required for downstream agents to verify." />
    <SchemaField name="page / section" type="string" :required="true" description="Granular location inside the source. Without it, verification is impractical." />
    <SchemaField name="publication_date" type="ISO 8601" :required="true" description="Required for freshness evaluation. A 2019 claim may now be outdated." />
    <SchemaField name="confidence" type="'direct' | 'inferred'" :required="true" description="Was this directly stated or inferred? How much weight to give it." />
  </div>
  <SlideFooter label="Structured-payload contract" :num="3" :total="8" />
</Frame>

<!--
The contract. A claim payload that survives a multi-agent pipeline has five required fields. Claim text: verbatim, not paraphrased — paraphrase introduces drift the downstream cannot detect. Source URL or document name: the location the claim came from — required for verification. Page or section: granular location inside that source — without it, a verifier would have to re-read the entire document. Publication date in ISO 8601: required for freshness reasoning — a 2019 claim about model benchmarks may be worse than useless now. Confidence: was this stated directly in the source, or inferred from context — the downstream agent needs to know how much weight to give it. Five fields. Non-negotiable for anything where accuracy matters.
-->

---

<CodeBlockSlide
  eyebrow="Code pattern"
  title="Structured Context Payload"
  lang="python"
  :code="payloadCode"
  annotation="Do: pass the full structured payload — Agent B never asks 'where did this come from?' Don't: narrative summaries — they discard provenance and embed the first agent's bias."
  :footerNum="4"
  :footerTotal="8"
/>

<!--
Here's the implementation. build_claim_payload takes a list of extracted claims and returns a list of dicts with the five required fields. The claim text is copied verbatim — never paraphrased. Then synthesize_with_context takes that payload, formats each claim into a line that preserves confidence, document name, page, date, and URL, and injects it into the first user message for the synthesis agent. The synthesis agent now has everything it needs to cite by source and page — and a human reviewer has everything they need to audit. Compare that to the alternative: ask the first agent to "summarize the findings." The summary looks fine, reads well, and is structurally useless.
-->

---

<TwoColSlide
  variant="compare"
  title="Narrative Summary vs Structured Payload"
  eyebrow="The real cost of summaries"
  leftLabel="Narrative Summary"
  rightLabel="Structured Payload"
  :footerNum="5"
  :footerTotal="8"
>
  <template #left>
    <ul>
      <li v-for="(b, i) in narrativeBullets" :key="i">{{ b }}</li>
    </ul>
  </template>
  <template #right>
    <ul>
      <li v-for="(b, i) in structuredBullets" :key="i">{{ b }}</li>
    </ul>
  </template>
</TwoColSlide>

<!--
Here's the real cost of the two approaches. A narrative summary is fast, easy to produce, easy to read — and easy to misinterpret. It loses source attribution. It loses publication dates and page references. And it embeds the first agent's paraphrase bias, which the downstream agent has no way to detect. A structured payload takes more design effort, but it preserves every piece of provenance. Claim text is verbatim. All metadata is intact. Downstream agents can evaluate freshness, credibility, and relevance independently. And the audit trail survives end-to-end. The rule: use structured payloads for any workflow where attribution, accuracy, or compliance matters. Summaries are only acceptable when downstream does not need to attribute, cite, or verify anything.
-->

---

<StepSequence
  eyebrow="Three injection patterns"
  title="How to Inject Context Into the Next Agent"
  :steps="injectionSteps"
  footerLabel="Match channel to lifecycle"
  :footerNum="6"
  :footerTotal="8"
/>

<!--
Three ways to inject context, and choosing the right one matters. Pattern one: system prompt injection. Put stable, reusable context there — the agent's role, domain rules, output schema. Things that don't change per request. Pattern two: first user message injection. Put per-request context there — the structured claim payload, the task state, prior agent output. This is the most common channel for multi-agent handoff. Pattern three: tool result injection. Dynamic context fetched mid-task — retrieved documents, database lookups — arrives through the tool-result loop and is appended to conversation history. The rule: context known before the call goes in system prompt or first user message. Context that depends on tool execution arrives via tool results. Never conflate the two — mixing them causes the agent to lose track of which context is stable and which is derived.
-->

---

<Frame>
  <Eyebrow>⚡ Exam tip</Eyebrow>
  <SlideTitle>Context Passing in Multi-Agent Pipelines</SlideTitle>
  <div style="margin-top: 40px; display: grid; grid-template-columns: 1fr 1fr; gap: 32px; flex: 1; min-height: 0;">
    <CalloutBox variant="dont" title="The trap">
      <p>A research agent passes a narrative summary to a synthesis agent. The synthesis agent then produces a report with source citations.</p>
      <p>Where do the citations come from? They can't come from the summary — attribution was discarded upstream. The synthesis agent will <strong>fabricate</strong> them.</p>
    </CalloutBox>
    <CalloutBox variant="do" title="Right answer">
      <p>Attribution metadata — source URL, document name, page number, publication date — <strong>must</strong> be in the structured payload.</p>
      <p>Summaries are only acceptable when the downstream agent does not need to attribute, cite, or verify.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Domain 1 · Multi-agent traps" :num="7" :total="8" />
</Frame>

<!--
The exam-tested trap. Scenario: a research agent extracts claims, summarizes them, and hands off to a synthesis agent that produces a report with citations. Question: what's the most likely failure mode? Wrong answers describe tone problems or prompt-engineering issues. The right answer: the synthesis agent will fabricate citations. The summary discarded attribution metadata upstream, so when the synthesis agent is asked to cite sources, it has no choice but to invent plausible-looking ones. This is a pipeline-design failure, not a prompt problem — and no amount of prompt engineering in the synthesis agent will fix it. The fix is structural: push attribution metadata into the handoff payload. Summaries are acceptable only when the downstream agent doesn't need to attribute or verify anything — and in multi-agent research, that's almost never the case.
-->

---

<BulletReveal
  eyebrow="Takeaways"
  title="Explicit Context Passing — What to Remember"
  :bullets="takeaways"
  :footerNum="8"
  :footerTotal="8"
/>

<!--
Six things to carry forward. One — each agent has only what you give it; there's no ambient shared memory in a multi-agent system. Two — always pass structured payloads, never narrative summaries, when attribution or accuracy matters. Three — the full claim payload has five fields: verbatim text, source URL, document name, page or section, publication date, and confidence. Four — never paraphrase when passing claims; verbatim preserves precision. Five — match the injection channel to the context's lifecycle: known before the call goes in system prompt or first user message; dynamic context comes through tool results. And six — summaries that discard provenance cause downstream to fabricate citations, which is a pipeline-design failure, not a prompt problem. In Lecture 3.10 we shift from "what to pass" to "what to enforce": programmatic guarantees versus prompt-based guidance.
-->
