---
name: testing-rules
description: Conventions for Vitest test files across the repo
paths:
  - "**/*.test.ts"
  - "**/*.test.tsx"
---

# Testing rules

This rule file loads only when editing a Vitest test file.  It does
not load when editing implementation code, so you can keep the
test-only conventions out of the way for ninety percent of editing
sessions.

## File layout

- Co-locate the test with the source: `foo.ts` and `foo.test.ts` live
  in the same directory.  Never introduce a parallel `tests/` tree.
- One top-level `describe` per exported symbol.  Nested `describe` is
  fine for grouping by behaviour.

## Test-writing conventions

- Every test begins with `import { describe, it, expect } from "vitest"`.
- Prefer `it("should <observable behaviour>", ...)` over vague names
  like `it("works", ...)`.  Descriptive names are the test's headline.
- Each `it` block should assert ONE behaviour.  Multiple expects are
  fine; multiple unrelated behaviours are not.
- Use `beforeEach` to reset mocks; never rely on state from a previous
  test.  Cross-test pollution is a red flag.

## Mocking

- Use `vi.mock()` for module-level replacement and `vi.spyOn()` for
  instance methods.  Do not hand-roll replacement objects.
- Mock at the service layer (e.g. the order-service client), not at
  the HTTP layer — tests that mock `fetch` directly are brittle.

## Async

- Use `async/await`.  No callback-style `done()`.
- For promises that should reject, use `await expect(promise).rejects.toThrow(...)`.

## Red flags to flag as `critical` in `/review`

- A test file with zero test blocks.
- A test that sleeps (`await new Promise(r => setTimeout(r, ...))`).
- Queries by CSS class or id in UI tests (use `getByRole` / `getByLabelText`).
- `expect(true).toBe(true)` or any placeholder assertion.

## What to leave alone

- Snapshot tests are discouraged but not banned; do not delete
  existing ones without discussing in PR review.
