---
theme: default
title: "Lecture 5.7: Skills — SKILL.md Deep Dive"
info: |
  Claude Certified Architect – Foundations
  Section 5 — Claude Code Configuration (Domain 3, 20%)
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
const surfaceColumns = ['Invoked by', 'Best for']
const surfaceRows = [
  { label: '/command', cells: ['Explicit name', 'Repetitive fixed workflow'] },
  { label: 'Skill', cells: ['Claude matches description', 'Context-triggered behavior'] },
]

const DASH = '-'.repeat(3)
const skillAnatomy = [
  DASH,
  'name: security-review',
  'description: Runs a security-focused code review on pending changes. Flags injection risks, auth bypasses, and secrets leaks.',
  'context: fork',
  'allowed-tools: [Read, Grep, Bash]',
  'argument-hint: "Usage: /security-review [path]"',
  DASH,
  '',
  '# Instructions',
  '',
  'Walk the diff and identify:',
  '1. Injection vectors (SQL, shell, template)',
  '2. Auth bypass or authz drift',
  '3. Secrets committed or logged',
  '',
  '# Examples',
  '',
  '## Correct usage',
  'User: "Run a security review on the billing branch."',
  'Assistant: invokes security-review skill.',
  '',
  '## Incorrect usage',
  'User: "Tell me what the billing branch does."',
  'Assistant: stays in main — skill is security-scoped.',
].join('\n')
</script>

<!-- SLIDE 1 — Cover -->

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div style="flex: 1; display: flex; flex-direction: column; justify-content: center;">
    <div style="font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px;">
      Domain 3 &middot; Lecture 5.7
    </div>
    <h1 style="font-family: var(--font-display); font-weight: 500; font-size: 108px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1500px;">
      Skills — <span style="color: var(--sprout-500);">SKILL.md</span> Deep Dive
    </h1>
    <div style="font-family: var(--font-display); font-size: 44px; color: var(--mint-200); margin-top: 40px; font-weight: 400; max-width: 1200px; line-height: 1.3;">
      Commands are invoked by name. Skills are invoked by semantics.
    </div>
  </div>
</Frame>

<!--
Skills and slash commands look similar. Both are markdown files with frontmatter. Both live in `.claude/` or `~/.claude/`. But they trigger differently — and that difference is the whole exam question. Commands are invoked by name. Skills are invoked by semantics. Let's go deep on the frontmatter that makes skills work.
-->

---

<!-- SLIDE 2 — Skills vs slash commands -->

<ComparisonTable
  eyebrow="Two surfaces, two triggers"
  title="Skills vs commands"
  :columns="surfaceColumns"
  :rows="surfaceRows"
  footerLabel="Lecture 5.7 · SKILL.md Deep Dive"
  :footerNum="2"
  :footerTotal="11"
/>

<!--
Put them side by side. A slash command is invoked by explicit name — you type `/review` and it runs. Best for repetitive fixed workflows where you already know what you want to run. A skill is invoked by Claude matching the description to the task at hand — you describe what you need, and Claude picks the skill that fits. Best for context-triggered behavior, where Claude should reach for the skill automatically when the right moment arrives. Same file shape. Totally different invocation model. The exam tests this distinction directly.
-->

---

<!-- SLIDE 3 — Anatomy -->

<CodeBlockSlide
  eyebrow="SKILL.md anatomy"
  title="Frontmatter + instructions + examples"
  lang="markdown"
  :code="skillAnatomy"
  annotation="Frontmatter is the interface. Body is the prompt. Examples are few-shot training."
  footerLabel="Lecture 5.7 · SKILL.md Deep Dive"
  :footerNum="3"
  :footerTotal="11"
/>

<!--
SKILL.md has three parts. YAML frontmatter at the top — that's where the five fields we're about to cover live. A body of instructions — what Claude should actually do when the skill runs. And examples — showing correct versus incorrect usage. The body is the prompt. The frontmatter is the interface. The examples are few-shot training for Claude's own judgment about when to invoke the skill and how to execute it.
-->

---

<!-- SLIDE 4 — Frontmatter fields -->

<Frame>
  <Eyebrow>Frontmatter fields</Eyebrow>
  <SlideTitle>Five fields. Five jobs.</SlideTitle>
  <div style="margin-top: 40px; display: flex; flex-direction: column; gap: 16px;">
    <SchemaField name="name" type="string" :required="true" description="Kebab-case identifier — the skill's handle." example="security-review" />
    <SchemaField name="description" type="string" :required="true" description="How Claude decides when to use the skill — rules are the same as tool descriptions." example="Runs security-focused review of pending changes" />
    <SchemaField name="context" type="enum" :required="false" description="Either 'fork' or 'main' — controls where the skill runs." example="fork" />
    <SchemaField name="allowed-tools" type="list" :required="false" description="Restrict which tools the skill may call during execution." example="[Read, Grep, Bash]" />
    <SchemaField name="argument-hint" type="string" :required="false" description="Shown to the user when they invoke the skill without required args." example="Usage: /security-review [path]" />
  </div>
  <SlideFooter label="Lecture 5.7 · SKILL.md Deep Dive" :num="4" :total="11" />
</Frame>

<!--
Five fields to know. `name` — a kebab-case identifier, the skill's handle. `description` — what the skill does, which is how Claude decides when to use it. `context` — either `fork` or `main`, controls where the skill runs. `allowed-tools` — a list restricting which tools the skill may call. `argument-hint` — a string shown to the user when they invoke the skill without required arguments. Of these, `description` is the one that decides whether the skill ever triggers. The other four shape how it runs once triggered.
-->

---

<!-- SLIDE 5 — description is a tool description -->

<Frame>
  <Eyebrow>Callback to Domain 2</Eyebrow>
  <SlideTitle>description is a tool description.</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Bad description = dead skill">
      <p>Same rules as tool descriptions from Task 2.1: purpose, inputs, examples, boundaries.</p>
      <p><strong>Bad:</strong> "analyzes things" — the skill never triggers.</p>
      <p><strong>Good:</strong> "runs a security-focused code review on pending changes, flags injection risks, auth bypasses, and secrets leaks" — triggers reliably on the right tasks.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.7 · SKILL.md Deep Dive" :num="5" :total="11" />
</Frame>

<!--
Callback to Domain 2, Task 2.1 — writing good tool descriptions. Same rules apply here. A skill description needs purpose, inputs, examples, boundaries. What does the skill do? When should Claude reach for it? When shouldn't it? If the description is vague — "analyzes things" — the skill never triggers because Claude can't tell when it applies. If the description is precise — "runs a security-focused code review on pending changes, flags injection risks, auth bypasses, and secrets leaks" — the skill triggers reliably on the right tasks. Bad description equals dead skill.
-->

---

<!-- SLIDE 6 — context field preview -->

<Frame>
  <Eyebrow>context field — preview</Eyebrow>
  <SlideTitle>Covered in 5.8.</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="context: fork isolates skill execution">
      <p>Takes two values — <code>fork</code> and <code>main</code>. <code>fork</code> isolates the skill from the main session — it runs in a sub-agent context, and only the final output returns.</p>
      <p>Prevents verbose skill execution from eating your main context. One of the most important frontmatter options in Domain 3 — gets its own lecture next.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.7 · SKILL.md Deep Dive" :num="6" :total="11" />
</Frame>

<!--
`context` takes two values — `fork` and `main`. The `fork` value isolates the skill from the main session — it runs in a sub-agent context, and only the final output returns. This prevents verbose skill execution from eating your main context. It's one of the most important frontmatter options in Domain 3, and it gets its own lecture next — 5.8. For now: just know it exists, and it's how you stop skills from polluting main conversation.
-->

---

<!-- SLIDE 7 — allowed-tools / argument-hint preview -->

<Frame>
  <Eyebrow>allowed-tools + argument-hint — preview</Eyebrow>
  <SlideTitle>Covered in 5.9.</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Safety rail + UX polish">
      <p><code>allowed-tools</code> is a safety rail — restricts which tools the skill may call during execution.</p>
      <p><code>argument-hint</code> is UX polish — when the user invokes the skill without required args, the hint shows instead of a silent failure.</p>
      <p>Small fields. Big operational impact. We'll spend a whole lecture on them.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.7 · SKILL.md Deep Dive" :num="7" :total="11" />
</Frame>

<!--
`allowed-tools` and `argument-hint` also get their own lecture — 5.9. Briefly: `allowed-tools` is a safety rail, restricting which tools the skill may call during execution. `argument-hint` is a UX polish — when the user invokes the skill without arguments, the hint gets shown instead of a silent failure. Small fields, big operational impact. We'll spend a whole lecture on them.
-->

---

<!-- SLIDE 8 — When to skill vs when to CLAUDE.md -->

<ConceptHero
  eyebrow="The decision"
  leadLine="Skill = on-demand workflow. CLAUDE.md = always-loaded standards."
  concept="Trigger = surface."
  supportLine="If Claude should always know it → CLAUDE.md. If Claude should invoke it when relevant → skill. Don't mix them up."
  accent="var(--sprout-600)"
  footerLabel="Lecture 5.7 · SKILL.md Deep Dive"
  :footerNum="8"
  :footerTotal="11"
/>

<!--
Here's the decision. Skill equals on-demand workflow. CLAUDE.md equals always-loaded standards. If Claude should always know the thing — coding conventions, testing rules, project architecture — it goes in CLAUDE.md. If Claude should only invoke the thing when the situation warrants — run a security review, generate a changelog, validate a schema — it's a skill. Same information-sharing goal, different loading model. Don't put always-applicable standards in a skill. Don't put on-demand workflows in CLAUDE.md. Each surface has its job.
-->

---

<!-- SLIDE 9 — Exam framing -->

<Frame>
  <Eyebrow>On the exam</Eyebrow>
  <SlideTitle>Three surfaces. Three triggers. Map and move on.</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Map trigger to surface">
      <p><strong>"On-demand, task-specific"</strong> → skill.</p>
      <p><strong>"Universal always-loaded standards"</strong> → CLAUDE.md.</p>
      <p><strong>"Applied by file path automatically"</strong> → <code>.claude/rules/</code>.</p>
      <p>Almost-right is the trap. A question might describe on-demand work and offer CLAUDE.md as a distractor. Map trigger → surface and you'll pick right.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.7 · SKILL.md Deep Dive" :num="9" :total="11" />
</Frame>

<!--
The exam distinguishes three Domain 3 surfaces. "On-demand, task-specific" maps to skill. "Universal always-loaded standards" maps to CLAUDE.md. "Applied by file path automatically" maps to `.claude/rules/`. Three surfaces, three triggers. Almost-right is the whole trap of this exam — a question might describe an on-demand workflow and offer CLAUDE.md as a distractor, or describe universal standards and offer skills as a distractor. Map the invocation trigger to the surface and you'll pick right.
-->

---

<!-- SLIDE 10 — Continuity -->

<ConceptHero
  eyebrow="Continuity"
  leadLine="Scenario 2 and Scenario 4 both test this."
  concept="The reusable-prompts surface."
  supportLine="Operational difference: 'run this when I ask' vs 'know this at all times.' That operational distinction IS the exam."
  accent="var(--teal-600)"
  footerLabel="Lecture 5.7 · SKILL.md Deep Dive"
  :footerNum="10"
  :footerTotal="11"
/>

<!--
Scenario 2 and Scenario 4 both test this. Skills are the reusable-prompts surface — if you've built them as a team, you know the operational difference between "run this when I ask" and "know this at all times." That operational distinction is literally the exam.
-->

---

<!-- SLIDE 11 — Closing -->

<Frame bg="var(--mint-100)">
  <Eyebrow>Takeaways</Eyebrow>
  <SlideTitle>Skills trigger by semantics, not name.</SlideTitle>
  <div style="margin-top: 48px; display: grid; grid-template-columns: 1fr 1fr; gap: 32px;">
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">01</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Description fires the skill.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Same rules as tool descriptions — purpose, inputs, examples, boundaries.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">02</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Five frontmatter fields.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">name, description, context, allowed-tools, argument-hint.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">03</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Skill vs CLAUDE.md.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">On-demand workflow vs always-loaded standards.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">04</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Next &mdash; 5.8.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;"><code>context: fork</code> — isolating skill execution from main context.</div>
    </div>
  </div>
</Frame>

<!--
Skills are semantic-triggered, commands are name-triggered. SKILL.md has five frontmatter fields. `description` decides whether the skill ever fires. Next lecture — 5.8 — we go deep on the `context: fork` field, because that's the one that solves a very specific context-pollution problem.
-->
