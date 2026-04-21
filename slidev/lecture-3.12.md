---
theme: default
title: "Lecture 3.12: Task Decomposition — Prompt Chaining vs Dynamic Adaptive"
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
const chainBullets = [
  'Steps defined upfront in code',
  "Each step receives the prior step's output",
  'Sequence never changes — same order every time',
  'Easy to reason about, test, and debug',
  'Output quality of each step is independently verifiable',
]
const adaptiveBullets = [
  'Claude decides what to do next based on results',
  'Step sequence emerges from the task, not from code',
  'Handles novel paths and unexpected findings',
  'More powerful — harder to predict and test',
  'Requires safeguards: loop limits, timeout, human checkpoints',
]

const chooseSteps = [
  { title: 'Prompt chaining — use when', body: 'Steps are known, sequence is fixed, correctness at each step is independently verifiable. Code review, report generation, data-transformation pipelines.' },
  { title: 'Dynamic adaptive — use when', body: 'Task is open-ended, the relevant path depends on findings, and the task space is too large to enumerate upfront. Debugging, research, investigation.' },
  { title: 'Hybrid — use when', body: 'Outer structure is known (phases) but each phase is open-ended. Phase 1 = gather evidence (dynamic). Phase 2 = write report (chained).' },
]

const takeaways = [
  { label: 'Prompt chaining = fixed sequence in code', detail: 'Predictable, testable, each step is independently verifiable.' },
  { label: 'Dynamic adaptive = model-driven', detail: 'Claude decides the next step based on results; requires explicit safety limits.' },
  { label: 'Code review is always prompt chaining', detail: 'Per-file → cross-file integration → report. Fixed steps, never dynamic.' },
  { label: 'Dynamic adaptive requires a max_steps cap', detail: 'Without it, unexpected data can cause unbounded loops in production.' },
  { label: 'Default to chaining when steps are known', detail: 'Only use dynamic adaptive when the path genuinely depends on runtime findings.' },
  { label: 'Hybrid is valid', detail: 'Fixed phase boundaries with dynamic execution inside each phase is a common production pattern.' },
]

const chainCode = `def run_code_review_pipeline(repo_path: str, changed_files: list[str]) -> dict:
    """Fixed sequential pipeline. Same three steps every time."""

    # Step 1 — per-file analysis (can be parallel internally, still fixed stage)
    per_file_findings = [
        analyze_single_file(path) for path in changed_files
    ]

    # Step 2 — integration pass across all files
    integration_findings = analyze_integration(per_file_findings)

    # Step 3 — synthesize the final report
    report = synthesize_report(per_file_findings, integration_findings)

    return report`

const adaptiveCode = `def run_investigation(initial_prompt: str, max_steps: int = 20) -> dict:
    """Dynamic adaptive — Claude decides the next step each turn."""

    messages = [{"role": "user", "content": initial_prompt}]
    step_count = 0

    while step_count < max_steps:
        response = client.messages.create(
            model="claude-opus-4-7",
            tools=investigation_tools,
            messages=messages,
        )

        if response.stop_reason == "end_turn":
            return {"status": "complete", "result": response.content}

        if response.stop_reason == "tool_use":
            tool_results = execute_tools(response.content)
            messages.append({"role": "assistant", "content": response.content})
            messages.append({"role": "user", "content": tool_results})

        step_count += 1

    # Safety valve — never ship dynamic adaptive without this.
    return summarize_partial_findings(messages)`
</script>

<Frame bg="var(--forest-900)" color="var(--mint-100)" :pad="false">
  <div style="position:absolute; inset:0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%);"></div>
  <div style="position:relative; z-index:1; padding:110px 120px 96px; width:100%; height:100%; display:flex; flex-direction:column; justify-content:space-between;">
    <div style="display:flex; align-items:center; gap:24px;">
      <img src="/assets/logo-mark.png" alt="" style="width:72px; height:auto;" />
      <div style="font-family: var(--font-body); font-size:26px; font-weight:500; letter-spacing:0.14em; text-transform:uppercase; color: var(--mint-200);">Dyer Innovation</div>
    </div>
    <div>
      <div style="font-family: var(--font-body); font-size:26px; font-weight:600; letter-spacing:0.16em; text-transform:uppercase; color: var(--sprout-500); margin-bottom:40px;">Lecture 3.12 &middot; Domain 1</div>
      <h1 style="font-family: var(--font-display); font-weight:500; font-size:128px; line-height:1.02; letter-spacing:-0.025em; color: var(--paper-0); margin:0; max-width:1600px;">Task <span style="color: var(--sprout-500);">Decomposition</span></h1>
      <div style="font-family: var(--font-display); font-size:44px; color: var(--mint-200); margin-top:40px; font-weight:400; max-width:1300px; line-height:1.3;">Prompt chaining vs dynamic adaptive.</div>
    </div>
    <div style="display:flex; align-items:center; gap:48px; font-family: var(--font-body); font-size:26px; color: var(--mint-200); letter-spacing:0.06em;">
      <span>Domain 1 · 27%</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>Scenario 2 — Code Review Pipeline</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>Path C</span>
    </div>
  </div>
</Frame>

<!--
Welcome to Lecture 3.12 — Task Decomposition: Prompt Chaining vs Dynamic Adaptive. Every non-trivial agentic workflow is decomposed into sub-tasks. The exam-tested question is what KIND of decomposition to use. There are two main patterns — prompt chaining, where you define the steps upfront in code, and dynamic adaptive, where Claude decides the next step at runtime. This lecture gives you the decision rule and the safeguards each pattern needs to be production-safe.
-->

---

<ConceptHero
  eyebrow="Why decompose"
  concept="One question, many focused calls"
  supportLine="Single calls have context and attention limits. Focused prompts produce higher-quality outputs. Sub-tasks can be verified independently. Parallel execution is possible when steps are independent."
  footerLabel="Design question: fixed sequence → Prompt Chaining. Each step determines the next → Dynamic Adaptive."
  :footerNum="2"
  :footerTotal="8"
/>

<!--
Why decompose at all? Four reasons. First, single calls have context and attention limits — cramming an entire pipeline into one prompt degrades quality. Second, focused prompts produce higher-quality outputs than kitchen-sink prompts. Third, sub-tasks can be verified independently — you can test each step in isolation. And fourth, when sub-tasks are independent, you can execute them in parallel, which we covered in Lecture 3.8. Once you've decided to decompose, the design question is: is the sequence fixed in advance, or does each step determine the next? Fixed → prompt chaining. Each step determines the next → dynamic adaptive. That single question drives the rest of this lecture.
-->

---

<TwoColSlide
  variant="compare"
  title="Prompt Chaining vs Dynamic Adaptive"
  eyebrow="Two decomposition patterns"
  leftLabel="Prompt Chaining (Fixed Sequential)"
  rightLabel="Dynamic Adaptive"
  :footerNum="3"
  :footerTotal="8"
>
  <template #left>
    <ul>
      <li v-for="(b, i) in chainBullets" :key="i">{{ b }}</li>
    </ul>
  </template>
  <template #right>
    <ul>
      <li v-for="(b, i) in adaptiveBullets" :key="i">{{ b }}</li>
    </ul>
  </template>
</TwoColSlide>

<!--
The two patterns side-by-side. Prompt chaining is fixed sequential — you define the steps in code, each step receives the prior step's output, the sequence never changes. It's easy to reason about, test, debug, and audit. Each step's output quality is independently verifiable. Dynamic adaptive is model-driven — Claude decides what to do next based on results, so the step sequence emerges from the task rather than from your code. It's more powerful for open-ended problems, it handles novel paths and unexpected findings, and it's harder to predict, test, and bound. It also requires safeguards: loop limits, timeouts, human checkpoints. The best fit for chaining: predictable workflows like code review, report generation, and structured analysis. The best fit for dynamic: open-ended investigation, debugging, research where the path depends on what you find.
-->

---

<CodeBlockSlide
  eyebrow="Example"
  title="Prompt Chaining — Code Review Pipeline"
  lang="python"
  :code="chainCode"
  annotation="The engineer determines the sequence, not Claude. Step 2 always follows Step 1. Testable, repeatable, auditable."
  :footerNum="4"
  :footerTotal="8"
/>

<!--
Here's prompt chaining in practice — the canonical code review pipeline. Step one: per-file analysis runs over every changed file. Step two: an integration pass looks across all the per-file findings for cross-file issues. Step three: synthesize the final report from both the per-file and integration findings. Three fixed steps. Step two always follows step one. Step three always follows step two. The sequence is determined by the engineer who wrote the pipeline, not by Claude at runtime. That's what makes this pattern testable, repeatable, and auditable — you can regression-test each stage independently, and the output of one run looks structurally identical to the next. Code review is the classic exam answer here: it's always prompt chaining, and the exam tests whether you know that.
-->

---

<CodeBlockSlide
  eyebrow="Example"
  title="Dynamic Adaptive — Open-Ended Investigation"
  lang="python"
  :code="adaptiveCode"
  annotation="max_steps is REQUIRED for dynamic adaptive. Without it, unexpected data could trigger infinite loops in production."
  :footerNum="5"
  :footerTotal="8"
/>

<!--
And here's dynamic adaptive — an investigation loop. The sequence is not defined in advance. On each turn, Claude decides whether to call a tool or stop. If stop_reason is end_turn, the investigation is complete. If stop_reason is tool_use, execute the tool, append the result to the conversation, and let Claude decide the next step. This is the right pattern for debugging a production incident where you don't know which logs to grep first, or for research where each document you read reshapes what you want to investigate next. Critical detail: the while-loop is bounded by max_steps. This safety valve is not optional. Without it, unexpected inputs — a page that keeps linking back to new pages, a log that keeps failing to parse — can trigger unbounded loops in production. If the loop hits the cap, we don't just error out; we summarize the partial findings so nothing learned is lost.
-->

---

<StepSequence
  eyebrow="Choose strategy"
  title="Choosing the Right Decomposition Strategy"
  :steps="chooseSteps"
  footerLabel="Default to chaining unless the task requires dynamic"
  :footerNum="6"
  :footerTotal="8"
/>

<!--
Three scenarios and the right pattern for each. Prompt chaining — use when the steps are known, the sequence is fixed, and correctness at each step is independently verifiable. Code review. Report generation. Data-transformation pipelines. Dynamic adaptive — use when the task is open-ended, the relevant path depends on what you find, and the task space is too large to enumerate upfront. Debugging. Research. Investigation. Hybrid — use when the outer structure is known but each phase is open-ended. For example: phase one is gather evidence, and inside that phase Claude adapts. Phase two is write the report, and that phase is chained. Default posture: start with prompt chaining whenever you can define the steps. Only reach for dynamic adaptive when the task genuinely requires it — because dynamic pipelines are harder to test, audit, and bound.
-->

---

<Frame>
  <Eyebrow>⚡ Exam tip</Eyebrow>
  <SlideTitle>Recognising the Right Decomposition Strategy</SlideTitle>
  <div style="margin-top: 40px; display: grid; grid-template-columns: 1fr 1fr; gap: 32px; flex: 1; min-height: 0;">
    <CalloutBox variant="dont" title="Common trap">
      <p>Choosing dynamic adaptive for a code-review pipeline because "Claude should be flexible."</p>
      <p>Code review has well-defined steps: per-file → cross-file → report. Fixed chaining is correct. Dynamic only adds complexity without benefit.</p>
    </CalloutBox>
    <CalloutBox variant="do" title="Decision rule">
      <p>Can you enumerate the steps before the task starts? <strong>Yes → prompt chaining. No → dynamic adaptive.</strong></p>
      <p>In both cases: define safety limits — max_steps, timeout, human checkpoints.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Domain 1 · Decomposition" :num="7" :total="8" />
</Frame>

<!--
The exam trap. A question describes a code-review pipeline, and one of the distractor answers is "use dynamic adaptive so Claude can be flexible." Tempting, but wrong. Code review has well-defined steps — per-file analysis, then cross-file integration, then report synthesis. The sequence never changes. Fixed chaining is correct because it's testable, bounded, and predictable. Dynamic adaptive in this scenario adds complexity with no benefit — you'd have to pay for safety rails that aren't solving a real problem. Decision rule: can you enumerate the steps before the task starts? Yes → prompt chaining. No → dynamic adaptive. And in both cases, define safety limits — max_steps, timeout, human checkpoints for high-risk actions. That rule answers almost every decomposition question on the exam.
-->

---

<BulletReveal
  eyebrow="Takeaways"
  title="Task Decomposition — What to Remember"
  :bullets="takeaways"
  :footerNum="8"
  :footerTotal="8"
/>

<!--
Six takeaways. One — prompt chaining is a fixed sequence in code: predictable, testable, independently verifiable. Two — dynamic adaptive is model-driven: Claude decides the next step at runtime, and it requires explicit safety limits. Three — code review is always prompt chaining: per-file, then cross-file integration, then report. Never dynamic. Four — dynamic adaptive requires a max_steps cap; without it, unexpected data can cause unbounded loops. Five — default to chaining when steps are known; reach for dynamic only when the path genuinely depends on runtime findings. And six — hybrid is a valid production pattern: fixed phase boundaries with dynamic execution inside each phase. In Lecture 3.13 we look at session management — how to resume, fork, or start fresh when a workflow spans multiple sessions.
-->
