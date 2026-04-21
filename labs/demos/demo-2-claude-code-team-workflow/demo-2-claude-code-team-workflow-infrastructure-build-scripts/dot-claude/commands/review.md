---
name: review
description: Structured code review against team standards.  Invokes rules scoped to the target path.
argument-hint: "<path-to-file>"
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash(git:*)
---

# /review

Perform a structured, read-only code review of the file the user
passed as `$ARGUMENTS`.  Do not modify the file.  Do not run tests.
Just read, think, and report.

## What to do, in order

1. Resolve the path.  If `$ARGUMENTS` is empty, ask for a path and
   stop.  If the path does not exist, say so and stop.
2. Read the file.  If it is a test file (`*.test.ts` / `*.test.tsx`),
   the rules in `.claude/rules/testing-rules.md` apply.  If it is under
   `src/api/**/*.ts`, the rules in `.claude/rules/api-rules.md` apply.
   Claude Code will load the matching rule automatically — just trust
   the glob and act on whatever guidance you see.
3. Evaluate the file against:
   - The project `CLAUDE.md` (universal standards).
   - Whichever `.claude/rules/` file matched (path-scoped standards).
   - Common-sense correctness, security, and readability.
4. Produce a report with the sections below.

## Report shape

Use this exact structure — no prose outside it:

### Summary
One or two sentences.  Call out the single most important finding.

### Issues
A bulleted list.  Each bullet is one issue, prefixed with a severity
tag and the line number:

- `[CRITICAL] line 42 — <message>` — a security bug, missing auth, or
  anything that must block merge.
- `[HIGH] line 17 — <message>` — missing tests, wrong convention,
  broken type, something a reviewer would definitely flag.
- `[MEDIUM] line 88 — <message>` — style / clarity.
- `[LOW] line 101 — <message>` — nits and doc suggestions.

If a class of issue is absent, omit the whole bullet — do not say
"no critical issues" just to fill space.

### Recommended next step
One concrete action, e.g. "add auth check at top of handler" or
"extract Zod schema to `src/api/schemas/orders.ts`".

## Tone

Short, concrete, and cite line numbers.  Imagine the author will read
the output and edit the file immediately; long preambles waste their
time.
