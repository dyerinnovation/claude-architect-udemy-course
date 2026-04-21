---
theme: default
title: "Lecture 5.9: allowed-tools and argument-hint"
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
const DASH = '-'.repeat(3)

const allowedToolsExample = [
  DASH,
  'name: write-docstring-to-file',
  'description: Adds a docstring to the specified file at the top of the given function. Write-only scope.',
  'allowed-tools: [Write, Edit, Read]',
  DASH,
  '',
  '# Instructions',
  '',
  'Given a file path and a function name:',
  '1. Read the file',
  '2. Generate a docstring in the project style',
  '3. Edit the file to insert it',
  '',
  '# Note',
  '',
  '# Bash is NOT in allowed-tools — blocked at the harness.',
].join('\n')

const argumentHintExample = [
  DASH,
  'name: research-topic',
  'description: Researches a topic and returns a markdown summary with sources.',
  'argument-hint: "Usage: /research-topic <topic> [--max-sources=10]"',
  DASH,
  '',
  '# Instructions',
  '',
  'Research the provided topic using web sources. Cap at max-sources.',
].join('\n')

const usageColumns = ['Use for']
const usageRows = [
  { label: 'allowed-tools', cells: ['Skill has destructive potential — scope down to exact tools it needs'] },
  { label: 'argument-hint', cells: ['Skill needs user input — prompt with usage string instead of silent failure'] },
]
</script>

<!-- SLIDE 1 — Cover -->

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div style="flex: 1; display: flex; flex-direction: column; justify-content: center;">
    <div style="font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px;">
      Domain 3 &middot; Lecture 5.9
    </div>
    <h1 style="font-family: var(--font-display); font-weight: 500; font-size: 108px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1500px;">
      <span style="color: var(--sprout-500);">allowed-tools</span> and<br/><span style="color: var(--sprout-500);">argument-hint</span>
    </h1>
    <div style="font-family: var(--font-display); font-size: 44px; color: var(--mint-200); margin-top: 40px; font-weight: 400; max-width: 1200px; line-height: 1.3;">
      Safety rail + UX polish. Two fields, two jobs.
    </div>
  </div>
</Frame>

<!--
Two frontmatter fields, two jobs. `allowed-tools` is a safety rail — scope down what the skill can call. `argument-hint` is UX polish — prompt the user instead of silently failing. Small fields. Big operational impact. The exam tests them as distinct answers to distinct problems.
-->

---

<!-- SLIDE 2 — allowed-tools -->

<Frame>
  <Eyebrow>allowed-tools</Eyebrow>
  <SlideTitle>Restrict scope. Enforce least privilege.</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="warn" title="Safety rail — what tools may the skill call?">
      <p>List the exact tools the skill may invoke: <code>Write, Edit, Read, Bash, Grep</code>, whatever. Anything not on the list is blocked at execution time.</p>
      <p>A skill you designed to "generate a changelog" should never run Bash. A skill you designed to "review pending changes" should never write files — it reads and reports. Locking the skill down prevents unintended blast radius when the prompt goes sideways.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.9 · allowed-tools + argument-hint" :num="2" :total="8" />
</Frame>

<!--
`allowed-tools` restricts scope. Inside the skill's frontmatter, you list the exact tools the skill is allowed to invoke — Write, Edit, Read, Bash, Grep, whatever. Anything not on the list is blocked at execution time. Why bother? Because a skill you designed to "generate a changelog" should never run Bash. And a skill you designed to "review pending changes" should never write files — it reads and reports. Locking the skill down to just the tools it needs prevents unintended blast radius when the prompt goes sideways. Principle of least privilege, applied at the skill level.
-->

---

<!-- SLIDE 3 — allowed-tools example -->

<CodeBlockSlide
  eyebrow="allowed-tools example"
  title="Write-only file skill"
  lang="yaml"
  :code="allowedToolsExample"
  annotation="Frontmatter is the contract. The harness keeps the skill inside it."
  footerLabel="Lecture 5.9 · allowed-tools + argument-hint"
  :footerNum="3"
  :footerTotal="8"
/>

<!--
Here's a write-only file skill. Frontmatter block — `name: write-docstring-to-file`. `allowed-tools: [Write, Edit, Read]`. That's it. The skill can read files, write files, edit files — nothing else. It can't run shell commands. It can't invoke web-fetch. It can't spawn subprocesses. If the skill's body tells it to run Bash — doesn't matter, blocked at the harness level before the tool ever fires. The frontmatter is the contract the harness enforces. You define the capabilities; the harness keeps the skill inside them.
-->

---

<!-- SLIDE 4 — argument-hint -->

<Frame>
  <Eyebrow>argument-hint</Eyebrow>
  <SlideTitle>Prompt the user. Don't fail silently.</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="UX polish — one line of frontmatter">
      <p>When the user invokes the skill without arguments, the hint string shows instead of a silent failure or a confused execution.</p>
      <p>"Usage: /my-skill &lt;topic&gt; [--depth=3]" tells the user what's missing and how to fix it. Turns "this skill doesn't work" bug reports into self-service fixes.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.9 · allowed-tools + argument-hint" :num="4" :total="8" />
</Frame>

<!--
`argument-hint` is UX polish. When the user invokes the skill without the arguments it needs, the hint string shows instead of a silent failure or a confused execution. It's a one-line prompt — "Usage: /my-skill <topic> [--depth=3]" — that tells the user what's missing and how to fix it. Small feature. Turns "this skill doesn't work" bug reports into self-service fixes. The user reads the hint, rephrases the invocation, skill runs. No Slack thread required.
-->

---

<!-- SLIDE 5 — argument-hint example -->

<CodeBlockSlide
  eyebrow="argument-hint example"
  title="SKILL.md with argument hint"
  lang="yaml"
  :code="argumentHintExample"
  annotation="Without the hint, the skill fails silently or picks a bad default."
  footerLabel="Lecture 5.9 · allowed-tools + argument-hint"
  :footerNum="5"
  :footerTotal="8"
/>

<!--
SKILL.md snippet. Frontmatter includes `argument-hint: "Usage: /research-topic <topic> [--max-sources=10]"`. Now when a developer invokes the skill without arguments, they see that hint. They know they're missing a topic. They know there's an optional max-sources flag. They retry with the right shape and the skill runs. Without the hint, the skill either fails silently or picks a bad default, and the developer doesn't know why. One extra line of frontmatter turns a mystery failure into a readable usage message.
-->

---

<!-- SLIDE 6 — When to use each -->

<ComparisonTable
  eyebrow="Two fields, two jobs"
  title="Frontmatter usage"
  :columns="usageColumns"
  :rows="usageRows"
  footerLabel="Lecture 5.9 · allowed-tools + argument-hint"
  :footerNum="6"
  :footerTotal="8"
/>

<!--
Different jobs. `allowed-tools` is for when the skill has destructive potential and you want to scope down what it's allowed to touch. Scope down, sleep better. `argument-hint` is for when the skill needs user input, and you want to prompt for it instead of failing. Prompt instead of fail. Neither replaces the other. A skill that does destructive work and needs arguments wants both fields set — the safety rail limits damage, and the hint makes the skill usable. Independent concerns.
-->

---

<!-- SLIDE 7 — Exam framing -->

<Frame>
  <Eyebrow>On the exam</Eyebrow>
  <SlideTitle>Don't swap the safety rail with the UX polish.</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Map the problem to the field">
      <p><strong>"Restrict the skill's destructive actions"</strong> → <code>allowed-tools</code>.</p>
      <p><strong>"Prompt the user for a missing argument"</strong> → <code>argument-hint</code>.</p>
      <p>Both fields sit in frontmatter. Both modify skill behavior. Swapping them in a distractor is an easy miss. Almost-right is the trap.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.9 · allowed-tools + argument-hint" :num="7" :total="8" />
</Frame>

<!--
On the exam, watch for this pair. "Restrict the skill's destructive actions" maps to `allowed-tools`. "Prompt the user for a missing argument" maps to `argument-hint`. Distinct fields, distinct jobs — and the exam will offer them as distractors for each other. Don't confuse the safety rail with the UX polish. If the question is about scope and restriction, it's `allowed-tools`. If the question is about user input and prompting, it's `argument-hint`. Map the problem to the field. Almost-right is the trap here — both fields sit in frontmatter, both modify skill behavior, so swapping them in a distractor is an easy miss.
-->

---

<!-- SLIDE 8 — Closing -->

<Frame bg="var(--mint-100)">
  <Eyebrow>Takeaways</Eyebrow>
  <SlideTitle>Two fields. Two jobs. No overlap.</SlideTitle>
  <div style="margin-top: 48px; display: grid; grid-template-columns: 1fr 1fr; gap: 32px;">
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">01</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">allowed-tools = safety.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Locks the skill down to approved tools. Least privilege at the skill level.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">02</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">argument-hint = UX.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Prompts user with usage string when args are missing. No silent failures.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">03</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Five fields total.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">name, description, context, allowed-tools, argument-hint. Each with a distinct role.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">04</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Next &mdash; 5.10.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Plan mode vs direct execution. Sample Q5 territory.</div>
    </div>
  </div>
</Frame>

<!--
`allowed-tools` locks the skill down to approved tools — the safety rail. `argument-hint` prompts the user for missing inputs — the UX polish. Two fields, two jobs, no overlap. Both live in SKILL.md frontmatter alongside `name`, `description`, and `context` from the last two lectures. Five fields total, each with a distinct role. Next lecture — 5.10 — we pivot out of skills and commands into the decision framework for plan mode versus direct execution. That's Sample Question 5 territory.
-->
