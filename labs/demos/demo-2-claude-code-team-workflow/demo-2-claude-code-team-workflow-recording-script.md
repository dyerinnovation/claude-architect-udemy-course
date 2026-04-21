# Demo: Claude Code Team Workflow Configuration — Recording Script

- **Section:** 9 | **Demo:** 2 | **Duration:** 7–9 min
- **Maps to:** Anthropic exam guide, *Preparation Exercise 2*
- **Primary exam domain:** Domain 3 — Claude Code Configuration & Workflows (20%)

---

## [0:00] Opening — why a team-wide config matters

**Narration (2–4 sentences):**

"If your team ships with Claude Code, you already know the pain: one engineer's Claude writes Vitest, another's writes Jest, a third invents a bespoke assertion style, and the PR is suddenly three different codebases in a trench coat. The fix is not to DM your prompt to the team — it's to check a configuration into the repo so every Claude in every clone behaves the same way. In the next eight minutes we'll walk the exact four knobs the exam tests for Domain 3: the CLAUDE.md hierarchy, path-scoped `.claude/rules/`, shared slash commands, and a skill with `context: fork`. Then we'll show the same config driving a CI gate via `claude -p`."

**On-screen actions:**

- Open a terminal, show `tree /tmp/demo-2-team-workflow -L 2` to establish the shape of the bootstrapped repo.
- Slide or title card: "Demo 2 — Team Workflow Config — Domain 3 (20%)".

---

## [0:45] Walking the CLAUDE.md hierarchy — root → project → personal

**Narration:**

"Claude Code layers three CLAUDE.md files. The project one, at the repo root, is checked in and authoritative for the team. A directory-level CLAUDE.md inside, say, `src/api/`, scopes instructions to that subtree. And `~/.claude/CLAUDE.md` is personal — my machine, my preferences, never shared. All three compose; more specific wins when they conflict. The exam will absolutely give you a scenario where a team convention is being overridden by someone's personal file, and the right answer is almost always 'move it to the project CLAUDE.md.'"

**On-screen actions:**

- `cat /tmp/demo-2-team-workflow/CLAUDE.md` — highlight the testing conventions block and the "do not invent new frameworks" rule.
- `cat ~/.claude/CLAUDE.md | head -20` (or a placeholder) to show personal scope exists separately.
- Draw or show a three-layer diagram: personal → project → directory.

---

## [1:45] `.claude/rules/` with glob frontmatter — scoped rule loading

**Narration:**

"`.claude/rules/` is the scalpel. Instead of jamming every convention into one CLAUDE.md, I write one rule file per concern and gate it with a `paths:` glob in the YAML frontmatter. This rule — `api-rules.md` — only loads when someone is editing `src/api/**/*.ts`. Open a React component, it stays out. Open our API handler, it's injected. That's how you stop rule files from fighting for context budget and how you keep API conventions from bleeding into your unrelated UI work."

**On-screen actions:**

- `cat /tmp/demo-2-team-workflow/.claude/rules/api-rules.md` — frontmatter visible, `paths: ["src/api/**/*.ts"]` highlighted.
- In Claude Code, open `example-project/src/api/handler.ts` and ask "what style rules apply here?" — Claude should cite the API rules.
- Open a non-matching path (e.g. a README) and re-ask — API rules no longer cited.

---

## [3:00] Custom slash command walk-through — `/review`

**Narration:**

"A slash command is just a markdown file under `.claude/commands/`. This one is `review.md`, and it lives in the project, not in my home dir — which means every teammate who clones this repo gets `/review` for free, with the exact same instructions. The body of the file is the prompt template; `$ARGUMENTS` takes the filename the user passes. Watch: `/review example-project/src/api/handler.ts`. Claude loads the file, pulls the API rules (because the path matches the glob), and runs the review checklist the command prescribes."

**On-screen actions:**

- `cat /tmp/demo-2-team-workflow/.claude/commands/review.md` — show the prompt body and `$ARGUMENTS` substitution.
- In Claude Code: type `/review example-project/src/api/handler.ts` and show the structured review output.
- Call out: the command is portable because it's checked in; personal commands live at `~/.claude/commands/`.

---

## [4:00] A skill with `context: fork` — isolation in action

**Narration:**

"Skills are the heavier hammer. A skill can invoke tools, read dozens of files, run commands — and that's exactly what makes them dangerous to your context window. `context: fork` is the answer. With fork, the skill runs in a sub-agent, does its 40 tool calls over there, and returns a clean summary to the main conversation. No 10,000-token transcript polluting your session. I also pin `allowed-tools` so the skill cannot reach for Bash or write to disk when its job is read-only review. That's two layers of blast-radius control in one frontmatter block."

**On-screen actions:**

- `cat /tmp/demo-2-team-workflow/.claude/skills/code-review/SKILL.md` — frontmatter: `context: fork`, `allowed-tools: [Read, Grep, Glob]`.
- Invoke the skill on the same handler.ts file; note that the main conversation receives a summary, not the intermediate tool-call log.
- Whiteboard callout: "fork = sub-agent context = you pay the cost once, you get the summary back."

---

## [5:00] `-p` mode CI integration — Claude in a shell script

**Narration:**

"The same config we just walked through also drives CI. `claude -p` runs Claude Code headlessly — no REPL, prompt in, response out, good for shell scripts and GitHub Actions. Pair it with `--output-format json` and `--json-schema schema.json` and you get structured, schema-validated output that a PR bot can parse without regex gymnastics. Here's the one-liner we're about to run."

**On-screen actions:**

- Show `ci-example/review.sh`:
  ```
  claude -p "Review the diff in $PR_DIFF and respond with the schema." \
    --output-format json \
    --json-schema ../schema.json
  ```
- Mention that `ANTHROPIC_API_KEY` must be set; point at CI secrets in a real pipeline.

---

## [6:30] Handoff output — the JSON schema enforced

**Narration:**

"And this is the whole point. The response isn't prose — it's a JSON object with `status`, `issues[]`, each issue typed with `severity` and `file` and `line`. Our GitHub Action can branch on `status == 'block'` and post inline comments from `issues[]` without any parsing code. If the model tries to return free-form text, Claude Code re-prompts until the schema validates — that retry loop is free, and it's exactly the reliability pattern Domain 3 and Domain 5 both want you to know."

**On-screen actions:**

- Run `./ci-example/review.sh` (or show a canned response file to keep the recording deterministic).
- `cat` the JSON output and pretty-print with `jq`. Point at `status`, `issues[0].severity`, `issues[0].file`.
- Open `schema.json` side-by-side so viewers see the contract.

---

## [7:30] Recap + exam framing

**Narration:**

"Let's bank it. Four knobs, one place each lives, one problem each solves. Project CLAUDE.md: universal standards, checked in. `.claude/rules/` with `paths:` globs: scoped conventions that only load when relevant. `.claude/commands/`: shared slash commands so the team shares prompts, not DMs. `.claude/skills/` with `context: fork`: heavy work in isolation. And `claude -p` with `--json-schema`: the same config enforced in CI. That entire stack is where Domain 3 lives — twenty percent of the exam — and if a question gives you a team-friction scenario, your job is to pick the knob that fits. Next demo, we move to structured data extraction."

**On-screen actions:**

- Recap slide with a 5-row table: knob → file path → problem it solves.
- Closing card: "Next — Demo 3: Structured Data Extraction."

---

## Optional overtime — supplementary/ extensions

If you have extra time (demo is under 8 minutes), point at `supplementary/ci-cd-pipeline/` and `supplementary/ci-code-review/` as deeper CI patterns — full GitHub Actions YAML and a richer review skill — and tell students the core four knobs they just saw are the exam-relevant surface; the supplementaries are for when they're building this for real.
