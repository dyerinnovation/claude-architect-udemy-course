# Demo 2 — Infrastructure Build Scripts

This directory is the source of truth for the files the deploy script
copies into `/tmp/demo-2-team-workflow/`.  Running
`./deploy-demo-2-claude-code-team-workflow.sh` produces a complete,
standalone repo that demonstrates the Claude Code team-workflow
configuration from the recording script.

## Why `dot-claude/` instead of `.claude/` in this directory

The course repo's editing sandbox blocks writes to any path inside a
`.claude/` directory to protect the course's own tooling config.  To
work around that while still shipping real files, the source of truth
here uses `dot-claude/` and the deploy script renames it to `.claude/`
on copy.  Students working in the bootstrapped `/tmp/` repo see the
correct `.claude/` path — only this staging directory is different.

## File-by-file walk-through

### `deploy-demo-2-claude-code-team-workflow.sh`
Bootstraps `/tmp/demo-2-team-workflow/` from the files in this
directory.  Renames `dot-claude/` to `.claude/` on copy, marks
`ci-example/review.sh` executable, runs `git init` so the CLAUDE.md
hierarchy discovery sees a proper repo root, and prints next-step
hints.  Idempotent — re-running wipes and recreates the target.

### `cleanup-demo-2-claude-code-team-workflow.sh`
Removes `/tmp/demo-2-team-workflow/`.  Reminds the viewer to `unset
ANTHROPIC_API_KEY` manually if they set it (a subshell cannot unset
exports in the caller).

### `CLAUDE.md`
The project-level CLAUDE.md that the team checks into the repo.
Covers universal conventions (TypeScript strictness, error class
hierarchy, test framework choice, commit rules) plus pointers to the
slash command, the skill, and the two rule files.  This file is the
layer every teammate's Claude loads automatically.

### `dot-claude/rules/api-rules.md`
YAML frontmatter: `paths: ["src/api/**/*.ts"]`.  Loads only when the
file being edited matches the glob.  Codifies HTTP-handler
conventions: Zod validation, `AppError` subclassing, `requireAuth`
placement, PII-safe logging.  In the demo we open
`example-project/src/api/handler.ts` and these rules should cite
themselves; we then open a non-matching file and confirm they do not.

### `dot-claude/rules/testing-rules.md`
YAML frontmatter: `paths: ["**/*.test.ts", "**/*.test.tsx"]`.  Loads
only inside Vitest test files.  Covers test-file layout, naming,
mocking strategy, and a red-flag list used by `/review`.

### `dot-claude/commands/review.md`
Shared `/review` slash command, project-scoped so every teammate
inherits it.  Frontmatter includes `argument-hint` and
`allowed-tools` restricted to read-only surfaces so the command
cannot accidentally modify files.  The body is the prompt template
that instructs Claude to evaluate the target against CLAUDE.md and
whichever rule file matches the path.

### `dot-claude/skills/code-review/SKILL.md`
Heavier read-only review.  Frontmatter carries the two exam-relevant
knobs:

- `context: fork` — sub-agent execution so the skill's many tool
  calls do not pollute the main conversation.
- `allowed-tools: [Read, Grep, Glob]` — capability bounding at the
  skill layer.

The skill returns a three-section markdown summary (summary /
findings / suggested patch) to the main session.  Use it when the
review needs to traverse multiple files; use `/review` for a
single-file pass.

### `example-project/src/api/handler.ts`
A small, canonical HTTP handler that exemplifies everything
`api-rules.md` prescribes.  It is the file the recording script opens
to demonstrate glob-scoped rule loading.  Deliberately narrow in
scope — the point of this file is to trip the glob, not to be a
production-shaped API.

### `schema.json`
Draft-07 JSON schema used by the CI example.  Defines the
`status` / `summary` / `issues[]` shape a PR bot can reliably
consume.  Every `issue` is tagged with `severity`, `file`, `line`,
`message`, and an optional `rule` name that points back at the rule
file that was violated — so downstream pipelines can route comments
by rule.

### `ci-example/review.sh`
One-file illustration of `claude -p` in CI.  Reads a diff (or a
single file, if there is no diff yet), sends it to Claude Code
headlessly with `--output-format json --json-schema schema.json`,
and pretty-prints the structured response with `jq`.  Drop-in
translation to a GitHub Actions step is in
`../supplementary/ci-cd-pipeline/` if you want the full pipeline.

## Verify the deploy

```bash
./deploy-demo-2-claude-code-team-workflow.sh
tree /tmp/demo-2-team-workflow -L 3 -a
```

Expected shape:

```
/tmp/demo-2-team-workflow/
├── .claude/
│   ├── commands/review.md
│   ├── rules/
│   │   ├── api-rules.md
│   │   └── testing-rules.md
│   └── skills/code-review/SKILL.md
├── CLAUDE.md
├── ci-example/review.sh
├── example-project/src/api/handler.ts
└── schema.json
```

## Cleanup

```bash
./cleanup-demo-2-claude-code-team-workflow.sh
unset ANTHROPIC_API_KEY   # run in your own shell if you set it
```
