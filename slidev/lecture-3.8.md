---
theme: default
title: "Lecture 3.8: Parallel Subagent Execution"
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
const compareLeft = [
  "Tasks do not depend on each other's output",
  'Web search + doc analysis + source verify — each proceeds independently',
  'No need to know what others found',
]
const compareRight = [
  "Task B requires Task A's output",
  'Synthesis cannot happen until research produces findings',
  'Dependent subagent must wait',
]
const seqLeft = [
  'One Task call per coordinator turn',
  'Coordinator waits for each result before proceeding',
  "Use when Task B depends on Task A's output",
  'Total time = sum of subagent times',
  'Example: Research → wait → Synthesis',
]
const parRight = [
  'Multiple Task calls in ONE coordinator turn',
  'All subagents run simultaneously',
  'Use when tasks are independent',
  'Total time ≈ slowest subagent',
  'Example: Web search + Doc analysis + Source verify',
]
const flowSteps = [
  { label: 'Coordinator', sublabel: 'issues 3 Task calls in one response' },
  { label: 'Subagents run', sublabel: 'Web search · Doc analysis · Source verify — all in parallel' },
  { label: 'user message', sublabel: '3 tool_results returned as a single batch' },
  { label: 'Coordinator', sublabel: 'aggregates results on the next turn' },
]
const takeaways = [
  { label: 'Parallel = multiple Task calls in ONE coordinator response turn', detail: 'Not across multiple turns. The structural signature is one response with many tool_use blocks.' },
  { label: 'Independent → parallel; data dependency → sequential', detail: "If Task B needs Task A's output, you cannot parallelise." },
  { label: 'All parallel results return as a SINGLE batch', detail: 'The next user message carries every tool_result before the coordinator continues.' },
  { label: 'Parallel time ≈ slowest subagent — not sum of all', detail: 'Latency is bounded by the slowest branch, not the total work done.' },
  { label: 'Handle partial failures explicitly as is_error:true tool_results', detail: 'The coordinator must reason about which branches succeeded and which did not.' },
  { label: 'Real pipelines mix both', detail: 'A parallel collection phase followed by a sequential synthesis phase is common.' },
]

const parallelCode = `# Coordinator's single response contains THREE Task tool_use blocks.
coordinator_response_content = [

    # 1 — web search subagent
    {
        "type": "tool_use",
        "id": "task_web_01",
        "name": "Task",
        "input": {
            "description": "Web research on topic X",
            "prompt": f"Research {topic}. Return structured findings.",
            "allowedTools": ["Task", "web_search", "read_url"]
        }
    },

    # 2 — document analysis subagent
    {
        "type": "tool_use",
        "id": "task_docs_01",
        "name": "Task",
        "input": {
            "description": "Analyze provided documents",
            "prompt": f"Analyze: {documents}. Extract key claims.",
            "allowedTools": ["Task", "read_file", "search_documents"]
        }
    },

    # 3 — source verification subagent
    {
        "type": "tool_use",
        "id": "task_verify_01",
        "name": "Task",
        "input": {
            "description": "Verify citations for the collected claims",
            "prompt": f"Verify each citation in: {claim_set}.",
            "allowedTools": ["Task", "read_url", "web_search"]
        }
    },
]
# All three Task calls in one response → parallel spawning.
# Coordinator waits for all three tool_results in the next user message.`
</script>

<Frame bg="var(--forest-900)" color="var(--mint-100)" :pad="false">
  <div style="position:absolute; inset:0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%);"></div>
  <div style="position:relative; z-index:1; padding:110px 120px 96px; width:100%; height:100%; display:flex; flex-direction:column; justify-content:space-between;">
    <div style="display:flex; align-items:center; gap:24px;">
      <img src="/assets/logo-mark.png" alt="" style="width:72px; height:auto;" />
      <div style="font-family: var(--font-body); font-size:26px; font-weight:500; letter-spacing:0.14em; text-transform:uppercase; color: var(--mint-200);">Dyer Innovation</div>
    </div>
    <div>
      <div style="font-family: var(--font-body); font-size:26px; font-weight:600; letter-spacing:0.16em; text-transform:uppercase; color: var(--sprout-500); margin-bottom:40px;">Lecture 3.8 &middot; Domain 1</div>
      <h1 style="font-family: var(--font-display); font-weight:500; font-size:128px; line-height:1.02; letter-spacing:-0.025em; color: var(--paper-0); margin:0; max-width:1600px;">Parallel <span style="color: var(--sprout-500);">Subagent</span> Execution</h1>
      <div style="font-family: var(--font-display); font-size:44px; color: var(--mint-200); margin-top:40px; font-weight:400; max-width:1300px; line-height:1.3;">Multiple Task calls in a single coordinator response turn.</div>
    </div>
    <div style="display:flex; align-items:center; gap:48px; font-family: var(--font-body); font-size:26px; color: var(--mint-200); letter-spacing:0.06em;">
      <span>Domain 1 · 27%</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>Scenario 3 — Multi-Agent Research</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>Hub-and-spoke</span>
    </div>
  </div>
</Frame>

<!--
Welcome to Lecture 3.8 — Parallel Subagent Execution. In the last lecture we looked at how the Task tool spawns subagents. In this one we zero in on what "parallel" actually means inside Claude's agentic loop, because the term gets misused more than almost any other in Domain 1. Parallel subagent execution has a very precise structural signature, and the exam will try to catch you on it. Let's get that signature nailed down.
-->

---

<ConceptHero
  eyebrow="Precise definition"
  concept="Parallel = one response, many Task calls"
  supportLine="Sequential: spawn subagent 1 → wait → spawn subagent 2 → wait. Parallel: all Task calls in the SAME response — coordinator collects every result in one batch before its next turn."
  footerLabel="Exam phrase: all parallel subagent spawning happens in one coordinator response turn"
  :footerNum="2"
  :footerTotal="8"
/>

<!--
Here is the precise definition. Parallel subagent execution means the coordinator emits multiple Task tool_use blocks in a SINGLE response. Not across two turns. Not in a loop. One response, many Task calls. Sequential, by contrast, is: spawn subagent one, wait for its result, then spawn subagent two, wait, and so on. That's the contrast the exam tests. The exam-key phrase to memorise: "all parallel subagent spawning happens in one coordinator response turn." If an answer describes spawning across multiple turns, it is describing sequential — regardless of how the word "parallel" appears in the text.
-->

---

<TwoColSlide
  variant="compare"
  title="Sequential vs Parallel — When to Use Each"
  eyebrow="Decision rule"
  leftLabel="Use parallel when"
  rightLabel="Use sequential when"
  :footerNum="3"
  :footerTotal="8"
>
  <template #left>
    <ul>
      <li v-for="(b, i) in compareLeft" :key="i">{{ b }}</li>
    </ul>
  </template>
  <template #right>
    <ul>
      <li v-for="(b, i) in compareRight" :key="i">{{ b }}</li>
    </ul>
  </template>
</TwoColSlide>

<!--
The decision rule is a single question: do the subagents depend on each other's output? If no, parallel is the right call — run them together and cut latency to the slowest branch. A classic parallel example: web search plus document analysis plus source verification. Each proceeds independently. If yes — task B genuinely needs task A's output — you must sequence them. Synthesis cannot happen until research has produced findings. The data dependency is the fork. Everything else is secondary.
-->

---

<CodeBlockSlide
  eyebrow="Code pattern"
  title="Parallel Spawning — Coordinator Response"
  lang="python"
  :code="parallelCode"
  annotation="All three Task calls in one response → parallel. Coordinator waits for all three tool_results as a single batch before its next turn."
  :footerNum="4"
  :footerTotal="8"
/>

<!--
Here's what parallel spawning looks like in code. The coordinator's response content array contains three Task tool_use blocks — web search, document analysis, and source verification. Each has its own id, its own self-contained prompt, and its own allowedTools set following least privilege. Crucially, all three appear in the SAME response. The coordinator does not call the API three times. It calls it once, emits three Task blocks, and then waits for the next user message to carry three tool_results back in a single batch. That's the structural signature — one response, three Tasks, one batch of results.
-->

---

<FlowDiagram
  eyebrow="Result collection"
  title="Collecting Results from Parallel Subagents"
  :steps="flowSteps"
  footerLabel="Parallel fan-out and fan-in"
  :footerNum="5"
  :footerTotal="8"
/>

<!--
Let's walk the fan-out and fan-in. Step one: the coordinator issues three Task calls in a single response. Step two: the subagents execute independently — web search, document analysis, and source verification all running at the same time. Step three: the next user message returns all three tool_results as a single batch. One message, three results. Step four: the coordinator resumes and aggregates the three outputs on its next turn. Two things to remember. First, the coordinator does NOT see partial results streaming in — it sees the whole batch at once. Second, if any subagent fails, that shows up as an is_error:true tool_result inside the same batch. The coordinator must reason explicitly about partial failures; it does not get a clean retry.
-->

---

<TwoColSlide
  variant="compare"
  title="Parallel vs Sequential — Full Comparison"
  eyebrow="Side-by-side"
  leftLabel="Sequential"
  rightLabel="Parallel"
  :footerNum="6"
  :footerTotal="8"
>
  <template #left>
    <ul>
      <li v-for="(b, i) in seqLeft" :key="i">{{ b }}</li>
    </ul>
  </template>
  <template #right>
    <ul>
      <li v-for="(b, i) in parRight" :key="i">{{ b }}</li>
    </ul>
  </template>
</TwoColSlide>

<!--
A side-by-side comparison. Sequential: one Task call per coordinator turn; coordinator waits for each result before proceeding; used when there's a data dependency; total time is the sum of every subagent's duration; the research-then-synthesis pipeline is the archetype. Parallel: multiple Task calls in ONE coordinator turn; subagents run simultaneously; used when tasks are independent; total time is approximately the slowest subagent's duration; web-search plus doc-analysis plus source-verify is the archetype. The big win for parallel is latency. The big constraint is that you cannot use it when task B depends on task A.
-->

---

<Frame>
  <Eyebrow>⚡ Exam tip</Eyebrow>
  <SlideTitle>Parallel Subagent Execution — Key Trap</SlideTitle>
  <div style="margin-top: 40px; display: grid; grid-template-columns: 1fr 1fr; gap: 32px; flex: 1; min-height: 0;">
    <CalloutBox variant="dont" title="Common trap">
      <p>An answer describes 'parallel' execution where the coordinator spawns subagents across multiple turns, waiting for each one. That is <strong>sequential</strong>, not parallel — regardless of the wording.</p>
      <p>Also wrong: subagents communicating directly to share intermediate results — violates hub-and-spoke isolation regardless of order.</p>
    </CalloutBox>
    <CalloutBox variant="do" title="Correct definition">
      <p>Parallel means <strong>multiple Task calls in ONE coordinator response turn</strong>. Independent tasks → parallel. Dependent tasks → sequential. All parallel results return as a single batch before the coordinator's next turn.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Domain 1 · Key trap" :num="7" :total="8" />
</Frame>

<!--
The exam trap you are most likely to see. A question describes "parallel" execution but the scenario says the coordinator spawned subagent one, waited for it, then spawned subagent two. That is sequential. The word "parallel" in the scenario is there to mislead you. Structure matters, not vocabulary — count the coordinator response turns. Another trap: subagents that communicate directly to share intermediate findings. That violates the hub-and-spoke isolation we established in Lecture 3.4, and it is wrong whether the execution is parallel or sequential. The correct definition: parallel means multiple Task calls in ONE coordinator response turn, period. Independent tasks parallelise; dependent tasks sequence. All results return as a batch before the coordinator's next turn.
-->

---

<BulletReveal
  eyebrow="Takeaways"
  title="Parallel Subagent Execution — What to Remember"
  :bullets="takeaways"
  :footerNum="8"
  :footerTotal="8"
/>

<!--
Six things to carry forward. One — parallel means multiple Task calls in ONE coordinator response turn, never across multiple turns. Two — independent tasks parallelise; data-dependent tasks must be sequenced. Three — all parallel results return as a single batch before the coordinator's next turn. Four — parallel execution time is bounded by the slowest subagent, not the sum of all. Five — partial failures show up as is_error:true tool_results inside the same batch, and the coordinator must handle them explicitly. And six — real pipelines almost always mix both: a parallel collection phase followed by a sequential synthesis phase. That pattern will show up in Scenario 3 and in Lecture 3.9, where we'll look at how context moves between the parallel and sequential parts of a pipeline.
-->
