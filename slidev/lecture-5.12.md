---
theme: default
title: "Lecture 5.12: Iterative Refinement Techniques"
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
const examplesCode = `Input row 1: {"id": 1, "email": null}
Output:       {"id": 1, "email": null}
# nulls preserved

Input row 2: {"id": 2, "email": "USER@ACME.com"}
Output:       {"id": 2, "email": "user@acme.com"}
# non-nulls lowercased

# Two examples, one unambiguous transformation.
`

const tddSteps = [
  { label: 'Write expected behavior as tests', sublabel: 'happy paths + edge cases + perf constraints' },
  { label: 'Claude implements', sublabel: 'against the failing suite' },
  { label: 'Run tests — share failures', sublabel: 'concrete assertions, not vibes' },
  { label: 'Claude fixes', sublabel: 'based on concrete failure data' },
  { label: 'Repeat until green', sublabel: 'deterministic termination' },
]

const interviewPrompt = `Before implementing, ask me 3-5 clarifying
questions about:
- authentication handling
- error recovery
- upstream rate limits

Response:
1. What's the retry policy on upstream failures?
2. Do you want jittered backoff?
3. What happens to in-flight requests if upstream returns 429?
4. Is there a circuit breaker?
5. What's the SLO target?
`

const batchColumns = ['Approach']
const batchRows = [
  { label: 'Issues interact', cells: ['Batch — one message so Claude sees the whole picture'] },
  { label: 'Issues independent', cells: ['Sequential — one at a time, cleaner diffs'] },
]
</script>

<!-- SLIDE 1 — Cover -->

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div style="flex: 1; display: flex; flex-direction: column; justify-content: center;">
    <div style="font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px;">
      Domain 3 &middot; Lecture 5.12
    </div>
    <h1 style="font-family: var(--font-display); font-weight: 500; font-size: 108px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1500px;">
      Iterative <span style="color: var(--sprout-500);">Refinement</span> Techniques
    </h1>
    <div style="font-family: var(--font-display); font-size: 44px; color: var(--mint-200); margin-top: 40px; font-weight: 400; max-width: 1200px; line-height: 1.3;">
      Three techniques. Three failure modes. Stop guessing.
    </div>
  </div>
</Frame>

<!--
Three techniques. Each one solves a different failure mode. Concrete examples for vague specs. Test-driven iteration for progressive convergence. The interview pattern for unfamiliar domains. When you know which technique fits which problem, you stop guessing and start iterating on purpose.
-->

---

<!-- SLIDE 2 — Technique 1: concrete examples -->

<Frame>
  <Eyebrow>Technique 1</Eyebrow>
  <SlideTitle>Concrete examples beat prose.</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="When prose fails, show examples">
      <p>Two or three input/output pairs beat ten sentences of specification.</p>
      <p>Prose leaves room for interpretation. "Handle edge cases gracefully" — what does that mean? "Normalize the input" — how? Examples lock ambiguity down. Input → output. No interpretation needed.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.12 · Iterative Refinement" :num="2" :total="10" />
</Frame>

<!--
When prose fails, show examples. Two or three input-output pairs beat ten sentences of specification. Prose leaves room for interpretation. "Handle edge cases gracefully" — what does that mean? "Normalize the input" — how? Examples lock ambiguity down. You give Claude an input and the output you want for that input, plus another input, plus one more. Now the pattern is explicit. No interpretation needed.
-->

---

<!-- SLIDE 3 — Examples in practice -->

<CodeBlockSlide
  eyebrow="Technique 1 in practice"
  title="Input → output pairs"
  lang="text"
  :code="examplesCode"
  annotation="Migration script with null handling. Preserve nulls. Lowercase non-nulls."
  footerLabel="Lecture 5.12 · Iterative Refinement"
  :footerNum="3"
  :footerTotal="10"
/>

<!--
Real scenario — a data migration script with null handling. Prose version: "handle nulls appropriately." Claude might skip them, might coerce them, might error out — all three are defensible interpretations. Example version: show one input row with a null email field and the expected output row where email stays null. Show another input row with a populated email and the expected output where email gets lowercased. Now Claude sees the exact transformation — preserve nulls, normalize non-nulls. Unambiguous. Two examples, problem solved.
-->

---

<!-- SLIDE 4 — Technique 2: test-driven iteration -->

<Frame>
  <Eyebrow>Technique 2</Eyebrow>
  <SlideTitle>Write the suite first. Converge by iterating.</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Progressive convergence">
      <p>Draft a test suite capturing expected behavior — happy paths, edge cases, performance. Claude implements against the tests. The tests run. Some fail.</p>
      <p>Paste failures back to Claude. Claude fixes. The next run has fewer failures. Loop until green. The tests become both the spec and the termination condition.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.12 · Iterative Refinement" :num="4" :total="10" />
</Frame>

<!--
Write the suite first. This is the progressive-convergence pattern. You draft a test suite that captures the expected behavior — happy paths, edge cases, performance constraints. Claude implements against the tests. The tests run. Some fail. You paste the failures back to Claude as feedback. Claude fixes. The next run has fewer failures. Loop until green. The tests become both the spec and the termination condition. You know you're done when the suite passes.
-->

---

<!-- SLIDE 5 — TDD pattern -->

<StepSequence
  eyebrow="TDD loop"
  title="Five steps to green"
  :steps="[
    { title: 'Write expected behavior as tests', body: 'Happy paths, edge cases, perf constraints' },
    { title: 'Claude implements', body: 'Against the failing suite' },
    { title: 'Run tests — share failures', body: 'Concrete assertions, not vibes' },
    { title: 'Claude fixes', body: 'Concrete failures produce concrete fixes' },
    { title: 'Repeat until green', body: 'Deterministic termination condition' },
  ]"
  footerLabel="Lecture 5.12 · Iterative Refinement"
  :footerNum="5"
  :footerTotal="10"
/>

<!--
Five-step loop. Write expected behavior as tests. Claude implements. Run the tests — share the failures. Claude fixes the failures. Repeat until the suite is green. The power is that each iteration is grounded in concrete failure data — not "it still seems wrong" but "test_handle_null_email failed with assertion: expected None, got empty string." Concrete failures produce concrete fixes. The loop terminates deterministically when no tests fail.
-->

---

<!-- SLIDE 6 — Technique 3: interview pattern -->

<Frame>
  <Eyebrow>Technique 3</Eyebrow>
  <SlideTitle>Unfamiliar domain? Have Claude interview you first.</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Surface what you'd otherwise miss">
      <p>Before implementing, ask Claude to surface the considerations — cache invalidation, concurrency edge cases, failure modes, cleanup semantics.</p>
      <p>Claude asks 3-5 clarifying questions. You answer. Now the implementation is grounded in your actual requirements, not Claude's assumptions about what a typical system looks like.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.12 · Iterative Refinement" :num="6" :total="10" />
</Frame>

<!--
Unfamiliar domain? Have Claude interview you first. Before implementing, ask Claude to surface the considerations you'd otherwise miss — cache invalidation strategies, concurrency edge cases, failure modes, cleanup semantics. Claude asks three to five clarifying questions. You answer. Now the implementation is grounded in your actual requirements, not in Claude's assumptions about what a typical system looks like. This is the pattern that saves you from shipping code that looks right and fails in production on a scenario nobody thought to mention.
-->

---

<!-- SLIDE 7 — Interview example -->

<CodeBlockSlide
  eyebrow="Interview pattern"
  title="One-line prompt that unlocks design"
  lang="text"
  :code="interviewPrompt"
  annotation="Implementation that follows is informed — surfaces edge cases before code gets written."
  footerLabel="Lecture 5.12 · Iterative Refinement"
  :footerNum="7"
  :footerTotal="10"
/>

<!--
One-line prompt that unlocks it. "Before implementing, ask me three to five clarifying questions about authentication handling, error recovery, and upstream rate limits." Claude responds with a numbered list of specifics — "What's the retry policy on upstream failures? Do you want jittered backoff? What happens to in-flight requests if the upstream returns a 429?" You answer each one. The implementation that follows is informed — it handles the real edge cases because you surfaced them before any code got written.
-->

---

<!-- SLIDE 8 — Single-message vs sequential -->

<ComparisonTable
  eyebrow="Batch vs sequence"
  title="When to batch fixes"
  :columns="batchColumns"
  :rows="batchRows"
  footerLabel="Lecture 5.12 · Iterative Refinement"
  :footerNum="8"
  :footerTotal="10"
/>

<!--
Last piece — when to batch versus sequence. If issues interact — fixing one affects the others, or the issues share root cause — batch them in a single message so Claude can see the whole picture and fix coherently. If issues are independent — a type error here, a missing null check there, unrelated files — sequential is simpler. One at a time. Cleaner diffs, easier review. The test is the dependency structure. Interacting equals batched. Independent equals sequential.
-->

---

<!-- SLIDE 9 — Exam framing -->

<Frame>
  <Eyebrow>On the exam</Eyebrow>
  <SlideTitle>Map the failure mode to the technique.</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Three failure modes, three techniques">
      <p><strong>"Vague spec → inconsistent output"</strong> → concrete examples.</p>
      <p><strong>"Unfamiliar domain → need design considerations surfaced"</strong> → interview pattern.</p>
      <p><strong>"Known behavior → need convergence"</strong> → test-driven iteration.</p>
      <p>Almost-right trap: the exam might offer "write more detailed prose" as a distractor for examples. Prose isn't the fix. Examples are.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.12 · Iterative Refinement" :num="9" :total="10" />
</Frame>

<!--
On the exam, the failure mode tells you the technique. "Vague spec leading to inconsistent output" maps to concrete examples. "Unfamiliar domain, need design considerations surfaced" maps to interview pattern. "Known behavior, need to converge on a correct implementation" maps to test-driven iteration. Three failure modes, three techniques. Almost-right traps appear here — the exam might offer you "write more detailed prose" as a distractor for the examples technique. Prose isn't the fix. Examples are.
-->

---

<!-- SLIDE 10 — Closing -->

<Frame bg="var(--mint-100)">
  <Eyebrow>Takeaways</Eyebrow>
  <SlideTitle>Three failure modes. Three named techniques.</SlideTitle>
  <div style="margin-top: 48px; display: grid; grid-template-columns: 1fr 1fr; gap: 32px;">
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">01</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Examples for vague.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">2-3 input/output pairs beat 10 sentences of prose.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">02</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">TDD for convergence.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Write the suite, paste failures, iterate until green.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">03</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Interview for unknown.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Have Claude surface considerations before implementation.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">04</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Next &mdash; 5.13.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">CI/CD integration. Three flags. Sample Q10 answer.</div>
    </div>
  </div>
</Frame>

<!--
Three techniques, three failure modes. Examples for vague specs — two or three input-output pairs beat ten sentences of prose. TDD for convergence — write the suite, paste failures, iterate until green. Interview for unfamiliar domains — have Claude surface considerations before implementation. Batch interacting issues, sequence independent ones. Task 3.5 in the exam guide covers all four patterns. Next lecture — 5.13 — we shift to CI/CD integration. Three flags you need to know, one of which is Sample Question 10 answer.
-->
