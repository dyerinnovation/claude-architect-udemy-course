---
name: code-review
description: Deep, read-only code review that walks the file plus its neighbours and returns a concise findings summary.  Runs in a forked sub-context so the main conversation stays clean.
context: fork
allowed-tools:
  - Read
  - Grep
  - Glob
---

# code-review skill

This skill is heavier than the `/review` slash command.  It is meant
for "I want Claude to really dig into this change" — typically a PR or
a multi-file refactor.  Because it reads many files and runs many
searches, the output would pollute the main conversation if it ran
inline.

Two frontmatter fields keep it in check:

- **`context: fork`** — the skill executes in a sub-agent.  Its
  intermediate tool calls and scratch reasoning stay in that
  sub-agent; only the final summary is returned to the main session.
  This is a direct hit on Domain 5's "context hygiene" bullet.
- **`allowed-tools: [Read, Grep, Glob]`** — the skill is read-only by
  construction.  Even if prompted to, it cannot run a Bash command or
  modify a file.  Capability bounding at the skill layer.

## How the skill works

When invoked, the skill:

1. Reads the target file (passed as a skill argument or inferred from
   the user's last message).
2. Uses `Grep` / `Glob` to locate:
   - The matching test file (`*.test.ts` in the same directory).
   - Any sibling handlers in `src/api/` that show the canonical shape.
   - Any `.claude/rules/` file whose `paths:` glob matches the target.
3. Loads the project `CLAUDE.md` for baseline conventions.
4. Synthesizes a findings list using the same severity taxonomy as
   `/review` (CRITICAL / HIGH / MEDIUM / LOW).

## What it returns

A short markdown block with three sections:

1. **Summary** — one paragraph, suitable for a PR comment header.
2. **Findings** — bulleted list, severity-tagged and line-numbered.
3. **Suggested patch** — a short code fence showing the smallest fix
   for the most important finding.  If no fix is obvious, omit this
   section.

The main conversation sees only those three sections — not the dozens
of Read / Grep / Glob calls the skill issued to get there.  That is
the whole point of `context: fork`.

## When to use this vs `/review`

- Use `/review` for a quick, inline pass on a single file.
- Use this skill when the review should consider the whole API
  surface, a PR spanning several files, or when the main conversation
  is already crowded and you do not want to add fifty tool-call
  receipts to it.
