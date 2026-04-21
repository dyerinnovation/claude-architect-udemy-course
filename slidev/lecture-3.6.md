---
theme: default
title: "Lecture 3.6: Subagent Context Isolation"
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
const reqSteps = [
  { number: 'What to pass', title: 'Everything relevant, explicitly', body: 'Original user objective, background facts/data, output format, constraints, and results from prior subagents that this subagent needs.' },
  { number: 'What fails without it', title: 'Incomplete or redundant work', body: "Subagent produces output that doesn't fit the broader task — or re-collects information via tools, wasting resources." },
  { number: 'What to NOT pass', title: 'The full history', body: "Don't dump the entire coordinator history. Pass only what's relevant — irrelevant context increases cost and confuses the subagent." },
]

const persistenceSteps = [
  { number: 'Implication 1', title: 'Two calls = two instances', body: 'Call Task twice with the same subagent description → two independent instances. The second has no memory of the first.' },
  { number: 'Implication 2', title: 'Retry reconstructs context', body: 'Retry logic must rebuild the full task context. You cannot resume a failed subagent — spawn fresh with the same (or corrected) prompt.' },
  { number: 'Implication 3', title: 'Coordinator is the only persistent entity', body: 'It accumulates results across subagent calls and maintains workflow state.' },
]

const takeawayBullets = [
  { label: 'No inherited history', detail: "Subagents do NOT inherit the coordinator's history — each starts with a blank context." },
  { label: 'Independent per call', detail: 'Each Task call creates an independent instance — no session persistence.' },
  { label: 'Explicit passing is mandatory', detail: 'Everything the subagent needs must live in the task prompt.' },
  { label: 'Relevant context only', detail: 'Dumping full history is inefficient and counterproductive — pass only what matters.' },
  { label: 'Coordinator is persistent', detail: 'The coordinator accumulates results and maintains workflow state.' },
  { label: 'Isolation shifts complexity', detail: "Benefits: parallelism, predictability, security. Cost: coordinator's prompt construction logic." },
]

const examBad = `Two traps the exam plants

Trap 1 — Implicit user-request access
  Answer assumes the subagent 'already knows' the user's
  original request because the coordinator received it.

Trap 2 — Cross-call memory
  Answer describes the subagent being 'updated' or
  'continuing' from a prior call. No — there is no
  memory between Task calls.`

const examGood = `Rule

Subagents start with a blank slate.
The coordinator is the sole source of context
for each subagent invocation.
EVERYTHING must be passed explicitly.`

const codePattern = `# Coordinator has rich context accumulated across the run:
#   - original user objective
#   - facts from the Research subagent
#   - notes from the Document subagent
# None of that flows to the next subagent automatically.

synthesis_task_prompt = f"""
You are the Synthesis subagent. Produce a concise brief.

## Objective (from the original user request)
{original_user_objective}

## Facts gathered by Research
{research_facts}

## Notes from Document Analysis
{document_notes}

## Output format
- Three-paragraph brief
- Cite sources inline
""".strip()

task_call = {
    "name": "Task",
    "input": {
        "description": "Synthesize research + doc analysis into a brief",
        "prompt": synthesis_task_prompt,
        "allowedTools": ["Task"]     # no external tools needed
    }
}`
</script>

<!-- SLIDE 1 — Cover -->

<Frame bg="var(--forest-900)" color="var(--mint-100)" :pad="false">
  <div style="position:absolute; inset:0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%);" />
  <div style="position:relative; z-index:1; padding:110px 120px 96px; width:100%; height:100%; display:flex; flex-direction:column; justify-content:space-between;">
    <div style="display:flex; align-items:center; gap:24px;">
      <img src="/assets/logo-mark.png" alt="" style="width:72px; height:auto;" />
      <div style="font-family: var(--font-body); font-size:26px; font-weight:500; letter-spacing:0.14em; text-transform:uppercase; color: var(--mint-200);">Dyer Innovation</div>
    </div>
    <div>
      <div style="font-family: var(--font-body); font-size:26px; font-weight:600; letter-spacing:0.16em; text-transform:uppercase; color: var(--sprout-500); margin-bottom:40px;">Domain 1 &middot; Lecture 3.6</div>
      <h1 style="font-family: var(--font-display); font-weight:500; font-size:128px; line-height:1.02; letter-spacing:-0.025em; color: var(--paper-0); margin:0; max-width:1500px;">
        Subagent <span style="color: var(--sprout-500);">Context Isolation</span>
      </h1>
      <div style="font-family: var(--font-display); font-size:44px; color: var(--mint-200); margin-top:40px; font-weight:400; max-width:1200px; line-height:1.3;">
        Each subagent starts with a blank slate. Make every assumption explicit.
      </div>
    </div>
    <div style="display:flex; align-items:center; gap:48px; font-family: var(--font-body); font-size:26px; color: var(--mint-200); letter-spacing:0.06em;">
      <span>Lecture 3.6</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>~8 min</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>8 slides</span>
    </div>
  </div>
</Frame>

<!--
In 3.4 and 3.5 we saw that subagents don't inherit the coordinator's history. This lecture goes deep on that rule — what isolation actually means, what the subagent does and doesn't have, and the design implications. Context isolation is the mechanism that makes multi-agent systems work. If you don't understand it, you'll pick distractors that assume implicit propagation.
-->

---

<!-- SLIDE 2 — What context isolation means -->

<TwoColSlide
  variant="compare"
  title="What Context Isolation Actually Means"
  leftLabel="Does NOT have"
  rightLabel="DOES have"
  footerLabel="Lecture 3.6"
  :footerNum="2"
  :footerTotal="8"
>
<template #left>

- Coordinator's conversation history.
- Results from other subagents.
- The original user request (unless passed).
- Any context from previous turns.

</template>
<template #right>

- Its own system prompt (if provided).
- The task prompt the coordinator constructed.
- The tools in its `allowedTools` list.
- **Only** what the coordinator explicitly passed.

*Design principle:* predictability + security. A subagent that can't accidentally SEE unrelated data can't accidentally ACT on it.

</template>
</TwoColSlide>

<!--
Let's be precise. The subagent does NOT have: the coordinator's conversation history, results from other subagents, the original user request unless it's passed, or any context from previous turns. The subagent DOES have: its own system prompt if one is provided, the task prompt the coordinator constructed, the tools in its allowedTools list, and only what the coordinator explicitly passed. The design principle is predictability plus security. A subagent that can't accidentally SEE unrelated data can't accidentally ACT on it.
-->

---

<!-- SLIDE 3 — Code pattern: explicit injection -->

<CodeBlockSlide
  eyebrow="Code pattern"
  title="Context Isolation in Code — What the Subagent Receives"
  lang="python"
  :code="codePattern"
  annotation="Every fact the subagent needs must be serialized into the task prompt by the coordinator."
  footerLabel="Lecture 3.6"
  :footerNum="3"
  :footerTotal="8"
/>

<!--
Here's what this actually looks like in code. The coordinator has rich context: original user objective, facts from the research subagent, notes from the document subagent. None of that flows automatically. The coordinator has to serialize everything the synthesis subagent needs into the task prompt — objective, facts, notes, output format. Then the Task call goes out. The subagent sees only that prompt. Every fact it needs must be injected by the coordinator. That's the contract.
-->

---

<!-- SLIDE 4 — The explicit passing requirement -->

<StepSequence
  eyebrow="Explicit context passing"
  title="The Requirement"
  :steps="reqSteps"
  footerLabel="Lecture 3.6"
  :footerNum="4"
  :footerTotal="8"
/>

<!--
Three rules about what to pass. What to pass: original user objective, background facts or data, output format, constraints, and results from prior subagents that this subagent needs. What fails without it: the subagent produces output that doesn't fit the broader task, or it re-collects information via tools — wasting resources and time. What to NOT pass: don't dump the entire coordinator history. Pass only what's relevant. Irrelevant context increases cost and confuses the subagent.
-->

---

<!-- SLIDE 5 — Benefits and challenges -->

<TwoColSlide
  variant="compare"
  title="Isolation — Benefits and Challenges"
  leftLabel="Benefits"
  rightLabel="Challenges"
  footerLabel="Lecture 3.6"
  :footerNum="5"
  :footerTotal="8"
>
<template #left>

- **Predictability** — behavior depends only on what you gave it.
- **Security** — sensitive data doesn't leak between subagents.
- **Parallelism** — isolated subagents safely run concurrently.
- **Testability** — test each subagent with known inputs.

</template>
<template #right>

- **Context engineering burden** — coordinator must construct complete, accurate prompts.
- **Serialization overhead** — large data structures formatted for prompts.
- **No shared state** — all results flow through the coordinator.

*Design implication:* isolation shifts complexity to the coordinator's prompt construction logic.

</template>
</TwoColSlide>

<!--
Isolation has clear benefits and real costs. Benefits: predictability — behavior depends only on what you gave the subagent. Security — sensitive data doesn't leak between subagents. Parallelism — isolated subagents safely run concurrently. Testability — you can test each subagent with known inputs. Challenges: context engineering burden — the coordinator must construct complete, accurate prompts. Serialization overhead — large data structures have to be formatted for prompts. No shared state — all results flow through the coordinator. The design implication is that isolation shifts complexity to the coordinator's prompt construction logic. That's the tradeoff.
-->

---

<!-- SLIDE 6 — No persistence across calls -->

<StepSequence
  eyebrow="No persistence"
  title="Each Task Call Creates an Independent Instance"
  :steps="persistenceSteps"
  footerLabel="Lecture 3.6"
  :footerNum="6"
  :footerTotal="8"
/>

<!--
Three implications of "no session persistence." Implication one: call the Task tool twice with the same subagent description and you get two independent instances. The second has no memory of the first. Implication two: retry logic must reconstruct the full task context. You cannot resume a failed subagent — you spawn a fresh one with the same, or corrected, prompt. Implication three: the coordinator is the only persistent entity. It accumulates results across subagent calls and maintains workflow state. Mental model: subagents are functions. Call them with arguments. They return results. They don't remember between calls.
-->

---

<!-- SLIDE 7 — Exam Tip -->

<AntiPatternSlide
  eyebrow="⚡ Exam Tip"
  title="Context Isolation — The Exam Traps"
  lang="text"
  :badExample="examBad"
  whyItFails="Subagents start blank every time. The coordinator is the sole source of context."
  :fixExample="examGood"
  footerLabel="Lecture 3.6"
  :footerNum="7"
  :footerTotal="8"
/>

<!--
Two traps to recognize. Trap one: an answer that assumes the subagent "already knows" the user's original request because the coordinator received it. No — the subagent only knows what's in its task prompt. Trap two: an answer that describes the subagent being "updated" or "continuing" from a prior call. No — there's no memory between Task calls. The rule is short: subagents start with a blank slate. The coordinator is the sole source of context for each subagent invocation. Everything must be passed explicitly.
-->

---

<!-- SLIDE 8 — Takeaways -->

<BulletReveal
  eyebrow="Takeaway"
  title="Subagent Context Isolation"
  :bullets="takeawayBullets"
  footerLabel="Lecture 3.6"
  :footerNum="8"
  :footerTotal="8"
/>

<!--
Six things to carry forward. Subagents do NOT inherit the coordinator's history — each starts with a blank context. Each Task call creates an independent instance — no session persistence. Explicit context passing is mandatory — everything in the task prompt. Pass RELEVANT context only — dumping full history is inefficient and counterproductive. The coordinator is the only persistent entity — it accumulates results and maintains state. And isolation enables parallelism, predictability, and security — at the cost of shifting complexity to the coordinator's prompt construction logic.
-->
