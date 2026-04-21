---
theme: default
title: "Lecture 5.13: Claude Code in CI/CD"
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
const pFlag = `# Non-interactive mode — required for CI
claude -p "Analyze this PR for security issues"

# -p tells Claude Code to:
# 1. Process the prompt
# 2. Write result to stdout
# 3. Exit
#
# No interactive prompts. No waiting for stdin.
`

const ciInvocation = `# Production CI call — three flags together
claude -p "Review this PR for security issues per standards in CLAUDE.md" \\
  --output-format json \\
  --json-schema ./review-schema.json

# -p              : non-interactive
# --output-format : machine-parseable JSON
# --json-schema   : enforced shape, no drift
`
</script>

<!-- SLIDE 1 — Cover -->

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div style="flex: 1; display: flex; flex-direction: column; justify-content: center;">
    <div style="font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px;">
      Domain 3 &middot; Lecture 5.13
    </div>
    <h1 style="font-family: var(--font-display); font-weight: 500; font-size: 108px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1500px;">
      Claude Code in <span style="color: var(--sprout-500);">CI/CD</span>
    </h1>
    <div style="font-family: var(--font-display); font-size: 44px; color: var(--mint-200); margin-top: 40px; font-weight: 400; max-width: 1200px; line-height: 1.3;">
      <code style="color: var(--sprout-500);">-p</code> · <code style="color: var(--sprout-500);">--output-format json</code> · <code style="color: var(--sprout-500);">--json-schema</code>
    </div>
  </div>
</Frame>

<!--
Three flags. Three jobs. `-p` makes Claude Code non-interactive. `--output-format json` makes the output machine-parseable. `--json-schema` enforces the structure. Without `-p`, the CI job hangs forever. This is Sample Question 10 — know the distractors cold.
-->

---

<!-- SLIDE 2 — The hanging job -->

<BigQuote
  lead="Sample Q10"
  quote="Pipeline calls <code>claude &quot;...analyze...&quot;</code> and waits forever. <em>The job never exits.</em>"
  attribution="The job nobody can debug because it just sits there"
/>

<!--
"Pipeline calls claude, quote, analyze this PR, close quote, and waits forever. The job never exits." That's Sample Question 10. It's the job nobody can debug because it just sits there. Claude Code is waiting for interactive input — a prompt the pipeline can't answer. Minutes pass. Hours pass. The runner eventually times out. The fix is one flag, but you have to know it.
-->

---

<!-- SLIDE 3 — The -p flag -->

<CodeBlockSlide
  eyebrow="The -p flag"
  title="-p for non-interactive"
  lang="bash"
  :code="pFlag"
  annotation="Without -p, you will have hanging jobs. This is the single most important flag for automation."
  footerLabel="Lecture 5.13 · Claude Code in CI/CD"
  :footerNum="3"
  :footerTotal="10"
/>

<!--
`-p` means print. Also called `--print`. You invoke `claude -p "Analyze this PR for security issues"`. The flag tells Claude Code to process the prompt, write the result to stdout, and exit. No interactive prompts. No waiting for stdin. No surprises. It's the documented way to run Claude Code in non-interactive mode, and it's exactly what CI pipelines need. One flag. Job runs to completion. Nothing hangs. This is the single most important thing to know about running Claude Code in automated environments — without `-p`, you will have hanging jobs.
-->

---

<!-- SLIDE 4 — --output-format json -->

<Frame>
  <Eyebrow>--output-format json</Eyebrow>
  <SlideTitle>Machine-parseable output.</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Why JSON instead of prose">
      <p>You want to post findings as inline PR comments, track review counts in a metrics database, or route output to downstream jobs.</p>
      <p>Raw text doesn't work — you can't programmatically extract "which file, which line, what severity" from prose reliably.</p>
      <p><code>--output-format json</code> turns Claude's response into a structured blob your pipeline can parse with <code>jq</code>, Python, or anything else that reads JSON.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.13 · Claude Code in CI/CD" :num="4" :total="10" />
</Frame>

<!--
Now you want the output to be parseable by your pipeline — you want to post findings as inline PR comments, or track review counts in a metrics database, or route output to downstream jobs. Raw text doesn't work — you can't programmatically extract "which file, which line, what severity" from prose reliably. `--output-format json` turns Claude's response into a structured JSON blob your pipeline can parse with standard tools. `jq`, `Python`, anything that reads JSON.
-->

---

<!-- SLIDE 5 — --json-schema -->

<Frame>
  <Eyebrow>--json-schema</Eyebrow>
  <SlideTitle>Enforced shape. No drift.</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Schema is the contract">
      <p>JSON is structured, but shape can still drift — fields get renamed, nesting changes, optional fields appear and disappear.</p>
      <p>Pair <code>--output-format json</code> with <code>--json-schema</code> and hand Claude a JSON schema file that enforces a specific shape. Output must match the schema.</p>
      <p>Your pipeline knows exactly what fields to expect, because the schema is the contract. No more "Claude's output shape changed and my parser broke."</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.13 · Claude Code in CI/CD" :num="5" :total="10" />
</Frame>

<!--
One more step. JSON is structured, but the shape can still drift — fields get renamed, nesting changes, optional fields appear and disappear. Pair `--output-format json` with `--json-schema` and you hand Claude a JSON schema file that enforces a specific shape. Output must match the schema. Your pipeline knows exactly what fields to expect, because the schema is the contract. No more "oh, Claude's output shape changed and my parser broke."
-->

---

<!-- SLIDE 6 — Full CI invocation -->

<CodeBlockSlide
  eyebrow="All three together"
  title="Production CI call"
  lang="bash"
  :code="ciInvocation"
  annotation="Runs in GitHub Actions, Jenkins, any CI orchestrator. Output is a JSON blob matching your schema."
  footerLabel="Lecture 5.13 · Claude Code in CI/CD"
  :footerNum="6"
  :footerTotal="10"
/>

<!--
Put it all together. A production CI invocation looks like `claude -p "Review this PR for security issues per standards in CLAUDE.md" --output-format json --json-schema ./review-schema.json`. Non-interactive, structured output, enforced shape. This runs inside your GitHub Actions job, or your Jenkins stage, or whatever orchestrator you're using. The output is a JSON blob matching your schema, ready for the next step — posting as PR comments, aggregating into metrics, failing the build on critical findings.
-->

---

<!-- SLIDE 7 — CLAUDE.md + CI -->

<Frame>
  <Eyebrow>Context travels to CI</Eyebrow>
  <SlideTitle>Project CLAUDE.md loads in CI too.</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="That's how CI-Claude gets team standards">
      <p>When Claude Code runs in CI, it still loads the project-level CLAUDE.md from the repo. Testing standards, review criteria, fixture conventions — everything the team codified.</p>
      <p>You don't need to reinject context in the prompt. The pipeline picks it up automatically. Task 3.6 calls this out — CLAUDE.md is the mechanism for providing project context to CI-invoked Claude Code.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.13 · Claude Code in CI/CD" :num="7" :total="10" />
</Frame>

<!--
Context travels. When Claude Code runs in CI, it still loads the project-level CLAUDE.md from the repo. That's how you give CI-Claude your testing standards, your review criteria, your fixture conventions — everything the team codified in CLAUDE.md. You don't need to reinject that context as part of the prompt. The pipeline picks it up from the repo automatically. Task 3.6 calls this out — CLAUDE.md is the mechanism for providing project context to CI-invoked Claude Code.
-->

---

<!-- SLIDE 8 — Session isolation -->

<Frame>
  <Eyebrow>Session isolation</Eyebrow>
  <SlideTitle>Review runs in a fresh session — by default.</SlideTitle>
  <div style="margin-up: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="CI naturally isolates">
      <p>Every CI run is a fresh session — no memory of previous runs, no carryover from the developer's interactive session.</p>
      <p>The CI-Claude has no idea how the code got written — it just sees the diff and the project context. That's the architecture you want for reliable review.</p>
      <p>Covered in depth in 5.14 — next lecture.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.13 · Claude Code in CI/CD" :num="8" :total="10" />
</Frame>

<!--
One more piece — when CI runs Claude, it's a fresh session. That matters. The code that was just generated in a developer's interactive session has all that reasoning baggage. CI gets a clean slate. That's a feature, not a bug — independent review is stronger than self-review. We cover this in depth in the next lecture, 5.14. For now, know that fresh-session review is baked into how CI works.
-->

---

<!-- SLIDE 9 — Exam framing -->

<Frame>
  <Eyebrow>Sample Q10 — memorize the distractors</Eyebrow>
  <SlideTitle>-p is the answer. Three distractors are fictional.</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="The four options">
      <p><strong>Correct:</strong> <code>-p</code> flag.</p>
      <p><strong>Distractor 1:</strong> <code>CLAUDE_HEADLESS=true</code> — doesn't exist, fictional env var.</p>
      <p><strong>Distractor 2:</strong> <code>&lt; /dev/null</code> redirect — Unix workaround that doesn't address Claude Code's syntax.</p>
      <p><strong>Distractor 3:</strong> <code>--batch</code> flag — doesn't exist either.</p>
      <p>Those three are designed to look plausible to someone guessing. Don't guess.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.13 · Claude Code in CI/CD" :num="9" :total="10" />
</Frame>

<!--
Sample Question 10 — memorize the distractor list. The correct answer is `-p`. The distractors: `CLAUDE_HEADLESS=true` — doesn't exist, fictional environment variable. `< /dev/null` redirect — Unix workaround that doesn't address Claude Code's syntax. `--batch` flag — doesn't exist either. Those three are designed to look plausible to someone who's guessing. Don't guess. `-p` is the answer. Know the three wrong options as firmly as you know the right one — you'll see them in distractor banks on other questions too.
-->

---

<!-- SLIDE 10 — Closing -->

<Frame bg="var(--mint-100)">
  <Eyebrow>Takeaways</Eyebrow>
  <SlideTitle>Three flags. Three jobs.</SlideTitle>
  <div style="margin-top: 48px; display: grid; grid-template-columns: 1fr 1fr; gap: 32px;">
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">01</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">-p = non-interactive.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Prevents hangs. Without it, CI waits forever.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">02</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">--output-format json.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Machine-parseable. Pipelines read with jq or standard tools.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">03</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">--json-schema.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Enforced shape. Schema is the contract. No drift.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">04</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Next &mdash; 5.14.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Session isolation for independent review — why fresh-session beats self-review.</div>
    </div>
  </div>
</Frame>

<!--
`-p` for non-interactive, prevents hangs. `--output-format json` for machine-parseable, gives the pipeline something to work with. `--json-schema` for enforced shape, prevents drift. CLAUDE.md still loads in CI so your team's standards ship automatically. `CLAUDE_HEADLESS`, `--batch`, and `< /dev/null` are all distractors on Sample Q10 — memorize them. Next lecture — 5.14 — goes deep on why fresh-session review beats self-review, and how that shapes CI architecture.
-->
