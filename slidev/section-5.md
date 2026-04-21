---
theme: default
title: "Section 5: Domain 3 - Claude Code Configuration & Workflows"
info: |
  Claude Certified Architect – Foundations
  Section 5: Domain 3 - Claude Code Configuration & Workflows (20%)
highlighter: shiki
transition: slide-left
mdc: true
canvasWidth: 1920
aspectRatio: 16/9
---

<style>
@import './design-system.css';
</style>

<!-- LECTURE 5.1 — The CLAUDE.md Configuration Hierarchy -->

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

<script setup>
const hierarchyColumns = ['Path', 'Shared?']
const hierarchyRows = [
  { label: 'User', cells: ['~/.claude/CLAUDE.md', 'No -- personal'] },
  { label: 'Project', cells: ['./CLAUDE.md or .claude/CLAUDE.md', 'Yes -- via VCS'] },
  { label: 'Directory', cells: ['subdir/CLAUDE.md', 'Yes -- scoped to subtree'] },
]
</script>

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

<script setup>
const loadOrderSteps = [
  { label: 'User-level loads first', sublabel: 'baseline from ~/.claude/' },
  { label: 'Project-level overrides/extends', sublabel: 'team layer from repo' },
  { label: 'Directory-level loads last', sublabel: 'only when editing in subtree' },
]
</script>

<FlowDiagram
  eyebrow="How they merge"
  title="Load order -- user, then project, then directory"
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
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Personal preferences, machine-local notes">
      <p>Lives at <code>~/.claude/CLAUDE.md</code>. NOT shared. Your own coding preferences, notes about your local machine, the test runner flags nobody else uses.</p>
      <p>If you've written detailed instructions for Claude and they live in your home directory, nobody else on your team benefits. They're invisible outside your machine. This is the classic new-hire onboarding bug.</p>
    </CalloutBox>
  </div>
  </v-clicks>
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
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="do" title="The shared one -- commit it">
      <p>Coding standards. Testing conventions. Project architecture context. Lives at <code>./CLAUDE.md</code> in the repo root or <code>.claude/CLAUDE.md</code> — and you commit it.</p>
      <p>When a teammate clones the repo, they get your CLAUDE.md for free. That's the whole point of project-level — it turns Claude configuration into a team artifact.</p>
    </CalloutBox>
  </div>
  </v-clicks>
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
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Loads only in its subtree">
      <p>Good for "the API directory has different rules." Drop a <code>CLAUDE.md</code> in <code>/api</code> with those specifics. When Claude works on files under <code>/api</code>, the directory-level file loads on top of the project-level one.</p>
      <p>Files outside <code>/api</code> never see it. This is how you keep conventions narrow without bloating your root CLAUDE.md.</p>
    </CalloutBox>
  </div>
  </v-clicks>
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
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="warn" title="&quot;Why doesn't Claude know our conventions?&quot;">
      <p>Check if the file is in <code>~/.claude/</code> instead of the repo. Someone wrote great instructions — in their home directory. The new hire they're onboarding gets none of it.</p>
      <p>The fix is one move: move the file into the repo's <code>.claude/</code> directory, commit, push. Use the <code>/memory</code> command to confirm what's loaded in the current session. When behavior diverges between teammates, <code>/memory</code> is the first move.</p>
    </CalloutBox>
  </div>
  </v-clicks>
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
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="The question pattern">
      <p>"A new team member clones the repo but Claude doesn't seem to know the team's conventions." The answer is always the hierarchy level. Conventions are living at user-level instead of project-level.</p>
      <p>"Update the CLAUDE.md" is the almost-right distractor — editing a user-level file doesn't help the teammate. The scope issue is primary. The content issue is secondary.</p>
    </CalloutBox>
  </div>
  </v-clicks>
  <SlideFooter label="Lecture 5.1 · CLAUDE.md Hierarchy" :num="8" :total="10" />
</Frame>

<!--
On the exam, this shows up as Scenario 2 — Code Generation with Claude Code. The question pattern: "A new team member clones the repo but Claude doesn't seem to know the team's conventions. What's wrong?" The answer is always the hierarchy level. The conventions are living at user-level on the author's machine instead of project-level in the repo. Almost-right is the whole trap of this exam — "update the CLAUDE.md" is a distractor if the file is at the wrong level to begin with. The distractor looks like a valid fix because editing CLAUDE.md is usually how you fix incorrect conventions. But here the file being edited is invisible to the teammate. You can update it all you want — nothing changes for anyone else. The scope issue is primary. The content issue is secondary.
-->

---

<!-- SLIDE 9 — Continuity -->

<ConceptHero
  eyebrow="Continuity"
  leadLine="Scenario 2 -- Code Generation with Claude Code"
  concept="From demo to team."
  supportLine="This is the first lecture that turns a demo into a team workflow. Every other piece of Domain 3 -- slash commands, skills, rules -- follows the same user-versus-project split."
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

---

<!-- LECTURE 5.2 — What Gets Shared via Version Control and What Doesn't -->

<!-- SLIDE 1 — Cover -->

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div style="flex: 1; display: flex; flex-direction: column; justify-content: center;">
    <div style="font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px;">
      Domain 3 &middot; Lecture 5.2
    </div>
    <h1 style="font-family: var(--font-display); font-weight: 500; font-size: 108px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1500px;">
      What Gets Shared via <span style="color: var(--sprout-500);">Git</span> — and What Doesn't
    </h1>
    <div style="font-family: var(--font-display); font-size: 44px; color: var(--mint-200); margin-top: 40px; font-weight: 400; max-width: 1200px; line-height: 1.3;">
      Two directories. Two intents. The pair Sample Q4 tests literally.
    </div>
  </div>
</Frame>

<!--
Two directories. Two intents. `.claude/` is the team directory — it ships in git. `~/.claude/` is the personal directory — it never leaves your machine. That's the whole rule. This lecture is short because the concept is small, but it's the exact pair the exam tests literally.
-->

---

<!-- SLIDE 2 — Two directories -->

<TwoColSlide
  eyebrow="The split"
  title="Two directories -- two intents"
  leftLabel=".claude/ -- team"
  rightLabel="~/.claude/ -- you"
  footerLabel="Lecture 5.2 · What Gets Shared"
  :footerNum="2"
  :footerTotal="8"
>
  <template #left>
    <p><strong>Shared via VCS.</strong> Tracked by git, pushed to the remote, pulled by every teammate.</p>
    <p>Everything here is a team artifact. Clone the repo and you have it.</p>
  </template>
  <template #right>
    <p><strong>Machine-local.</strong> Personal. Nothing here ever leaves your laptop unless you put it there deliberately.</p>
    <p>Your own preferences, experiments, and scratch space.</p>
  </template>
</TwoColSlide>

<!--
Put the directories side by side. On the left: `.claude/` — the team directory inside your repo root. Everything here is shared via version control — tracked by git, pushed to the remote, pulled by every teammate. On the right: `~/.claude/` — your home directory. Personal. Machine-local. Nothing in here ever leaves your laptop unless you put it there deliberately. These two paths are the vocabulary of the rest of Section 5. Every slash command, every skill, every rule file we discuss has a shared-or-personal variant, and the variant is determined by which of these two directories it lives in. Memorize the pair. You'll see it a dozen times.
-->

---

<!-- SLIDE 3 — What belongs in .claude/ -->

<script setup>
const teamBullets = [
  { label: 'CLAUDE.md', detail: 'The project-level instructions -- the team source of truth' },
  { label: 'commands/', detail: 'Custom slash commands your whole team can invoke by name' },
  { label: 'skills/', detail: 'SKILL.md files Claude triggers automatically via description matching' },
  { label: 'rules/', detail: 'Topic-specific rules with path-based loading' },
  { label: '.mcp.json', detail: 'MCP server configuration shared with every teammate' },
]
</script>

<BulletReveal
  eyebrow=".claude/ -- team-shared"
  title="What belongs in the repo"
  :bullets="teamBullets"
  footerLabel="Lecture 5.2 · What Gets Shared"
  :footerNum="3"
  :footerTotal="8"
/>

<!--
Here's what ships with the repo. `CLAUDE.md` — the project-level instructions from the last lecture, the main source of truth for coding conventions. `commands/` — custom slash commands your whole team can invoke by name. `skills/` — SKILL.md files that Claude triggers automatically based on description matching. `rules/` — the topic-specific rules we cover in 5.4. And `.mcp.json` — MCP server configuration so every teammate connects to the same project-scoped servers. All five of these are team artifacts. They belong in git. When a new hire clones the repo, they should get the team's full Claude configuration without asking anyone for it.
-->

---

<!-- SLIDE 4 — What belongs in ~/.claude/ -->

<script setup>
const personalBullets = [
  { label: 'Personal CLAUDE.md overrides', detail: 'Your preferences on top of team defaults' },
  { label: 'Personal slash commands', detail: "Named differently so they don't collide with team ones" },
  { label: 'Experimental skills', detail: 'Incubator space before you propose them to the team' },
  { label: 'Personal MCP servers', detail: 'Local tools nobody else uses' },
]
</script>

<BulletReveal
  eyebrow="~/.claude/ -- personal"
  title="What stays on your machine"
  :bullets="personalBullets"
  footerLabel="Lecture 5.2 · What Gets Shared"
  :footerNum="4"
  :footerTotal="8"
/>

<!--
Here's what stays on your machine. Personal CLAUDE.md overrides — your own preferences on top of the team defaults, things like "I prefer vim over emacs when Claude drafts edit scripts." Personal slash commands — things like `/my-review-shortcut` that are just for you, named so they don't collide with team commands. Experimental skills you're trying out before proposing them to the team — incubator space, effectively. Personal MCP servers — maybe you've got a local obsidian server or a personal notes tool nobody else uses. These don't belong in the team repo, and they're safe in your home directory. Your personal config lives there and stays there.
-->

---

<!-- SLIDE 5 — Gitignore pattern -->

<script setup>
const gitignoreCode = `# Do NOT do this:
# .claude/            <- hides team config from VCS

# Correct -- only session state and secrets:
.claude/sessions/
.env
**/*.credentials
`
</script>

<CodeBlockSlide
  eyebrow="Subtle but critical"
  title=".gitignore -- only local-session files"
  lang="text"
  :code="gitignoreCode"
  annotation="Don't gitignore .claude/ itself. That's the silent failure mode."
  footerLabel="Lecture 5.2 · What Gets Shared"
  :footerNum="5"
  :footerTotal="8"
/>

<!--
Now the subtle part. Don't gitignore `.claude/` itself. That's the bug. I've seen teams do this because they assumed it was like `.vscode/` or `.idea/` — editor cruft, user-specific settings. It isn't. `.claude/` is your team's Claude configuration — CLAUDE.md, commands, skills, rules, MCP config — and if you gitignore it, you just hid your team's Claude setup from version control. New teammates clone the repo and get nothing. You want it tracked. What you do gitignore is session state — `.claude/sessions/` — because that's per-developer transcript history and bloats the repo. And of course any secret files — `.env`, credentials, API keys — if you've accidentally put them in `.claude/`. Secrets never go in the repo regardless of path. But the directory structure itself stays checked in.
-->

---

<!-- SLIDE 6 — Exam framing -->

<Frame>
  <Eyebrow>On the exam</Eyebrow>
  <SlideTitle>Memorize the pair literally — Sample Q4.</SlideTitle>
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Sample Q4 -- the literal path test">
      <p><code>.claude/commands/</code> means team, shared via VCS. <code>~/.claude/commands/</code> means personal.</p>
      <p>Sample Q4 describes a <code>/review</code> command that should be available to every developer when they clone the repo. The answer is <code>.claude/commands/</code>. The distractor is <code>~/.claude/commands/</code> in every developer's home — plausible, but then nobody else gets it. Know this reflex cold.</p>
    </CalloutBox>
  </div>
  </v-clicks>
  <SlideFooter label="Lecture 5.2 · What Gets Shared" :num="6" :total="8" />
</Frame>

<!--
On the exam, memorize this pair literally. `.claude/commands/` means team, shared via VCS. `~/.claude/commands/` means personal. This literal pair shows up in Sample Question 4 — a `/review` command that should be available to every developer when they clone the repo. The answer is `.claude/commands/` in the project. The distractor is `~/.claude/commands/` in every developer's home directory — plausible, but then nobody else gets it. Know this reflex cold.
-->

---

<!-- SLIDE 7 — Anti-pattern -->

<AntiPatternSlide
  eyebrow="Anti-pattern"
  title="Don't gitignore .claude/"
  badExample='echo ".claude/" >> .gitignore
# Silent failure: team config vanishes from VCS.
# New teammates clone and get nothing.'
  whyItFails="Hides the team's Claude configuration from every future teammate."
  fixExample="# Commit .claude/ in full.
# Gitignore only session state + secrets.
.claude/sessions/
.env"
  lang="bash"
  footerLabel="Lecture 5.2 · What Gets Shared"
  :footerNum="7"
  :footerTotal="8"
/>

<!--
Here's the anti-pattern. Bad: `echo .claude/ >> .gitignore`. You just hid your team's Claude configuration from version control. New teammates clone the repo and get nothing. It's the silent failure mode — nothing breaks visibly, but your team's Claude setup stops propagating. Good: commit `.claude/` in its entirety. Gitignore `.claude/sessions/` if you want to avoid committing session transcripts. Gitignore `.env` or any secret files that happen to live in `.claude/`. That's it. The directory itself stays tracked. New teammates clone, they get the full team configuration, zero setup required.
-->

---

<!-- SLIDE 8 — Closing -->

<Frame bg="var(--mint-100)">
  <Eyebrow>Takeaways</Eyebrow>
  <SlideTitle>Two directories. Two intents.</SlideTitle>
  <div style="margin-top: 48px; display: grid; grid-template-columns: 1fr 1fr; gap: 32px;">
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">01</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Team in the repo.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;"><code>.claude/</code> checked in. Every teammate gets it on clone.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">02</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Personal in home.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;"><code>~/.claude/</code> stays local. Your overrides, your experiments.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">03</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Gitignore sessions + secrets.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Not <code>.claude/</code> itself. That's the silent bug.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">04</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Next &mdash; 5.3.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">The <code>@import</code> syntax for modular CLAUDE.md.</div>
    </div>
  </div>
</Frame>

<!--
Two directories, two intents. If you want your team to have it, `.claude/` in the repo, committed. If it's just for you, `~/.claude/` in your home, machine-local. Don't gitignore the team directory — do gitignore `.claude/sessions/` and secrets. Sample Q4 tests this pair literally. Next up — 5.3 — we tackle what happens when your CLAUDE.md grows past 400 lines and stops being readable. That's where the `@import` syntax earns its keep.
-->

---

<!-- LECTURE 5.3 — @import — Modular CLAUDE.md -->

<!-- SLIDE 1 — Cover -->

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div style="flex: 1; display: flex; flex-direction: column; justify-content: center;">
    <div style="font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px;">
      Domain 3 &middot; Lecture 5.3
    </div>
    <h1 style="font-family: var(--font-display); font-weight: 500; font-size: 108px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1500px;">
      <span style="color: var(--sprout-500);">@import</span> — Modular CLAUDE.md
    </h1>
    <div style="font-family: var(--font-display); font-size: 44px; color: var(--mint-200); margin-top: 40px; font-weight: 400; max-width: 1200px; line-height: 1.3;">
      Each imported file is one concern. One line stops the monolith.
    </div>
  </div>
</Frame>

<!--
CLAUDE.md grows linearly with complexity. Every new convention gets appended. Every new team adds a section. Before long you've got a 400-line file that nobody reads and Claude skims. `@import` is how you stop that.
-->

---

<!-- SLIDE 2 — The problem -->

<BigQuote
  lead="The failure mode"
  quote="CLAUDE.md hit 400 lines. Nobody reads it. <em>Claude skims it.</em>"
  attribution="Every team eventually"
/>

<!--
"CLAUDE.md hit 400 lines. Nobody reads it. Claude skims it." That's the failure mode. Monolithic instructions files rot. New conventions get buried next to old ones. Teams stop reading because they can't find the thing they care about. Claude's attention gets spread across content that isn't relevant to the current task. The fix isn't "write a shorter CLAUDE.md" — the conventions are real. The fix is modularity.
-->

---

<!-- SLIDE 3 — The syntax -->

<script setup>
const importSyntax = `# CLAUDE.md

## Project conventions
...

@import ./docs/testing-standards.md
@import ./docs/api-conventions.md
@import ./docs/deployment.md
`
</script>

<CodeBlockSlide
  eyebrow="One line of syntax"
  title="@import in CLAUDE.md"
  lang="markdown"
  :code="importSyntax"
  annotation="Claude splices the imported file in verbatim at the @import line."
  footerLabel="Lecture 5.3 · @import"
  :footerNum="3"
  :footerTotal="9"
/>

<!--
The syntax is one line. Inside your CLAUDE.md you write `@import ./docs/testing-standards.md` — relative path to another markdown file. Claude loads that file inline at the location of the import, as if the content were spliced in verbatim. You can import from anywhere in the repo — a `docs/` folder, a shared standards directory, a sibling package, even a top-level standards directory that multiple packages reference. Each imported file is its own concern. Testing standards in one file. API conventions in another. Deployment rules in a third. Security practices in a fourth. The CLAUDE.md becomes a table of contents rather than a dumping ground — it says what applies here, and the imported files hold the detail.
-->

---

<!-- SLIDE 4 — When to split -->

<script setup>
const splitBullets = [
  { label: 'Topic is maintained by a different team', detail: 'Testing standards owned by platform eng; API conventions owned by product' },
  { label: 'Only relevant to a subset of work', detail: "Frontend package doesn't need database-migration rules" },
  { label: 'Changes often and noise-floods the main file', detail: 'High churn buried next to stable conventions' },
]
</script>

<BulletReveal
  eyebrow="When to split"
  title="Three signals that earn modularity"
  :bullets="splitBullets"
  footerLabel="Lecture 5.3 · @import"
  :footerNum="4"
  :footerTotal="9"
/>

<!--
Split a section into its own imported file when the topic is maintained by a different team — your testing standards are owned by platform engineering, say, and your API conventions by the product team. Split when the content is only relevant to a subset of work — the frontend package doesn't need database migration rules. Split when the section changes often and noise-floods the main file with churn. Those three signals — different owner, different scope, high change rate — are when modularity pays for itself.
-->

---

<!-- SLIDE 5 — Import tree example -->

<script setup>
const importTreeExample = `# packages/api/CLAUDE.md
@import ../../docs/api-conventions.md
@import ../../docs/testing-standards.md

# packages/frontend/CLAUDE.md
@import ../../docs/react-standards.md
@import ../../docs/testing-standards.md

# packages/infra/CLAUDE.md
@import ../../docs/terraform-standards.md
@import ../../docs/deployment.md
`
</script>

<CodeBlockSlide
  eyebrow="Monorepo pattern"
  title="Package CLAUDE.md with selective imports"
  lang="markdown"
  :code="importTreeExample"
  annotation="Each package maintainer picks the 2-3 standards files that actually apply."
  footerLabel="Lecture 5.3 · @import"
  :footerNum="5"
  :footerTotal="9"
/>

<!--
Here's the pattern in a monorepo. Each package has its own CLAUDE.md, and each one imports selectively. The API package imports `api-conventions.md` and `testing-standards.md`. The frontend package imports `react-standards.md` and `testing-standards.md`. The infra package imports `terraform-standards.md` and `deployment.md`. The maintainer of each package picks the 2–3 standards files that actually apply. The root CLAUDE.md stays high-level — architecture overview, build commands — and the package-level ones pull in what they need.
-->

---

<!-- SLIDE 6 — Alternative: .claude/rules/ -->

<Frame>
  <Eyebrow>Two modular patterns</Eyebrow>
  <SlideTitle>@import vs .claude/rules/ — same goal, different triggers.</SlideTitle>
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Know the distinction">
      <p><code>@import</code> loads <strong>always</strong> — whenever the parent CLAUDE.md loads, the imported file comes with it.</p>
      <p><code>.claude/rules/</code> loads <strong>conditionally</strong> — based on path globs in YAML frontmatter. Covered in 5.4 and 5.5.</p>
      <p>Use <code>@import</code> when content should always be loaded for this package. Use rules when content should only load when specific file types are being edited.</p>
    </CalloutBox>
  </div>
  </v-clicks>
  <SlideFooter label="Lecture 5.3 · @import" :num="6" :total="9" />
</Frame>

<!--
Here's a distinction you need. `@import` loads always — when Claude opens that CLAUDE.md, the imported file comes with it. `.claude/rules/` loads conditionally — based on path globs in YAML frontmatter, which we cover next in 5.4 and 5.5. Two patterns, two use cases. Use `@import` when the content should always be loaded for this package. Use `.claude/rules/` when the content should only load when specific file types are being edited. Same goal — modularity — different triggers.
-->

---

<!-- SLIDE 7 — Exam framing -->

<Frame>
  <Eyebrow>On the exam</Eyebrow>
  <SlideTitle>"Modular CLAUDE.md" = @import.</SlideTitle>
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Task 3.1 -- the keyword match">
      <p>"Using <code>@import</code> to selectively include relevant standards files in each package's CLAUDE.md based on maintainer domain knowledge." Direct quote from the exam guide.</p>
      <p>Memorize the phrase <strong>per-package selective imports</strong>. If the question describes a monorepo with multiple packages each needing different subsets of standards, the answer is <code>@import</code> — not a monolithic root CLAUDE.md.</p>
    </CalloutBox>
  </div>
  </v-clicks>
  <SlideFooter label="Lecture 5.3 · @import" :num="7" :total="9" />
</Frame>

<!--
On the exam, "modular CLAUDE.md" is the keyword that maps to `@import`. The skill the exam tests is "using @import to selectively include relevant standards files in each package's CLAUDE.md based on maintainer domain knowledge." That's a direct quote from Task 3.1. Memorize the phrase "per-package selective imports" — it's the pattern match for any question about splitting up a large CLAUDE.md without losing standards. If the question describes a monorepo with multiple packages each needing different subsets of standards, the answer is `@import`, not a monolithic root CLAUDE.md.
-->

---

<!-- SLIDE 8 — Anti-pattern -->

<AntiPatternSlide
  eyebrow="Anti-pattern"
  title="Don't import everything everywhere"
  badExample="# packages/frontend/CLAUDE.md
@import ../../docs/testing-standards.md
@import ../../docs/api-conventions.md
@import ../../docs/terraform-standards.md
@import ../../docs/rds-backup-policy.md
@import ../../docs/deployment.md
# ... 12 more"
  whyItFails="Twelve copies of the same monolith is worse than one monolith."
  fixExample="# packages/frontend/CLAUDE.md
@import ../../docs/react-standards.md
@import ../../docs/testing-standards.md
# Only the 2-3 files this package actually needs."
  lang="markdown"
  footerLabel="Lecture 5.3 · @import"
  :footerNum="8"
  :footerTotal="9"
/>

<!--
Bad: import every standards file into every CLAUDE.md. You've replaced one monolith with twelve copies of the same monolith. Good: each package imports only the 2–3 files its maintainer deemed relevant. The point of modularity isn't to stop using the content — it's to stop loading irrelevant content. A terraform file doesn't need React conventions. The frontend doesn't need the RDS backup policy. Import what applies.
-->

---

<!-- SLIDE 9 — Closing -->

<Frame bg="var(--mint-100)">
  <Eyebrow>Takeaways</Eyebrow>
  <SlideTitle>@import — one file per concern.</SlideTitle>
  <div style="margin-top: 48px; display: grid; grid-template-columns: 1fr 1fr; gap: 32px;">
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">01</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Always-loaded.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Splices in verbatim when the parent CLAUDE.md loads.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">02</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Split by concern.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Different owner, different scope, high change rate.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">03</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Import per package.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Each maintainer picks only the files that apply to their package.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">04</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Next &mdash; 5.4.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;"><code>.claude/rules/</code> — topic-specific rule files.</div>
    </div>
  </div>
</Frame>

<!--
`@import` is the universal-always pattern — one file per concern, loaded every time the parent CLAUDE.md loads. Split by concern, import per package. Keep the main CLAUDE.md a table of contents, not a monolith. Next lecture — 5.4 — we move to the conditional-load pattern: `.claude/rules/`. Same goal of modularity, different trigger — conditional instead of always. Then 5.5 puts the two together with path globs, and that's where Sample Question 6 lives.
-->

---

<!-- LECTURE 5.4 — .claude/rules/ — Topic-Specific Rule Files -->

<!-- SLIDE 1 — Cover -->

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div style="flex: 1; display: flex; flex-direction: column; justify-content: center;">
    <div style="font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px;">
      Domain 3 &middot; Lecture 5.4
    </div>
    <h1 style="font-family: var(--font-display); font-weight: 500; font-size: 108px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1500px;">
      <span style="color: var(--sprout-500);">.claude/rules/</span><br/>Topic-Specific Rule Files
    </h1>
    <div style="font-family: var(--font-display); font-size: 44px; color: var(--mint-200); margin-top: 40px; font-weight: 400; max-width: 1200px; line-height: 1.3;">
      One file per topic. The harness decides which to load.
    </div>
  </div>
</Frame>

<!--
`.claude/rules/` is the directory that breaks the CLAUDE.md monolith apart by topic. One file per concern. The harness decides which rules to load based on context. Ships with the repo like everything else in `.claude/`.
-->

---

<!-- SLIDE 2 — Why -->

<ConceptHero
  eyebrow="The idea"
  leadLine="Split by topic, load by context"
  concept="One file, one concern."
  supportLine="The harness decides which rules to load. Better than a 400-line CLAUDE.md in every session."
  accent="var(--sprout-600)"
  footerLabel="Lecture 5.4 · .claude/rules/"
  :footerNum="2"
  :footerTotal="9"
/>

<!--
Split by topic, load by context. That's the idea. One file per topic — testing in one file, API conventions in another, deployment in a third, security in a fourth. Each file is focused. Each file can be maintained by the team that owns that topic — the platform team owns testing, the product team owns API conventions, SRE owns deployment. And critically — Claude doesn't have to load all of them at once. The harness picks which rules apply based on what Claude is actually doing. Better than a 400-line CLAUDE.md for every session where you actually only needed the testing rules.
-->

---

<!-- SLIDE 3 — Structure -->

<script setup>
const rulesLayout = `.claude/
  rules/
    testing.md
    api-conventions.md
    deployment.md
    security.md
  CLAUDE.md
`
</script>

<CodeBlockSlide
  eyebrow="The layout"
  title=".claude/rules/ -- one file per topic"
  lang="text"
  :code="rulesLayout"
  annotation="Names are for humans -- the harness uses frontmatter to decide when to load."
  footerLabel="Lecture 5.4 · .claude/rules/"
  :footerNum="3"
  :footerTotal="9"
/>

<!--
Here's the layout. Inside your repo, `.claude/rules/` holds a handful of markdown files. `testing.md`. `api-conventions.md`. `deployment.md`. `security.md`. Each file is one topic. The names are for humans — the harness uses frontmatter to decide when to load them, not the filename. But the filename matters for the maintainers, the people who open the repo six months from now and need to know where the testing standards live. Keep names descriptive so the next teammate can find what they need without opening every file. Your rule directory should read like a table of contents for your team's conventions.
-->

---

<!-- SLIDE 4 — Each file format -->

<script setup>
const DASH_54 = '-'.repeat(3)
const ruleFileSample = [
  DASH_54,
  'paths:',
  '  - "**/*.test.ts"',
  '  - "**/*.spec.ts"',
  DASH_54,
  '',
  '# Testing conventions',
  '',
  '- Prefer Vitest + Testing Library',
  '- Co-locate tests next to source files',
  '- Name test files with .test.ts suffix',
].join('\n')
</script>

<CodeBlockSlide
  eyebrow="File shape"
  title="testing.md -- a rule file"
  lang="markdown"
  :code="ruleFileSample"
  annotation="YAML frontmatter declares scope. Markdown body is the convention."
  footerLabel="Lecture 5.4 · .claude/rules/"
  :footerNum="4"
  :footerTotal="9"
/>

<!--
Each rule file has two parts — YAML frontmatter at the top, markdown body below. The frontmatter declares when the rule loads — that's where the `paths:` field lives, which we cover in depth next lecture. The body is the actual convention — the content Claude reads when the rule fires. Think of it as the same shape as a blog post with metadata, or a Jekyll page, or a Notion database entry, or an Obsidian note. Frontmatter declares scope. Body is content. Same two-part pattern across the whole Claude Code ecosystem — commands, skills, rules all follow it.
-->

---

<!-- SLIDE 5 — vs @import -->

<script setup>
const ruleColumns = ['Loads when', 'Best for']
const ruleRows = [
  { label: '@import', cells: ['Always, when CLAUDE.md loads', 'Universal standards'] },
  { label: '.claude/rules/*', cells: ['Conditionally -- by path glob', 'File-type specific conventions'] },
]
</script>

<ComparisonTable
  eyebrow="Two modular patterns"
  title="rules/ vs @import"
  :columns="ruleColumns"
  :rows="ruleRows"
  footerLabel="Lecture 5.4 · .claude/rules/"
  :footerNum="5"
  :footerTotal="9"
/>

<!--
Put `.claude/rules/` next to `@import` from the last lecture. `@import` loads always — whenever the parent CLAUDE.md loads, the imported content comes with it. `.claude/rules/*` loads conditionally — by path glob, only when Claude is editing files that match. Best for what? `@import` fits universal standards — things every session needs. `.claude/rules/` fits file-type-specific conventions — test files, terraform files, migration scripts, API handlers. Two patterns, two jobs. Know when to reach for each.
-->

---

<!-- SLIDE 6 — Next lecture preview -->

<Frame>
  <Eyebrow>Next lecture preview</Eyebrow>
  <SlideTitle>Path scoping — coming in 5.5.</SlideTitle>
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Rules get their power from YAML paths:">
      <p>A rule file has frontmatter that controls when it loads. The loading is conditional on file paths matched by glob patterns.</p>
      <p>We'll make this concrete with globs and real codebase examples in the next ten minutes. Sample Question 6 lives there.</p>
    </CalloutBox>
  </div>
  </v-clicks>
  <SlideFooter label="Lecture 5.4 · .claude/rules/" :num="6" :total="9" />
</Frame>

<!--
The real power of `.claude/rules/` comes from YAML frontmatter `paths:` globs. That's next lecture — 5.5. For now, know that a rule file has frontmatter that controls when it loads, and the loading is conditional on file paths. We'll make this concrete with globs and real codebase examples in the next ten minutes.
-->

---

<!-- SLIDE 7 — Exam framing -->

<Frame>
  <Eyebrow>On the exam</Eyebrow>
  <SlideTitle>"Split conventions by topic without bloating CLAUDE.md."</SlideTitle>
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Task 3.1 -- structural answer">
      <p>"Splitting large CLAUDE.md files into focused topic-specific files in <code>.claude/rules/</code>, like <code>testing.md</code>, <code>api-conventions.md</code>, <code>deployment.md</code>." Quote from the exam guide.</p>
      <p>Whenever a question describes a monolithic CLAUDE.md problem and asks for modularity, <code>.claude/rules/</code> is the structural answer. Read the sentence, own it.</p>
    </CalloutBox>
  </div>
  </v-clicks>
  <SlideFooter label="Lecture 5.4 · .claude/rules/" :num="7" :total="9" />
</Frame>

<!--
On the exam, the keyword match is "split conventions by topic without bloating CLAUDE.md." That's `.claude/rules/`. It's the structural answer whenever a question describes a monolithic CLAUDE.md problem and asks for modularity. The exam skill is literally — quote from Task 3.1 — "splitting large CLAUDE.md files into focused topic-specific files in .claude/rules/, like testing.md, api-conventions.md, deployment.md." That's the sentence. Read it, own it.
-->

---

<!-- SLIDE 8 — Continuity -->

<ConceptHero
  eyebrow="Continuity"
  leadLine="Same hierarchy logic as 1.1 -- biggest levers get the biggest share of context."
  concept="Load what's relevant."
  supportLine="Testing rules don't need to load when editing deployment YAML. Adding a new rule file doesn't bloat every session's context."
  accent="var(--teal-600)"
  footerLabel="Lecture 5.4 · .claude/rules/"
  :footerNum="8"
  :footerTotal="9"
/>

<!--
Same hierarchy logic as 1.1 — biggest levers get the biggest share of context. Your testing conventions don't need to load when you're editing deployment YAML. Your API error-handling rules don't need to load when you're editing a migration script. Load what's relevant. Leave out what isn't. That's how you keep Claude's attention on the thing in front of it — and it scales as your repo grows, because adding a new rule file doesn't bloat every session's context.
-->

---

<!-- SLIDE 9 — Closing -->

<Frame bg="var(--mint-100)">
  <Eyebrow>Takeaways</Eyebrow>
  <SlideTitle>Split by topic. Load by context.</SlideTitle>
  <div style="margin-top: 48px; display: grid; grid-template-columns: 1fr 1fr; gap: 32px;">
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">01</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">One file per topic.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Testing, API, deployment, security — each in its own file in <code>.claude/rules/</code>.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">02</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Conditional load.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Harness picks which rules apply based on context — not always loaded like <code>@import</code>.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">03</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Two-part shape.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">YAML frontmatter declares scope. Markdown body is the convention.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">04</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Next &mdash; 5.5.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Path-specific rules with YAML frontmatter glob patterns. Sample Q6 lives here.</div>
    </div>
  </div>
</Frame>

<!--
`.claude/rules/` splits CLAUDE.md by topic. One file per topic, loaded conditionally by the harness. Different from `@import` — that's always-loaded, this is conditional. Different from subdirectory CLAUDE.md — that's path-bound, this is file-type-bound. Next lecture — 5.5 — we look at the frontmatter that makes conditional loading actually work. The field is `paths:`, the values are globs, and this is where Sample Question 6 lives.
-->

---

<!-- LECTURE 5.5 — Path-Specific Rules with YAML Frontmatter Glob Patterns -->

<!-- SLIDE 1 — Cover -->

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div style="flex: 1; display: flex; flex-direction: column; justify-content: center;">
    <div style="font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px;">
      Domain 3 &middot; Lecture 5.5
    </div>
    <h1 style="font-family: var(--font-display); font-weight: 500; font-size: 108px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1500px;">
      Path-Specific Rules<br/><span style="color: var(--sprout-500);">paths:</span> glob frontmatter
    </h1>
    <div style="font-family: var(--font-display); font-size: 44px; color: var(--mint-200); margin-top: 40px; font-weight: 400; max-width: 1200px; line-height: 1.3;">
      Sample Q6 lives here. Pattern-match and move on.
    </div>
  </div>
</Frame>

<!--
`paths:` in YAML frontmatter is a glob list. The rule file loads only when Claude is editing files that match one of those globs. This is how you ship conventions that span directories — and it's the pattern behind Sample Question 6, one of the most common Domain 3 exam questions.
-->

---

<!-- SLIDE 2 — The problem -->

<BigQuote
  lead="The problem"
  quote="Test files live next to source files. <em>Button.test.tsx lives next to Button.tsx.</em> How do you apply test-specific conventions without bloating every CLAUDE.md?"
/>

<!--
"Test files live next to source files. Button.test.tsx lives next to Button.tsx. How do you apply test-specific conventions without bloating every CLAUDE.md?" That's the problem statement. React test files are scattered throughout the codebase. So are Python test files. So are any file type that follows co-location conventions. Subdirectory CLAUDE.md files don't help here — there's no single subdirectory that holds all your tests. You need path-based rules that span the whole tree.
-->

---

<!-- SLIDE 3 — The answer -->

<script setup>
const DASH_55a = '-'.repeat(3)
const pathsYaml = [
  DASH_55a,
  'paths:',
  '  - "**/*.test.tsx"',
  '  - "**/*.spec.tsx"',
  '  - "**/__tests__/**/*"',
  DASH_55a,
  '',
  '# Test file conventions',
  '',
  '- Every new component needs one test',
  '- Tests use Testing Library, not shallow rendering',
  '- Accessibility queries over test-id queries',
].join('\n')
</script>

<CodeBlockSlide
  eyebrow="The syntax"
  title="paths: glob in frontmatter"
  lang="yaml"
  :code="pathsYaml"
  annotation="Standard shell globbing. Double-star recurses. Single-star matches within a directory."
  footerLabel="Lecture 5.5 · Path-Specific Rules"
  :footerNum="3"
  :footerTotal="10"
/>

<!--
Here's the syntax. At the top of a rule file — say `.claude/rules/testing.md` — you put YAML frontmatter with a `paths:` field. Inside the YAML fences, `paths: ["**/*.test.tsx"]`. That's a glob. Any file Claude touches whose path matches `**/*.test.tsx` triggers this rule to load. Anything else — the rule stays out of context. You can list multiple globs in the same array — mix React test files and Python test files if your test conventions apply across both. You can use any standard glob syntax — double-star for recursive directories, single-star for within-directory matches, braces for alternation. Standard shell globbing rules, same as your `.gitignore`.
-->

---

<!-- SLIDE 4 — How it loads -->

<script setup>
const loadSteps = [
  { label: 'User asks Claude to edit Button.test.tsx', sublabel: 'the trigger event' },
  { label: 'Harness scans .claude/rules/ frontmatter', sublabel: 'deterministic, no inference' },
  { label: 'Any rule whose paths glob matches loads', sublabel: 'others stay out of context' },
  { label: 'Claude sees only the rules that apply', sublabel: 'lean context, targeted guidance' },
]
</script>

<FlowDiagram
  eyebrow="The load sequence"
  title="Conditional rule load"
  :steps="loadSteps"
  footerLabel="Lecture 5.5 · Path-Specific Rules"
  :footerNum="4"
  :footerTotal="10"
/>

<!--
The load sequence is straightforward. User asks Claude to edit `src/components/Button.test.tsx`. The harness scans the frontmatter of every rule in `.claude/rules/`. Any rule whose `paths:` glob matches the file being edited loads. Others stay out of context. The decision is deterministic — no inference, no guessing. Claude either sees the rule because the path matched, or doesn't because it didn't. That determinism is the point.
-->

---

<!-- SLIDE 5 — Why glob > subdirectory CLAUDE.md -->

<script setup>
const globColumns = ['When it fits', 'When it fails']
const globRows = [
  { label: 'Subdir CLAUDE.md', cells: ['All files under one path', 'Files spread across dirs'] },
  { label: 'paths glob', cells: ['Spans directories by file type', 'More flexible -- no failure modes'] },
]
</script>

<ComparisonTable
  eyebrow="Glob vs subdirectory CLAUDE.md"
  title="Why path globs beat subdirectory files for scattered conventions"
  :columns="globColumns"
  :rows="globRows"
  footerLabel="Lecture 5.5 · Path-Specific Rules"
  :footerNum="5"
  :footerTotal="10"
/>

<!--
Compare glob rules to subdirectory CLAUDE.md. A subdir CLAUDE.md fits when all the files share one path — an `/api` directory with API conventions, a `/terraform` directory with infra conventions. Works great when your structure is grouped by convention. It fails when files spread across dirs — test files everywhere, migration scripts everywhere, config files everywhere. Globs handle that. They span directories by file type instead of by location. More flexible. No situation where a subdir CLAUDE.md works and a glob rule doesn't — but the reverse is common.
-->

---

<!-- SLIDE 6 — Multiple scopes -->

<script setup>
const multiScopeYaml = [
  '# .claude/rules/terraform-rules.md',
  'paths: ["terraform/**/*"]',
  '',
  '# .claude/rules/api-rules.md',
  'paths: ["src/api/**/*"]',
  '',
  '# .claude/rules/test-rules.md',
  'paths: ["**/*.test.*"]',
].join('\n')
</script>

<CodeBlockSlide
  eyebrow="Real team, real globs"
  title="Different rules, different globs"
  lang="yaml"
  :code="multiScopeYaml"
  annotation="Three rules, three concerns. None load unless the current file matches."
  footerLabel="Lecture 5.5 · Path-Specific Rules"
  :footerNum="6"
  :footerTotal="10"
/>

<!--
Here's what a real team looks like. `terraform-rules.md` with `paths: ["terraform/**/*"]` — all your infra files, one convention file. `api-rules.md` with `paths: ["src/api/**/*"]` — API-specific handlers, validators, types. `test-rules.md` with `paths: ["**/*.test.*"]` — every test file, regardless of location or extension. Three rules, three globs, three concerns. None of them load unless the current file matches. That's the targeting you want.
-->

---

<!-- SLIDE 7 — Exam framing -->

<Frame>
  <Eyebrow>On the exam</Eyebrow>
  <SlideTitle>Sample Q6 — direct exam quote.</SlideTitle>
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="The question pattern">
      <p>"Test files are spread throughout the codebase alongside the code they test, and you want all tests to follow the same conventions regardless of location."</p>
      <p><strong>Correct:</strong> rule files in <code>.claude/rules/</code> with YAML frontmatter glob patterns. <strong>Distractors:</strong> consolidate in root CLAUDE.md (unreliable), use skills (manual invocation), drop CLAUDE.md in every subdir (can't span scattered files). Memorize the distractor list.</p>
    </CalloutBox>
  </div>
  </v-clicks>
  <SlideFooter label="Lecture 5.5 · Path-Specific Rules" :num="7" :total="10" />
</Frame>

<!--
This is Sample Question 6 territory — direct exam quote. "Your codebase has distinct areas with different coding conventions. Test files are spread throughout the codebase alongside the code they test, and you want all tests to follow the same conventions regardless of location." The correct answer is rule files in `.claude/rules/` with YAML frontmatter glob patterns. The distractors are: consolidate in root CLAUDE.md — unreliable, relies on inference; use skills — requires manual invocation, not automatic; drop CLAUDE.md in every subdir — can't handle files spread across many directories. Memorize that distractor list. It'll save you points.
-->

---

<!-- SLIDE 8 — Anti-pattern -->

<script setup>
const DASH_55b = '-'.repeat(3)
const antiPatternBad = [
  '# src/components/CLAUDE.md',
  '# src/features/auth/CLAUDE.md',
  '# src/features/billing/CLAUDE.md',
  '# ... 20 more copies',
  '# All say the same thing about tests.',
].join('\n')

const antiPatternFix = [
  '# .claude/rules/testing.md',
  DASH_55b,
  'paths: ["**/*.test.*"]',
  DASH_55b,
  '# Conventions load only for test files.',
].join('\n')
</script>

<AntiPatternSlide
  eyebrow="Anti-pattern"
  title="Don't scatter CLAUDE.md files"
  :badExample="antiPatternBad"
  whyItFails="Button.test.tsx lives next to Button.tsx. A subdir CLAUDE.md applies to both."
  :fixExample="antiPatternFix"
  lang="yaml"
  footerLabel="Lecture 5.5 · Path-Specific Rules"
  :footerNum="8"
  :footerTotal="10"
/>

<!--
Bad: drop CLAUDE.md in every subdirectory that needs test conventions. You've got Button.test.tsx living next to Button.tsx, which lives under `src/components/`, and you can't put a CLAUDE.md there without applying it to Button.tsx too. You end up with CLAUDE.md files scattered everywhere, most of them duplicating the same test conventions. Good: one file — `.claude/rules/testing.md` — with `paths: ["**/*.test.*"]`. The rule loads for tests, only for tests, no matter where they live.
-->

---

<!-- SLIDE 9 — Continuity -->

<ConceptHero
  eyebrow="Continuity"
  leadLine="Files spread across the codebase + apply conventions automatically"
  concept="Pattern-match, move on."
  supportLine="This is a direct exam-guide sample question. Don't read the distractors carefully -- reflex the pattern."
  accent="var(--teal-600)"
  footerLabel="Lecture 5.5 · Path-Specific Rules"
  :footerNum="9"
  :footerTotal="10"
/>

<!--
This is a direct exam-guide sample question — know the pattern as a reflex. If the scenario says "files spread across the codebase" and "apply conventions automatically," the answer is `.claude/rules/` with glob frontmatter. Don't even read the distractors carefully — pattern-match and move on.
-->

---

<!-- SLIDE 10 — Closing -->

<Frame bg="var(--mint-100)">
  <Eyebrow>Takeaways</Eyebrow>
  <SlideTitle>Globs solve the co-location problem.</SlideTitle>
  <div style="margin-top: 48px; display: grid; grid-template-columns: 1fr 1fr; gap: 32px;">
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">01</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;"><code>paths:</code> is the field.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Array of globs in YAML frontmatter. Rule loads when current file matches.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">02</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Spans directories.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">By file type, not by location. Works where subdirectory CLAUDE.md fails.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">03</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Sample Q6 reflex.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Scattered files + auto-apply = <code>.claude/rules/</code> with glob frontmatter.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">04</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Next &mdash; 5.6.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Custom slash commands. Same team/personal split, different surface.</div>
    </div>
  </div>
</Frame>

<!--
Glob-scoped rule files solve the co-location problem. Frontmatter declares when to load — `paths:` with globs. Rules span directories by file type rather than by location. Sample Q6 is this pattern exactly — know the distractors. Next lecture — 5.6 — we pivot from rules to slash commands. Same `.claude/` versus `~/.claude/` split you've seen twice already — but a different surface, with its own frontmatter options.
-->

---

<!-- LECTURE 5.6 — Custom Slash Commands -->

<!-- SLIDE 1 — Cover -->

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div style="flex: 1; display: flex; flex-direction: column; justify-content: center;">
    <div style="font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px;">
      Domain 3 &middot; Lecture 5.6
    </div>
    <h1 style="font-family: var(--font-display); font-weight: 500; font-size: 108px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1500px;">
      Custom <span style="color: var(--sprout-500);">Slash Commands</span>
    </h1>
    <div style="font-family: var(--font-display); font-size: 44px; color: var(--mint-200); margin-top: 40px; font-weight: 400; max-width: 1200px; line-height: 1.3;">
      Filename equals command name. Sample Q4 territory.
    </div>
  </div>
</Frame>

<!--
Slash commands mirror the CLAUDE.md hierarchy. Project directory equals team-shared via VCS. Home directory equals personal. Same pattern, different surface. This lecture is where Sample Question 4 lives, so pay attention to the exact paths.
-->

---

<!-- SLIDE 2 — Two directories -->

<TwoColSlide
  eyebrow="Same split, new surface"
  title="Two directories -- same pattern as CLAUDE.md"
  leftLabel=".claude/commands/ -- team"
  rightLabel="~/.claude/commands/ -- personal"
  footerLabel="Lecture 5.6 · Slash Commands"
  :footerNum="2"
  :footerTotal="9"
>
  <template #left>
    <p><strong>Lives in the repo.</strong> Ships via git. Every teammate gets them on clone.</p>
    <p>Shared prompts — <code>/review</code>, <code>/release-notes</code>, <code>/new-migration</code>.</p>
  </template>
  <template #right>
    <p><strong>Lives in your home directory.</strong> Nobody else sees them. Never ship.</p>
    <p>Personal shortcuts — <code>/my-review-shortcut</code>, <code>/explore-quick</code>.</p>
  </template>
</TwoColSlide>

<!--
You've seen this split twice already, so I'll keep it short. Commands in `.claude/commands/` are the team commands — they live in the repo, they ship via git, every teammate gets them when they clone. Commands in `~/.claude/commands/` are personal — they live in your home directory, nobody else sees them, they never ship. Same decision logic as CLAUDE.md. Same decision logic as skills. Same decision logic as rules. One pattern to rule them all. If you internalize this split once, you get every subsequent surface in Domain 3 for free.
-->

---

<!-- SLIDE 3 — File format -->

<script setup>
const DASH_56a = '-'.repeat(3)
const commandFormat = [
  DASH_56a,
  'description: Team code review against our standards',
  'allowed-tools: [Read, Grep, Bash]',
  'argument-hint: "Usage: /review [path]"',
  DASH_56a,
  '',
  '# Review the pending changes',
  '',
  'Walk through the diff and flag:',
  '- Null-pointer risks on nullable fields',
  '- Error-handling on every external call',
  '- Logging on exceptions',
  '- Test coverage for new public APIs',
].join('\n')
</script>

<CodeBlockSlide
  eyebrow="File shape"
  title=".claude/commands/review.md"
  lang="markdown"
  :code="commandFormat"
  annotation="Filename equals command name. Frontmatter configures. Body is the prompt."
  footerLabel="Lecture 5.6 · Slash Commands"
  :footerNum="3"
  :footerTotal="9"
/>

<!--
A slash command is a markdown file with frontmatter on top and a prompt body below. The filename becomes the command name — `review.md` in `.claude/commands/` means developers invoke it as `/review`. The frontmatter holds optional metadata — a description, allowed-tools, argument-hint — the same fields we cover in 5.9. The body is the actual prompt that Claude runs when the command is invoked. That's it. Filename equals command name. Frontmatter configures. Body prompts. Writing a slash command is writing a prompt and giving it a name, basically.
-->

---

<!-- SLIDE 4 — Example: /review -->

<script setup>
const DASH_56b = '-'.repeat(3)
const reviewExample = [
  DASH_56b,
  'description: Team code review -- run before every PR',
  DASH_56b,
  '',
  '# /review',
  '',
  'Review the pending changes against the team standards.',
  '',
  'Check for:',
  '- Null-pointer risks on nullable fields',
  '- Error-handling on every external call',
  '- Logging on raised exceptions',
  '- Test coverage for new public APIs',
  '',
  'Report findings with:',
  '- File + line citation',
  '- Severity (critical, high, medium, nit)',
  '- One suggested fix per finding',
].join('\n')
</script>

<CodeBlockSlide
  eyebrow="Full team command"
  title="Team code-review command"
  lang="markdown"
  :code="reviewExample"
  annotation="Commit once. Every teammate runs /review and gets the exact same checklist."
  footerLabel="Lecture 5.6 · Slash Commands"
  :footerNum="4"
  :footerTotal="9"
/>

<!--
Here's a team code-review command. File: `.claude/commands/review.md`. In the body: "Review the pending changes. Check for: null-pointer risks on nullable fields. Error-handling on every external call. Logging on exceptions. Test coverage for new public APIs. Report findings with file-line citations, severity, and a suggested fix." Commit that file. Every developer on the team can now run `/review` and get the exact same checklist. No training, no onboarding doc, no "hey what did we decide on review criteria?" It's codified.
-->

---

<!-- SLIDE 5 — Personal variant pattern -->

<Frame>
  <Eyebrow>Personal customization</Eyebrow>
  <SlideTitle>Don't override team commands by name.</SlideTitle>
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Create a differently-named variant instead">
      <p>Want a personal variant of <code>/review</code>? Create <code>/review-personal</code> or <code>/review-quick</code> in <code>~/.claude/commands/</code>.</p>
      <p>Your personal command is just for you. The team command stays canonical. If you want a permanent change to the team command, make the change in the repo and open a PR. That's how shared tools stay healthy.</p>
    </CalloutBox>
  </div>
  </v-clicks>
  <SlideFooter label="Lecture 5.6 · Slash Commands" :num="5" :total="9" />
</Frame>

<!--
Want a personal variant? Don't override the team command by reusing the name — that's asking for confusion. Instead, create a differently-named command in `~/.claude/commands/`. Call it `/review-personal` or `/review-quick` or whatever you want. Your personal command is just for you. The team command stays canonical. If you find yourself wanting a permanent change to the team command, make the change in the repo and open a PR. That's how shared tools stay healthy.
-->

---

<!-- SLIDE 6 — Exam framing -->

<Frame>
  <Eyebrow>Sample Q4 — literal</Eyebrow>
  <SlideTitle>"Available when any developer clones the repo."</SlideTitle>
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="The four options">
      <p><strong>Correct:</strong> <code>.claude/commands/</code> in the project.</p>
      <p><strong>Distractor 1:</strong> <code>~/.claude/commands/</code> — nobody else gets it.</p>
      <p><strong>Distractor 2:</strong> <code>CLAUDE.md</code> at project root — that's for instructions, not commands.</p>
      <p><strong>Distractor 3:</strong> <code>.claude/config.json</code> with a commands array — doesn't exist, not a real thing.</p>
    </CalloutBox>
  </div>
  </v-clicks>
  <SlideFooter label="Lecture 5.6 · Slash Commands" :num="6" :total="9" />
</Frame>

<!--
Sample Question 4 is the literal test of this pattern. "You want to create a custom /review slash command that should be available to every developer when they clone or pull the repository. Where should you create this command file?" The correct answer is `.claude/commands/`. The distractors: `~/.claude/commands/` in each developer's home — nobody else gets it. `CLAUDE.md` at the project root — that's for instructions, not commands. `.claude/config.json` with a commands array — doesn't exist, not a real thing. Three distractors, all plausible if you skim. All wrong.
-->

---

<!-- SLIDE 7 — Anti-pattern -->

<AntiPatternSlide
  eyebrow="Anti-pattern"
  title="Don't hide team commands in ~"
  badExample="# Team needs /review.
# You add it to ~/.claude/commands/review.md
# Works for you.
# Nobody else can invoke it.
# A month later: 'how do I run the team review?'"
  whyItFails="Team tools in personal directory never reach the team."
  fixExample="# Commit to .claude/commands/review.md
# Push.
# Everyone gets /review on next pull.
# No onboarding required."
  lang="bash"
  footerLabel="Lecture 5.6 · Slash Commands"
  :footerNum="7"
  :footerTotal="9"
/>

<!--
Bad: the team needs `/review`. You add it to your `~/.claude/commands/`. You've got a working command. Nobody else can invoke it. A month later someone asks "hey, how do I run the team review?" and the answer is "you can't, it's on my laptop." Good: put it in the repo's `.claude/commands/`. Commit. Push. Now everyone gets `/review` on their next pull. That's the point of project-scoped commands.
-->

---

<!-- SLIDE 8 — Continuity -->

<ConceptHero
  eyebrow="Continuity"
  leadLine="Same decision rule as 5.2"
  concept="Shared = repo. Personal = home."
  supportLine="CLAUDE.md, commands, skills, rules, MCP -- all the same split. Know it once, know it everywhere."
  accent="var(--teal-600)"
  footerLabel="Lecture 5.6 · Slash Commands"
  :footerNum="8"
  :footerTotal="9"
/>

<!--
Same decision rule as 5.2. Shared utility goes in the repo. Personal utility stays home. This rule holds for CLAUDE.md, for commands, for skills, for rules, for MCP servers. Once you internalize it, half of Domain 3 becomes reflexive. The exam weaponizes this — multiple questions across the twelve sample questions test the same decision under different surfaces. If you know the decision once, you know it everywhere.
-->

---

<!-- SLIDE 9 — Closing -->

<Frame bg="var(--mint-100)">
  <Eyebrow>Takeaways</Eyebrow>
  <SlideTitle>Filename = command name. Location = scope.</SlideTitle>
  <div style="margin-top: 48px; display: grid; grid-template-columns: 1fr 1fr; gap: 32px;">
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">01</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Project = team.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;"><code>.claude/commands/review.md</code> — available to everyone who clones.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">02</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Home = personal.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;"><code>~/.claude/commands/</code> — just for you. Use distinct names.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">03</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Sample Q4 cold.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;"><code>.claude/config.json</code> is fictional. CLAUDE.md is for instructions, not commands.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">04</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Next &mdash; 5.7.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Skills. Look like commands. Trigger by semantics, not name.</div>
    </div>
  </div>
</Frame>

<!--
Slash commands are filename-named team prompts. Project `.claude/commands/` for team, home `~/.claude/commands/` for personal. Don't override team commands by name — create distinct personal variants like `/review-personal`. Sample Q4 tests this exact distinction, and the distractor list includes a fictional `.claude/config.json` and the CLAUDE.md file — both wrong. Next up — 5.7 — we get into skills, which look similar but trigger differently. Commands are invoked by name. Skills are invoked by semantics.
-->

---

<!-- LECTURE 5.7 — Skills — SKILL.md Deep Dive -->

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

<script setup>
const surfaceColumns = ['Invoked by', 'Best for']
const surfaceRows = [
  { label: '/command', cells: ['Explicit name', 'Repetitive fixed workflow'] },
  { label: 'Skill', cells: ['Claude matches description', 'Context-triggered behavior'] },
]
</script>

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

<script setup>
const DASH_57 = '-'.repeat(3)
const skillAnatomy = [
  DASH_57,
  'name: security-review',
  'description: Runs a security-focused code review on pending changes. Flags injection risks, auth bypasses, and secrets leaks.',
  'context: fork',
  'allowed-tools: [Read, Grep, Bash]',
  'argument-hint: "Usage: /security-review [path]"',
  DASH_57,
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
  'Assistant: stays in main -- skill is security-scoped.',
].join('\n')
</script>

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
    <SchemaField name="name" type="string" :required="true" description="Kebab-case identifier -- the skill's handle." example="security-review" />
    <SchemaField name="description" type="string" :required="true" description="How Claude decides when to use the skill -- rules are the same as tool descriptions." example="Runs security-focused review of pending changes" />
    <SchemaField name="context" type="enum" :required="false" description="Either 'fork' or 'main' -- controls where the skill runs." example="fork" />
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
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Bad description = dead skill">
      <p>Same rules as tool descriptions from Task 2.1: purpose, inputs, examples, boundaries.</p>
      <p><strong>Bad:</strong> "analyzes things" — the skill never triggers.</p>
      <p><strong>Good:</strong> "runs a security-focused code review on pending changes, flags injection risks, auth bypasses, and secrets leaks" — triggers reliably on the right tasks.</p>
    </CalloutBox>
  </div>
  </v-clicks>
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
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="context: fork isolates skill execution">
      <p>Takes two values — <code>fork</code> and <code>main</code>. <code>fork</code> isolates the skill from the main session — it runs in a sub-agent context, and only the final output returns.</p>
      <p>Prevents verbose skill execution from eating your main context. One of the most important frontmatter options in Domain 3 — gets its own lecture next.</p>
    </CalloutBox>
  </div>
  </v-clicks>
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
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Safety rail + UX polish">
      <p><code>allowed-tools</code> is a safety rail — restricts which tools the skill may call during execution.</p>
      <p><code>argument-hint</code> is UX polish — when the user invokes the skill without required args, the hint shows instead of a silent failure.</p>
      <p>Small fields. Big operational impact. We'll spend a whole lecture on them.</p>
    </CalloutBox>
  </div>
  </v-clicks>
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
  supportLine="If Claude should always know it -> CLAUDE.md. If Claude should invoke it when relevant -> skill. Don't mix them up."
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
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Map trigger to surface">
      <p><strong>"On-demand, task-specific"</strong> -> skill.</p>
      <p><strong>"Universal always-loaded standards"</strong> -> CLAUDE.md.</p>
      <p><strong>"Applied by file path automatically"</strong> -> <code>.claude/rules/</code>.</p>
      <p>Almost-right is the trap. A question might describe on-demand work and offer CLAUDE.md as a distractor. Map trigger -> surface and you'll pick right.</p>
    </CalloutBox>
  </div>
  </v-clicks>
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

---

<!-- LECTURE 5.8 — context: fork — Isolating Skill Execution -->

<!-- SLIDE 1 — Cover -->

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div style="flex: 1; display: flex; flex-direction: column; justify-content: center;">
    <div style="font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px;">
      Domain 3 &middot; Lecture 5.8
    </div>
    <h1 style="font-family: var(--font-display); font-weight: 500; font-size: 108px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1500px;">
      <span style="color: var(--sprout-500);">context: fork</span><br/>Isolating Skill Execution
    </h1>
    <div style="font-family: var(--font-display); font-size: 44px; color: var(--mint-200); margin-top: 40px; font-weight: 400; max-width: 1200px; line-height: 1.3;">
      Main session gets output — not working tokens.
    </div>
  </div>
</Frame>

<!--
`context: fork` is the frontmatter field that runs a skill in a sub-agent context. The main conversation gets a clean summary, not forty tool-call receipts. This is how you stop verbose skills from eating your context budget. One field. Big operational lever.
-->

---

<!-- SLIDE 2 — The problem -->

<BigQuote
  lead="The failure mode"
  quote="A codebase-analysis skill runs — returns <em>35 tool calls and 8,000 tokens</em> of exploration to the main session. Now every turn is slower."
/>

<!--
"A codebase-analysis skill runs — returns thirty-five tool calls and eight thousand tokens of exploration to the main session. Now every turn is slower." That's the failure mode. You wrote a skill that does useful work. It works. But the byproduct is that every grep, every read, every trace step of the skill execution gets accumulated in your main context. The main session is now carrying that weight for the rest of the conversation — slower responses, more token spend, and context pressure that wasn't necessary because the user didn't need the receipts.
-->

---

<!-- SLIDE 3 — The fix -->

<ConceptHero
  eyebrow="The fix"
  leadLine="Fork the context"
  concept="context: fork."
  supportLine="Skill runs in isolation -- sub-agent spins up, does its work, returns only the final output. Main session keeps the answer, not the working memory."
  accent="var(--sprout-600)"
  footerLabel="Lecture 5.8 · context: fork"
  :footerNum="3"
  :footerTotal="9"
/>

<!--
Fork the context. That's the move. Set `context: fork` in the skill's frontmatter. Now the skill runs in isolation — a sub-agent spins up with its own context window, does its work, and returns just the final output to the main session. The exploration tokens, the intermediate tool calls, the branching thoughts — none of it comes back. Main session gets the answer and none of the working memory that produced it.
-->

---

<!-- SLIDE 4 — When to fork -->

<script setup>
const forkBullets = [
  { label: 'Produces verbose exploration output', detail: 'Codebase analysis, dependency tracing, doc gathering' },
  { label: 'Brainstorms alternatives', detail: 'You want one chosen path, not the full branching exploration' },
  { label: 'Runs a multi-step analysis', detail: 'Security audits tracing each finding through the code' },
  { label: 'Has side-effect-free discovery phases', detail: 'Test: does the main session need the intermediate work, or just the conclusion?' },
]
</script>

<BulletReveal
  eyebrow="When to fork"
  title="Fork when the skill..."
  :bullets="forkBullets"
  footerLabel="Lecture 5.8 · context: fork"
  :footerNum="4"
  :footerTotal="9"
/>

<!--
Fork when the skill produces verbose exploration output — codebase analysis, dependency tracing, documentation gathering, anything where getting the answer requires a lot of intermediate reading. Fork when the skill brainstorms alternatives — you want one chosen path returned, not the full branching exploration of options that didn't make the cut. Fork when the skill runs multi-step analysis — a security audit that traces each finding through the code doesn't need to leak every step into the main session. Fork when the skill has side-effect-free discovery phases. The test: does the main session need the intermediate work, or just the conclusion? If just the conclusion — fork.
-->

---

<!-- SLIDE 5 — When NOT to fork -->

<script setup>
const noForkBullets = [
  { label: 'Modifies state the main session tracks', detail: 'File edits, command runs whose effects matter downstream' },
  { label: 'Is short -- forking adds overhead', detail: 'Spinning up a sub-agent has real cost' },
  { label: 'Needs continuity with prior turns', detail: 'If the skill needs context from 5 turns ago, a fresh sub-agent strips it' },
]
</script>

<BulletReveal
  eyebrow="When NOT to fork"
  title="Keep in main when the skill..."
  :bullets="noForkBullets"
  footerLabel="Lecture 5.8 · context: fork"
  :footerNum="5"
  :footerTotal="9"
/>

<!--
Don't fork when the skill modifies state the main session needs to track — if the skill edits files or runs commands whose side effects matter for subsequent turns, the main session should see those. Don't fork short skills — the cost of spinning up a sub-agent is real, and a skill that fires quickly isn't benefiting from isolation. Don't fork when continuity with prior turns matters — if the skill needs to reason about what was said five turns ago, running in a fresh sub-agent context will strip that out. The decision isn't "fork always," it's "fork when the working tokens aren't the point."
-->

---

<!-- SLIDE 6 — Example -->

<script setup>
const DASH_58 = '-'.repeat(3)
const forkExample = [
  DASH_58,
  'name: codebase-explorer',
  'description: Traces data flow through the codebase for a specified feature. Summarizes call sites, dependencies, and entry points.',
  'context: fork',
  DASH_58,
  '',
  '# Instructions',
  '',
  'Given a feature name:',
  '1. Grep for feature references',
  '2. Read and trace data flow',
  '3. Return a structured summary (not the exploration receipts)',
].join('\n')
</script>

<CodeBlockSlide
  eyebrow="SKILL.md with fork"
  title="A codebase-exploration skill that forks"
  lang="yaml"
  :code="forkExample"
  annotation="Without fork, all the grepping and reading lands in main context. With fork, only the summary returns."
  footerLabel="Lecture 5.8 · context: fork"
  :footerNum="6"
  :footerTotal="9"
/>

<!--
Here's it in practice. SKILL.md with the frontmatter block up top. `name: codebase-explorer`. `description: traces data flow through the codebase for a specified feature`. `context: fork`. The skill will grep, read a bunch of files, build a mental model, summarize. Without `fork`, all that grepping and reading lands in the main context. With `fork`, only the summary returns. Same output to the user, an order of magnitude less context consumed.
-->

---

<!-- SLIDE 7 — Ties to Explore subagent -->

<Frame>
  <Eyebrow>Same idea, different surface</Eyebrow>
  <SlideTitle>context: fork is one of two isolation surfaces.</SlideTitle>
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="The Explore subagent is the other">
      <p>Domain 3 also has the Explore subagent — Task 3.4 — for the exact same purpose in a different place.</p>
      <p><code>context: fork</code> lives in SKILL.md. The Explore subagent is a plan-mode surface tool.</p>
      <p>Both isolate verbose discovery from main context. Covered in depth in 5.11. Same pattern, different invocation surface.</p>
    </CalloutBox>
  </div>
  </v-clicks>
  <SlideFooter label="Lecture 5.8 · context: fork" :num="7" :total="9" />
</Frame>

<!--
Same idea, different surface. Domain 3 also has the Explore subagent — Task 3.4 — for the exact same purpose in a different place. `context: fork` in SKILL.md is the skills-surface version. The Explore subagent is the plan-mode surface version. Both isolate verbose discovery from main context. We cover Explore in depth in 5.11. If you know one, you know the other — the pattern is the reusable lesson.
-->

---

<!-- SLIDE 8 — Exam framing -->

<Frame>
  <Eyebrow>On the exam</Eyebrow>
  <SlideTitle>Verbose skill pollutes main context -> fork.</SlideTitle>
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Isolation is the fix -- not volume reduction">
      <p><strong>Not</strong> "fewer tool calls" — misses the point.</p>
      <p><strong>Not</strong> "better description" — that controls when the skill fires, not what it spills.</p>
      <p><strong>Not</strong> "shorter body" — truncating it makes the skill worse.</p>
      <p><strong>The answer:</strong> <code>context: fork</code>. Isolation is the fix.</p>
    </CalloutBox>
  </div>
  </v-clicks>
  <SlideFooter label="Lecture 5.8 · context: fork" :num="8" :total="9" />
</Frame>

<!--
On the exam, a verbose skill output polluting main context is always `context: fork`. Not "fewer tool calls" — that's a distractor that misses the point. Not "better description" — descriptions control when the skill fires, not what it spills. Not "shorter body" — the body is the prompt, and truncating it makes the skill worse, not cleaner. The isolation is the fix. `context: fork` is how you isolate. Memorize the pair — verbose skill plus pollution equals fork.
-->

---

<!-- SLIDE 9 — Closing -->

<Frame bg="var(--mint-100)">
  <Eyebrow>Takeaways</Eyebrow>
  <SlideTitle>Fork when working tokens aren't the point.</SlideTitle>
  <div style="margin-top: 48px; display: grid; grid-template-columns: 1fr 1fr; gap: 32px;">
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">01</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Isolates execution.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Skill runs in sub-agent. Main session gets only the final output.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">02</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Fork when verbose.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Exploration, analysis, brainstorming. Working tokens aren't the answer.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">03</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Don't fork stateful skills.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">File edits, continuity, short skills — leave in main.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">04</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Next &mdash; 5.9.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;"><code>allowed-tools</code> and <code>argument-hint</code> — safety rail and UX polish.</div>
    </div>
  </div>
</Frame>

<!--
`context: fork` runs a skill in isolation. Main session gets output, not working tokens. Use it when the skill is verbose, exploratory, or analytical. Don't use it when the skill modifies state the main session tracks, when the skill is short, or when continuity across turns matters. Next lecture — 5.9 — covers the other two important frontmatter fields: `allowed-tools` for safety and `argument-hint` for UX. Small fields, big operational impact.
-->

---

<!-- LECTURE 5.9 — allowed-tools and argument-hint -->

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
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="warn" title="Safety rail -- what tools may the skill call?">
      <p>List the exact tools the skill may invoke: <code>Write, Edit, Read, Bash, Grep</code>, whatever. Anything not on the list is blocked at execution time.</p>
      <p>A skill you designed to "generate a changelog" should never run Bash. A skill you designed to "review pending changes" should never write files — it reads and reports. Locking the skill down prevents unintended blast radius when the prompt goes sideways.</p>
    </CalloutBox>
  </div>
  </v-clicks>
  <SlideFooter label="Lecture 5.9 · allowed-tools + argument-hint" :num="2" :total="8" />
</Frame>

<!--
`allowed-tools` restricts scope. Inside the skill's frontmatter, you list the exact tools the skill is allowed to invoke — Write, Edit, Read, Bash, Grep, whatever. Anything not on the list is blocked at execution time. Why bother? Because a skill you designed to "generate a changelog" should never run Bash. And a skill you designed to "review pending changes" should never write files — it reads and reports. Locking the skill down to just the tools it needs prevents unintended blast radius when the prompt goes sideways. Principle of least privilege, applied at the skill level.
-->

---

<!-- SLIDE 3 — allowed-tools example -->

<script setup>
const DASH_59a = '-'.repeat(3)
const allowedToolsExample = [
  DASH_59a,
  'name: write-docstring-to-file',
  'description: Adds a docstring to the specified file at the top of the given function. Write-only scope.',
  'allowed-tools: [Write, Edit, Read]',
  DASH_59a,
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
  '# Bash is NOT in allowed-tools -- blocked at the harness.',
].join('\n')
</script>

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
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="UX polish -- one line of frontmatter">
      <p>When the user invokes the skill without arguments, the hint string shows instead of a silent failure or a confused execution.</p>
      <p>"Usage: /my-skill &lt;topic&gt; [--depth=3]" tells the user what's missing and how to fix it. Turns "this skill doesn't work" bug reports into self-service fixes.</p>
    </CalloutBox>
  </div>
  </v-clicks>
  <SlideFooter label="Lecture 5.9 · allowed-tools + argument-hint" :num="4" :total="8" />
</Frame>

<!--
`argument-hint` is UX polish. When the user invokes the skill without the arguments it needs, the hint string shows instead of a silent failure or a confused execution. It's a one-line prompt — "Usage: /my-skill <topic> [--depth=3]" — that tells the user what's missing and how to fix it. Small feature. Turns "this skill doesn't work" bug reports into self-service fixes. The user reads the hint, rephrases the invocation, skill runs. No Slack thread required.
-->

---

<!-- SLIDE 5 — argument-hint example -->

<script setup>
const DASH_59b = '-'.repeat(3)
const argumentHintExample = [
  DASH_59b,
  'name: research-topic',
  'description: Researches a topic and returns a markdown summary with sources.',
  'argument-hint: "Usage: /research-topic <topic> [--max-sources=10]"',
  DASH_59b,
  '',
  '# Instructions',
  '',
  'Research the provided topic using web sources. Cap at max-sources.',
].join('\n')
</script>

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

<script setup>
const usageColumns = ['Use for']
const usageRows = [
  { label: 'allowed-tools', cells: ['Skill has destructive potential -- scope down to exact tools it needs'] },
  { label: 'argument-hint', cells: ['Skill needs user input -- prompt with usage string instead of silent failure'] },
]
</script>

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
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Map the problem to the field">
      <p><strong>"Restrict the skill's destructive actions"</strong> -> <code>allowed-tools</code>.</p>
      <p><strong>"Prompt the user for a missing argument"</strong> -> <code>argument-hint</code>.</p>
      <p>Both fields sit in frontmatter. Both modify skill behavior. Swapping them in a distractor is an easy miss. Almost-right is the trap.</p>
    </CalloutBox>
  </div>
  </v-clicks>
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

---

<!-- LECTURE 5.10 — Plan Mode vs Direct Execution -->

<!-- SLIDE 1 — Cover -->

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div style="flex: 1; display: flex; flex-direction: column; justify-content: center;">
    <div style="font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px;">
      Domain 3 &middot; Lecture 5.10
    </div>
    <h1 style="font-family: var(--font-display); font-weight: 500; font-size: 108px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1500px;">
      Plan Mode vs <span style="color: var(--sprout-500);">Direct</span> Execution
    </h1>
    <div style="font-family: var(--font-display); font-size: 44px; color: var(--mint-200); margin-top: 40px; font-weight: 400; max-width: 1200px; line-height: 1.3;">
      Sample Q5 territory. One question answers the decision.
    </div>
  </div>
</Frame>

<!--
Plan mode. Direct execution. Two modes of Claude Code work. The decision rule is one question. If more than one valid approach exists, plan. If you already know the fix, direct. This lecture is Sample Question 5 territory — know the framework as reflex.
-->

---

<!-- SLIDE 2 — The question -->

<BigQuote
  lead="The plan-mode test"
  quote="Is there more than one reasonable way to do this?"
  attribution="One question. The whole decision rides on it."
/>

<!--
"Is there more than one reasonable way to do this?" That's the plan-mode test. One question, yes or no. If yes — architectural choice, approach ambiguity, multiple valid paths — plan. If no — there's a clear best path, you already know it, the scope is tight — direct. Don't overthink the framework. It's one sentence. The whole decision rides on whether the approach itself needs deliberation or just execution.
-->

---

<!-- SLIDE 3 — Plan mode -->

<Frame>
  <Eyebrow>Plan mode</Eyebrow>
  <SlideTitle>Think before you touch.</SlideTitle>
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="When approach is ambiguous">
      <p>Large-scale changes. Architectural decisions. Multi-file edits. Multiple valid approaches where picking the wrong one is expensive to undo.</p>
      <p>Plan mode does codebase exploration, designs an approach, writes a plan, and <strong>waits for you to approve it before any file gets modified</strong>. Output is a plan, not a diff. Review, adjust, commit to the approach, then execute.</p>
    </CalloutBox>
  </div>
  </v-clicks>
  <SlideFooter label="Lecture 5.10 · Plan vs Direct" :num="3" :total="11" />
</Frame>

<!--
Plan mode is for when you need to think before you touch. Large-scale changes. Architectural decisions. Multi-file edits. Tasks where multiple valid approaches exist and picking the wrong one is expensive to undo. Plan mode does codebase exploration, designs an approach, writes a plan, and waits for you to approve it before any file gets modified. The output is a plan, not a diff. You review, you adjust, you commit to the approach, and then you execute.
-->

---

<!-- SLIDE 4 — Direct execution -->

<Frame>
  <Eyebrow>Direct execution</Eyebrow>
  <SlideTitle>Path is clear — just ship it.</SlideTitle>
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="When approach is unambiguous">
      <p>Single-file bug with a clean stack trace. Adding a validation check to one function. Well-scoped change where the approach isn't in question — only the implementation.</p>
      <p>You already know what to do. Going into plan mode here adds overhead without benefit. Direct execution just writes the fix and moves on.</p>
    </CalloutBox>
  </div>
  </v-clicks>
  <SlideFooter label="Lecture 5.10 · Plan vs Direct" :num="4" :total="11" />
</Frame>

<!--
Direct is for when the path is clear. Single-file bug with a clean stack trace. Adding a validation check to one function. Well-scoped change where the approach isn't in question — only the implementation. You already know what to do. Going into plan mode here adds overhead without benefit. Direct execution just writes the fix and moves on.
-->

---

<!-- SLIDE 5 — Concrete examples -->

<script setup>
const decisionsColumns = ['Mode', 'Why']
const decisionsRows = [
  { label: 'Monolith -> microservices', cells: ['Plan', 'Architectural -- Sample Q5'] },
  { label: 'Date-validation conditional', cells: ['Direct', 'Well-scoped single-file'] },
  { label: 'Library migration -- 45 files', cells: ['Plan', 'Multi-file, approach matters'] },
  { label: 'Fix stack trace', cells: ['Direct', 'Root cause is clear'] },
]
</script>

<ComparisonTable
  eyebrow="Real decisions, real framework"
  title="Concrete decisions"
  :columns="decisionsColumns"
  :rows="decisionsRows"
  footerLabel="Lecture 5.10 · Plan vs Direct"
  :footerNum="5"
  :footerTotal="11"
/>

<!--
Put real decisions next to the framework. Monolith to microservices — plan mode, because that's architectural, and it's exactly Sample Question 5. Date-validation conditional inside one function — direct, because the scope is a single file and the approach is unambiguous. Library migration affecting forty-five files — plan mode, because cross-file implications matter and the approach is non-trivial. Fix a stack trace where the root cause is obvious — direct, because there's one clear fix. Four decisions, four applications of the same rule.
-->

---

<!-- SLIDE 6 — Combined pattern -->

<ConceptHero
  eyebrow="The move that beats either alone"
  leadLine="Plan to design. Direct to implement."
  concept="Both. In order."
  supportLine="Explore the codebase, trace dependencies, pick the approach. Commit to the plan. Switch to direct and ship."
  accent="var(--sprout-600)"
  footerLabel="Lecture 5.10 · Plan vs Direct"
  :footerNum="6"
  :footerTotal="11"
/>

<!--
Here's the move that's better than either alone. Plan mode to design, then direct execution to implement. Use plan mode to explore the codebase, trace the dependencies, pick the approach. Review the plan. Commit to it. Switch to direct execution and ship it. Best of both — deliberation where it earns its keep, speed where it doesn't. The exam guide calls this out explicitly — "combining plan mode for investigation with direct execution for implementation." Remember the phrase.
-->

---

<!-- SLIDE 7 — The plan-mode output -->

<script setup>
const planOutput = `# Refactor plan: user-service -> microservices

## Files touched
- services/user/* (new)
- services/auth/* (modified)
- infra/k8s/user-service.yaml (new)
- ... 38 more

## Order
1. Extract session helpers -> services/auth
2. Create services/user scaffolding
3. Migrate controllers
4. Wire inter-service auth
5. Cut over + remove monolith routes

## Trade-offs considered
- Shared Postgres instance vs per-service DB -> chose shared (migration cost)
- gRPC vs REST for internal -> REST (existing observability)

## Risks
- Session TTL drift during cutover
- Transaction boundary across services
`
</script>

<CodeBlockSlide
  eyebrow="The plan artifact"
  title="What plan mode produces"
  lang="markdown"
  :code="planOutput"
  annotation="A first-class artifact. You review it like any proposal before any code changes."
  footerLabel="Lecture 5.10 · Plan vs Direct"
  :footerNum="7"
  :footerTotal="11"
/>

<!--
What does plan mode actually produce? A written plan — in markdown, typically — that describes the change: what files will be touched, in what order, with what approach, and what trade-offs were considered. You read the plan before any code changes. You push back on decisions you disagree with. Claude revises. When you're happy, you commit to the plan and exit plan mode for the execution phase. The plan is a first-class artifact. It gets reviewed like any proposal.
-->

---

<!-- SLIDE 8 — Anti-pattern -->

<AntiPatternSlide
  eyebrow="Anti-pattern"
  title="Don't direct-execute architectural changes"
  badExample="# Strategy: 'I'll start in direct mode
#            and switch to plan if it gets hard.'
# Problem: complexity is stated in the requirements.
# You commit to a bad approach and pay in rework."
  whyItFails="The complexity isn't going to emerge mid-execution -- it's stated up front."
  fixExample="# Strategy: read the requirements.
# Architectural -> plan mode from the start.
# Well-scoped single-file -> direct mode.
# Match the mode to what the task is."
  lang="text"
  footerLabel="Lecture 5.10 · Plan vs Direct"
  :footerNum="8"
  :footerTotal="11"
/>

<!--
Bad: "I'll start in direct mode and switch to plan if it gets hard." That sounds reasonable, but it's wrong. The requirements already told you the task was architectural — Sample Question 5 says "dozens of files, decisions about service boundaries and module dependencies." The complexity isn't going to emerge mid-execution — it's stated up front. Starting direct and hoping you don't hit turbulence is exactly how you commit to a bad approach and pay for it in rework. Good: if the requirements say architectural, start in plan mode. If they say well-scoped single-file, start direct.
-->

---

<!-- SLIDE 9 — Exam framing -->

<Frame>
  <Eyebrow>Sample Q5 — the template</Eyebrow>
  <SlideTitle>Monolith -> microservices = plan mode from the start.</SlideTitle>
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="The correct reflex">
      <p><strong>Question:</strong> "Restructure monolith into microservices. Changes across dozens of files. Decisions about service boundaries and module dependencies."</p>
      <p><strong>Correct:</strong> enter plan mode, explore, understand dependencies, design before any changes.</p>
      <p><strong>Classic distractor:</strong> "start in direct execution and switch to plan mode if you encounter unexpected complexity." Almost-right trap. The complexity isn't unexpected — it's stated.</p>
    </CalloutBox>
  </div>
  </v-clicks>
  <SlideFooter label="Lecture 5.10 · Plan vs Direct" :num="9" :total="11" />
</Frame>

<!--
Sample Question 5 is the template. "Restructure monolith into microservices. Changes across dozens of files. Decisions about service boundaries and module dependencies." Correct answer — enter plan mode, explore, understand dependencies, design before any changes. The classic distractor — "start in direct execution and switch to plan mode if you encounter unexpected complexity." That's the almost-right trap. The complexity isn't unexpected — it's stated. Plan mode from the start is the correct reflex.
-->

---

<!-- SLIDE 10 — Continuity -->

<ConceptHero
  eyebrow="Continuity"
  leadLine="Path A, Path B, Path C -- doesn't matter."
  concept="Plan mode scales."
  supportLine="Experienced devs still benefit from plan mode on architectural work. What changes with experience is how quickly you spot the multiple-approaches case."
  accent="var(--teal-600)"
  footerLabel="Lecture 5.10 · Plan vs Direct"
  :footerNum="10"
  :footerTotal="11"
/>

<!--
Path A, Path B, Path C — doesn't matter. Experienced devs still benefit from plan mode on architectural work, and brand-new users benefit even more. The decision framework scales with experience — what changes is how quickly you can tell whether a task has multiple valid approaches, not whether the framework applies.
-->

---

<!-- SLIDE 11 — Closing -->

<Frame bg="var(--mint-100)">
  <Eyebrow>Takeaways</Eyebrow>
  <SlideTitle>The plan-mode test: more than one valid approach?</SlideTitle>
  <div style="margin-top: 48px; display: grid; grid-template-columns: 1fr 1fr; gap: 32px;">
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">01</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Plan when ambiguous.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Architectural, multi-file, multiple valid approaches.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">02</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Direct when clear.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Single-file scope, clean stack trace, you know the fix.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">03</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Combine for big work.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Plan to design, direct to implement. Best of both.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">04</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Next &mdash; 5.11.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">The Explore subagent — same isolation idea as <code>context: fork</code>, different surface.</div>
    </div>
  </div>
</Frame>

<!--
Plan mode when the approach is ambiguous. Direct when the approach is clear. Combine them — plan to design, direct to implement. Sample Question 5 lives here. Next lecture — 5.11 — covers the Explore subagent, the other tool for isolating discovery from main context. Same idea as `context: fork`, different surface.
-->

---

<!-- LECTURE 5.11 — The Explore Subagent -->

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

<script setup>
const flowSteps = [
  { label: 'Main hits "need to understand X"', sublabel: 'trigger for delegation' },
  { label: 'Spawns Explore subagent with goal', sublabel: 'e.g. "map data flow for feature Y"' },
  { label: 'Explore does Grep / Read / trace', sublabel: 'in its own context window' },
  { label: 'Returns summary -- main keeps only summary', sublabel: 'intermediate tokens are gone' },
]
</script>

<FlowDiagram
  eyebrow="The flow"
  title="Main -> Explore -> Main"
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

<script setup>
const exploreBullets = [
  { label: 'Multi-phase task', detail: 'Discovery and implementation are separable' },
  { label: 'Discovery output is long', detail: 'Dozens of tool calls, thousands of tokens' },
  { label: 'Want main lean for implementation', detail: 'Room for code changes, reviews, iterations' },
]
</script>

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

<script setup>
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
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Two isolation surfaces">
      <p>Both <code>context: fork</code> (skills) and the Explore subagent (plan mode) isolate verbose discovery.</p>
      <p>Both return summaries. Both keep main context lean.</p>
      <p>The difference is invocation surface — <code>context: fork</code> is a frontmatter field in SKILL.md; Explore is a plan-mode subagent you delegate to.</p>
    </CalloutBox>
  </div>
  </v-clicks>
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
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Know both surfaces">
      <p>If the question frames the problem in <strong>plan mode or CLI terms</strong> -> Explore subagent.</p>
      <p>If the question frames it in <strong>skill-definition terms</strong> -> <code>context: fork</code>.</p>
      <p>Either way the fix is isolation. Don't pick "reduce the Grep calls" or "summarize in the body" — those miss the architectural fix.</p>
    </CalloutBox>
  </div>
  </v-clicks>
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

---

<!-- LECTURE 5.12 — Iterative Refinement Techniques -->

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
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="When prose fails, show examples">
      <p>Two or three input/output pairs beat ten sentences of specification.</p>
      <p>Prose leaves room for interpretation. "Handle edge cases gracefully" — what does that mean? "Normalize the input" — how? Examples lock ambiguity down. Input -> output. No interpretation needed.</p>
    </CalloutBox>
  </div>
  </v-clicks>
  <SlideFooter label="Lecture 5.12 · Iterative Refinement" :num="2" :total="10" />
</Frame>

<!--
When prose fails, show examples. Two or three input-output pairs beat ten sentences of specification. Prose leaves room for interpretation. "Handle edge cases gracefully" — what does that mean? "Normalize the input" — how? Examples lock ambiguity down. You give Claude an input and the output you want for that input, plus another input, plus one more. Now the pattern is explicit. No interpretation needed.
-->

---

<!-- SLIDE 3 — Examples in practice -->

<script setup>
const examplesCode = `Input row 1: {"id": 1, "email": null}
Output:       {"id": 1, "email": null}
# nulls preserved

Input row 2: {"id": 2, "email": "USER@ACME.com"}
Output:       {"id": 2, "email": "user@acme.com"}
# non-nulls lowercased

# Two examples, one unambiguous transformation.
`
</script>

<CodeBlockSlide
  eyebrow="Technique 1 in practice"
  title="Input -> output pairs"
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
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Progressive convergence">
      <p>Draft a test suite capturing expected behavior — happy paths, edge cases, performance. Claude implements against the tests. The tests run. Some fail.</p>
      <p>Paste failures back to Claude. Claude fixes. The next run has fewer failures. Loop until green. The tests become both the spec and the termination condition.</p>
    </CalloutBox>
  </div>
  </v-clicks>
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
    { title: 'Run tests -- share failures', body: 'Concrete assertions, not vibes' },
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
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Surface what you'd otherwise miss">
      <p>Before implementing, ask Claude to surface the considerations — cache invalidation, concurrency edge cases, failure modes, cleanup semantics.</p>
      <p>Claude asks 3-5 clarifying questions. You answer. Now the implementation is grounded in your actual requirements, not Claude's assumptions about what a typical system looks like.</p>
    </CalloutBox>
  </div>
  </v-clicks>
  <SlideFooter label="Lecture 5.12 · Iterative Refinement" :num="6" :total="10" />
</Frame>

<!--
Unfamiliar domain? Have Claude interview you first. Before implementing, ask Claude to surface the considerations you'd otherwise miss — cache invalidation strategies, concurrency edge cases, failure modes, cleanup semantics. Claude asks three to five clarifying questions. You answer. Now the implementation is grounded in your actual requirements, not in Claude's assumptions about what a typical system looks like. This is the pattern that saves you from shipping code that looks right and fails in production on a scenario nobody thought to mention.
-->

---

<!-- SLIDE 7 — Interview example -->

<script setup>
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
</script>

<CodeBlockSlide
  eyebrow="Interview pattern"
  title="One-line prompt that unlocks design"
  lang="text"
  :code="interviewPrompt"
  annotation="Implementation that follows is informed -- surfaces edge cases before code gets written."
  footerLabel="Lecture 5.12 · Iterative Refinement"
  :footerNum="7"
  :footerTotal="10"
/>

<!--
One-line prompt that unlocks it. "Before implementing, ask me three to five clarifying questions about authentication handling, error recovery, and upstream rate limits." Claude responds with a numbered list of specifics — "What's the retry policy on upstream failures? Do you want jittered backoff? What happens to in-flight requests if the upstream returns a 429?" You answer each one. The implementation that follows is informed — it handles the real edge cases because you surfaced them before any code got written.
-->

---

<!-- SLIDE 8 — Single-message vs sequential -->

<script setup>
const batchColumns = ['Approach']
const batchRows = [
  { label: 'Issues interact', cells: ['Batch -- one message so Claude sees the whole picture'] },
  { label: 'Issues independent', cells: ['Sequential -- one at a time, cleaner diffs'] },
]
</script>

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
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Three failure modes, three techniques">
      <p><strong>"Vague spec -> inconsistent output"</strong> -> concrete examples.</p>
      <p><strong>"Unfamiliar domain -> need design considerations surfaced"</strong> -> interview pattern.</p>
      <p><strong>"Known behavior -> need convergence"</strong> -> test-driven iteration.</p>
      <p>Almost-right trap: the exam might offer "write more detailed prose" as a distractor for examples. Prose isn't the fix. Examples are.</p>
    </CalloutBox>
  </div>
  </v-clicks>
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

---

<!-- LECTURE 5.13 — Claude Code in CI/CD -->

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

<script setup>
const pFlag = `# Non-interactive mode -- required for CI
claude -p "Analyze this PR for security issues"

# -p tells Claude Code to:
# 1. Process the prompt
# 2. Write result to stdout
# 3. Exit
#
# No interactive prompts. No waiting for stdin.
`
</script>

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
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Why JSON instead of prose">
      <p>You want to post findings as inline PR comments, track review counts in a metrics database, or route output to downstream jobs.</p>
      <p>Raw text doesn't work — you can't programmatically extract "which file, which line, what severity" from prose reliably.</p>
      <p><code>--output-format json</code> turns Claude's response into a structured blob your pipeline can parse with <code>jq</code>, Python, or anything else that reads JSON.</p>
    </CalloutBox>
  </div>
  </v-clicks>
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
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Schema is the contract">
      <p>JSON is structured, but shape can still drift — fields get renamed, nesting changes, optional fields appear and disappear.</p>
      <p>Pair <code>--output-format json</code> with <code>--json-schema</code> and hand Claude a JSON schema file that enforces a specific shape. Output must match the schema.</p>
      <p>Your pipeline knows exactly what fields to expect, because the schema is the contract. No more "Claude's output shape changed and my parser broke."</p>
    </CalloutBox>
  </div>
  </v-clicks>
  <SlideFooter label="Lecture 5.13 · Claude Code in CI/CD" :num="5" :total="10" />
</Frame>

<!--
One more step. JSON is structured, but the shape can still drift — fields get renamed, nesting changes, optional fields appear and disappear. Pair `--output-format json` with `--json-schema` and you hand Claude a JSON schema file that enforces a specific shape. Output must match the schema. Your pipeline knows exactly what fields to expect, because the schema is the contract. No more "oh, Claude's output shape changed and my parser broke."
-->

---

<!-- SLIDE 6 — Full CI invocation -->

<script setup>
const ciInvocation = `# Production CI call -- three flags together
claude -p "Review this PR for security issues per standards in CLAUDE.md" \\
  --output-format json \\
  --json-schema ./review-schema.json

# -p              : non-interactive
# --output-format : machine-parseable JSON
# --json-schema   : enforced shape, no drift
`
</script>

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
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="That's how CI-Claude gets team standards">
      <p>When Claude Code runs in CI, it still loads the project-level CLAUDE.md from the repo. Testing standards, review criteria, fixture conventions — everything the team codified.</p>
      <p>You don't need to reinject context in the prompt. The pipeline picks it up automatically. Task 3.6 calls this out — CLAUDE.md is the mechanism for providing project context to CI-invoked Claude Code.</p>
    </CalloutBox>
  </div>
  </v-clicks>
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
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="CI naturally isolates">
      <p>Every CI run is a fresh session — no memory of previous runs, no carryover from the developer's interactive session.</p>
      <p>The CI-Claude has no idea how the code got written — it just sees the diff and the project context. That's the architecture you want for reliable review.</p>
      <p>Covered in depth in 5.14 — next lecture.</p>
    </CalloutBox>
  </div>
  </v-clicks>
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
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="The four options">
      <p><strong>Correct:</strong> <code>-p</code> flag.</p>
      <p><strong>Distractor 1:</strong> <code>CLAUDE_HEADLESS=true</code> — doesn't exist, fictional env var.</p>
      <p><strong>Distractor 2:</strong> <code>&lt; /dev/null</code> redirect — Unix workaround that doesn't address Claude Code's syntax.</p>
      <p><strong>Distractor 3:</strong> <code>--batch</code> flag — doesn't exist either.</p>
      <p>Those three are designed to look plausible to someone guessing. Don't guess.</p>
    </CalloutBox>
  </div>
  </v-clicks>
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

---

<!-- LECTURE 5.14 — Fresh-Session Review -->

<!-- SLIDE 1 — Cover -->

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div style="flex: 1; display: flex; flex-direction: column; justify-content: center;">
    <div style="font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px;">
      Domain 3 &middot; Lecture 5.14
    </div>
    <h1 style="font-family: var(--font-display); font-weight: 500; font-size: 108px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1500px;">
      <span style="color: var(--sprout-500);">Fresh-Session</span> Review
    </h1>
    <div style="font-family: var(--font-display); font-size: 44px; color: var(--mint-200); margin-top: 40px; font-weight: 400; max-width: 1200px; line-height: 1.3;">
      The session that wrote the code is the worst one to review it in.
    </div>
  </div>
</Frame>

<!--
The session that generated code is the worst session to review it in. Fresh session equals fresh eyes. Domain 4 covers the multi-instance pattern in depth; Domain 3 covers its Claude Code surface. The exam tests both. Know the principle — independent review beats self-review, always.
-->

---

<!-- SLIDE 2 — The problem -->

<BigQuote
  lead="The failure mode"
  quote="Same session that wrote the code is biased toward saying <em>it's fine.</em>"
  attribution="Self-review looks like review but doesn't function like one"
/>

<!--
"Same session that wrote the code is biased toward saying it's fine." That's the failure mode. When a single Claude session both generates and reviews code, it carries reasoning context from generation — "I chose this approach for reasons X, Y, Z" — and that reasoning biases the review. Claude is less likely to question its own decisions because the decisions seemed justified at the time. Self-review looks like review but doesn't function like one. It's not that Claude is sloppy — it's that the generation context contaminates the review context. Structurally weaker, not effortfully weaker.
-->

---

<!-- SLIDE 3 — Why -->

<ConceptHero
  eyebrow="Why self-review fails"
  leadLine="Reasoning context biases review"
  concept="Less questioning."
  supportLine="Claude's 'why I wrote it' makes it less likely to question itself. Fresh session strips the reasons -- review must stand on what's in the diff."
  accent="var(--sprout-600)"
  footerLabel="Lecture 5.14 · Fresh-Session Review"
  :footerNum="3"
  :footerTotal="9"
/>

<!--
Reasoning context biases review. That's the anchor. Claude's "why I wrote it this way" makes it less likely to question itself. If you wrote a function and you know the trade-offs you considered, you're more forgiving of the function than someone encountering it cold. Same mechanism here. Self-review is a weaker test than independent review. Not because Claude is trying to be kind to itself, but because the context that produced the code also produces the rationalization of the code. You can't unknow the reasons once you've held them. Fresh session strips the reasons away — the review has to stand on what's in the diff, not what was in the prior thought process.
-->

---

<!-- SLIDE 4 — The fix -->

<StepSequence
  eyebrow="Independent review flow"
  title="Four steps to real review"
  :steps="[
    { title: 'Session A generates the code', body: 'Full context of requirements and reasoning' },
    { title: 'Commit the code', body: 'The diff is the artifact' },
    { title: 'Session B -- fresh -- runs the review', body: 'Only CLAUDE.md context; no generation reasoning' },
    { title: 'Review reads the code cold', body: 'Catches what the generation session missed' },
  ]"
  footerLabel="Lecture 5.14 · Fresh-Session Review"
  :footerNum="4"
  :footerTotal="9"
/>

<!--
Independent review flow is four steps. Session A generates the code. Commit the code. Session B — fresh, no prior context — runs the review. The review session has only the CLAUDE.md context and the code diff. No generation reasoning. No attachment to particular approaches. It reads the code cold, the way a new teammate would. That fresh perspective catches things the generation session missed — subtle bugs, missed edge cases, approaches that looked fine at generation time but look off when read cold. The four-step pattern is the architecture, not the afterthought.
-->

---

<!-- SLIDE 5 — CI integration -->

<Frame>
  <Eyebrow>CI naturally isolates</Eyebrow>
  <SlideTitle>Every CI run is a fresh session.</SlideTitle>
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Good default -- use it">
      <p>No memory of previous runs. No carryover from the developer's interactive session.</p>
      <p>When you run <code>claude -p</code> in a CI job to review a PR, that Claude instance has no idea how the code got written — it just sees the diff and the project context.</p>
      <p>CI isn't just automation — it's structural session isolation.</p>
    </CalloutBox>
  </div>
  </v-clicks>
  <SlideFooter label="Lecture 5.14 · Fresh-Session Review" :num="5" :total="9" />
</Frame>

<!--
CI naturally isolates. Every CI run is a fresh session — no memory of previous runs, no carryover from the developer's interactive session. Good default. Use it. When you run `claude -p` in a CI job to review a PR, that Claude instance has no idea how the code got written — it just sees the diff and the project context. That's the architecture you want for reliable review. CI isn't just automation — it's structural session isolation.
-->

---

<!-- SLIDE 6 — Re-review on new commits -->

<Frame>
  <Eyebrow>Re-review on new commits</Eyebrow>
  <SlideTitle>Pass prior findings — skip duplicates.</SlideTitle>
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Avoid noise without losing independence">
      <p>When you re-run review on a new commit, include prior findings in the new session's context.</p>
      <p>Instruct Claude: "Report only new or still-unaddressed issues. Don't repeat anything already flagged in the prior review."</p>
      <p>The fresh session still doesn't inherit generation reasoning — it just deduplicates against the prior review. Task 3.6 calls this pattern out.</p>
    </CalloutBox>
  </div>
  </v-clicks>
  <SlideFooter label="Lecture 5.14 · Fresh-Session Review" :num="6" :total="9" />
</Frame>

<!--
One subtlety — when you re-run review on a new commit, you want to avoid duplicate findings. The fix is to include prior findings in the new session's context and instruct Claude: "report only new or still-unaddressed issues. Don't repeat anything already flagged in the prior review." That instruction lets the fresh session act independently — it still doesn't inherit generation reasoning — but it avoids noise from repeated findings. Task 3.6 calls this pattern out specifically.
-->

---

<!-- SLIDE 7 — Exam framing -->

<Frame>
  <Eyebrow>On the exam</Eyebrow>
  <SlideTitle>"Self-review is good enough" is always a distractor.</SlideTitle>
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Two domains, one principle">
      <p><strong>Always wrong:</strong> "self-review is good enough" — sounds efficient, isn't.</p>
      <p><strong>Always right:</strong> independent Claude instance runs the review.</p>
      <p>Domain 3 covers the Claude Code surface. Domain 4 covers the broader multi-instance pattern — revisited in 6.14. Two places, same principle.</p>
    </CalloutBox>
  </div>
  </v-clicks>
  <SlideFooter label="Lecture 5.14 · Fresh-Session Review" :num="7" :total="9" />
</Frame>

<!--
On the exam, "self-review is good enough" is always a distractor. Always. It sounds efficient, it sounds like it saves tokens, and it's wrong. The correct answer for any review-quality question is an independent Claude instance. Domain 3 covers the Claude Code surface of this pattern. Domain 4 covers the broader multi-instance review architecture — we revisit it in Section 6, lecture 6.14. Two places, same principle. Know both.
-->

---

<!-- SLIDE 8 — Continuity -->

<ConceptHero
  eyebrow="Continuity"
  leadLine="Scenario 5 -- Claude Code for CI"
  concept="Isolation is structural."
  supportLine="Without session isolation, CI review is no better than self-review. With it, you have a genuinely independent second pair of eyes."
  accent="var(--teal-600)"
  footerLabel="Lecture 5.14 · Fresh-Session Review"
  :footerNum="8"
  :footerTotal="9"
/>

<!--
Scenario 5 — Claude Code for CI — this is the architecture pattern that makes Scenario 5 work. Without session isolation, your CI review is no better than self-review. With session isolation, it's a genuinely independent second pair of eyes. That's why CI-based review is a strong default — the isolation is structural.
-->

---

<!-- SLIDE 9 — Closing -->

<Frame bg="var(--mint-100)">
  <Eyebrow>Takeaways</Eyebrow>
  <SlideTitle>Fresh session = fresh eyes.</SlideTitle>
  <div style="margin-top: 48px; display: grid; grid-template-columns: 1fr 1fr; gap: 32px;">
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">01</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Self-review is biased.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Generation context contaminates review — structurally, not effortfully.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">02</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">CI naturally isolates.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Every CI run is fresh. Use it as the default review surface.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">03</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Pass prior findings.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Re-review deduplicates against them — still no generation reasoning inherited.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">04</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Next &mdash; 5.15.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Two commands: <code>/memory</code> for diagnostics, <code>/compact</code> for context.</div>
    </div>
  </div>
</Frame>

<!--
Same session that wrote the code is biased toward saying it's fine. Fresh session is the fix. CI naturally isolates — every run is independent. When re-reviewing, include prior findings and instruct Claude to skip duplicates. Exam rule of thumb — any answer saying "self-review is enough" is wrong. Independent instance is the right pattern. Next lecture — 5.15 — closes out Section 5 with two commands: `/memory` for diagnostics and `/compact` for context management.
-->

---

<!-- LECTURE 5.15 — /memory and /compact -->

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
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Your first move when something's wrong">
      <p>Lists the CLAUDE.md files Claude can see in the current session — user, project, any directory-level files that matched.</p>
      <p>"Why doesn't Claude know X?" -> run <code>/memory</code>, look at the paths, see if your file is there.</p>
      <p>If it's not — the file isn't where you think it is. Probably sitting at user-level instead of project-level. Ten seconds of diagnostic saves an hour of "why isn't this working."</p>
    </CalloutBox>
  </div>
  </v-clicks>
  <SlideFooter label="Lecture 5.15 · /memory and /compact" :num="2" :total="9" />
</Frame>

<!--
What's loaded? That's what `/memory` answers. It lists the CLAUDE.md files Claude can see in the current session — user-level, project-level, any directory-level files that matched. It's your first move when someone says "why doesn't Claude know X?" Run `/memory`, look at the paths, see if the file you expected is in the list. If it's not, the file isn't where you think it is — probably sitting at user-level instead of project-level, the #1 bug we covered in 5.1. Ten seconds of diagnostic saves you an hour of "why isn't this working."
-->

---

<!-- SLIDE 3 — /memory output -->

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
</script>

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

<script setup>
const memoryUseCases = [
  { label: "New teammate doesn't have your conventions", detail: 'Check whether the project CLAUDE.md made it into their session' },
  { label: 'Different behavior across sessions', detail: 'Maybe one teammate has a personal CLAUDE.md overriding the team one' },
  { label: 'Adding a new rule and want to confirm it loads', detail: 'Verify the glob matched and frontmatter parsed' },
]
</script>

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
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Condense older turns into a summary">
      <p>Claude has a context window. Once it's mostly full, responses get slower and more expensive, and older turns start dropping without your control.</p>
      <p><code>/compact</code> condenses older turns into a summary — keeps critical outcomes and decisions, drops the verbose intermediate work. Frees tokens. You trade loss of detail for headroom.</p>
      <p>Task 5.4 in the exam guide covers this — memory management is the surface, <code>/compact</code> is the tool.</p>
    </CalloutBox>
  </div>
  </v-clicks>
  <SlideFooter label="Lecture 5.15 · /memory and /compact" :num="5" :total="9" />
</Frame>

<!--
Different job entirely. `/compact` is for long sessions where context is filling up. Claude has a context window, and once it's mostly full, responses get slower and more expensive, and older turns start getting dropped without your control. `/compact` condenses the older turns into a summary — keeps the critical outcomes and decisions, drops the verbose intermediate work. Frees tokens. You trade loss of detail for headroom to keep going. Task 5.4 in the exam guide covers this — memory management is the surface, `/compact` is the tool.
-->

---

<!-- SLIDE 6 — When to /compact -->

<script setup>
const compactWhen = [
  { label: 'Session is long and context fills', detail: 'Slower responses, context-pressure warnings, waiting longer for each turn' },
  { label: 'You have a natural end of phase', detail: 'After a design review, before implementation; after refactor, before tests' },
  { label: 'Want a clean slate + history summary', detail: 'Keep the critical outcomes and decisions, drop verbose intermediate work' },
]
</script>

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
  <v-clicks>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Different jobs -- don't confuse them">
      <p><strong>"Which memory files are loaded?"</strong> -> <code>/memory</code>.</p>
      <p><strong>"Context filled during long exploration"</strong> -> <code>/compact</code>.</p>
      <p>Both names sound like memory management, but they do totally different jobs. Diagnostic scenario = <code>/memory</code>. Context-pressure scenario = <code>/compact</code>.</p>
    </CalloutBox>
  </div>
  </v-clicks>
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
