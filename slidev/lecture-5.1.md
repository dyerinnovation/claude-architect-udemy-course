---
theme: default
title: "Lecture 5.1: The CLAUDE.md Configuration Hierarchy"
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
const hierarchyColumns = ['Path', 'Shared?']
const hierarchyRows = [
  { label: 'User', cells: ['~/.claude/CLAUDE.md', 'No — personal'] },
  { label: 'Project', cells: ['./CLAUDE.md or .claude/CLAUDE.md', 'Yes — via VCS'] },
  { label: 'Directory', cells: ['subdir/CLAUDE.md', 'Yes — scoped to subtree'] },
]

const loadOrderSteps = [
  { label: 'User-level loads first', sublabel: 'baseline from ~/.claude/' },
  { label: 'Project-level overrides/extends', sublabel: 'team layer from repo' },
  { label: 'Directory-level loads last', sublabel: 'only when editing in subtree' },
]
</script>

<!-- SLIDE 1 — Cover -->

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div style="flex: 1; display: flex; flex-direction: column; justify-content: center;">
    <div style="font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px;">
      Domain 3 &middot; Lecture 5.1
    </div>
    <h1 style="font-family: var(--font-display); font-weight: 500; font-size: 108px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1500px;">
      The <span style="color: var(--sprout-500);">CLAUDE.md</span><br/>Configuration Hierarchy
    </h1>
    <div style="font-family: var(--font-display); font-size: 44px; color: var(--mint-200); margin-top: 40px; font-weight: 400; max-width: 1200px; line-height: 1.3;">
      Three levels, three purposes, one very common bug.
    </div>
  </div>
</Frame>

<!--
Welcome to Section 5 — Domain 3 — Claude Code Configuration. Twenty percent of the exam lives here, tied with Domain 4 as the second-largest block after the agentic-loop domain. This first lecture is the foundation for everything that follows in this section. Three levels of CLAUDE.md. Three purposes. One very common bug that the exam tests literally.
-->

---

<!-- SLIDE 2 — Three levels -->

<ComparisonTable
  eyebrow="The hierarchy"
  title="CLAUDE.md hierarchy"
  :columns="hierarchyColumns"
  :rows="hierarchyRows"
  footerLabel="Lecture 5.1 · CLAUDE.md Hierarchy"
  :footerNum="2"
  :footerTotal="10"
/>

<!--
Here's the hierarchy. User-level sits at `~/.claude/CLAUDE.md`. Project-level sits at `./CLAUDE.md` — or `.claude/CLAUDE.md` inside the repo. Directory-level is a `CLAUDE.md` dropped into a subdirectory of your project. Three levels, three scopes. User-level is personal — it lives in your home directory and nobody else on your team sees it. Project-level ships with the repo via version control. Directory-level is scoped to its subtree — it loads when Claude is working on files under that directory. Memorize this table. The exam will hand you a scenario that hinges on which level a file should live in.
-->

---

<!-- SLIDE 3 — Load order -->

<FlowDiagram
  eyebrow="How they merge"
  title="Load order — user, then project, then directory"
  :steps="loadOrderSteps"
  footerLabel="Lecture 5.1 · CLAUDE.md Hierarchy"
  :footerNum="3"
  :footerTotal="10"
/>

<!--
Load order matters. User-level loads first. Project-level loads next, and it can extend or override what the user-level said. Directory-level loads last — but only when Claude is actually editing files in that subtree. The mental model is: user is the baseline, project is the team layer, directory is the scope-specific layer. If you've worked with git config — `--global`, `--local`, per-directory — this should feel familiar. Same idea, different surface.
-->

---

<!-- SLIDE 4 — User-level -->

<Frame>
  <Eyebrow>User level</Eyebrow>
  <SlideTitle>~/.claude/CLAUDE.md — personal, never shared.</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Personal preferences, machine-local notes">
      <p>Lives at <code>~/.claude/CLAUDE.md</code>. NOT shared. Your own coding preferences, notes about your local machine, the test runner flags nobody else uses.</p>
      <p>If you've written detailed instructions for Claude and they live in your home directory, nobody else on your team benefits. They're invisible outside your machine. This is the classic new-hire onboarding bug.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.1 · CLAUDE.md Hierarchy" :num="4" :total="10" />
</Frame>

<!--
User-level is for you. Personal coding preferences. Notes about your local machine. Maybe the fact that you use a particular test runner flag nobody else uses. It lives at `~/.claude/CLAUDE.md`, and it never ships. This is the level people get wrong. If you've written detailed instructions for Claude and they live in your home directory, nobody else on your team benefits from them. They're invisible outside your machine.
-->

---

<!-- SLIDE 5 — Project-level -->

<Frame>
  <Eyebrow>Project level</Eyebrow>
  <SlideTitle>./CLAUDE.md — the team shared file.</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="do" title="The shared one — commit it">
      <p>Coding standards. Testing conventions. Project architecture context. Lives at <code>./CLAUDE.md</code> in the repo root or <code>.claude/CLAUDE.md</code> — and you commit it.</p>
      <p>When a teammate clones the repo, they get your CLAUDE.md for free. That's the whole point of project-level — it turns Claude configuration into a team artifact.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.1 · CLAUDE.md Hierarchy" :num="5" :total="10" />
</Frame>

<!--
Project-level is the shared one. This is where team coding standards live. Testing conventions. The architecture summary you want every new hire's Claude session to understand. It lives at `./CLAUDE.md` in the repo root or `.claude/CLAUDE.md` — and you commit it. When a teammate clones the repo, they get your CLAUDE.md for free. That's the whole point of project-level — it turns Claude configuration into a team artifact.
-->

---

<!-- SLIDE 6 — Directory-level -->

<Frame>
  <Eyebrow>Directory level</Eyebrow>
  <SlideTitle>subdir/CLAUDE.md — scoped rules.</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Loads only in its subtree">
      <p>Good for "the API directory has different rules." Drop a <code>CLAUDE.md</code> in <code>/api</code> with those specifics. When Claude works on files under <code>/api</code>, the directory-level file loads on top of the project-level one.</p>
      <p>Files outside <code>/api</code> never see it. This is how you keep conventions narrow without bloating your root CLAUDE.md.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.1 · CLAUDE.md Hierarchy" :num="6" :total="10" />
</Frame>

<!--
Directory-level is for scope-specific rules. Say your repo has an `/api` directory with conventions that differ from the rest of the codebase — different error-handling style, different logging pattern, different auth flow. Drop a `CLAUDE.md` in `/api` with those specifics. When Claude works on files under `/api`, the directory-level file loads on top of the project-level one. Files outside `/api` — they don't see it. This is how you keep conventions narrow without bloating your root CLAUDE.md.
-->

---

<!-- SLIDE 7 — Diagnostic -->

<Frame>
  <Eyebrow>Diagnostic</Eyebrow>
  <SlideTitle>The #1 bug on every team.</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="warn" title="&quot;Why doesn't Claude know our conventions?&quot;">
      <p>Check if the file is in <code>~/.claude/</code> instead of the repo. Someone wrote great instructions — in their home directory. The new hire they're onboarding gets none of it.</p>
      <p>The fix is one move: move the file into the repo's <code>.claude/</code> directory, commit, push. Use the <code>/memory</code> command to confirm what's loaded in the current session. When behavior diverges between teammates, <code>/memory</code> is the first move.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.1 · CLAUDE.md Hierarchy" :num="7" :total="10" />
</Frame>

<!--
Here's the number-one bug I see on teams. Someone says "Claude doesn't know our conventions." You look, and their CLAUDE.md is in `~/.claude/` — their home directory — not the repo. They've spent two weeks writing great instructions that only they can see. The new hire they're onboarding gets none of it. The fix is one move — move the file into the repo's `.claude/` directory, commit, push. Use the `/memory` command to confirm what's loaded in the current session. We'll cover `/memory` in depth in 5.15. Until then, just know it's your diagnostic tool. When behavior diverges between teammates, `/memory` is the first move — it tells you exactly which files Claude can see.
-->

---

<!-- SLIDE 8 — Exam framing -->

<Frame>
  <Eyebrow>On the exam</Eyebrow>
  <SlideTitle>Scenario 2 — wrong hierarchy level.</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="The question pattern">
      <p>"A new team member clones the repo but Claude doesn't seem to know the team's conventions." The answer is always the hierarchy level. Conventions are living at user-level instead of project-level.</p>
      <p>"Update the CLAUDE.md" is the almost-right distractor — editing a user-level file doesn't help the teammate. The scope issue is primary. The content issue is secondary.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.1 · CLAUDE.md Hierarchy" :num="8" :total="10" />
</Frame>

<!--
On the exam, this shows up as Scenario 2 — Code Generation with Claude Code. The question pattern: "A new team member clones the repo but Claude doesn't seem to know the team's conventions. What's wrong?" The answer is always the hierarchy level. The conventions are living at user-level on the author's machine instead of project-level in the repo. Almost-right is the whole trap of this exam — "update the CLAUDE.md" is a distractor if the file is at the wrong level to begin with. The distractor looks like a valid fix because editing CLAUDE.md is usually how you fix incorrect conventions. But here the file being edited is invisible to the teammate. You can update it all you want — nothing changes for anyone else. The scope issue is primary. The content issue is secondary.
-->

---

<!-- SLIDE 9 — Continuity -->

<ConceptHero
  eyebrow="Continuity"
  leadLine="Scenario 2 — Code Generation with Claude Code"
  concept="From demo to team."
  supportLine="This is the first lecture that turns a demo into a team workflow. Every other piece of Domain 3 — slash commands, skills, rules — follows the same user-versus-project split."
  accent="var(--teal-600)"
  footerLabel="Lecture 5.1 · CLAUDE.md Hierarchy"
  :footerNum="9"
  :footerTotal="10"
/>

<!--
Scenario 2 — Code Generation with Claude Code — this is the first lecture that turns a Claude Code demo into a team workflow. The hierarchy is where that starts. Every other piece of Domain 3 — slash commands, skills, rules — follows the same user-versus-project split you just learned.
-->

---

<!-- SLIDE 10 — Closing -->

<Frame bg="var(--mint-100)">
  <Eyebrow>Takeaways</Eyebrow>
  <SlideTitle>Three levels. Know the split cold.</SlideTitle>
  <div style="margin-top: 48px; display: grid; grid-template-columns: 1fr 1fr; gap: 32px;">
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600; letter-spacing: 0.08em;">01</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">User is personal.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Lives at <code>~/.claude/CLAUDE.md</code>. Machine-local. Nobody else sees it.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600; letter-spacing: 0.08em;">02</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Project is team.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;"><code>./CLAUDE.md</code> or <code>.claude/CLAUDE.md</code> — committed, shared via VCS.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600; letter-spacing: 0.08em;">03</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Directory is scoped.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Drop one in any subdirectory. Loads only when editing inside its subtree.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600; letter-spacing: 0.08em;">04</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Next &mdash; 5.2.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">What Gets Shared via Version Control and What Doesn't.</div>
    </div>
  </div>
</Frame>

<!--
Three levels. User is personal, at `~/.claude/CLAUDE.md`. Project is team, shared via VCS, at `./CLAUDE.md` or `.claude/CLAUDE.md`. Directory is scoped to a subtree, dropped into any subdirectory where you want scope-specific rules. The #1 bug is writing instructions at user level and assuming teammates see them. They don't. Hold onto that — it's the anchor for this whole section. Next up — 5.2 — we go deeper on what you commit and what you gitignore, because "share it" has a second half nobody talks about, and it's where the second literal exam-test pair shows up.
-->
