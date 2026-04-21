---
theme: default
title: "Lecture 5.11: The Explore Subagent"
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
const flowSteps = [
  { label: 'Main hits "need to understand X"', sublabel: 'trigger for delegation' },
  { label: 'Spawns Explore subagent with goal', sublabel: 'e.g. "map data flow for feature Y"' },
  { label: 'Explore does Grep / Read / trace', sublabel: 'in its own context window' },
  { label: 'Returns summary — main keeps only summary', sublabel: 'intermediate tokens are gone' },
]

const exploreBullets = [
  { label: 'Multi-phase task', detail: 'Discovery and implementation are separable' },
  { label: 'Discovery output is long', detail: 'Dozens of tool calls, thousands of tokens' },
  { label: 'Want main lean for implementation', detail: 'Room for code changes, reviews, iterations' },
]

const exploreCode = `# In plan mode, delegate to Explore:

result = explore_codebase(
    query="Map all call sites of legacy billing handlers",
    scope=["services/billing/**/*.py"],
)

# From main's perspective: one tool call, concise result.
# Inside Explore: 40 tool calls to produce it.
# Asymmetry is the point.
`
</script>

<!-- SLIDE 1 — Cover -->

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div style="flex: 1; display: flex; flex-direction: column; justify-content: center;">
    <div style="font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px;">
      Domain 3 &middot; Lecture 5.11
    </div>
    <h1 style="font-family: var(--font-display); font-weight: 500; font-size: 108px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1500px;">
      The <span style="color: var(--sprout-500);">Explore</span> Subagent
    </h1>
    <div style="font-family: var(--font-display); font-size: 44px; color: var(--mint-200); margin-top: 40px; font-weight: 400; max-width: 1200px; line-height: 1.3;">
      Same idea as context: fork — different surface.
    </div>
  </div>
</Frame>

<!--
The Explore subagent is how you isolate verbose discovery from your main conversation. Same core idea as `context: fork` from lecture 5.8 — different surface. Where `context: fork` lives in a SKILL.md, the Explore subagent is a plan-mode surface tool. Same problem, different tool.
-->

---

<!-- SLIDE 2 — Why it exists -->

<ConceptHero
  eyebrow="Why it exists"
  leadLine="Discovery is verbose"
  concept="Keep main lean."
  supportLine="Tracing an unfamiliar codebase costs thousands of tokens. Main session needs the map, not the hike that produced it."
  accent="var(--sprout-600)"
  footerLabel="Lecture 5.11 · Explore Subagent"
  :footerNum="2"
  :footerTotal="9"
/>

<!--
Discovery is verbose. That's the anchor. Tracing an unfamiliar codebase — grepping, reading, following imports, following function calls, building a mental model — costs thousands of tokens. You don't want those tokens in your main context after the discovery is done, because they crowd out the actual task. The main session needs the map, not the hike that produced the map. Every turn after the exploration carries the weight of the exploration — slower, more expensive, less headroom for the work you actually came to do.
-->

---

<!-- SLIDE 3 — Pattern -->

<FlowDiagram
  eyebrow="The flow"
  title="Main → Explore → Main"
  :steps="flowSteps"
  footerLabel="Lecture 5.11 · Explore Subagent"
  :footerNum="3"
  :footerTotal="9"
/>

<!--
Here's the flow. Main session hits a "I need to understand X" moment. It spawns an Explore subagent with a specific goal — "map the data flow for feature Y" or "identify all call sites of function Z" or "summarize how authentication works across the three services." Explore does its thing — Grep, Read, trace — in its own context window. When Explore finishes, it returns a summary. The main session keeps only the summary, not the intermediate tool calls, not the tokens that produced it. Main stays lean. The subagent has done the expensive work, and all that returns is the conclusion.
-->

---

<!-- SLIDE 4 — When to use -->

<BulletReveal
  eyebrow="When Explore fits"
  title="Use it when..."
  :bullets="exploreBullets"
  footerLabel="Lecture 5.11 · Explore Subagent"
  :footerNum="4"
  :footerTotal="9"
/>

<!--
Explore fits multi-phase tasks where discovery and implementation are separable. Use it when the discovery output is long — dozens of tool calls, thousands of tokens — and the main session doesn't need the receipts. Use it when you want main lean for implementation, so you have room for the code changes, the review feedback, the follow-up iterations. If you're building a migration plan, let Explore do the survey; main session starts implementation with a clean summary. The rule of thumb — if discovery would eat more than a quarter of your context window, Explore earns its keep.
-->

---

<!-- SLIDE 5 — Code example -->

<CodeBlockSlide
  eyebrow="In practice"
  title="Explore subagent call"
  lang="python"
  :code="exploreCode"
  annotation="One tool call from main. A full sub-conversation inside. Summary-only return."
  footerLabel="Lecture 5.11 · Explore Subagent"
  :footerNum="5"
  :footerTotal="9"
/>

<!--
In practice, you invoke the Explore subagent inside plan mode with a specific goal — something like calling `explore_codebase` with a query parameter describing what you need to know. The subagent spins up, runs its discovery — grep, read, follow imports, trace call sites — returns a structured summary. The main session reads the summary, integrates it into the plan, and continues. From the main session's perspective, Explore is a single tool call that returns a concise result. From inside, it's a full sub-conversation that did forty tool calls to produce it. That asymmetry is the point.
-->

---

<!-- SLIDE 6 — Ties to skills -->

<Frame>
  <Eyebrow>Same pattern, different surface</Eyebrow>
  <SlideTitle>context: fork in SKILL.md is this, for skills.</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Two isolation surfaces">
      <p>Both <code>context: fork</code> (skills) and the Explore subagent (plan mode) isolate verbose discovery.</p>
      <p>Both return summaries. Both keep main context lean.</p>
      <p>The difference is invocation surface — <code>context: fork</code> is a frontmatter field in SKILL.md; Explore is a plan-mode subagent you delegate to.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.11 · Explore Subagent" :num="6" :total="9" />
</Frame>

<!--
Same pattern as `context: fork` in SKILL.md. Both isolate verbose discovery. Both return summaries. Both keep main context lean. The difference is invocation surface — `context: fork` is a skill-level config in frontmatter; Explore is a plan-mode subagent you delegate to. If you understand one, you understand the other — what changes is where the isolation knob lives, not what it does.
-->

---

<!-- SLIDE 7 — Exam framing -->

<Frame>
  <Eyebrow>On the exam</Eyebrow>
  <SlideTitle>"Main context polluted by exploration."</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Know both surfaces">
      <p>If the question frames the problem in <strong>plan mode or CLI terms</strong> → Explore subagent.</p>
      <p>If the question frames it in <strong>skill-definition terms</strong> → <code>context: fork</code>.</p>
      <p>Either way the fix is isolation. Don't pick "reduce the Grep calls" or "summarize in the body" — those miss the architectural fix.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.11 · Explore Subagent" :num="7" :total="9" />
</Frame>

<!--
On the exam, "main context getting polluted by exploration" is the pattern that maps to either Explore subagent or a forked skill. Know both surfaces. If the question frames the problem in plan mode or CLI terms, the answer is Explore. If the question frames it in skill-definition terms, the answer is `context: fork`. Either way the fix is isolation. Don't pick "reduce the Grep calls" or "summarize in the body" — those miss the architectural fix.
-->

---

<!-- SLIDE 8 — Anti-pattern -->

<AntiPatternSlide
  eyebrow="Anti-pattern"
  title="Don't Grep-and-Read in main for big repos"
  badExample="# Main agent runs 40 tool calls exploring.
# Main context is now 3/4 full of receipts.
# No code has been written yet.
# Every subsequent turn gets slower."
  whyItFails="Main context pays for exploration the user never needed to see."
  fixExample="# Delegate to Explore.
# Main context stays under half full.
# Return with a summary and headroom
# to do the actual work."
  lang="text"
  footerLabel="Lecture 5.11 · Explore Subagent"
  :footerNum="8"
  :footerTotal="9"
/>

<!--
Bad: main agent does forty tool calls exploring an unfamiliar codebase. Your main context is now three-quarters full of discovery receipts, and you haven't written a single line of code yet. Every subsequent turn gets slower and more expensive. Good: delegate to Explore. Main context stays under half full. You return from Explore with a summary and headroom to do the actual work.
-->

---

<!-- SLIDE 9 — Closing -->

<Frame bg="var(--mint-100)">
  <Eyebrow>Takeaways</Eyebrow>
  <SlideTitle>Delegate discovery. Keep main lean.</SlideTitle>
  <div style="margin-top: 48px; display: grid; grid-template-columns: 1fr 1fr; gap: 32px;">
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">01</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Isolates discovery.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Plan-mode subagent runs in its own context window.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">02</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Returns summaries.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Main keeps only the conclusion. Intermediate tokens stay in the sub-context.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">03</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Plan + Explore combo.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Canonical pattern for architectural work. Plan decides, Explore maps, main executes.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">04</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Next &mdash; 5.12.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Iterative refinement — examples, TDD, interview pattern. Three failure modes.</div>
    </div>
  </div>
</Frame>

<!--
Explore subagent isolates verbose discovery. Same idea as forked skills — different surface. Use it when the discovery is long and the main session needs to stay lean for implementation. Plan mode plus Explore is the canonical pattern for architectural work — plan mode decides what to do, Explore figures out what you're working with, main session stays clean to execute. Next lecture — 5.12 — shifts to iterative refinement. Three techniques, three failure modes.
-->
