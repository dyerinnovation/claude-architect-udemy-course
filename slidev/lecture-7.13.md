---
theme: default
title: "Lecture 7.13: Crash Recovery with State Manifests"
info: |
  Claude Certified Architect – Foundations
  Section 7 — Context & Reliability (Domain 5, 15%)
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
const manifestCode = `{
  "agents": [
    {
      "agent_id": "doc-retrieval",
      "completion_status": "completed",
      "output_location": "s3://pipeline/run-42/doc-retrieval.json",
      "timestamp": "2026-04-12T14:22:03Z"
    },
    {
      "agent_id": "extraction",
      "completion_status": "completed",
      "output_location": "s3://pipeline/run-42/extraction.json",
      "timestamp": "2026-04-12T14:28:10Z"
    },
    {
      "agent_id": "analysis",
      "completion_status": "completed",
      "output_location": "s3://pipeline/run-42/analysis.json",
      "timestamp": "2026-04-12T14:34:22Z"
    },
    {
      "agent_id": "cross-referencing",
      "completion_status": "failed",
      "failure_type": "out_of_memory",
      "timestamp": "2026-04-12T14:36:14Z"
    },
    {
      "agent_id": "synthesis",
      "completion_status": "not_started"
    },
    {
      "agent_id": "quality-review",
      "completion_status": "not_started"
    }
  ]
}`

const recoverySteps = [
  { label: 'Coordinator loads manifest', sublabel: 'Source of truth on resume' },
  { label: 'Reads per-agent status', sublabel: 'completed / failed / not_started' },
  { label: 'Skips completed', sublabel: 'Pulls outputs from output_location' },
  { label: 'Reruns incomplete agents', sublabel: 'Starting from first failure' },
]

const useWhenBullets = [
  { label: 'Long-running multi-agent pipelines', detail: 'Tens of minutes, many handoffs.' },
  { label: 'Expensive subagent work', detail: 'Web searches, doc analysis, large retrieval — re-run cost is meaningful.' },
  { label: 'External failure modes', detail: 'Network flakes, rate limits, OOM kills, upstream API outages.' },
]

const antiPatternBad = `Coordinator holds all subagent state
in conversation memory.

→ One crash and everything's gone.
→ Coordinator's plan lost.
→ Subagent outputs lost.
→ Starting from scratch on every failure.`

const antiPatternFix = `Each agent persists to filesystem /
object store. Coordinator reconstructs
from manifest on resume.

→ Durable beats in-memory whenever
  the cost of loss is non-trivial.
→ Same externalization principle as
  case-facts (7.4), scratchpads (7.12).`
</script>

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div class="di-cover">
    <div class="di-cover__eyebrow">Domain 5 · Lecture 7.13</div>
    <div class="di-cover__title">Crash Recovery with<br/>State Manifests</div>
    <div class="di-cover__subtitle">Filesystem discipline, not magic</div>
  </div>
</Frame>

<style scoped>
.di-cover { flex: 1; display: flex; flex-direction: column; justify-content: center; gap: 32px; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 28px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); }
.di-cover__title { font-family: var(--font-display); font-size: 108px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); max-width: 1500px; }
.di-cover__subtitle { font-family: var(--font-display); font-size: 40px; color: var(--mint-200); font-style: italic; }
</style>

<!--
Lecture 7.13. Crash recovery with structured agent state manifests. This is Scenario 3 territory — multi-agent pipelines — and it's one of those lectures where the pattern sounds like plumbing, but the exam tests it directly. If you've ever worked on production batch jobs, the shape will feel familiar. If you haven't, memorize it from this lecture.
-->

---

<BigQuote
  lead="The problem"
  quote="Multi-agent pipeline crashes at agent 4 of 6. <em>Do you restart all six? Or resume?</em>"
  attribution="Restart wastes work. Resume requires knowing what finished and where outputs live."
/>

<!--
Here's the scenario. A multi-agent pipeline runs six subagents — document retrieval, extraction, analysis, cross-referencing, synthesis, quality review. Agent four crashes on an out-of-memory error. Do you restart all six? Or do you resume from agent four?

If you restart all six, you've thrown away the work of agents one through three — potentially hours of web search, document download, and extraction that you now have to pay for again. If you resume from agent four, you need to know what one through three produced, because agent four's input depends on them. The question is how the coordinator knows what finished and where the outputs live.
-->

---

<ConceptHero
  leadLine="Each agent exports state"
  concept="Every success leaves a trace."
  supportLine="State goes to a known location on completion. Coordinator reads the manifest on resume. Only unfinished agents re-run."
/>

<!--
Each agent exports state. When an agent completes, it writes its output plus a small metadata manifest to a known location — typically a shared filesystem or object store. The coordinator, on resume, reads the manifest first. It sees which agents finished, where their outputs live, and which agents haven't run yet. It pulls the completed outputs into the input of the next agent, and it only re-runs the unfinished ones.

Crash recovery isn't magic. It's filesystem discipline. Every successful agent leaves a durable trace. The coordinator uses those traces as its source of truth on resume.
-->

---

<CodeBlockSlide
  title="Agent state manifest"
  lang="json"
  :code="manifestCode"
  annotation="Four fields per agent: id, status, location, timestamp. Written atomically after output persists."
/>

<!--
The manifest is a small JSON structure per agent. Agent_id — which subagent this entry is for. Completion_status — "completed," "failed," "running," "not_started." Output_location — the path or URL where the agent's output lives. Timestamp — when the manifest was written. Optionally: failure details if the status is "failed," so the coordinator knows whether to retry or escalate.

Four fields. Known location. Written atomically on completion — meaning, the manifest only flips to "completed" after the output is fully persisted, so there's no partial-state ambiguity. That's the contract.
-->

---

<FlowDiagram
  title="Resume after crash"
  :steps="recoverySteps"
/>

<!--
The resume flow. Coordinator starts. Coordinator loads the manifest. Coordinator reads per-agent status. For each agent marked "completed," coordinator pulls the output from the output_location and injects it into downstream inputs. For each agent not completed, coordinator re-runs — starting from the first incomplete agent and continuing through the pipeline.

Four steps. Deterministic. Testable. You can resume the same crashed pipeline ten times in a row and get the same outcome — either it finishes or it fails at the same step, but it never silently skips or silently re-does.
-->

---

<CalloutBox variant="tip" title="Discipline required — not free, worth it">

Each agent must write state. Coordinator must know where. Overhead is real — but crash cost is worse.

<p>In a six-agent chain with even a small per-agent failure rate, the probability of a clean full run drops quickly. Manifests amortize the discipline cost across every successful resume.</p>

</CalloutBox>

<!--
This isn't free. Each agent has to write state on completion — that's disk I/O, serialization, extra error handling. The coordinator has to know where to look and how to parse. The overhead is real.

But crash cost is worse. A pipeline that can't resume loses everything on every failure, and in a six-agent chain with even a small per-agent failure rate, the probability of a full clean run drops quickly. You end up re-doing the early work constantly. Manifests amortize the discipline cost across every successful resume — you pay the overhead once per run and save the re-work cost on every failure.
-->

---

<BulletReveal
  title="Use for..."
  :bullets="useWhenBullets"
/>

<!--
Use state manifests for long-running multi-agent pipelines. Use them when subagent work is expensive — web searches, document analysis, large retrieval jobs where the cost of re-running is meaningful. Use them when external failure modes exist — network flakes, rate limits, out-of-memory kills, upstream API outages.

If your pipeline is two short subagents running in-process and finishing in thirty seconds, skip it — the overhead isn't worth it. If it's six agents touching external systems over tens of minutes, build it in from day one. The break-even point for adding manifests is lower than most teams expect.
-->

---

<AntiPatternSlide
  title="Don't rely on in-memory state"
  lang="text"
  :badExample="antiPatternBad"
  whyItFails="Conversation memory can't survive a process crash. There's no durable trace to reconstruct from."
  :fixExample="antiPatternFix"
/>

<!--
The anti-pattern: coordinator holds all subagent state in conversation memory. One crash and everything's gone — both the coordinator's plan and the subagents' outputs. You're starting from scratch on every failure.

The better pattern: each agent persists to the filesystem, coordinator reconstructs from the manifest on resume. Durable beats in-memory whenever the cost of loss is non-trivial. This is the same externalization principle we've been tracking since 7.4 — case-facts blocks, scratchpads, state manifests. Different surfaces, one discipline.
-->

---

<CalloutBox variant="tip" title="On the exam">

"Recover multi-agent pipeline after crash" → state manifests (or equivalent durable-state language).

<p>Distractors: "restart the pipeline from scratch" or "increase coordinator context window." Both ignore the point. Restart is wasteful; larger windows don't solve the crash problem at all.</p>

<p>Ingredients to recognize: multi-agent, long-running, crash recovery → manifest answer follows.</p>

</CalloutBox>

<!--
On the exam, the shape is: "Recover multi-agent pipeline after crash." The right answer is state manifests — or equivalent durable-state language. The distractor is "restart the pipeline from scratch" or "increase coordinator context window." Both ignore the point. Restart is wasteful; larger windows don't solve the crash problem at all.

Recognize the question by its ingredients — multi-agent, long-running, crash recovery — and the manifest answer follows.
-->

---

<Frame bg="var(--mint-100)">
  <Eyebrow>Closing</Eyebrow>
  <SlideTitle>Next up: 7.14 — Human Review Workflows and Confidence Calibration.</SlideTitle>

  <div class="closing-body">
    <p><strong>Heads-up:</strong> this one has a nuance that directly contradicts something you learned in 7.5. The two lectures disagree intentionally — and the exam tests whether you understand WHY. I'll call out the reconciliation explicitly when we get there.</p>
  </div>
</Frame>

<style scoped>
.closing-body { margin-top: 56px; font-family: var(--font-body); font-size: 30px; line-height: 1.5; color: var(--forest-500); max-width: 1400px; }
.closing-body p strong { color: var(--clay-600); }
</style>

<!--
Next up: 7.14, human review workflows and confidence calibration. Heads-up: this one has a nuance that directly contradicts something you learned in 7.5. The two lectures disagree intentionally — and the exam tests whether you understand WHY. I'll call out the reconciliation explicitly when we get there. See you there.
-->
