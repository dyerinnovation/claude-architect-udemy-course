---
name: api-rules
description: Conventions for HTTP handlers under src/api/
paths:
  - "src/api/**/*.ts"
---

# API handler rules

These rules load only when Claude Code is working with a file whose
path matches one of the globs above (see the `paths:` frontmatter
block).  Do not restate these conventions in the project `CLAUDE.md` —
scoping them here is the whole point.

## Request and response shape

- Every exported handler must be typed as
  `(req: AppRequest, res: AppResponse) => Promise<void>`.
- Never reach into `req.body` without parsing it through a Zod schema
  defined in the same module or under `src/api/schemas/`.
- Responses use `res.json(...)` with an explicit status code
  (`res.status(200).json(...)`).  Do not rely on default 200.

## Errors

- Throw `AppError` subclasses — never bare `Error`.  The API middleware
  maps known error subclasses to HTTP status codes; a bare `Error`
  becomes a 500 and loses the category.
- Transient, retryable failures must throw `TransientError` so the
  client-side retry middleware can distinguish them from validation
  errors.

## Logging

- Use the `logger` imported from `src/lib/logger.ts`.  No `console.log`.
- Log at `info` on request entry and at `warn` on handled errors.
- Never log request bodies that could contain PII (emails, phone
  numbers, addresses) — log the shape (`typeof body`, key count), not
  the values.

## Authn and authz

- Every route that is not explicitly public must call
  `requireAuth(req)` as the first line of the handler.
- `requireAuth` throws if the session is missing or expired.  Do not
  wrap it in a try/catch — let the API middleware turn it into a 401.

## When in doubt

Look at `example-project/src/api/handler.ts` for the canonical shape.
If this rule file and `CLAUDE.md` disagree, this file wins — it is
closer to the file being edited.
