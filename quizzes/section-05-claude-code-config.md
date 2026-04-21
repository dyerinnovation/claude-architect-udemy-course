# Quiz: Claude Code Configuration (Domain 3)

Domain 3 - Claude Code Configuration & Workflows (20% of exam). Primary scenarios: 2, 4, 5.

---

## Question 1
**A new teammate clones the repo and runs Claude Code. They report that none of the coding-style conventions the rest of the team depends on are being applied. Which CLAUDE.md configuration mistake is the most likely cause?**

- A) The conventions were written into `~/.claude/CLAUDE.md` on the original author's machine instead of committed to the repo
- B) The project CLAUDE.md is too long and `@import` isn't being used
- C) The project CLAUDE.md is missing `context: fork` in its frontmatter
- D) The teammate hasn't run `/compact` yet, so older conventions aren't loaded

**Correct Answer**: A

### Explanation
`~/.claude/CLAUDE.md` is user-scoped and machine-local, so anything authored there never reaches the repo. The "new teammate doesn't get conventions" bug is almost always a CLAUDE.md that lives at the wrong hierarchy level. (B) is a real CLAUDE.md problem but doesn't explain a totally missing convention — the teammate would still see something. (C) is nonsense: `context: fork` is a SKILL.md frontmatter option, not a CLAUDE.md property. (D) `/compact` condenses session history; it has nothing to do with loading conventions.

**Domain**: Domain 3 · **Scenarios**: 2, 4, 5 · **Format**: Multiple choice

---

## Question 2
**True or False: `.claude/rules/testing.md` with frontmatter `paths: ["**/*.test.tsx"]` will be loaded into Claude's context on every session, regardless of which files the user is editing.**

- A) True
- B) False

**Correct Answer**: B (False)

### Explanation
Path-scoped rules in `.claude/rules/` with a `paths:` glob only load conditionally — when the files being edited match the glob. That's the whole point of the pattern: ship test-file conventions that live quietly until Claude touches a matching file. If you want a rule to load every session, use `@import` from CLAUDE.md instead. The almost-right trap is conflating `.claude/rules/` (conditional) with `@import` (always-on).

**Domain**: Domain 3 · **Scenarios**: 2, 5 · **Format**: True/False

---

## Question 3
**A team wants a `/review` slash command available to every developer who clones the repo. Where should the command file live?**

- A) `~/.claude/commands/review.md` on each developer's machine
- B) `.claude/commands/review.md` at the project root, committed to git
- C) `.claude.json` under a `commands` key at the project root
- D) `CLAUDE.md` at the project root, with the command body as a fenced code block

**Correct Answer**: B

### Explanation
Project-scoped commands live in `.claude/commands/` at the repo root and ship with the repository — exactly what "available when any developer clones the repo" requires. (A) is the personal location and ships with nothing. (C) isn't a real configuration path; `.claude.json` doesn't define slash commands. (D) confuses surfaces — CLAUDE.md carries standards and context, not invokable commands.

**Domain**: Domain 3 · **Scenarios**: 2, 5 · **Format**: Multiple choice

---

## Question 4
**Which two SKILL.md frontmatter fields do the following jobs? Select all that apply.**

- A) `context: fork` — runs the skill in an isolated sub-context so verbose tool output doesn't pollute the main session
- B) `allowed-tools` — restricts which tools the skill may invoke, acting as a safety rail against destructive actions
- C) `description` — prompts the user interactively when arguments are missing
- D) `argument-hint` — enforces a JSON schema on the skill's return value

**Correct Answer**: A and B (multi-select)

### Explanation
`context: fork` isolates the skill's execution context so the main session receives only the skill's final output, not 40 tool-call receipts. `allowed-tools` scopes the tool surface — a "generate report" skill with `allowed-tools: [Read, Write]` can't shell out. (C) swaps the jobs: `description` is how Claude decides when to invoke the skill (same rules as tool descriptions); the interactive prompt on missing args comes from `argument-hint`. (D) is fabricated — `argument-hint` is a UX string, not a schema enforcer.

**Domain**: Domain 3 · **Scenarios**: 2, 4, 5 · **Format**: Multi-select

---

## Question 5
**A team is migrating a monolith to microservices across roughly 40 files. Which Claude Code execution mode fits, and why?**

- A) Direct execution — the task is well-defined, so planning adds unnecessary latency
- B) Direct execution with a pre-written checklist pasted into the prompt
- C) Plan mode — architectural decisions with multiple valid approaches deserve a reviewable plan before any file changes
- D) Plan mode only for the first file, then direct execution for the other 39

**Correct Answer**: C

### Explanation
The plan-mode test is "is there more than one reasonable way to do this?" A monolith-to-microservices split has many valid decompositions, interface boundaries, and migration orders — exactly the shape plan mode is built for. (A) is the classic distractor: experienced developers assume direct execution is always faster, but on architectural work the time saved in planning is paid back many times in avoided rework. (B) doesn't change anything — a pasted checklist still skips the written, reviewable plan. (D) would commit you to an approach based on how the first file happened to go, not on the architecture.

**Domain**: Domain 3 · **Scenarios**: 2, 4, 5 · **Format**: Multiple choice

---

## Question 6
**A CI pipeline invokes `claude "Analyze this PR for security issues"` and the job hangs forever without producing output. Which single change is the correct fix?**

- A) Set the `CLAUDE_HEADLESS=1` environment variable before the call
- B) Pipe `/dev/null` into stdin: `claude "..." < /dev/null`
- C) Add the `-p` flag: `claude -p "Analyze this PR for security issues"`
- D) Add the `--batch` flag to route through the Message Batches API

**Correct Answer**: C

### Explanation
The `-p` flag runs Claude Code non-interactively — exactly what CI needs. Without it, Claude Code opens an interactive session and waits for input that never comes. (A) `CLAUDE_HEADLESS` is not a real environment variable — it's one of the exam's classic plausible-but-fake distractors. (B) redirecting stdin doesn't tell Claude Code it's in a pipeline; the session still initializes expecting interactive input. (D) `--batch` isn't the mechanism either; Message Batches is a distinct API for bulk async jobs, not a flag for `claude` CLI CI invocations.

**Domain**: Domain 3 · **Scenarios**: 5 · **Format**: Multiple choice

---

## Question 7
**A team wants CI/CD output from Claude Code to match a stable JSON shape so downstream tooling can parse it reliably. Which flag combination enforces that?**

- A) `--output-format json` alone
- B) `--output-format json --json-schema ./review-schema.json`
- C) `--p --json` followed by a regex post-processing step
- D) `--structured --validate-schema`

**Correct Answer**: B

### Explanation
`--output-format json` emits structured JSON, but doesn't enforce a specific shape — fields can drift between runs. Pairing it with `--json-schema ./schema.json` pins the output to a contract: downstream parsers don't break when a prompt tweak shifts the fields. (A) alone is common and subtly wrong — it answers "is this JSON?" not "does it match my contract?" (C) `--p` isn't a flag (it's `-p`), and regex post-processing is the thing you're trying to avoid. (D) neither flag exists.

**Domain**: Domain 3 · **Scenarios**: 5 · **Format**: Multiple choice

---

## Question 8
**True or False: Code review in Claude Code is most reliable when the same session that generated the code also reviews it, because the session has full context on the author's intent.**

- A) True
- B) False

**Correct Answer**: B (False)

### Explanation
The opposite is true: the generating session is the worst session to review in, because it carries the reasoning context that justified the code in the first place and is biased toward ratifying it. A fresh session — or a CI run, which is naturally fresh — reviews without that self-justification bias. This is the same principle as multi-instance review in Domain 4 (Lecture 6.14), rendered at the Claude Code surface.

**Domain**: Domain 3 · **Scenarios**: 5 · **Format**: True/False

---

## Question 9
**A skill that brainstorms refactors produces 35 tool calls and roughly 8,000 tokens of exploration output. The main session slows down for the rest of the task. What's the right fix?**

- A) Rewrite the skill's description so Claude invokes it less often
- B) Add `context: fork` to the SKILL.md frontmatter so the skill runs in an isolated context and returns only a summary
- C) Lower the skill's `allowed-tools` list so fewer tools are callable
- D) Delete the skill and use `/compact` at the end of every session instead

**Correct Answer**: B

### Explanation
`context: fork` is the direct fix for "verbose skill pollutes main context." The skill still does its work; the main session receives the distilled output rather than the 35-call transcript. (A) reduces how often pollution happens but doesn't fix it when the skill does run. (C) cuts the tool surface but may break the skill's function without addressing the context bloat. (D) `/compact` is reactive — it condenses after the damage is done, and loses fidelity in the process.

**Domain**: Domain 3 · **Scenarios**: 2, 4 · **Format**: Multiple choice

---

## Question 10
**Which of the following are valid uses of `/memory` and `/compact`? Select all that apply.**

- A) Run `/memory` to list which CLAUDE.md files Claude currently sees in this session — a diagnostic when conventions seem missing
- B) Run `/compact` mid-decision, right when critical state is still in motion, to free up tokens
- C) Run `/compact` at a natural phase boundary (after a design review, before implementation) to reclaim context with minimal loss of active state
- D) Run `/memory` to persist conversation history across sessions permanently

**Correct Answer**: A and C (multi-select)

### Explanation
`/memory` is a diagnostic — it shows the CLAUDE.md files loaded into the current session, which is your first move when a new teammate says "Claude doesn't know our conventions." `/compact` reclaims context by summarizing older turns, and the right time to run it is at a phase boundary where the working state is stable. (B) inverts the rule — compacting mid-decision can erase exactly the state you're about to act on. (D) is a common misconception: `/memory` is session-scoped introspection, not cross-session persistence.

**Domain**: Domain 3 · **Scenarios**: 2, 4 · **Format**: Multi-select
