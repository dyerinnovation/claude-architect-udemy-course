---
theme: default
title: "Lecture 3.7: The Task Tool — Spawning Subagents"
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
const capabilityBullets = [
  { label: 'Principle of least privilege', detail: 'Each subagent only has tools required for its specific job. Doc analysis doesn\'t need web search. Web search doesn\'t need file write.' },
  { label: 'Why it matters', detail: 'Overpowered subagent = unintended actions. Write access where read-only was meant → data corruption. Constrained = predictable, auditable, safer.' },
  { label: 'Examples', detail: "Research: ['Task', 'web_search', 'read_url'] · Report writer: ['Task', 'write_file'] · Code reviewer: ['Task', 'read_file', 'run_tests']" },
]

const takeawayBullets = [
  { label: 'Task = the spawn mechanism', detail: 'The Task tool is how coordinators spawn independent subagent instances.' },
  { label: "allowedTools must include 'Task'", detail: 'Without it, the subagent cannot properly accept its assignment.' },
  { label: 'Each call = fresh instance', detail: 'No state persists between Task calls.' },
  { label: 'prompt must be self-contained', detail: "It's all the subagent knows — make every assumption explicit." },
  { label: 'Apply least privilege', detail: 'Each subagent gets only the tools needed for its specific job — nothing more.' },
  { label: 'Multiple calls = parallel', detail: 'Multiple Task calls in one coordinator response = parallel spawning (covered in 3.8).' },
]

const taskStructCode = `task_call = {
    "name": "Task",
    "input": {
        "description": "Short label for this subagent run",
        "prompt":      "Complete, self-contained task specification",
        "allowedTools": ["Task", "read_file", "search_documents"]
    }
}`

const allowedBad = `// Missing "Task" — subagent cannot properly accept its task
{
  "allowedTools": ["read_file", "search_documents"]
}`

const allowedGood = `// "Task" present — subagent can accept and execute
{
  "allowedTools": ["Task", "read_file", "search_documents"]
}`

const examBad = `Two traps the exam plants

Trap 1 — Missing 'Task' in allowedTools
  Subagent fails to process its assignment; the question
  describes unexpected behavior. Root cause: 'Task' is
  absent from allowedTools.

Trap 2 — Overly permissive allowedTools
  'Give every subagent access to all tools for flexibility.'
  Violates least privilege — the right answer narrows the list.`

const examGood = `Rule

Every subagent's allowedTools must include 'Task'
PLUS only the tools needed for its specific job.
Nothing more.`

const parallelCode = `# Coordinator spawns two subagents in ONE response turn
coordinator_response_content = [
    {
        "type": "tool_use",
        "id": "toolu_01RES",
        "name": "Task",
        "input": {
            "description": "Research Q3 industry trends",
            "prompt": "Find 5 sources on Q3 AI infra spend...",
            "allowedTools": ["Task", "web_search", "read_url"]
        }
    },
    {
        "type": "tool_use",
        "id": "toolu_01DOC",
        "name": "Task",
        "input": {
            "description": "Analyze the uploaded Q3 report",
            "prompt": "Extract revenue, margin, and growth...",
            "allowedTools": ["Task", "read_file"]
        }
    }
]

# Both Task calls go out in THE SAME coordinator turn = parallel.
# Coordinator waits for BOTH results before continuing.`
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
      <div style="font-family: var(--font-body); font-size:26px; font-weight:600; letter-spacing:0.16em; text-transform:uppercase; color: var(--sprout-500); margin-bottom:40px;">Domain 1 &middot; Lecture 3.7</div>
      <h1 style="font-family: var(--font-display); font-weight:500; font-size:128px; line-height:1.02; letter-spacing:-0.025em; color: var(--paper-0); margin:0; max-width:1500px;">
        The <span style="color: var(--sprout-500);">Task</span> Tool
      </h1>
      <div style="font-family: var(--font-display); font-size:44px; color: var(--mint-200); margin-top:40px; font-weight:400; max-width:1200px; line-height:1.3;">
        Spawning subagents — structure, constraints, and least privilege.
      </div>
    </div>
    <div style="display:flex; align-items:center; gap:48px; font-family: var(--font-body); font-size:26px; color: var(--mint-200); letter-spacing:0.06em;">
      <span>Lecture 3.7</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>~8 min</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>8 slides</span>
    </div>
  </div>
</Frame>

<!--
The Task tool is the mechanism behind everything we covered in 3.4, 3.5, and 3.6. When we say "the coordinator spawns a subagent," what we mean, concretely, is "the coordinator calls the Task tool." This lecture covers what the Task tool is, its key parameters, the allowedTools requirement the exam tests, and the least-privilege principle. Get this right and the multi-agent patterns all fall into place.
-->

---

<!-- SLIDE 2 — What the Task tool is / isn't -->

<TwoColSlide
  variant="compare"
  title="What the Task Tool Is"
  leftLabel="What it does"
  rightLabel="What it is NOT"
  footerLabel="Lecture 3.7"
  :footerNum="2"
  :footerTotal="8"
>
<template #left>

- Creates an **independent Claude instance**.
- Passes a task description and instructions.
- Constrains the subagent to specific tools.
- Returns the subagent's final output to the coordinator.

</template>
<template #right>

- **NOT** a generic HTTP call to another service.
- **NOT** a thread or process fork.
- **NOT** a shared-memory communication channel.
- **NOT** persistent — each call is independent.

*Analogy:* the Task tool is Claude's native way of saying "I need a specialist to handle this — let me formally assign the work."

</template>
</TwoColSlide>

<!--
Let's anchor what the Task tool actually is. It does four things: creates an independent Claude instance, passes a task description and instructions, constrains the subagent to specific tools, and returns the subagent's final output to the coordinator. What it is NOT: a generic HTTP call to another service, a thread or process fork, a shared-memory communication channel, or a persistent session. Each call is independent. The analogy I like: the Task tool is Claude's native way of saying "I need a specialist to handle this — let me formally assign the work."
-->

---

<!-- SLIDE 3 — Key parameters -->

<CodeBlockSlide
  eyebrow="Structure"
  title="The Task Tool — Key Parameters"
  lang="python"
  :code="taskStructCode"
  annotation="allowedTools — which tools the subagent can use; MUST include 'Task'. prompt — complete self-contained context; it's all the subagent knows."
  footerLabel="Lecture 3.7"
  :footerNum="3"
  :footerTotal="8"
/>

<!--
The Task tool takes three key parameters. Description: a short label for what this subagent is doing. Prompt: the complete, self-contained task specification — objective, context, output format, constraints. This is all the subagent knows. And allowedTools: the list of tools the subagent is permitted to use. Two things the exam tests here. One: the prompt must be self-contained — because of context isolation, it's everything the subagent knows. Two: allowedTools must include "Task" or the subagent can't accept the assignment. That's the next slide.
-->

---

<!-- SLIDE 4 — allowedTools must include 'Task' -->

<AntiPatternSlide
  eyebrow="Critical detail"
  title="The allowedTools Requirement"
  lang="json"
  :badExample="allowedBad"
  whyItFails="The Task tool is how an agent FORMALLY accepts an assignment. Without it in the allowed set, the subagent cannot acknowledge and execute the task specification."
  :fixExample="allowedGood"
  footerLabel="Lecture 3.7"
  :footerNum="4"
  :footerTotal="8"
/>

<!--
This is one of the highest-value slides in Domain 1. The allowedTools parameter MUST include "Task". If it's missing, the subagent cannot properly accept its task specification. The reason is mechanical: the Task tool is how an agent formally accepts an assignment. The subagent needs Task in its allowed set in order to process its task specification. Without it, it can't acknowledge and execute. The exam will hand you an answer where allowedTools lists everything except Task, and ask why the subagent isn't doing what's expected. Recognize the pattern on sight.
-->

---

<!-- SLIDE 5 — Least privilege for subagent tools -->

<BulletReveal
  eyebrow="Security"
  title="Constraining Subagent Capabilities via allowedTools"
  :bullets="capabilityBullets"
  footerLabel="Lecture 3.7"
  :footerNum="5"
  :footerTotal="8"
/>

<!--
Beyond the required "Task," the rest of allowedTools is where you apply the principle of least privilege. Each subagent only gets the tools required for its specific job. Document analysis doesn't need web search. Web search doesn't need file write. Why it matters: an overpowered subagent can take unintended actions. Give write access where read-only was meant and you get data corruption. Constrained allowedTools means predictable, auditable, safer behavior. Three quick examples: Research gets Task, web_search, read_url. Report writer gets Task and write_file. Code reviewer gets Task, read_file, and run_tests. Narrow lists. No "just in case" tools.
-->

---

<!-- SLIDE 6 — Parallel spawning setup -->

<CodeBlockSlide
  eyebrow="Parallel spawning"
  title="Coordinator Spawning Multiple Subagents in One Turn"
  lang="python"
  :code="parallelCode"
  annotation="Both Task calls in the SAME coordinator response = parallel. Coordinator waits for ALL Task results before continuing. Covered in depth in 3.8."
  footerLabel="Lecture 3.7"
  :footerNum="6"
  :footerTotal="8"
/>

<!--
Here's what parallel spawning looks like at the Task-call level. The coordinator emits a single response whose content array contains two tool_use blocks — both with name "Task." One spawns the research subagent, the other spawns the document subagent. Each has its own description, prompt, and allowedTools list. Both Task calls are in the same coordinator response turn. That's what "parallel" means here. The coordinator then waits for both Task results before continuing. We'll dive into parallel execution in depth in 3.8.
-->

---

<!-- SLIDE 7 — Exam Tip -->

<AntiPatternSlide
  eyebrow="⚡ Exam Tip"
  title="The Task Tool — Two Exam Traps"
  lang="text"
  :badExample="examBad"
  whyItFails="Task is required to accept an assignment. Every unnecessary tool expands the blast radius of a misbehaving subagent."
  :fixExample="examGood"
  footerLabel="Lecture 3.7"
  :footerNum="7"
  :footerTotal="8"
/>

<!--
Two exam traps to watch for. Trap one: the subagent isn't processing its assignment correctly — and the root cause is that "Task" is missing from allowedTools. Trap two: an answer that hands every subagent access to all tools "for flexibility." That violates least privilege — the correct answer narrows the list. The rule the exam is looking for: every subagent's allowedTools must include "Task" plus only the tools needed for its specific job. Nothing more.
-->

---

<!-- SLIDE 8 — Takeaways -->

<BulletReveal
  eyebrow="Takeaway"
  title="The Task Tool — What to Know Cold"
  :bullets="takeawayBullets"
  footerLabel="Lecture 3.7"
  :footerNum="8"
  :footerTotal="8"
/>

<!--
Six things to carry into 3.8. The Task tool is the mechanism coordinators use to spawn independent subagent instances. allowedTools must include "Task" — without it, the subagent cannot properly accept its assignment. Each Task call creates a fresh independent instance — no state persists. The prompt must be self-contained — it's all the subagent knows. Apply least privilege — each subagent gets only the tools needed for its specific job. Multiple Task calls in one coordinator response equals parallel spawning, which we cover next.
-->
