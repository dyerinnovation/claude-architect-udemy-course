# Demo: Claude Code Team Workflow Configuration

- **Module/Section:** Section 9 — Demo 2
- **Duration:** ~7–9 min
- **Maps to:** Anthropic exam guide, *Preparation Exercise 2 — Configure Claude Code for a Team Development Workflow*

---

## Overview

When a team ships with Claude Code, "what does the agent know" and "what is it allowed to do" have to stop being a per-developer decision. A personal `~/.claude/CLAUDE.md` works for one engineer; it does not scale to a pull request where three teammates' Claudes each interpreted the codebase differently. The fix is a layered, checked-in configuration: a project `CLAUDE.md` for universal standards, `.claude/rules/` with frontmatter globs for path-scoped conventions, `.claude/commands/` for shared slash commands, and `.claude/skills/` with `context: fork` for isolated subtasks. All of it travels with the repo.

This demo walks through a small but realistic team configuration and then shows the same configuration driving CI via `claude -p` (headless/print mode) with a JSON schema that gates merges. You will see the **CLAUDE.md hierarchy** load in order, watch a rule file activate only when a matching path is opened, invoke a shared `/review` slash command, run a skill whose `context: fork` frontmatter keeps its 40 tool calls out of the main conversation, and finally call Claude non-interactively from a CI script with `--output-format json` against a schema a PR bot can reliably parse.

By the end, you should be able to pattern-match the Domain 3 exam scenarios: given a team friction (inconsistent test style, credentials leaking into prompts, PR reviews that drift, noisy skills) you should know which knob to turn — `CLAUDE.md`, a path-scoped rule, a slash command, a forked skill, or a headless CI hook — and why that knob is the right one.

## Learning Objectives

By the end of this demo, you will be able to:

- Explain and walk the **CLAUDE.md hierarchy** — `~/.claude/CLAUDE.md` (personal) → project `CLAUDE.md` (team-shared, checked in) → directory-level `CLAUDE.md` (scope-specific) — and describe how instructions compose.
- Author a `.claude/rules/` file with YAML frontmatter `paths:` globs (e.g. `paths: ["src/api/**/*.ts"]`) and verify it loads only for matching files.
- Ship a **custom slash command** in `.claude/commands/` so every teammate gets the same `/review` behavior without copying a prompt.
- Build a project skill with `context: fork` and `allowed-tools` frontmatter so verbose work (codebase scans, multi-file refactors) runs in an isolated sub-context and returns only a summary.
- Drive Claude Code from a **CI pipeline** using `claude -p "<prompt>" --output-format json --json-schema schema.json`, and show the JSON schema forcing the output shape the PR gate expects.

## Claude Surfaces Used

- **Claude Code CLI** — interactive session plus headless (`-p` / `--print`) mode for CI.
- **CLAUDE.md hierarchy** — user scope, project scope, directory scope.
- **`.claude/rules/`** — YAML-frontmatter rule files with `paths:` globs for conditional loading.
- **`.claude/commands/`** — shared custom slash commands (project-scoped).
- **`.claude/skills/`** — project skills with `context: fork` and `allowed-tools` frontmatter.
- **Headless flags** — `-p`, `--output-format json`, `--json-schema`, `--append-system-prompt`.

## Exam Domain Reinforced

- **Domain 3 — Claude Code Configuration & Workflows (20%)** is the primary target. This demo exercises every bullet in the domain: the hierarchy, `.claude/rules/` with frontmatter globs, custom slash commands, skills, and CI integration via `-p` mode.
- **Domain 5 — Context Management & Reliability (15%)** appears as a cameo via `context: fork`: isolating a verbose skill is a context-hygiene technique, not just a config knob.

## Prerequisites

- **Claude Code CLI** installed and authenticated (`claude --version` prints a version).
- **Git** (for the hierarchy walk — the demo bootstraps a tiny repo).
- **Node.js 18+** (`node --version`) — the `example-project/` uses Node/TypeScript. No build step; we just reference files.
- **Anthropic API key** available as `ANTHROPIC_API_KEY` (only needed for the CI section).

No package installs, no cloud infra. Everything runs against a throwaway directory in `/tmp/` that the deploy script creates.

## Quick Start

### Deploy

```bash
cd demo-2-claude-code-team-workflow-infrastructure-build-scripts
chmod +x deploy-demo-2-claude-code-team-workflow.sh cleanup-demo-2-claude-code-team-workflow.sh ci-example/review.sh
./deploy-demo-2-claude-code-team-workflow.sh
# This creates /tmp/demo-2-team-workflow/ with:
#   CLAUDE.md, .claude/rules/*.md, .claude/commands/review.md,
#   .claude/skills/code-review/SKILL.md, example-project/src/api/handler.ts,
#   schema.json, and ci-example/review.sh
cd /tmp/demo-2-team-workflow
claude   # launch Claude Code in the bootstrapped repo
```

### Walk-through

Follow `demo-2-claude-code-team-workflow-recording-script.md` for the timestamped narration (7–9 min). Key beats: hierarchy walk, path-scoped rule, `/review` slash command, forked skill, then `-p` mode in CI with the JSON schema enforced.

### Cleanup

```bash
cd demo-2-claude-code-team-workflow-infrastructure-build-scripts
./cleanup-demo-2-claude-code-team-workflow.sh
# Removes /tmp/demo-2-team-workflow/ and unsets ANTHROPIC_API_KEY from the current shell.
```

## File Structure

```
demo-2-claude-code-team-workflow/
├── README.md                                             # you are here
├── demo-2-claude-code-team-workflow-recording-script.md  # timestamped walkthrough
├── demo-2-claude-code-team-workflow-infrastructure-build-scripts/
│   ├── README.md                                         # code walk-through
│   ├── deploy-demo-2-claude-code-team-workflow.sh        # bootstrap /tmp repo
│   ├── cleanup-demo-2-claude-code-team-workflow.sh       # tear down
│   ├── CLAUDE.md                                         # project-level CLAUDE.md
│   ├── dot-claude/                                       # staged; deploy renames to .claude/
│   │   ├── rules/
│   │   │   ├── api-rules.md                              # paths: ["src/api/**/*.ts"]
│   │   │   └── testing-rules.md                          # paths: ["**/*.test.ts"]
│   │   ├── commands/
│   │   │   └── review.md                                 # /review slash command
│   │   └── skills/
│   │       └── code-review/
│   │           └── SKILL.md                              # context: fork + allowed-tools
│   ├── example-project/
│   │   └── src/
│   │       └── api/
│   │           └── handler.ts                            # file the api-rules glob matches
│   ├── schema.json                                       # JSON schema used by -p mode in CI
│   └── ci-example/
│       └── review.sh                                     # one-file example of `claude -p` in CI
└── supplementary/
    ├── README.md                                         # frames the two extensions below
    ├── ci-cd-pipeline/                                   # extension: full GitHub Actions example
    └── ci-code-review/                                   # extension: deeper CI code-review patterns
```

## Additional Resources

- Anthropic Exam Guide, *Preparation Exercises* — Exercise 2 (the canonical version of this scenario).
- Anthropic Exam Guide, *Technologies and Concepts* — Claude Code section (CLAUDE.md hierarchy, `.claude/rules/`, `.claude/commands/`, `.claude/skills/` frontmatter, headless/print mode).
- Course scripts — `scripts/section-05-claude-code-config/` (lectures 5.3–5.8 cover every surface used here).
- Claude Code docs — CLAUDE.md, skills, custom slash commands, `claude -p` headless mode.
- **Extensions** (optional, deeper CI patterns): `supplementary/ci-cd-pipeline/` and `supplementary/ci-code-review/`.
