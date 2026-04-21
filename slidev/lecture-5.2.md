---
theme: default
title: "Lecture 5.2: What Gets Shared via Version Control and What Doesn't"
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
const teamBullets = [
  { label: 'CLAUDE.md', detail: 'The project-level instructions — the team source of truth' },
  { label: 'commands/', detail: 'Custom slash commands your whole team can invoke by name' },
  { label: 'skills/', detail: 'SKILL.md files Claude triggers automatically via description matching' },
  { label: 'rules/', detail: 'Topic-specific rules with path-based loading' },
  { label: '.mcp.json', detail: 'MCP server configuration shared with every teammate' },
]

const personalBullets = [
  { label: 'Personal CLAUDE.md overrides', detail: 'Your preferences on top of team defaults' },
  { label: 'Personal slash commands', detail: 'Named differently so they don\u2019t collide with team ones' },
  { label: 'Experimental skills', detail: 'Incubator space before you propose them to the team' },
  { label: 'Personal MCP servers', detail: 'Local tools nobody else uses' },
]

const gitignoreCode = `# Do NOT do this:
# .claude/            ← hides team config from VCS

# Correct — only session state and secrets:
.claude/sessions/
.env
**/*.credentials
`
</script>

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
  title="Two directories — two intents"
  leftLabel=".claude/ — team"
  rightLabel="~/.claude/ — you"
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

<BulletReveal
  eyebrow=".claude/ — team-shared"
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

<BulletReveal
  eyebrow="~/.claude/ — personal"
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

<CodeBlockSlide
  eyebrow="Subtle but critical"
  title=".gitignore — only local-session files"
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
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Sample Q4 — the literal path test">
      <p><code>.claude/commands/</code> means team, shared via VCS. <code>~/.claude/commands/</code> means personal.</p>
      <p>Sample Q4 describes a <code>/review</code> command that should be available to every developer when they clone the repo. The answer is <code>.claude/commands/</code>. The distractor is <code>~/.claude/commands/</code> in every developer's home — plausible, but then nobody else gets it. Know this reflex cold.</p>
    </CalloutBox>
  </div>
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
