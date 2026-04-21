---
theme: default
title: "Lecture 5.6: Custom Slash Commands"
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

const commandFormat = [
  DASH,
  'description: Team code review against our standards',
  'allowed-tools: [Read, Grep, Bash]',
  'argument-hint: "Usage: /review [path]"',
  DASH,
  '',
  '# Review the pending changes',
  '',
  'Walk through the diff and flag:',
  '- Null-pointer risks on nullable fields',
  '- Error-handling on every external call',
  '- Logging on exceptions',
  '- Test coverage for new public APIs',
].join('\n')

const reviewExample = [
  DASH,
  'description: Team code review — run before every PR',
  DASH,
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
  title="Two directories — same pattern as CLAUDE.md"
  leftLabel=".claude/commands/ — team"
  rightLabel="~/.claude/commands/ — personal"
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
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Create a differently-named variant instead">
      <p>Want a personal variant of <code>/review</code>? Create <code>/review-personal</code> or <code>/review-quick</code> in <code>~/.claude/commands/</code>.</p>
      <p>Your personal command is just for you. The team command stays canonical. If you want a permanent change to the team command, make the change in the repo and open a PR. That's how shared tools stay healthy.</p>
    </CalloutBox>
  </div>
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
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="The four options">
      <p><strong>Correct:</strong> <code>.claude/commands/</code> in the project.</p>
      <p><strong>Distractor 1:</strong> <code>~/.claude/commands/</code> — nobody else gets it.</p>
      <p><strong>Distractor 2:</strong> <code>CLAUDE.md</code> at project root — that's for instructions, not commands.</p>
      <p><strong>Distractor 3:</strong> <code>.claude/config.json</code> with a commands array — doesn't exist, not a real thing.</p>
    </CalloutBox>
  </div>
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
  supportLine="CLAUDE.md, commands, skills, rules, MCP — all the same split. Know it once, know it everywhere."
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
