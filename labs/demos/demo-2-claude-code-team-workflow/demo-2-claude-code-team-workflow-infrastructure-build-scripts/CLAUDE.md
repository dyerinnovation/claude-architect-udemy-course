# CLAUDE.md — Acme Commerce API

This file is the **project-level** Claude Code configuration for the Acme
Commerce API.  It is checked into the repo, and every teammate's Claude
Code session loads it automatically.  Personal preferences belong in
`~/.claude/CLAUDE.md`; directory-scoped overrides belong in the nearest
`CLAUDE.md` inside a subtree.

## Project snapshot

- **Language:** TypeScript 5.x on Node 20.
- **Runtime shape:** an HTTP API under `example-project/src/api/` + a
  handful of utilities under `example-project/src/lib/`.
- **Test framework:** Vitest.  Test files sit next to the code they
  cover as `*.test.ts` — no separate `tests/` tree.
- **Formatter / linter:** Prettier + ESLint with the Acme shared config.
  Do not hand-format; run the tooling.
- **Package manager:** pnpm.  Never invoke `npm install` or `yarn` here.

## Conventions that apply to the whole repo

1. Prefer narrow, explicit TypeScript types.  Never widen to `any`
   without a `// eslint-disable-next-line @typescript-eslint/no-explicit-any`
   comment that explains why.
2. All exported functions must have JSDoc with `@param` and `@returns`
   blocks.  Internal helpers do not need JSDoc.
3. Errors thrown across a module boundary must be subclasses of the
   domain `AppError` base class, not bare `Error`.
4. Do not introduce a new dependency without opening a dependency ADR
   in `docs/adrs/`.  This is a hard rule — team lead approval required.
5. Do not invent a second test framework.  If you think we need one,
   stop and ask.

## How to pick up work

- Small, single-file bug fix → just edit it.  Plan mode is overkill.
- Multi-file refactor or library upgrade → start in **plan mode**, show
  the plan, get approval, then execute.
- Brand-new feature with multiple valid designs → plan mode, and
  surface at least two approaches before writing code.

## Slash commands available in this repo

- `/review <path>` — runs the shared code-review template against the
  file.  Defined in `.claude/commands/review.md`.

## Skills available in this repo

- `code-review` — deeper read-only review that runs in a forked
  sub-context so its tool calls do not pollute the main conversation.
  Defined in `.claude/skills/code-review/SKILL.md`.

## Rules that load conditionally

- `.claude/rules/api-rules.md` loads only for files under
  `src/api/**/*.ts`.
- `.claude/rules/testing-rules.md` loads only for `*.test.ts` files.

## What to leave alone

- The `.claude/` directory is team-shared.  If you want a personal
  tweak, put it in `~/.claude/` on your own machine.
- Generated code in `example-project/dist/` is ignored; do not edit it.
