---
theme: default
title: "Lecture 5.15: /memory and /compact"
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
const memoryOutput = `> /memory

Loaded memory files:

  User:    /Users/jordan/.claude/CLAUDE.md
  Project: /repo/.claude/CLAUDE.md
  Rules:   /repo/.claude/rules/testing.md
           /repo/.claude/rules/api-conventions.md
  Directory: (none matched current path)

# 4 files loaded. Check against expected list.
`

const memoryUseCases = [
  { label: 'New teammate doesn\u2019t have your conventions', detail: 'Check whether the project CLAUDE.md made it into their session' },
  { label: 'Different behavior across sessions', detail: 'Maybe one teammate has a personal CLAUDE.md overriding the team one' },
  { label: 'Adding a new rule and want to confirm it loads', detail: 'Verify the glob matched and frontmatter parsed' },
]

const compactWhen = [
  { label: 'Session is long and context fills', detail: 'Slower responses, context-pressure warnings, waiting longer for each turn' },
  { label: 'You have a natural end of phase', detail: 'After a design review, before implementation; after refactor, before tests' },
  { label: 'Want a clean slate + history summary', detail: 'Keep the critical outcomes and decisions, drop verbose intermediate work' },
]
</script>

<!-- SLIDE 1 — Cover -->

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div style="flex: 1; display: flex; flex-direction: column; justify-content: center;">
    <div style="font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px;">
      Domain 3 &middot; Lecture 5.15
    </div>
    <h1 style="font-family: var(--font-display); font-weight: 500; font-size: 108px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1500px;">
      <span style="color: var(--sprout-500);">/memory</span> and <span style="color: var(--sprout-500);">/compact</span>
    </h1>
    <div style="font-family: var(--font-display); font-size: 44px; color: var(--mint-200); margin-top: 40px; font-weight: 400; max-width: 1200px; line-height: 1.3;">
      Two commands. Two completely different jobs. Don't swap them.
    </div>
  </div>
</Frame>

<!--
Two commands. Two completely different jobs. `/memory` tells you what CLAUDE.md files are loaded — it's your diagnostic. `/compact` reclaims context during long sessions — it's your escape hatch. The exam tests them as a pair specifically so you don't swap them. Don't swap them.
-->

---

<!-- SLIDE 2 — /memory — diagnostic -->

<Frame>
  <Eyebrow>/memory — diagnostic</Eyebrow>
  <SlideTitle>What CLAUDE.md files are loaded right now?</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Your first move when something's wrong">
      <p>Lists the CLAUDE.md files Claude can see in the current session — user, project, any directory-level files that matched.</p>
      <p>"Why doesn't Claude know X?" → run <code>/memory</code>, look at the paths, see if your file is there.</p>
      <p>If it's not — the file isn't where you think it is. Probably sitting at user-level instead of project-level. Ten seconds of diagnostic saves an hour of "why isn't this working."</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.15 · /memory and /compact" :num="2" :total="9" />
</Frame>

<!--
What's loaded? That's what `/memory` answers. It lists the CLAUDE.md files Claude can see in the current session — user-level, project-level, any directory-level files that matched. It's your first move when someone says "why doesn't Claude know X?" Run `/memory`, look at the paths, see if the file you expected is in the list. If it's not, the file isn't where you think it is — probably sitting at user-level instead of project-level, the #1 bug we covered in 5.1. Ten seconds of diagnostic saves you an hour of "why isn't this working."
-->

---

<!-- SLIDE 3 — /memory output -->

<CodeBlockSlide
  eyebrow="/memory output"
  title="A simple list of paths"
  lang="text"
  :code="memoryOutput"
  annotation="Scan, verify your file is there, confirm Claude can see it. Done."
  footerLabel="Lecture 5.15 · /memory and /compact"
  :footerNum="3"
  :footerTotal="9"
/>

<!--
The output is a simple list. User-level path at the top — `~/.claude/CLAUDE.md` if it exists. Project-level path next — `./CLAUDE.md` or `.claude/CLAUDE.md` from your repo. Directory-level paths after that, if any match the current working context. Each entry is a concrete file path. You scan the list, you verify the file you wrote is there, and you confirm Claude can actually see it. Diagnostic done. Takes ten seconds.
-->

---

<!-- SLIDE 4 — Use case -->

<BulletReveal
  eyebrow="/memory use cases"
  title="Run /memory when..."
  :bullets="memoryUseCases"
  footerLabel="Lecture 5.15 · /memory and /compact"
  :footerNum="4"
  :footerTotal="9"
/>

<!--
Run `/memory` when a new teammate says "Claude doesn't seem to have our conventions" — you're checking whether the project CLAUDE.md made it into their session. Run it when behavior differs across sessions — maybe one teammate has a personal CLAUDE.md overriding the team one, and the override explains the divergence. Run it when you add a new rule and want to confirm it actually loads — verifies the glob matched, the frontmatter parsed, everything works. It's a debugging reflex, not a ceremony. First move on any "something's wrong with Claude's context" report.
-->

---

<!-- SLIDE 5 — /compact — context reclamation -->

<Frame>
  <Eyebrow>/compact — context reclamation</Eyebrow>
  <SlideTitle>Long session, context filling. Escape hatch.</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Condense older turns into a summary">
      <p>Claude has a context window. Once it's mostly full, responses get slower and more expensive, and older turns start dropping without your control.</p>
      <p><code>/compact</code> condenses older turns into a summary — keeps critical outcomes and decisions, drops the verbose intermediate work. Frees tokens. You trade loss of detail for headroom.</p>
      <p>Task 5.4 in the exam guide covers this — memory management is the surface, <code>/compact</code> is the tool.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.15 · /memory and /compact" :num="5" :total="9" />
</Frame>

<!--
Different job entirely. `/compact` is for long sessions where context is filling up. Claude has a context window, and once it's mostly full, responses get slower and more expensive, and older turns start getting dropped without your control. `/compact` condenses the older turns into a summary — keeps the critical outcomes and decisions, drops the verbose intermediate work. Frees tokens. You trade loss of detail for headroom to keep going. Task 5.4 in the exam guide covers this — memory management is the surface, `/compact` is the tool.
-->

---

<!-- SLIDE 6 — When to /compact -->

<BulletReveal
  eyebrow="/compact use cases"
  title="Compact when..."
  :bullets="compactWhen"
  footerLabel="Lecture 5.15 · /memory and /compact"
  :footerNum="6"
  :footerTotal="9"
/>

<!--
Compact when the session is long and context is filling — the signs are slower responses, the harness warning about context pressure, or you noticing yourself waiting longer for each turn. Compact at natural phase boundaries — after a design review, before implementation. After a refactor, before tests. The transition point is a good place because there's a clean summary to hand off. Don't compact mid-decision — you lose the exact details that are still in flight.
-->

---

<!-- SLIDE 7 — Anti-pattern -->

<AntiPatternSlide
  eyebrow="Anti-pattern"
  title="Don't /compact mid-decision"
  badExample="# Mid-discussion: picking one of three approaches
# Context is getting tight
# You panic-compact
# Summary loses nuance of the three options
# Now you're re-exploring ground already covered"
  whyItFails="You compact when the critical state is exactly what needs to be preserved."
  fixExample="# Finish the decision first
# Commit to an approach
# THEN compact
# Summary carries the decision forward cleanly
# Fine details of unused options don't come back"
  lang="text"
  footerLabel="Lecture 5.15 · /memory and /compact"
  :footerNum="7"
  :footerTotal="9"
/>

<!--
Bad: compact right when critical state is still in motion. You're mid-discussion about which of three approaches to take, context is getting tight, you panic-compact, and the summary loses the nuance of the three options. Now you're re-exploring ground you already covered. Good: compact at phase boundaries. Finish the decision, commit to an approach, then compact. The new session state carries the decision forward cleanly without losing the fine details of options you never needed to revisit.
-->

---

<!-- SLIDE 8 — Exam framing -->

<Frame>
  <Eyebrow>On the exam</Eyebrow>
  <SlideTitle>The swap is the trap.</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Different jobs — don't confuse them">
      <p><strong>"Which memory files are loaded?"</strong> → <code>/memory</code>.</p>
      <p><strong>"Context filled during long exploration"</strong> → <code>/compact</code>.</p>
      <p>Both names sound like memory management, but they do totally different jobs. Diagnostic scenario = <code>/memory</code>. Context-pressure scenario = <code>/compact</code>.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.15 · /memory and /compact" :num="8" :total="9" />
</Frame>

<!--
On the exam, the swap is the trap. "Which memory files are loaded?" maps to `/memory`. "Context filled during a long exploration session" maps to `/compact`. If a question describes a diagnostic scenario, the answer is `/memory`. If it describes a context-pressure scenario, the answer is `/compact`. Don't pick the wrong command because both names sound like memory management. They do totally different jobs.
-->

---

<!-- SLIDE 9 — Closing -->

<Frame bg="var(--mint-100)">
  <Eyebrow>Section 5 wrap</Eyebrow>
  <SlideTitle>Domain 3 — you've just covered the full surface.</SlideTitle>
  <div style="margin-top: 48px; display: grid; grid-template-columns: 1fr 1fr; gap: 32px;">
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">01</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">/memory is diagnostic.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Lists loaded CLAUDE.md files. First move on "why doesn't Claude know X?"</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">02</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">/compact reclaims.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Condenses older turns. Trade detail for headroom at phase boundaries.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">03</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Domain 3 = 20%.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Full surface covered — hierarchy, sharing, imports, rules, skills, plan mode, CI.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">04</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Next &mdash; Section 6.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Domain 4 — Prompt Engineering & Structured Output. Another 20%.</div>
    </div>
  </div>
</Frame>

<!--
`/memory` lists loaded files — your diagnostic. `/compact` condenses old turns — your context escape hatch. Section 5 wrap: Domain 3 is twenty percent of your exam. You've just covered the full surface — hierarchy, sharing, imports, rules, globs, commands, skills, skill frontmatter, plan mode, Explore subagent, iteration, CI flags, session isolation, memory commands. Next up, Section 6 — Domain 4 — Prompt Engineering and Structured Output. Another twenty percent. Let's keep going.
-->
