---
theme: default
title: "Lecture 3.5: The Coordinator's Role: Decompose, Delegate, Aggregate"
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
const delegateSteps = [
  { number: 'Rule 1', title: 'Subagents start with fresh context', body: "The coordinator's conversation history is NOT passed down. Everything the subagent needs must be in the task prompt." },
  { number: 'Rule 2', title: 'Task prompt must include everything', body: 'Objective, relevant background, output format, constraints. If synthesis needs research facts, the coordinator injects them explicitly.' },
  { number: 'Rule 3', title: 'Least-privilege tools', body: 'Only give each subagent the tools it needs. Constrained tools = predictable, auditable behavior.' },
]

const aggregateSteps = [
  { number: 'Happy path', title: 'All subagents return results', body: 'Coordinator synthesizes — combine, deduplicate, format into a single coherent output.' },
  { number: 'Partial failure', title: 'One subagent fails or returns no result', body: 'Coordinator decides: retry, proceed without, or surface the failure to the caller.' },
  { number: 'Total failure', title: 'A critical subagent fails', body: 'Coordinator surfaces clearly — NOT a silently incomplete result.' },
]

const takeawayBullets = [
  { label: 'Orchestrator, never operator', detail: 'Coordinator orchestrates — it never executes domain tasks directly.' },
  { label: 'Decompose cleanly', detail: 'Bounded subtasks with clear output contracts and no implicit dependencies.' },
  { label: 'Delegate explicitly', detail: 'Subagents start fresh — everything they need lives in the task prompt.' },
  { label: 'Aggregate every outcome', detail: 'Handle success, partial failure, and total failure — never drop silently.' },
  { label: 'Dynamic selection', detail: 'Choose the right specialized subagent based on the nature of the subtask.' },
  { label: 'Single point of error handling', detail: 'Coordinator owns error handling for all subagent outputs.' },
]

const examBad = `Two traps the exam plants

Trap 1 — Coordinator doing domain work
  'Coordinator browses the web and writes the final report.'
  Coordinators orchestrate; they do not operate.

Trap 2 — Implicit context propagation
  'Subagent picks up where the coordinator left off.'
  There is no implicit channel — subagents start fresh.`

const examGood = `Remember

Coordinator = Decompose, Delegate (with explicit context),
              Aggregate (with error handling).

Dynamic subagent selection means the coordinator
chooses the right specialized agent based on the
nature of the subtask.`
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
      <div style="font-family: var(--font-body); font-size:26px; font-weight:600; letter-spacing:0.16em; text-transform:uppercase; color: var(--sprout-500); margin-bottom:40px;">Domain 1 &middot; Lecture 3.5</div>
      <h1 style="font-family: var(--font-display); font-weight:500; font-size:128px; line-height:1.02; letter-spacing:-0.025em; color: var(--paper-0); margin:0; max-width:1500px;">
        The Coordinator's Role
      </h1>
      <div style="font-family: var(--font-display); font-size:44px; color: var(--mint-200); margin-top:40px; font-weight:400; max-width:1200px; line-height:1.3;">
        Decompose. Delegate. Aggregate.
      </div>
    </div>
    <div style="display:flex; align-items:center; gap:48px; font-family: var(--font-body); font-size:26px; color: var(--mint-200); letter-spacing:0.06em;">
      <span>Lecture 3.5</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>~8 min</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>8 slides</span>
    </div>
  </div>
</Frame>

<!--
In 3.4 we sketched the hub-and-spoke topology. Now we zoom into the hub itself — the coordinator. This lecture walks through its three jobs in detail: how to decompose a task well, how to delegate with explicit context, and how to aggregate results across every possible outcome. Get this right and your multi-agent system is debuggable and predictable. Get it wrong and it silently returns partial nonsense.
-->

---

<!-- SLIDE 2 — Coordinator is the brain -->

<TwoColSlide
  variant="compare"
  title="The Coordinator Is the Brain"
  leftLabel="Does"
  rightLabel="Does NOT do"
  footerLabel="Lecture 3.5"
  :footerNum="2"
  :footerTotal="8"
>
<template #left>

- Receives the original user task.
- Decides how to split it into subtasks.
- Selects which subagents handle which parts.
- Passes the right context to each subagent.
- Collects and synthesizes results.

</template>
<template #right>

- Browse the web.
- Analyze documents directly.
- Execute code.
- Write the final research report.

*These are subagent responsibilities.*

**Exam implication:** if an answer has the coordinator directly executing domain tasks instead of delegating, it's wrong.

</template>
</TwoColSlide>

<!--
The coordinator is the brain of a multi-agent system. It does five things: receives the original user task, decides how to split it into subtasks, selects which subagents handle which parts, passes the right context to each subagent, and collects and synthesizes results. It does NOT do the actual domain work — it doesn't browse the web, analyze documents directly, execute code, or write the final research report. Those are subagent responsibilities. The exam implication is direct: if an answer choice has the coordinator executing domain tasks instead of delegating, it's wrong. The coordinator orchestrates — it never operates.
-->

---

<!-- SLIDE 3 — Decompose -->

<TwoColSlide
  variant="antipattern-fix"
  title="Decompose — Breaking the Task Well"
  leftLabel="❌ Poor decomposition"
  rightLabel="✓ Good decomposition"
  footerLabel="Lecture 3.5"
  :footerNum="3"
  :footerTotal="8"
>
<template #left>

- "Research agent" does research **AND** writes the summary.
- Subtasks have unclear boundaries.
- Subagent A's output format is assumed by subagent B.
- One subagent is responsible for too much.

</template>
<template #right>

- Each subagent has one clearly defined job.
- Independent tasks can run in parallel.
- Dependent tasks are chained explicitly.
- Each subtask has a clear output contract.

*Dynamic selection:* coordinator chooses the right specialized subagent based on the subtask — requires reasoning about capabilities.

</template>
</TwoColSlide>

<!--
Decompose is the first job and the easiest to get wrong. Poor decomposition bundles responsibilities — a research agent that does research AND writes the summary, subtasks with unclear boundaries, or one subagent implicitly depending on another's output format. Good decomposition gives each subagent one clearly defined job, lets independent tasks run in parallel, chains dependent tasks explicitly, and gives each subtask a clear output contract. And the coordinator doesn't have a fixed map of subtask-to-subagent. Dynamic selection means the coordinator chooses the right specialized subagent based on the nature of the subtask — which requires it to reason about capabilities.
-->

---

<!-- SLIDE 4 — Delegate -->

<StepSequence
  eyebrow="Delegation"
  title="Delegate — Explicit Context Passing"
  :steps="delegateSteps"
  footerLabel="Lecture 3.5"
  :footerNum="4"
  :footerTotal="8"
/>

<!--
Delegate is the second job. Three rules. Rule one: subagents start with fresh context. The coordinator's history is NOT passed down. Everything the subagent needs must be in the task prompt. Rule two: the task prompt must include everything — objective, relevant background, output format, constraints. If the synthesis subagent needs facts from the research pipeline, the coordinator injects them explicitly. Rule three: least-privilege tools. Only give each subagent the tools it needs. Document analysis doesn't need web search. Constrained tools make for predictable, auditable behavior. The failure mode here is assuming the subagent "knows what you mean" — it doesn't. Make every assumption explicit.
-->

---

<!-- SLIDE 5 — Aggregate -->

<StepSequence
  eyebrow="Aggregation"
  title="Aggregate — Collecting and Synthesizing Results"
  :steps="aggregateSteps"
  footerLabel="Lecture 3.5"
  :footerNum="5"
  :footerTotal="8"
/>

<!--
Aggregate is the third job, and the one candidates underweight. Three outcomes to handle. Happy path: all subagents return results. Coordinator synthesizes — combine, deduplicate, format. Partial failure: one subagent fails or returns no result. The coordinator decides whether to retry, proceed without, or surface to the caller. Total failure: a critical subagent fails. The coordinator surfaces clearly — not a silently incomplete result. The aggregation rule is simple: the coordinator is the single point of error handling for all subagent outputs. Errors are caught here — not silently dropped.
-->

---

<!-- SLIDE 6 — Full lifecycle -->

<TwoColSlide
  variant="compare"
  title="The Full Coordinator Lifecycle"
  leftLabel="Flow"
  rightLabel="Per step"
  footerLabel="Lecture 3.5"
  :footerNum="6"
  :footerTotal="8"
>
<template #left>

```
Receive user task
  → Decompose into subtasks
    → Select subagents dynamically
      → Spawn via Task tool
        (explicit context)
          → Receive subagent results
            → Aggregate
              → Return final output
```

</template>
<template #right>

- **Decompose** — each subtask has one owner, clear scope, explicit output contract.
- **Select** — choose the right specialized subagent; not all tasks need the same agent.
- **Spawn** — pass exactly what's needed, no more, no less.
- **Aggregate** — handle errors, synthesize outputs, return a coherent result.

</template>
</TwoColSlide>

<!--
Put it all together and the coordinator has a clean lifecycle: receive the user task, decompose it into subtasks, select subagents dynamically, spawn them via the Task tool with explicit context, receive results, aggregate, and return the final output. At each step: decompose gives each subtask one owner and a clear output contract. Select means choosing the right specialized subagent for the subtask — not all tasks need the same agent. Spawn passes exactly what's needed, no more and no less. Aggregate handles errors, synthesizes outputs, and returns a coherent result.
-->

---

<!-- SLIDE 7 — Exam Tip -->

<AntiPatternSlide
  eyebrow="⚡ Exam Tip"
  title="Coordinator Responsibility Boundaries"
  lang="text"
  :badExample="examBad"
  whyItFails="Coordinators only decompose, delegate, and aggregate. And subagents have no shared memory — everything must be passed explicitly."
  :fixExample="examGood"
  footerLabel="Lecture 3.5"
  :footerNum="7"
  :footerTotal="8"
/>

<!--
Two traps the exam loves to plant in coordinator questions. Trap one: the coordinator doing domain work — browsing the web, writing the report directly. Coordinators orchestrate; they do not operate. Trap two: implicit context propagation — an answer that suggests the subagent "picks up where the coordinator left off" without explicit passing. That's not how isolation works. Remember: coordinator equals decompose, delegate with explicit context, and aggregate with error handling. And dynamic subagent selection means the coordinator chooses the right agent based on the nature of the subtask.
-->

---

<!-- SLIDE 8 — Takeaways -->

<BulletReveal
  eyebrow="Takeaway"
  title="The Coordinator's Role"
  :bullets="takeawayBullets"
  footerLabel="Lecture 3.5"
  :footerNum="8"
  :footerTotal="8"
/>

<!--
Six things to carry forward. Coordinator orchestrates — it never executes domain tasks directly. Decompose into bounded subtasks with clear output contracts and no implicit dependencies. Delegate with explicit context passing — subagents start fresh and everything lives in the prompt. Aggregate handles every outcome: success, partial failure, total failure. Dynamic subagent selection means choosing the right specialized agent based on the nature of the subtask. And the coordinator is the single point of error handling for all subagent outputs.
-->
